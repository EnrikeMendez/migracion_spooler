
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