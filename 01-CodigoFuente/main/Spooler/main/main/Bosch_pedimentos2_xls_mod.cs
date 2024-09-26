using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace serverreports
{
    internal class Bosch_pedimentos2_xls_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) Bosch_Pedimentos2_xls 
            (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Clientes, string Planta, string imp_exp, string[,] parins, string[,] contacmail, int visible_sql)
        {
            //5071980
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();

            Excel xlsx = new Excel();
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

            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = arch;
            return inf;
        }
    }
}
