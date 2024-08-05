 -- HOJA DE RESUMEN POR CLIENTE 
    last_cli  := -1;
    last_anio := anio_base;
    anio_max  := to_number(to_char(vfecha_max, 'YYYY'));
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|NewHoja|Resumen Cliente|');
  
    append_data(vcontent,
                vno_linea,
                '|FORMATO_GAL|FontSize=8;FontAlign=Center;FontBold=True|');
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Rows|Freeze=2|', false);
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', 'Cliente');
    put_data(vcontent, vno_linea, '', 'Nombre');
  
    put_data(vcontent, vno_linea, '', 'Tot. Anticipos');
    put_data(vcontent, vno_linea, '', 'Tot. Erogaciones');
    put_data(vcontent, vno_linea, '', 'Tot. GAR');
    put_data(vcontent, vno_linea, '', 'Tot. InterCo');
    put_data(vcontent, vno_linea, '', 'Tot. Garantia');
  
    put_data(vcontent, vno_linea, '', 'Diferencial');
  
    put_data(vcontent, vno_linea, '', 'Diferencial (+)');
    put_data(vcontent, vno_linea, '', 'Diferencial (-)');
  
    put_data(vcontent,
             vno_linea,
             '',
             'Anticipos Antes ' || to_char(last_anio));
    put_data(vcontent,
             vno_linea,
             '',
             'Erogaciones Antes ' || to_char(last_anio));
    put_data(vcontent, vno_linea, '', 'GAR Antes ' || to_char(last_anio));
    put_data(vcontent,
             vno_linea,
             '',
             'InterCo Antes ' || to_char(last_anio));
    put_data(vcontent,
             vno_linea,
             '',
             'Garantia Antes ' || to_char(last_anio));
  /////////***********************/
    for i in last_anio .. anio_max loop
      put_data(vcontent, vno_linea, '', 'Anticipos 01-06 ' || to_char(i));
      put_data(vcontent, vno_linea, '', 'Erogaciones 01-06 ' || to_char(i));
      put_data(vcontent, vno_linea, '', 'GAR 01-06 ' || to_char(i));
      put_data(vcontent, vno_linea, '', 'InterCo 01-06 ' || to_char(i));
      put_data(vcontent, vno_linea, '', 'Garantia 01-06 ' || to_char(i));
    
      if i < to_number(to_char(trunc(vfecha_max, 'YYYY'), 'YYYY')) or
         to_number(to_char(vfecha_max, 'MM')) > 6 then
        put_data(vcontent, vno_linea, '', 'Anticipos 07-12 ' || to_char(i));
        put_data(vcontent,
                 vno_linea,
                 '',
                 'Erogaciones 07-12 ' || to_char(i));
        put_data(vcontent, vno_linea, '', 'GAR 07-12 ' || to_char(i));
        put_data(vcontent, vno_linea, '', 'InterCo 07-12 ' || to_char(i));
        put_data(vcontent, vno_linea, '', 'Garantia 07-12 ' || to_char(i));
      end if;
    end loop;
  /////////***********************/
    --append_new_line(vcontent, vno_linea);
    --append_data(vcontent, vno_linea, '|FREEZE|2|', false);
  /***********/
    for i in clis loop
      last_anio := anio_base;
      cur_anio  := anio_base;
      last_bim  := -1;
    
      select sum(nvl(miant, 0)) ant, sum(nvl(mierog, 0)) erog
        into tot_antcli, tot_erocli
        from emontos_cliente_por_anio mcpa
       where mcpa.created_by = upper(user)
         and micli = i.micli;
    
      mi_difcli := nvl(tot_antcli, 0) - nvl(tot_erocli, 0);
    
      append_new_line(vcontent, vno_linea);
      append_data(vcontent, vno_linea, '|Datos|', false);
      put_data(vcontent, vno_linea, '', i.micli);
      put_data(vcontent, vno_linea, '', i.clinom);
    
      if last_cli = -1 then
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIFCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;PUTSELECTION=RESANTCLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTANTCLI;ENDFUNC=RESTOTANTCLI',
                 ''); --CLEARSELECTION=RESANTCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIFCLI' || to_char(i.micli, 'FM99999990') ||
                 ',-1;PUTSELECTION=RESEROCLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTEROCLI;ENDFUNC=RESTOTEROCLI',
                 ''); --;CLEARSELECTION=RESEROCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'PUTSELECTION=RESGARCLI' || to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTGARCLI;ENDFUNC=RESTOTGARCLI',
                 ''); --;CLEARSELECTION=RESGARCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'PUTSELECTION=RESINTERCOCLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTINTERCOCLI;ENDFUNC=RESTOTINTERCOCLI',
                 ''); --;CLEARSELECTION=RESGARCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'PUTSELECTION=RESGARANTIACLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTGARANTIACLI;ENDFUNC=RESTOTGARANTIACLI',
                 ''); --;CLEARSELECTION=RESGARCLI', '');
      
        put_data(vcontent,
                 vno_linea,
                 'PUTSELECTION=DIFCLI' || to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTDIFCLI;ENDFUNC=RESTOTDIFCLI',
                 '');
      else
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIFCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;CLEARSELECTION=RESANTCLI' ||
                 to_char(last_cli, 'FM99999990') ||
                 ';PUTSELECTION=RESANTCLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTANTCLI;ENDFUNC=RESTOTANTCLI',
                 ''); --CLEARSELECTION=RESANTCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=DIFCLI' || to_char(i.micli, 'FM99999990') ||
                 ',-1;CLEARSELECTION=RESEROCLI' ||
                 to_char(last_cli, 'FM99999990') ||
                 ';PUTSELECTION=RESEROCLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTEROCLI;ENDFUNC=RESTOTEROCLI',
                 ''); --;CLEARSELECTION=RESEROCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'CLEARSELECTION=RESGARCLI' ||
                 to_char(last_cli, 'FM99999990') ||
                 ';PUTSELECTION=RESGARCLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTGARCLI;ENDFUNC=RESTOTGARCLI',
                 ''); --;CLEARSELECTION=RESGARCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'CLEARSELECTION=RESINTERCOCLI' ||
                 to_char(last_cli, 'FM99999990') ||
                 ';PUTSELECTION=RESINTERCOCLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTINTERCOCLI;ENDFUNC=RESTOTINTERCOCLI',
                 ''); --;CLEARSELECTION=RESGARCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'CLEARSELECTION=RESGARANTIACLI' ||
                 to_char(last_cli, 'FM99999990') ||
                 ';PUTSELECTION=RESGARANTIACLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;INITFUNC=RESTOTGARANTIACLI;ENDFUNC=RESTOTGARANTIACLI',
                 ''); --;CLEARSELECTION=RESGARCLI', '');
        put_data(vcontent,
                 vno_linea,
                 'PUTSELECTION=DIFCLI' || to_char(i.micli, 'FM99999990') ||
                 ';Format=#,##0.00;CLEARSELECTION=DIFCLI' ||
                 to_char(last_cli, 'FM99999990') ||
                 ';INITFUNC=RESTOTDIFCLI;ENDFUNC=RESTOTDIFCLI',
                 '');
      end if;
    
      if mi_difcli > 0 then
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=RESTOTDIFCLIMAS;ENDFUNC=RESTOTDIFCLIMAS',
                 mi_difcli);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=RESTOTDIFCLIMENOS;ENDFUNC=RESTOTDIFCLIMENOS',
                 0);
      else
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=RESTOTDIFCLIMAS;ENDFUNC=RESTOTDIFCLIMAS',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'Format=#,##0.00;INITFUNC=RESTOTDIFCLIMENOS;ENDFUNC=RESTOTDIFCLIMENOS',
                 mi_difcli);
      end if;
    
      last_cli := i.micli;
    
      -- PRIMERO, PONEMOS LO DE AÑOS ANTERIORES
      for j in res_anteriores(anio_base, i.micli) loop
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESANTCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=ANT0000;ENDFUNC=ANT0000;Format=#,##0.00',
                 j.ant);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESEROCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=EROG0000;ENDFUNC=EROG0000;Format=#,##0.00',
                 j.erog);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESGARCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=GAR0000;ENDFUNC=GAR0000;Format=#,##0.00',
                 j.gar);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESINTERCOCLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=INTERCO0000;ENDFUNC=INTERCO0000;Format=#,##0.00',
                 j.interco);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESGARANTIACLI' ||
                 to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=GARANTIA0000;ENDFUNC=GARANTIA0000;Format=#,##0.00',
                 j.garantia);
        last_anio := 0;
      end loop;
    
      if last_anio != 0 then
        -- ES QUE NO HEMOS ENTRADO EN EL LOOP ANTERIOR Y NO HEMOS PUESTO last_anio = 0
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=ANT0000;ENDFUNC=ANT0000;Format=#,##0.00',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=EROG0000;ENDFUNC=EROG0000;Format=#,##0.00',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=GAR0000;ENDFUNC=GAR0000;Format=#,##0.00',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=INTERCO0000;ENDFUNC=INTERCO0000;Format=#,##0.00',
                 0);
        put_data(vcontent,
                 vno_linea,
                 'INITFUNC=GARANTIA0000;ENDFUNC=GARANTIA0000;Format=#,##0.00',
                 0);
      end if;
    
      -- DESPUES, LO DEL PENULTIMO AÑO
      cur_anio := anio_base;
      last_bim := -1;
    
      for j in res_bimestre(cur_anio, i.micli) loop
        if last_bim = -1 and j.bim = 1 then
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=ANT00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=ANT00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=EROG00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=EROG00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=GAR00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=GAR00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=INTERCO00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=INTERCO00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=GARANTIA00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=GARANTIA00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
        end if;
        last_bim := j.bim;
      
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESANTCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=ANT' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';ENDFUNC=ANT' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';Format=#,##0.00',
                 j.ant);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESEROCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=EROG' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';ENDFUNC=EROG' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';Format=#,##0.00',
                 j.erog);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESGARCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=GAR' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';ENDFUNC=GAR' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';Format=#,##0.00',
                 j.gar);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESINTERCOCLI' ||
                 to_char(i.micli, 'FM99999990') || ',1;INITFUNC=INTERCO' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';ENDFUNC=INTERCO' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';Format=#,##0.00',
                 j.interco);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESGARANTIACLI' ||
                 to_char(i.micli, 'FM99999990') || ',1;INITFUNC=GARANTIA' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';ENDFUNC=GARANTIA' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';Format=#,##0.00',
                 j.garantia);
      end loop;
    
      -- DESPUES, LO DEL ULTIMO AÑO
      cur_anio := cur_anio + 1;
      last_bim := -1;
    
      for j in res_bimestre(cur_anio, i.micli) loop
        if last_bim = -1 and j.bim = 1 then
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=ANT00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=ANT00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=EROG00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=EROG00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=GAR00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=GAR00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=INTERCO00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=INTERCO00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
          put_data(vcontent,
                   vno_linea,
                   'INITFUNC=GARANTIA00' || to_char(cur_anio, 'FM0000') ||
                   ';ENDFUNC=GARANTIA00' || to_char(cur_anio, 'FM0000') ||
                   ';Format=#,##0.00',
                   0);
        end if;
        last_bim := j.bim;
      
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESANTCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=ANT' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';ENDFUNC=ANT' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';Format=#,##0.00',
                 j.ant);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESEROCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=EROG' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';ENDFUNC=EROG' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';Format=#,##0.00',
                 j.erog);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESGARCLI' || to_char(i.micli, 'FM99999990') ||
                 ',1;INITFUNC=GAR' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';ENDFUNC=GAR' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';Format=#,##0.00',
                 j.gar);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESINTERCOCLI' ||
                 to_char(i.micli, 'FM99999990') || ',1;INITFUNC=INTERCO' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';ENDFUNC=INTERCO' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';Format=#,##0.00',
                 j.interco);
        put_data(vcontent,
                 vno_linea,
                 'ADDSELECTION=RESGARANTIACLI' ||
                 to_char(i.micli, 'FM99999990') || ',1;INITFUNC=GARANTIA' ||
                 to_char(j.bim, 'FM00') || to_char(cur_anio, 'FM0000') ||
                 ';ENDFUNC=GARANTIA' || to_char(j.bim, 'FM00') ||
                 to_char(cur_anio, 'FM0000') || ';Format=#,##0.00',
                 j.garantia);
      end loop;
    
    end loop;
  ////////////*********************/
    append_new_line(vcontent, vno_linea);
  
    last_anio := anio_base;
  
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|Datos|', false);
    put_data(vcontent, vno_linea, '', '');
    put_data(vcontent, vno_linea, '', '');
  
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=RESTOTANTCLI,SUM;CLEARFUNC=RESTOTANTCLI;Format=#,##0.00',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=RESTOTEROCLI,SUM;CLEARFUNC=RESTOTEROCLI;Format=#,##0.00',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=RESTOTGARCLI,SUM;CLEARFUNC=RESTOTGARCLI;Format=#,##0.00',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=RESTOTINTERCOCLI,SUM;CLEARFUNC=RESTOTINTERCOCLI;Format=#,##0.00',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=RESTOTGARANTIACLI,SUM;CLEARFUNC=RESTOTGARANTIACLI;Format=#,##0.00',
             '');
  
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=RESTOTDIFCLI,SUM;CLEARFUNC=RESTOTDIFCLI;Format=#,##0.00',
             '');
  
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=RESTOTDIFCLIMAS,SUM;CLEARFUNC=RESTOTDIFCLIMAS;Format=#,##0.00',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=RESTOTDIFCLIMENOS,SUM;CLEARFUNC=RESTOTDIFCLIMENOSS;Format=#,##0.00',
             '');
  
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=ANT0000,SUM;Format=#,##0.00;CLEARFUNC=ANT0000',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=EROG0000,SUM;Format=#,##0.00;CLEARFUNC=EROG0000',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=GAR0000,SUM;Format=#,##0.00;CLEARFUNC=GAR0000',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=INTERCO0000,SUM;Format=#,##0.00;CLEARFUNC=INTERCO0000',
             '');
    put_data(vcontent,
             vno_linea,
             'PUTFUNC=GARANTIA0000,SUM;Format=#,##0.00;CLEARFUNC=GARANTIA0000',
             '');
  
    for i in last_anio .. anio_max loop
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=ANT00' || to_char(i, 'FM0000') ||
               ',SUM;Format=#,##0.00;CLEARFUNC=ANT00' ||
               to_char(i, 'FM0000'),
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=EROG00' || to_char(i, 'FM0000') ||
               ',SUM;Format=#,##0.00;CLEARFUNC=EROG00' ||
               to_char(i, 'FM0000'),
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=GAR00' || to_char(i, 'FM0000') ||
               ',SUM;Format=#,##0.00;CLEARFUNC=GAR00' ||
               to_char(i, 'FM0000'),
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=INTERCO00' || to_char(i, 'FM0000') ||
               ',SUM;Format=#,##0.00;CLEARFUNC=INTERCO00' ||
               to_char(i, 'FM0000'),
               '');
      put_data(vcontent,
               vno_linea,
               'PUTFUNC=GARANTIA00' || to_char(i, 'FM0000') ||
               ',SUM;Format=#,##0.00;CLEARFUNC=GARANTIA00' ||
               to_char(i, 'FM0000'),
               '');
    
      if i < to_number(to_char(trunc(vfecha_max, 'YYYY'), 'YYYY')) or
         to_number(to_char(vfecha_max, 'MM')) > 6 then
        put_data(vcontent,
                 vno_linea,
                 'PUTFUNC=ANT01' || to_char(i, 'FM0000') ||
                 ',SUM;Format=#,##0.00;CLEARFUNC=ANT01' ||
                 to_char(i, 'FM0000'),
                 '');
        put_data(vcontent,
                 vno_linea,
                 'PUTFUNC=EROG01' || to_char(i, 'FM0000') ||
                 ',SUM;Format=#,##0.00;CLEARFUNC=EROG01' ||
                 to_char(i, 'FM0000'),
                 '');
        put_data(vcontent,
                 vno_linea,
                 'PUTFUNC=GAR01' || to_char(i, 'FM0000') ||
                 ',SUM;Format=#,##0.00;CLEARFUNC=GAR01' ||
                 to_char(i, 'FM0000'),
                 '');
        put_data(vcontent,
                 vno_linea,
                 'PUTFUNC=INTERCO01' || to_char(i, 'FM0000') ||
                 ',SUM;Format=#,##0.00;CLEARFUNC=INTERCO01' ||
                 to_char(i, 'FM0000'),
                 '');
        put_data(vcontent,
                 vno_linea,
                 'PUTFUNC=GARANTIA01' || to_char(i, 'FM0000') ||
                 ',SUM;Format=#,##0.00;CLEARFUNC=GARANTIA01' ||
                 to_char(i, 'FM0000'),
                 '');
      end if;
    end loop;
    append_new_line(vcontent, vno_linea);
    append_data(vcontent, vno_linea, '|AutoFit|', false);
  
    cur_anio := to_number(to_char(trunc(vfecha_max, 'YYYY'), 'YYYY'));
    cur_anio := cur_anio - 1;
  
    