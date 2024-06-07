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
        public string trading_genera_GSK(string Carpeta, string file_name, string param1, string Fecha_1, string Fecha_2, string empresa, Int32 idCron, int vs)
        {
            Utilerias util = new Utilerias();
            DM DM = new DM();
            Excel xlsx = new Excel();
            DataTable[] LisDT = new DataTable[1];
            string[] LisDT_tit = new string[1]; ;
            string msg = "Deberia enviar correo";
            LisDT[0] = DM.datos(DM.trading_genera_GSK(param1, Fecha_1, Fecha_2, empresa, idCron, vs));
            LisDT_tit[0] = "Shipments";
            if (LisDT[0].Rows.Count>0) { 
               xlsx.CrearExcel_file(LisDT, LisDT_tit, "spread_"+ file_name);
              // xlsx.CreadorExcel_2F(LisDT, LisDT_tit, "closedxm_"+ file_name);
               msg= DM.trading_genera_GSK(param1, Fecha_1, Fecha_2, empresa, idCron, 1);
               LisDT[0].Clear();
            }
            return msg;
        }
    }
}
