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
        public string transmision_edocs_bosch(string Carpeta, string Archivo, string Clientes, string Fecha_1, string Fecha_2, string imp_exp, string tipo_doc,int visible_sql)
        {
            DataTable temp;
            DataTable[] LisDT;
            string[] LisDT_tit;
            string[,] tab_impexp;
            Utilerias util = new Utilerias();
            DM DM = new DM();
            Excel xlsx = new Excel();
            if (imp_exp.Trim() == "1" || imp_exp.Trim() == "2")
            {
                LisDT = new DataTable[1];
                LisDT_tit = new string[1];
                /*
                tab_impexp = new string[3, 1];
                tab_impexp[0, 0] = imp_exp.Trim();
                tab_impexp[1, 0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                tab_impexp[2, 0] = util.iff(imp_exp, "=", "1", "_imp", "_exp");             
                */
                Console.WriteLine(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, imp_exp));
                LisDT[0]=    DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, imp_exp));
                LisDT_tit[0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                Console.WriteLine(util.Tdetalle(LisDT[0]));
                xlsx.CrearExcel_file(LisDT, LisDT_tit, "bosch_spread");
                xlsx.CreadorExcel_2F(LisDT, LisDT_tit, "bosch_closedxm");
            }
            else
            {
                LisDT = new DataTable[2];
                LisDT_tit = new string[2];
             /*   tab_impexp = new string[3, 2];
                tab_impexp[0, 0] = "1";
                tab_impexp[1, 0] = "Importación";
                tab_impexp[2, 0] = "_imp";
                tab_impexp[0, 1] = "2";
                tab_impexp[1, 1] = "Exportación";
                tab_impexp[2, 1] = "_exp";
             */
                //Console.WriteLine(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, imp_exp));
                //temp = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, imp_exp));
                //((Console.WriteLine(util.Tdetalle(temp));
                //                util.closedXML(temp);
                //  util.CrearExcel(temp);
                Console.WriteLine("/********tipo 2***/////////");
                LisDT[0] = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, "2", visible_sql));
                LisDT_tit[0] = "Exportación";
                Console.WriteLine(util.Tdetalle(LisDT[0]));
                Console.WriteLine("/********tipo 1***/////////");
                LisDT[1] = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, "1", visible_sql));
                LisDT_tit[1] = "Importación";
                Console.WriteLine(util.Tdetalle(LisDT[1]));
                xlsx.CrearExcel_file(LisDT, LisDT_tit, "bosch_spread");
                xlsx.CreadorExcel_2F(LisDT, LisDT_tit, "bosch_closedxm");
            }

           return "0";

        }

    }
}
