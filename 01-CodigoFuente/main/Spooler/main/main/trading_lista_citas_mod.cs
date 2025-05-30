using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace serverreports
{
    internal class trading_lista_citas_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) trading_lista_citas
         (string[,] file_name, string Cliente, string cedis, string[,] pargral, int visible_sql)
        {
            DM DM = new DM();
            DateTime date1 = new DateTime(2008, 6, 1, 7, 47, 0);
            Utilerias util = new Utilerias();
            DataTable[] LisDT = new DataTable[1];
            string[,] LisDT_tit = new string[1, 3]; ;
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string[,] par_st = new string[7, 4];
            string arch = file_name[0, 0];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_FECHA_INICIO";
            par_st[0, 3] = pargral[6, 1];

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_FECHA_FIN";
            par_st[1, 3] = pargral[7, 1];

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_CLICLEF";
            par_st[2, 3] = null;
            if (Cliente != "")
                par_st[2, 3] = Cliente;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_CEDIS";
            par_st[3, 3] = null;
            if (cedis != "")
                par_st[3, 3] = cedis;


            par_st[4, 0] = "o";
            par_st[4, 1] = "c";
            par_st[4, 2] = "p_Cur_LISTA_CITAS_RES";

            par_st[5, 0] = "o";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_MENSAJE";
            par_st[5, 3] = "msg";

            par_st[6, 0] = "o";
            par_st[6, 1] = "i";
            par_st[6, 2] = "p_CODIGO_ERROR";
            par_st[6, 3] = "cod";

            datos_sp.sql = "SC_RS.SPG_RS_DIST_TRAD_LISTA_CITAS.P_DAT_TRADING_CITAS_RESUMEN";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
            int ntb = datos_sp.tb.Rows.Count + 1;
            LisDT = new DataTable[ntb];
            LisDT_tit = new string[ntb, 4];
            LisDT[0] = datos_sp.tb;
            int ncta = 0;
            for (int i = 0; i <= ntb - 1; i++)
            {
                ncta = i + 1;
                if (i == (ntb - 1))
                {
                    ncta = 0;
                    cedis = "";
                    LisDT_tit[ncta, 0] = "Resumen";
                }
                else
                {
                    LisDT_tit[ncta, 0] = util.Tcampo_reg(LisDT[0], "ALLCODIGO", i);
                    cedis = util.Tcampo_reg(LisDT[0], "ALLCLAVE", i);
                }

                par_st[0, 0] = "i";
                par_st[0, 1] = "v";
                par_st[0, 2] = "p_FECHA_INICIO";
                par_st[0, 3] = pargral[6, 1];

                par_st[1, 0] = "i";
                par_st[1, 1] = "v";
                par_st[1, 2] = "p_FECHA_FIN";
                par_st[1, 3] = pargral[7, 1];

                par_st[2, 0] = "i";
                par_st[2, 1] = "v";
                par_st[2, 2] = "p_CLICLEF";
                par_st[2, 3] = null;
                if (Cliente != "")
                    par_st[2, 3] = Cliente;

                par_st[3, 0] = "i";
                par_st[3, 1] = "v";
                par_st[3, 2] = "p_CEDIS";
                par_st[3, 3] = null;
                if (cedis != "")
                    par_st[3, 3] = cedis;

                par_st[4, 0] = "o";
                par_st[4, 1] = "c";
                par_st[4, 2] = "p_Cur_LISTA_CITAS_RES";

                par_st[5, 0] = "o";
                par_st[5, 1] = "v";
                par_st[5, 2] = "p_MENSAJE";
                par_st[5, 3] = "msg";

                par_st[6, 0] = "o";
                par_st[6, 1] = "i";
                par_st[6, 2] = "p_CODIGO_ERROR";
                par_st[6, 3] = "cod";

                datos_sp.sql = "SC_RS.SPG_RS_DIST_TRAD_LISTA_CITAS.P_DAT_TRADING_CITAS";
                datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
                LisDT[ncta] = datos_sp.tb;
            }
            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = arch;
            return inf;
        }

    }
}
