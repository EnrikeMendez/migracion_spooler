using System;
using System.Collections.Generic;
using System.ComponentModel.Design;
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
            DataTable temp;

         

            string[,] tab_impexp;
            Utilerias util = new Utilerias();
            DM DM = new DM();
            if (imp_exp.Trim() == "1" || imp_exp.Trim() == "2")
            {
                tab_impexp = new string[3, 1];
                tab_impexp[0, 0] = imp_exp.Trim();
                tab_impexp[1, 0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                tab_impexp[2, 0] = util.iff(imp_exp, "=", "1", "_imp", "_exp");             
                Console.WriteLine(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, imp_exp));
                temp=    DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, imp_exp));
                Console.WriteLine(util.Tdetalle(temp));
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
                Console.WriteLine(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, imp_exp));
                temp = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, imp_exp));
                Console.WriteLine(util.Tdetalle(temp));
                util.closedXML(temp);
                util.CrearExcel(temp);
            }

           return "0";

        }

    }
}
