using System.Data;

namespace serverreports
{
    internal class Bosch_pedimentos3_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) Bosch_Pedimentos3
                   (string Carpeta, string[,] file_name, string Fecha_1, string Fecha_2, string Cliente, string imp_exp, string folios, string mi_sgeclave, string[,] parins, int visible_sql)

        {
            //5071980
            int sw_error = 0;
            Utilerias util = new Utilerias();
            envio_correo correo = new envio_correo();
            DM DM = new DM();
            Excel xlsx = new Excel();
            string[,] tab_impexp;
            DataTable[] LisDT = new DataTable[2];
            string[,] LisDT_tit = new string[2, 2]; ;
            string[] LisDT_tit1 = new string[2];
            List<string> elementos = new List<string>();
            string[] arh;
            if (file_name[4, 0] == "1")
                arh = new string[2];
            else
                arh = new string[1];
            string arch = file_name[0, 0];
            string[,] html = new string[6, 1];
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            int count_R1 = 0;
            string imp_R = "";
            string header_R_tmp = "";
            string Line_Buffer = "";
            string header_tmp = "";
            string[,] par_st = new string[9, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "i";
            par_st[0, 2] = "p_CLIENTE";
            par_st[0, 3] = Cliente;


            par_st[1, 0] = "i";
            par_st[1, 1] = "i";
            par_st[1, 2] = "p_IMP_EXP";
            par_st[1, 3] = imp_exp;


            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Fecha_Inicio";
            par_st[2, 3] = Fecha_1;


            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_Fecha_Fin";
            par_st[3, 3] = Fecha_2;


            par_st[4, 0] = "i";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_MI_SGECLAVE";
            par_st[4, 3] = mi_sgeclave;


            par_st[5, 0] = "i";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_FOLIOS";
            par_st[5, 3] = folios;


            par_st[6, 0] = "o";
            par_st[6, 1] = "c";
            par_st[6, 2] = "p_Cur_Bosch_Pedi";

            par_st[7, 0] = "o";
            par_st[7, 1] = "v";
            par_st[7, 2] = "p_MENSAJE";
            par_st[7, 3] = "msg";

            par_st[8, 0] = "o";
            par_st[8, 1] = "i";
            par_st[8, 2] = "p_CODIGO_ERROR";
            par_st[8, 3] = "cod";

            datos_sp.sql = " SC_RS.SPG_RS_COEX_PEDIMENTOS_BOSCH.P_DAT_IMPORT";

            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(parins[13, 1]), visible_sql);
            LisDT[0] = datos_sp.tb;
            LisDT_tit[0, 0] = " Store 1";
            LisDT_tit1[0] = " Store 1";
            Console.WriteLine(util.Tdetalle(LisDT[0]));
            string val = "";
            for (int i = 0; i < LisDT[0].Rows.Count; i++)
            {
                val = "";
                if (Cliente == "11244, 11248" || Cliente == "11470,11471")
                {
                    if (header_R_tmp != util.nvl(LisDT[0].Rows[i]["FOLIO"].ToString()))
                    {
                        count_R1 = 0;
                        imp_R = "";
                        header_R_tmp = util.nvl(LisDT[0].Rows[i]["FOLIO"].ToString());
                    }
                }
                val = "";
                if (header_tmp != util.nvl(LisDT[0].Rows[i]["SGECLAVE"].ToString()))
                {
                    for (int j = 0; j < 10; j++)
                    {
                        if (Cliente == "11244, 11248" || Cliente == "11470,11471")
                        {
                            if (util.nvl(LisDT[0].Rows[i]["SGECLAVE"].ToString()) == "R1")
                            {
                                if (j == 2)
                                {
                                    count_R1 = count_R1 + 1;
                                    for (int k = 0; k < count_R1; k++)
                                        imp_R = imp_R + "R";
                                    val = val + imp_R + LisDT[0].Rows[i][j].ToString();
                                }
                                else
                                    val = val + LisDT[0].Rows[i][j].ToString();
                            }
                            else
                                val = val + LisDT[0].Rows[i][j].ToString();
                        }
                        else
                            val = val + LisDT[0].Rows[i][j].ToString();
                    }
                    val = val + util.nvl(LisDT[0].Rows[i]["IVA_GAL2"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["ADV_GAL2"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["DTA_GAL2"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["OTROS_GAL2"].ToString());

                    val = val + util.nvl(LisDT[0].Rows[i]["SGEVALORDOLARES"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["SGEVALORADUANA"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["SGEPRECIOPAGADO"].ToString());

                    val = val + util.nvl(LisDT[0].Rows[i]["VALOR_AGREGADO_GAL"].ToString());
                    val = val + util.nvl(LisDT[0].Rows[i]["adicional"].ToString());
                    header_tmp = util.nvl(LisDT[0].Rows[i]["SGECLAVE"].ToString());
                    //If NVL(rs.Fields("'D'")) <> "" Then
                    elementos.Add(val);
                }
                elementos.Add(val);
            }
                        inf.LisDT_tit = LisDT_tit;
            inf.LisDT = LisDT;
            inf.arch = "";
            return inf;

        }
    }
}
