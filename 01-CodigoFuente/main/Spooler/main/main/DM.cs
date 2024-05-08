using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Reflection.PortableExecutable;
using System.Linq.Expressions;
using System.Data.OracleClient;
using Microsoft.Extensions.Configuration;
using System.Reflection;
namespace serverreports
{
    internal class DM
    {
        public DataTable datos(string SQL)
        {
            DataTable dtTemp = new DataTable();
            OracleConnection cnn = new OracleConnection(conecBD());
            using (cnn)
            {
                cnn.Open();
                if ((cnn.State) > 0)
                {
                    OracleCommand cmd = new OracleCommand(SQL, cnn);
                    OracleDataAdapter da = new OracleDataAdapter(cmd);
                    //da = new OracleDataAdapter(cmd);
                    da.Fill(dtTemp);
                    cnn.Close();
                }
            }
            return dtTemp;
        }
        private string conecBD()
        {
            var configuration = new ConfigurationBuilder()
                                              .AddUserSecrets(Assembly.GetExecutingAssembly())
                                              .Build();
            var orfeo = configuration["Orfeo2"];
            return orfeo;
        }
        public DataTable Main_rep(string nom_proc, string id_cron, int vs)
        {
           DataTable dtTemp = new DataTable();
           switch (nom_proc)
            {
                case "main_rp_cron":                         
                                    break;
            }
            return dtTemp;
        }

        public  DataTable main_rp_cron(string id_cron, int vs)
        {
            string SQL = " select rep.id_rep, rep.ID_CRON, rep.NAME, rep.CONFIRMACION, rep.FRECUENCIA,     \n " +
            " rep.cliente, cli.clistatus, cli.cliclef || ' - ' || InitCap(cli.clinom) cli_nom              \n " +
            " from rep_detalle_reporte rep join eclient cli on cli.cliclef= rep.CLIENTE                    \n " +
            " Where rep.ID_CRON =  @id_cron ";
            DataTable dtTemp = new DataTable();
            dtTemp = datos(SQL.Replace("@id_cron", "" + id_cron + ""));
            return dtTemp;
        }
               




    }
}

