using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using System.Text;
using System.Threading.Tasks;
using DocumentFormat.OpenXml.Drawing;

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
            //LisDT[0] = DM.datos(DM.porteos_tln(cliente, Fecha_1, Fecha_2, empresa, idCron, 1));
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            datos_sp.sql = "SC_DIST.SPG_RS_COEX.P_RS_PORTEOS_TLN";
            datos_sp = DM.datos_sp(datos_sp.sql, vs);
            Console.WriteLine(" Mensaje store :" + datos_sp.msg);
            Console.WriteLine(" Codigo store :" + datos_sp.codigo);
            LisDT_tit[0] = "Shipments";
            LisDT[0] = datos_sp.tb;
            try
            {
                if (LisDT[0].Rows.Count > 0 && datos_sp.codigo == "1")
                {
                    xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + "\\" + file_name + ".xlsx");
                    //msg = DM.porteos_tln(cliente, Fecha_1, Fecha_2, empresa, idCron, 1);
                    correo.send_mail("Report: < Logis PORTEO TLN> Envio ok", [], "proceso correcto");
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
            if (sw_error==1)
               correo.msg_error("PORTEOS_TLN",datos_sp.codigo, datos_sp.msg);

            LisDT[0].Clear();
            return sw_error.ToString();
        }

    }
}