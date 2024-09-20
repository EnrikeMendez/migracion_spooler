using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;

namespace serverreports
{
    internal class Bosch_pedimentos2_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) Bosch_Pedimentos2
               (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Clientes, string Planta, string imp_exp, string[,] parins, string[] contacmail, int visible_sql)
        {
            int sw_error = 0;
            Utilerias util = new Utilerias();
            DM DM = new DM();
            string[,] tab_impexp;
            DataTable[] LisDT = new DataTable[3];
            string[,] LisDT_tit = new string[3, 2]; ;
            List<string> elementos = new List<string>();
            string[] arh;
            if (file_name[4, 0] == "1")
                arh = new string[2];
            else
                arh = new string[1];
            string arch = file_name[0, 0];
            string[,] html = new string[6, 1];
            int count_R1 = 0;
            string imp_R = "";
            string header_R_tmp = "";
            string Line_Buffer = "";
            string header_tmp = "";

            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;

            string[,] par_st = new string[7, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_CLIENTE";
            par_st[0, 3] = "1235";
            //par_st[0, 3] = Clientes;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_IMP_EXP";
            par_st[1, 3] = "1";
            //par_st[1, 3] = imp_exp;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Fecha_Inicio";
            par_st[2, 3] = "10/23/2002";
            //par_st[2, 3] = Fecha_1;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Fecha_Fin";
            par_st[3, 3] = "11/23/2002";
            //par_st[3, 3] =Fecha_2;

            par_st[4, 0] = "o";
            par_st[4, 1] = "c";
            par_st[4, 2] = "p_Cur_Bosch_Pedi";

            par_st[5, 0] = "o";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_MENSAJE";
            par_st[5, 3] = "msg";

            par_st[6, 0] = "o";
            par_st[6, 1] = "i";
            par_st[6, 2] = "p_CODIGO_ERROR";
            par_st[6, 3] = "cod";

            datos_sp.sql = " SC_RS.SPG_RS_COEX_PEDIMENTOS_BOSCH.P_DAT_FOLIOS_GENERAL ";
            Console.WriteLine(Planta);
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, visible_sql);
            LisDT[0] = datos_sp.tb;
            LisDT_tit[0, 0] = "Pediment 2 " + Fecha_1 + " To" + Fecha_2;
          
            string val = "";
            for (int i = 0; i < LisDT[0].Rows.Count; i++)
            {
                val = "";
                if (header_tmp != util.nvl(LisDT[0].Rows[i]["SGECLAVE"].ToString()))
                {
                    for (int j = 0; j < 10; j++)
                        val = val + LisDT[0].Rows[i][j].ToString();

                    val = val + util.nvl(LisDT[0].Rows[i]["IVA_GAL2"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["ADV_GAL2"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["DTA_GAL2"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["OTROS_GAL2"].ToString());

                    val = val  + util.nvl(LisDT[0].Rows[i]["SGEVALORDOLARES"].ToString());
                    val = val  + util.nvl(LisDT[0].Rows[i]["SGEVALORADUANA"].ToString());
                    val = val  + util.nvl(LisDT[0].Rows[i]["SGEPRECIOPAGADO"].ToString());
                    val = val  + util.nvl(LisDT[0].Rows[i]["EDOCUMENT"].ToString());
                    header_tmp = util.nvl(LisDT[0].Rows[i]["CLAVE_FAC"].ToString());
                    elementos.Add(val);
                }
                if (util.nvl(LisDT[0].Rows[i]["DETALLE_D"].ToString()) != "")
                {
                    Line_Buffer = "";
                    for (int j = 20; j <= 37; j++)
                        Line_Buffer = Line_Buffer + LisDT[0].Rows[i][j].ToString();
                    elementos.Add(Line_Buffer);
                }
            }

            par_st = new string[9, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_CLIENTE";
            par_st[0, 3] = "1235";
            //par_st[0, 3] = Clientes;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_IMP_EXP";
            par_st[1, 3] = "1";
            //par_st[1, 3] = imp_exp;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Fecha_Inicio";
            par_st[2, 3] = "03/04/2003";
            //par_st[2, 3] = Fecha_1;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Fecha_Fin";
            par_st[3, 3] = "04/04/2003";
            //par_st[3, 3] = Fecha_2;

            par_st[4, 0] = "i";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_CLAVE_FAC";
            //par_st[4, 3] = util.nvl(util.Tcampo(LisDT[0], "SGECLAVE"));
            par_st[4, 3] = "165777";
            //par_st[2, 3] = Fecha_1;

            par_st[5, 0] = "i";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_NUM_PEDIMENTO";
            //par_st[5, 3] = util.nvl(util.Tcampo(LisDT[0], "NUM_PEDIMENTO"));
            par_st[5, 3] = "034734203004129";
            //par_st[3, 3] = Fecha_2;

            par_st[6, 0] = "o";
            par_st[6, 1] = "c";
            par_st[6, 2] = "p_Cur_Bosch_Pedi_cve";

            par_st[7, 0] = "o";
            par_st[7, 1] = "v";
            par_st[7, 2] = "p_MENSAJE";
            par_st[7, 3] = "msg";

            par_st[8, 0] = "o";
            par_st[8, 1] = "i";
            par_st[8, 2] = "p_CODIGO_ERROR";
            par_st[8, 3] = "cod";

            datos_sp.sql = "SC_RS.SPG_RS_COEX_PEDIMENTOS_BOSCH.P_DAT_FOLIOS_CLAVE";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, visible_sql);
            LisDT[1] = datos_sp.tb;
            Console.WriteLine(util.Tdetalle(LisDT[1]));
            for (int i = 0; i < LisDT[1].Rows.Count; i++)
            {
                val = "";
                for (int j = 0; j < 10; j++)
                    val = val + LisDT[1].Rows[i][j].ToString();
                val = val + util.nvl(LisDT[1].Rows[i]["IVA_GAL"].ToString());
                val = val + util.nvl(LisDT[1].Rows[i]["ADV_GAL"].ToString());
                val = val + util.nvl(LisDT[1].Rows[i]["DTA_GAL"].ToString());
                val = val + util.nvl(LisDT[1].Rows[i]["OTROS_GAL"].ToString());

                val = val + util.nvl(LisDT[1].Rows[i]["SGEVALORDOLARES"].ToString());
                val = val + util.nvl(LisDT[1].Rows[i]["SGEVALORADUANA"].ToString());
                val = val + util.nvl(LisDT[1].Rows[i]["SGEPRECIOPAGADO"].ToString());
                val = val + util.nvl(LisDT[1].Rows[i]["EDOCUMENT"].ToString());

                //header_tmp = util.nvl(LisDT[].Rows[i]["CLAVE_FAC"].ToString());
                elementos.Add(val);
            }


            par_st = new string[7, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_CLIENTE";
            par_st[0, 3] = "23386";
            //par_st[1, 3] = Fecha_1;

            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_IMP_EXP";
            par_st[1, 3] = "1";
            //par_st[2, 3] = Fecha_2;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Fecha_Inicio";
            par_st[2, 3] = "08/30/2023";
            //par_st[2, 3] = Fecha_1;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Fecha_Fin";
            par_st[3, 3] = "03/19/2024";
            //par_st[3, 3] = Fecha_2;
            par_st[4, 0] = "o";
            par_st[4, 1] = "c";
            par_st[4, 2] = "p_Cur_Bosch_Pedi_rac";
            par_st[5, 0] = "o";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_MENSAJE";
            par_st[5, 3] = "msg";

            par_st[6, 0] = "o";
            par_st[6, 1] = "i";
            par_st[6, 2] = "p_CODIGO_ERROR";
            par_st[6, 3] = "cod";

            datos_sp.sql = "SC_RS.SPG_RS_COEX_PEDIMENTOS_BOSCH.P_DAT_FOLIOS_RECTIFICACION ";
            datos_sp = DM.datos_sp([datos_sp.sql], par_st, visible_sql);
            LisDT[2] = datos_sp.tb;
            Console.WriteLine(util.Tdetalle(LisDT[2]));
            string IMP_EXP_tmp = "";
            string FOLIO_tmp = "";
            string CLAVE_PED_tmp = "";
            string NUM_PEDIMENTO_tmp = "";
            string SGECLAVE_tmp = "";
            for (int i = 0; i < LisDT[2].Rows.Count; i++)
            {
                val = "";
                if (
                IMP_EXP_tmp != util.nvl(LisDT[2].Rows[i]["IMP_EXP"].ToString()) &
                FOLIO_tmp != util.nvl(LisDT[2].Rows[i]["ADUANA_SEC"].ToString()) &
                CLAVE_PED_tmp != util.nvl(LisDT[2].Rows[i]["CLAVE_PED"].ToString()) &
                NUM_PEDIMENTO_tmp != util.nvl(LisDT[2].Rows[i]["NUM_PEDIMENTO"].ToString()) &
                SGECLAVE_tmp != util.nvl(LisDT[2].Rows[i]["SGECLAVE"].ToString()))
                {
                    for (int j = 0; j < 10; j++)
                        val = val + LisDT[2].Rows[i][j].ToString();
                    val = val + util.nvl(LisDT[2].Rows[i]["IVA_GAL"].ToString());
                    val = val + util.nvl(LisDT[2].Rows[i]["ADV_GAL"].ToString());
                    val = val + util.nvl(LisDT[2].Rows[i]["DTA_GAL"].ToString());
                    val = val + util.nvl(LisDT[2].Rows[i]["OTROS_GAL"].ToString());
                    val = val + util.nvl(LisDT[2].Rows[i]["SGEVALORDOLARES"].ToString());
                    val = val + util.nvl(LisDT[2].Rows[i]["SGEVALORADUANA"].ToString());
                    val = val + util.nvl(LisDT[2].Rows[i]["SGEPRECIOPAGADO"].ToString());
                    elementos.Add(val);
                }

                val = "";
                for (int j = util.Tcampo_numcol(LisDT[2], "DETALLE_D") + 1; j < LisDT[2].Columns.Count; j++)
                    val = val + LisDT[2].Rows[i][j].ToString();
                elementos.Add(val);
                IMP_EXP_tmp = util.nvl(LisDT[2].Rows[i]["IMP_EXP"].ToString());
                FOLIO_tmp = util.nvl(LisDT[2].Rows[i]["ADUANA_SEC"].ToString());
                CLAVE_PED_tmp = util.nvl(LisDT[2].Rows[i]["CLAVE_PED"].ToString());
                NUM_PEDIMENTO_tmp = util.nvl(LisDT[2].Rows[i]["NUM_PEDIMENTO"].ToString());
                SGECLAVE_tmp = util.nvl(LisDT[2].Rows[i]["SGECLAVE"].ToString());
            }
            /*
            string cp = "C:\\pc\\ruta_alterna\\";
            if (!Directory.Exists(cp))
            {
              Directory.CreateDirectory(cp);
            }
            using (StreamWriter sw = File.CreateText(cp + "Pedimento2.txt"))
            {
                sw.WriteLine(util.Tdetalle(LisDT[0]));
            }
            */
            //Console.WriteLine(util.Tdetalle(LisDT[0]));
         //   System.IO.File.WriteAllLines(@"C:\\pc\\ruta_alterna\\Pedimento2.txt", elementos);
            System.IO.File.WriteAllLines(@Carpeta + "\\" + arch + ".txt", elementos);
            inf.LisDT_tit = LisDT_tit;
            inf.LisDT     = LisDT;
            inf.arch = arch + "|" + Carpeta + "\\" + arch + ".txt";
            return inf;            

        }
    }
}
