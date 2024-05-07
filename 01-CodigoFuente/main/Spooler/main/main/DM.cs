using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Reflection.PortableExecutable;
using System.Linq.Expressions;
using System.Data.OracleClient;
namespace serverreports
{
    internal class DM
    {
        public DataTable datos(string SQL)
        {
            DataTable dtTemp = new DataTable();
            OracleConnection cnn = new OracleConnection("DATA SOURCE=192.168.0.4/Orfeo2; USER ID=USR_CONSULTA26; PASSWORD=S4v2Th#6p");
            using (cnn)
            {
                cnn.Open();
                if ((cnn.State) > 0)
                {
                    OracleCommand cmd = new OracleCommand(SQL, cnn);                
                    OracleDataAdapter da = null;               
                    da = new OracleDataAdapter(cmd);
                    da.Fill(dtTemp);
                    cnn.Close();                   
                }
            }
            return dtTemp;
        }
    }
}

