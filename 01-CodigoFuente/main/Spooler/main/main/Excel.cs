using SpreadsheetLight;
using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DocumentFormat.OpenXml.Spreadsheet;
using ClosedXML.Excel;
using SpreadsheetLight.Charts;
using DocumentFormat.OpenXml.Bibliography;
using DocumentFormat.OpenXml.Wordprocessing;
using DocumentFormat.OpenXml.Drawing.Diagrams;

namespace serverreports
{
    internal class Excel
    {
        public string CrearExcel_file(DataTable[] LisDT, string[] tit, string name, int? del_col = null)
        {
            using (var workbook = new XLWorkbook())
            {
                try
                {
                    for (int i = 0; i < LisDT.Length; i++)
                    {
                        if (LisDT[i] != null)
                        {
                            var hoja = workbook.Worksheets.Add(tit[i]);
                            var table = hoja.Cell("A1").InsertTable(LisDT[i]);

                            table.ShowAutoFilter = false;
                            table.Theme = XLTableTheme.None;

                            if (del_col != null)
                            {
                                table.Column((int)del_col).Delete();
                            }
                            table.Style = estilo_bosch1(hoja.Style, "d");

                            var rango = table.Row(1);
                            rango.Style = estilo_bosch1(rango.Style, "e");
                            hoja.Columns().AdjustToContents();
                        }
                    }

                    workbook.SaveAs(name + ".xlsx");
                    Console.WriteLine("Se genero Archivo " + name);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
                }
                return name + ".xlsx";
            }
        }

        public IXLStyle estilo_bosch1(IXLStyle hoja, string tp)
        {
            hoja.Font.SetBold(true);
            hoja.Font.FontSize = 8;
            hoja.Font.FontName = "Arial";
            hoja.Alignment.Horizontal = XLAlignmentHorizontalValues.Center; //Alineamos horizontalmente
            hoja.Alignment.Vertical = XLAlignmentVerticalValues.Center;
            hoja.Fill.BackgroundColor = XLColor.White;
            hoja.Font.FontColor = XLColor.Black;
            if (tp.ToUpper() == "E")
            {
                hoja.Fill.BackgroundColor = XLColor.Black;
                hoja.Font.FontColor = XLColor.White;
            }
            return hoja;
        }

        public void grafica()
        {
            /* using SpreadsheetLight;*/
            SLDocument sl = new SLDocument();
            sl.SetCellValue("C2", "Enero");
            sl.SetCellValue("D2", "Febrero");
            sl.SetCellValue("E2", "Marzo");
            sl.SetCellValue("F2", "Abril");
            sl.SetCellValue("G2", "Mayo");
            sl.SetCellValue("B3", "North");
            sl.SetCellValue("B4", "South");
            sl.SetCellValue("B5", "East");
            sl.SetCellValue("B6", "West");

            sl.SetCellValue("C7", "Enero");
            sl.SetCellValue("D7", "Febrero");
            sl.SetCellValue("E7", "Marzo");
            sl.SetCellValue("F7", "Abril");
            sl.SetCellValue("C8", 10);
            sl.SetCellValue("D8", 43);
            sl.SetCellValue("E8", 23);
            sl.SetCellValue("F8", 98);

            Random rand = new Random();
            for (int i = 3; i <= 6; ++i)
            {
                for (int j = 3; j <= 7; ++j)
                {
                    sl.SetCellValue(i, j, 9000 * rand.NextDouble() + 1000);
                }
            }
            double fChartHeight = 15.0;
            double fChartWidth = 7.5;
            SLChart chart;
            /*
            chart = sl.CreateChart("B2", "G6");
            chart.SetChartType(SLBarChartType.ClusteredBar);
            chart.SetChartPosition(1, 9, 1 + fChartHeight, 9 + fChartWidth);
            sl.InsertChart(chart);

            chart = sl.CreateChart("B2", "G6");
            chart.SetChartType(SLBarChartType.StackedHorizontalPyramidMax);
            chart.SetChartStyle(SLChartStyle.Style1);
            chart.SetChartPosition(7, 1, 7 + fChartHeight, 1 + fChartWidth);
            sl.InsertChart(chart);

            chart = sl.CreateChart("B2", "G6");
            chart.SetChartType(SLBarChartType.StackedHorizontalCylinder);
            chart.SetChartStyle(SLChartStyle.Style26);
            chart.SetChartPosition(16, 9, 16 + fChartHeight, 9 + fChartWidth);
            sl.InsertChart(chart);

            sl.SaveAs("ChartsBar.xlsx");
            */
            chart = sl.CreateChart("B2", "G6");
            chart.SetChartType(SLColumnChartType.ClusteredColumn);
            //chart.SetChartPosition(1, 9, 1 + fChartHeight, 9 + fChartWidth);
            chart.SetChartPosition(8, 1, 8 + fChartHeight, fChartWidth);
            sl.InsertChart(chart);
            /*
            chart = sl.CreateChart("B2", "G6");
            chart.SetChartType(SLColumnChartType.StackedCylinderMax);
            chart.SetChartStyle(SLChartStyle.Style4);
            chart.SetChartPosition(7, 1, 7 + fChartHeight, 1 + fChartWidth);
            sl.InsertChart(chart);
            
            chart = sl.CreateChart("B2", "G6");
            chart.SetChartType(SLColumnChartType.Pyramid3D);
            chart.SetChartStyle(SLChartStyle.Style47);
            chart.SetChartPosition(16, 9, 16 + fChartHeight, 9 + fChartWidth);
            sl.InsertChart(chart);
            */


            /*
            chart = sl.CreateChart("B2", "G6");
            chart.SetChartType(SLPieChartType.Pie);
            chart.SetChartPosition(1, 9, 1 + fChartHeight, 9 + fChartWidth);
            sl.InsertChart(chart);

            chart = sl.CreateChart("B2", "G6");
            chart.SetChartType(SLPieChartType.PieOfPie);
            chart.SetChartStyle(SLChartStyle.Style24);
            chart.SetChartPosition(7, 1, 7 + fChartHeight, 1 + fChartWidth);
            sl.InsertChart(chart);
            */
            chart = sl.CreateChart("B7", "F8");
            //chart = sl.CreateChart(2, 3, 3, 6);
            chart.SetChartType(SLPieChartType.ExplodedPie3D);
            chart.SetChartStyle(SLChartStyle.Style10);
            chart.SetChartPosition(16, 9, 16 + fChartHeight, 9 + fChartWidth);

            sl.InsertChart(chart);

            sl.SaveAs("Grafica.xlsx");
            Console.WriteLine("Grafica");
        }


        public string CrearExcel_filen(DataTable[] LisDT, string[,] tit, string? name = "", int? del_col = null, int? fre_row = null, int? posinitablav = 1, int? espaciov = 0, int? graf = 0, int? graf_ran_row_neg = 0)
        {
            string archivo = "";
            int del;
            string hoja = "";
            SLDocument sl = new SLDocument();
            int posinitabla = (int)(posinitablav);
            int espacio = (int)(espaciov);
            int col = 0;
            int row = 0;
            int rowg = 0;
            string enc_h = "";
            string enc_hh = "";
            string enc_ht = "";
            string enc_hg = "";
            string det_alig = "";
            String[] enc;
            String[] vert;
            try
            {
                int pos = 1;
                for (int i = 0; i < LisDT.Length; i++)
                {
                    if (LisDT[i] != null)
                    {
                        enc_h = "";
                        enc_hh = "";
                        enc_ht = "";
                        enc_hg = "";
                        det_alig = "";
                        /*
                        enc = tit[i, 0].Split("|");
                        enc_h = enc[0];
                        row = LisDT[i].Rows.Count;
                        if (enc.Length > 1)
                        {
                            enc_hh = enc[1];
                        }
                        */
                        if (tit[i, 0] == null)
                        {
                            enc = new string[1];
                            enc[0] = "NA";
                        }
                        else
                            enc = tit[i, 0].Split("|");
                        enc_h = enc[0];
                        row = LisDT[i].Rows.Count;
                        if (enc.Length > 1)
                        {
                            switch (enc.Length)
                            {
                                case 2:
                                    enc_hh = enc[1]; //encabezado de hoja                                    
                                    break;
                                case 3:
                                    enc_hh = enc[1]; //encabezado de hoja
                                    enc_ht = enc[2];//encabezado de tablas                                   
                                    break;
                                case 4:
                                    enc_hh = enc[1]; //encabezado de hoja
                                    enc_ht = enc[2];//encabezado de tablas                                   
                                    enc_hg = enc[3];//encabezado de grafica
                                    break;
                                case 5:
                                    enc_hh = enc[1]; //encabezado de hoja
                                    enc_ht = enc[2];//encabezado de tablas                                   
                                    enc_hg = enc[3];//encabezado de grafica
                                    //det_ft = enc[4];//encabezado de grafica
                                    det_alig = enc[4];//encabezado de grafica
                                    break;

                            }
                        }

                        if (hoja == enc_h)
                            pos = (int)(pos + col + espacio);
                        else
                            pos = 1;
                        col = LisDT[i].Columns.Count;

                        if (i == 0) sl.RenameWorksheet("Sheet1", enc_h);
                        else sl.AddWorksheet(enc_h);

                        if (LisDT[i].Rows.Count == 0)
                        {
                            DataTable dt = new DataTable();
                            if (enc_ht == "") dt.Rows.Add("Sin Inf."); else dt.Rows.Add(enc_ht);//
                            dt.Rows.Add("Sin Inf.");
                            LisDT[i] = dt;
                            col = LisDT[i].Columns.Count;
                        }
                        //Vertical
                        // if (tit[i,0] == "Resumen")
                        if (tit[i, 1] != null)
                        {
                            /*
                            pos = 1;
                            posinitabla = 1;
                           if ((i == 0) )       
                            posinitabla = posinitabla + LisDT[i - 1].Rows.Count + espacio;
                            */
                            vert = tit[i, 1].Split("|");
                            pos = int.Parse(vert[0]);
                            if ((i == 0))
                            {
                                //posinitabla =1 ;
                                posinitabla = int.Parse(vert[1]);
                                pos = pos;
                                espacio = int.Parse(vert[1]);
                            }
                            else
                            {
                                espacio = int.Parse(vert[1]);
                                posinitabla = posinitabla + LisDT[i - 1].Rows.Count + espacio;
                                pos = pos;
                            }

                        }
                        else
                            posinitabla = (int)(posinitablav);

                        //vertical                          

                        sl.ImportDataTable(posinitabla, pos, LisDT[i], true);//cambio
                        //
                        
                        sl.SetCellStyle(posinitabla, pos, posinitabla, (col - 1) + (pos), estilo_bosch(sl, "e"));
                        sl.SetCellStyle(posinitabla + 1, pos, (posinitabla - 1) + row + 1, col + (pos), estilo_bosch(sl, "d", det_alig));
                        sl.AutoFitColumn(pos - 1, col);

                        SLTable table = null;
                        if (del_col != null)
                        {
                            sl.DeleteColumn(1, (int)del_col);
                            table = sl.CreateTable(posinitabla, pos, (posinitabla - 1) + row + 1, col - (int)del_col);//resta pol a columna eliminada
                        }
                        else
                        {
                            table = sl.CreateTable(posinitabla, pos, (posinitabla - 1) + row + 1, col + (pos - 1));
                        }
                        table.HasBandedRows = true;
                        table.HasAutoFilter = false;
                        table.HasBandedColumns = true;
                        
                        if (fre_row != null)
                        {
                            sl.FreezePanes((int)fre_row, 0);
                        }
                        sl.InsertTable(table);
                        Utilerias util = new Utilerias();
                        string[,] postabla = util.abc_cel(pos, col - 1);
                        if (graf == 1)
                        {
                            double fChartHeight = 15.0;
                            double fChartWidth = 7;
                            //table = sl.CreateTable(2, 2, 5, 6);                            
                            SLChart chart;
                            //Console.WriteLine(" Posicion Init  " + postabla[0, 0] + (posinitablav - 1).ToString());
                            //Console.WriteLine(" Posicion fInit " + postabla[0, 1] + (posinitablav - 1).ToString());
                            //Console.WriteLine(" Posicion Ini   " + postabla[0, 0] + (posinitablav + 1).ToString());
                            //Console.WriteLine(" Posicion fin   " + postabla[0, 1] + ((posinitabla - 1) + row + 1).ToString());
                            //Console.WriteLine(" Posicion fin 1 " + postabla[0, 1] + ((posinitabla) + row + 1).ToString());
                            //Console.WriteLine(" Posicion fin 2 " + postabla[0, 1] + ((posinitabla - 1) + row).ToString());
                            //  chart = sl.CreateChart("A5", "G11", new SLCreateChartOptions() { RowsAsDataSeries = false });
                            chart = sl.CreateChart(postabla[0, 0] + (posinitablav).ToString(), postabla[0, 1] + ((posinitabla - graf_ran_row_neg) + row).ToString(), new SLCreateChartOptions() { RowsAsDataSeries = false });

                            chart.SetChartType(SLColumnChartType.ClusteredColumn);
                            SLDataSeriesOptions dso;
                            dso = chart.GetDataSeriesOptions(4);
                            dso.Line.Width = 0;
                            dso.Fill.SetNoFill();
                            dso.Marker.Fill.SetNoFill();
                            dso.Line.SetSolidLine(SLThemeColorIndexValues.Accent1Color, 0, 100);
                            dso.Marker.Line.SetSolidLine(SLThemeColorIndexValues.Accent5Color, 0, 100);
                            for (int x = 1; x < col - 1; x++)
                            {
                                chart.SetDataSeriesOptions(x, dso);
                                chart.PlotDataSeriesAsPrimaryAreaChart(x, SLChartDataDisplayType.Normal);
                            }
                            SLGroupDataLabelOptions gdloptions;
                            gdloptions = chart.CreateGroupDataLabelOptions();
                            gdloptions.ShowValue = true;
                            chart.SetGroupDataLabelOptions(8, gdloptions);
                            SLFont ft;
                            SLRstType rst = sl.CreateRstType();
                            ft = sl.CreateFont();
                            ft.SetFont("Arial", 10);
                            rst.AppendText(enc_hg, ft);
                            chart.Title.SetTitle(rst);
                            chart.ShowChartTitle(false);
                            chart.HideChartLegend();
                            if (rowg < row) rowg = row;
                            chart.SetChartPosition(rowg + 6, pos - 1, rowg + 6 + fChartHeight, pos + fChartWidth - 2);
                            sl.InsertChart(chart);
                        }
                        if (enc_ht != "")
                        {
                            sl.SetCellValue(postabla[0, 0] + (posinitabla - 1).ToString(), enc_ht);
                            sl.MergeWorksheetCells(postabla[0, 0] + (posinitabla - 1).ToString(), postabla[0, 1] + (posinitabla - 1).ToString(), estilo_bosch(sl, "e"));
                        }

                        if (hoja != enc_h && enc_hh != "")
                        {
                            sl.SetCellValue(postabla[0, 0] + (posinitablav - 4).ToString(), enc_hh);
                            sl.MergeWorksheetCells(postabla[0, 0] + (posinitablav - 4).ToString(), postabla[0, 1] + (posinitablav - 4).ToString(), estilo_bosch(sl, "e"));
                        }

                        hoja = enc_h;
                    }
                }

                sl.SaveAs(name);
                archivo = name;

            }
            catch (Exception ex)
            {
                Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
            }
            sl.Dispose();
            return archivo;
        }
        public SLStyle estilo_bosch(SLDocument sl, string tp, String? Alig = "")
        {
            SLStyle style_d = sl.CreateStyle();
            style_d.SetFont("Arial", 8);
            style_d.SetFontBold(true);
            style_d.SetVerticalAlignment(DocumentFormat.OpenXml.Spreadsheet.VerticalAlignmentValues.Center);
            if (Alig == "")
                style_d.SetHorizontalAlignment(DocumentFormat.OpenXml.Spreadsheet.HorizontalAlignmentValues.Center);
            else
                style_d.SetHorizontalAlignment(DocumentFormat.OpenXml.Spreadsheet.HorizontalAlignmentValues.Left);
            style_d.Fill.SetPattern(PatternValues.Solid, System.Drawing.Color.White, System.Drawing.Color.Black);
            style_d.SetFontColor(System.Drawing.Color.Black);
            if (tp.ToUpper() == "E")
            {
                style_d.Fill.SetPattern(PatternValues.Solid, System.Drawing.Color.Black, System.Drawing.Color.White);
                style_d.SetFontColor(System.Drawing.Color.White);
                //  style_d.Alignment.ShrinkToFit = true;
            }
            return style_d;
        }
        /// <summary>
        /// Crea un archivo XLSX a partir de un Dataset, considerando una Hoja de trabajo por cada DataTable.
        /// </summary>
        /// <param name="dsData">DataSet con los DataTable's que contienen la información a plasmar en el archivo.</param>
        /// <param name="dsTitles">Opcional: En caso de requerir encabezados específicos, se debe declarar un DataTable de encabezados por cada DataTable de Datos.</param>
        /// <param name="filename">Opcional: Nombre que se le dará al archivo, por default se almacenará como wroksheet_logis_{ddMMyyyyHHmmssfff}.xlsx</param>
        /// <returns>Ruta y nombre del archivo creado.</returns>
        public string CreateExcel_file(DataSet dsData, DataSet dsTitles = null, string? filename = "", string? carpeta = "")
        {
            int i = 0;
            int j = 0;
            SLDocument sl = new SLDocument();
            string ruta_nombre = string.Empty;
            string hoja_default = string.Empty;
            string hoja_inicial = string.Empty;
            DataSet dsResultante = new DataSet();
            SLStyle headerStyle = new SLStyle();
            SLStyle styleFont = new SLStyle();

            try
            {
                headerStyle = new SLStyle();
                headerStyle.Font.Bold = true;
                headerStyle.SetFont("Arial", 8);
                headerStyle.Font.FontColor = System.Drawing.Color.White;
                headerStyle.Fill.SetPatternType(PatternValues.Solid);
                headerStyle.Fill.SetPatternBackgroundColor(System.Drawing.Color.Black);
                headerStyle.Alignment.Horizontal = DocumentFormat.OpenXml.Spreadsheet.HorizontalAlignmentValues.Center;

                styleFont = new SLStyle();
                styleFont.SetFont("Arial", 8);
                styleFont.Font.Bold = true;
                styleFont.Alignment.Horizontal = DocumentFormat.OpenXml.Spreadsheet.HorizontalAlignmentValues.Center;

                if (filename != null)
                {
                    if (!filename.Trim().Equals(string.Empty))
                    {
                        if (!filename.ToLower().EndsWith(".xls") && !filename.ToLower().EndsWith(".xlsx"))
                        {
                            filename = string.Format("{0}.xlsx", filename);
                        }
                    }
                    else
                    {
                        filename = string.Format("wroksheet_logis_{0}.xlsx", DateTime.Now.ToString("ddMMyyyyHHmmssfff"));
                    }
                }
                else
                {
                    filename = string.Format("wroksheet_logis_{0}.xlsx", DateTime.Now.ToString("ddMMyyyyHHmmssfff"));
                }
                if (dsData != null && dsTitles != null)
                {
                    if (dsData.Tables.Count > 0 && dsTitles.Tables.Count > 0)
                    {
                        if (dsData.Tables.Count.Equals(dsTitles.Tables.Count))
                        {
                            i = 0;
                            foreach (DataTable dt in dsData.Tables)
                            {
                                j = 0;
                                dsResultante.Tables.Add(dt.Copy());

                                if (dsResultante.Tables[i].Columns.Count.Equals(dsTitles.Tables[i].Rows.Count))
                                {
                                    foreach (DataRow dr in dsTitles.Tables[i].Rows)
                                    {
                                        dsResultante.Tables[i].Columns[j].ColumnName = dr[0].ToString();
                                        j++;
                                    }
                                }

                                i++;
                            }
                        }
                    }
                    else if (dsData.Tables.Count > 0)
                    {
                        i = 0;
                        foreach (DataTable dt in dsData.Tables)
                        {
                            dsResultante.Tables.Add(dt.Copy());
                        }
                    }
                }
                else if (dsData != null && dsTitles == null)
                {
                    i = 0;
                    foreach (DataTable dt in dsData.Tables)
                    {
                        dsResultante.Tables.Add(dt.Copy());
                    }
                }
                if (dsResultante != null)
                {
                    if (dsResultante.Tables.Count > 0)
                    {
                        sl = new SLDocument();
                        hoja_default = sl.GetCurrentWorksheetName();

                        foreach (DataTable dt in dsResultante.Tables)
                        {
                            if (hoja_inicial.Trim().Equals(string.Empty))
                            {
                                hoja_inicial = dt.TableName;
                            }
                            sl.AddWorksheet(dt.TableName);
                            sl.ImportDataTable(1, 1, dt, true);
                            sl.AutoFitColumn(1, dt.Columns.Count);
                            sl.FreezePanes(1, 0);
                            //sl.SetRowStyle(1, headerStyle);
                            sl.SetCellStyle(1, 1, 1, dt.Columns.Count, headerStyle);
                            sl.SetCellStyle(1, 1, dt.Rows.Count + 1, dt.Columns.Count, styleFont);
                        }

                        sl.DeleteWorksheet(hoja_default);
                        sl.SelectWorksheet(hoja_inicial);


                        if (carpeta == "")
                        {
                            ruta_nombre = string.Format("{0}{1}", Path.GetTempPath(), filename);
                            carpeta = Path.GetTempPath();
                        }
                        else
                        {
                            ruta_nombre = carpeta + "\\" + filename;
                        }

                        ruta_nombre = ruta_nombre.Replace("\\\\", "\\");


                        sl.SaveAs(ruta_nombre);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Write(ex);
            }

            return ruta_nombre;
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="sl"></param>
        /// <param name="color">El color puede enviar en formato de nombre o por Hexadecimal</param>
        /// <param name="tipo">C= colo en formato nombre, H= Formato Hexadecimal</param>
        /// <returns></returns>
        public SLStyle stylecol(SLDocument sl, string color, string? tipo = null)
        {
            SLStyle style_d = sl.CreateStyle();
            string tipocolor;

            if (tipo == null)
            {
                tipocolor = color.IndexOf("#", 0) >= 0 ? "H" : "C";
            }
            else
            {
                tipocolor = tipo;
            }

            if (tipocolor == "C")
            {
                style_d.Fill.SetPattern(PatternValues.Solid, System.Drawing.Color.FromName(color), System.Drawing.Color.White);
            }
            else if (tipocolor == "H")
            {
                style_d.Fill.SetPattern(PatternValues.Solid, System.Drawing.ColorTranslator.FromHtml(color), System.Drawing.Color.White);
            }
            else
            {
                style_d.Fill.SetPattern(PatternValues.Solid, System.Drawing.Color.White, System.Drawing.Color.White);
            }

            return style_d;

        }

        public string CreateExcel_file_FacPend(DataSet dsData, string sheet, string columPrint, string indexColumPrint, string columColor, DataSet dsTitles = null, string? filename = "")
        {
            int i = 0;
            int j = 0;
            SLDocument sl = new SLDocument();
            string ruta_nombre = string.Empty;
            string hoja_default = string.Empty;
            string hoja_inicial = string.Empty;
            DataSet dsResultante = new DataSet();
            SLStyle headerStyle = new SLStyle();

            try
            {
                headerStyle = new SLStyle();
                headerStyle.Font.Bold = true;
                headerStyle.Font.FontColor = System.Drawing.Color.White;
                headerStyle.Fill.SetPatternType(PatternValues.Solid);
                headerStyle.Fill.SetPatternBackgroundColor(System.Drawing.Color.Black);
                headerStyle.Alignment.Horizontal = DocumentFormat.OpenXml.Spreadsheet.HorizontalAlignmentValues.Center;


                if (filename != null)
                {
                    if (!filename.Trim().Equals(string.Empty))
                    {
                        if (!filename.ToLower().EndsWith(".xls") && !filename.ToLower().EndsWith(".xlsx"))
                        {
                            filename = string.Format("{0}.xlsx", filename);
                        }
                    }
                    else
                    {
                        filename = string.Format("wroksheet_logis_{0}.xlsx", DateTime.Now.ToString("ddMMyyyyHHmmssfff"));
                    }
                }
                else
                {
                    filename = string.Format("wroksheet_logis_{0}.xlsx", DateTime.Now.ToString("ddMMyyyyHHmmssfff"));
                }
                if (dsData != null && dsTitles != null)
                {
                    if (dsData.Tables.Count > 0 && dsTitles.Tables.Count > 0)
                    {
                        if (dsData.Tables.Count.Equals(dsTitles.Tables.Count))
                        {
                            i = 0;
                            foreach (DataTable dt in dsData.Tables)
                            {
                                j = 0;
                                dsResultante.Tables.Add(dt.Copy());

                                if (dsResultante.Tables[i].Columns.Count.Equals(dsTitles.Tables[i].Rows.Count))
                                {
                                    foreach (DataRow dr in dsTitles.Tables[i].Rows)
                                    {
                                        dsResultante.Tables[i].Columns[j].ColumnName = dr[0].ToString();
                                        j++;
                                    }
                                }

                                i++;
                            }
                        }
                    }
                }
                else if (dsData != null && dsTitles == null)
                {
                    i = 0;
                    foreach (DataTable dt in dsData.Tables)
                    {
                        dsResultante.Tables.Add(dt.Copy());
                    }
                }
                if (dsResultante != null)
                {
                    if (dsResultante.Tables.Count > 0)
                    {
                        sl = new SLDocument();
                        hoja_default = sl.GetCurrentWorksheetName();

                        foreach (DataTable dt in dsResultante.Tables)
                        {
                            if (hoja_inicial.Trim().Equals(string.Empty))
                            {
                                hoja_inicial = dt.TableName;
                            }
                            sl.AddWorksheet(dt.TableName);
                            sl.ImportDataTable(1, 1, dt, true);
                            sl.AutoFitColumn(1, dt.Columns.Count);
                            sl.FreezePanes(1, 0);
                            sl.SetRowStyle(1, headerStyle);


                            if (sheet == dt.TableName)
                            {
                                for (i = 0; i < dt.Rows.Count; i++)
                                {
                                    if (sl.GetCellValueAsString(i + 2, dt.Columns.IndexOf(columPrint) + 1) != "")
                                    {
                                        sl.SetCellStyle((indexColumPrint + (i + 2)).ToString(), stylecol(sl, dt.Rows[i][columColor].ToString()));
                                    }
                                }

                                if (dt.Columns.Contains(columColor))
                                {
                                    sl.DeleteColumn(dt.Columns.IndexOf(columColor) + 1, 1);
                                }
                            }
                        }

                        sl.DeleteWorksheet(hoja_default);
                        sl.SelectWorksheet(hoja_inicial);
                        //ruta_nombre = string.Format("{0}{1}", Path.GetTempPath(), filename);
                        ruta_nombre = filename;


                        sl.SaveAs(ruta_nombre);

                        sl.Dispose();

                    }
                }
            }
            catch (Exception ex)
            {
                Console.Write(ex);
            }

            return ruta_nombre;
        }

        public string CreateExcel_file_Style(DataSet dsData, DataSet? dsTitles = null, string? filename = "", string? carpeta = "", string[,]? styls = null, string?[,] tbInSheet = null)
        {
            int i = 0;
            int j = 0;
            int index;
            string campo;
            string color;
            string dat;
            int round = 0;
            string nameSheetTemp = "";
            int refCelRow = 0;
            string refCelColIni = "";
            string refCelColFin = "";
            string rango = "";
            string titCellCom = "";
            string colCelCom = "";
            string colHeader = "";

            SLDocument sl = new SLDocument();
            string ruta_nombre = string.Empty;
            string hoja_default = string.Empty;
            string hoja_inicial = string.Empty;
            DataSet dsResultante = new DataSet();
            SLStyle headerStyle = new SLStyle();
            SLStyle styleFont = new SLStyle();
            SLStyle styleBorde = new SLStyle();
            Utilerias utils = new Utilerias();

            try
            {
                headerStyle = new SLStyle();
                headerStyle.Font.Bold = true;
                headerStyle.SetFont("Arial", 8);
                headerStyle.Font.FontColor = System.Drawing.Color.White;
                headerStyle.Fill.SetPatternType(PatternValues.Solid);
                headerStyle.Fill.SetPatternBackgroundColor(System.Drawing.Color.Black);
                headerStyle.Alignment.Horizontal = DocumentFormat.OpenXml.Spreadsheet.HorizontalAlignmentValues.Center;

                styleFont = new SLStyle();
                styleFont.SetFont("Arial", 8);
                styleFont.Font.Bold = true;
                styleFont.Alignment.Horizontal = DocumentFormat.OpenXml.Spreadsheet.HorizontalAlignmentValues.Center;

                styleBorde = new SLStyle();
                styleBorde.Border.Outline = true;
                styleBorde.Border.SetLeftBorder(BorderStyleValues.Thick, System.Drawing.Color.White);
                styleBorde.Border.SetRightBorder(BorderStyleValues.Thick, System.Drawing.Color.White);
                styleBorde.Border.SetTopBorder(BorderStyleValues.Thick, System.Drawing.Color.White);
                styleBorde.Border.SetBottomBorder(BorderStyleValues.Thick, System.Drawing.Color.White);


                if (filename != null)
                {
                    if (!filename.Trim().Equals(string.Empty))
                    {
                        if (!filename.ToLower().EndsWith(".xls") && !filename.ToLower().EndsWith(".xlsx"))
                        {
                            filename = string.Format("{0}.xlsx", filename);
                        }
                    }
                    else
                    {
                        filename = string.Format("wroksheet_logis_{0}.xlsx", DateTime.Now.ToString("ddMMyyyyHHmmssfff"));
                    }
                }
                else
                {
                    filename = string.Format("wroksheet_logis_{0}.xlsx", DateTime.Now.ToString("ddMMyyyyHHmmssfff"));
                }
                if (dsData != null && dsTitles != null)
                {
                    if (dsData.Tables.Count > 0 && dsTitles.Tables.Count > 0)
                    {
                        if (dsData.Tables.Count.Equals(dsTitles.Tables.Count))
                        {
                            i = 0;
                            foreach (DataTable dt in dsData.Tables)
                            {
                                j = 0;
                                dsResultante.Tables.Add(dt.Copy());

                                if (dsResultante.Tables[i].Columns.Count.Equals(dsTitles.Tables[i].Rows.Count))
                                {
                                    foreach (DataRow dr in dsTitles.Tables[i].Rows)
                                    {
                                        dsResultante.Tables[i].Columns[j].ColumnName = dr[0].ToString();
                                        j++;
                                    }
                                }

                                i++;
                            }
                        }
                    }
                    else if (dsData.Tables.Count > 0)
                    {
                        i = 0;
                        foreach (DataTable dt in dsData.Tables)
                        {
                            dsResultante.Tables.Add(dt.Copy());
                        }
                    }
                }
                else if (dsData != null && dsTitles == null)
                {
                    i = 0;
                    foreach (DataTable dt in dsData.Tables)
                    {
                        dsResultante.Tables.Add(dt.Copy());
                    }
                }
                if (dsResultante != null)
                {
                    if (dsResultante.Tables.Count > 0)
                    {
                        sl = new SLDocument();
                        hoja_default = sl.GetCurrentWorksheetName();

                        foreach (DataTable dt in dsResultante.Tables)
                        {



                            //Bloque de tablas en una misma hoja
                            if (tbInSheet != null)
                            {
                                index = utils.getIndexArrMulti(tbInSheet, dt.TableName, 1);

                                if (index != -1)
                                {
                                    if (hoja_inicial.Trim().Equals(string.Empty))
                                    {
                                        hoja_inicial = tbInSheet[index, 0].ToString();
                                    }


                                    if (nameSheetTemp != tbInSheet[index, 0].ToString())
                                    {
                                        sl.AddWorksheet(tbInSheet[index, 0].ToString());
                                        round = 0;
                                    }

                                    if (round == 0)
                                    {
                                        sl.ImportDataTable(2, 1, dt, true);
                                    }
                                    else
                                    {
                                        sl.ImportDataTable(sl.GetCells().Keys.Max() + 4, 1, dt, true);
                                    }

                                    sl.AutoFitColumn(1, dt.Columns.Count);

                                    if (round == 0)
                                    {
                                        sl.SetCellStyle(1, 1, sl.GetCells().Keys.Max(), dt.Columns.Count, styleFont);
                                    }
                                    else
                                    {
                                        sl.SetCellStyle(sl.GetCells().Keys.Max() - dt.Rows.Count, 1, sl.GetCells().Keys.Max(), dt.Columns.Count, styleFont);
                                    }


                                    //Bloque de combinar Celdas
                                    if (tbInSheet.GetLength(1) >= 2)
                                    {
                                        refCelRow = tbInSheet[index, 2].Split("|").GetValue(0).ToString() == "S" ? (sl.GetCells().Keys.Max() - dt.Rows.Count) - 1 : sl.GetCells().Keys.Max() - dt.Rows.Count;

                                        if (tbInSheet[index, 2].Split("|").GetValue(0).ToString() == "S" && tbInSheet[index, 2].ToString().Split("|").Length > 1)
                                        {
                                            colHeader = tbInSheet[index, 2].Split("|").GetValue(1).ToString();

                                            if (colHeader != "")
                                            {
                                                sl.SetCellStyle(refCelRow + 1, 1, refCelRow + 1, dt.Columns.Count, stylecol(sl, colHeader));
                                            }
                                        }

                                        for (i = 0; i < tbInSheet[index, 3].Split("|").Count(); i++)
                                        {
                                            rango = tbInSheet[index, 3].Split("|").GetValue(i).ToString();

                                            refCelColIni = rango.Split("-").GetValue(0).ToString();
                                            refCelColFin = rango.Split("-").GetValue(1).ToString();
                                            titCellCom = rango.Split("-").Length > 2 ? rango.Split("-").GetValue(2).ToString() : "";
                                            colCelCom = rango.Split("-").Length > 3 ? rango.Split("-").GetValue(3).ToString() : "";

                                            sl.MergeWorksheetCells(refCelColIni + refCelRow.ToString(), refCelColFin + refCelRow.ToString(), styleBorde);
                                            sl.SetCellValue(refCelColIni + refCelRow.ToString(), titCellCom);

                                            if (colCelCom != "")
                                            {
                                                sl.SetCellStyle(refCelColIni + refCelRow.ToString(), stylecol(sl, colCelCom));
                                            }

                                            sl.SetCellStyle(refCelColIni + refCelRow.ToString(), styleFont);
                                        }
                                    }

                                    round = 1;
                                    rango = "";
                                    refCelColIni = "";
                                    refCelColFin = "";
                                    titCellCom = "";
                                    refCelRow = 0;
                                    nameSheetTemp = tbInSheet[index, 0].ToString();

                                }
                                else
                                {

                                    if (hoja_inicial.Trim().Equals(string.Empty))
                                    {
                                        hoja_inicial = dt.TableName;
                                    }

                                    sl.AddWorksheet(dt.TableName);
                                    sl.ImportDataTable(1, 1, dt, true);
                                    sl.AutoFitColumn(1, dt.Columns.Count);
                                    sl.FreezePanes(1, 0);
                                    sl.SetCellStyle(1, 1, 1, dt.Columns.Count, headerStyle);
                                    sl.SetCellStyle(1, 1, dt.Rows.Count + 1, dt.Columns.Count, styleFont);
                                }
                            }
                            else
                            {

                                if (hoja_inicial.Trim().Equals(string.Empty))
                                {
                                    hoja_inicial = dt.TableName;
                                }

                                sl.AddWorksheet(dt.TableName);
                                sl.ImportDataTable(1, 1, dt, true);
                                sl.AutoFitColumn(1, dt.Columns.Count);
                                sl.FreezePanes(1, 0);
                                sl.SetCellStyle(1, 1, 1, dt.Columns.Count, headerStyle);
                                sl.SetCellStyle(1, 1, dt.Rows.Count + 1, dt.Columns.Count, styleFont);
                            }


                            ///Bloque de estilos a campos
                            if (styls != null)
                            {
                                index = utils.getIndexArrMulti(styls, sl.GetCurrentWorksheetName(), 0); // Si la hoja se encuentra en el arreglo, llevara color
                                if (index != -1)
                                {
                                    for (i = 0; i <= sl.GetCells().Keys.Max(); i++) //registros de la hoja
                                    {

                                        if (styls[index, 1].Split("|").Length > 1)
                                        {

                                            for (j = 0; j < styls[index, 1].ToString().Split("|").Length; j++) // ciclo por columnas a pintar 
                                            {
                                                campo = sl.GetCellValueAsString(i + 1, dt.Columns.IndexOf(styls[index, 1].Split("|").GetValue(j).ToString()) + 1); //obtiene valor del campo "Info|Color"

                                                color = (campo.Split("|").Length > 1 ? campo.Split("|").GetValue(1).ToString() : "").Trim();  //Obtiene el color del campo obtenido anteriormente "|Color"
                                                dat = (campo.Split("|").Length > 0 ? campo.Split("|").GetValue(0).ToString() : campo).Trim(); //Obtiene la información del campo obtenido anteriormente "Info|"

                                                if (color != "")
                                                {
                                                    sl.SetCellStyle(i + 1, dt.Columns.IndexOf(styls[index, 1].Split("|").GetValue(j).ToString()) + 1, stylecol(sl, color)); //Coloca el estilo a la celda (fila, columna, stylo)
                                                }
                                                sl.SetCellValue(i + 1, dt.Columns.IndexOf(styls[index, 1].Split("|").GetValue(j).ToString()) + 1, dat); // cambia el valor del campo por solo la información (fila, columna, datos)
                                            }
                                        }
                                        else
                                        {
                                            for (j = 1; j < sl.GetWorksheetStatistics().NumberOfColumns; j++)
                                            {
                                                campo = sl.GetCellValueAsString(i + 1, j);

                                                color = (campo.Split("|").Length > 1 ? campo.Split("|").GetValue(1).ToString() : "").Trim();
                                                dat = (campo.Split("|").Length > 0 ? campo.Split("|").GetValue(0).ToString() : "").Trim();

                                                if (color != "")
                                                {
                                                    sl.SetCellStyle(i + 1, j, stylecol(sl, color)); //Coloca el estilo a la celda (fila, columna, stylo)
                                                }
                                                sl.SetCellValue(i + 1, j, dat);

                                            }

                                        }

                                        //Coloca el formato del encabezado para los casos en que se coloque mas de una tabla en la misma hoja
                                        if (styls.GetLength(1) >= 3)
                                        {
                                            if (styls.GetValue(index, 2).ToString() != "" && i != 0)
                                            {
                                                if (sl.GetCellValueAsString(i + 1, dt.Columns.IndexOf(styls[index, 2].ToString()) + 1).ToString() == styls.GetValue(index, 2).ToString())
                                                {
                                                    sl.SetCellStyle(i + 1, 1, i + 1, dt.Columns.Count, headerStyle);
                                                }
                                            }
                                        }

                                        //Remplaza la primer fila por la segunda 
                                        if (styls.GetLength(1) >= 4)
                                        {
                                            if (styls.GetValue(index, 3).ToString() == "S" && i == 1)
                                            {
                                                sl.DeleteRow(1, 1);
                                                break;
                                            }
                                        }

                                    }
                                }
                            }
                        }

                        sl.DeleteWorksheet(hoja_default);
                        sl.SelectWorksheet(hoja_inicial);


                        if (carpeta == "")
                        {
                            ruta_nombre = string.Format("{0}{1}", Path.GetTempPath(), filename);
                            carpeta = Path.GetTempPath();
                        }
                        else
                        {
                            ruta_nombre = carpeta + "\\" + filename;
                        }

                        ruta_nombre = ruta_nombre.Replace("\\\\", "\\");

                        sl.SaveAs(ruta_nombre);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Write(ex);
            }

            return ruta_nombre;
        }



    }
}