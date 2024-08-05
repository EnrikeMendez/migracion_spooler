
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
  
   