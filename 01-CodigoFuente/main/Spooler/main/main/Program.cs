// See https://aka.ms/new-console-template for more information
using serverreports;
using System.Data;
int rep_id = 0;
int sw_cron = 0;
int visible_sql = 0;
string msg = "";
string sqladd = " ,case when (@param=0 and  rep.FRECUENCIA is not null) then logis.display_fecha_confirmacion4(rep.FRECUENCIA, sysdate, sysdate,1)  end fecha  ";
int reporte_temporal = 0;
string FECHA_1 = "";
string FECHA_2 = "";
int num_of_param = 0;
///init_var()
string Errror = "";
string cc_mail = "";
string mail_server = "";
string mail_footer = "";
string mail_From = "";
string mail_FromName = "";
string[] mail_grupo_error = new string[1];
string[] Error_texto = new string[1];

string IP_servidor1 = "";
string IP_servidor2 = "";
string first_path = "";
string second_path = "";
string Get_IP = "";
string mail_Lots_Info = "";
bool mail_adjuntarArchivoXLS = false;
bool mail_adjuntarArchivoTXT = false;
string mail_tempFolder = "";
bool bExit = false;
///
string[,] tab_archivos;

string[] tab_files;

string reporte_name = "";
int days_deleted = 0;
string file_name = "";
int id_Reporte = 0;
string mail_error = "";
string Carpeta = "";
string servidor = "";
string param_string = "";
string dest_mail = "";
string MiComando = "";
string fecha_1_intervalo = "";

string[,] pargral = new string[17, 2];
string[] contmail;
DataTable trep_cron = new DataTable();
DataTable tdato_repor = new DataTable();
DataTable tnum_param = new DataTable();
DataTable tmail_contact = new DataTable();
DataTable tconfirmacion2 = new DataTable();
try
{

    Utilerias util = new Utilerias();
    DM DM = new DM();
    (string[,]? LisDT_tit, DataTable[]? LisDT, string? arch) inf;
    Excel xlsx = new Excel();
    envio_correo correo = new envio_correo();
    init_var();

    try

    {
        string comand = args[0];
        rep_id = Convert.ToInt32(args[0]);
    }
    catch (Exception e) { msg = " ¡¡¡error opc de reporte¡¡ No.error" + e.HResult; }
    if (args.Length == 2 && args[1] == "1")
        reporte_temporal = 1;

    if (rep_id != 1)
    {
        trep_cron = DM.Main_rep("main_rp_cron", rep_id.ToString(), visible_sql, reporte_temporal.ToString()).tb;
        if (trep_cron.Rows.Count > 0)
            sw_cron = 1;
    }
    else
        Console.WriteLine("Falta el numero del reporte.....");
    if (rep_id != 0 && sw_cron == 1)
    {
        Console.WriteLine("****************************");
        Console.WriteLine("*   Spooler                 *");
        Console.WriteLine("****************************");
        Console.WriteLine("ID_CRON =" + rep_id);
        Console.WriteLine("reporte_temporal =" + reporte_temporal);
        //   Console.WriteLine(util.Tdetalle(trep_cron));
        //   util.CrearZip();
        // util.CrearZip2("C:\\pc\\file2.xlsx", ["C:\\pc\\file.xlsx", "C:\\pc\\prueba_adj.txt"], "C:\\pc");
        // Excel xlsx = new Excel();
        // xlsx.grafica();
        // Environment.Exit(0);

        //trep_cron = DM.main_rp_cron(id_cron.ToString(),0);
        /* por definir
         If rs.EOF Then
         GoTo Errman
           ElseIf rs.Fields("id_rep") <> "317" And rs.Fields("clistatus") = "1" And reporte_temporal<> 1 And rs.Fields("cliente") <> "0" And(CLng(rs.Fields("cliente")) < 9900 Or CLng(rs.Fields("cliente")) > 9999) Then
         Call send_error_mail("Error - Cliente inactivo - Report : < " & rs.Fields("NAME") & " >", mail_grupo_error, "El reporte tiene como cliente : " & rs.Fields("cli_nom") & " - " & " que es inactivo." & vbCrLf & "Favor de verificar lo y de quitar la programacion de este reporte.")
         GoTo Errman
         End If
        */
        
        if (reporte_temporal == 0)
        {
            string tm_fec = util.Tcampo(trep_cron, "fecha");
            FECHA_1 = tm_fec.Substring(0, 10);
            FECHA_2 = tm_fec.Substring(tm_fec.Length - 10, 10);
        }
        else
        {
            FECHA_1 = util.Tcampo(trep_cron, "fecha_1");
            FECHA_2 = util.Tcampo(trep_cron, "fecha_2");
        }

        if (FECHA_1 == FECHA_2)
        {

            //  Console.WriteLine("************** rep_dias_libres **************");
            string dialib = DM.Main_rep("rep_dias_libres", rep_id.ToString(), visible_sql, reporte_temporal.ToString(), util.Tcampo(trep_cron, "cliente"), FECHA_1).val;
                    //Por aplicar
            //            if (dialib != "")
            if (dialib != "0")
            {
                Console.WriteLine("************** actializa **************");
                string SQL_p = "update rep_chron set in_progress=0 \n" +
                 "where id_rapport= '" + rep_id + "' ";
                DM.ejecuta_sql(SQL_p, 1);
                Environment.Exit(0);
            }
        }

        if ((util.nvl(util.Tcampo(trep_cron, "CONFIRMACION")) == "1") && (reporte_temporal == 0))
        //    if (1 == 1)
        {
            string SQL_p2 = "select check_fecha_confirmacion2('" + util.Tcampo(trep_cron, "FRECUENCIA") + "',conf_date, conf_date_2) as ok \n" +
                          " , to_char(conf.conf_date, 'mm/dd/yyyy') as fecha_1 \n" +
                          " , to_char(conf.conf_date_2, 'mm/dd/yyyy') as fecha_2, conf.param \n" +
                          " from rep_confirmacion conf \n" +
                          " where conf.ID_CONF = '" + rep_id + "' \n" +
                          " and check_fecha_confirmacion2('" + util.Tcampo(trep_cron, "FRECUENCIA") + "',conf_date, conf_date_2) = 'ok' \n" +
                          " and trunc(conf_date) +decode(" + util.Tcampo(trep_cron, "FRECUENCIA") + ", 1, 1, 0) <= trunc(sysdate) \n" +
                          "";
            //Console.WriteLine("************** confirma fecha **************");
            //Console.WriteLine(SQL_p2);

            tconfirmacion2 = DM.Main_rep("confirmacion2", rep_id.ToString(), visible_sql, reporte_temporal.ToString(), null, util.Tcampo(trep_cron, "FRECUENCIA")).tb;

            if (util.Tcampo(tconfirmacion2, "CONFIRMACION") != "")            
            {
                SQL_p2 = "select display_fecha_confirmacion4(('" + util.Tcampo(trep_cron, "FRECUENCIA") + "',conf.CONF_DATE,conf.CONF_DATE_2,decode(conf.CONF_DATE,null,1,0)) as next_fecha \n" +
             " from rep_confirmacion conf \n" +
             " where  conf.ID_CONF = '" + rep_id + "' \n" +
             " order by to_date(next_fecha, 'mm/dd/yyyy') desc \n";
                string confirma4 = DM.Main_rep("confirmacion4", rep_id.ToString(), visible_sql, reporte_temporal.ToString(), null, util.Tcampo(trep_cron, "FRECUENCIA")).val;
                //  Console.WriteLine(" valor confirma4 =" + confirma4);

                if (confirma4 != "null")
                    mail_error = "agregar valor de " + confirma4;
                else
                    mail_error = "Ninguna confirmacion llegada.";
            }
            //Console.WriteLine("************** confirma fecha 2**************");
            
        }


        if (mail_error != "")
        {
            tmail_contact = DM.Main_rep("main_mail_contact", rep_id.ToString(), visible_sql).tb;
            string tema = "Error generacion de : " + util.Tcampo(tmail_contact, "NAME");
            string contactos = util.listTcampo(tmail_contact, "mail", ";");
            contactos = contactos + mail_grupo_error[0];
            if (mail_error.Split("/").Length > 1)
            {
                Error_texto = mail_error.Split("|");
                mail_error = "Id_reporte : " + rep_id + "\n" +
                    "Fecha 1 : " + Error_texto[0] + "\n" +
                    "Fecha 2 : " + Error_texto[1];
            }
            else
            {
                mail_error = "Id_reporte : " + rep_id + "\n" +
                     "Fecha : " + mail_error;
            }

            string cuerpo = "Error en la generacion de este reporte, no se ha creado." + "\n" +
                 "Falta confirmacion : \n" +
            mail_error +
                 mail_footer;
            Errror = DM.ejecuta_sql("update rep_chron set in_progress=0 where id_rapport= '" + rep_id + "'");
        }

        tdato_repor = DM.Main_rep("main_datos_rep", rep_id.ToString(), visible_sql, util.arma_param("REP.PARAM_", num_of_param)).tb;
        if (tdato_repor.Rows.Count > 0)
        {
            contmail = new string[tdato_repor.Rows.Count];
            for (int j = 0; j < tdato_repor.Rows.Count; j++)
            {
                contmail[j] = tdato_repor.Rows[j]["mail"].ToString();
            }
        }
        else
            contmail = new string[0];

        dest_mail = util.nvl(util.Tcampo(tdato_repor, "DEST_MAIL"));
        for (int i = 1; i <= num_of_param; i++)
        {
            param_string = param_string + util.nvl(util.Tcampo(tdato_repor, "PARAM_" + i));
            if (i != num_of_param) { param_string = param_string + "|"; }
        }
        reporte_name = util.nvl(util.Tcampo(tdato_repor, "NAME"));
        days_deleted = Int32.Parse(util.nvl(util.Tcampo(tdato_repor, "DAYS_DELETED"), "n"));
        //file_name = util.nvl(util.Tcampo(tdato_repor, "FILE_NAME"));
        file_name = util.filter_file_name(util.nvl(util.Tcampo(tdato_repor, "FILE_NAME")), FECHA_1, FECHA_2);
        id_Reporte = Int32.Parse(util.nvl(util.Tcampo(tdato_repor, "ID_REP")));
        //Carpeta = first_path & NVL(rs.Fields("CARPETA")) & "\" & IIf(NVL(rs.Fields("SUBCARPETA")) <> "", NVL(rs.Fields("SUBCARPETA")) & "\", "")
        Carpeta = first_path + util.nvl(util.Tcampo(tdato_repor, "CARPETA")) + "\\" +
                          util.iff(util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA")), "<>", "", util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA")) + "\\", "");
        MiComando = util.nvl(util.Tcampo(tdato_repor, "COMMAND"));

        tab_archivos = new string[6, 2];
        tab_archivos[0, 0] = file_name;
        tab_archivos[1, 0] = reporte_name;
        tab_archivos[4, 0] = "1";
        //servidor = "http://" & Trim(Split(Get_IP(), "-")(0))
        servidor = "http://" + Get_IP;

        //Console.WriteLine("valor servidor:" + servidor);
        //  Carpeta = "C:\\Users\\usuario\\Desktop\\Raul\\prueba";

        if (!Directory.Exists(Carpeta))
        {
            Directory.CreateDirectory(Carpeta);
        }
        //servidor = "http://" & Trim(Split(Get_IP(), "-")(0))
        servidor = "http://" + Get_IP;
        servidor = "http://www.logiscomercioexterior.com.mx";
        //Console.WriteLine("valor servidor:" + servidor);

        pargral[0, 0] = "DEST_MAIL";
        pargral[0, 1] = dest_mail;
        pargral[1, 0] = "Carpeta";
        pargral[1, 1] = util.nvl(util.Tcampo(tdato_repor, "CARPETA"));
        pargral[2, 0] = "param_string";
        pargral[2, 1] = param_string;
        pargral[3, 0] = "days_deleted";
        pargral[3, 1] = days_deleted.ToString();
        pargral[4, 0] = "SUBCARPETA";
        pargral[4, 1] = util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA"));
        pargral[5, 0] = "id_Reporte";
        pargral[5, 1] = id_Reporte.ToString();
        pargral[6, 0] = "FECHA_1";
        pargral[6, 1] = FECHA_1;
        pargral[7, 0] = "FECHA_2";
        pargral[7, 1] = FECHA_2;
        pargral[8, 0] = "fecha_1_intervalo";
        pargral[8, 1] = fecha_1_intervalo;
        pargral[9, 0] = "id_cron";
        pargral[9, 1] = rep_id.ToString();
        pargral[10, 0] = "Servidor";
        pargral[10, 1] = servidor;
        pargral[11, 0] = "second_path";
        pargral[11, 1] = second_path;
        pargral[12, 0] = "Path_file";
        pargral[12, 1] = Carpeta;
        pargral[13, 0] = "usr_bd";
        pargral[13, 1] = "2";
        pargral[14, 0] = "ip";
        pargral[14, 1] = util.Tcampo(trep_cron, "IP_ADDRESS_err");
        pargral[15, 0] = "param3";
        pargral[15, 1] = util.nvl(util.Tcampo(tdato_repor, "PARAM_3"));
        pargral[16, 0] = "param4";
        pargral[16, 1] = util.nvl(util.Tcampo(tdato_repor, "PARAM_4"));

        string[] arh;
        if (tab_archivos[4, 0] == "1")
            arh = new string[2];
        else
            arh = new string[1];
        string arch = "";
        int encorr = 0;
        switch (MiComando)
        {
            case "gsk_pedimientos":
                //gsk 3723307
                pargral[13, 1] = "1";
                trading_genera_GSK_mod trading_genera_GSK = new trading_genera_GSK_mod();
                trading_genera_GSK.trading_genera_GSK(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), rep_id, pargral, contmail, visible_sql);
                break;
            
            case "porteos_tln":
                // 6651805
                pargral[13, 1] = "1";
                trading_genera_TLN_mod trading_genera_TLN = new trading_genera_TLN_mod();
                trading_genera_TLN.trading_genera_TLN(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), rep_id, servidor, pargral, contmail, visible_sql);
                break;

            case "ing_egr_gar_pend_fact":
                //4220496
                //4241096
                //7216555
                //5566766
                pargral[13, 1] = "1";
                Ing_egr_gar_pend_fact_mod Ing_egr_gar_pend_fact = new Ing_egr_gar_pend_fact_mod();
                inf = Ing_egr_gar_pend_fact.Ing_egr_gar_pend_fact(tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), pargral, contmail, visible_sql);
                // arch = xlsx.CrearExcel_file(inf.LisDT, inf.LisDT_tit, Carpeta + "\\" + inf.arch + ".xlsx", null, null, 0);
                arch = xlsx.CrearExcel_filen(inf.LisDT, inf.LisDT_tit, Carpeta + "\\" + inf.arch + ".xlsx", null, null, 1, 3);
                encorr = 1;
                break;

            case "fondo_fijo":
                //5566768
                pargral[13, 1] = "1";
                web_fondo_fijo_mod Fondo_fijo = new web_fondo_fijo_mod();
                inf = Fondo_fijo.Fondo_fijo(tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), pargral, contmail, visible_sql);
                arch = xlsx.CrearExcel_filen(inf.LisDT, inf.LisDT_tit, Carpeta + "\\" + inf.arch + ".xlsx", null, null, 1, 3);
                encorr = 1;
                break;

            case "reservacion_ltl":
                //5545714
                pargral[13, 1] = "1";
                pargral[15, 1] = "1";//txt
                pargral[16, 1] = "";
                web_reservacion_LTL_mod reservacion_ltl = new web_reservacion_LTL_mod();
                inf = reservacion_ltl.reservacion_ltl(Carpeta, tab_archivos, "23213", "3", pargral, visible_sql, rep_id.ToString());
                //inf = reservacion_ltl.reservacion_ltl(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), pargral, visible_sql);
                encorr = 2;
                break;

            case "reservacion_CD":
                //5545714
                //7774047
                pargral[13, 1] = "1";
                web_reservacion_CD_mod reservacion_CD = new web_reservacion_CD_mod();
                inf = reservacion_CD.reservacion_CD(Carpeta, tab_archivos, "20660", "3", pargral, visible_sql, rep_id.ToString());
                break;

            case "reservacion_ltl_excel":
                //7864811
                pargral[13, 1] = "1";
                pargral[15, 1] = "";//txt
                pargral[16, 1] = "1";//xlsx
                web_reservacion_LTL_mod reservacion_ltl_xlsx = new web_reservacion_LTL_mod();
                inf = reservacion_ltl_xlsx.reservacion_ltl(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), "3", pargral, visible_sql, rep_id.ToString());
                //inf = reservacion_ltl.reservacion_ltl(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), pargral, visible_sql);                
                arch = xlsx.CrearExcel_filen(inf.LisDT, inf.LisDT_tit, Carpeta + "\\" + inf.arch + ".xlsx", null, null, 1, 0);
                encorr = 1;
                break;

            case "conv_sin_exp":
                //7864811
                pargral[13, 1] = "1";
                pargral[15, 1] = "";//txt
                pargral[16, 1] = "1";//xlsx
                web_conv_sin_exp_mod conv_sin_exp = new web_conv_sin_exp_mod();
                inf = conv_sin_exp.conv_sin_exp(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), "3", pargral, visible_sql, rep_id.ToString());
                //inf = reservacion_ltl.reservacion_ltl(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), pargral, visible_sql);                
                arch = xlsx.CrearExcel_filen(inf.LisDT, inf.LisDT_tit, Carpeta + "\\" + inf.arch + ".xlsx", null, null, 1, 0);
                encorr = 1;
                break;
















                /*
                            case "transmision_edocs_bosch":
                                //5132031
                                web_transmision_edocs_bosch edocs_bosch = new web_transmision_edocs_bosch();
                                edocs_bosch.transmision_edocs_bosch(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), pargral, contmail, visible_sql);
                                break;

                            case "ind_cal_bosch":
                                //5071980
                                web_indice_cal_bosch indice_cal_bosch = new web_indice_cal_bosch();
                                inf = indice_cal_bosch.indice_cal_bosch(Carpeta, tab_archivos, FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), pargral, contmail, visible_sql);
                                //indice_cal_bosch.indice_cal_bosch(Carpeta, tab_archivos[0], FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), visible_sql);
                                arch = xlsx.CrearExcel_filen(inf.LisDT, inf.LisDT_tit, Carpeta + "\\" + inf.arch + ".xlsx", null, null, 5, 2, 1, 1);
                                encorr = 1;

                                break;
                            case "bosch_pedim2":
                                //case "bosch_pedim3":
                                //5335530
                                Bosch_pedimentos2_mod Bosch_Pedimentos2 = new Bosch_pedimentos2_mod();
                                inf = Bosch_Pedimentos2.Bosch_Pedimentos2(Carpeta, tab_archivos, FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), pargral, contmail, visible_sql);
                                encorr = 2;
                                break;
                            //case "bosch_pedim3":
                            case "bosch_pedim2_xlsok":
                                //5335530
                                Bosch_pedimentos2_xls_mod Bosch_Pedimentos2_xls = new Bosch_pedimentos2_xls_mod();
                                inf = Bosch_Pedimentos2_xls.Bosch_Pedimentos2_xls(Carpeta, tab_archivos, FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), pargral, visible_sql);
                                arch = xlsx.CrearExcel_filen(inf.LisDT, inf.LisDT_tit, Carpeta + "\\" + inf.arch + ".xlsx", null, null, 1, 0);
                                encorr = 1;
                                break;
                            case "bosch_pedim3ok":
                                //5335530                
                                Bosch_pedimentos3_mod Bosch_Pedimentos3 = new Bosch_pedimentos3_mod();
                                inf = Bosch_Pedimentos3.Bosch_Pedimentos3(Carpeta, tab_archivos, "01/09/2004", "09/04/2006", "2478", "1", null, null, pargral, visible_sql);
                                //inf = Bosch_Pedimentos3.Bosch_Pedimentos3(Carpeta, tab_archivos, FECHA_1     , FECHA_2     , util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")),util.nvl(util.Tcampo(tdato_repor, "PARAM_4")), pargral,  visible_sql);
                                encorr = 2;
                                break;
                            case "bosch_pedim3":
                                //case "bosch_pedim3_xls":
                                //5335530                
                                Bosch_pedimentos3_xls_mod Bosch_Pedimentos3_xls = new Bosch_pedimentos3_xls_mod();
                                inf = Bosch_Pedimentos3_xls.Bosch_Pedimentos3_xls(Carpeta, tab_archivos, "03/14/2013", "03/23/2013", "11244", "1", null, null, pargral, visible_sql);
                                //inf = Bosch_Pedimentos3_xls.Bosch_Pedimentos3_xls(Carpeta, tab_archivos, FECHA_1     , FECHA_2     , util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")),util.nvl(util.Tcampo(tdato_repor, "PARAM_4")), pargral,  visible_sql);
                                arch = xlsx.CrearExcel_filen(inf.LisDT, inf.LisDT_tit, Carpeta + "\\" + inf.arch + ".xlsx", null, null, 1, 0);
                                encorr = 1;
                                break;
                            //case "bosch_pedim3_xls":
                */
        }
        if (encorr > 0)
        {
            string[,] html = new string[6, 1];
            arch = tab_archivos[0, 0];
            if (encorr == 2)
            {
                arh[0] = Carpeta + "\\" + tab_archivos[0, 0] + ".txt";
                tab_archivos[0, 0] = tab_archivos[0, 0] + ".txt";
            }
            else
            {
                arh[0] = Carpeta + "\\" + tab_archivos[0, 0] + ".xlsx";
                tab_archivos[0, 0] = tab_archivos[0, 0] + ".xlsx";
            }

            if (tab_archivos[4, 0] == "1")
            {
                //arh[1] = util.agregar_zip_nv(file_name, arch, Carpeta);
                html = util.agregar_zip(tab_archivos, arch, Carpeta);
                arh[1] = Carpeta + "\\" + arch + ".zip";
            }
            // tab_archivos[4, 0] = "0";
            html = util.hexafile_nv(tab_archivos, Carpeta, int.Parse(pargral[9, 1]), arch, pargral);
            string mensaje = correo.display_mail(pargral[10, 1], "", arch, html, Int32.Parse(pargral[3, 1]), "");
            util.replica_tem(arch, pargral);
            if (contmail.Length > 0)
            {
                string[,] cor = new string[0, 0];
                //correo.send_mail("Report: " + html[1, 0] + " created v2024", contacmail, mensaje, arh);
                // correo.send_mail("Report: Reservacion_de_Guias_LTL  created v2024", [], mensaje, arh);
                correo.send_mail("Report: " + html[1, 0] + " created v2024", [], mensaje, arh);
            
            }
            DM.act_proceso(pargral, visible_sql);
            util.borra_arch(arh, Carpeta);
        }
    }
    else
        Console.WriteLine("Error es necesario especifica los parametros \n 1. Falta numero reporte: ''{0}'' \n 2. valor tipo de reporte: {1} " + msg, rep_id, reporte_temporal);

    Console.WriteLine("Oprimar cualquier tecla para terminar");
    trep_cron.Dispose();
    tdato_repor.Dispose();
    tnum_param.Dispose();
    tmail_contact.Dispose();
    Console.ReadKey();
}
catch (Exception e)
{
    Console.WriteLine(e.Message + " No. error" + e.HResult);

}
trep_cron.Dispose();
tdato_repor.Dispose();
tnum_param.Dispose();
tmail_contact.Dispose();
tconfirmacion2.Dispose();

void init_var()
{
    num_of_param = 0;
    //parametros de correos
    cc_mail = "";
    mail_server = "192.168.100.6";
    mail_footer = "\n" + "\n" + "\n" +
    "*********************************************************\n" +
    "This is a message automatically generated, please contact \n" +
    "web-master@logis.com.mx for any question or to unsubscribe.";
    mail_From = "web-reports@logis.com.mx";
    mail_FromName = "Logis report server";
    mail_grupo_error[0] = "desarrollo_web@logis.com.mx ;";
    /*
    IP_servidor1 = "192.168.100.5";
    IP_servidor2 = "192.168.100.4";
    first_path = "\\\\" + IP_servidor1 + "\\reportes\\web_reports\\";
    second_path = "\\\\" + IP_servidor2 + "\\reportes\\web_reports\\";
    Get_IP = util.Get_IP();
    first_path = "\\\\" + Get_IP + "\\reportes\\web_reports\\";
    */
    /**comodin para probar ***/
    IP_servidor1 = AppDomain.CurrentDomain.BaseDirectory;
    IP_servidor2 = AppDomain.CurrentDomain.BaseDirectory;
    first_path = IP_servidor1 + "\\reportes\\web_reports\\";
    second_path = IP_servidor2 + "\\reportes\\web_reports\\";
    /**comodin para probar ***/

    if (Get_IP == IP_servidor1)
        second_path = "\\\\" + IP_servidor2 + "\\reportes\\web_reports\\";
    else
        second_path = "\\\\" + IP_servidor1 + "\\reportes\\web_reports\\";
    second_path = "C:\\pc\\ruta_alterna\\ejeml\\";
    mail_Lots_Info = "";
    mail_adjuntarArchivoXLS = false;
    mail_adjuntarArchivoTXT = false;
    mail_tempFolder = "\\\\192.168.100.4\\reportes\\web_reports\\temp\\";
    bExit = false;
    string Error = "0";
}
void Errman(Exception e)
{

}
