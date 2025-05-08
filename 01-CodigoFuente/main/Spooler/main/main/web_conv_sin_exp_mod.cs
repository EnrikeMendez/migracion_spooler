using DocumentFormat.OpenXml.Wordprocessing;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace serverreports
{
    internal class web_conv_sin_exp_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) conv_sin_exp
                  (string Carpeta, string[,] file_name, string Cliente, string cantidad, string[,] pargral, int visible_sql, string? id_cron = "")

        {
            string IP_ADDRESS;

            DM DM = new DM();
            Utilerias util = new Utilerias();
            DataTable[] LisDT = new DataTable[1];
            string[,] LisDT_tit = new string[1, 2]; ;
            List<string> elementos = new List<string>();

            string arch = file_name[0, 0];
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string[,] par_st = new string[7, 4];
            List<string>? campos = new List<string>();

            IP_ADDRESS = null;
            if (pargral[14, 1] != "")
            {
                IP_ADDRESS = pargral[14, 1];
            }


            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_IP_ADDRESS";
            par_st[0, 3] = IP_ADDRESS;
            //par_st[2, 3] = Fecha_2;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_Num_Cliente";
            par_st[1, 3] = Cliente;
            //par_st[1, 3] = Fecha_1;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_CANTIDAD";
            par_st[2, 3] = cantidad;
            //par_st[2, 3] = Fecha_1;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_idCron";
            par_st[3, 3] = id_cron;
            //par_st[3, 3] = Fecha_2;

            par_st[4, 0] = "o";
            par_st[4, 1] = "c";
            par_st[4, 2] = "p_Cur_Reserva_LTL";
            par_st[4, 3] = null;
            //par_st[3, 3] = Fecha_2;

            par_st[5, 0] = "o";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_MENSAJE";
            par_st[5, 3] = "msg";

            par_st[6, 0] = "o";
            par_st[6, 1] = "i";
            par_st[6, 2] = "p_CODIGO_ERROR";
            par_st[6, 3] = "cod";

            datos_sp.sql = " SC_DIST.SPG_DIST_DOC_NUI_RESERVA.P_DAT_RESERVACION_LTL";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            LisDT[0] = datos_sp.tb;

            if (pargral[15, 1] == "1")
            {
                LisDT_tit[0, 0] = "TXT";
                campos.Clear();
                campos.Add("FIJO");
                campos.Add("TALON_RASTREO");
                campos.Add("NUMERO DE GUIA *");
                elementos = util.txt(LisDT[0], campos, "|");
                System.IO.File.WriteAllLines(Carpeta + "\\" + arch + ".txt", elementos);
                if (File.Exists(Carpeta + "\\" + arch + ".txt"))
                    arch = arch + "|" + Carpeta + "\\" + arch + ".txt";
            }
            else if (pargral[16, 1] == "1")
            {
                LisDT_tit[0, 0] = "Reservacion de Guias LTL";
                string[,] datosdef = new string[3, 3];
                datosdef[0, 0] = "NUMERO DE GUIA *";
                datosdef[0, 1] = "S";
                datosdef[0, 2] = "V";

                datosdef[1, 0] = "DESCRIPCIÓN";
                datosdef[1, 1] = "S";
                datosdef[1, 2] = "SN";

                datosdef[2, 0] = "PESO EN (KG) *";
                datosdef[2, 1] = "S";
                datosdef[2, 2] = "SN";
                LisDT[0] = util.tab_col_def(LisDT[0], datosdef);
            }
            inf.arch = arch;

            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            return inf;
        }
    }
}