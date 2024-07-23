// See https://aka.ms/new-console-template for more information
using System.Data;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using serverreports;
using static System.Net.Mime.MediaTypeNames;
using static System.Runtime.InteropServices.JavaScript.JSType;
int rep_id = 0;
int sw_cron = 0;
int visible_sql =1;
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
string[,] parins = new string[13, 2];
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
 init_var();

    try
 
    { string comand = args[0];
   rep_id = Convert.ToInt32(args[0]); } 
   catch (Exception e) { msg = " ¡¡¡error opc de reporte¡¡ No.error" + e.HResult; }
 if (args.Length == 2 && args[1] == "1")
    reporte_temporal = 1;

 if (rep_id != 1)
 {
    trep_cron = DM.Main_rep("main_rp_cron", rep_id.ToString(), visible_sql,  reporte_temporal.ToString()).tb;
    

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
    Console.WriteLine(util.Tdetalle(trep_cron));
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
        /* DataTable tfec_conf = new DataTable(); si se habilida independientes*/
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
    Console.WriteLine("display_fecha_confirmacion4 :" + FECHA_1 + " :" + FECHA_2);

        if (FECHA_1 == FECHA_2)
        {

            Console.WriteLine("************** rep_dias_libres **************");
            string dialib = DM.Main_rep("rep_dias_libres", rep_id.ToString(), visible_sql, reporte_temporal.ToString(), util.Tcampo(trep_cron, "cliente"), FECHA_1).val;
            /*
            string SQL_p = " select 1 from rep_dias_libres \n" +
            " where dia_libre = to_date('" + FECHA_1 + "', 'mm/dd/yyyy') \n" +
            " and cliente in ('" + rep_id.ToString() + "', 0) \n";
            // DM.datos(SQL_p);
            Console.WriteLine(SQL_p);
            */
            Console.WriteLine(" valor dia libre =" + dialib);
            //Por aplicar
            //            if (dialib != "")
            if (dialib !="0")
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
            Console.WriteLine("************** confirma fecha **************");
            Console.WriteLine(SQL_p2);

            tconfirmacion2 = DM.Main_rep("confirmacion2", rep_id.ToString(), visible_sql, reporte_temporal.ToString(), null, util.Tcampo(trep_cron, "FRECUENCIA")).tb;

            if (util.Tcampo(tconfirmacion2, "CONFIRMACION") != "")
           // if (1 == 1)
            {
                SQL_p2 = "select display_fecha_confirmacion4(('" + util.Tcampo(trep_cron, "FRECUENCIA") + "',conf.CONF_DATE,conf.CONF_DATE_2,decode(conf.CONF_DATE,null,1,0)) as next_fecha \n" +
             " from rep_confirmacion conf \n" +
             " where  conf.ID_CONF = '" + rep_id + "' \n" +
             " order by to_date(next_fecha, 'mm/dd/yyyy') desc \n";
                string confirma4 = DM.Main_rep("confirmacion4", rep_id.ToString(), visible_sql, reporte_temporal.ToString(), null, util.Tcampo(trep_cron, "FRECUENCIA")).val;
                Console.WriteLine(" valor confirma4 =" + confirma4);

                if (confirma4 != "null")
                    mail_error = "agregar valor de " + confirma4;
                else
                    mail_error = "Ninguna confirmacion llegada.";
            }
            Console.WriteLine("************** confirma fecha 2**************");
            Console.WriteLine(SQL_p2);
        }

        /*
         If FECHA_1 = FECHA_2 Then
        valida 
            sql 4 y 4.1

        */

        //////*******  Parametros *********////////////////////

        /*
        valida confirmacion
        sql 5 y 5.1
        */


        if (mail_error != "")
    {
        tmail_contact = DM.Main_rep("main_mail_contact", rep_id.ToString(), visible_sql).tb;
        //proceso de envio de correo
        Console.WriteLine("************** SQL contactos **************");
        Console.WriteLine(util.Tdetalle(tmail_contact));

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



    //////*******  Parametros *********////////////////////

    tnum_param = DM.Main_rep("main_num_param", rep_id.ToString(), visible_sql).tb;

    try { num_of_param = Convert.ToInt32(util.Tcampo(tnum_param, "NUM_OF_PARAM")); } catch (Exception) { }
    Console.WriteLine("Numero Parametros : " + num_of_param);
    util.arma_param("REP.PARAM_", num_of_param);
    Console.WriteLine("Parametros : " + util.arma_param("REP.PARAM_", num_of_param));

    tdato_repor = DM.Main_rep("main_datos_rep", rep_id.ToString(), visible_sql, util.arma_param("REP.PARAM_", num_of_param)).tb;
    Console.WriteLine("************** datos repore **************");
    Console.WriteLine(util.Tdetalle(tdato_repor));
        ///////////////////////////////////////
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

    tab_archivos = new string[6,2];
    tab_archivos[0,0] = file_name;
    tab_archivos[1,0] = reporte_name;
    tab_archivos[4,0] = "1";


    Console.WriteLine("valor ''dest_mail   '':" + dest_mail);
    Console.WriteLine("valor ''param_string'':" + param_string);
    Console.WriteLine("valor ''reporte_name'':" + reporte_name);
    Console.WriteLine("valor ''days_deleted'':" + days_deleted);
    Console.WriteLine("valor ''file_name   '':" + file_name);
    Console.WriteLine("valor ''id_Reporte  '':" + id_Reporte);
    Console.WriteLine("valor ''Carpeta     '':" + Carpeta);
    Console.WriteLine("valor ''COMMAND     '' " + MiComando);

    Console.WriteLine("valor ''tab_archivos 0 '':" + tab_archivos[0,0]);
    Console.WriteLine("valor ''tab_archivos 1 '':" + tab_archivos[1,0]);
    Console.WriteLine("valor ''tab_archivos 4 '' " + tab_archivos[4,0]);
    for (int i = 1; i <= num_of_param; i++)
        Console.WriteLine("valor ''PARAM_"+i+" '':" + util.nvl(util.Tcampo(tdato_repor, "PARAM_"+i)));

    Console.WriteLine("valor ''FECHA_1'':" + FECHA_1);
    Console.WriteLine("valor ''FECHA_2'':" + FECHA_2);

    Console.WriteLine("valor ''filter_file_name     '' " + util.filter_file_name(file_name, FECHA_1, FECHA_2));

    //servidor = "http://" & Trim(Split(Get_IP(), "-")(0))
    servidor = "http://" + Get_IP;
 
    Console.WriteLine("valor servidor:" + servidor);
  //  Carpeta = "C:\\Users\\usuario\\Desktop\\Raul\\prueba";

    if (!Directory.Exists(Carpeta))
    {
        Directory.CreateDirectory(Carpeta);
    }
    //servidor = "http://" & Trim(Split(Get_IP(), "-")(0))
    servidor = "http://" + Get_IP;
        servidor = "http://www.logiscomercioexterior.com.mx";
        Console.WriteLine("valor servidor:" + servidor);
   // Carpeta = "C:\\Users\\usuario\\Desktop\\Raul\\prueba1";
    if (!Directory.Exists(Carpeta))
    {
        Directory.CreateDirectory(Carpeta);
        Console.WriteLine("carpeta creada :" + Carpeta);
    }
    else Console.WriteLine("La carpeta existe.."+Carpeta);

        parins[0, 0]  = "DEST_MAIL";
        parins[0, 1]  = dest_mail;
        parins[1, 0]  = "Carpeta";
        parins[1, 1]  = util.nvl(util.Tcampo(tdato_repor, "CARPETA"));
        parins[2, 0]  = "param_string";
        parins[2, 1]  = param_string;
        parins[3, 0]  = "days_deleted";
        parins[3, 1]  = days_deleted.ToString();
        parins[4, 0]  = "SUBCARPETA";
        parins[4, 1]  = util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA"));
        parins[5, 0]  = "id_Reporte";
        parins[5, 1]  = id_Reporte.ToString();
        parins[6, 0]  = "FECHA_1";
        parins[6, 1]  = FECHA_1;
        parins[7, 0]  = "FECHA_2";
        parins[7, 1]  = FECHA_2;
        parins[8, 0]  = "fecha_1_intervalo";
        parins[8, 1]  = fecha_1_intervalo;
        parins[9, 0] = "id_cron";
        parins[9, 1] = rep_id.ToString();
        parins[10, 0] = "Servidor";
        parins[10, 1] = servidor;
        parins[11, 0] = "second_path";
        parins[11, 1] = second_path;
        parins[12, 0] = "Path_file";
        parins[12, 1] = Carpeta;



        //web_transmision_edocs_bosch edocs_bosch = new web_transmision_edocs_bosch();
        //edocs_bosch.transmision_edocs_bosch(Carpeta, tab_archivos[0], util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), visible_sql);
        // Console.WriteLine(DM.transmision_edocs_bosch("18975", "04/01/2024", "04/30/2024", "", "E", "1"));

        //Console.WriteLine(DM.trading_genera_GSK(tab_archivos[0], FECHA_1, FECHA_2, "", rep_id, 1));
        //trading_genera_GSK_mod trading_genera_GSK = new trading_genera_GSK_mod();
        //Console.WriteLine(trading_genera_GSK.trading_genera_GSK(Carpeta, tab_archivos[0], util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), rep_id,visible_sql));
        //Console.WriteLine(trading_genera_GSK.trading_genera_GSK(Carpeta, "gsk_pedimientos", "20501,20502"                                , FECHA_1, FECHA_2, ""                                           , 3723307, visible_sql));

        switch (MiComando)
    {
        case "transmision_edocs_bosch":
             web_transmision_edocs_bosch edocs_bosch = new web_transmision_edocs_bosch();
             edocs_bosch.transmision_edocs_bosch(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), parins, contmail, visible_sql);
             break;
          
        case "gsk_pedimientos":
             trading_genera_GSK_mod trading_genera_GSK = new trading_genera_GSK_mod();
             trading_genera_GSK.trading_genera_GSK(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), rep_id, parins, contmail, visible_sql);
                
             break;
        case "porteos_tln":
             // 6651805
             trading_genera_TLN_mod trading_genera_TLN = new trading_genera_TLN_mod();
             trading_genera_TLN.trading_genera_TLN(Carpeta, tab_archivos, util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_2")), rep_id, servidor, parins, contmail, visible_sql);
             break;
        }

}
 else
    Console.WriteLine("Error es necesario especifica los parametros \n 1. Falta numero reporte: ''{0}'' \n 2. valor tipo de reporte: {1} " + msg, rep_id, reporte_temporal);
    envio_correo correo = new envio_correo();
 Console.WriteLine("Oprimar cualquier tecla para terminar");
 trep_cron.Clear();
 tdato_repor.Clear();
 tnum_param.Clear();
 tmail_contact.Clear();
 Console.ReadKey();
}
catch (Exception e)
{    
   Console.WriteLine(e.Message +" No. error" + e.HResult);
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
void Errman (Exception e)
{

}
