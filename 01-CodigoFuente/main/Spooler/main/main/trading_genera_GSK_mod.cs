using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using System.Drawing;

namespace serverreports
{
    internal class trading_genera_GSK_mod
    {
        public string trading_genera_GSK(string Carpeta, string file_name, string cliente, string Fecha_1, string Fecha_2, string empresa, Int32 idCron, int vs)
        {
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[1];
            string[] LisDT_tit = new string[1]; ;
             (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            datos_sp.sql = "SC_DIST.SPG_RS_COEX.P_RS_GSK_PEDIMENTOS";
            datos_sp = DM.datos_sp(datos_sp.sql , vs);
            Console.WriteLine(" Mensaje store :" + datos_sp.msg);
            Console.WriteLine(" Codigo store :" + datos_sp.codigo);
            LisDT_tit[0] = "Shipments";
            LisDT[0] = datos_sp.tb;
            try
            {
                if ((LisDT[0].Rows.Count > 0) && (datos_sp.codigo == "1"))
                 {
                    xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + "\\" +  file_name + ".xlsx");                    
                    correo.send_mail("Report: < Logis GSK > Envio ok", [], "proceso correcto");
                }
                else
                {
                  if (datos_sp.codigo == "1")
                     datos_sp.msg = "No hay registros en la consulta :" + datos_sp.sql;
                  sw_error = 1;
                }
            }
            catch (Exception ex1)
            {
                datos_sp.codigo = ex1.HResult.ToString();
                datos_sp.msg = ex1.Message;
                sw_error = 1;
            }
            if (sw_error == 1)
            {
                string mensaje = "Hola,  \n"
                + "Ocurrió un error al intentar generar este reporte.  \n"
                + "Consulta ejecutada:  \n"
                + datos_sp.codigo + " \n"
                + datos_sp.msg + " \n"
                + " \n"
                + " \n\n" + " Saludos."
                + " \n\n" + "Logis Reports Server.";
                correo.send_mail("Report: < Logis GSK > Error", [], mensaje);
            }
            LisDT[0].Clear();
            return sw_error.ToString();
        }
    }
}
