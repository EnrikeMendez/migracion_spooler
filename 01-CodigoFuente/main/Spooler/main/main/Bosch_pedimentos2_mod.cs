using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace serverreports
{
    internal class Bosch_pedimentos2_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) Bosch_Pedimentos2
               (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Clientes, string Planta, string imp_exp, string[,] parins, string[,] contacmail, int visible_sql)
        {
            DataTable[] LisDT = new DataTable[3];
            string[,] LisDT_tit = new string[3, 2]; ;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = "";
            return inf;
        }
    }
}
