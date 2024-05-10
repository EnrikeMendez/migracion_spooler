// See https://aka.ms/new-console-template for more information
using System.Data;
using System.Linq.Expressions;
using System.Security.Cryptography;
using serverreports;
int id_cron = 0;
int sw_cron = 0;
int num_of_param = 0;
int visible_sql = 0;
string msg = "";
string sqladd = " ,case when @param=1 then logis.display_fecha_confirmacion4(rep.FRECUENCIA, sysdate, sysdate,1)  end fecha  ";
int reporte_temporal = 0;
string FECHA_1 = "";
string FECHA_2 = "";
Utilerias util=new Utilerias();
DM DM = new DM();
string comand = args[0];
try { id_cron = Convert.ToInt32(args[0]); } catch (Exception) {  msg = " ¡¡¡error opc de reporte¡¡"; }
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
    //////*******  Parametros *********////////////////////
    tmail_contact = DM.Main_rep("main_mail_contact", id_cron.ToString(), visible_sql);
    Console.WriteLine("************** SQL contactos **************");
    Console.WriteLine(util.Tdetalle(tmail_contact));
   
    DataTable tnum_param = new DataTable();
    tnum_param = DM.Main_rep("main_num_param", id_cron.ToString(), visible_sql);
    num_of_param = Convert.ToInt32(util.Tcampo(tnum_param, "NUM_OF_PARAM"));
    Console.WriteLine("Numero parametros :"+ num_of_param);
    Console.WriteLine("************** parametros **************");
    Console.WriteLine(util.arma_param("REP.PARAM_", num_of_param));

    DataTable tdato_repor = new DataTable();
    tdato_repor = DM.Main_rep("main_datos_rep", id_cron.ToString(), visible_sql, util.arma_param("REP.PARAM_", num_of_param));
    Console.WriteLine("************** datos repore **************");
    Console.WriteLine(util.Tdetalle(tdato_repor));
    /****///
}
else
    Console.WriteLine("Error es necesario dos parametros \n 1. Falta numero repor: ''{0}'' \n 2. valor numerico: {1} " + msg, id_cron, reporte_temporal);
Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();