using SpreadsheetLight;
using System;
using System.Data;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using DocumentFormat.OpenXml.Spreadsheet;
using ClosedXML.Excel;

namespace serverreports
{
    internal class Excel
    {
        public void CrearExcel_file(DataTable[] LisDT, string[] tit, string name)
        {
            try
            {
                SLDocument sl = new SLDocument();
                for (int i = 0; i < LisDT.Length; i++) 
                {
                    
                    if (i == 0) sl.RenameWorksheet("Sheet1", tit[i]);
                    else sl.AddWorksheet(tit[i]);
                    sl.ImportDataTable(1, 1, LisDT[i], true);
                    sl.AutoFitColumn(1, LisDT[i].Columns.Count);

                    SLStyle style_d = sl.CreateStyle();
                    style_d.SetFont("Arial", 8);
                    style_d.SetFontBold(true);
                    style_d.SetVerticalAlignment(VerticalAlignmentValues.Center);
                    style_d.SetHorizontalAlignment(HorizontalAlignmentValues.Center);

                    
                    SLStyle style_e = sl.CreateStyle();
                    style_e.SetFont("Arial", 8);
                    style_e.SetFontBold(true);
                    style_e.Fill.SetPattern(PatternValues.Solid, System.Drawing.Color.Black, System.Drawing.Color.White);
                    style_e.SetFontColor(System.Drawing.Color.White);
                    style_e.Alignment.ShrinkToFit = true;                  

                    sl.SetCellStyle(1, 1, LisDT[i].Rows.Count+1, LisDT[i].Columns.Count, style_d);
                    sl.SetCellStyle(1, 1, 1, LisDT[i].Columns.Count, style_e);
                    sl.DeleteColumn(1, 1);
                    sl.FreezePanes(1, 0);
                }

                //Guardar como, y aqui ponemos la ruta de nuestro archivo
                sl.SaveAs(name+".xlsx");
                Console.WriteLine("Se genero Archivo " + name + ".xlsx");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
            }
        }

        public void CreadorExcel_2F(DataTable[] LisDT, string[] tit, string name)
        {
            using (var workbook = new XLWorkbook())
            {
                try
                {
                    for (int i = 0; i < LisDT.Length; i++)
                    {
                        var hoja = workbook.Worksheets.Add(tit[i]);
                        var table = hoja.Cell("A1").InsertTable(LisDT[i]);
                        table.Theme = XLTableTheme.None;
                        table.ShowAutoFilter = false;
                        table.Column(1).Delete();
                        table.Style.Font.SetBold(true);
                        table.Style.Font.FontSize = 8;
                        table.Style.Font.FontName = "Arial";
                        table.Style.Alignment.Vertical = XLAlignmentVerticalValues.Center;
                        table.Style.Alignment.Horizontal = XLAlignmentHorizontalValues.Center;
                        var rango = table.Row(1);                                            
                        rango.Style.Fill.BackgroundColor = XLColor.Black;
                        rango.Style.Font.FontColor = XLColor.White;
                        hoja.Columns().AdjustToContents();
                        hoja.SheetView.FreezeRows(1);
                    }
                    workbook.SaveAs(name + ".xlsx");
                    Console.WriteLine("Se genero Archivo " + name + ".xlsx");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
                }
            }

        }

    }
}
