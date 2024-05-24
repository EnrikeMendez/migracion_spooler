// See https://aka.ms/new-console-template for more information
using db_cone;
using System.Data;
int rep_id = 0;
int visible_sql = 0;
string msg = "";
string sqladd = " ,case when (@param=1 and  rep.FRECUENCIA is not null) then logis.display_fecha_confirmacion4(rep.FRECUENCIA, sysdate, sysdate,1)  end fecha  ";
int reporte_temporal = 0;
Utilerias util = new Utilerias();
DM DM = new DM();
DataTable trep_cron = new DataTable();
DataTable tdato_repor = new DataTable();
string comand = args[0];
try { rep_id = Convert.ToInt32(args[0]); } catch (Exception) { msg = " ¡¡¡error opc de reporte¡¡"; }
if (args.Length == 2 && args[1] == "1")
    reporte_temporal = 1;
trep_cron = DM.Main_rep("main_rp_cron", rep_id.ToString(), visible_sql, sqladd.Replace("@param", "" + reporte_temporal + ""));
if (rep_id != 0)
{
    trep_cron = DM.Main_rep("main_rp_cron", rep_id.ToString(), visible_sql, sqladd.Replace("@param", "" + reporte_temporal + ""));
    Console.WriteLine("ID_CRON =" + rep_id);
    Console.WriteLine("reporte_temporal =" + reporte_temporal);
    Console.WriteLine(util.Tdetalle(trep_cron));
}
else
    Console.WriteLine("Falta el numero del reporte.....");

Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();

