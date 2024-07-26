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

namespace serverreports
{
    internal class Excel
    {
        public void CrearExcel_file(DataTable[] LisDT, string[] tit, string name, int? del_col = null)
        {
            using (var workbook = new XLWorkbook())
            {
                try
                {
                    for (int i = 0; i < LisDT.Length; i++)
                    {
                        var hoja = workbook.Worksheets.Add(tit[i]);
                        var table = hoja.Cell("A1").InsertTable(LisDT[i]);

                        table.ShowAutoFilter = false;
                        table.Theme = XLTableTheme.None;

                        if (del_col != null)
                        {
                            table.Column((int)del_col).Delete();
                        }
                        table.Style = estilo_bosch(hoja.Style, "d");

                        var rango = table.Row(1);
                        rango.Style = estilo_bosch(rango.Style, "e");
                        hoja.Columns().AdjustToContents();
                    }

                    workbook.SaveAs(name+".xlsx");
                    Console.WriteLine("Se genero Archivo " + name);
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
                }
            }
        }

        public IXLStyle estilo_bosch(IXLStyle hoja, string tp)
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
    }
}