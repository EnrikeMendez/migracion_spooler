using System.Data;

namespace serverreports
{
    internal class web_conv_sin_exp_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) conv_sin_exp
                  (string Carpeta, string[,] file_name, string mi_cedis, string mi_cedis_traslado, string[,] pargral, int visible_sql, string? id_cron = "")

        {
            DM DM = new DM();
            DataSet ds = null;
            DataTable dt = null;
            Excel xls = new Excel();
            Utilerias util = new Utilerias();
            DataTable[] LisDT = new DataTable[2];
            List<string> elementos = new List<string>();

            string file = string.Empty;
            string arch = file_name[0, 0];
            string IP_ADDRESS = string.Empty;
            string[,] par_st = new string[7, 4];
            string[,] LisDT_tit = new string[1, 2];
            List<string>? campos = new List<string>();
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;

            try
            {
                if (pargral[14, 1] != "")
                {
                    IP_ADDRESS = pargral[14, 1];
                }

                par_st[0, 0] = "i";
                par_st[0, 1] = "v";
                par_st[0, 2] = "p_Fecha_Inicio";
                par_st[0, 3] = pargral[6, 1];

                par_st[1, 0] = "i";
                par_st[1, 1] = "v";
                par_st[1, 2] = "p_Fecha_Fin";
                par_st[1, 3] = pargral[7, 1];

                par_st[2, 0] = "i";
                par_st[2, 1] = "v";
                par_st[2, 2] = "p_Clve_Cedis";
                par_st[2, 3] = mi_cedis;

                par_st[3, 0] = "i";
                par_st[3, 1] = "v";
                par_st[3, 2] = "p_Clve_Cedis_Tras";
                par_st[3, 3] = mi_cedis_traslado;
                //par_st[3, 3] = "11";////////////this is just a test!

                par_st[4, 0] = "o";
                par_st[4, 1] = "c";
                par_st[4, 2] = "p_Cur_Convert_Sin_Exp";
                par_st[4, 3] = null;

                par_st[5, 0] = "o";
                par_st[5, 1] = "v";
                par_st[5, 2] = "p_Mensaje";
                par_st[5, 3] = "msg";

                par_st[6, 0] = "o";
                par_st[6, 1] = "i";
                par_st[6, 2] = "p_Codigo_Error";
                par_st[6, 3] = "cod";

                datos_sp.sql = " SC_RS.SPG_RS_DIST_CONVERT_SIN_EXP.P_DAT_CONVERT_SIN_EXP_ENC ";
                datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);


                if (datos_sp.codigo == "1")
                {
                    dt = datos_sp.tb.Copy();
                    dt.TableName = "Convertidores sin Exp";
                    LisDT[0] = dt;

                    datos_sp.sql = " SC_RS.SPG_RS_DIST_CONVERT_SIN_EXP.P_DAT_CONVERT_SIN_EXP_DET ";
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);

                    if (datos_sp.codigo == "1")
                    {
                        dt = datos_sp.tb.Copy();
                        dt.TableName = "Detalle Convertidores";
                        LisDT[1] = dt;

                        ds = new DataSet(arch);
                        ds.Tables.Add(LisDT[0]);
                        ds.Tables.Add(LisDT[1]);

                        file = file_name[0, 0].Trim().Equals(string.Empty) ? "Convertidores_sin_expedicion_" + DateTime.Now.ToString("ddMMyyyyHHmmssfff") : file_name[0, 0];
                        arch = xls.CreateExcel_file(ds, null, file);
                        Carpeta = arch.Replace(file + ".xlsx", "");
                    }
                }

                /*
                    //Ejemplo de creación de un archivo XLSX enviando el listado de encabezados:
                        xls.CreateExcel_file(ds, dsHeaders, "Convertidores_sin_expedicion_"+DateTime.Now.ToString("ddMMyyyyHHmmssfff"));
                    //Ejemplo de creación de un archivo XLSX conservando los encabezados que tenga cada DataTable:
                        xls.CreateExcel_file(ds, null, "Convertidores_sin_expedicion_"+DateTime.Now.ToString("ddMMyyyyHHmmssfff"));
                */
            }
            catch (Exception ex)
            {
            }
            finally
            {
                inf.arch = arch;
                inf.LisDT = LisDT;
                inf.LisDT_tit = LisDT_tit;

                if (dt != null)
                {
                    dt.Dispose();
                    GC.SuppressFinalize(dt);
                }
                if (ds != null)
                {
                    ds.Dispose();
                    GC.SuppressFinalize(ds);
                }
            }

            return inf;
        }
    }
}