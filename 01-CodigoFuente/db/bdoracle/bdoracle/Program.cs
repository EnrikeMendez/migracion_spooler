using Oracle.ManagedDataAccess.Client;
using System;
using System.Configuration;
using System.Data;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Runtime.Intrinsics.X86;
using System.Data.Common;
using System.Reflection.Metadata;
using System.Security.Cryptography;
using System.Windows.Input;



//OracleConnection cnn = new OracleConnection("DATA SOURCE=192.168.0.4/Orfeo2; USER ID=USR_CONSULTA26; PASSWORD=S4v2Th#6p");
OracleConnection cnn = new OracleConnection("DATA SOURCE=192.168.0.140/ORFEODES; USER ID=USR_RS_COEX; PASSWORD=RyK3#58pDf");
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


        /*
         cmd.CommandType = CommandType.StoredProcedure;
                cmd.CommandType = CommandType.Text;
        */
        try
        {
            //sp = "logis.SPG_PRUEBA_CARGA_MASIVA.p_PRUEBA_NUMBER_P_S";
            sp = "logis.SPG_PRUEBA_INVOCACIONES.f_PRUEBA_NUMBER_P_S";


            OracleCommand cmd = new OracleCommand(sp, cnn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("PARAMETRO_1", OracleDbType.Int64).Value = 2;
            cmd.Parameters.Add("PARAMETRO_2", OracleDbType.Varchar2, 5).Value = "valor";
            cmd.Parameters.Add("PARAMETRO_4", OracleDbType.Int32).Direction = ParameterDirection.Output;
            cmd.Parameters.Add("PARAMETRO_5", OracleDbType.Varchar2, 10).Direction = ParameterDirection.Output;
            Console.WriteLine("*********** " + sp + " ***************");
            OracleDataReader reader = cmd.ExecuteReader();
            string PARAMETRO_4 = cmd.Parameters["PARAMETRO_4"].Value.ToString();
            string PARAMETRO_5 = cmd.Parameters["PARAMETRO_5"].Value.ToString();
            Console.WriteLine("valor es PARAMETRO_4 = " + PARAMETRO_4);
            Console.WriteLine("valor es PARAMETRO_5= " + PARAMETRO_5);

        }
        catch
        {

        }

        /*
        try
        {
            //sp = "select SC_REPORTES.GEN_REP_CLAVE name  from dual";
            sp = "select SC_REPORTES.GEN_REP_CLAVE name  from dual";


            OracleCommand cmd = new OracleCommand(sp, cnn);
            //cmd.CommandType = CommandType.StoredProcedure;
            //cmd.Parameters.Add("Return_Value", OracleType.VarChar, 100).Direction = ParameterDirection.Output;
            //cmd.Parameters.Add("RETURN", OracleType.VarChar, 10).Direction = ParameterDirection.ReturnValue;
            // cmd.Parameters.Add("RETURN", OracleType.VarChar, 4000).Direction = ParameterDirection.ReturnValue;

            // cmd.ExecuteNonQuery();
            OracleDataReader reader = cmd.ExecuteReader();
            OracleDataAdapter da1 = new OracleDataAdapter(cmd);
            DataTable dtTemp1 = new DataTable();
            Console.WriteLine("****************************");
            da1.Fill(dtTemp1);
            Console.WriteLine("*********** " + sp + " *****************");

            for (i = 0; i < dtTemp1.Columns.Count; i++)
            {
                Console.WriteLine(" GEN_REP_CLAVE valor  es " + dtTemp1.Columns[i].ColumnName);
            }
            for (int j = 0; j < dtTemp1.Rows.Count; j++)
            {

                // Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
                Console.WriteLine(" GEN_REP_CLAVE valor  es " + dtTemp1.Rows[j]["name"].ToString());
            }

        }
        catch (Exception e) { Console.WriteLine(e.Message); }
        */

        try
        {

            sp = "logis.SPG_PRUEBA_INVOCACIONES.F_PRUEBA_NUMBER_P_S";
            OracleCommand cmd = new OracleCommand(sp, cnn);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.Parameters.Add("RETURN", OracleDbType.Varchar2, 10).Direction = ParameterDirection.ReturnValue;
            cmd.Parameters.Add("PARAMETRO_1", OracleDbType.Int32).Value = 2;
            cmd.Parameters.Add("PARAMETRO_2", OracleDbType.Varchar2, 10).Value = "valor";
            cmd.Parameters.Add("PARAMETRO_4", OracleDbType.Int32).Direction = ParameterDirection.Output;
            cmd.Parameters.Add("PARAMETRO_5", OracleDbType.Varchar2, 10).Direction = ParameterDirection.Output;
            // string job_no = (string)cmd.Parameters["PARAMETRO_4"].Value;
            // Console.WriteLine("valor es = " +  job_no);
            Console.WriteLine("*********** " + sp + " ***************");

            OracleDataReader reader = cmd.ExecuteReader();
            string PARAMETRO_4 = cmd.Parameters["PARAMETRO_4"].Value.ToString();
            string PARAMETRO_5 = cmd.Parameters["PARAMETRO_5"].Value.ToString();
            string RETURN = cmd.Parameters["RETURN"].Value.ToString();
            Console.WriteLine("valor es PARAMETRO_4 = " + PARAMETRO_4);
            Console.WriteLine("valor es PARAMETRO_5= " + PARAMETRO_5);
            Console.WriteLine("valor es RETURN= " + RETURN);
        }
        catch (Exception e) { Console.WriteLine(e.Message); }

        try
        {
            OracleParameter op = null;


            sp = "SC_DIST.SPG_RS_COEX.P_RS_GSK_PEDIMENTOS";

            OracleCommand cmd = new OracleCommand(sp, cnn);
            cmd.CommandType = CommandType.StoredProcedure;
            op = new OracleParameter("p_Cur_GSK", OracleDbType.RefCursor);
            op.Direction = ParameterDirection.Output;
            op.ParameterName = "p_Cur_GSK";
            cmd.Parameters.Add(op);

            op = new OracleParameter("v_Mensaje", OracleDbType.Varchar2);
            op.Direction = ParameterDirection.Output;
            op.Size = 4000;
            op.ParameterName = "v_Mensaje";
            cmd.Parameters.Add(op);

            op = new OracleParameter("v_Codigo_Error", OracleDbType.Int32);
            op.Direction = ParameterDirection.Output;
            op.Size = 5;
            op.ParameterName = "v_Codigo_Error";
            cmd.Parameters.Add(op);


            /*
            cmd.Parameters.Add(new OracleParameter("p_Cur_GSK"     , OracleType.Cursor)).Direction = ParameterDirection.Output;
            cmd.Parameters.Add(new OracleParameter("v_Mensaje"     , OracleType.VarChar,4000)).Direction = ParameterDirection.Output;
            cmd.Parameters.Add(new OracleParameter("v_Codigo_Error", OracleType.Number)).Direction = ParameterDirection.Output;
            */
            //cmd.Parameters.Add("p_Cur_GSK").Direction =  ParameterDirection.Output;
            //cmd.Parameters.Add("v_Mensaje", OracleType.VarChar,4000).Direction = ParameterDirection.Output;
            //cmd.Parameters.Add("v_Codigo_Error", OracleType.Number).Direction = ParameterDirection.Output; 
            /*

            cmd.Parameters.Add("v_Mensaje", OracleType.LongVarChar, 4000).Direction = ParameterDirection.Output;
            cmd.Parameters.Add("v_Codigo_Error", OracleType.Number).Direction = ParameterDirection.Output;
            */



            Console.WriteLine("****************************");
            //   cmd.ExecuteNonQuery();
            // OracleDataReader reader = cmd.ExecuteReader();
            OracleDataAdapter da1 = new OracleDataAdapter(cmd);
            DataTable dtTemp1 = new DataTable();

            da1.Fill(dtTemp1);
            Console.WriteLine("*********** " + sp + " *****************");

            for (i = 0; i < dtTemp1.Columns.Count - 1; i++)
            {
                Console.WriteLine(" Titulo " + dtTemp1.Columns[i].ColumnName);
                for (int j = 0; j < dtTemp1.Rows.Count; j++)
                {

                    // Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
                    Console.WriteLine(" Detalle " + dtTemp1.Rows[j][i].ToString());
                }
            }


        }
        catch (Exception e) { Console.WriteLine(e.Message); }
        try
        {

            sp = "logis.SPG_PRUEBA_INVOCACIONES.F_PRUEBA_NUMBER_P_S";
            //            sp = "BEGIN v_salida:= logis.SPG_PRUEBA_INVOCACIONES.F_PRUEBA_NUMBER_P_S(PARAMETRO_1, PARAMETRO_2, PARAMETRO_4, PARAMETRO_5); END";
            OracleCommand cmd = new OracleCommand(sp, cnn);
            cmd.CommandType = CommandType.StoredProcedure;


            cmd.Parameters.Add("v_salida", OracleDbType.NVarchar2, 10).Direction = ParameterDirection.ReturnValue;
            //cmd.Parameters.Add("retval", OracleType.Int16, 10, ParameterDirection.ReturnValue);
            cmd.Parameters.Add("PARAMETRO_1", OracleDbType.Int32).Value = 2;
            cmd.Parameters.Add("PARAMETRO_2", OracleDbType.NVarchar2, 10).Value = "valor";
            cmd.Parameters.Add("PARAMETRO_4", OracleDbType.Int32).Direction = ParameterDirection.Output;
            cmd.Parameters.Add("PARAMETRO_5", OracleDbType.NVarchar2, 10).Direction = ParameterDirection.Output;

            cmd.Parameters.Add("PARAMETRO_1", OracleDbType.Int32).Value = 2;

            Console.WriteLine("****************************");
            //  cmd.ExecuteNonQuery();
            OracleDataReader reader = cmd.ExecuteReader();
            OracleDataAdapter da1 = new OracleDataAdapter(cmd);
            DataTable dtTemp1 = new DataTable();

            da1.Fill(dtTemp1);
            Console.WriteLine("*********** " + sp + " *****************");

            for (i = 0; i < dtTemp1.Columns.Count; i++)
            {
                Console.WriteLine(" GEN_REP_CLAVE valor  es " + dtTemp1.Columns[i].ColumnName);
            }
            for (int j = 0; j < dtTemp1.Rows.Count - 1; j++)
            {

                // Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
                Console.WriteLine(" GEN_REP_CLAVE valor  es " + dtTemp1.Rows[j]["name"].ToString());
            }

        }
        catch { }

        try
        {
            OracleParameter op = null;
            // OracleDataReader dr = null;
            sp = "LOGIS.SPG_PRUEBA_INVOCACIONES.F_PRUEBA_BOOLEAN";

            OracleCommand cmd = new OracleCommand(sp, cnn);
            cmd.CommandType = CommandType.StoredProcedure;
            // cmd.Parameters.Add("v_salida", OracleDbType.NVarchar2, 10).Direction = ParameterDirection.ReturnValue;

            //  cmd.Parameters.Add(new OracleParameter("v_salida", OracleDbType.Boolean)).Direction = ParameterDirection.Output;
            //  cmd.CommandType = CommandType.StoredProcedure;
            op = new OracleParameter("v_salida", OracleDbType.Int16);
            op.Direction = ParameterDirection.ReturnValue;
            op.ParameterName = "v_salida";
            cmd.Parameters.Add(op);
            Console.WriteLine("****************************");
            //cmd.ExecuteNonQuery();
            OracleDataReader reader = cmd.ExecuteReader();


        }
        catch (Exception e) { Console.WriteLine(e.Message); }

        DataTable dtTemp = new DataTable();
        OracleDataAdapter da;
        try
        {
            //sp = "select LOGIS.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_VARCHAR name from dual";
            sp = "select LOGIS.SPG_PRUEBA_INVOCACIONES.F_PRUEBA_VARCHAR name from dual";

            OracleCommand cmd1 = new OracleCommand(sp, cnn);
            da = new OracleDataAdapter(cmd1);


            da.Fill(dtTemp);
            Console.WriteLine("*********** " + sp + " *****************");

            for (i = 0; i < dtTemp.Columns.Count; i++)
            {
                Console.WriteLine(" valor  es " + dtTemp.Columns[i].ColumnName);
            }
            for (int j = 0; j < dtTemp.Rows.Count; j++)
            {
                // Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
                Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
            }

            da = null;
            dtTemp = null;
        }
        catch { }
        try
        {
            //sp = "select LOGIS.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_NUMBER name from dual ";
            sp = "select LOGIS.SPG_PRUEBA_INVOCACIONES.F_PRUEBA_NUMBER name from dual ";

            OracleCommand cmd3 = new OracleCommand(sp, cnn);
            da = new OracleDataAdapter(cmd3);
            dtTemp = new DataTable();
            da.Fill(dtTemp);
            Console.WriteLine("*********** " + sp + " *****************");

            for (i = 0; i < dtTemp.Columns.Count; i++)
            {
                Console.WriteLine(" valor  es " + dtTemp.Columns[i].ColumnName);
            }
            for (int j = 0; j < dtTemp.Rows.Count; j++)
            {

                // Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
                Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
            }

            da = null;
            dtTemp = null;
        }
        catch { }

        //sp = "select LOGIS.SPG_PRUEBA_CARGA_MASIVA.F_PRUEBA_NUMBER_P_E (3) as name from dual ";
        sp = "select LOGIS.SPG_PRUEBA_INVOCACIONES.F_PRUEBA_NUMBER_P_E (3) as name from dual ";


        try
        {
            OracleCommand cmd4 = new OracleCommand(sp, cnn);
            da = new OracleDataAdapter(cmd4);
            dtTemp = new DataTable();
            da.Fill(dtTemp);
            Console.WriteLine("*********** " + sp + " *****************");

            for (i = 0; i < dtTemp.Columns.Count; i++)
            {
                Console.WriteLine(" valor  es " + dtTemp.Columns[i].ColumnName);
            }
            for (int j = 0; j < dtTemp.Rows.Count; j++)
            {

                // Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
                Console.WriteLine(" valor  es " + dtTemp.Rows[j]["name"].ToString());
            }
        }
        catch { }

        cnn.Close();
    }
    else
        Console.WriteLine("Conexión falló");
}
Console.WriteLine("Oprimar cualquier tecla para terminar");
Console.ReadKey();