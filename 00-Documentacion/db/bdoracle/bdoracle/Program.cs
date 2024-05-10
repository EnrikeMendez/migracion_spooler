using System.Data.OracleClient;
using System;
using System.Configuration;
using System.Data;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Runtime.Intrinsics.X86;
using System.Data.Common;
using System.Reflection.Metadata;
using System.Security.Cryptography;


OracleConnection cnn = new OracleConnection("DATA SOURCE=192.168.0.4/Orfeo2; USER ID=USR_CONSULTA26; PASSWORD=S4v2Th#6p");
Console.WriteLine("Conectar a base de Datos Oracle");
string sp = "select name from rep_reporte where id_rep=14 order by 1";
//sp = "select LOGIS.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_VARCHAR name from dual ";
//sp = "select LOGIS.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_NUMBER name from dual ";
//sp = "select LOGIS.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_NUMBER_P_E (3) as name from dual ";
sp = "logis.SPG_PRUEBA_CARGA_MASIVA.p_PRUEBA_NUMBER_P_S";

/*
sp = "set SERVEROUTPUT on "+
    "declare  "+
     "   name varchar2(4000); " +
     "V_PARAMETRO_4 NUMBER; " +
     "V_PARAMETRO_5 VARCHAR2(4000); " +
     "begin  " +
     " name := logis.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_NUMBER_P_S(PARAMETRO_1 => 2   " +
     "                                               , PARAMETRO_2 => 'VALOR'       " +
     "                                               , PARAMETRO_4 => V_PARAMETRO_4 " +
     "                                              , PARAMETRO_5 => V_PARAMETRO_5  2" +
     " dbms_output.put_line( v_salida); " +
     " end ";
*/
//sp = "begin :RETURN := logis.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_NUMBER_P_S(:PARAMETRO_1,:PARAMETRO_2,:PARAMETRO_4,:PARAMETRO_5); ";
//sp = "logis.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_NUMBER_P_S";

using (cnn)
{
    int i = 0;
    cnn.Open();
    if ((cnn.State) > 0)
    {
        
        Console.WriteLine("Conexión OK!");
        OracleCommand cmd = new OracleCommand(sp, cnn);

        /*
         cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandType = CommandType.Text;
        */
        ////StoredProcedure
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.Add("PARAMETRO_1", OracleType.Int32).Value = 2;
        cmd.Parameters.Add("PARAMETRO_2", OracleType.VarChar, 5).Value = "valor";
        cmd.Parameters.Add("PARAMETRO_4", OracleType.Int32).Direction = ParameterDirection.Output;
        cmd.Parameters.Add("PARAMETRO_5", OracleType.VarChar, 10).Direction = ParameterDirection.Output;
        Console.WriteLine("****************************");
        OracleDataReader reader = cmd.ExecuteReader();
        int PARAMETRO_4    = (int)cmd.Parameters["PARAMETRO_4"].Value;
        string PARAMETRO_5 = (string)cmd.Parameters["PARAMETRO_5"].Value;
        Console.WriteLine("valor es PARAMETRO_4 = " + PARAMETRO_4);
        Console.WriteLine("valor es PARAMETRO_5= " + PARAMETRO_5);

        /*      
         cmd.CommandType = CommandType.StoredProcedure;
         cmd.Parameters.Add("RETURN", OracleType.VarChar, 10).Direction = ParameterDirection.ReturnValue;
         cmd.Parameters.Add("PARAMETRO_1", OracleType.Int32).Value = 2;
         cmd.Parameters.Add("PARAMETRO_2", OracleType.VarChar,5).Value = "valor";
         cmd.Parameters.Add("PARAMETRO_4", OracleType.Int32).Direction = ParameterDirection.Output;
         cmd.Parameters.Add("PARAMETRO_5", OracleType.VarChar, 10).Direction = ParameterDirection.Output;           
         // string job_no = (string)cmd.Parameters["PARAMETRO_4"].Value;
         // Console.WriteLine("valor es = " +  job_no);
         Console.WriteLine("****************************");
        // OracleDataAdapter da = new OracleDataAdapter(cmd);
         OracleDataReader reader= cmd.ExecuteReader(); 


         while (reader.Read())
         {
             if (i == 0)
             {
                 Console.WriteLine("{0}\t ", reader.GetName(0));
                 Console.WriteLine("****************************");
             }
             Console.WriteLine("{0}\t ", reader.GetInt32(0));
             i++;
         }
    */

        /*
        DataTable dtTemp = new DataTable();
        da.Fill(dtTemp);
        Console.WriteLine("****************************");
        cnn.Close();
        for (i= 0; i < dtTemp.Columns.Count; i++)
        {
            Console.WriteLine(" valor  es " + dtTemp.Columns[i].ColumnName);
        }
        for (int j = 0; j < dtTemp.Rows.Count; j++)
        {

            // Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
            Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
        }
        */
    }
    else
        Console.WriteLine("Conexión falló");
}
Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();
