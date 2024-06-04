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
        public void CrearExcel_file(DataTable[] LisDT)
        {
            try
            {
                SLDocument sl = new SLDocument();
                for (int i = 0; i < LisDT.Length; i++) 
                {
                    if (i == 0) sl.RenameWorksheet("Sheet1", tit[i]);
                    else sl.AddWorksheet(tit[i]);


                }
                //Guardar como, y aqui ponemos la ruta de nuestro archivo
                sl.SaveAs("boschspreadsheetlight.xlsx");
            }
            catch (Exception ex)
            {
                Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
            }
        }

        public void CreadorExcel_2F(DataTable[] LisDT)
        {
            using (var workbook = new XLWorkbook())
            {
                try
                {
                    for (int i = 0; i < LisDT.Length; i++)
                    {
                        var hoja = workbook.Worksheets.Add(tit[i]);
                        var table = hoja.Cell("A1").InsertTable(LisDT[i]);

                    }
                    workbook.SaveAs("closedXML.xlsx");
                    Console.WriteLine("Se genero Archivo " + "closedXML.xlsx");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
                }
            }

        }

    }
}
