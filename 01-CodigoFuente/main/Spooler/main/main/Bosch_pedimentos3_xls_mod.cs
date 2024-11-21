using System.Data;

namespace serverreports
{
    internal class Bosch_pedimentos3_xls_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) Bosch_Pedimentos3_xls
                   (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Cliente, string imp_exp, string folios, string mi_sgeclave, string[,] pargral, int visible_sql)
        {
            DataTable[] LisDT = new DataTable[1];
            string[,] LisDT_tit = new string[1, 2]; ;
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string[,] par_st = new string[9, 4];
            DM DM = new DM();
            Utilerias util = new Utilerias();
            string arch = file_name[0, 0];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_CLIENTE";
            par_st[0, 3] = Cliente;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_IMP_EXP";
            par_st[1, 3] = imp_exp;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Fecha_Inicio";
            par_st[2, 3] = Fecha_1;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Fecha_Fin";
            par_st[3, 3] = Fecha_2;

            par_st[4, 0] = "i";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_MI_SGECLAVE";
            par_st[4, 3] = mi_sgeclave;
          
            par_st[5, 0] = "i";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_FOLIOS";
            par_st[5, 3] = folios;

            par_st[6, 0] = "o";
            par_st[6, 1] = "c";
            par_st[6, 2] = "p_Cur_Bosch_XLS";

            par_st[7, 0] = "o";
            par_st[7, 1] = "v";
            par_st[7, 2] = "p_MENSAJE";
            par_st[7, 3] = "msg";

            par_st[8, 0] = "o";
            par_st[8, 1] = "i";
            par_st[8, 2] = "p_CODIGO_ERROR";
            par_st[8, 3] = "cod";

            datos_sp.sql = " SC_RS.SPG_RS_COEX_PEDIMENTOS_BOSCH.P_DAT_IMPORT_XLS";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            LisDT[0] = datos_sp.tb;
            LisDT_tit[0, 0] = "Folios";                        
            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = "";
            inf.arch = arch;
            return inf;
        }
    }

}
