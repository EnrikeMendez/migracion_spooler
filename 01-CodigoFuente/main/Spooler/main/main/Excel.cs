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
                    if (del_col != null)
                    {
                        sl.DeleteColumn(1, (int)del_col);
                    }
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


    }
}
