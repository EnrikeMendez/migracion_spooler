using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace serverreports
{
    internal class web_talones_envios_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) talones_envios(string Carpeta, string[,] file_name, string cliente, string fecha_1, string fecha_2, string tipo_fecha, string[,] pargral, int vs)
        {
            DM obj_dm = new DM();
            Utilerias obj_utilerias = new Utilerias();
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            string[,] par_st = new string[8, 4];

            DataTable dt = null;
            DataSet ds = null;
            Excel xls = new Excel();
            string arch = file_name[0, 0];
            DataTable[] LisDT = new DataTable[1];
            string[,] LisDT_tit = new string[1, 2];
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;


            try
            {
                par_st[0, 0] = "i";
                par_st[0, 1] = "v";
                par_st[0, 2] = "p_Num_Cliente";
                par_st[0, 3] = cliente;

                par_st[1, 0] = "i";
                par_st[1, 1] = "v";
                par_st[1, 2] = "P_Tipo_fecha";
                par_st[1, 3] = tipo_fecha;

                par_st[2, 0] = "i";
                par_st[2, 1] = "v";
                par_st[2, 2] = "p_Lista_Nuis";
                par_st[2, 3] = null;

                par_st[3, 0] = "i";
                par_st[3, 1] = "v";
                par_st[3, 2] = "p_Fecha_Inicio";
                par_st[3, 3] = fecha_1;

                par_st[4, 0] = "i";
                par_st[4, 1] = "v";
                par_st[4, 2] = "p_Fecha_Fin";
                par_st[4, 3] = fecha_2;

                par_st[5, 0] = "o";
                par_st[5, 1] = "c";
                par_st[5, 2] = "p_Cur_Talones_Envios";
                par_st[5, 3] = null;

                par_st[6, 0] = "o";
                par_st[6, 1] = "v";
                par_st[6, 2] = "p_Mensaje";
                par_st[6, 3] = "msg";

                par_st[7, 0] = "o";
                par_st[7, 1] = "i";
                par_st[7, 2] = "p_Codigo_Error";
                par_st[7, 3] = "cod";

                datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_TALONES_ENVIOS.P_DAT_TALONES_ENVIOS";
                datos_sp = obj_dm.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), vs);

                if (datos_sp.codigo == "1")
                {
                    dt = datos_sp.tb.Copy();

                    dt.TableName = "Talones Envios";
                    LisDT[0] = dt;

                    ds = new DataSet(arch);
                    ds.Tables.Add(LisDT[0]);

                    arch = xls.CreateExcel_file(ds, null, arch, Carpeta);
                }
            }
            catch { }
            finally
            {
                inf.arch = arch;
                inf.LisDT = LisDT;
                inf.LisDT_tit = LisDT_tit;
            }

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

            return inf;
        }
    }
}
