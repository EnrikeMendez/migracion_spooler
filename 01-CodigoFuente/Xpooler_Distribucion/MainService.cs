using System.Reflection;
using Oracle.ManagedDataAccess.Client;
using System.Data;

namespace Xpooler_Distribucion
{
    public sealed class MainService
    {
        //private readonly ILogger<ServiceWorker> _logger;

        public string GetConfigValue(string section)
        {
            var configuration = new ConfigurationBuilder().AddJsonFile(Assembly.GetExecutingAssembly().Location.Replace("Xpooler_Distribucion.dll", "appsettings.json")).Build();

            return configuration.GetSection("Config").GetSection(section).Value ?? string.Empty;
        }
        public string GetProcess()
        {
            string processTOexecute = string.Empty;
            /*
            Process process = _processes.ElementAt(
                Random.Shared.Next(_processes.Count));

            //return $"{process.IdCron}{Environment.NewLine}{process.RepName}";
            return $"{process.IdCron} {process.RepName}";
            */

            processTOexecute = ReturnProcess().ToString();
            return processTOexecute;
        }
        private string ReturnProcess()
        {
            string sql = string.Empty;
            string dbConfig = string.Empty;
            string run_process = string.Empty;
            DataTable? dt = null;
            OracleCommand? command = null;
            OracleDataAdapter? adapter = null;
            OracleConnection? connection = null;

            try
            {
                /*
                sql = string.Format("select rdr.ID_CRON IdCron, rdr.ID_REP IdRep, rdr.name NombreRep from rep_detalle_reporte rdr where trunc(rdr.date_created) >= trunc(sysdate-30)");
                dbConfig = GetConfigValue("DB_DIST");
                connection = new OracleConnection(dbConfig);
                connection.Open();
                command = new OracleCommand(sql, connection);
                adapter = new OracleDataAdapter(command);
                dt = new DataTable();
                adapter.Fill(dt);
                connection.Close();
                */

                //dt = GetProcessOnDemand();
                dt = GetAllProcess();

                if (dt != null)
                {
                    if (dt.Rows.Count > 0)
                    {
                        run_process = string.Format("{0} - {1} {2}", dt.Rows[0][0], dt.Rows[0][1], dt.Rows[0][2]);
                    }
                }
            }
            catch (Exception ex)
            {
                //_logger.LogError(ex.ToString(), ex);
                LOG.RegistraExcepcion(ex);
            }
            finally
            {
                if (adapter != null)
                {
                    adapter.Dispose();
                    GC.SuppressFinalize(adapter);
                }
                if (command != null)
                {
                    command.Dispose();
                    GC.SuppressFinalize(command);
                }
                if (connection != null)
                {
                    connection.Dispose();
                    GC.SuppressFinalize(connection);
                }
            }

            /*
             return _processes.First().IdCron + " " + _processes.First().RepName;
            */

            return run_process;
        }

        private readonly HashSet<Process> _processes = new()
        {
            new Process("¿Qué es lo mejor de una función booleana?", "Incluso si estás equivocado, sólo estás equivocado por un bit."),
            new Process("¿Cuál es la manera Orientada a Objetos que te vuelve millonario?", "La Herencia."),
            new Process("¿Por qué el programador dejó su trabajo?", "Porque no se obtuvo ningún arreglo."),
            new Process("¿Cuántos programadores se necesitan para cambiar una bombilla?", "Ninguno, es un problema de hardware."),
            new Process("Si pones un millón de monos frente a un millón de teclados, uno de ellos eventualmente escribirá un programa Java.", "El resto de ellos escribirán Pearl."),
            new Process("['hip', 'hip']", "(es un arreglo tipo hip)."),
            new Process("Para entender qué es la recursividad...", "...primero debes saber qué es recursividad."),
            new Process("Hay 10 tipos de personas en este mundo...", "... los que entienden el binario y los que no."),
            new Process("¿Qué canción cantaría una excepción?", "*Can't catch me* de Avicii"),
            new Process("¿Cómo comprobar si una página web es HTML5?", "Pruébala en Internet Explorer."),
            new Process("Una interfaz de usuario es como un chiste...", "... si tienes que explicarlo entonces no es bueno."),
            new Process("Iba a contarte un chiste sobre UDP...", "...pero puede que no lo entiendas."),
            new Process("A menudo, el chiste llega antes que el planteamiento.", "¿Conoces el problema con los chistes sobre UDP?"),
            new Process("¿Por qué los desarrolladores de C# y Java siguen rompiendo sus teclados?", "Porque utilizan un lenguaje fuertemente tipado."),
            new Process("Knock-knock.", "Una condición de carrera. ¿Quién está ahí?"),
            new Process("¿Qué es lo mejor de los chistes de TCP?", "Puedo seguir diciéndoselos hasta que los consigas."),
            new Process("Un programador pone dos vasos en su mesita de noche antes de irse a dormir...", "... uno lleno por si tienen sed, y otro vacío por si no."),
            new Process("Hay 10 tipos de personas en este mundo...", "... los que entienden el binario, los que no y los que no esperaban un chiste sobre base 3."),
            new Process("Tres sentencias SQL entran en un Bar NoSQL y rápidamente salen ...", "... porque no encontraron un Table.")


        };

        private DataTable GetProcessOnDemand()
        {
            string process = string.Empty;
            string sql = string.Empty;
            string dbConfig = string.Empty;
            DataTable dt = new DataTable();
            OracleCommand? command = null;
            OracleDataAdapter? adapter = null;
            OracleConnection? connection = null;

            sql = string.Format("{0}SELECT  RDR.ID_CRON \"IdCron\", \n", sql);
            sql = string.Format("{0}        RDR.ID_REP \"IdRep\", \n", sql);
            sql = string.Format("{0}        RDR.NAME \"NombreReporte\", \n", sql);
            sql = string.Format("{0}        TO_CHAR(NVL(rdr.date_modified,rdr.date_created),'DD/MM/YYYY HH24:MI:SS') \"Fecha\" \n", sql);
            sql = string.Format("{0}FROM REP_DETALLE_REPORTE RDR \n", sql);
            sql = string.Format("{0}    INNER JOIN REP_CHRON RC ON RDR.ID_CRON = RC.ID_RAPPORT \n", sql);
            sql = string.Format("{0}WHERE   NVL(RC.IN_PROGRESS,0) = 0 \n", sql);
            sql = string.Format("{0}    AND RC.ACTIVE = 1 \n", sql);
            sql = string.Format("{0}    AND RC.MINUTES IS NULL \n", sql);
            sql = string.Format("{0}    AND RC.HEURES IS NULL \n", sql);
            sql = string.Format("{0}    AND RC.JOURS IS NULL \n", sql);
            sql = string.Format("{0}    AND RC.MOIS IS NULL \n", sql);
            sql = string.Format("{0}    AND RC.JOUR_SEMAINE IS NULL \n", sql);
            sql = string.Format("{0}    AND TRUNC(NVL(RDR.DATE_MODIFIED,RDR.DATE_CREATED)) >= TRUNC(SYSDATE-1) \n", sql);
            sql = string.Format("{0}ORDER BY RC.PRIORITE ASC, RDR.ID_CRON DESC \n", sql);

            dbConfig = GetConfigValue("DB_DIST");
            connection = new OracleConnection(dbConfig);
            connection.Open();
            command = new OracleCommand(sql, connection);
            adapter = new OracleDataAdapter(command);
            dt = new DataTable();
            adapter.Fill(dt);
            connection.Close();
            /*
            if (dt != null)
            {
                if (dt.Rows.Count > 0)
                {
                    process = string.Format("{0} - {1} {2}", dt.Rows[0][0], dt.Rows[0][1], dt.Rows[0][2]);
                }
            }
            */

            return dt;
        }
        private string GetProcessProgramm()
        {
            string process = string.Empty;



            return process;
        }

        private DataTable GetAllProcess()
        {
            OracleCommand? command = null;
            string dbConfig = string.Empty;
            DataTable dt = new DataTable();
            OracleDataAdapter? adapter = null;
            OracleConnection? connection = null;

            try
            {
                dbConfig = GetConfigValue("DB_DIST");
                connection = new OracleConnection(dbConfig);

                connection.Open();
                command = new OracleCommand();
                command.Connection = connection;
                command.CommandType=CommandType.StoredProcedure;
                command.CommandText = "SC_RS_DIST.SPG_REP_REPORTES.P_DAT_PROCESOS_XPOOLER";
                
                command.Parameters.Clear();
                command.Parameters.Add("p_Cur_Procesos_XP", OracleDbType.RefCursor, ParameterDirection.Output);
                /*command.Parameters.Add("p_Mensaje", OracleDbType.NVarchar2, 4000, ParameterDirection.Output);*/
                command.Parameters.Add("p_Mensaje", OracleDbType.NVarchar2, 4000, null, ParameterDirection.Output);
                command.Parameters.Add("p_Codigo_Error", OracleDbType.Int64, ParameterDirection.Output);
                
                adapter = new OracleDataAdapter(command);
                adapter.Fill(dt);
            }
            catch (Exception ex)
            {
                ex.Source = string.Format("SC_RS_DIST.SPG_REP_REPORTES.P_DAT_PROCESOS_XPOOLER \n {0}", ex.Source);
                //_logger.LogError(ex.ToString(), ex);
                LOG.RegistraExcepcion(ex);
            }
            finally
            {
                if(dbConfig!=null)
                {
                    dbConfig = string.Empty;
                    GC.SuppressFinalize(dbConfig);
                }
                if(adapter!=null)
                {
                    adapter.Dispose();
                    GC.SuppressFinalize (adapter);
                }
                if(command!=null)
                {
                    command.Dispose();
                    GC.SuppressFinalize(command);
                }
                if(connection!=null)
                {
                    if(connection.State == ConnectionState.Open)
                    {
                        connection.Close();
                    }
                    connection.Dispose();
                    GC.SuppressFinalize(connection);
                }
                GC.Collect();
            }

            return dt;
        }
    }

    readonly record struct Process(string IdCron, string RepName);
}