
-- HOJA DE RESUMEN POR AÑO 
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|NewHoja|Resumen|');
  
    append_data(vcontent,
                vno_linea,
                '|FORMATO_GAL|FontSize=8;FontAlign=Center;FontBold=True|');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent, vno_linea, '', 'Mes');
    put_data(vcontent, vno_linea, '', 'Ingresos');
    put_data(vcontent, vno_linea, '', 'Erogaciones');
    put_data(vcontent, vno_linea, '', 'GAR');
    put_data(vcontent, vno_linea, '', 'InterCo');
    put_data(vcontent, vno_linea, '', 'Garantia');
    put_data(vcontent, vno_linea, '', 'Diferencial');
    put_data(vcontent, vno_linea, '', 'Diferencial -');
    put_data(vcontent, vno_linea, '', 'Diferencial +');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent,
             vno_linea,
             'FORMAT=@',
             to_char(cur_anio - 1) || ' y antes');
  
    for j in res_anteriores(cur_anio) loop
      put_data(vcontent,
               vno_linea,
               'ADDSELECTION=DIF' || to_char(cur_anio - 1, 'FM0000') ||
               ',1;Format=#,##0.00;INITFUNC=ANTSUMRESBIM;ENDFUNC=ANTSUMRESBIM',
               j.ant);
      put_data(vcontent,
               vno_linea,
               'ADDSELECTION=DIF' || to_char(cur_anio - 1, 'FM0000') ||
               ',-1;Format=#,##0.00;INITFUNC=EROSUMRESBIM;ENDFUNC=EROSUMRESBIM',
               j.erog);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=GARSUMRESBIM;ENDFUNC=GARSUMRESBIM',
               j.gar);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=INTERCOSUMRESBIM;ENDFUNC=INTERCOSUMRESBIM',
               j.interco);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=GARANTIASUMRESBIM;ENDFUNC=GARANTIASUMRESBIM',
               j.garantia);
    
      put_data(vcontent,
               vno_linea,
               'PUTSELECTION=DIF' || to_char(cur_anio - 1, 'FM0000') ||
               ';Format=#,##0.00;INITFUNC=DIFSUMRESBIM;ENDFUNC=DIFSUMRESBIM',
               '');
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=MASSUMRESBIM;ENDFUNC=MASSUMRESBIM',
               j.dif_mas);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=MENOSSUMRESBIM;ENDFUNC=MENOSSUMRESBIM',
               j.dif_menos);
    end loop;
  
    last_bim := -1;
  
    for j in res_bimestre(cur_anio) loop
      if last_bim = -1 and j.bim = 1 then
        append_new_line(vcontent, vno_linea);
        append_data(vcontent, vno_linea, '|Datos|', false);
        put_data(vcontent, vno_linea, '', '');
        put_data(vcontent,
                 vno_linea,
                 'FORMAT=@',
                 'Enero a Junio ' || to_char(cur_anio, 'FM0000'));
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIF01' || to_char(cur_anio, 'FM0000') ||
                 ',1;Format=#,##0.00;INITFUNC=ANTSUMRESBIM;ENDFUNC=ANTSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIF01' || to_char(cur_anio, 'FM0000') ||
                 ',-1;Format=#,##0.00;INITFUNC=EROSUMRESBIM;ENDFUNC=EROSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=GARSUMRESBIM;ENDFUNC=GARSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=INTERCOSUMRESBIM;ENDFUNC=INTERCOSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=GARANTIASUMRESBIM;ENDFUNC=GARANTIASUMRESBIM',
                 0);
      
        put_data(vcontent,
                 vno_linea,
                 'PUTSELECTION=DIF01' || to_char(cur_anio, 'FM0000') ||
                 ';Format=#,##0.00;INITFUNC=DIFSUMRESBIM;ENDFUNC=DIFSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=MASSUMRESBIM;ENDFUNC=MASSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=MENOSSUMRESBIM;ENDFUNC=MENOSSUMRESBIM',
                 0);
      end if;
      last_bim := j.bim;
    
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', '');
      if j.bim = 0 then
        put_data(vcontent,
                 vno_linea,
                 'FORMAT=@',
                 'Enero a Junio ' || to_char(cur_anio, 'FM0000'));
      else
        put_data(vcontent,
                 vno_linea,
                 'FORMAT=@',
                 'Junio a Diciembre ' || to_char(cur_anio, 'FM0000'));
      end if;
      put_data(vcontent,
               vno_linea,
               'ADDSELECTION=DIF' || to_char(j.bim, 'FM00') ||
               to_char(cur_anio, 'FM0000') ||
               ',1;Format=#,##0.00;INITFUNC=ANTSUMRESBIM;ENDFUNC=ANTSUMRESBIM',
               j.ant);
      put_data(vcontent,
               vno_linea,
               'ADDSELECTION=DIF' || to_char(j.bim, 'FM00') ||
               to_char(cur_anio, 'FM0000') ||
               ',-1;Format=#,##0.00;INITFUNC=EROSUMRESBIM;ENDFUNC=EROSUMRESBIM',
               j.erog);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=GARSUMRESBIM;ENDFUNC=GARSUMRESBIM',
               j.gar);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=INTERCOSUMRESBIM;ENDFUNC=INTERCOSUMRESBIM',
               j.interco);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=GARANTIASUMRESBIM;ENDFUNC=GARANTIASUMRESBIM',
               j.garantia);
    
      put_data(vcontent,
               vno_linea,
               'PUTSELECTION=DIF' || to_char(j.bim, 'FM00') ||
               to_char(cur_anio, 'FM0000') ||
               ';Format=#,##0.00;INITFUNC=DIFSUMRESBIM;ENDFUNC=DIFSUMRESBIM',
               0);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=MASSUMRESBIM;ENDFUNC=MASSUMRESBIM',
               j.dif_mas);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=MENOSSUMRESBIM;ENDFUNC=MENOSSUMRESBIM',
               j.dif_menos);
    end loop;
  
    last_bim := -1;
    cur_anio := cur_anio + 1;
  
    for j in res_bimestre(cur_anio) loop
      if last_bim = -1 and j.bim = 1 then
        append_new_line(vcontent, vno_linea);
        append_data(vcontent, vno_linea, '|Datos|', false);
        put_data(vcontent, vno_linea, '', '');
        put_data(vcontent,
                 vno_linea,
                 'FORMAT=@',
                 'Enero a Junio ' || to_char(cur_anio, 'FM0000'));
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIF01' || to_char(cur_anio, 'FM0000') ||
                 ',1;Format=#,##0.00;INITFUNC=ANTSUMRESBIM;ENDFUNC=ANTSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIF01' || to_char(cur_anio, 'FM0000') ||
                 ',-1;Format=#,##0.00;INITFUNC=EROSUMRESBIM;ENDFUNC=EROSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=GARSUMRESBIM;ENDFUNC=GARSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=INTERCOSUMRESBIM;ENDFUNC=INTERCOSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=GARANTIASUMRESBIM;ENDFUNC=GARANTIASUMRESBIM',
                 0);
      
        put_data(vcontent,
                 vno_linea,
                 'PUTSELECTION=DIF01' || to_char(cur_anio, 'FM0000') ||
                 ';Format=#,##0.00;INITFUNC=DIFSUMRESBIM;ENDFUNC=DIFSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=MASSUMRESBIM;ENDFUNC=MASSUMRESBIM',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=MENOSSUMRESBIM;ENDFUNC=MENOSSUMRESBIM',
                 0);
      end if;
      last_bim := j.bim;
    
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', '');
      if j.bim = 0 then
        put_data(vcontent,
                 vno_linea,
                 'FORMAT=@',
                 'Enero a Junio ' || to_char(cur_anio, 'FM0000'));
      else
        put_data(vcontent,
                 vno_linea,
                 'FORMAT=@',
                 'Junio a Diciembre ' || to_char(cur_anio, 'FM0000'));
      end if;
      put_data(vcontent,
               vno_linea,
               'ADDSELECTION=DIF' || to_char(j.bim, 'FM00') ||
               to_char(cur_anio, 'FM0000') ||
               ',1;Format=#,##0.00;INITFUNC=ANTSUMRESBIM;ENDFUNC=ANTSUMRESBIM',
               j.ant);
      put_data(vcontent,
               vno_linea,
               'ADDSELECTION=DIF' || to_char(j.bim, 'FM00') ||
               to_char(cur_anio, 'FM0000') ||
               ',-1;Format=#,##0.00;INITFUNC=EROSUMRESBIM;ENDFUNC=EROSUMRESBIM',
               j.erog);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=GARSUMRESBIM;ENDFUNC=GARSUMRESBIM',
               j.gar);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=INTERCOSUMRESBIM;ENDFUNC=INTERCOSUMRESBIM',
               j.interco);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=GARANTIASUMRESBIM;ENDFUNC=GARANTIASUMRESBIM',
               j.garantia);
    
      put_data(vcontent,
               vno_linea,
               'PUTSELECTION=DIF' || to_char(j.bim, 'FM00') ||
               to_char(cur_anio, 'FM0000') ||
               ';Format=#,##0.00;INITFUNC=DIFSUMRESBIM;ENDFUNC=DIFSUMRESBIM',
               0);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=MASSUMRESBIM;ENDFUNC=MASSUMRESBIM',
               j.dif_mas);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=MENOSSUMRESBIM;ENDFUNC=MENOSSUMRESBIM',
               j.dif_menos);
    end loop;
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|');
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent, vno_linea, '', 'TOTALES');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=ANTSUMRESBIM,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=EROSUMRESBIM,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=GARSUMRESBIM,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=INTERCOSUMRESBIM,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=GARANTIASUMRESBIM,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=DIFSUMRESBIM,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=MASSUMRESBIM,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=MENOSSUMRESBIM,SUM',
             '');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|');
    append_data(vcontent, vno_linea, '|Datos|', false);
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent, vno_linea, '', 'Mes');
    put_data(vcontent, vno_linea, '', 'Ingresos');
    put_data(vcontent, vno_linea, '', 'Erogaciones');
    put_data(vcontent, vno_linea, '', 'GAR');
    put_data(vcontent, vno_linea, '', 'InterCo');
    put_data(vcontent, vno_linea, '', 'Garantia');
    put_data(vcontent, vno_linea, '', 'Diferencial');
    put_data(vcontent, vno_linea, '', 'Diferencial -');
    put_data(vcontent, vno_linea, '', 'Diferencial +');
  
    for i in meses loop
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, 'FORMAT=@', to_char(i.mes, 'MM/YYYY'));
    
      for j in res_mes(i.mes) loop
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIF' || to_char(i.mes, 'MM/YYYY') ||
                 ',1;Format=#,##0.00;INITFUNC=ANTSUMRESCUR;ENDFUNC=ANTSUMRESCUR',
                 j.ant);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIF' || to_char(i.mes, 'MM/YYYY') ||
                 ',-1;Format=#,##0.00;INITFUNC=EROSUMRESCUR;ENDFUNC=EROSUMRESCUR',
                 j.erog);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=GARSUMRESCUR;ENDFUNC=GARSUMRESCUR',
                 j.gar);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=INTERCOSUMRESCUR;ENDFUNC=INTERCOSUMRESCUR',
                 j.interco);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=GARANTIASUMRESCUR;ENDFUNC=GARANTIASUMRESCUR',
                 j.garantia);
        put_data(vcontent,
                 vno_linea,
                 'PUTSELECTION=DIF' || to_char(i.mes, 'MM/YYYY') ||
                 ';Format=#,##0.00;INITFUNC=DIFSUMRESCUR;ENDFUNC=DIFSUMRESCUR',
                 '');
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=MASSUMRESCUR;ENDFUNC=MASSUMRESCUR',
                 j.dif_mas);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=MENOSSUMRESCUR;ENDFUNC=MENOSSUMRESCUR',
                 j.dif_menos);
      end loop;
    end loop;
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|');
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent, vno_linea, '', 'TOTALES');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=ANTSUMRESCUR,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=EROSUMRESCUR,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=GARSUMRESCUR,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=INTERCOSUMRESCUR,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=GARANTIASUMRESCUR,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=DIFSUMRESCUR,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=MASSUMRESCUR,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=MENOSSUMRESCUR,SUM',
             '');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|');
    append_data(vcontent, vno_linea, '|Datos|');
  
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent, vno_linea, '', 'Clientes con Mayor Financiamiento');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', 'Cliente');
    put_data(vcontent, vno_linea, '', 'Razon Social');
    put_data(vcontent, vno_linea, '', 'Ingresos');
    put_data(vcontent, vno_linea, '', 'Erogaciones');
    put_data(vcontent, vno_linea, '', 'GAR');
    put_data(vcontent, vno_linea, '', 'InterCo');
    put_data(vcontent, vno_linea, '', 'Garantia');
    put_data(vcontent, vno_linea, '', 'Diferencial');
  
    for i in mas_financiados loop
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', i.micli);
      put_data(vcontent, vno_linea, '', i.clinom);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;ADDSELECTION=FINANCIADO' || i.micli ||
               ',1;INITFUNC=ANTFINANCIADO;ENDFUNC=ANTFINANCIADO',
               i.ant);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;ADDSELECTION=FINANCIADO' || i.micli ||
               ',-1;INITFUNC=EROFINANCIADO;ENDFUNC=EROFINANCIADO',
               i.erog);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=GARFINANCIADO;ENDFUNC=GARFINANCIADO',
               i.gar);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=INTERCOFINANCIADO;ENDFUNC=INTERCOFINANCIADO',
               i.interco);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;INITFUNC=GARANTIAFINANCIADO;ENDFUNC=GARANTIAFINANCIADO',
               i.garantia);
      put_data(vcontent,
               vno_linea,
               'Format=#,##0.00;PUTSELECTION=FINANCIADO' || i.micli ||
               ';INITFUNC=DIFFINANCIADO;ENDFUNC=DIFFINANCIADO',
               '');
    end loop;
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent, vno_linea, '', 'TOTALES');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=ANTFINANCIADO,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=EROFINANCIADO,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=GARFINANCIADO,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=INTERCOFINANCIADO,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=GARANTIAFINANCIADO,SUM',
             '');
    put_data(vcontent,
             vno_linea,
             'Format=#,##0.00;PUTFUNC=DIFFINANCIADO,SUM',
             '');
  
    ------------------
    --  CONCLUSION  --
    ------------------
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|AutoFit|');
  
    log_sql(paccion => 'FIN REPORTE');
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