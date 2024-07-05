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


        public string transmision_edocs_bosch(string Carpeta, string file_name, string Clientes, string Fecha_1, string Fecha_2, string imp_exp, string tipo_doc, int visible_sql)
        {
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[1];
            string[] LisDT_tit = new string[1]; ;
            string[] tab_impexp;

            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            try
            {
                datos_sp.sql = "SC_DIST.SPG_RS_COEX.P_RS_TRANSMISION_COVE";
            if (imp_exp.Trim() == "1" || imp_exp.Trim() == "2")
            {
                LisDT = new DataTable[1];
                LisDT_tit = new string[1];
                datos_sp = DM.datos_sp([datos_sp.sql], visible_sql, Clientes, Fecha_1, Fecha_2, imp_exp, tipo_doc, imp_exp);
                Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                LisDT[0] = datos_sp.tb;
                LisDT_tit[0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name);
            }
            else
            {
                LisDT = new DataTable[2];
                LisDT_tit = new string[2];
                datos_sp = DM.datos_sp([datos_sp.sql], visible_sql, Clientes, Fecha_1, Fecha_2, "null", tipo_doc, "2");
                LisDT[0] = datos_sp.tb;
                LisDT_tit[0] = "Exportación";
                Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                datos_sp = DM.datos_sp([datos_sp.sql], visible_sql, Clientes, Fecha_1, Fecha_2, "null", tipo_doc, "1");
                LisDT[1] = datos_sp.tb;
                LisDT_tit[1] = "Importación";
                Console.WriteLine(" Mensaje store :" + datos_sp.msg);
                Console.WriteLine(" Codigo store :" + datos_sp.codigo);
                string[] arh = new string[2];
                
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name, 1);
            }
        }
            catch (Exception ex1)
            {
                datos_sp.codigo = ex1.HResult.ToString();
                datos_sp.msg = ex1.Message;
                sw_error = 1;
            }
            if (sw_error == 1)
                correo.msg_error("PORTEOS_TLN", datos_sp.codigo, datos_sp.msg);
            LisDT[0].Clear();
            return sw_error.ToString();
        }

        public string transmision_edocs_bosch2(string Carpeta, string file_name, string Clientes, string Fecha_1, string Fecha_2, string imp_exp, string tipo_doc, int visible_sql)
        {
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
                //  Console.WriteLine(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, imp_exp, tipo_doc, imp_exp, visible_sql));
                LisDT[0] = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, imp_exp, tipo_doc, imp_exp));
                LisDT_tit[0] = util.iff(imp_exp, "=", "1", "Importación", "Exportación");
                ///Console.WriteLine(util.Tdetalle(LisDT[0]));
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name);
            }
            else
            {
                LisDT = new DataTable[2];
                LisDT_tit = new string[2];
                //Console.WriteLine("/********tipo 2***/////////");
                LisDT[0] = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, "2", visible_sql));
                LisDT_tit[0] = "Exportación";
                // Console.WriteLine(util.Tdetalle(LisDT[0]));
                //Console.WriteLine("/********tipo 1***/////////");
                LisDT[1] = DM.datos(DM.transmision_edocs_bosch(Clientes, Fecha_1, Fecha_2, "", tipo_doc, "1", visible_sql));
                LisDT_tit[1] = "Importación";
                //Console.WriteLine(util.Tdetalle(LisDT[1]));
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + file_name, 1);
            }
            for (int i = 0; i < LisDT.Length; i++)
                LisDT[i].Clear();
            return "0";

        }

    }
}
