// See https://aka.ms/new-console-template for more information
using System.Data;
using System.Linq.Expressions;
using serverreports;
int id_cron = 0;
string msg = "";
int reporte_temporal = 0;
Utilerias util=new Utilerias();
DM dM = new DM();
string comand = args[0];
try { id_cron = Convert.ToInt32(args[0]); } catch (Exception) {  msg = " ¡¡¡error opc de reporte¡¡"; }
if (args.Length == 2 && args[1] == "1")
    reporte_temporal = 1;
if (id_cron != 0)
{
    Console.WriteLine("****************************");
    Console.WriteLine("*   Spooler                 *");
    Console.WriteLine("****************************");
    Console.WriteLine("ID_CRON =" + id_cron);
    Console.WriteLine("reporte_temporal =" + reporte_temporal);
    DataTable trep_cron = new DataTable();
    trep_cron = dM.main_rp_cron(id_cron.ToString(),0);
  
     if (trep_cron.Rows.Count>0)
        Console.WriteLine(util.Tdetalle(trep_cron));
    else
        Console.WriteLine("Falta el numero del reporte.....");
}
else
        Console.WriteLine("Error es necesario dos parametros \n 1. Falta numero repor: ''{0}'' \n 2. valor numerico: {1} "+ msg, id_cron, reporte_temporal);
Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();
