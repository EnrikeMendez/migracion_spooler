// See https://aka.ms/new-console-template for more information
using System.Data;
using System.Linq.Expressions;
using Oracle.ManagedDataAccess.Client;
using serverreports;
int id_cron = 0;
int reporte_temporal = 0;
string SQL = " select rep.id_rep, rep.ID_CRON, rep.NAME, rep.CONFIRMACION, rep.FRECUENCIA,     \n " +
            " rep.cliente, cli.clistatus, cli.cliclef || ' - ' || InitCap(cli.clinom) cli_nom  \n " +
            " from rep_detalle_reporte rep join eclient cli on cli.cliclef= rep.CLIENTE        \n " +
            " Where rep.ID_CRON =  '@id_cron' ";
DM dM = new DM();
OracleConnection cnn = new DM().bd();
string comand = args[0];
try { id_cron = Convert.ToInt32(args[0]); } catch (Exception) { }
if (args.Length == 2 && args[1] == "1")
    reporte_temporal = 1;
if ((args.Length > 1) && (id_cron != 0))
{
    Console.WriteLine("****************************");
    Console.WriteLine("*   Spooler                 *");
    Console.WriteLine("****************************");
    Console.WriteLine("ID_CRON =" + id_cron);
    Console.WriteLine("reporte_temporal =" + reporte_temporal);
    Console.WriteLine("****************************");
    Console.WriteLine(SQL);
    using (cnn)
    {
        cnn.Open();
        OracleDataReader reader = dM.datos(SQL.Replace("@id_cron", "" + id_cron + ""), cnn);
        int i = 0;
        while (reader.Read())
        {
            if (i == 0)
            {
                Console.WriteLine("{0}\t {1} \t{2}", reader.GetName(0), reader.GetName(1), reader.GetName(2));
                Console.WriteLine("****************************");
            }
            Console.WriteLine("{0}\t {1} \t{2}", reader.GetInt32(0), reader.GetString(1), reader.GetString(2));
            i++;
        }
        Console.WriteLine("****************************");
        cnn.Close();
    }

}
else
    Console.WriteLine("Error es necesario dos parametros \n 1. Falta numero repor: ''{0}'' \n 2. valor numerico: {1} ", id_cron, reporte_temporal);
Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();
