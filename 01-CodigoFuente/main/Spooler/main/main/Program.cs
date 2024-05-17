// See https://aka.ms/new-console-template for more information
using System.Data;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using serverreports;
using static System.Net.Mime.MediaTypeNames;
int rep_id = 0;
int sw_cron = 0;
int visible_sql =0;
string msg = "";
string sqladd = " ,case when (@param=1 and  rep.FRECUENCIA is not null) then logis.display_fecha_confirmacion4(rep.FRECUENCIA, sysdate, sysdate,1)  end fecha  ";
int reporte_temporal = 0;
string FECHA_1 = "";
string FECHA_2 = "";
int num_of_param = 0;
///init_var()
string cc_mail = "";
string mail_server = "";
string mail_footer = "";
string mail_From = "";
string mail_FromName = "";
string mail_grupo_error = "";
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

Utilerias util = new Utilerias();
DM DM = new DM();
init_var();
DataTable trep_cron = new DataTable();
DataTable tdato_repor = new DataTable();
string comand = args[0];
try { rep_id = Convert.ToInt32(args[0]); } catch (Exception) { msg = " ¡¡¡error opc de reporte¡¡"; }
if (args.Length == 2 && args[1] == "1")
reporte_temporal = 1;


if (rep_id != 0)
{
trep_cron = DM.Main_rep("main_rp_cron", rep_id.ToString(), visible_sql, sqladd.Replace("@param", "" + reporte_temporal + ""));
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
    DataTable tnum_param = new DataTable();
    DataTable tmail_contact = new DataTable();
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
        FECHA_1 = util.Tcampo(trep_cron, "fecha");
        FECHA_2 = util.Tcampo(trep_cron, "fecha");
    }
    else
    {
        FECHA_1 = util.Tcampo(trep_cron, "fecha_1");
        FECHA_2 = util.Tcampo(trep_cron, "fecha_2");
    }
    Console.WriteLine("display_fecha_confirmacion4 :" + FECHA_1 + " :" + FECHA_2);

    //   if (FECHA_1 == FECHA_2)
    {
        Console.WriteLine("************** rep_dias_libres **************");
        string SQL_p = " select 1 from rep_dias_libres \n" +
        " where dia_libre = to_date('" + FECHA_1 + "', 'mm/dd/yyyy') \n" +
        " and cliente in ('" + rep_id.ToString() + "', 0) \n";
        // DM.datos(SQL_p);
        Console.WriteLine(SQL_p);
        Console.WriteLine("************** actializa **************");
        SQL_p = "update rep_chron set in_progress=0 \n" +
            "where id_rapport= '" + rep_id + "' ";
        DM.ejecuta_sql(SQL_p, 1);
    }

    //   if  ((util.nvl(util.Tcampo(trep_cron, "CONFIRMACION")) == "1") && (reporte_temporal == 0)) 
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
        SQL_p2 = "select display_fecha_confirmacion4(('" + util.Tcampo(trep_cron, "FRECUENCIA") + "',conf.CONF_DATE,conf.CONF_DATE_2,decode(conf.CONF_DATE,null,1,0)) as next_fecha \n" +
         " from rep_confirmacion conf \n" +
         " where  conf.ID_CONF = '" + rep_id + "' \n" +
         " order by to_date(next_fecha, 'mm/dd/yyyy') desc \n";
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
        tmail_contact = DM.Main_rep("main_mail_contact", rep_id.ToString(), visible_sql);
        //proceso de envio de correo
        Console.WriteLine("************** SQL contactos **************");
        Console.WriteLine(util.Tdetalle(tmail_contact));
    }
    //////*******  Parametros *********////////////////////



    try { num_of_param = Convert.ToInt32(util.Tcampo(tnum_param, "NUM_OF_PARAM")); } catch (Exception) { }
    Console.WriteLine("Numero Parametros : " + num_of_param);
    util.arma_param("REP.PARAM_", num_of_param);
    Console.WriteLine("Parametros : " + util.arma_param("REP.PARAM_", num_of_param));


    tdato_repor = DM.Main_rep("main_datos_rep", rep_id.ToString(), visible_sql, util.arma_param("REP.PARAM_", num_of_param));
    Console.WriteLine("************** datos repore **************");
    Console.WriteLine(util.Tdetalle(tdato_repor));
    ///////////////////////////////////////


    //Console.WriteLine(util.Tdetalle(tdato_repor));
    /****///
    dest_mail = util.nvl(util.Tcampo(tdato_repor, "DEST_MAIL"));
    for (int i = 1; i <= num_of_param; i++)
    {
        param_string = param_string + util.nvl(util.Tcampo(tdato_repor, "PARAM_" + i));
        if (i != num_of_param) { param_string = param_string + "|"; }
    }

    reporte_name = util.nvl(util.Tcampo(tdato_repor, "NAME"));
    days_deleted = Int32.Parse(util.nvl(util.Tcampo(tdato_repor, "DAYS_DELETED"), "n"));
    file_name    = util.nvl(util.Tcampo(tdato_repor, "FILE_NAME"));
    id_Reporte   = Int32.Parse(util.nvl(util.Tcampo(tdato_repor, "ID_REP"), "n"));
    //Carpeta      = first_path & NVL(rs.Fields("CARPETA")) & "\" & IIf(NVL(rs.Fields("SUBCARPETA")) <> "", NVL(rs.Fields("SUBCARPETA")) & "\", "")
    Carpeta      = first_path + util.nvl(util.Tcampo(tdato_repor, "CARPETA"));
    if (util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA")) != "")
        Carpeta = Carpeta + util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA")) + "\\";
    else
        Carpeta = Carpeta + "";
    MiComando = util.nvl(util.Tcampo(tdato_repor, "COMMAND"));

    Console.WriteLine("valor ''dest_mail   '':" + dest_mail);
    Console.WriteLine("valor ''param_string'':" + param_string);
    Console.WriteLine("valor ''reporte_name'':" + reporte_name);
    Console.WriteLine("valor ''days_deleted'':" + days_deleted);
    Console.WriteLine("valor ''file_name   '':" + file_name);
    Console.WriteLine("valor ''id_Reporte  '':" + id_Reporte);
    Console.WriteLine("valor ''Carpeta     '':" + Carpeta);
    Console.WriteLine("valor ''COMMAND     '' " + MiComando);
    Console.WriteLine("valor ''Get_IP      '' " + Get_IP);
    Console.WriteLine("valor ''first_path  '' " + first_path);
    Console.WriteLine("valor ''second_path '' " + second_path);
    //servidor = "http://" & Trim(Split(Get_IP(), "-")(0))
    servidor = "http://" + Get_IP;
    Console.WriteLine("valor servidor:" + servidor);
    Carpeta = "C:\\Users\\usuario\\Desktop\\Raul\\prueba1";
    if (!Directory.Exists(Carpeta))
    {
        Directory.CreateDirectory(Carpeta);
        Console.WriteLine("carpeta creada :" + Carpeta);
    }
    else Console.WriteLine("La carpeta existe.."+Carpeta);

}
else
    Console.WriteLine("Error es necesario dos parametros \n 1. Falta numero repor: ''{0}'' \n 2. valor numerico: {1} " + msg, rep_id, reporte_temporal);
Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();

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
    mail_grupo_error = "desarrollo_web@logis.com.mx;christelle@logis.com.mx;desarrollo_web@logis.com.mx;desarrollo_web@logis.com.mx;";
    //carpeta = "E:\reportes\web_reports\"
    //second_path = "E:\reportes\web_reports\distant\"
    IP_servidor1 = "192.168.100.5";
    IP_servidor2 = "192.168.100.4";
    first_path = "\\\\" + IP_servidor1 + "\\reportes\\web_reports\\";
    second_path = "\\\\" + IP_servidor2 + "\\reportes\\web_reports\\";
    Get_IP = util.Get_IP();
    first_path = "\\\\" + Get_IP + "\\reportes\\web_reports\\";

    if (Get_IP == IP_servidor1)
        second_path = "\\\\" + IP_servidor2 + "\\reportes\\web_reports\\";
    else
        second_path = "\\\\" + IP_servidor1 + "\\reportes\\web_reports\\";

    mail_Lots_Info = "";
    mail_adjuntarArchivoXLS = false;
    mail_adjuntarArchivoTXT = false;
    mail_tempFolder = "\\\\192.168.100.4\\reportes\\web_reports\\temp\\";
    bExit = false;
    string Errror = "0";
}
void Errman(Exception e)
{

}
