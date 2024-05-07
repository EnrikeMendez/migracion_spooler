// See https://aka.ms/new-console-template for more information
using System.Data;
using System.Linq.Expressions;
using serverreports;
int id_cron = 0;
string msg = "";
int reporte_temporal = 0;
string SQL = " select rep.id_rep, rep.ID_CRON, rep.NAME, rep.CONFIRMACION, rep.FRECUENCIA,     \n " +
            " rep.cliente, cli.clistatus, cli.cliclef || ' - ' || InitCap(cli.clinom) cli_nom  \n " +
            " from rep_detalle_reporte rep join eclient cli on cli.cliclef= rep.CLIENTE        \n " +
            " Where rep.ID_CRON =  @id_cron ";
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
    Console.WriteLine("****************************");
    DataTable dtTemp = new DataTable();
    dtTemp= dM.datos(SQL.Replace("@id_cron", "" + id_cron + ""));
    if  (dtTemp.Rows.Count>0)
        {
        string tit = "";
        string val = "";
        for (int j = 0; j < dtTemp.Rows.Count; j++)
        {
            for (int i = 0; i < dtTemp.Columns.Count; i++)
            {
                if (j == 0) { tit = tit + dtTemp.Columns[i].ColumnName + "\t"; }
                val = val + dtTemp.Rows[j][i].ToString() + "\t";
            }
            val = val + "\n";
        }
        Console.WriteLine(tit);
        Console.WriteLine(val);
       }
    else
        Console.WriteLine("Reporte no valido.....");
}
else
        Console.WriteLine("Error es necesario dos parametros \n 1. Falta numero repor: ''{0}'' \n 2. valor numerico: {1} "+ msg, id_cron, reporte_temporal);
Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();
