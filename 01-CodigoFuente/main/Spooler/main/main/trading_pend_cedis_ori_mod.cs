using DocumentFormat.OpenXml.Wordprocessing;
using SixLabors.Fonts;
using System.Data;
using System.Text;

namespace serverreports
{
    internal class trading_pend_cedis_ori_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) trading_fact_pend_cedis_ori(string Carpeta, string[,] file_name, string? cliente, string? cedis, string[,] pargral, int vs)
        {
            DM DM = new DM();
            Utilerias util = new Utilerias();
            DataTable dttmp = new DataTable();
            DataSet ds = new DataSet();  
            DataTable[] LisDT = new DataTable[2];
            Excel xlsx = new Excel();

            string[,] LisDT_tit = new string[2, 2];

            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            string arch = file_name[0, 0];
            string[,] par_st;

            par_st = new string[5, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_CLICLEF";
            par_st[0, 3] = cliente;

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_CEDIS_ORI";
            par_st[1, 3] = cedis;

            par_st[2, 0] = "o";
            par_st[2, 1] = "c";
            par_st[2, 2] = "p_CurEVIDENCIAS_TOTAL";

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

                datos_sp.sql = "SC_RS.SPG_RS_DIST_FACTURAS_PEND_ORI.P_DAT_EVIDENCIAS_TOTAL";
                datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), vs);


                if (datos_sp.codigo == "1")
                {
                    dttmp = datos_sp.tb.Copy();
                    dttmp.TableName = "Evidencias Total";
                    ds.Tables.Add(dttmp);

                    datos_sp.sql = "SC_RS.SPG_RS_DIST_FACTURAS_PEND_ORI.P_DAT_HASTA_ENTRE_TOTAL";
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), vs);

                    if (datos_sp.codigo == "1")
                    {
                        dttmp = datos_sp.tb.Copy();
                        dttmp.TableName = "Hasta Entrega Total";
                        dttmp.Columns["LIMITE_ENTREGA"].ColumnName = "Fecha limite Entrega (TN cliente)";
                        dttmp.Columns["Tipo Entrega1"].ColumnName = "Tipo Entrega";
                        ds.Tables.Add(dttmp);

                        arch = xlsx.CreateExcel_file_FacPend(ds, "Hasta Entrega Total", "Fecha limite Entrega (TN cliente)", "W", "COLOR_FECHA", null, Carpeta + "\\" + arch + ".xlsx");
                    }

                }

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                inf.arch = arch;
                inf.LisDT = LisDT;
                inf.LisDT_tit = LisDT_tit;
            }

            return inf;

        }



             


    }
}
