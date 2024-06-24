using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Data;
using System.Reflection.PortableExecutable;
using System.Linq.Expressions;
using Oracle.ManagedDataAccess.Client;
using Microsoft.Extensions.Configuration;
using System.Configuration;
using System.Reflection;
using System.Data.Odbc;
using System.Data.OleDb;
using System.Xml.Linq;
using DocumentFormat.OpenXml.Vml;
using DocumentFormat.OpenXml.Wordprocessing;
using System.IO.Compression;
using DocumentFormat.OpenXml.Spreadsheet;
using ConfigurationManager = System.Configuration.ConfigurationManager;

namespace serverreports;

internal class DM
{
    Utilerias util = new Utilerias();
    public DataTable datos(string SQL)
    {
        DataTable dtTemp = new DataTable();
        OracleConnection cnn = new OracleConnection(conecBD());
        
        try
        {
            using (cnn)
            {
                cnn.Open();
                if ((cnn.State) > 0)
                {
                    OracleCommand cmd = new OracleCommand(SQL, cnn);
                    OracleDataAdapter da = new OracleDataAdapter(cmd);
                    da.Fill(dtTemp);
                    cnn.Close();
                }
            }
        }
        catch (Exception ex)
        {

            if (ex.HResult == -2147467261)
                Console.WriteLine("No Existe la carpeta UserScrets " + ex.HResult);
            else
                Console.WriteLine(ex.Message + " -var conex *" + conecBD() + "* " + ex.HResult);
        }   
        return dtTemp;
    }

    public DataTable datos_sp1(string SQL)
    {
        DataTable dtTemp = new DataTable();
        OracleConnection cnn = new OracleConnection(conecBD());
        try
        {
            using (cnn)
        {
            cnn.Open();
            if ((cnn.State) > 0)
            {
                OracleCommand cmd = new OracleCommand(SQL, cnn);
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add(new OracleParameter("p_Cur_GSK", OracleDbType.RefCursor)).Direction = ParameterDirection.Output;
                cmd.Parameters.Add(new OracleParameter("v_Mensaje", OracleDbType.NVarchar2, 4000)).Direction = ParameterDirection.Output;
                cmd.Parameters.Add(new OracleParameter("v_Codigo_Error", OracleDbType.Int64)).Direction = ParameterDirection.Output;
                OracleDataAdapter da1 = new OracleDataAdapter(cmd);
                da1.Fill(dtTemp);
            }
        }
        }
        catch (Exception ex)
        {

            if (ex.HResult == -2147467261)
                Console.WriteLine("No Existe la carpeta UserScrets " + ex.HResult);
            else
                Console.WriteLine(ex.Message + " -var conex *" + conecBD() + "* " + ex.HResult);
        }
        return dtTemp;
    }

    private string conecBD()
    {
        var orfeo = "Error";
        try
        {
            var configuration = new ConfigurationBuilder()
                                              .AddUserSecrets(Assembly.GetExecutingAssembly())
                                              .Build();
            //orfeo = configuration["Orfeo2"];
            orfeo = configuration["ORFEODES"];
            // toma el valor de app.config
            //  orfeo = ConfigurationManager.ConnectionStrings["Orfeo2"].ToString();
            //  orfeo = ConfigurationManager.ConnectionStrings["ORFEODES"].ToString();

        }
        catch (Exception ex)
        {
            orfeo = orfeo + ex.Message;
        }
        return orfeo;
    }
    public DataTable Main_rep(string nom_proc, string id_cron, int? vs=0, string? addsq = "")
    {
        DataTable dtTemp = new DataTable();
        switch (nom_proc)
        {
            case "main_rp_cron":
                dtTemp = datos(main_rp_cron(id_cron.ToString(), vs, addsq));
                break;
            case "main_mail_contact":
                dtTemp = datos(main_mail_contact(id_cron.ToString(), vs));
                break;
            case "main_num_param":
                dtTemp = datos(main_num_param(id_cron.ToString(), vs));                
                break;
            case "main_datos_rep":
                dtTemp = datos(main_datos_rep(id_cron.ToString(), vs, addsq));
                break;
        }
        return dtTemp;
    }

    public string /*DataTable*/ main_rp_cron(string id_cron, int? vs = 0, string? addsq = "")
    {
        string SQL = " select rep.id_rep, rep.ID_CRON, rep.NAME, rep.CONFIRMACION, rep.FRECUENCIA,\n " +
                     " rep.cliente, cli.clistatus, cli.cliclef || ' - ' || InitCap(cli.clinom) cli_nom  @sqladd            \n " +
                     " , to_char(LAST_CONF_DATE_1, 'mm/dd/yyyy')  as fecha_1, to_char(LAST_CONF_DATE_2, 'mm/dd/yyyy') as fecha_2      \n " +
                     " , cli.CLICLEF || ' - ' || InitCap(cli.CLINOM) nomcli_err, rep.IP_ADDRESS IP_ADDRESS_err, rep.IP_NAME IP_NAME_err     \n " +
                     " from rep_detalle_reporte rep inner join eclient cli on cli.cliclef= rep.CLIENTE   \n " +
                     " Where rep.ID_CRON =  {0} ";

        //DataTable dtTemp = new DataTable();
        //SQL = SQL.Replace("@id_cron", "" + id_cron + "");
        SQL = string.Format(SQL, id_cron);
        if (vs == 1) { Console.WriteLine(SQL.Replace("@sqladd", "" + addsq + "") + "\n"); }
        //dtTemp = datos(SQL.Replace("@id_cron", "" + id_cron + ""));
        return SQL.Replace("@sqladd", "" + addsq + "");
        /*return dtTemp*/
    }

    public string main_mail_contact(string id_cron, int? vs = 0)
    {
        string SQL = " SELECT REP.NAME, DEST.NOMBRE, DEST.MAIL \n" +
        "  FROM REP_DETALLE_REPORTE REP \n" +
        "  inner join  REP_DEST_MAIL DEST_M on REP.MAIL_ERROR = DEST_M.ID_DEST_MAIL \n" +
        "  inner join  REP_MAIL DEST   on DEST_M.ID_DEST = DEST.ID_MAIL \n" +
        "  WHERE status = 1 \n" +
        "  AND REP.ID_CRON = {0}";
        if (vs == 1) { Console.WriteLine(string.Format(SQL, id_cron) + "\n"); }
        return string.Format(SQL, id_cron);
    }

    public string main_num_param(string id_cron, int? vs = 0)
    {
        string SQL = " SELECT REPORT.NUM_OF_PARAM  \n "
                     + " FROM REP_REPORTE REPORT inner join REP_DETALLE_REPORTE REP on REPORT.ID_REP = REP.ID_REP \n "
                     + " WHERE REP.ID_CRON = {0}";
        /*
        string SQL1 = " update rep_chron set in_progress=0  \n "
                      + " where id_rapport= @id_cron ";
        */     
        if (vs == 1) { Console.WriteLine(string.Format(SQL, id_cron) + "\n"); }       
        return string.Format(SQL, id_cron);        
    }

    public string main_datos_rep(string id_cron, int? vs = 0, string? addsq = "")
    {
        string SQL = " SELECT REP.NAME, REP.CLIENTE \n"
                    + " , REP.FILE_NAME, REP.CARPETA \n"
                     + " , CLI.CLINOM \n"
                     + " , mail.NOMBRE, mail.MAIL \n"
                     + " , REPORT.COMMAND \n"
                     + " , REP.DAYS_DELETED \n"
                     + " , REPORT.NUM_OF_PARAM \n"
                     + " , REP.DEST_MAIL, to_char(REP.LAST_CONF_DATE_1, 'mm/dd/yyyy') LAST_CONF_DATE_1, to_char(REP.LAST_CONF_DATE_2, 'mm/dd/yyyy') LAST_CONF_DATE_2 \n"
                     + "    @sqladd \n"
                     + "  , mail.client_num \n"
                     + "  , REPORT.ID_REP, REPORT.SUBCARPETA \n"
                     + "  , REP.CREATED_BY \n"
                     + "  ,TERCERO \n"
                     + "  FROM REP_DETALLE_REPORTE REP \n"
                     + "  , ECLIENT CLI \n"
                     + "  , REP_DEST_MAIL DEST \n"
                     + "  , REP_MAIL MAIL \n"
                     + "  , REP_REPORTE REPORT \n"
                     + "  WHERE REP.CLIENTE = CLI.CLICLEF(+) \n"
                     + "  AND REP.ID_CRON ={0} \n"
                     + "  AND mail.ID_MAIL(+) = DEST.ID_DEST \n"
                     + "  AND DEST.ID_DEST_MAIL(+) = REP.MAIL_OK \n"
                     + "  AND REPORT.ID_REP = REP.ID_REP \n"
                     + "  AND NVL(mail.status, 1) = 1  \n"
                     + "Union All \n"
                     + "SELECT REP.NAME, REP.CLIENTE \n"
                     + "  , REP.FILE_NAME, REP.CARPETA \n"
                     + "  , CLI.CLINOM  \n"
                     + "  , mail.NOMBRE, mail.MAIL \n"
                     + "  , REPORT.COMMAND \n"
                     + "  , REP.DAYS_DELETED \n"
                     + "  , REPORT.NUM_OF_PARAM \n"
                     + "  , REP.DEST_MAIL, to_char(REP.LAST_CONF_DATE_1, 'mm/dd/yyyy') LAST_CONF_DATE_1, to_char(REP.LAST_CONF_DATE_2, 'mm/dd/yyyy') LAST_CONF_DATE_2 \n"
                     + "    @sqladd \n"
                     + " , mail.client_num \n"
                     + " , REPORT.ID_REP, REPORT.SUBCARPETA \n"
                     + " , REP.CREATED_BY \n"
                     + " ,TERCERO \n"
                     + " FROM REP_DETALLE_REPORTE REP \n"
                     + " , ECLIENT CLI \n"
                     + " , REP_DEST_MAIL DEST \n"
                     + " , REP_MAIL MAIL \n"
                     + " , REP_REPORTE REPORT \n"
                     + " WHERE REP.CLIENTE = CLI.CLICLEF(+) \n"
                     + " AND REP.ID_CRON ={0} \n"
                     + " AND  DEST.id_dest_mail=2888 \n"
                     + " AND mail.ID_MAIL(+) = DEST.ID_DEST \n"
                     + " AND REPORT.ID_REP = REP.ID_REP \n"
                     + " AND NVL(mail.status, 1) = 1  \n"
                     + " and REP.MAIL_OK is not null \n"
                     + " and not exists(  SELECT null FROM REP_DEST_MAIL DESTD, REP_MAIL MAILD \n"
                     + " Where DESTD.id_dest_mail = REP.MAIL_OK  \n"
                     + " AND maild.ID_MAIL = DESTD.ID_DEST \n"
                     + " AND maild.status = 1 ) \n"
                     + " order by CLIENT_NUM, TERCERO desc , NOMBRE ";
        //DataTable dtTemp = new DataTable();
        SQL = string.Format(SQL, id_cron);
        if (vs == 1) { Console.WriteLine(SQL.Replace("@sqladd", "" + addsq + "") + "\n"); }
        //dtTemp = datos(SQL.Replace("@id_cron", "" + id_cron + ""));
        return SQL.Replace("@sqladd", "" + addsq + "");
        /*return dtTemp*/
    }
   
    public string ejecuta_sql(string sql, int? vs = 1)
    {
        string result = "Error conexion";
        OracleConnection cnn = new OracleConnection(conecBD());
        try
        {
            using (cnn)
            {
                cnn.Open();
                if ((cnn.State) > 0)
                {
                    OracleCommand cmd = new OracleCommand(sql, cnn);
                    //cmd.ExecuteNonQuery();
                    if (vs == 1) Console.WriteLine(sql);
                    result = "1";
                }
            }
        }
        catch (Exception e)
        {
            result = e.Message;
        }
        return result;
    }

    public void log_SQL(string modulo, string accion, string instancia, int? vs = 0)
    {
        string SQL = "INSERT INTO EMODULOS_USADOS (MODULO, ACCION, INSTANCIA, USUARIO, FECHA) \n" +
                   " VALUES ('" + modulo.Substring(1, 100).Replace("'", "''") + "',\n '" + modulo.Substring(1, 200).Replace("'", "''") + "',\n '" + modulo.Substring(1, 50).Replace("'", "''") + "' "
                   + " ,\n USER, SYSDATE) ";
            ejecuta_sql(SQL, vs);
    }


    public string transmision_edocs_bosch(string Cliente, string Fecha_1, string Fecha_2, string impexp, string tipo_doc, string tp, int? vs = 0)
    {
        string SQL = " SELECT /*+ORDERED INDEX(PED IDX_PEDDATE) USE_NL(SGE PED)*/ FOL.FOLFOLIO Folio  \n"
              + "       , SGE.SGEDOUCLEF \"Aduana\"  \n"
              + "       , SUBSTR(SGE.SGEPEDNUMERO, 1, 4) \"Patente\"   \n"
              + "       , SUBSTR(SGE.SGEPEDNUMERO, 6, 7) \"Pedimento\"  \n"
              + "       , SGE.SGE_YCXCLEF \"Tipo Operación\"   \n"
              + "       , SGE.SGE_REDCLEF \"Clave\"   \n"
              + "       , TO_CHAR(SGE.SGEFECHA_PAGO, 'dd/mm/yyyy') \"Fecha Pago\" \n"
              + "       , COUNT(*) \"Total "+ util.iff(tipo_doc, "=", "C", "Coves", "Edocs") + "\"  \n"
              + "     FROM EPEDIMENTO PED    \n"
              + "       , ESAAI_M3_GENERAL SGE      \n"
              + "       , EFOLIOS FOL  \n"
              + "       , EDOCUMENTOS_SAT DSA  \n"
             + util.iff(tipo_doc, "<>", "C"
                  , "       , EDOCUMENTO_ANEXO DAX   \n"
                     + "       , ECATALOGO_ANEXOS CAX  \n"
                   , "")
              /*
             If tipo_doc <> "C" Then
               + "       , EDOCUMENTO_ANEXO DAX   \n"
               + "       , ECATALOGO_ANEXOS CAX  \n"
              End If      

               */

              + "  WHERE PED.PEDDATE BETWEEN TO_DATE('" + Fecha_1 + "', 'mm/dd/yyyy') AND TO_DATE('" + Fecha_2 + "','mm/dd/yyyy')+1   \n"
              + "    AND SGE.SGEFIRMA_ELECTRONICA IS NOT NULL    \n"
              + "    AND SGE.SGE_CLICLEF IN (" + Cliente + ")   \n"

              + "    AND SGE.SGE_YCXCLEF = " + tp + "   \n"
              + "    AND PED.PEDNUMERO = SGE.SGEPEDNUMERO    \n"
              + "    AND PED.PEDDOUANE = SGE.SGEDOUCLEF    \n"
              + "    AND PED.PEDANIO = SGE.SGEANIO    \n"
              + "    AND FOL.FOLCLAVE = PED.PEDFOLIO    \n"
              + util.iff(impexp, "<>", ""
                     , "    AND SGE.SGE_YCXCLEF = '" + impexp + "'  \n"
                     , "")
              /*             
               If impexp <> "" Then
                + "    AND SGE.SGE_YCXCLEF = '" & impexp & "'  \n"
               End If            
               */
              + "    AND DSA.DSA_SGECLAVE = SGE.SGECLAVE   \n"
              + "    AND DSA.DSA_EDOCUMENT IS NOT NULL  \n"

              + util.iff(tipo_doc, "<>", "C"
                     , "    AND DSA_DAXCLAVE = DAX.DAXCLAVE  \n"
                       + "    AND DAX.DAX_CAXCLAVE = CAX.CAXCLAVE  \n"
                       + "    AND NVL(CAX.CAX_ENVIO_ELEC,'S') <> 'N'  \n"
                     ,
                       "    AND DSA_DAXCLAVE IS NULL  \n"
                     )
             /* If tipo_doc<> "C" Then
                  + "    AND DSA_DAXCLAVE = DAX.DAXCLAVE  \n"
                  + "    AND DAX.DAX_CAXCLAVE = CAX.CAXCLAVE  \n"
                  + "    AND NVL(CAX.CAX_ENVIO_ELEC,'S') <> 'N'  \n"
               Else
                  + "    AND DSA_DAXCLAVE IS NULL  \n"
                End If
             */
             + " GROUP BY SGE.SGEDOUCLEF  \n"
             + "         ,SUBSTR(SGE.SGEPEDNUMERO, 1, 4)  \n"
             + "         ,SUBSTR(SGE.SGEPEDNUMERO, 6, 7)  \n"
             + "         ,SGE.SGE_YCXCLEF  \n"
             + "         ,SGE.SGE_REDCLEF  \n"
             + "         ,TO_CHAR(SGE.SGEFECHA_PAGO, 'dd/mm/yyyy')  \n"
             + "         ,FOLFOLIO  \n"
             + " UNION ALL  \n"
             + "  SELECT /*+ORDERED INDEX(PED IDX_PEDDATE) USE_NL(SGE PED)*/ FOL.FOLFOLIO  Folio \n"
             + "       , SGE.SGEDOUCLEF \"Aduana\"   \n"
             + "       , SUBSTR(SGE.SGEPEDNUMERO, 1, 4) \"Patente\"    \n"
             + "       , SUBSTR(SGE.SGEPEDNUMERO, 6, 7) \"Pedimento\"   \n"
             + "       , SGE.SGE_YCXCLEF \"Tipo Operación\"    \n"
             + "       , SGE.SGE_REDCLEF \"Clave\"    \n"
             + "       , TO_CHAR(SGE.SGEFECHA_PAGO, 'dd/mm/yyyy') \"Fecha Pago\"   \n"
             + "       , 0 \"Total "+ util.iff(tipo_doc, "=", "C", "Coves", "Edocs") + "\" \n"
             + "     FROM EPEDIMENTO PED     \n"
             + "       , ESAAI_M3_GENERAL SGE       \n"
             + "       , EFOLIOS FOL   \n"
             + "  WHERE PED.PEDDATE BETWEEN TO_DATE('" + Fecha_1 + "', 'mm/dd/yyyy') AND TO_DATE('" + Fecha_2 + "', 'mm/dd/yyyy')+1   \n"
             + "    AND SGE.SGEFIRMA_ELECTRONICA IS NOT NULL     \n"
             + "    AND SGE.SGE_CLICLEF IN (" + Cliente + ")   \n"
              + "    AND SGE.SGE_YCXCLEF = " + tp + "   \n"
             + "    AND PED.PEDNUMERO = SGE.SGEPEDNUMERO     \n"
             + "    AND PED.PEDDOUANE = SGE.SGEDOUCLEF     \n"
             + "    AND PED.PEDANIO = SGE.SGEANIO     \n"
             + "    AND FOL.FOLCLAVE = PED.PEDFOLIO     \n"
             + util.iff(impexp, "<>", ""
                     , "    AND SGE.SGE_YCXCLEF = '" + impexp + "'  \n"
                     , ""
                     )

             /*    If impexp <> "" Then
               + "    AND SGE.SGE_YCXCLEF = '" & impexp & "'  \n"
                 End If
              */
             + util.iff(tipo_doc, "<>", "C"
                 , "    AND NOT EXISTS (SELECT NULL   \n"
                   + "                      FROM EDOCUMENTOS_SAT DSA   \n"
                   + "                         , EDOCUMENTO_ANEXO DAX   \n"
                   + "                         , ECATALOGO_ANEXOS CAX   \n"
                   + "                     WHERE DSA.DSA_SGECLAVE = SGE.SGECLAVE  \n"
                   + "                       AND DSA_DAXCLAVE = DAX.DAXCLAVE  \n"
                   + "                       AND DAX.DAX_CAXCLAVE = CAX.CAXCLAVE  \n"
                   + "                       AND NVL(CAX.CAX_ENVIO_ELEC,'S') <> 'N')  \n"
                , "    AND NOT EXISTS (SELECT NULL   \n"
                   + "                      FROM EDOCUMENTOS_SAT DSA   \n"
                   + "                     WHERE DSA.DSA_SGECLAVE = SGE.SGECLAVE  \n"
                   + "                       AND DSA.DSA_DAXCLAVE IS NULL)  \n"
                 )

              /*       
                     If tipo_doc <> "C" Then
                         + "    AND NOT EXISTS (SELECT NULL   \n"
                         + "                      FROM EDOCUMENTOS_SAT DSA   \n"
                         + "                         , EDOCUMENTO_ANEXO DAX   \n"
                         + "                         , ECATALOGO_ANEXOS CAX   \n"
                         + "                     WHERE DSA.DSA_SGECLAVE = SGE.SGECLAVE  \n"
                         + "                       AND DSA_DAXCLAVE = DAX.DAXCLAVE  \n"
                         + "                       AND DAX.DAX_CAXCLAVE = CAX.CAXCLAVE  \n"
                         + "                       AND NVL(CAX.CAX_ENVIO_ELEC,'S') <> 'N')  \n"
                     Else
                         + "    AND NOT EXISTS (SELECT NULL   \n"
                         + "                      FROM EDOCUMENTOS_SAT DSA   \n"
                         + "                     WHERE DSA.DSA_SGECLAVE = SGE.SGECLAVE  \n"
                         + "                       AND DSA.DSA_DAXCLAVE IS NULL)  \n"
                     End If
           */
              + " GROUP BY SGE.SGEDOUCLEF   \n"
              + "         ,SUBSTR(SGE.SGEPEDNUMERO, 1, 4)   \n"
             + "         ,SUBSTR(SGE.SGEPEDNUMERO, 6, 7)   \n"
             + "         ,SGE.SGE_YCXCLEF   \n"
             + "         ,SGE.SGE_REDCLEF   \n"
             + "         ,TO_CHAR(SGE.SGEFECHA_PAGO, 'dd/mm/yyyy')   \n"
             + "         ,FOLFOLIO  \n"
             + " ORDER BY 1  \n";

        //DataTable dtTemp = new DataTable();
        if (vs == 1) { Console.WriteLine(SQL + "\n"); }
        return SQL;
    }
    public string trading_genera_GSK(string cliente, string? Fecha_1, string? Fecha_2, string? empresa, Int32? idCron, int? vs)//to_char(WCD.DATE_CREATED, 'dd/mm/yy')
    {
        string SQL_GSK = " SELECT  \n"//TO_CHAR(WEL.DATE_CREATED, 'DD/MM/YY') \"SHIP_DATE\"
             + "  NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA)\"SHIPMENT_NO\", '' \"CARRIER\", '' \"PLANNED_SHIPDATE\", to_date(WCD.DATE_CREATED) \"SHIP_DATE\", '' \"PLANNED_DELIVERY_DATE\", INITCAP(DIS.DISNOM) \"ORIGIN\", InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL ,NULL,NULL, ' C.P. ' || DISCODEPOSTAL)) \"ORIGIN_ADDRESS\",  \n"
             + "  INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')')\"ORIGIN_CITY\", INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE)) \"DESTINATION\", InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || '  ' || DIENUMINT || '  ' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' C.P. ' || DIECODEPOSTAL)) \"DESTINATION_ADDRESS\", \n"
             + "  INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')') DESTINATION_CITY, 'Road' \"MODE_\", WCD.WCD_FIRMA \"SHIPMENT_LINE#\", to_char(TO_DATE(WCD.DATE_CREATED), 'mm/dd/yyyy hh24:mi') \"CREATION_DATE\"\n"
             + "  FROM  \n"
             + "  WCROSS_DOCK WCD, EDIRECCIONES_ENTREGA DIE, ECLIENT_CLIENTE CCL, EDISTRIBUTEUR DIS, ECIUDADES CIU_ORI, EESTADOS EST_ORI, ECIUDADES CIU_DEST, EESTADOS EST_DEST, ETRANS_DETALLE_CROSS_DOCK TDCD, ETRANSFERENCIA_TRADING TRA, ETRANS_ENTRADA TAE  \n"
             + "  WHERE  \n"
             + " -- TRUNC(WCD.DATE_CREATED) BETWEEN TRUNC(sysdate -1) AND TRUNC(sysdate -1) AND WCD_CLICLEF in(20501,20502) AND NOT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) LIKE '%PRUEBA%' AND NOT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) LIKE '%SENSORES%'\n"
             + "  TRUNC(WCD.DATE_CREATED) BETWEEN TRUNC(sysdate -1) AND TRUNC(sysdate -1) AND WCD_CLICLEF in(" + cliente + ") AND NOT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) LIKE '%PRUEBA%' AND NOT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) LIKE '%SENSORES%'\n"
             + "  AND NOT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) LIKE '%TARIMAS%' AND DISCLEF = WCD.WCD_DISCLEF AND DIECLAVE = NVL(NVL(TDCD_DIECLAVE_ENT, TDCD_DIECLAVE), WCD_DIECLAVE_ENTREGA) AND CCLCLAVE = NVL(TDCD_CCLCLAVE, WCD.WCD_CCLCLAVE)  \n"
             + "  AND CIU_ORI.VILCLEF = DISVILLE AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO AND CIU_DEST.VILCLEF = DIEVILLE AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO AND TDCDCLAVE(+) = WCD.WCD_TDCDCLAVE AND TDCDSTATUS (+) = '1'  \n"
             + "  AND TRACLAVE(+) = WCD.WCD_TRACLAVE AND TRASTATUS (+) = '1' AND TAE_TRACLAVE(+) = WCD.WCD_TRACLAVE\n"
                      //  'ORP: Se integra subconsulta para obtener registros de LTL una vez que CD ya no este vigente
                      + "  UNION\n"
                      + "  SELECT\n"
                      + "    NVL(TDCD.TDCDFACTURA, WEL.WELFACTURA) \"SHIPMENT_NO\", '' \"CARRIER\", '' \"PLANNED_SHIPDATE\",\n"
                      + "    to_date(WEL.DATE_CREATED) \"SHIP_DATE\", '' \"PLANNED_DELIVERY_DATE\", INITCAP(DIS.DISNOM)  \"ORIGIN\",\n"
                      + "    INITCAP(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' C.P. ' || DISCODEPOSTAL)) \"ORIGIN_ADDRESS\",\n"
                      + "    INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')') \"ORIGIN_CITY\",\n"
                      + "    INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE)) \"DESTINATION\",\n"
                      + "    INITCAP( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || '  ' || DIENUMINT || '  ' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' C.P. ' || DIECODEPOSTAL)) \"DESTINATION_ADDRESS\",\n"
                      + "    INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')') \"DESTINATION_CITY\",\n"
                      + "    'ROAD' \"MODE_\", WEL.WEL_FIRMA \"SHIPMENT_LINE#\", to_char(TO_DATE(WEL.DATE_CREATED), 'mm/dd/yyyy hh24:mi') \"CREATION_DATE\"\n"
                      + "  FROM\n"
                      + "    WEB_LTL WEL,\n"
                      + "    EDIRECCIONES_ENTREGA DIE,\n"
                      + "    ECLIENT_CLIENTE CCL,\n"
                      + "    EDISTRIBUTEUR DIS,\n"
                      + "    ECIUDADES CIU_ORI,\n"
                      + "    EESTADOS EST_ORI,\n"
                      + "    ECIUDADES CIU_DEST,\n"
                      + "    EESTADOS EST_DEST,\n"
                      + "    ETRANS_DETALLE_CROSS_DOCK TDCD,\n"
                      + "    ETRANSFERENCIA_TRADING TRA,\n"
                      + "    ETRANS_ENTRADA TAE\n"
                      + "  WHERE 1=1\n"
                      + "    AND TRUNC(WEL.DATE_CREATED) BETWEEN TRUNC(SYSDATE -1) AND TRUNC(SYSDATE -1)\n"
                      + "    --AND WEL_CLICLEF IN(20501,20502,23488,23489)\n"
                      + "    AND WEL_CLICLEF IN(" + cliente + ",23488,23489)\n"
                      + "    AND NOT NVL(TDCD.TDCDFACTURA, WEL.WELFACTURA) LIKE '%PRUEBA%'\n"
                      + "    AND NOT NVL(TDCD.TDCDFACTURA, WEL.WELFACTURA) LIKE '%SENSORES%'\n"
                      + "    AND NOT NVL(TDCD.TDCDFACTURA, WEL.WELFACTURA) LIKE '%TARIMAS%'\n"
                      + "    AND DISCLEF = WEL.WEL_DISCLEF\n"
                      + "    AND DIECLAVE = NVL(NVL(TDCD_DIECLAVE_ENT, TDCD_DIECLAVE), WEL_DIECLAVE)\n"
                      + "    AND CCLCLAVE = NVL(TDCD_CCLCLAVE, WEL.WEL_CCLCLAVE)\n"
                      + "    AND CIU_ORI.VILCLEF = DISVILLE\n"
                      + "    AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO\n"
                      + "    AND CIU_DEST.VILCLEF = DIEVILLE\n"
                      + "    AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO\n"
                      + "    AND TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE\n"
                      + "    AND TDCDSTATUS (+) = '1'\n"
                      + "    AND TRACLAVE(+) = WEL.WEL_TRACLAVE\n"
                      + "    AND TRASTATUS (+) = '1'\n"
                      + "    AND TAE_TRACLAVE(+) = WEL.WEL_TRACLAVE\n";

        //DataTable dtTemp = new DataTable();
        if (vs == 1) { Console.WriteLine(SQL_GSK + "\n"); }
        return SQL_GSK;
    }
    public string porteos_tln(string cliente, string? Fecha_1, string? Fecha_2, string? empresa, Int32? idCron, int? vs = 0)
    {
      string SQL = "  SELECT  \n"
                + "  DISTINCT  \n"
                + "  TRA.TRACONS_GENERAL, TRA.TRACLAVE, TRA.TRA_CLICLEF CLICLEF, TDCD_PEDIDO_CLIENTE, TDCD.TDCDFACTURA, NVL(CCL.CCL_NOMBRE, WCCL.WCCL_NOMBRE) CLIENTE_FINAL, NVL(DIE.DIE_A_ATENCION_DE, WCCL.WCCLABREVIACION) SUCURSAL,  \n"
                + "  NVL(DIE.DIENOMBRE, WCCL.WCCL_NOMBRE) NOMBRE, NVL(CIU.VILNOM, CIUW.VILNOM) || ' (' || NVL(EST.ESTNOMBRE, ESTW.ESTNOMBRE) || ')' CIUDAD, TDCD_ORDEN_COMPRA, TAEFECHALLEGADA,  \n"
                + "  TDCD_FEC_CITA_PROGRAMADA, TCDC_CDAD_BULTOS, TDCDVOLUMEN, EAL.ALLCODIGO CEDIS, 'CROSS DOCK' CROSS_DOCK, TDCD.TDCDCLAVE, EXP.EXP_NUM_EXPEDICION, DXP.DXP_TIPO_ENTREGA, DIE.DIEVILLE, TDCDCOLLECT_PREPAID,  \n"
                + "  TRA.TRA_MEZTCLAVE_ORI, TRA.TRA_MEZTCLAVE_DEST, EALINFL.ALLCODIGO CED_DEST, TDCD_DXPCLAVE_ORI DXPCLAVE_ORI, TRA.TRA_ALLCLAVE, DXP.DXPCLAVE DXPCLAVE, CLINOM, TRA.CREATED_BY, TO_CHAR( (DXP_REC.DXP_FECHA_ENTREGA) , 'DD/MM/YYYY') F_ENTREGA, DXP_REC.DXP_AUTORIZA_RECHAZO AUTORIZA  \n"
                + "  FROM  (select * from ETRANSFERENCIA_TRADING where DATE_CREATED >= TRUNC(SYSDATE) - 360 ) TRA left join ( select * from ETRANS_DETALLE_CROSS_DOCK where DATE_CREATED >= TRUNC(SYSDATE) - 360  ) TDCD on (TDCD_TRACLAVE) = (TRA.TRACLAVE)  \n"
                + "  left join ECLIENT CLI on (CLICLEF) = (TRA_CLICLEF) left join (select * from EALMACENES_LOGIS ) EAL on (TRA.TRA_ALLCLAVE) = (eal.allclave) left join ECLIENT_CLIENTE CCL on (CCL.CCLCLAVE) = (TDCD_CCLCLAVE)  \n"
                + "  left join EDIRECCIONES_ENTREGA DIE on DIE.DIECLAVE = NVL((TDCD_DIECLAVE_ENT), (TDCD_DIECLAVE)) left join ECIUDADES CIU on  (CIU.VILCLEF) = (DIE.DIEVILLE) left join EESTADOS EST on (EST.ESTESTADO) = (CIU.VIL_ESTESTADO)  \n"
                + "  left join (select * from  ETRANS_ENTRADA where DATE_CREATED >= TRUNC(SYSDATE) - 360  ) TAE on (TAE_TRACLAVE) = (TRA.TRACLAVE) left join (select * from   EDET_EXPEDICIONES where DATE_CREATED >= TRUNC(SYSDATE) - 360  ) DXP on (DXP.DXP_TDCDCLAVE) = (TDCDCLAVE)  \n"
                + "  left join (select * from EEXPEDICIONES where DATE_CREATED >= TRUNC(SYSDATE) - 360 ) EXP on (EXP.EXPCLAVE) = (DXP.DXP_EXPCLAVE) left join (select * from WEB_LTL where DATE_CREATED >= TRUNC(SYSDATE) - 360  ) WEL on (WEL.WEL_TDCDCLAVE) = (TDCD.TDCDCLAVE)  \n"
                + "  left join WEB_CLIENT_CLIENTE WCCL on  (WCCL.WCCLCLAVE) = (WEL.WEL_WCCLCLAVE) left join ECIUDADES CIUW on (CIUW.VILCLEF) = (WCCL.WCCL_VILLE) left join EESTADOS ESTW on (ESTW.ESTESTADO) = (CIUW.VIL_ESTESTADO)  \n"
                + "  left join ( SELECT ETRANS_DETALLE_CROSS_DOCK.TDCDCLAVE,EDESTINOS_POR_RUTA.DER_ALLCLAVE FROM ETRANS_DETALLE_CROSS_DOCK , WEB_LTL , EDESTINOS_POR_RUTA WHERE  WEL_ID_OP = TDCD_ID_OP AND DER_VILCLEF = WEL_VILCLEF_DEST ) TDCDW on (TDCDW.TDCDCLAVE) = (TDCD.TDCDCLAVE)  \n"
                + "  left join ( SELECT max(DXPCLAVE) DXPCLAVE ,DXP_ID_OP,max(DXP_AUTORIZA_RECHAZO) DXP_AUTORIZA_RECHAZO, max(DXP_FECHA_ENTREGA)DXP_FECHA_ENTREGA , NVL(DXP_TINCLAVE, 0) FROM EDET_EXPEDICIONES  \n"
                //WHERE   DXP_TIPO_ENTREGA = 'DIRECTO' AND NVL(DXP_TINCLAVE, 0)  != 0 and not dxp_autoriza_rechazo is null and date_created >= trunc(sysdate) -360 group by DXP_ID_OP, NVL(DXP_TINCLAVE, 0) ) DXP_REC on --trim(DXP_REC.DXPCLAVE) = trim(TDCD.TDCDCLAVE) AND--        trim(DXP_REC.DXP_ID_OP) = trim(TDCD.TDCD_ID_OP)
                + "  WHERE   DXP_TIPO_ENTREGA = 'DIRECTO' AND NVL(DXP_TINCLAVE, 0)  != 0 and not dxp_autoriza_rechazo is null and date_created >= trunc(sysdate) -360 group by DXP_ID_OP, NVL(DXP_TINCLAVE, 0) ) DXP_REC on          trim(DXP_REC.DXP_ID_OP) = trim(TDCD.TDCD_ID_OP) \n"
                + "  left join EALMACENES_LOGIS EALINFL on (EALINFL.ALLCLAVE) = (TDCDW.DER_ALLCLAVE) WHERE EAL.ALLCLAVE = 1 AND TRA.TRACLAVE >= 17300000 AND TRA.TRASTATUS = '1' AND TRA.TRA_MEZTCLAVE_ORI = 0  \n"
                //AND TRA_MEZTCLAVE_DEST IN (24 ) AND TRA.TRA_ALLCLAVE = 1 --AND TRA.TRA_CLICLEF  in(select distinct tra_cliclef from ETRANSFERENCIA_TRADING )-- AND TRA.TRA_CLICLEF NOT IN (2896, 2897, 3195, 3196, 3109)  \n"
                + "  AND TRA_MEZTCLAVE_DEST IN (24 ) AND TRA.TRA_ALLCLAVE = 1  AND TRA.TRA_CLICLEF NOT IN (2896, 2897, 3195, 3196, 3109)  \n"
                + "  AND TRA.DATE_CREATED >= TRUNC(SYSDATE) - 360 AND TDCD_TRACLAVE = TRA.TRACLAVE AND TDCD.TDCDSTATUS = '1' AND TDCD_DXPCLAVE_ORI IS NOT NULL AND NOT EXISTS  \n"
                + "  (SELECT NULL FROM ETRANS_CONVERTIDOR_DET TCOD WHERE (TCOD.TCOD_TDCDCLAVE) = (TDCD.TDCDCLAVE) AND ROWNUM = 1)  \n"
                + "  AND NOT EXISTS (SELECT NULL FROM EDET_EXPEDICIONES WHERE (DXP_TDCDCLAVE) = (TDCD.TDCDCLAVE) AND DXP_NDCCLAVE IS NOT NULL AND ROWNUM = 1)  \n"
                + "  AND (EXISTS (SELECT  NULL FROM ETRANSFERENCIA_PALETA TDP, ETRANSFERENCIA_TRADING TRA2 WHERE (TDP.TDP_TDCDCLAVE) = (TDCD.TDCDCLAVE) AND (TRA2.TRACLAVE) = (TDP.TDP_TRACLAVE) AND TRA2.TRASTATUS = '1'  \n"
                + "  AND TRA2.TRA_MEZTCLAVE_DEST = 2 AND NOT EXISTS ( SELECT NULL FROM ETRANSFERENCIA_PALETA TDP3, ETRANSFERENCIA_TRADING TRA3 WHERE TDP3.TDP_PALCLAVE = TDP.TDP_PALCLAVE AND (TRA3.TRACLAVE) = (TDP3.TDP_TRACLAVE)  \n"
                + "  AND (TRA3.TRA_TRACLAVE) = (TRA2.TRACLAVE) AND (TRA3.TRASTATUS) = '1' AND TRA3.TRA_MEZTCLAVE_DEST = 21 AND ROWNUM = 1 ) AND ROWNUM = 1 ) OR NOT EXISTS (SELECT  NULL FROM ETRANSFERENCIA_PALETA TDP, ETRANSFERENCIA_TRADING TRA2  \n"
                + "  WHERE (TDP.TDP_TDCDCLAVE) = (TDCD.TDCDCLAVE) AND (TRA2.TRACLAVE) = (TDP.TDP_TRACLAVE) AND (TRA2.TRASTATUS) = '1' AND TRA2.TRA_MEZTCLAVE_DEST IN (97, 6, 7, 99, 57, 2) AND ROWNUM = 1)) AND trim(CLICLEF) = trim(TRA_CLICLEF)  \n";
        //DataTable dtTemp = new DataTable();
        if (vs == 1) { Console.WriteLine(SQL + "\n"); }
        return SQL;
    }

}

