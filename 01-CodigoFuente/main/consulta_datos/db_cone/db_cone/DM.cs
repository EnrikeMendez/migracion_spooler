using Microsoft.Extensions.Configuration;
using System;
using System.Collections.Generic;
using System.Data.OracleClient;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace db_cone
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
                case "main_num_param":
                    dtTemp = datos(main_num_param(id_cron.ToString(), vs));
                    break;
                case "main_datos_rep":
                    dtTemp = datos(main_datos_rep(id_cron.ToString(), vs, addsq));
                    break;
            }
            return dtTemp;
        }

        public string /*DataTable*/ main_rp_cron(string id_cron, int vs, string? addsq = "")
        {
            string SQL = " select rep.id_rep, rep.ID_CRON, rep.NAME, rep.CONFIRMACION, rep.FRECUENCIA,\n " +
                         " rep.cliente, cli.clistatus, cli.cliclef || ' - ' || InitCap(cli.clinom) cli_nom  @sqladd  \n " +
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

        public string main_num_param(string id_cron, int vs)
        {
            string SQL = " SELECT REPORT.NUM_OF_PARAM  \n "
                         + " FROM REP_REPORTE REPORT inner join REP_DETALLE_REPORTE REP on REPORT.ID_REP = REP.ID_REP \n "
                         + " WHERE REP.ID_CRON = {0}";
            /*
            string SQL1 = " update rep_chron set in_progress=0  \n "
                          + " where id_rapport= @id_cron ";
            */
            if (vs == 1) { Console.WriteLine(string.Format(SQL, id_cron) + "\n"); }
            return string.Format(SQL, id_cron);
        }

        public string main_datos_rep(string id_cron, int vs, string? addsq = "")
        {
            string SQL = " SELECT REP.NAME, REP.CLIENTE \n"
                        + " , REP.FILE_NAME, REP.CARPETA \n"
                         + " , CLI.CLINOM \n"
                         + " , mail.NOMBRE, mail.MAIL \n"
                         + " , REPORT.COMMAND \n"
                         + " , REP.DAYS_DELETED \n"
                         + " , REPORT.NUM_OF_PARAM \n"
                         + " , REP.DEST_MAIL, to_char(REP.LAST_CONF_DATE_1, 'mm/dd/yyyy') LAST_CONF_DATE_1, to_char(REP.LAST_CONF_DATE_2, 'mm/dd/yyyy') LAST_CONF_DATE_2 \n"
                         + "    @sqladd \n"
                         + "  , mail.client_num \n"
                         + "  , REPORT.ID_REP, REPORT.SUBCARPETA \n"
                         + "  , REP.CREATED_BY \n"
                         + "  ,TERCERO \n"
                         + "  FROM REP_DETALLE_REPORTE REP \n"
                         + "  , ECLIENT CLI \n"
                         + "  , REP_DEST_MAIL DEST \n"
                         + "  , REP_MAIL MAIL \n"
                         + "  , REP_REPORTE REPORT \n"
                         + "  WHERE REP.CLIENTE = CLI.CLICLEF(+) \n"
                         + "  AND REP.ID_CRON ={0} \n"
                         + "  AND mail.ID_MAIL(+) = DEST.ID_DEST \n"
                         + "  AND DEST.ID_DEST_MAIL(+) = REP.MAIL_OK \n"
                         + "  AND REPORT.ID_REP = REP.ID_REP \n"
                         + "  AND NVL(mail.status, 1) = 1  \n"
                         + "Union All \n"
                         + "SELECT REP.NAME, REP.CLIENTE \n"
                         + "  , REP.FILE_NAME, REP.CARPETA \n"
                         + "  , CLI.CLINOM  \n"
                         + "  , mail.NOMBRE, mail.MAIL \n"
                         + "  , REPORT.COMMAND \n"
                         + "  , REP.DAYS_DELETED \n"
                         + "  , REPORT.NUM_OF_PARAM \n"
                         + "  , REP.DEST_MAIL, to_char(REP.LAST_CONF_DATE_1, 'mm/dd/yyyy') LAST_CONF_DATE_1, to_char(REP.LAST_CONF_DATE_2, 'mm/dd/yyyy') LAST_CONF_DATE_2 \n"
                         + "    @sqladd \n"
                         + " , mail.client_num \n"
                         + " , REPORT.ID_REP, REPORT.SUBCARPETA \n"
                         + " , REP.CREATED_BY \n"
                         + " ,TERCERO \n"
                         + " FROM REP_DETALLE_REPORTE REP \n"
                         + " , ECLIENT CLI \n"
                         + " , REP_DEST_MAIL DEST \n"
                         + " , REP_MAIL MAIL \n"
                         + " , REP_REPORTE REPORT \n"
                         + " WHERE REP.CLIENTE = CLI.CLICLEF(+) \n"
                         + " AND REP.ID_CRON ={0} \n"
                         + " AND  DEST.id_dest_mail=2888 \n"
                         + " AND mail.ID_MAIL(+) = DEST.ID_DEST \n"
                         + " AND REPORT.ID_REP = REP.ID_REP \n"
                         + " AND NVL(mail.status, 1) = 1  \n"
                         + " and REP.MAIL_OK is not null \n"
                         + " and not exists(  SELECT null FROM REP_DEST_MAIL DESTD, REP_MAIL MAILD \n"
                         + " Where DESTD.id_dest_mail = REP.MAIL_OK  \n"
                         + " AND maild.ID_MAIL = DESTD.ID_DEST \n"
                         + " AND maild.status = 1 ) \n"
                         + " order by CLIENT_NUM, TERCERO desc , NOMBRE ";
            //DataTable dtTemp = new DataTable();
            SQL = string.Format(SQL, id_cron);
            if (vs == 1) { Console.WriteLine(SQL.Replace("@sqladd", "" + addsq + "") + "\n"); }
            //dtTemp = datos(SQL.Replace("@id_cron", "" + id_cron + ""));
            return SQL.Replace("@sqladd", "" + addsq + "");
            /*return dtTemp*/
        }

    }
}
