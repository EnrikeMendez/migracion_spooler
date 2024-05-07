using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Oracle.ManagedDataAccess.Client;
using System.Data;
using System.Reflection.PortableExecutable;
using System.Linq.Expressions;


namespace serverreports
{

    internal class DM
    {
        public OracleDataReader datos(string SQL, OracleConnection cnn)
        {
            OracleDataReader reader=null;
                if ((cnn.State) > 0)
                {
                   OracleCommand cmd = new OracleCommand(SQL, cnn);
                    reader = cmd.ExecuteReader();
                }
            return reader;         
        }

        public OracleConnection bd()
        {
            OracleConnection cnn = new OracleConnection("DATA SOURCE=192.168.0.4/Orfeo2; USER ID=USR_CONSULTA26; PASSWORD=S4v2Th#6p");
            return cnn;
        }

    }
}
