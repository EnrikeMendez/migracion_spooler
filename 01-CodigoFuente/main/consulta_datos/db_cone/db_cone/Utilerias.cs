using ClosedXML.Excel;
using DocumentFormat.OpenXml.Spreadsheet;
using DocumentFormat.OpenXml.Wordprocessing;
using SpreadsheetLight;
using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using static System.Runtime.InteropServices.JavaScript.JSType;

namespace db_cone
{
    internal class Utilerias
    {
        
     public string Tdetalle(DataTable dtTemp)
    {
        string tit = "";
        string val = "";
        for (int j = 0; j < dtTemp.Rows.Count; j++)
        {
            for (int i = 0; i < dtTemp.Columns.Count; i++)
            {
                if (j == 0) { tit = tit + dtTemp.Columns[i].ColumnName + "\t"; }
                val = val + dtTemp.Rows[j][i].ToString() + "\t";
            }
            if (j == 0) { val = tit + "\n" + val + "\n"; }
            else
            {
                val = val + "\n";
            }
        }
        return val;
    }
  

    public void closedXML(DataTable dtTemp)
    {
            
        using (var workbook = new XLWorkbook())
        {
                try
                {
                    var hoja = workbook.Worksheets.Add();
                    var table = hoja.Cell("a1").InsertTable(dtTemp);
                    table.ShowAutoFilter = false;
                    table.Theme = XLTableTheme.None;
                    //var format = "YYYY/MM/DD; (YYYY/MM/DD)";
                    hoja.Cell("J1").Style.DateFormat.Format =  "yyyy-mm-dd";
                    var format = "$#,##0.000; ($#,##0.000)";
                    hoja.Cell("A2").Style.NumberFormat.Format = format;
                    workbook.SaveAs("closedXML.xlsx");
                    Console.WriteLine("Se genero Archivo " + "closedXML.xlsx");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
                }
            }
  
    }


        public void CrearExcel(DataTable dtTemp)
        {
            using (SLDocument sl = new SLDocument())
            { 
                try
                {

                    sl.ImportDataTable(1, 1, dtTemp, true);
                    SLStyle style = sl.CreateStyle();
                    style.FormatCode = "YYYY/MM/DD";
                    sl.SetColumnStyle(9, style);
                    sl.SetColumnStyle(10, style);
                    sl.SetColumnStyle(11, style);
                    style.FormatCode = "$#,##0.00";
                    sl.SetColumnStyle(1, style);
                    sl.SaveAs("spreadsheetlight.xlsx");
                    Console.WriteLine("Se genero Archivo " + "spreadsheetlight.xlsx");
                }
                catch (Exception ex)
                {
                    Console.WriteLine("Ocurrio una Excepción: " + ex.Message);
                }
            }
        }



    }
}
