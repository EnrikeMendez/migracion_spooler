using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Text;
using System.Threading.Tasks;

namespace serverreports
{
    internal class trading_genera_GSK_mod
    {
        public string trading_genera_GSK(string Carpeta, string file_name, string cliente, string Fecha_1, string Fecha_2, string empresa, Int32 idCron, int vs)
        {
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[1];
            string[] LisDT_tit = new string[1]; ;
            string msg = "Deberia enviar correo";
           
            (string? codigo, string? msg, DataTable? tab) datos_sp = DM.trading_genera_GSK_nv(vs);
            //LisDT[0] = DM.datos_sp1(DM.trading_genera_GSK(cliente, Fecha_1, Fecha_2, empresa, idCron, vs));

            LisDT_tit[0] = "Shipments";
            if ((LisDT[0].Rows.Count > 0) && (datos_sp.codigo == "1"))
            {
                xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + "\\" +  file_name);
                msg = DM.trading_genera_GSK(cliente, Fecha_1, Fecha_2, empresa, idCron, 1);

            }
            else
            {
              string mensaje = "Hola,  \n"
                            + "Ocurrió un error al intentar generar este reporte.  \n"
                            + "Consulta ejecutada:  \n"
                            + DM.trading_genera_GSK(cliente, Fecha_1, Fecha_2, empresa, idCron, vs)  + " \n"
                            + " \n"
                            + " \n\n" + " Saludos."
                            + " \n\n" + "Logis Reports Server.";
                
               // correo.send_error_mail( "Report: < Logis GSK > Error", ["raulrgg@logis.com.mx"], mensaje);
                correo.send_error_mail("Report: < Logis GSK > Error", [], mensaje);
                //correo.send_error_mail("prueba","Prueba");
            }
            LisDT[0].Clear();
            return msg;
        }
    }
}
