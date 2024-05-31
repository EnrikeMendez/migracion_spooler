using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace serverreports
{
    internal class web_transmision_edocs_bosch
    {
        public string transmision_edocs_bosch(string Carpeta, string Archivo, string Clientes, string Fecha_1, string Fecha_2, string imp_exp, string tipo_doc)
        {
            DataTable[] LisDT;
            string[] LisDT_tit;
            LisDT = new DataTable[2];
            LisDT_tit = new string[2];

            string[,] tab_impexp;
            Utilerias util = new Utilerias();
            DM DM = new DM();
            if (imp_exp.Trim() == "1" || imp_exp.Trim() == "2")
            {
                tab_impexp = new string[2, 0];
                tab_impexp[0, 0] = imp_exp.Trim();
                tab_impexp[1, 0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                tab_impexp[2, 0] = util.iff(imp_exp, "=", "1", "_imp", "_exp");

            }
            else
            {
                tab_impexp = new string[3, 2];
                tab_impexp[0, 0] = "1";
                tab_impexp[1, 0] = "Importación";
                tab_impexp[2, 0] = "_imp";
                tab_impexp[0, 1] = "2";
                tab_impexp[1, 1] = "Exportación";
                tab_impexp[2, 1] = "_exp";
            }

            if (tab_impexp[0, 0] != "")
            {
                Console.WriteLine(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, "1"));
    
            }
            return "0";

        }

    }
}
