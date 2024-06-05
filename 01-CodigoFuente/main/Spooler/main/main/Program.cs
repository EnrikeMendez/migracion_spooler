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
string sqladd = " ,case when (@param=1 and  rep.FRECUENCIA is not null) then logis.display_fecha_confirmacion4(rep.FRECUENCIA, sysdate, sysdate,1)  end fecha  ";
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

string[] tab_archivos;
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

Utilerias util = new Utilerias();
DM DM = new DM();
init_var();
DataTable trep_cron = new DataTable();
DataTable tdato_repor = new DataTable();
DataTable tnum_param = new DataTable();
DataTable tmail_contact = new DataTable();
string comand = args[0];
try { rep_id = Convert.ToInt32(args[0]); } catch (Exception) { msg = " ¡¡¡error opc de reporte¡¡"; }
if (args.Length == 2 && args[1] == "1")
    reporte_temporal = 1;

if (rep_id != 1)
{
    trep_cron = DM.Main_rep("main_rp_cron", rep_id.ToString(), visible_sql, sqladd.Replace("@param", "" + reporte_temporal + ""));



    //        util.CreadorExcel("patito.xlsx");
    //        util.CrearExcel(trep_cron, "prueba1");

    //Esto ultimo solo para verificar que todo fue bien.
    // Console.WriteLine("Se creo el archivo, presiona una tecla para terminar");
    // Console.ReadKey();


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
    if (reporte_temporal == 1)
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
    if (1 == 0)
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
    if (1 == 0)
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
        //  if conf_date !=null
        if (1 == 0)
        {
            SQL_p2 = "select display_fecha_confirmacion4(('" + util.Tcampo(trep_cron, "FRECUENCIA") + "',conf.CONF_DATE,conf.CONF_DATE_2,decode(conf.CONF_DATE,null,1,0)) as next_fecha \n" +
         " from rep_confirmacion conf \n" +
         " where  conf.ID_CONF = '" + rep_id + "' \n" +
         " order by to_date(next_fecha, 'mm/dd/yyyy') desc \n";
            //  if conf.CONF_DATE !=null
            mail_error = "agregar valor de rs2.Fields(0).Value ";
            //else
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
        tmail_contact = DM.Main_rep("main_mail_contact", rep_id.ToString(), visible_sql);
        //proceso de envio de correo
        Console.WriteLine("************** SQL contactos **************");
        Console.WriteLine(util.Tdetalle(tmail_contact));

        string tema = "Error generacion de : " + util.Tcampo(tmail_contact, "NAME");
        string contactos = util.listTcampo(tmail_contact, "mail", ";");
        contactos = contactos + mail_grupo_error[0];
        if (mail_error.Split("/").Length > 0)
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

    tnum_param = DM.Main_rep("main_num_param", rep_id.ToString(), visible_sql);


    try { num_of_param = Convert.ToInt32(util.Tcampo(tnum_param, "NUM_OF_PARAM")); } catch (Exception) { }
    Console.WriteLine("Numero Parametros : " + num_of_param);
    util.arma_param("REP.PARAM_", num_of_param);
    Console.WriteLine("Parametros : " + util.arma_param("REP.PARAM_", num_of_param));


    tdato_repor = DM.Main_rep("main_datos_rep", rep_id.ToString(), visible_sql, util.arma_param("REP.PARAM_", num_of_param));
    Console.WriteLine("************** datos repore **************");
    Console.WriteLine(util.Tdetalle(tdato_repor));
    ///////////////////////////////////////
    dest_mail = util.nvl(util.Tcampo(tdato_repor, "DEST_MAIL"));
    for (int i = 1; i <= num_of_param; i++)
    {
        param_string = param_string + util.nvl(util.Tcampo(tdato_repor, "PARAM_" + i));
        if (i != num_of_param) { param_string = param_string + "|"; }
    }
    reporte_name = util.nvl(util.Tcampo(tdato_repor, "NAME"));
    days_deleted = Int32.Parse(util.nvl(util.Tcampo(tdato_repor, "DAYS_DELETED"), "n"));
    file_name = util.nvl(util.Tcampo(tdato_repor, "FILE_NAME"));
    id_Reporte = Int32.Parse(util.nvl(util.Tcampo(tdato_repor, "ID_REP")));
    //Carpeta = first_path & NVL(rs.Fields("CARPETA")) & "\" & IIf(NVL(rs.Fields("SUBCARPETA")) <> "", NVL(rs.Fields("SUBCARPETA")) & "\", "")
    Carpeta = first_path + util.nvl(util.Tcampo(tdato_repor, "CARPETA")) + "\\" +
                      util.iff(util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA")), "<>", "", util.nvl(util.Tcampo(tdato_repor, "SUBCARPETA")) + "\\", "");
    MiComando = util.nvl(util.Tcampo(tdato_repor, "COMMAND"));

    tab_archivos = new string[5];
    tab_archivos[0] = file_name;
    tab_archivos[1] = reporte_name;
    tab_archivos[4] = "1";
    reporte_name = util.nvl(util.Tcampo(tdato_repor, "PARAM_1"));
    reporte_name = util.nvl(util.Tcampo(tdato_repor, "PARAM_2"));
    reporte_name = util.nvl(util.Tcampo(tdato_repor, "PARAM_3"));

    Console.WriteLine("valor ''dest_mail   '':" + dest_mail);
    Console.WriteLine("valor ''param_string'':" + param_string);
    Console.WriteLine("valor ''reporte_name'':" + reporte_name);
    Console.WriteLine("valor ''days_deleted'':" + days_deleted);
    Console.WriteLine("valor ''file_name   '':" + file_name);
    Console.WriteLine("valor ''id_Reporte  '':" + id_Reporte);
    Console.WriteLine("valor ''Carpeta     '':" + Carpeta);
    Console.WriteLine("valor ''COMMAND     '' " + MiComando);

    Console.WriteLine("valor ''tab_archivos 0 '':" + tab_archivos[0]);
    Console.WriteLine("valor ''tab_archivos 1 '':" + tab_archivos[1]);
    Console.WriteLine("valor ''tab_archivos 4    '' " + tab_archivos[4]);

    Console.WriteLine("valor ''PARAM_1 '':" + util.nvl(util.Tcampo(tdato_repor, "PARAM_1")));
    Console.WriteLine("valor ''PARAM_2 '':" + util.nvl(util.Tcampo(tdato_repor, "PARAM_2")));
    Console.WriteLine("valor ''PARAM_3 '': " + util.nvl(util.Tcampo(tdato_repor, "PARAM_3")));

    Console.WriteLine("valor ''FECHA_1 '':" + FECHA_1);
    Console.WriteLine("valor ''FECHA_2'':" + FECHA_2);


    Console.WriteLine("valor ''filter_file_name     '' " + util.filter_file_name(file_name, FECHA_1, FECHA_2));


    //servidor = "http://" & Trim(Split(Get_IP(), "-")(0))
    servidor = "http://" + Get_IP;
    Console.WriteLine("valor servidor:" + servidor);
    Carpeta = "C:\\Users\\usuario\\Desktop\\Raul\\prueba";

    if (!Directory.Exists(Carpeta))
    {
        Directory.CreateDirectory(Carpeta);
    }
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
    web_transmision_edocs_bosch edocs_bosch = new web_transmision_edocs_bosch();
    edocs_bosch.transmision_edocs_bosch(Carpeta, tab_archivos[0], util.nvl(util.Tcampo(tdato_repor, "PARAM_1")), FECHA_1, FECHA_2, util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), util.nvl(util.Tcampo(tdato_repor, "PARAM_3")), visible_sql);
   // Console.WriteLine(DM.transmision_edocs_bosch("18975", "04/01/2024", "04/30/2024", "", "E", "1"));


}
else
    Console.WriteLine("Error es necesario dos parametros \n 1. Falta numero repor: ''{0}'' \n 2. valor numerico: {1} " + msg, rep_id, reporte_temporal);

Console.WriteLine("Oprimar cualquier tecla para terminar");
trep_cron.Clear();
tdato_repor.Clear();
tnum_param.Clear();
tmail_contact.Clear();
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
    mail_grupo_error[0] = "desarrollo_web@logis.com.mx ;";
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
