using System.Data;

namespace serverreports
{
    internal class Bosch_pedimentos3_xls_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) Bosch_Pedimentos3_xls
                   (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Cliente, string imp_exp, string folios, string mi_sgeclave, string[,] parins, int visible_sql)
        {
            DataTable[] LisDT = new DataTable[1];
            string[,] LisDT_tit = new string[1, 2]; ;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string[,] par_st = new string[9, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_CLIENTE";
            par_st[0, 3] = Cliente;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_IMP_EXP";
            par_st[1, 3] = imp_exp;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_Fecha_Inicio";
            par_st[1, 3] = Fecha_1;

            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = "";
            return inf;
        }
    }

}
