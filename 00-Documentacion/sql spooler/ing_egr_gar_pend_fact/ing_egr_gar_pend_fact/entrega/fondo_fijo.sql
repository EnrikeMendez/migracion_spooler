 procedure fondo_fijo(pmsg       out varchar2,
                       prep_clave in varchar2,
                       pemp       in number,
                       pdiv       in varchar2) is

    /*
    * varibles locales
    */
    vcontent  clob;
    vno_linea number := 1;
    --
  
    tot_erog_no_fact         number;
    tot_erog_no_fact_interco number;
  
    tot_erog_fact         number;
    tot_erog_fact_interco number;
  
    fact_erog_interco number;
    fact_erog_tercero number;
  
    fact_anticipo_saldo number;
    fact_integre_saldo  number;
    a_descontar         number;
  
    monto_fondo number;
    dispo       number;
    --
  
    /*
    * cursores locales
    */
    cursor clientes is
      select cliclef, clinom
        from eclient
       where clistatus = 0
         and exists
       (select /*+ INDEX (DPO IDPOCOMPTEDATE) */
               null
                from detailpolice dpo
               where dpocompte like '8700-' || get_cli_enmascarado(cliclef)
                 and rownum = 1)
       order by 1;
  
    cursor fact_pends(mi_cli in number) is
      select nvl(fac.fcttotal, 0) fcttotal,
             nvl(fac.fctintegre, 0) fctintegre,
             nvl(fac.fcttotingreso, 0) fcttotal_ing,
             nvl(fac.fcttoterogation, 0) fcttotal_erog,
             nvl(fac.fcttotanticipo, 0) fcttotal_ant,
             fctclef --, FOLFOLIO
        from efacturas fac --, EFOLIOS FOL
       where fac.fct_empclave = pemp
         and fac.fctdivisa = pdiv
         and fct_cli_pagador = mi_cli
         and fac.fct_yfaclef in ('1', '2', '3')
         and nvl(fac.fctintegre, 0) != nvl(fac.fcttotal, 0);
    --AND FOLCLAVE = FCTFOLIO;
  
    
    /*
    * funciones / procedimientos locales
    */
    function get_saldo_fondo_fijo(mi_cli in number) return number is
      mi_saldo number;
    begin
      select sum(dpoavoir) - sum(dpodu)
        into mi_saldo
        from detailpolice
       where dpocompte = '8700-' || get_cli_enmascarado(mi_cli)
         and exists (select null
                from police
               where polclef = dpopolice
                 and poletat = 'A'
                 and pol_empclave = pemp
                 and pol_divclef = pdiv
                 and rownum = 1);
    
      return(mi_saldo);
    end;
  
    procedure put_encabezado(pcontent  in out clob,
                             pno_linea in out number,
                             titulo    in varchar2) is
    begin
      append_data(pcontent, pno_linea, '|NewHoja|' || titulo || '|');
    
      append_data(pcontent,
                  pno_linea,
                  '|FORMATO_GAL|FontSize=8;FontAlign=Center;FontBold=True|');
    
      append_data(pcontent, pno_linea, '|Rows|FontSize=14;FontAlign=Left|');
    
      append_new_line(pcontent, pno_linea);
      append_data(pcontent,
                  pno_linea,
                  '|Rows|FontSize=10;FontAlign=Left|Freeze|');
    
      append_data(pcontent, pno_linea, '|Datos|', false);
      -- TITULOS COLUMNAS --
      put_data(pcontent, pno_linea, '', 'No. Cliente');
      put_data(pcontent, pno_linea, '', 'Razon Social');
      put_data(pcontent, pno_linea, '', 'Importe Fondo');
      put_data(pcontent, pno_linea, '', 'Pendientes por facturar Terceros'); -- TERCEROS, EROGACIONES NO ASOCIADAS A NINGUNA FACTURA
      put_data(pcontent, pno_linea, '', 'Pendientes por facturar Interco'); -- INTERCOS, EROGACIONES NO ASOCIADAS A NINGUNA FACTURA
      put_data(pcontent, pno_linea, '', 'Facturadas Terceros'); -- TERCEROS, EGORACIONES EN FACTURAS PERO NO PAGADAS POR EL CLIENTE TODAVIA
      put_data(pcontent, pno_linea, '', 'Facturadas Interco'); -- INTERCOS, EGORACIONES EN FACTURAS PERO NO PAGADAS POR EL CLIENTE TODAVIA
      put_data(pcontent, pno_linea, '', 'Total Terceros');
      put_data(pcontent, pno_linea, '', 'Total Interco');
      put_data(pcontent, pno_linea, '', 'Disponible');
    
      --append_new_line(pcontent, pno_linea);
      --append_data(pcontent, pno_linea, '|FREEZE|0|', false);
    
    end;
  
  begin
    -- init
    gv_modulo := 'fondo_fijo';
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
    -- reporte >
    monto_fondo := 0;
  
    put_encabezado(vcontent, vno_linea, 'Fondo Fijo');
  
    for i in clientes loop
      tot_erog_no_fact         := 0;
      tot_erog_no_fact_interco := 0;
    
      tot_erog_fact         := 0;
      tot_erog_fact_interco := 0;
    
      monto_fondo := 0;
      monto_fondo := get_saldo_fondo_fijo(i.cliclef);
    
      for j in fact_pends(i.cliclef) loop
        fact_erog_interco   := 0;
        fact_erog_tercero   := 0;
        fact_anticipo_saldo := 0;
        fact_integre_saldo  := 0;
        a_descontar         := 0;
      
        -- PRIMERO SE DETERMINAN LOS INTERCOS DE LA FACTURA
		
        select nvl(sum(pdd.pddsomme), 0)
          into fact_erog_interco
          from eprovdocdet pdd, econceptoshoja cho, eprovdoc prd
         where pddfacture = j.fctclef
           and pddtype = 'P01'
           and choclave = pdd_choclave
           and cho.chotipoie = 'E'
           and prd.prd_empclave = pemp
           and prd.prdclef = pdd.pddprovdoc
           and pdd.pdd_prd_empclave = pemp
           and prd.prdanio = pdd.pddanio
           and prd.prdetat = 'A'
           and prd.prddivisa = pdiv
           and (prdproveedor >= 9900 and prdproveedor <= 9999);
      
        -- LAS DEMAS EROGACIONES SON LAS EROGACIONES DE TERCERO
        fact_erog_tercero := j.fcttotal_erog - fact_erog_interco;
      
        -- INICIALIZAMOS EL SALDO DE ANTICIPO Y EL SALDO DEL INTEGRADO
        -- ESOS SALDOS SE VAN A DESCONTAR PRIMERO DE LAS EROGACIONES A TERCERO, Y DESPUES DE LAS EROGACIONES INTERCO
        fact_anticipo_saldo := j.fcttotal_ant;
        fact_integre_saldo  := j.fctintegre;
      
        -- PRIMERO DESCONTAMOS EL ANTICIPO DE LAS EROGACIONES DE TERCERO
        if fact_anticipo_saldo >= fact_erog_tercero then
          a_descontar := fact_erog_tercero;
        else
          a_descontar := fact_anticipo_saldo;
        end if;
      
        fact_anticipo_saldo := fact_anticipo_saldo - a_descontar;
        fact_erog_tercero   := fact_erog_tercero - a_descontar;
        a_descontar         := 0;
      
        -- DESPUES SI SOBRA ANTICIPO, SE DESCUENTA DE LAS EROGACIONES INTERCOS
        if fact_anticipo_saldo >= fact_erog_interco then
          a_descontar := fact_erog_interco;
        else
          a_descontar := fact_anticipo_saldo;
        end if;
      
        fact_anticipo_saldo := fact_anticipo_saldo - a_descontar;
        fact_erog_interco   := fact_erog_interco - a_descontar;
        a_descontar         := 0;
      
        -- DESPUES DESCONTAMOS LO INTEGRADO DE LAS EROGACIONES DE TERCERO
        if fact_integre_saldo >= fact_erog_tercero then
          a_descontar := fact_erog_tercero;
        else
          a_descontar := fact_integre_saldo;
        end if;
      
        fact_integre_saldo := fact_integre_saldo - a_descontar;
        fact_erog_tercero  := fact_erog_tercero - a_descontar;
        a_descontar        := 0;
      
        -- POR FIN, SI SOBRA INTEGRADO, SE DESCUENTA DE LAS EROGACIONES INTERCOS
        if fact_integre_saldo >= fact_erog_interco then
          a_descontar := fact_erog_interco;
        else
          a_descontar := fact_integre_saldo;
        end if;
      
        fact_integre_saldo := fact_integre_saldo - a_descontar;
        fact_erog_interco  := fact_erog_interco - a_descontar;
        a_descontar        := 0;
      
        tot_erog_fact         := tot_erog_fact + fact_erog_tercero;
        tot_erog_fact_interco := tot_erog_fact_interco + fact_erog_interco;
      end loop;
    
      tot_erog_no_fact         := logis.get_erog_no_fact(i.cliclef,
                                                         pemp,
                                                         pdiv);
      tot_erog_no_fact_interco := logis.get_erog_interco_no_fact(i.cliclef,
                                                                 pemp,
                                                                 pdiv);
    
      dispo := monto_fondo - tot_erog_no_fact - tot_erog_fact;
    
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', i.cliclef);
      put_data(vcontent, vno_linea, '', i.clinom);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=TOTFOND;ENDFUNC=TOTFOND',
               monto_fondo);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=PENDTERCERO;ENDFUNC=PENDTERCERO',
               tot_erog_no_fact);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=PENDINTERCO;ENDFUNC=PENDINTERCO',
               tot_erog_no_fact_interco);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=FCTTERCERO;ENDFUNC=FCTTERCERO',
               tot_erog_fact);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=FCTINTERCO;ENDFUNC=FCTINTERCO',
               tot_erog_fact_interco);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=TOTTERCERO;ENDFUNC=TOTTERCERO',
               tot_erog_no_fact + tot_erog_fact);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=TOTINTERCO;ENDFUNC=TOTINTERCO',
               tot_erog_no_fact_interco + tot_erog_fact_interco);
    
      if dispo > 0 then
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;ADDSELECTION=DISPOMAS,1;INITFUNC=TOTDISP;ENDFUNC=TOTDISP',
                 dispo);
      else
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;ADDSELECTION=DISPOMENOS,1;INITFUNC=TOTDISP;ENDFUNC=TOTDISP',
                 dispo);
      end if;
    end loop;
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=TOTFOND,SUM;CLEARFUNC=TOTFOND',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=PENDTERCERO,SUM;CLEARFUNC=PENDTERCERO',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=PENDINTERCO,SUM;CLEARFUNC=PENDINTERCO',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=FCTTERCERO,SUM;CLEARFUNC=FCTTERCERO',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=FCTINTERCO,SUM;CLEARFUNC=FCTINTERCO',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=TOTTERCERO,SUM;CLEARFUNC=TOTTERCERO',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=TOTINTERCO,SUM;CLEARFUNC=TOTINTERCO',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=TOTDISP,SUM;CLEARFUNC=TOTDISP',
             '');
  
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
    put_data(vcontent, vno_linea, 'Format=@', 'Positivo');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTSELECTION=DISPOMAS',
             '');
  
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
    put_data(vcontent, vno_linea, 'Format=@', 'Negativo');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTSELECTION=DISPOMENOS',
             '');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|AutoFit|');
    append_new_line(vcontent, vno_linea);
    -- < reporte
  
    -- finaliza
    flush(vcontent, vno_linea, true, true);
    --
    commit;
    pmsg := 'OK';
  exception
    when others then
      rollback;
      pmsg := substr(dbms_utility.format_error_stack ||
                     dbms_utility.format_error_backtrace,
                     1,
                     1024);
  end;

begin
  -- initialization
  gv_sysdate := sysdate;
end sc_reportes;