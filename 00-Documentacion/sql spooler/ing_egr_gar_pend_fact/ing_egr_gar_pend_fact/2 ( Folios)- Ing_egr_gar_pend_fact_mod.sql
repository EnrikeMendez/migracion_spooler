  -- CON FOLIOS
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|NewHoja|Folios|');
  
    append_data(vcontent,
                vno_linea,
                '|FORMATO_GAL|FontSize=8;FontAlign=Center;FontBold=True|');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Rows|Freeze|');
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', 'Cliente');
    put_data(vcontent, vno_linea, '', 'Nombre');
    put_data(vcontent, vno_linea, '', 'Folio');
    put_data(vcontent, vno_linea, '', 'F. Pago');
  
    put_data(vcontent, vno_linea, '', 'Ingresos');
    put_data(vcontent, vno_linea, '', 'Erogaciones');
    put_data(vcontent, vno_linea, '', 'GAR');
    put_data(vcontent, vno_linea, '', 'InterCo');
    put_data(vcontent, vno_linea, '', 'Garantia');
    put_data(vcontent, vno_linea, '', 'Diferencial');
    put_data(vcontent, vno_linea, '', 'Diferencial (+)');
    put_data(vcontent, vno_linea, '', 'Diferencial (-)');
  
    append_new_line(vcontent, vno_linea);
    --append_data(vcontent, vno_linea, '|FREEZE|0|', false);
  
    milastcli := -1;
  
    ya_insertado := 0;
  
    log_sql(paccion => 'ANTES CURSOR MISFOLIOS');
 /****************main***************/ 
    for i in misfolios loop
      if ya_insertado = 0 then
        log_sql(paccion => 'EN CURSOR MISFOLIOS');
      
        ya_insertado := 1;
      end if;
    
      if i.micli != milastcli then
        if milastcli != -1 then
          append_new_line(vcontent, vno_linea);
          append_data(vcontent, vno_linea, '|Datos|', false);
          put_data(vcontent, vno_linea, '', milastcli);
          put_data(vcontent, vno_linea, '', milastnom);
          put_data(vcontent, vno_linea, '', '');
          put_data(vcontent, vno_linea, '', 'TOTALES');
          put_data(vcontent,
                   vno_linea,
                   'PUTFUNC=INGSUMFOLCLI' || milastcli ||
                   ',SUM;CLEARFUNC=INGSUMFOLCLI' || milastcli ||
                   ';Format=#,##0.00',
                   '');
          put_data(vcontent,
                   vno_linea,
                   'PUTFUNC=EROSUMFOLCLI' || milastcli ||
                   ',SUM;CLEARFUNC=EROSUMFOLCLI' || milastcli ||
                   ';Format=#,##0.00',
                   '');
          put_data(vcontent,
                   vno_linea,
                   'PUTFUNC=GARSUMFOLCLI' || milastcli ||
                   ',SUM;CLEARFUNC=GARSUMFOLCLI' || milastcli ||
                   ';Format=#,##0.00',
                   '');
          put_data(vcontent,
                   vno_linea,
                   'PUTFUNC=INTERCOSUMFOLCLI' || milastcli ||
                   ',SUM;CLEARFUNC=INTERCOSUMFOLCLI' || milastcli ||
                   ';Format=#,##0.00',
                   '');
          put_data(vcontent,
                   vno_linea,
                   'PUTFUNC=GARANTIASUMFOLCLI' || milastcli ||
                   ',SUM;CLEARFUNC=GARANTIASUMFOLCLI' || milastcli ||
                   ';Format=#,##0.00',
                   '');
        
          put_data(vcontent,
                   vno_linea,
                   'PUTFUNC=DIFSUMFOLCLI' || milastcli ||
                   ',SUM;CLEARFUNC=DIFSUMFOLCLI' || milastcli ||
                   ';Format=#,##0.00',
                   '');
          put_data(vcontent,
                   vno_linea,
                   'PUTFUNC=DIFSUMFOLCLIMAS' || milastcli ||
                   ',SUM;CLEARFUNC=DIFSUMFOLCLIMAS' || milastcli ||
                   ';Format=#,##0.00',
                   '');
          put_data(vcontent,
                   vno_linea,
                   'PUTFUNC=DIFSUMFOLCLIMENOS' || milastcli ||
                   ',SUM;CLEARFUNC=DIFSUMFOLCLIMENOS' || milastcli ||
                   ';Format=#,##0.00',
                   '');
        
          append_new_line(vcontent, vno_linea);
          append_data(vcontent, vno_linea, '|Datos|');
          append_data(vcontent, vno_linea, '|Datos|', false);
        end if;
        milastcli := i.micli;
        milastnom := i.clinom;
      end if;
    
      mi_diffol := nvl(i.ant, 0) - nvl(i.erog, 0);
    
      f_pago := null;
    
      begin
        select min(peddate)
          into f_pago
          from epedimento
         where pedfolio = i.folclave;
      exception
        when others then
          null;
      end;
    
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', i.micli);
      put_data(vcontent, vno_linea, '', i.clinom);
      put_data(vcontent, vno_linea, '', i.mifolio);
      put_data(vcontent,
               vno_linea,
               'FORMAT=@',
               to_char(f_pago, 'DD/MM/YYYY'));
      put_data(vcontent,
               vno_linea,
               'INITFUNC=INGSUMFOLCLI' || i.micli ||
               ';ENDFUNC=INGSUMFOLCLI' || i.micli || ';Format=#,##0.00',
               i.ant);
      put_data(vcontent,
               vno_linea,
               'INITFUNC=EROSUMFOLCLI' || i.micli ||
               ';ENDFUNC=EROSUMFOLCLI' || i.micli || ';Format=#,##0.00',
               i.erog);
      put_data(vcontent,
               vno_linea,
               'INITFUNC=GARSUMFOLCLI' || i.micli ||
               ';ENDFUNC=GARSUMFOLCLI' || i.micli || ';Format=#,##0.00',
               i.gar);
      put_data(vcontent,
               vno_linea,
               'INITFUNC=INTERCOSUMFOLCLI' || i.micli ||
               ';ENDFUNC=INTERCOSUMFOLCLI' || i.micli || ';Format=#,##0.00',
               i.interco);
      put_data(vcontent,
               vno_linea,
               'INITFUNC=GARANTIASUMFOLCLI' || i.micli ||
               ';ENDFUNC=GARANTIASUMFOLCLI' || i.micli ||
               ';Format=#,##0.00',
               i.garantia);
    
      put_data(vcontent,
               vno_linea,
               'INITFUNC=DIFSUMFOLCLI' || i.micli ||
               ';ENDFUNC=DIFSUMFOLCLI' || i.micli || ';Format=#,##0.00',
               mi_diffol);
      if mi_diffol >= 0 then
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=DIFSUMFOLCLIMAS' || i.micli ||
                 ';ENDFUNC=DIFSUMFOLCLIMAS' || i.micli ||
                 ';Format=#,##0.00',
                 mi_diffol);
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=DIFSUMFOLCLIMENOS' || i.micli ||
                 ';ENDFUNC=DIFSUMFOLCLIMENOS' || i.micli ||
                 ';Format=#,##0.00',
                 0);
      else
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=DIFSUMFOLCLIMAS' || i.micli ||
                 ';ENDFUNC=DIFSUMFOLCLIMAS' || i.micli ||
                 ';Format=#,##0.00',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=DIFSUMFOLCLIMENOS' || i.micli ||
                 ';ENDFUNC=DIFSUMFOLCLIMENOS' || i.micli ||
                 ';Format=#,##0.00',
                 mi_diffol);
      end if;
    end loop;
  /*******************************/
    if milastcli != -1 then
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', milastcli);
      put_data(vcontent, vno_linea, '', milastnom);
      put_data(vcontent, vno_linea, '', '');
      put_data(vcontent, vno_linea, '', 'TOTALES');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=INGSUMFOLCLI' || milastcli ||
               ',SUM;CLEARFUNC=INGSUMFOLCLI' || milastcli ||
               ';Format=#,##0.00',
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=EROSUMFOLCLI' || milastcli ||
               ',SUM;CLEARFUNC=EROSUMFOLCLI' || milastcli ||
               ';Format=#,##0.00',
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=GARSUMFOLCLI' || milastcli ||
               ',SUM;CLEARFUNC=GARSUMFOLCLI' || milastcli ||
               ';Format=#,##0.00',
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=INTERCOSUMFOLCLI' || milastcli ||
               ',SUM;CLEARFUNC=INTERCOSUMFOLCLI' || milastcli ||
               ';Format=#,##0.00',
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=GARANTIASUMFOLCLI' || milastcli ||
               ',SUM;CLEARFUNC=GARANTIASUMFOLCLI' || milastcli ||
               ';Format=#,##0.00',
               '');
    
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=DIFSUMFOLCLI' || milastcli ||
               ',SUM;CLEARFUNC=DIFSUMFOLCLI' || milastcli ||
               ';Format=#,##0.00',
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=DIFSUMFOLCLIMAS' || milastcli ||
               ',SUM;CLEARFUNC=DIFSUMFOLCLIMAS' || milastcli ||
               ';Format=#,##0.00',
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=DIFSUMFOLCLIMENOS' || milastcli ||
               ',SUM;CLEARFUNC=DIFSUMFOLCLIMENOS' || milastcli ||
               ';Format=#,##0.00',
               '');
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|AutoFit|', false);
    end if;
	/***/
  
    log_sql(paccion => 'DESPUES CURSOR MISFOLIOS');
  
    anio_base := to_number(to_char(trunc(vfecha_max, 'YYYY'), 'YYYY')) - 1;
  
   