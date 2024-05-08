using System;
using System.Collections.Generic;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace serverreports
{
    internal class Utilerias
    {
        public string Tcampo(DataTable dtTemp, string campo)
        {
            string valor = "";
            if (dtTemp.Rows.Count>0 && campo!=null)
            {
            for (int j = 0; j < 1; j++)
                valor = dtTemp.Rows[j][campo].ToString();        
          
            }
            return valor;

        }
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
                if (j == 0) { val = tit+"\n" + val + "\n"; }
                else { 
                val = val + "\n";
                }
            }
            return val;
        }



    }
}
