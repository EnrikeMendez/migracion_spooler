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
namespace serverreports;

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
    public DataTable Main_rep(string nom_proc, string id_cron, int vs, string? addsq = "")
    {
        DataTable dtTemp = new DataTable();
        switch (nom_proc)
        {
            case "main_rp_cron":
                dtTemp = datos(main_rp_cron(id_cron.ToString(), vs, addsq));
                break;
            case "main_mail_contact":
                dtTemp = datos(main_mail_contact(id_cron.ToString(), vs));
                break;
        }
        return dtTemp;
    }

    public string /*DataTable*/ main_rp_cron(string id_cron, int vs, string? addsq = "")
    {
        string SQL = " select rep.id_rep, rep.ID_CRON, rep.NAME, rep.CONFIRMACION, rep.FRECUENCIA,\n " +
                     " rep.cliente, cli.clistatus, cli.cliclef || ' - ' || InitCap(cli.clinom) cli_nom  @sqladd            \n " +
                     " , to_char(LAST_CONF_DATE_1, 'mm/dd/yyyy')  as fecha_1, to_char(LAST_CONF_DATE_2, 'mm/dd/yyyy') as fecha_2      \n " +
                     " from rep_detalle_reporte rep inner join eclient cli on cli.cliclef= rep.CLIENTE   \n " +
                     " Where rep.ID_CRON =  {0} ";
        //DataTable dtTemp = new DataTable();
        //SQL = SQL.Replace("@id_cron", "" + id_cron + "");
        SQL = string.Format(SQL, id_cron);
        if (vs == 1) { Console.WriteLine(SQL.Replace("@sqladd", "" + addsq + "") + "\n"); }
        //dtTemp = datos(SQL.Replace("@id_cron", "" + id_cron + ""));
        return SQL.Replace("@sqladd", "" + addsq + "");
        /*return dtTemp*/
    }

    public string main_mail_contact(string id_cron, int vs)
    {
        string SQL = " SELECT REP.NAME, DEST.NOMBRE, DEST.MAIL \n" +
        "  FROM REP_DETALLE_REPORTE REP \n" +
        "  inner join  REP_DEST_MAIL DEST_M on REP.MAIL_ERROR = DEST_M.ID_DEST_MAIL \n" +
        "  inner join  REP_MAIL DEST   on DEST_M.ID_DEST = DEST.ID_MAIL \n" +
        "  WHERE status = 1 \n" +
        "  AND REP.ID_CRON = {0}";
        if (vs == 1) { Console.WriteLine(string.Format(SQL, id_cron) + "\n"); }
        return string.Format(SQL, id_cron);
    }



}

