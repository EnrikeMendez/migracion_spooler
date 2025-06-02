using System.Data;

using static System.Net.WebRequestMethods;

namespace serverreports
{
    internal class web_doc_interna_pendientes_mod
    {

        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) web_cd_ltl_doc_interna_pend(string Carpeta, string[,] file_name, string[,] pargral, string fecha_ini, string fecha_fin, string? cedis, string? cliente, string? manif, string? pestana)
        {

            DM DM = new DM();
            Excel xlsx = new Excel();
            Utilerias util = new Utilerias();
            DataSet ds = new DataSet();
            DataTable dt = new DataTable();
            DataTable dttemp = new DataTable();
            DataTable dttemp2 = new DataTable();
            DataTable dttemp3 = new DataTable();
            DataTable dttemp4 = new DataTable();
            
            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string arch = file_name[0, 0];
            string[,] par_st;
            string mi_pestana = pestana;
            bool procExito = false;

            //mi_pestana = "";

            if (!int.TryParse(mi_pestana, out int res))
            {
                mi_pestana = "";
            }
            else
            {        
                mi_pestana = Convert.ToInt16(mi_pestana) <= 0 || Convert.ToInt16(mi_pestana) > 12 ? "" : mi_pestana;
            }

            par_st = new string[8, 4];
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_Numero_Cliente";
            par_st[0, 3] = cliente;

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_CEDIS";
            par_st[1, 3] = cedis;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_Manifiesto";
            par_st[2, 3] = manif;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_FECHA_INICIO";
            par_st[3, 3] = fecha_ini;

            par_st[4, 0] = "i";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_FECHA_FINAL";
            par_st[4, 3] = fecha_fin;

            par_st[5, 0] = "o";
            par_st[5, 1] = "c";
            par_st[5, 2] = "";

            par_st[6, 0] = "o";
            par_st[6, 1] = "v";
            par_st[6, 2] = "p_MENSAJE";
            par_st[6, 3] = "msg";

            par_st[7, 0] = "o";
            par_st[7, 1] = "i";
            par_st[7, 2] = "p_CODIGO_ERROR";
            par_st[7, 3] = "cod";

            try
            {
                switch (mi_pestana)
                {
                    case "1":

                        // 1A_Merc Scan Entrada Cliente
                        // 1B_Merc Scan Entrada Cliente
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_SCAN_ENTRA_CLI_A";
                        par_st[5, 2] = "p_CurSCAN_ENTRA_CLI_1A";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "1A_Merc Scan Entrada Cliente";
                            ds.Tables.Add(dt);

                            datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_SCAN_ENTRA_CLI_B";
                            par_st[5, 2] = "p_CurSCAN_ENTRA_CLI_1B";
                            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));
                            if (datos_sp.codigo == "1")
                            {
                                dt = datos_sp.tb.Copy();
                                dt.TableName = "1B_Merc Scan Entrada Cliente";
                                ds.Tables.Add(dt);
                                procExito = true;
                            }
                        }

                        break;

                    case "2":
                        // 2_Merc Sin Datos Logistico
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_SIN_DAT_LOGISTICO";
                        par_st[5, 2] = "p_CurSIN_DAT_LOGISTICO";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "2_Merc Sin Datos Logistico";
                            ds.Tables.Add(dt);
                            procExito = true;
                        }

                        break;

                    case "3":
                        // 3_Merc Sin Convertidor
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_SIN_CONVERTIDOR";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurSIN_CONVERTIDOR";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "CROSSDOCK NORMAL")
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "3A_Merc Sin Convertidor";
                            dttemp2.TableName = "3B_Merc Sin Convertidor";
                            ds.Tables.Add(dttemp);
                            ds.Tables.Add(dttemp2);
                            procExito = true;
                        }

                        break;

                    case "4":
                        // 4_Transf Doc a Control Doc
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_TRANSF_DOC_A_CTRL_DOC";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurDOC_A_CTRL_DOC";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.Columns.RemoveAt(dt.Columns.Count - 1);
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();
                            dttemp3 = dt.Clone();
                            dttemp4 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if ((dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "CROSSDOCK NORMAL")
                                     && dt.Rows[i]["Cedis"].ToString().ToUpper() == "TLN" && (Convert.ToInt64(dt.Rows[i]["N°"].ToString()) >= 10000 || Convert.ToInt64(dt.Rows[i]["N°"].ToString()) < 9900))
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else if ((dt.Rows[i]["Tipo operacion"].ToString().ToUpper() != "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() != "CROSSDOCK NORMAL")
                                     && dt.Rows[i]["Cedis"].ToString().ToUpper() == "TLN" && (Convert.ToInt64(dt.Rows[i]["N°"].ToString()) >= 10000 || Convert.ToInt64(dt.Rows[i]["N°"].ToString()) < 9900))
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                                else if (Convert.ToInt64(dt.Rows[i]["N°"].ToString()) >= 9900 || Convert.ToInt64(dt.Rows[i]["N°"].ToString()) <= 9999)
                                {
                                    dttemp3.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp4.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "4A_Transf Doc a Control Doc";
                            dttemp2.TableName = "4B_Transf Doc a Control Doc";
                            dttemp3.TableName = "4C_Transf Doc a Control Doc";
                            dttemp4.TableName = "4D_Transf Doc a Control Doc";
                            ds.Tables.Add(dttemp);
                            ds.Tables.Add(dttemp2);
                            ds.Tables.Add(dttemp3);
                            ds.Tables.Add(dttemp4);
                            procExito = true;
                        }

                        break;

                    case "5":
                        // 5_Merc Conv No Validado
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_CONV_NO_VALIDADO";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurCONV_NO_VALIDADO";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "5_Merc Conv No Validado";
                            ds.Tables.Add(dt);
                            procExito = true;
                        }

                        break;

                    case "6":
                        // 6_Armado Doc Manif Convertidor
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_ARMADO_DOC_MANIF_CONV ";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurDOC_MANIF_CONV";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();
                            dttemp3 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if ((dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "CROSSDOCK NORMAL")
                                     && (Convert.ToInt64(dt.Rows[i]["N° Cliente"].ToString()) >= 10000 || Convert.ToInt64(dt.Rows[i]["N° Cliente"].ToString()) < 9900))
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else if ((dt.Rows[i]["Tipo operacion"].ToString().ToUpper() != "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() != "CROSSDOCK NORMAL")
                                     && (Convert.ToInt64(dt.Rows[i]["N° Cliente"].ToString()) >= 10000 || Convert.ToInt64(dt.Rows[i]["N° Cliente"].ToString()) < 9900))
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp3.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "6A_Armado Doc Manif Convertidor";
                            dttemp2.TableName = "6B_Armado Doc Manif Convertidor";
                            dttemp3.TableName = "6C_Armado Doc Manif Convertidor";
                            ds.Tables.Add(dttemp);
                            ds.Tables.Add(dttemp2);
                            ds.Tables.Add(dttemp3);
                            procExito = true;
                        }

                        break;

                    case "7":
                        // 7_Merc Conv Sin Expedicion
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_CONV_SIN_EXP";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurMERC_CONV_SIN_EXP";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Tipo"].ToString().ToUpper() == "SOBRE")
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "7B_Merc Conv Sin Expedicion";
                            dttemp2.TableName = "7A_Merc Conv Sin Expedicion";
                            ds.Tables.Add(dttemp2);
                            ds.Tables.Add(dttemp);
                            procExito = true;
                        }

                        break;

                    case "8":
                        // 8_Ensobretado Doc Expedicion
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_ENSOBRENTADO_DOC_EXP";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurENSOBRENTADO_DOC_EXP";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Tipo"].ToString().ToUpper() == "SOBRE")
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "8B_Ensobretado Doc Expedicion";
                            dttemp2.TableName = "8A_Ensobretado Doc Expedicion";
                            ds.Tables.Add(dttemp2);
                            ds.Tables.Add(dttemp);
                            procExito = true;
                        }

                        break;

                    case "9":
                        // 9_Trans Doc Conv a Control Doc
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_TRA_DOC_CONV_CRTL_DOC ";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurDOC_CONV_A_CRTL";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "9_Trans Doc Conv a Control Doc";
                            ds.Tables.Add(dt);
                            procExito = true;
                        }

                        break;

                    case "10":
                        // 10_Merc Traslados por recibir
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_TRAS_POR_RECIBIR";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "P_DAT_MERC_TRAS_POR_RECIBIR";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "10_Trans Doc Conv a Control Doc";
                            ds.Tables.Add(dt);
                            procExito = true;
                        }
                   
                        break;

                    case "11":
                        // 11_Merc_Conv_por_cerrar
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_CONV_POR_CERRAR";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurCONV_POR_CERRAR ";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "11_Merc_Conv_por_cerrar";
                            ds.Tables.Add(dt);
                            procExito = true;
                        }

                        break;

                    case "12":
                        // 12_Merc_Conv_por_imprimir
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_CONV_POR_IMPRIM";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurCONV_POR_IMPRIM";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "12_Merc_Conv_por_imprimir";
                            ds.Tables.Add(dt);
                            procExito = true;
                        }

                        break;

                    default:
                        procExito = true;

                        // 1A_Merc Scan Entrada Cliente
                        // 1B_Merc Scan Entrada Cliente
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_SCAN_ENTRA_CLI_A";
                        par_st[5, 2] = "p_CurSCAN_ENTRA_CLI_1A";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));
                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "1A_Merc Scan Entrada Cliente";
                            ds.Tables.Add(dt);

                            datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_SCAN_ENTRA_CLI_B";
                            par_st[5, 2] = "p_CurSCAN_ENTRA_CLI_1B";
                            datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                            if (datos_sp.codigo == "1")
                            {
                                dt = datos_sp.tb.Copy();
                                dt.TableName = "1B_Merc Scan Entrada Cliente";
                                ds.Tables.Add(dt);

                            }  else { procExito = false;  break; }
                        } else { procExito = false; break; }

                        // 2_Merc Sin Datos Logistico 
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_SIN_DAT_LOGISTICO";
                        par_st[5, 2] = "p_CurSIN_DAT_LOGISTICO";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "2_Merc Sin Datos Logistico";
                            ds.Tables.Add(dt);
                        } else { procExito = false; break; }

                        // 3_Merc Sin Convertidor
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_SIN_CONVERTIDOR";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurSIN_CONVERTIDOR";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "CROSSDOCK NORMAL")
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "3A_Merc Sin Convertidor";
                            dttemp2.TableName = "3B_Merc Sin Convertidor";
                            ds.Tables.Add(dttemp);
                            ds.Tables.Add(dttemp2);
                        } else { procExito = false; break; }

                        // 4_Transf Doc a Control Doc
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_TRANSF_DOC_A_CTRL_DOC";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurDOC_A_CTRL_DOC";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.Columns.RemoveAt(dt.Columns.Count - 1);
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();
                            dttemp3 = dt.Clone();
                            dttemp4 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if ((dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "CROSSDOCK NORMAL")
                                        && dt.Rows[i]["Cedis"].ToString().ToUpper() == "TLN" && (Convert.ToInt64(dt.Rows[i]["N°"].ToString()) >= 10000 || Convert.ToInt64(dt.Rows[i]["N°"].ToString()) < 9900))
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else if ((dt.Rows[i]["Tipo operacion"].ToString().ToUpper() != "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() != "CROSSDOCK NORMAL")
                                        && dt.Rows[i]["Cedis"].ToString().ToUpper() == "TLN" && (Convert.ToInt64(dt.Rows[i]["N°"].ToString()) >= 10000 || Convert.ToInt64(dt.Rows[i]["N°"].ToString()) < 9900))
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                                else if (Convert.ToInt64(dt.Rows[i]["N°"].ToString()) >= 9900 || Convert.ToInt64(dt.Rows[i]["N°"].ToString()) <= 9999)
                                {
                                    dttemp3.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp4.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "4A_Transf Doc a Control Doc";
                            dttemp2.TableName = "4B_Transf Doc a Control Doc";
                            dttemp3.TableName = "4C_Transf Doc a Control Doc";
                            dttemp4.TableName = "4D_Transf Doc a Control Doc";
                            ds.Tables.Add(dttemp);
                            ds.Tables.Add(dttemp2);
                            ds.Tables.Add(dttemp3);
                            ds.Tables.Add(dttemp4);
                        } else { procExito = false; break; }

                        // 5_Merc Conv No Validado
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_CONV_NO_VALIDADO";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurCONV_NO_VALIDADO";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));
                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "5_Merc Conv No Validado";
                            ds.Tables.Add(dt);
                        } else { procExito = false; break; }

                        // 6_Armado Doc Manif Convertidor
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_ARMADO_DOC_MANIF_CONV ";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurDOC_MANIF_CONV";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();
                            dttemp3 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if ((dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() == "CROSSDOCK NORMAL")
                                        && (Convert.ToInt64(dt.Rows[i]["N° Cliente"].ToString()) >= 10000 || Convert.ToInt64(dt.Rows[i]["N° Cliente"].ToString()) < 9900))
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else if ((dt.Rows[i]["Tipo operacion"].ToString().ToUpper() != "LTL" || dt.Rows[i]["Tipo operacion"].ToString().ToUpper() != "CROSSDOCK NORMAL")
                                        && (Convert.ToInt64(dt.Rows[i]["N° Cliente"].ToString()) >= 10000 || Convert.ToInt64(dt.Rows[i]["N° Cliente"].ToString()) < 9900))
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp3.ImportRow(dt.Rows[i]);
                                }
                            } 

                            dttemp.TableName = "6A_Armado Doc Manif Convertidor";
                            dttemp2.TableName = "6B_Armado Doc Manif Convertidor";
                            dttemp3.TableName = "6C_Armado Doc Manif Convertidor";
                            ds.Tables.Add(dttemp);
                            ds.Tables.Add(dttemp2);
                            ds.Tables.Add(dttemp3);
                        } else { procExito = false; break; }

                        // 7_Merc Conv Sin Expedicion
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_CONV_SIN_EXP";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurMERC_CONV_SIN_EXP";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Tipo"].ToString().ToUpper() == "SOBRE")
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "7B_Merc Conv Sin Expedicion";
                            dttemp2.TableName = "7A_Merc Conv Sin Expedicion";
                            ds.Tables.Add(dttemp2);
                            ds.Tables.Add(dttemp);
                        } else { procExito = false; break; }

                        // 8_Ensobretado Doc Expedicion
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_ENSOBRENTADO_DOC_EXP";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurENSOBRENTADO_DOC_EXP";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dttemp = dt.Clone();
                            dttemp2 = dt.Clone();

                            for (int i = 0; i < dt.Rows.Count; i++)
                            {
                                if (dt.Rows[i]["Tipo"].ToString().ToUpper() == "SOBRE")
                                {
                                    dttemp.ImportRow(dt.Rows[i]);
                                }
                                else
                                {
                                    dttemp2.ImportRow(dt.Rows[i]);
                                }
                            }

                            dttemp.TableName = "8B_Ensobretado Doc Expedicion";
                            dttemp2.TableName = "8A_Ensobretado Doc Expedicion";
                            ds.Tables.Add(dttemp2);
                            ds.Tables.Add(dttemp);
                        } else { procExito = false; break; }

                        // 9_Trans Doc Conv a Control Doc
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_TRA_DOC_CONV_CRTL_DOC ";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurDOC_CONV_A_CRTL";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "9_Trans Doc Conv a Control Doc";
                            ds.Tables.Add(dt);
                        } else { procExito = false; break; }

                        // 10_Merc Traslados por recibir
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_TRAS_POR_RECIBIR";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurTRASPOR_RECIBIR";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "10_Trans Doc Conv a Control Doc";
                            ds.Tables.Add(dt);
                        } else { procExito = false; break; }

                        // 11_Merc_Conv_por_cerrar
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_CONV_POR_CERRAR";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurCONV_POR_CERRAR";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "11_Merc_Conv_por_cerrar";
                            ds.Tables.Add(dt);
                        } else { procExito = false; break; } 

                        // 12_Merc_Conv_por_imprimir
                        datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_DOC_LTL_PEND_SCAN.P_DAT_MERC_CONV_POR_IMPRIM";
                        par_st[0, 1] = "N/A";
                        par_st[2, 1] = "N/A";
                        par_st[5, 2] = "p_CurCONV_POR_IMPRIM";
                        datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                        if (datos_sp.codigo == "1")
                        {
                            dt = datos_sp.tb.Copy();
                            dt.TableName = "12_Merc_Conv_por_imprimir";
                            ds.Tables.Add(dt);
                        }
                        else { procExito = false; }
                        
                        break;
                }

                arch = procExito ? xlsx.CreateExcel_file(ds, null,  arch + ".xlsx", Carpeta) : arch;

            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
            }
            finally
            {
                inf.arch = arch;
                inf.LisDT = null;
                inf.LisDT_tit = null;
            }

            return inf;
        }
    }
}