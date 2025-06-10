using System.Data;

namespace serverreports
{
    internal class web_talones_seguros_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) web_talones_seguros(string Carpeta, string[,] file_name, string[,] pargral, string fecha_ini, string fecha_fin)
        {

            DM DM = new DM();
            Excel xlsx = new Excel();
            Utilerias util = new Utilerias();
            DataSet ds = new DataSet();
            DataTable dt = new DataTable();

            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string arch = file_name[0, 0];
            string[,] par_st;
            bool procExito = false;

            par_st = new string[5, 4];

            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_FECHA_INICIO";
            par_st[0, 3] = fecha_ini;

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_FECHA_FINAL";
            par_st[1, 3] = fecha_fin;

            par_st[2, 0] = "o";
            par_st[2, 1] = "c";
            par_st[2, 2] = "p_CurFTL_CON_IMPORTE";

            par_st[3, 0] = "o";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_MENSAJE";
            par_st[3, 3] = "msg";

            par_st[4, 0] = "o";
            par_st[4, 1] = "i";
            par_st[4, 2] = "p_CODIGO_ERROR";
            par_st[4, 3] = "cod";

            try
            {
                datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_TALONES_CON_SEGURO.P_DAT_FTL_CON_IMPORTE";
                datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                if (datos_sp.codigo == "1")
                {
                    dt = datos_sp.tb.Copy();
                    dt.TableName = "FTL con importe";
                    ds.Tables.Add(dt);

                    datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_TALONES_CON_SEGURO.P_DAT_TALON_CON_SEGURO";
                    par_st[2, 2] = "p_CurTALON_CON_SEGURO";
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                    if (datos_sp.codigo == "1")
                    {
                        dt = datos_sp.tb.Copy();
                        dt.TableName = "Talones con seguro";

                        ds.Tables.Add(dt);
                        procExito = true;
                    }
                }

                arch = procExito ? xlsx.CreateExcel_file(ds, null, arch + ".xlsx", Carpeta) : arch;

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                inf.arch = arch;
                inf.LisDT = null;
                inf.LisDT_tit = null;
            }

            return inf;
        }
    }
}
