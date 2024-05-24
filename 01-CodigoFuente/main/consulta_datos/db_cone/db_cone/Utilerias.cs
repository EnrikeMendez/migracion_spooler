using System;
using System.Collections.Generic;
using System.Data;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

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
    }
   

}
