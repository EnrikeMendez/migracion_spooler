using System.Data;

namespace serverreports
{
    internal class Bosch_pedimentos2_xls_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) Bosch_Pedimentos2_xls
            (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Clientes, string Planta, string imp_exp, string[,] parins, int visible_sql)
        {
            //5071980
            DM DM = new DM();
            string[,] tab_impexp;
            DataTable[] LisDT = new DataTable[3];
            string[,] LisDT_tit = new string[3, 2]; ;
            string[] arh;
            if (file_name[4, 0] == "1")
                arh = new string[2];
            else
                arh = new string[1];
            string arch = file_name[0, 0];
            string[,] html = new string[6, 1];
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string[,] par_st = new string[7, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_CLIENTE";
            //par_st[0, 3] = Clientes;
            par_st[0, 3] = "23386";

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_IMP_EXP";
            //par_st[1, 3] = imp_exp;
            par_st[1, 3] = "1";

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Fecha_Inicio";
            //par_st[2, 3] = Fecha_1;
            par_st[2, 3] = "08/30/2023";

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Fecha_Fin";
            //par_st[3, 3] = Fecha_2;
            par_st[3, 3] = "03/19/2024";

            par_st[4, 0] = "o";
            par_st[4, 1] = "c";
            par_st[4, 2] = "p_Cur_Bosch_Pedi_rac";

            par_st[5, 0] = "o";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_MENSAJE";
            par_st[5, 3] = "msg";

            par_st[6, 0] = "o";
            par_st[6, 1] = "i";
            par_st[6, 2] = "p_CODIGO_ERROR";
            par_st[6, 3] = "cod";
            datos_sp.sql = "SC_RS.SPG_RS_COEX_PEDIMENTOS_BOSCH.P_DAT_FOLIOS_RECTIFICACION ";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(parins[13, 1]), visible_sql);
            LisDT[0] = datos_sp.tb;
            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = arch;
            return inf;
        }
    }
}
