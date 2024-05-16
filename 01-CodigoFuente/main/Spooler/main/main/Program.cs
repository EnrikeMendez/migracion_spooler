// See https://aka.ms/new-console-template for more information
using System.Data;
using System.Linq.Expressions;
using System.Net;
using System.Security.Cryptography;
using serverreports;
using static System.Net.Mime.MediaTypeNames;
int id_cron = 0;
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

Utilerias util=new Utilerias();
DM DM = new DM();
init_var();
/*
 *Generar funsion de inicalicion de variables
 */
string comand = args[0];
//try { id_cron = Convert.ToInt32(args[0]); } catch (Exception e) {  msg = " ¡¡¡error opc de reporte¡¡"; }
try   { id_cron = Convert.ToInt32(args[0]); } catch (Exception e) { Console.WriteLine(e.Message); }

if (args.Length == 2 && args[1] == "1")
    reporte_temporal = 1;
DataTable trep_cron = new DataTable();
if (id_cron != 0){
    trep_cron = DM.Main_rep("main_rp_cron", id_cron.ToString(), visible_sql, sqladd.Replace("@param", "" + reporte_temporal + ""));
    if (trep_cron.Rows.Count > 0)
        sw_cron = 1;
}
else
    Console.WriteLine("Falta el numero del reporte.....");
if (id_cron != 0 && sw_cron == 1)
{
    Console.WriteLine("****************************");
    Console.WriteLine("*   Spooler                 *");
    Console.WriteLine("****************************");
    Console.WriteLine("ID_CRON =" + id_cron);
    Console.WriteLine("reporte_temporal =" + reporte_temporal);
    Console.WriteLine(util.Tdetalle(trep_cron));
    DataTable tnum_param = new DataTable();
    DataTable tmail_contact = new DataTable();
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
        FECHA_1 = util.Tcampo(trep_cron, "fecha");
        FECHA_2 = util.Tcampo(trep_cron, "fecha");
    }
    else
    {
        FECHA_1 = util.Tcampo(trep_cron, "fecha_1");
        FECHA_2 = util.Tcampo(trep_cron, "fecha_2");
    }
    Console.WriteLine("display_fecha_confirmacion4 :" + FECHA_1 + " :" + FECHA_2);

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

    //////*******  Parametros *********////////////////////
    tmail_contact = DM.Main_rep("main_mail_contact", id_cron.ToString(), visible_sql);
    Console.WriteLine("************** SQL contactos **************");
    Console.WriteLine(util.Tdetalle(tmail_contact));


    tnum_param = DM.Main_rep("main_num_param", id_cron.ToString(), visible_sql);
    num_of_param = Convert.ToInt32(util.Tcampo(tnum_param, "NUM_OF_PARAM"));
    Console.WriteLine("Numero parametros :" + num_of_param);
    Console.WriteLine("************** parametros **************");
    Console.WriteLine(util.arma_param("REP.PARAM_", num_of_param));

    DataTable tdato_repor = new DataTable();
    tdato_repor = DM.Main_rep("main_datos_rep", id_cron.ToString(), visible_sql, util.arma_param("REP.PARAM_", num_of_param));
    Console.WriteLine("************** datos repore **************");
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
    Console.WriteLine("valor ''Get_IP         '' " + Get_IP);
    Console.WriteLine("valor ''first_path     '' " + first_path);
    Console.WriteLine("valor ''second_path    '' " + second_path);
    /*
                 
             IPHostEntry host = Dns.GetHostEntry(Dns.GetHostName());
             foreach (IPAddress ip in host.AddressList)
             {
                 if (ip.AddressFamily.ToString() == "InterNetwork")
                 {
                     localIP = ip.ToString();
                 }
             }
             Console.WriteLine("valor IP " + localIP);
             return localIP;
     */

}
else
    Console.WriteLine("Error es necesario dos parametros \n 1. Falta numero repor: ''{0}'' \n 2. valor numerico: {1} " + msg, id_cron, reporte_temporal);
Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();

void init_var()
{
    num_of_param = 0;
    cc_mail = "";
    mail_server = "192.168.100.6";
    mail_footer = "\n" + "\n" + "\n" +
    "*********************************************************\n" +
    "This is a message automatically generated, please contact \n" +
    "web-master@logis.com.mx for any question or to unsubscribe.";
    mail_From = "web-reports@logis.com.mx";
    mail_FromName = "Logis report server";
    mail_grupo_error = "desarrollo_web@logis.com.mx;christelle@logis.com.mx;desarrollo_web@logis.com.mx;desarrollo_web@logis.com.mx;";
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
}
void Errman(Exception e)
{

}
