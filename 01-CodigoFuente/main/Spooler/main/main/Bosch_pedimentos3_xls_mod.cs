using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace serverreports
{
    internal class Bosch_pedimentos3_xls_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) Bosch_Pedimentos3_xls
                   (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Cliente, string imp_exp, string folios, string mi_sgeclave, string[,] parins, int visible_sql)
        {
            string[,] LisDT_tit = new string[2, 2]; ;
            DataTable[] LisDT = new DataTable[2];
            string arh = "";
            /*
            Console.WriteLine("1 " + Carpeta);
            Console.WriteLine("2 " + file_name[0,0]);
            Console.WriteLine("3 " + Fecha_1);
            Console.WriteLine("4 " + Fecha_2);
            Console.WriteLine("5 " + Cliente);  
            */
            return (LisDT_tit, LisDT, arh);
        }
    }

}
