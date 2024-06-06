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
                    sl.SetCellStyle(2, 1, LisDT[i].Rows.Count + 1, LisDT[i].Columns.Count, estilo_bosch(sl, "d"));
                    sl.SetCellStyle(1, 1, 1, LisDT[i].Columns.Count, estilo_bosch(sl, "e")); 
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
                        table.Style = estilo_bosch1(hoja.Style,"d");                        
                        var rango = table.Row(1);
                        rango.Style = estilo_bosch1(rango.Style, "e");
                        table.Column(1).Delete();
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
        public SLStyle estilo_bosch(SLDocument sl, string tp)
        {
            SLStyle style_d = sl.CreateStyle();
            style_d.SetFont("Arial", 8);
            style_d.SetFontBold(true);
            style_d.SetVerticalAlignment(VerticalAlignmentValues.Center);
            style_d.SetHorizontalAlignment(HorizontalAlignmentValues.Center);
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

    }
}
