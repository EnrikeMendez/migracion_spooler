using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Text;
using System.Threading.Tasks;

namespace serverreports
{
    internal class trading_genera_TLN_mod
    {
        public string trading_genera_TLN(string Carpeta, string file_name, string cliente, string Fecha_1, string Fecha_2, string empresa, Int32 idCron, int vs)
        {
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[1];
            string[] LisDT_tit = new string[1];
            LisDT[0] = DM.datos(DM.porteos_tln(cliente, Fecha_1, Fecha_2, empresa, idCron, 1));
            LisDT_tit[0] = "Shipments";
            if (LisDT[0].Rows.Count > 0)
            {
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + "\\" + file_name + ".xlsx");
                //msg = DM.porteos_tln(cliente, Fecha_1, Fecha_2, empresa, idCron, 1);
            }
            else
            {
                string mensaje = "Hola,  \n"
                              + "Ocurrió un error al intentar generar este reporte.  \n"
                              + "Consulta ejecutada:  \n"
                              + DM.porteos_tln(cliente, Fecha_1, Fecha_2, empresa, idCron, 1) + " \n"
                              + " \n"
                              + " \n\n" + " Saludos."
                              + " \n\n" + "Logis Reports Server.";

                // correo.send_error_mail( "Report: < Logis GSK > Error", ["raulrgg@logis.com.mx"], mensaje);
                correo.send_mail("Report: < Logis GSK > Error", [], mensaje);
                //correo.send_error_mail("prueba","Prueba");
            }
            LisDT[0].Clear();
            return sw_error.ToString();
        }

    }
}