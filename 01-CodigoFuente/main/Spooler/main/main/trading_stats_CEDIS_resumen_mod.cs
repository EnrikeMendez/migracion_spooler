using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using DocumentFormat.OpenXml.Drawing;
using System.Xml.Serialization;

namespace serverreports
{
    internal class trading_stats_CEDIS_resumen_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) stats_cedis_resumen(string Carpeta, string[,] file_name, string[,] pargral, string fecha_ini, string fecha_fin, string? clienteIn, string? clienteOut, string? cedis)
        {
            DM DM = new DM();
            Excel xlsx = new Excel();
            Utilerias util = new Utilerias();
            DataSet ds = new DataSet();
            DataSet ds2 = new DataSet();
            DataTable dt = new DataTable();
            DataTable dtemp = new DataTable();
            DataTable dtRes = new DataTable();

            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string arch = file_name[0, 0];
            string[,] par_st;
            string sql = "";
            decimal sumCampo;
            string porcen;
            bool procExito = false;
            string[] tipoTabla;
            string[,] tablesInSheet;
            string[,] estilos;
            tipoTabla = new string[4];
            tablesInSheet = new string[4,4];
            estilos = new string[1,2];

            tipoTabla[0] = "On_Time_Entregas";
            tipoTabla[1] = "Incidencias_Rechazos";
            tipoTabla[2] = "Captura_Fechas";
            tipoTabla[3] = "Envio_Evidencias";

            par_st = new string[9, 4];
            //par_st = new string[4, 4];


            
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_FECHA_INICIO";
            par_st[0, 3] = fecha_ini;

            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_FECHA_FINAL";
            par_st[1, 3] = fecha_fin;

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_CLIENTE_IN";
            par_st[2, 3] = clienteIn;

            par_st[3, 0] = "i";
            par_st[3, 1] = "v";
            par_st[3, 2] = "p_CLIENTE_OUT";
            par_st[3, 3] = clienteOut;

            par_st[4, 0] = "i";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_CEDIS";
            par_st[4, 3] = cedis;

            par_st[5, 0] = "i";
            par_st[5, 1] = "v";
            par_st[5, 2] = "p_TIPO_DATO";
            par_st[5, 3] = "";

            par_st[6, 0] = "o";
            par_st[6, 1] = "c";
            par_st[6, 2] = "p_CurResumenCEDIS";

            par_st[7, 0] = "o";
            par_st[7, 1] = "v";
            par_st[7, 2] = "p_MENSAJE";
            par_st[7, 3] = "msg";

            par_st[8, 0] = "o";
            par_st[8, 1] = "i";
            par_st[8, 2] = "p_CODIGO_ERROR";
            par_st[8, 3] = "cod";
            
            procExito = false;

            try
            {
                for (int i = 0; i < tipoTabla.GetLength(0); i++)
                {
                    datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_EST_ENTR_CEDIS_RES.P_DAT_RESUMEN_CEDIS";
                    par_st[5, 3] = tipoTabla[i].ToString();
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                    if (datos_sp.codigo == "1")
                    {
                        dt = datos_sp.tb.Copy();

                        DataView view = new DataView(dt);
                        DataTable dtTipos = view.ToTable(true, "cedis");

                        for (int j = 0; j < dtTipos.Rows.Count; j++)
                        {
                            sumCampo = 0;
                            porcen = "";
                            DataRow[] reg = dt.Select("cedis = " + "'" + dtTipos.Rows[j]["cedis"].ToString() + "'");
                            DataTable xs = reg.CopyToDataTable();

                            xs = util.Tdetalle_regtot(xs, 2, 0, 1, 0, 0); //Sumatoria de la tabla

                            //Calculo de porcentajes
                            switch (tipoTabla[i].ToString())
                            {
                                case "On_Time_Entregas":
                                    porcen = ((Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["On Time"]) / Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Cdad Facturas"])) * 100).ToString("N2");
                                    xs.Rows[xs.Rows.Count - 1]["%"] = porcen + "%";

                                    porcen = "";
                                    porcen = ((Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["On Time1"]) / Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Cdad Facturas"])) * 100).ToString("N2");
                                    xs.Rows[xs.Rows.Count - 1]["%1"] = porcen + "%";


                                    xs.Columns["On Time1"].ColumnName = "On Time ";
                                    xs.Columns["Off Time1"].ColumnName = "Off Time ";
                                    xs.Columns["vacio1"].ColumnName = "Vacio ";
                                    xs.Columns["%1"].ColumnName = "% ";

                                    break;
                                case "Incidencias_Rechazos":
                                    sumCampo = Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Rechazo TOTAL"]) + Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Rechazo Parcial"]) + Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Entrega Incompleta"]) + Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["No entregado"]);
                                    porcen = ((sumCampo / Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Cdad Facturas"])) * 100).ToString("N2");
                                    xs.Rows[xs.Rows.Count - 1]["% Incidencias"] = porcen + "%";

                                    sumCampo = (Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Rechazo TOTAL"]) + Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Rechazo Parcial"])) - Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Vacio"]);
                                    porcen = (sumCampo == 0 ? "n/a" : ((Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Dia sig <12h"]) / sumCampo) * 100).ToString("N2") + "%");
                                    xs.Rows[xs.Rows.Count - 1]["%"] = porcen;

                                    sumCampo =  (Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Rechazo TOTAL"]) + Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Rechazo Parcial"])) - Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Vacio1"]);
                                    porcen = (sumCampo == 0 ? "n/a" : ((Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["On Time"]) / sumCampo) * 100).ToString("N2") + "%");
                                    xs.Rows[xs.Rows.Count - 1]["%1"] = porcen;

                                    xs.Columns["vacio1"].ColumnName = "Vacio ";
                                    xs.Columns["%1"].ColumnName = "% ";

                                    break;
                                case "Captura_Fechas":
                                    porcen = ((Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Mismo Dia"]) / Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Cdad Facturas"])) * 100).ToString("N2");
                                    xs.Rows[xs.Rows.Count - 1]["%"] = porcen + "%";

                                    sumCampo = Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Mismo Dia1"]) + Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Dia sig <12h"]);
                                    porcen = ((sumCampo / Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Cdad Facturas"])) * 100).ToString("N2");
                                    xs.Rows[xs.Rows.Count - 1]["%1"] = porcen + "%";

                                    porcen = ((Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Mismo Dia2"]) / Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Cdad Facturas"])) * 100).ToString("N2");
                                    xs.Rows[xs.Rows.Count - 1]["%2"] = porcen + "%";

                                    xs.Columns["Mismo dia1"].ColumnName = "Mismo día ";
                                    xs.Columns["Otro dia1"].ColumnName = "Otro día ";
                                    xs.Columns["vacio1"].ColumnName = "Vacio ";
                                    xs.Columns["%1"].ColumnName = "% ";
                                    xs.Columns["Mismo dia2"].ColumnName = "Mismo día  ";
                                    xs.Columns["Otro dia2"].ColumnName = "Otro día  ";
                                    xs.Columns["vacio2"].ColumnName = "Vacio  ";
                                    xs.Columns["%2"].ColumnName = "%  ";

                                    break;
                                case "Envio_Evidencias":
                                    sumCampo = Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["Cdad Facturas"]) - Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["n/a"]);
                                    porcen = (sumCampo == 0 ? "n/a" : ((Convert.ToDecimal(xs.Rows[xs.Rows.Count - 1]["<24h"]) / sumCampo) * 100).ToString("N2") + "%");
                                    xs.Rows[xs.Rows.Count - 1]["%"] = porcen;

                                    break;

                                default:

                                    break;
                            }

                            xs = util.convDataTypeString(xs);

                            for (int k = 0; k < xs.Columns.Count; k++)
                            {
                                xs.Rows[xs.Rows.Count - 1][k] = xs.Rows[xs.Rows.Count - 1][k].ToString() + "|#DAF7A6";
                            }

                            dtemp.Merge(xs);

                        }
                        dtRes = dtemp.Copy();


                        dtRes.TableName = tipoTabla[i].ToString().Replace("_"," ");
                        ds.Tables.Add(dtRes);
                        dtemp.Reset();
                        procExito = true;
                    }
                    else { procExito = false; break; }
                }

                tablesInSheet[0, 0] = "Resumen Cedis"; //Hoja 
                tablesInSheet[0, 1] = "On Time Entregas"; // Nombre de la tabla
                tablesInSheet[0, 2] = "S|#FAAF22"; // Union de celdas     S = colocar arriba de los encabezados originales, poner color(opcional) a encabezados originales, si no se quiere colocar arriba de los encabezados poner N
                tablesInSheet[0, 3] = "A-B-On Time Entregas|I-L-On Time Interno-#FAAF22|M-P-On Time Cliente-#FAAF22"; // RangoIni - RangoFin - Titulo de celda combinada - Color

                tablesInSheet[1, 0] = "Resumen Cedis";
                tablesInSheet[1, 1] = "Incidencias Rechazos";
                tablesInSheet[1, 2] = "S|#FAAF22";
                tablesInSheet[1, 3] = "A-B-Incidencias y rechazos|E-I-Incidencias-#FAAF22|J-M-Entrada Rechazo-#FAAF22|N-Q-Entrada Rechazo Cedis Ori-#FAAF22";

                tablesInSheet[2, 0] = "Resumen Cedis";
                tablesInSheet[2, 1] = "Captura Fechas";
                tablesInSheet[2, 2] = "S|#FAAF22";
                tablesInSheet[2, 3] = "A-B-Captura Fechas|E-H-Captura Fecha Entrega-#FAAF22|I-M-Entrega Evidencia-#FAAF22|N-Q-Captura Entrega Evidencia-#FAAF22";

                tablesInSheet[3, 0] = "Resumen Cedis";
                tablesInSheet[3, 1] = "Envio Evidencias";
                tablesInSheet[3, 2] = "S|#FAAF22";
                tablesInSheet[3, 3] = "A-B-Envio Evidencias|E-K-Envio Evidencia-#FAAF22";

                estilos[0, 0] = "Resumen Cedis"; //Hoja en la que se pondra color a los campos
                estilos[0, 1] = ""; // Columna en la que va el color, si son todas las columnas dejar vacio

                arch = procExito ? xlsx.CreateExcel_file_Style(ds, null, arch + ".xlsx", Carpeta,estilos, tablesInSheet) : arch;
                //arch = procExito ? xlsx.CreateExcel_file_test(ds, null, arch + ".xlsx", Carpeta, tablesInSheet) : arch;

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
