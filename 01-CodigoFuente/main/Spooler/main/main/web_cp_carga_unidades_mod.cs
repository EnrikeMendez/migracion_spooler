using DocumentFormat.OpenXml.Drawing.Spreadsheet;
using DocumentFormat.OpenXml.Office2021.Excel.Pivot;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Net.WebRequestMethods;

namespace serverreports
{
    internal class web_cp_carga_unidades_mod
    {
        public (string[,] LisDT_tit, DataTable[] LisDT, string arch) carta_porte_carga_unidades(string Carpeta, string[,] file_name, string[,] pargral, string fecha_ini, string fecha_fin, string cedis, string? tipoReporte, string? nuevasColumns)
        {

            DM DM = new DM();
            Excel xlsx = new Excel();
            Utilerias util = new Utilerias();
            DataSet ds = new DataSet();
            DataTable dt = new DataTable();

            (string? codigo, string? msg, string? sql, DataTable? tb) datos_sp;
            (string[,] LisDT_tit, DataTable[] LisDT, string arch) inf;
            string arch = file_name[0, 0];
            string[,] par_st;
            string[,] estilos;
            bool procExito = false;
            int index = 0;
            int indEnd = 0;

            par_st = new string[6, 4];
            estilos = new string[3, 4];
           
            par_st[0, 0] = "i";
            par_st[0, 1] = "v";
            par_st[0, 2] = "p_CEDIS";
            par_st[0, 3] = cedis;
            
            par_st[1, 0] = "i";
            par_st[1, 1] = "v";
            par_st[1, 2] = "p_FECHA_INICIO";
            par_st[1, 3] = fecha_ini + " 07:00";

            par_st[2, 0] = "i";
            par_st[2, 1] = "v";
            par_st[2, 2] = "p_FECHA_FINAL";
            par_st[2, 3] = fecha_fin + " 07:00";

            par_st[3, 0] = "o";
            par_st[3, 1] = "c";
            par_st[3, 2] = "p_CurPARAMETROS_OPT";

            par_st[4, 0] = "o";
            par_st[4, 1] = "v";
            par_st[4, 2] = "p_MENSAJE";
            par_st[4, 3] = "msg";

            par_st[5, 0] = "o";
            par_st[5, 1] = "i";
            par_st[5, 2] = "p_CODIGO_ERROR";
            par_st[5, 3] = "cod";

            try
            {           
                datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_PORTEOS_PESOS_VOL.P_DAT_PARAMETROS_OPT";
                par_st[0, 1] = "N/A";
                par_st[1, 1] = "N/A";
                par_st[2, 1] = "N/A";
                datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                if (datos_sp.codigo == "1")
                {
                    dt = datos_sp.tb.Copy();
                    dt.TableName = "Parametros de Optimizacion";
                    ds.Tables.Add(dt);
                    procExito = true;
                } else { procExito = false; }
                
                if (procExito)
                {
                    datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_PORTEOS_PESOS_VOL.P_DAT_RESUMEN";
                    par_st[0, 1] = "v";
                    par_st[1, 1] = "v";
                    par_st[2, 1] = "v";
                    par_st[3, 2] = "p_CurRESUMEN";
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                    if (datos_sp.codigo == "1")
                    {
                        dt = datos_sp.tb.Copy();
                        dt.TableName = "Resumen 2";

                        DataTable dttemp2 = new DataTable();

                        dttemp2 = util.convDataTypeString(dt);

                        for (int i = 0; i < dt.Rows.Count; i++)
                        {
                            dttemp2.Rows[i+i]["Total Imp."] = dttemp2.Rows[i+i]["Total Imp."] + "|#ffb32d";
                            dttemp2.Rows[i+i]["Total cdad."] = dttemp2.Rows[i+i]["Total cdad."] + "|#ffb32d";
                            dttemp2.Rows[i+i]["Total Peso"] = dttemp2.Rows[i+i]["Total Peso"] + "|#ffb32d";
                            dttemp2.Rows[i+i]["Total Vol."] = dttemp2.Rows[i+i]["Total Vol."] + "|#ffb32d";
                            
                            DataRow rowAdd = dttemp2.NewRow();
                            rowAdd[dt.Columns[0].ColumnName.ToString()] = " ";
                            dttemp2.Rows.InsertAt(rowAdd, (i * 2) + 1);
                            dttemp2.AcceptChanges();
                        }

                        dt.Reset();
                        dt.Merge(dttemp2);

                        ds.Tables.Add(dt);
                    } else { procExito = false; }
                }

                if (procExito)
                {
                    datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_PORTEOS_PESOS_VOL.P_DAT_RES_ORDEN_DIST";
                    par_st[3, 2] = "p_CurRES_ORDEN_DIST";
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));
                    
                    if (datos_sp.codigo == "1")
                    {
                        dt = datos_sp.tb.Copy();
                        dt.Columns["Tipo Unidad"].ColumnName = "Tipo_Unidad";
                        dt.Columns.RemoveAt(dt.Columns.Count - 1);
                        DataView view = new DataView(dt);
                        DataTable dtTipos = view.ToTable(true, "Tipo_Unidad");

                        if (dtTipos.Rows.Count > 1) { 
                            DataTable dTemp = new DataTable();
                            DataTable dRes = new DataTable();

                            List<string> lsTitColum = new List<string>();

                            foreach (DataColumn dr in dt.Columns)
                            {
                                lsTitColum.Add(dr.ColumnName.ToString());
                            }

                            for (int i = 0; i < dtTipos.Rows.Count; i++)
                            {
                                DataRow[] reg = dt.Select("Tipo_Unidad = " + "'" + dtTipos.Rows[i]["Tipo_Unidad"].ToString().Replace("'","''") + "'");
                                DataTable xs = reg.CopyToDataTable();

                                dTemp = util.convDataTypeString(xs);

                                if (i != dtTipos.Rows.Count - 1) { 
                                    dTemp.Rows.Add();
                                    dTemp.Rows.Add();
                                    for (int j = 0; j < lsTitColum.Count; j++)
                                    {
                                        dTemp.Rows[dTemp.Rows.Count - 1][lsTitColum[j]] = (lsTitColum[j] == "Tipo_Unidad" ? "Tipo Unidad": lsTitColum[j]);
                                    }
                                }
                                dRes.Merge(dTemp);
                            }

                            dt = dRes.Copy();
                            dTemp.Clear();
                            dTemp.Reset();
                            dRes.Clear();
                            dRes.Reset();
                        }

                        index = dt.Columns.IndexOf("Caja") + 1 ;
                        indEnd = dt.Columns.IndexOf("Fecha/Hora Validacion exp");
                        dt = util.Tdetalle_regtot(dt, index, 0, 1, 0, 0); //Sumatoria de la tabla


                        dt = util.convDataTypeString(dt);

                        for (int i= index; i < dt.Columns.Count; i++)
                        {
                            dt.Rows[dt.Rows.Count - 1][i] = i >= indEnd ? " " : dt.Rows[dt.Rows.Count - 1][i] + "|#fff9a3";
                        }

                        dt.Columns["Tipo_Unidad"].ColumnName = "Tipo Unidad";
                        dt.TableName = "Resumen-Orden Distribución";
                        ds.Tables.Add(dt);
                    }
                    else { procExito = false; }
                }

                if (procExito)
                {
                    datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_PORTEOS_PESOS_VOL.P_DAT_RES_CONVERTIDOR";
                    par_st[3, 2] = "p_CurRES_CONVERTIDOR";
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                    if (datos_sp.codigo == "1")
                    {
                        dt = datos_sp.tb.Copy();
                        dt.TableName = "Hoja Resumen Convertidor";
                        ds.Tables.Add(dt);
                    }
                    else { procExito = false; }
                }

                if (procExito)
                {
                    datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_PORTEOS_PESOS_VOL.P_DAT_RES_EMBARQUES";
                    par_st[3, 2] = "p_CurRES_EMBARQUES";
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                    if (datos_sp.codigo == "1")
                    {
                        dt = datos_sp.tb.Copy();
                        dt.TableName = "Resumen Embarques";
                        ds.Tables.Add(dt);
                    }
                    else { procExito = false; }
                }

                if (procExito)
                {
                    datos_sp.sql = "SC_RS_DIST.SPG_RS_DIST_PORTEOS_PESOS_VOL.P_DAT_DETALLE";
                    par_st[3, 2] = "p_CurDETALLE";
                    datos_sp = DM.datos_sp([datos_sp.sql], par_st, Convert.ToInt32(pargral[13, 1]));

                    if (datos_sp.codigo == "1")
                    {
                        dt = datos_sp.tb.Copy();
                        dt.TableName = "Detalle_" + (fecha_ini == fecha_fin ? fecha_ini.Replace("/", "-") : (fecha_ini.Replace("/", "-") + "_al_" + fecha_fin.Replace("/", "-")).Substring(0,23));
                            
                           
                        ds.Tables.Add(dt);
                    }
                    else { procExito = false; }
                }

                estilos[0, 0] = "Resumen-Orden Distribución"; //// Hoja en la que se va aponer estilos (Obligatorio)
                estilos[0, 1] = "Peso|Volumen|Peso (sin insumos)|Volumen (sin insumos)|Peso volumetrico|Base calculo|IMPORTE|Valor Flete|$ Flete / Kg";   //// Columnas en las que se va poner estilos (Obligatorio)
                estilos[0, 2] = "Tipo Unidad";   //// Identificador si es que en la misma hoja va más de una tabla (opcional) 
                estilos[0, 3] = ""; ////Borra Encabezados, se remplaza por la fila 2 (Opcional)

                estilos[1, 0] = "Resumen 2";
                estilos[1, 1] = "Total Imp.|Total cdad.|Total Peso|Total Vol.";   
                estilos[1, 2] = "";
                estilos[1, 3] = "";

                estilos[2, 0] = "Parametros de Optimizacion";
                estilos[2, 1] = "Objetivos|Volumen (m3) R|Peso (TON) R|Volumen (m3) N|Peso (TON) N|Volumen (m3) V|Peso (TON) V";
                estilos[2, 2] = "";
                estilos[2, 3] = "S"; 

                arch = procExito ? xlsx.CreateExcel_file_Style(ds, null, arch + ".xlsx", Carpeta, estilos) : arch;

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
