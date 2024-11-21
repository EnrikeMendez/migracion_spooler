using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace serverreports
{
    internal class web_indice_cal_bosch
    {

        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) indice_cal_bosch
            (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Clientes, string Planta, string imp_exp, string[,] pargral, string[] contacmail, int visible_sql)
        {
            //5071980
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            string[,] tab_impexp;
            DataTable[] LisDT = new DataTable[1];
            string[,] LisDT_tit = new string[6,1]; ;

            string[] arh;
            if (file_name[4, 0] == "1")
                arh = new string[2];
            else
                arh = new string[1];
            string arch = file_name[0, 0];
            string[,] html = new string[6, 1];
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;

            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;

            string[,] par_st = new string[8, 4];
            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_Fecha_Inicio";
            par_st[1, 3] = "01/01/2024";
            //par_st[1, 3] = Fecha_1;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Fecha_Fin";
            par_st[2, 3] = "01/31/2024";
            //par_st[2, 3] = Fecha_2;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Filtro_Cliente";
            //par_st[3, 3] = "11244,11248,11470,11471,19939,19943,5199";
            par_st[3, 3] = Clientes;
            par_st[5, 0] = "o";
            par_st[5, 1] = "c";
            par_st[5, 2] = "p_Cur_Tiempos_Desp";

            par_st[6, 0] = "o";
            par_st[6, 1] = "v";
            par_st[6, 2] = "p_Mensaje";
            par_st[6, 3] = "msg";

            par_st[7, 0] = "o";
            par_st[7, 1] = "i";
            par_st[7, 2] = "p_Codigo_Error";
            par_st[7, 3] = "cod";

            /*
            SC_RS.SPG_RS_COEX.P_DAT_TIEMPOS_DESPACHO(p_Tipo_Aduana => 'M'-- IN VARCHAR2 *****0
                                          , p_Fecha_Inicio => '01/01/2024'-- IN VARCHAR2
            , p_Fecha_Fin => '01/31/2024'-- IN VARCHAR2
                                          , p_Filtro_Cliente => '3000661,3000663'-- IN VARCHAR2
                                          , p_Tab_Impexp => NULL-- IN VARCHAR2  **** 4
                                          , p_Cur_Tiempos_Desp => v_Cur_Tiempos_Desp--OUT SYS_REFCURSOR
                                          , p_Mensaje => v_Mensaje--OUT VARCHAR2
                                          , p_Codigo_Error => v_Codigo_Error--OUT NUMBER
                                          );
            */
            datos_sp.sql = "SC_RS.SPG_RS_COEX.P_DAT_TIEMPOS_DESPACHO";

            if (imp_exp.Trim() == "1" || imp_exp.Trim() == "2")
            {
                tab_impexp = new string[1, 2];
                tab_impexp[0, 0] = imp_exp;
                tab_impexp[0, 1] = util.iff(imp_exp, "=", "1", "Import", "Export");
                LisDT = new DataTable[3];
                LisDT_tit = new string[3,2];
                par_st[4, 0] = "i";
                par_st[4, 1] = "v";
                par_st[4, 2] = "p_Tab_Impexp";
                par_st[4, 3] = imp_exp;

            }
            else
            {
                tab_impexp = new string[2, 4];
                tab_impexp[0, 0] = "1";
                tab_impexp[0, 1] = "2";
                tab_impexp[1, 0] = "Import";
                tab_impexp[1, 1] = "Export";
                LisDT = new DataTable[6];
                LisDT_tit = new string[6,2];

            }
            Console.WriteLine(Planta);

            int z = 0;
            for (int i = 0; i < tab_impexp.GetLength(0); i++)
            {
                Console.WriteLine(tab_impexp[1, i]);
                par_st[4, 0] = "i";
                par_st[4, 1] = "v";
                par_st[4, 2] = "p_Tab_Impexp";
                par_st[4, 3] = tab_impexp[0, i];

                par_st[0, 0] = "i";
                par_st[0, 1] = "v";
                par_st[0, 2] = "p_Tipo_Aduana";
                par_st[0, 3] = "A";

                datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
                LisDT[z] = datos_sp.tb;
                Console.WriteLine(util.Tdetalle(LisDT[z]));
                LisDT[z] = util.Tdetalle_regtot(LisDT[z], 1, 0, 1, 0, 1); //porcentaje           
                LisDT[z] = util.Tdetalle_reversa(LisDT[z]);
                //LisDT[z] = util.Tdetalle_regtot(LisDT[z], 1, 0, 0, LisDT[z].Columns.Count-2, 1); //porcentaje
                //LisDT_tit[z,0] = tab_impexp[1, i] + "|" + "Titulo de Hoja";
                LisDT_tit[z, 0] = Planta + " " + tab_impexp[1, i] + "|" + "Customs Clearance - From " + Fecha_1 + " To" + Fecha_2 + util.iff(Planta, "=", " ", "", " - " + Planta) + "|" + "MoT: Air" + "|" + "Customs Clearance Times - Air MoT";
                Console.WriteLine(util.Tdetalle(LisDT[z]));                
                z++; 
                par_st[0, 3] = "M";
                datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
                LisDT[z] = datos_sp.tb;
                Console.WriteLine(util.Tdetalle(LisDT[z]));
                LisDT[z] = util.Tdetalle_regtot(LisDT[z], 1, 0, 1, 0, 1); //porcentaje
                LisDT[z] = util.Tdetalle_reversa(LisDT[z]); //reversa
               // LisDT[z] = util.Tdetalle_regtot(LisDT[z], 1, 0, 0, LisDT[z].Columns.Count - 2, 1); //porcentaje
                Console.WriteLine(util.Tdetalle(LisDT[z]));
                //LisDT_tit[z,0] = tab_impexp[1, i] + "|" + "Titulo de Hoja";
                LisDT_tit[z, 0] = Planta + " " + tab_impexp[1, i] + "|" + "Customs Clearance - From " + Fecha_1 + " To" + Fecha_2 + util.iff(Planta, "=", " ", "", " - " + Planta) + "|" + "MoT: Sea" + "|" + "Customs Clearance Times - Sea MoT";
                //LisDT_tit[z] = tab_impexp[1, i];
                Console.WriteLine(util.Tdetalle(LisDT[z]));
                z++;
                par_st[0, 3] = "T";
                datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]), visible_sql);
                LisDT[z] = datos_sp.tb;
                Console.WriteLine(util.Tdetalle(LisDT[z]));
                LisDT[z] = util.Tdetalle_regtot(LisDT[z], 1, 0, 1, 0, 1); //porcentaje
                LisDT[z] = util.Tdetalle_reversa(LisDT[z]); //reversa
                //LisDT[z] = util.Tdetalle_regtot(LisDT[z], 1, 0, 0, LisDT[z].Columns.Count - 2, 1); //porcentaje
                //LisDT_tit[z] = tab_impexp[1, 0];
                //LisDT_tit[z, 0] = tab_impexp[1, i] + "|" + "Titulo de Hoja";
                LisDT_tit[z, 0] = Planta + " " + tab_impexp[1, i] + "|" + "Customs Clearance - From " + Fecha_1 + " To" + Fecha_2 + util.iff(Planta, "=", " ", "", " - " + Planta) + "|" + "MoT: Land" + "|" + "Customs Clearance Times - Land MoT";
                Console.WriteLine(util.Tdetalle(LisDT[z]));
                z++;

            }

            /*
            Console.WriteLine(tab_impexp[1, 0]);
                par_st[4, 0] = "i";
                par_st[4, 1] = "v";
                par_st[4, 2] = "p_Tab_Impexp";
                par_st[4, 3] = tab_impexp[0, 0];

                par_st[0, 0] = "i";
                par_st[0, 1] = "v";
                par_st[0, 2] = "p_Tipo_Aduana";
                par_st[0, 3] = "A";
                datos_sp = DM.datos_sp([datos_sp.sql], par_st, visible_sql);
                LisDT[0] = datos_sp.tb;
                Console.WriteLine(util.Tdetalle(LisDT[0]));

                LisDT[0] = util.Tdetalle_regtot(LisDT[0], 1, 0, 1, 1, 1); //porcentaje
                LisDT[0] = util.Tdetalle_reversa(LisDT[0]);
                LisDT_tit[0] = tab_impexp[1, 0];
                Console.WriteLine(util.Tdetalle(LisDT[0]));        
            */
            // Console.WriteLine(xlsx.CrearExcel_file(LisDT, LisDT_tit, Carpeta + "\\" + arch));
            inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = arch;
            return inf;
        }
    }
}
