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

                    workbook.SaveAs(name);
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


    }
}