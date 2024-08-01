CREATE OR REPLACE package body LOGIS.sc_reportes is

  -- private type declarations
  --type <typename> is <datatype>;

  -- private constant declarations
  gv_crlf constant varchar2(2) := chr(13) || chr(10);

  -- private variable declarations
  gv_rep_clave varchar2(6);
  gv_sysdate   date;
  gv_modulo    varchar2(100);

  -- function and procedure implementations
  function gen_rep_clave return varchar2 is
    vrep_clave varchar2(6);
  begin
    vrep_clave := trim(to_char(round(dbms_random.value(1, 999999)),
                               'XXXXXX'));
    return vrep_clave;
  exception
    when others then
      return null;
  end;

  procedure clean(prep_clave in varchar2) is
    vdia varchar2(10);
    vinc number;
  begin
    vdia := lower(to_char(sysdate, 'dy'));
  
    if vdia = 'mon' or vdia = 'lun' then
      vinc := 5;
    else
      vinc := 3;
    end if;
  
    delete contenido_reporte t
     where t.date_created < trunc(sysdate) - vinc;
    delete contenido_reporte t where t.repid = prep_clave;
    commit;
  end;
  --

  procedure log_sql(pmodulo    in varchar2 default gv_modulo,
                    paccion    in varchar2,
                    pinstancia in varchar2 default null) is
    pragma autonomous_transaction;
  begin
    insert into emodulos_usados
      (modulo, accion, instancia, usuario, fecha)
    values
      (substr(pmodulo, 1, 100),
       substr(gv_rep_clave || ': ' || paccion, 1, 200),
       substr(pinstancia, 1, 50),
       user,
       sysdate);
    --
    commit;
  exception
    when others then
      rollback;
  end;
  --

  procedure flush(pvalue      in out clob,
                  pno_linea   in out number,
                  pfinal      in boolean default false,
                  pforce_save in boolean default false) is
  begin
    if pvalue is not null and dbms_lob.getlength(pvalue) > 0 then
      insert into contenido_reporte
        (repid, no_linea, content)
      values
        (gv_rep_clave, pno_linea, pvalue);
    
      pno_linea := pno_linea + 1;
    
      if mod(pno_linea, 1000) = 0 or pforce_save then
        log_sql(paccion => 'Commit a las ' || pno_linea ||
                           ' lineas archivo ');
        commit;
      end if;
    end if;
  
    pvalue := null;
    --dbms_lob.freetemporary(pvalue);
  
    if not pfinal then
      dbms_lob.createtemporary(pvalue, true);
    end if;
  end;
  --

  procedure append_data(pcontent  in out clob,
                        pno_linea in out number,
                        pvalue    in varchar2,
                        padd_crlf boolean := true) is
    vstring varchar2(4000);
  begin
    vstring := null;
  
    if pvalue is not null then
      vstring := pvalue;
    end if;
  
    if padd_crlf then
      vstring := vstring || gv_crlf;
    end if;
  
    dbms_lob.append(pcontent, vstring);
  
    if padd_crlf then
      flush(pcontent, pno_linea);
    end if;
  end;

  --
  procedure append_new_line(pcontent in out clob, pno_linea in out number) is
  begin
    append_data(pcontent, pno_linea, null);
  end;

  --

  procedure put_data(pcontent  in out clob,
                     pno_linea in out number,
                     pformato  in varchar2,
                     pdata     in varchar2) is
  begin
    append_data(pcontent,
                pno_linea,
                pformato || '|' || pdata || '|',
                false);
  end;
  --

  procedure step_folios_egr_ing_pend(pmsg       out varchar2,
                                     prep_clave in varchar2,
                                     pemp       in number,
                                     pdiv       in varchar2,
                                     pfecha_max in varchar2) is
    /*
    * varibles locales
    */
    vcontent   clob;
    vno_linea  number := 1;
    vfecha_max date;
  
    --
    abrev         varchar2(50);
    fecha_cierre  date;
    fol_clv       number;
    fct_num       varchar2(1000);
    fct_fecha     varchar2(1000);
    ped_fecha     date;
    dpc_importe   number;
    costo_directo number;
  
    last_cli  number;
    last_anio number;
    last_bim  number;
    anio_max  number;
    anio_base number := 2005;
  
    debugmode varchar2(2) := 'NO';
  
    cur_anio number;
  
    milastcli number;
    milastnom varchar2(200);
  
    tot_antcli number;
    tot_erocli number;
    mi_difcli  number;
  
    mi_diffol number;
  
    f_pago date;
  
    ya_insertado number := 0;
  
    /*
    * cursores locales
    */
    -- cursor folios
    cursor folios(fec_cierre date) is
      select /*+ use_nl(fol, dpc, cli) */
       fol.fol_cliclef cliclef,
       cli.clinom,
       fol.folclave,
       fol.folfolio,
       fol.fol_douclef,
       fol.fol_ycxclef,
       dtc.dtcclef dtcclf,
       dtc.dtcconcept tipo,
       'ING' orig,
       dtc.dtccheque renglon,
       dtc.date_created fecha_int,
       to_number(null) erogac,
       decode(dtcconcept, 'I01', nvl(dtc.dtcsomme, 0), 0) ingreso,
       0 egreso,
       0 gar,
       to_char(null) nombreerog,
       0 interco,
       decode(dtcconcept, 'I09', -1 * nvl(dtc.dtcsomme, 0), 0) garantia
        from (select /*+ index (dtc idx_dtcconcept) */
               dtcclef,
               dtcconcept,
               dtc.date_created,
               dtccheque,
               dtcsomme,
               dtcfolio
                from edetailcheque dtc
               where nvl(dtc.date_modified, dtc.date_created) <= fec_cierre
                 and dtccheque >= 336477
                 and dtc.dtcconcept in ('I01', 'I09')
                 and dtcfolio is not null
                 and exists (select null
                        from edepotcheque
                       where dpcclef = dtccheque
                         and dpc_empclave = pemp
                         and dpcdivisa = pdiv
                         and rownum = 1)
                 and not exists
               (select 1
                        from efacturas fct
                       where fct.fctclef = dtc.dtcfacture
                         and fct.fct_yfaclef in ('1', '2', '3')
                         and fct.fctdatefacture < vfecha_max + 1
                         and rownum = 1)) dtc,
             edepotcheque dpc,
             efolios fol,
             eclient cli
       where dpc.dpc_empclave = pemp
         and dpc.dpcdate <= vfecha_max
         and dpcdate >= to_date('01/01/2013', 'DD/MM/YYYY')
         and dpcclef >= 336477
         and dpc.dpcdivisa = pdiv
         and dpcetat = 'A'
         and dtc.dtccheque = dpc.dpcclef
         and fol.folclave = dtc.dtcfolio
         and cli.cliclef = fol.fol_cliclef
      union all
      select /*+ use_nl( fol, sbq, cli, cho) */
       fol.fol_cliclef,
       cli.clinom,
       fol.folclave,
       fol.folfolio,
       fol.fol_douclef,
       fol.fol_ycxclef,
       soa.soaclef,
       soa.soatype,
       decode(soa.soatype, 'E01', 'E_EGR', 'E12', 'G_EGR', '?_EGR'),
       soa.soasortie,
       soa.date_created,
       cho.chonumero,
       0,
       decode(soa.soatype, 'E01', soa.soasomme, 0),
       decode(soa.soatype, 'E12', soa.soasomme - nvl(soa.soaiva, 0), 0),
       cho.chonombre,
       0 interco,
       decode(soa.soatype, 'E09', soa.soasomme, 0) garantia
        from (select soasortie,
                     soatype,
                     soa.date_created,
                     soa_choclave,
                     soasomme,
                     soaiva,
                     soa_sbqanio,
                     soafolio,
                     soaclef
                from esortieargent soa
               where soa.soa_sbq_empclave = pemp
                 and soa_sbqanio >= 2013
                 and soa.soafolio is not null
                 and soa.soatype in ('E01', 'E12', 'E09')
                 and nvl(soa.date_modified, soa.date_created) <= fec_cierre
                 and not exists
               (select 1
                        from efacturas fct
                       where fct.fctclef = soa.soafacture
                         and fct.fct_yfaclef in ('1', '2', '3')
                         and fct.fctdatefacture < vfecha_max + 1
                         and rownum = 1)) soa,
             esortiebanque sbq,
             efolios fol,
             econceptoshoja cho,
             eclient cli
       where sbq.sbq_empclave = pemp
         and sbqanio >= 2013
         and sbq.sbqdatefait <= vfecha_max
         and sbq.sbqetat = 'A'
         and sbq.sbqdivisa = pdiv
         and soa.soasortie = sbq.sbqclef
         and soa.soa_sbqanio = sbq.sbqanio
         and fol.folclave = soa.soafolio
         and cho.choclave(+) = soa.soa_choclave
         and cli.cliclef = fol.fol_cliclef
      union all
      select /*+ use_nl( fol, ddi, dia, cho, cli) */
       fol.fol_cliclef,
       cli.clinom,
       fol.folclave,
       fol.folfolio,
       fol.fol_douclef,
       fol.fol_ycxclef,
       ddi.ddiclef,
       ddi.dditype,
       decode(ddi.dditype, 'D01', 'E_DIA', 'D12', 'G_DIA', '?_DIA'),
       ddi.ddidiario,
       ddi.date_created,
       cho.chonumero,
       0,
       decode(ddi.dditype, 'D01', ddi.ddisomme, 0),
       decode(ddi.dditype, 'D12', ddi.ddisomme - nvl(ddi.ddiiva, 0), 0),
       cho.chonombre,
       0 interco,
       decode(ddi.dditype,
              'D09',
              decode(diadebe, 'D', -1, 1) * ddi.ddisomme,
              0) garantia
        from (select /*+ index(ddi idx_ddi_emp_type) */
               ddiclef,
               dditype,
               ddidiario,
               ddi.date_created,
               ddisomme,
               ddiiva,
               ddifolio,
               ddi_choclave,
               ddi_diaanio
                from edetaildiario ddi
               where ddi.ddi_dia_empclave = pemp
                 and ddi_diaanio >= 2013
                 and ddi.ddifolio is not null
                 and ddi.dditype in ('D01', 'D12', 'D09')
                 and nvl(ddi.date_modified, ddi.date_created) <= fec_cierre
                 and not exists
               (select 1
                        from efacturas fct
                       where fct.fctclef = ddi.ddifacture
                         and fct.fct_yfaclef in ('1', '2', '3')
                         and fct.fctdatefacture < vfecha_max + 1
                         and rownum = 1)) ddi,
             ediario dia,
             efolios fol,
             econceptoshoja cho,
             eclient cli
       where dia.dia_empclave = pemp
         and dia.diadate <= vfecha_max
         and dia.diaetat = 'A'
         and diaanio >= 2013
         and dia.diadivisa = pdiv
         and ddi.ddidiario = dia.diaclef
         and ddi.ddi_diaanio = dia.diaanio
         and fol.folclave = ddi.ddifolio
         and cho.choclave(+) = ddi.ddi_choclave
         and cli.cliclef = fol.fol_cliclef
      union all
      select /*+ use_nl( fol, gem, gco, cho, cli)  */
       fol.fol_cliclef,
       cli.clinom,
       fol.folclave,
       fol.folfolio,
       fol.fol_douclef,
       fol.fol_ycxclef,
       gco.gcoclef,
       gco.gcotype,
       decode(gco.gcotype, 'G01', 'E_GAC', 'G12', 'G_GAC', '?_GAC'),
       gco.gcogasto,
       gco.date_created,
       cho.chonumero,
       0,
       decode(gco.gcotype, 'G01', gco.gcosomme, 0),
       decode(gco.gcotype, 'G12', gco.gcosomme - nvl(gco.gcoiva, 0), 0),
       cho.chonombre,
       0 interco,
       0 garantia
        from (select /*+ index(gco idx_gco_emp_type ) */
               gcoclef,
               gcotype,
               gcogasto,
               gcosomme,
               gcoiva,
               gco_choclave,
               gco.date_created,
               gco_gemanio,
               gcofolio
                from egcomprobar gco
               where gco.gco_gem_empclave = pemp
                 and gco_gemanio >= 2013
                 and gco.gcofolio is not null
                 and gco.gcotype in ('G01', 'G12')
                 and nvl(gco.date_modified, gco.date_created) <= fec_cierre
                 and not exists
               (select 1
                        from efacturas fct
                       where fct.fctclef = gco.gcofacture
                         and fct.fct_yfaclef in ('1', '2', '3')
                         and fct.fctdatefacture < vfecha_max + 1
                         and rownum = 1)) gco,
             egastoempleado gem,
             efolios fol,
             econceptoshoja cho,
             eclient cli
       where gem.gem_empclave = pemp
         and gem.gemdate <= vfecha_max
         and gem.gemetat = 'A'
         and gemanio >= 2013
         and gem.gemaffecte = 'S'
         and gem.gem_divclef = pdiv
         and gco.gcogasto = gem.gemclef
         and gco.gco_gemanio = gem.gemanio
         and fol.folclave = gco.gcofolio
         and cho.choclave = gco.gco_choclave
         and cli.cliclef = fol.fol_cliclef
      union all
      select /*+ use_nl( prd, pdd, fol, pdd, cho, cli) */
       fol.fol_cliclef,
       cli.clinom,
       fol.folclave,
       fol.folfolio,
       fol.fol_douclef,
       fol.fol_ycxclef,
       pdd.pddclef,
       pdd.pddtype,
       decode(pdd.pddtype, 'P01', 'E_PRO', 'P12', 'G_PRO', '?_PRO'),
       pdd.pddprovdoc,
       pdd.date_created,
       cho.chonumero,
       0,
       decode(pdd.pddtype, 'P01', pdd.pddsomme, 0),
       decode(pdd.pddtype, 'P12', pdd.pddsomme, 0),
       cho.chonombre,
       0 interco,
       0 garantia
        from (select /*+ index(pdd idx_pdd_emp_type ) */
               pddclef,
               pddtype,
               pddprovdoc,
               pdd.date_created,
               pddsomme,
               pdd_choclave,
               pddfolio,
               pddanio
                from eprovdocdet pdd
               where pdd.pdd_prd_empclave = pemp
                 and pdd.pddfolio is not null
                 and pddanio >= 2013
                 and pdd.pddtype in ('P01', 'P12')
                 and nvl(pdd.date_modified, pdd.date_created) <= fec_cierre
                 and not exists
               (select 1
                        from efacturas fct
                       where fct.fctclef = pdd.pddfacture
                         and fct.fct_yfaclef in ('1', '2', '3')
                         and fct.fctdatefacture < vfecha_max + 1
                         and rownum = 1)) pdd,
             eprovdoc prd,
             efolios fol,
             econceptoshoja cho,
             eclient cli
       where prd.prd_empclave = pemp
         and prd.prddaterev <= vfecha_max
         and prdanio >= 2013
         and prd.prdetat = 'A'
         and prd.prddivisa = pdiv
         and pdd.pddprovdoc = prd.prdclef
         and pdd.pddanio = prd.prdanio
         and (prdproveedor < 9900 or prdproveedor > 9999)
         and fol.folclave = pdd.pddfolio
         and cho.choclave = pdd.pdd_choclave
         and cli.cliclef = fol.fol_cliclef
      union all
      select /*+ use_nl( prd, pdd, fol, pdd, cho, cli) */
       fol.fol_cliclef,
       cli.clinom,
       fol.folclave,
       fol.folfolio,
       fol.fol_douclef,
       fol.fol_ycxclef,
       pdd.pddclef,
       pdd.pddtype,
       decode(pdd.pddtype, 'P01', 'E_PRO', 'P12', 'G_PRO', '?_PRO'),
       pdd.pddprovdoc,
       pdd.date_created,
       cho.chonumero,
       0,
       0,
       0,
       cho.chonombre,
       pddsomme interco,
       0 garantia
        from (select /*+ index(pdd idx_pdd_emp_type ) */
               pddclef,
               pddtype,
               pddprovdoc,
               pdd.date_created,
               pddsomme,
               pdd_choclave,
               pddfolio,
               pddanio
                from eprovdocdet pdd
               where pdd.pdd_prd_empclave = pemp
                 and pdd.pddfolio is not null
                 and pddanio >= 2013
                 and pdd.pddtype in ('P01', 'P12')
                 and nvl(pdd.date_modified, pdd.date_created) <= fec_cierre
                 and not exists
               (select 1
                        from efacturas fct
                       where fct.fctclef = pdd.pddfacture
                         and fct.fct_yfaclef in ('1', '2', '3')
                         and fct.fctdatefacture < vfecha_max + 1
                         and rownum = 1)) pdd,
             eprovdoc prd,
             efolios fol,
             econceptoshoja cho,
             eclient cli
       where prd.prd_empclave = pemp
         and prd.prddaterev <= vfecha_max
         and prdanio >= 2013
         and prd.prdetat = 'A'
         and prd.prddivisa = pdiv
         and pdd.pddprovdoc = prd.prdclef
         and pdd.pddanio = prd.prdanio
         and pdd.pddtype = 'P01'
         and prdproveedor >= 9900
         and prdproveedor <= 9999
         and fol.folclave = pdd.pddfolio
         and cho.choclave = pdd.pdd_choclave
         and cli.cliclef = fol.fol_cliclef
       order by 3;
  
    --
    cursor facturas(fol number) is
      select fct.fctnumero, fct.fctdatefacture
        from efacturas fct
       where fct.fct_empclave = pemp
         and fct.fct_yfaclef = '1'
         and fct.fctfolio = fol
         and fct.fctdivisa = pdiv;
  
    -- 
    cursor res_anual is
      select micli,
             clinom,
             to_number(to_char(mifec, 'YYYY')) anio,
             trunc((to_number(to_char(mifec, 'MM')) - 1) / 6) bim,
             sum(nvl(miant, 0)) ant,
             sum(nvl(mierog, 0)) erog,
             sum(nvl(migar, 0)) gar,
             sum(nvl(miinterco, 0)) interco,
             sum(nvl(migarantia, 0)) garantia
        from emontos_cliente_por_anio mcpa, eclient cli
       where mcpa.created_by = upper(user)
         and to_number(to_char(mifec, 'YYYY')) >= anio_base
         and cliclef = micli
       group by micli,
                clinom,
                to_number(to_char(mifec, 'YYYY')),
                trunc((to_number(to_char(mifec, 'MM')) - 1) / 6)
      union all
      select micli,
             clinom,
             0 anio,
             0,
             sum(nvl(miant, 0)) ant,
             sum(nvl(mierog, 0)) erog,
             sum(nvl(migar, 0)) gar,
             sum(nvl(miinterco, 0)) interco,
             sum(nvl(migarantia, 0)) garantia
        from emontos_cliente_por_anio mcpa, eclient cli
       where mcpa.created_by = upper(user)
         and to_number(to_char(mifec, 'YYYY')) < anio_base
         and cliclef = micli
       group by micli, clinom
       order by 1, 3, 4;
  
    --
    cursor clis is
      select distinct micli, clinom
        from emontos_cliente_por_anio mcpa, eclient
       where mcpa.created_by = upper(user)
         and cliclef = micli
       order by 1;
  
    --
    cursor res_anteriores(mi_anio in number, mi_cli in number default null) is
      select sum(ant) ant,
             sum(erog) erog,
             sum(gar) gar,
             sum(interco) interco,
             sum(garantia) garantia,
             sum(dif_mas) dif_mas,
             sum(dif_menos) dif_menos
        from (select sum(nvl(miant, 0)) ant,
                     sum(nvl(mierog, 0)) erog,
                     sum(nvl(migar, 0)) gar,
                     sum(nvl(miinterco, 0)) interco,
                     sum(nvl(migarantia, 0)) garantia,
                     micli,
                     decode(sign(sum(nvl(miant, 0)) - sum(nvl(mierog, 0))),
                            -1,
                            sum(nvl(miant, 0)) - sum(nvl(mierog, 0)),
                            0) dif_mas,
                     decode(sign(sum(nvl(miant, 0)) - sum(nvl(mierog, 0))),
                            1,
                            sum(nvl(miant, 0)) - sum(nvl(mierog, 0)),
                            0) dif_menos
                from emontos_cliente_por_anio mcpa
               where mcpa.created_by = upper(user)
                 and micli = nvl(mi_cli, micli)
                 and mifec < to_date('01/01/' || to_char(mi_anio, 'FM0000'),
                                     'DD/MM/YYYY')
               group by micli);
  
    --
    cursor res_bimestre(mi_anio in number, mi_cli in number default null) is
      select bim,
             sum(ant) ant,
             sum(erog) erog,
             sum(gar) gar,
             sum(interco) interco,
             sum(garantia) garantia,
             sum(dif_mas) dif_mas,
             sum(dif_menos) dif_menos
        from (select trunc((to_number(to_char(mifec, 'MM')) - 1) / 6) bim,
                     sum(nvl(miant, 0)) ant,
                     sum(nvl(mierog, 0)) erog,
                     sum(nvl(migar, 0)) gar,
                     sum(nvl(miinterco, 0)) interco,
                     sum(nvl(migarantia, 0)) garantia,
                     micli,
                     decode(sign(sum(nvl(miant, 0)) - sum(nvl(mierog, 0))),
                            -1,
                            sum(nvl(miant, 0)) - sum(nvl(mierog, 0)),
                            0) dif_mas,
                     decode(sign(sum(nvl(miant, 0)) - sum(nvl(mierog, 0))),
                            1,
                            sum(nvl(miant, 0)) - sum(nvl(mierog, 0)),
                            0) dif_menos
                from emontos_cliente_por_anio mcpa
               where mcpa.created_by = upper(user)
                 and micli = nvl(mi_cli, micli)
                 and mifec >= to_date('01/01/' || to_char(mi_anio, 'FM0000'),
                                      'DD/MM/YYYY')
                 and mifec <
                     to_date('01/01/' || to_char(mi_anio + 1, 'FM0000'),
                             'DD/MM/YYYY')
               group by micli,
                        trunc((to_number(to_char(mifec, 'MM')) - 1) / 6))
       group by bim;
  
    --
    cursor meses is
      select mes
        from emes
       where mes >= add_months(vfecha_max, -6)
            --    and mes >= trunc(vfecha_max, 'YYYY')
         and mes <= vfecha_max;
  
    --
    cursor res_mes(mi_mes in date) is
      select sum(ant) ant,
             sum(erog) erog,
             sum(gar) gar,
             sum(interco) interco,
             sum(garantia) garantia,
             sum(dif_mas) dif_mas,
             sum(dif_menos) dif_menos
        from (select sum(nvl(miant, 0)) ant,
                     sum(nvl(mierog, 0)) erog,
                     sum(nvl(migar, 0)) gar,
                     sum(nvl(miinterco, 0)) interco,
                     sum(nvl(migarantia, 0)) garantia,
                     micli,
                     decode(sign(sum(nvl(miant, 0)) - sum(nvl(mierog, 0))),
                            -1,
                            sum(nvl(miant, 0)) - sum(nvl(mierog, 0)),
                            0) dif_mas,
                     decode(sign(sum(nvl(miant, 0)) - sum(nvl(mierog, 0))),
                            1,
                            sum(nvl(miant, 0)) - sum(nvl(mierog, 0)),
                            0) dif_menos
                from emontos_cliente_por_anio mcpa
               where mcpa.created_by = upper(user)
                 and mifec >= mi_mes
                 and mifec < add_months(mi_mes, 1)
               group by micli);
  
    --
    cursor mas_financiados is
      select micli,
             clinom,
             sum(nvl(miant, 0)) ant,
             sum(nvl(mierog, 0)) erog,
             sum(nvl(migar, 0)) gar,
             sum(nvl(miinterco, 0)) interco,
             sum(nvl(migarantia, 0)) garantia
        from emontos_cliente_por_anio mcpa, eclient cli
       where mcpa.created_by = upper(user)
         and cliclef = micli
       group by micli, clinom
      having(sum(nvl(miant, 0)) - sum(nvl(mierog, 0))) <= -100000
       order by (sum(nvl(miant, 0)) - sum(nvl(mierog, 0)));
  
    --  
    cursor misfolios is
      select micli,
             clinom,
             mifolio,
             sum(nvl(miant, 0)) ant,
             sum(nvl(mierog, 0)) erog,
             sum(nvl(migar, 0)) gar,
             sum(nvl(miinterco, 0)) interco,
             sum(nvl(migarantia, 0)) garantia,
             folclave
        from emontos_cliente_por_anio mcpa, eclient cli, efolios fol
       where mcpa.created_by = upper(user)
         and cliclef = micli
         and folfolio = mifolio
       group by micli, clinom, mifolio, folclave
       order by 1, 3;
  
    /*
    * procedimientos locales
    */
    procedure put_encabezado(pcontent  in out clob,
                             pno_linea in out number,
                             titulo    in varchar2) is
    begin
      append_data(pcontent, pno_linea, '|NewHoja|' || titulo || '|');
      append_data(pcontent,
                  pno_linea,
                  '|FORMATO_GAL|FontSize=8;FontAlign=Center;FontBold=True|');
      append_data(pcontent, pno_linea, '|Rows|FontSize=14;FontAlign=Left|');
      append_data(pcontent, pno_linea, '|Datos|', false);
    
      put_data(pcontent,
               pno_linea,
               '',
               'FOLIOS CON EGR/ING/GAR PENDIENTES POR FACTURAR INCLUYENDO SALDO ING. PENDIENTES POR INTEGRAR');
    
      append_new_line(pcontent, pno_linea);
      append_data(pcontent, pno_linea, '|Rows|FontSize=12;FontAlign=Left|');
    
      begin
        select empabreviacion
          into abrev
          from eempresas
         where empclave = pemp;
      exception
        when no_data_found then
          abrev := '';
      end;
    
      append_data(pcontent, pno_linea, '|Datos|', false);
      put_data(pcontent,
               pno_linea,
               '',
               'Empresa: ' || abrev || ' - Divisa ' || pdiv);
    
      append_new_line(pcontent, pno_linea);
      append_data(pcontent, pno_linea, '|Datos|', false);
      put_data(pcontent,
               pno_linea,
               'FontAlign=Left',
               'Fecha Max Folio: ' || to_char(vfecha_max, 'DD/MM/RRRR'));
    
      append_new_line(pcontent, pno_linea);
      append_data(pcontent, pno_linea, '|Datos|', false);
      put_data(pcontent,
               pno_linea,
               'FontAlign=Left',
               'Fecha Cierre: ' || to_char(fecha_cierre, 'DD/MM/RRRR'));
    
      append_new_line(pcontent, pno_linea);
      append_data(pcontent, pno_linea, '|Datos|', false);
    
      append_new_line(pcontent, pno_linea);
      append_data(pcontent, pno_linea, '|Datos|', false);
    
      -- TITULOS COLUMNAS --
      put_data(pcontent, pno_linea, '', 'No. Cliente');
      put_data(pcontent, pno_linea, '', 'Razon Social');
      put_data(pcontent, pno_linea, '', 'Ad.');
      put_data(pcontent, pno_linea, '', 'Folio');
      put_data(pcontent, pno_linea, '', 'Fecha Pago');
      put_data(pcontent, pno_linea, '', 'ING Pend. Integrar');
      put_data(pcontent, pno_linea, '', 'Costo Directo');
      put_data(pcontent, pno_linea, '', 'No. Factura');
      put_data(pcontent, pno_linea, '', 'Fecha Factura');
      put_data(pcontent, pno_linea, '', 'Origen');
      put_data(pcontent, pno_linea, '', 'Renglon');
      put_data(pcontent, pno_linea, '', 'Fecha Integr.');
      put_data(pcontent, pno_linea, '', 'clv Erog.');
      put_data(pcontent, pno_linea, '', 'Descripcion Erogacion');
      put_data(pcontent, pno_linea, '', 'Ingresos');
      put_data(pcontent, pno_linea, '', 'Erogaciones');
      put_data(pcontent, pno_linea, '', 'GAR');
      put_data(pcontent, pno_linea, '', 'InterCo');
      put_data(pcontent, pno_linea, '', 'Garantia');
    
      append_new_line(pcontent, pno_linea);
      append_data(pcontent, pno_linea, '|Datos|', false);
    
    end;
  begin
    -- init
    gv_modulo := 'step_folios_egr_ing_pend';
    dbms_lob.createtemporary(vcontent, true);
  
    if prep_clave is null then
      raise_application_error(-20001, 'Falta el parametro Clave Reporte');
    end if;
  
    gv_rep_clave := prep_clave;
  
    if pemp is null or pdiv is null then
      raise_application_error(-20001,
                              'Falta el parametro Empresa o Divisa');
    end if;
  
    clean(gv_rep_clave);
  
    if pfecha_max is null then
      vfecha_max := sysdate;
    else
      vfecha_max := to_date(pfecha_max, 'dd/mm/yyyy');
    end if;
  
    -- reporte >
  
    ----------------------
    --  CALCULO FECHAS  --
    ----------------------
    log_sql(paccion => 'INICIO REPORTE');
  
    if vfecha_max is null then
      fecha_cierre := sysdate;
    else
      select min(coc.date_created)
        into fecha_cierre
        from ecoupecompta coc
       where coc.coc_empclave = pemp
         and coc.cocdate >= vfecha_max;
    
      if fecha_cierre is null then
        fecha_cierre := sysdate;
      end if;
    end if;
  
    ------------------
    --  ENCABEZADO  --
    ------------------  
    put_encabezado(vcontent, vno_linea, 'EGR_ING_Pend_Fact');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Rows|BackColor=48|');
    append_data(vcontent, vno_linea, '|Datos|', false);
  
    if nvl(debugmode, 'NO') != 'SI' then
      delete emontos_cli_rep where created_by = upper(user);
      delete emontos_cliente_por_anio where created_by = upper(user);
      commit;
    end if;
  
    --------------------
    --  DATOS FOLIOS  --
    --------------------
  
    if nvl(debugmode, 'NO') != 'SI' then
      log_sql(paccion => 'ANTES CURSOR FOLIO');
	  
///////////////************main*******************/////////////////////////////////    
      for c in folios(fecha_cierre) loop
        if ya_insertado = 0 then
          log_sql(paccion => 'EN CURSOR FOLIO');
          ya_insertado := 1;
        end if;
      
        fct_num   := null;
        fct_fecha := null;
      
        if fol_clv is null or fol_clv != c.folclave then
          for i in facturas(c.folclave) loop
            if fct_num is null then
              fct_num   := to_char(i.fctnumero);
              fct_fecha := to_char(i.fctdatefacture, 'DD/MM/RRRR');
            elsif length(fct_fecha) < 980 then
              fct_num   := fct_num || ' - ' || to_char(i.fctnumero);
              fct_fecha := fct_fecha || ' - ' ||
                           to_char(i.fctdatefacture, 'DD/MM/RRRR');
            end if;
          end loop;
        
          select min(ped.peddate)
            into ped_fecha
            from epedimento ped, eagentdouane ado
           where ped.pedfolio = c.folclave
             and ado.adopatente = substr(ped.pednumero, 1, 4)
             and ped.pedregime not in ('R3', 'T3');
        
          begin
            select mi_cd, mi_dpc
              into costo_directo, dpc_importe
              from emontos_cli_rep
             where mi_emp = pemp
               and mi_fec = vfecha_max
               and mi_div = pdiv
               and created_by = upper(user)
               and mi_cli = c.cliclef;
          exception
            when others then
              select /*+ ordered use_nl(pol) */
               sum(dpo.dpodu) - sum(dpo.dpoavoir)
                into costo_directo
                from detailpolice dpo, police pol
               where dpo.dpopolice = pol.polclef
                 and dpo.dpocompte in
                     ('7100-' || get_cli_enmascarado(c.cliclef),
                      '7200-' || get_cli_enmascarado(c.cliclef))
                 and dpo_poldate >= trunc(vfecha_max, 'MM')
                 and dpo_poldate < vfecha_max + 1
                 and dpo_pol_empclave = pemp
                 and dpo_pol_divclef = pdiv;
            
              select /*+ INDEX(DPC IDX_DPC_CLI_EMP_DATE) */
               sum(dpc.dpcsomme) - sum(nvl(dtc.dtcsomme, 0))
                into dpc_importe
                from edepotcheque dpc, edetailcheque dtc
               where dpc.dpcclient = c.cliclef
                 and dpc.dpcdate < vfecha_max + 1
                 and dpc.dpc_empclave = pemp
                 and dpc.dpcdivisa = pdiv
                 and dpc.dpcetat = 'A'
                 and dtc.dtccheque(+) = dpc.dpcclef
                 and dtcfacture is null
                 and nvl(nvl(dtc.date_modified, dtc.date_created),
                         dpc.dpcdate) <= fecha_cierre;
            
              insert into emontos_cli_rep
                (mi_emp,
                 mi_div,
                 mi_fec,
                 mi_cli,
                 mi_cd,
                 mi_dpc,
                 created_by,
                 date_created)
              values
                (pemp,
                 pdiv,
                 vfecha_max,
                 c.cliclef,
                 costo_directo,
                 dpc_importe,
                 upper(user),
                 sysdate);
            
              commit;
          end;
        end if;
      
        append_new_line(vcontent, vno_linea);
        append_data(vcontent, vno_linea, '|Datos|', false);
        put_data(vcontent, vno_linea, '', c.cliclef);
        put_data(vcontent, vno_linea, '', c.clinom);
        put_data(vcontent, vno_linea, '', c.fol_douclef);
        put_data(vcontent, vno_linea, '', c.folfolio);
        put_data(vcontent, vno_linea, '', to_char(ped_fecha, 'DD/MM/RRRR'));
        put_data(vcontent, vno_linea, 'Format=#,##0.00', dpc_importe);
        put_data(vcontent, vno_linea, 'Format=#,##0.00', costo_directo);
        put_data(vcontent, vno_linea, '', fct_num);
        put_data(vcontent, vno_linea, '', fct_fecha);
        put_data(vcontent, vno_linea, '', c.orig);
        put_data(vcontent, vno_linea, '', c.renglon);
        put_data(vcontent,
                 vno_linea,
                 '',
                 to_char(c.fecha_int, 'DD/MM/RRRR'));
        put_data(vcontent, vno_linea, '', c.erogac);
        put_data(vcontent, vno_linea, '', c.nombreerog);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=DETING;ENDFUNC=DETING',
                 c.ingreso);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=DETEGR;ENDFUNC=DETEGR',
                 c.egreso);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=DETGAR;ENDFUNC=DETGAR',
                 c.gar);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=DETINTERCO;ENDFUNC=DETINTERCO',
                 c.interco);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=DETGARANTIA;ENDFUNC=DETGARANTIA',
                 c.garantia);
      
        fol_clv := c.folclave;
      
        insert into emontos_cliente_por_anio
          (micli,
           mifec,
           miant,
           mierog,
           migar,
           created_by,
           mifolio,
           miinterco,
           migarantia,
           date_created)
        values
          (c.cliclef,
           c.fecha_int,
           nvl(c.ingreso, 0),
           nvl(c.egreso, 0),
           nvl(c.gar, 0),
           upper(user),
           c.folfolio,
           nvl(c.interco, 0),
           nvl(c.garantia, 0),
           sysdate);
      end loop;
    ///////////////*******************************/////////////////////////////////
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;PUTFUNC=DETING,SUM;CLEARFUNC=DETING',
               '');
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;PUTFUNC=DETEGR,SUM;CLEARFUNC=DETEGR',
               '');
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;PUTFUNC=DETGAR,SUM;CLEARFUNC=DETGAR',
               '');
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;PUTFUNC=DETINTERCO,SUM;CLEARFUNC=DETINTERCO',
               '');
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;PUTFUNC=DETGARANTIA,SUM;CLEARFUNC=DETGARANTIA',
               '');
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|AutoFit|', false);
    
      /*    DELETE EMONTOS_CLI_REP
          WHERE mi_emp = emp
          AND mi_fec = fecha_max
          AND mi_div = div
          AND CREATED_BY = UPPER(USER);
      */
      commit;
    end if;
  
    log_sql(paccion => 'DESPUES CURSOR FOLIO');
  
  

 
/