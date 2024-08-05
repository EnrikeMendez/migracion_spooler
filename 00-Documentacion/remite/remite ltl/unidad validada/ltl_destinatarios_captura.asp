<% option explicit
%><!--#include file="include/include.asp"--><%
  dim array_usr, SQL, loginId
'verificar si existe un MD5 para la conexion
if Request("loginId") <> "" then
    SQL = "SELECT A.LOCLOGIN, A.LOCPASSWORD, B.LCD_CLICLEF, C.CLINOM, " & _
     "decode(B.LCD_CLICLEF, A.LOCCLIENTE,'checked') as checked, " & _
     " C.clistatus, A.locstatus, A.locdescripcion, B.LCD_DISCLEF, B.LCD_ALLCLAVE , UPPER(B.LCD_WEL_OBSERVACION)   " & _ 
     "FROM ELOGINCLIENTE A, eloginclientedetalle B , eclient C    " & _ 
     "WHERE A.LOCMD5 = '"& SQLEscape(Request("loginId")) & "' " & _
     "AND A.LOCLOGIN = B.LCD_LOCLOGIN  " & _ 
     "AND C.CLICLEF=B.LCD_CLICLEF " & _ 
     "order by A.LOCLOGIN, checked "

    array_usr = GetArrayRS(SQL)
    if IsArray(array_usr) then
        Session("array_client")= array_usr
        'guardamos el ID para los URL
        loginId = "&loginId=" & Request("loginId")
    end if
end if


call check_session()
dim i, array_tmp, viewSubmit
dim numLTL, recol_domicilio, entrega_domicilio, volumen, detalle_bultos
dim rst, fecha_recol, wcclclave, numWCCL
dim wccl_nombre, wccl_adresse1, wccl_adresse2, wccl_numext, wccl_numint, wccl_codepostal, wccl_ville, wccltelephone, wcclfax, wcclabreviacion, wccl_cliclef, wccl_estado, wcclcontacto, wcclcontacto_correo, wel_count, wccl_rfc
dim wccl_instr_entrega, wccl_cliclef_fact


wcclclave = Request("wcclclave")

if wcclclave <> "" then
'recuperacion de los datos
	SQL = "SELECT WCCL_NOMBRE " & VbCrlf
	SQL = SQL & "   ,WCCLABREVIACION " & VbCrlf
	SQL = SQL & "   ,WCCL_RFC " & VbCrlf
	SQL = SQL & "   , WCCL_ADRESSE1 " & VbCrlf
	SQL = SQL & "   , WCCL_ADRESSE2  " & VbCrlf
	SQL = SQL & "   , WCCL_NUMEXT " & VbCrlf
	SQL = SQL & "   , WCCL_NUMINT " & VbCrlf
	SQL = SQL & "   , WCCL_CODEPOSTAL " & VbCrlf
	SQL = SQL & "   , WCCL_VILLE " & VbCrlf
	SQL = SQL & "   , WCCLTELEPHONE " & VbCrlf
	SQL = SQL & "   , WCCLFAX " & VbCrlf
	SQL = SQL & "   , WCCL_CLICLEF  " & VbCrlf
	SQL = SQL & "   , EST.ESTESTADO  " & VbCrlf
	SQL = SQL & "   , WCCLCONTACTO  " & VbCrlf
	SQL = SQL & "   , WCCLCONTACTO_CORREO  " & VbCrlf
	SQL = SQL & "   , COUNT(WELCLAVE) wel_count  " & VbCrlf
	SQL = SQL & "   , WCCL_INSTR_ENTREGA  " & VbCrlf
	SQL = SQL & "   , WCCL_CLICLEF_FACT  " & VbCrlf
	SQL = SQL & " FROM WEB_CLIENT_CLIENTE  " & VbCrlf
	SQL = SQL & "   , ECIUDADES CIU  " & VbCrlf
	SQL = SQL & "   , EESTADOS EST  " & VbCrlf
	SQL = SQL & "   , WEB_LTL WEL  " & VbCrlf
	SQL = SQL & " WHERE WCCLCLAVE = " & wcclclave
	SQL = SQL & " AND EST.ESTESTADO = CIU.VIL_ESTESTADO   " & VbCrlf
	SQL = SQL & " AND CIU.VILCLEF = WCCL_VILLE   " & VbCrlf
	SQL = SQL & " AND WEL.WEL_WCCLCLAVE(+) = WCCLCLAVE   " & VbCrlf
	SQL = SQL & " GROUP BY WCCL_NOMBRE " & VbCrlf
	SQL = SQL & "   ,WCCLABREVIACION " & VbCrlf
	SQL = SQL & "   ,WCCL_RFC " & VbCrlf
	SQL = SQL & "   , WCCL_ADRESSE1 " & VbCrlf
	SQL = SQL & "   , WCCL_ADRESSE2  " & VbCrlf
	SQL = SQL & "   , WCCL_NUMEXT " & VbCrlf
	SQL = SQL & "   , WCCL_NUMINT " & VbCrlf
	SQL = SQL & "   , WCCL_CODEPOSTAL " & VbCrlf
	SQL = SQL & "   , WCCL_VILLE " & VbCrlf
	SQL = SQL & "   , WCCLTELEPHONE " & VbCrlf
	SQL = SQL & "   , WCCLFAX " & VbCrlf
	SQL = SQL & "   , WCCL_CLICLEF  " & VbCrlf
	SQL = SQL & "   , EST.ESTESTADO  " & VbCrlf
	SQL = SQL & "   , WCCLCONTACTO  " & VbCrlf
	SQL = SQL & "   , WCCLCONTACTO_CORREO  " & VbCrlf
	SQL = SQL & "   , WCCL_INSTR_ENTREGA  " & VbCrlf
	SQL = SQL & "   , WCCL_CLICLEF_FACT  " & VbCrlf
	
	array_tmp = GetArrayRS(SQL)
	if IsArray(array_tmp) then
		wccl_nombre = UCase(SQLescape(array_tmp(0,0)))
		wcclabreviacion = UCase(SQLescape(array_tmp(1,0)))
		wccl_rfc = UCase(SQLescape(array_tmp(2,0)))
		wccl_adresse1 = UCase(SQLescape(array_tmp(3,0)))
		wccl_adresse2 = UCase(SQLescape(array_tmp(4,0)))
		wccl_numext = UCase(SQLescape(array_tmp(5,0)))
		wccl_numint = UCase(SQLescape(array_tmp(6,0)))
		wccl_codepostal = UCase(SQLescape(array_tmp(7,0)))
		wccl_ville = UCase(SQLescape(array_tmp(8,0)))
		wccltelephone = UCase(SQLescape(array_tmp(9,0)))
		wcclfax = UCase(SQLescape(array_tmp(10,0)))
		wccl_cliclef = UCase(SQLescape(array_tmp(11,0)))
		wccl_estado = UCase(SQLescape(array_tmp(12,0)))
		wcclcontacto = UCase(SQLescape(array_tmp(13,0)))
		wcclcontacto_correo = UCase(SQLescape(array_tmp(14,0)))
		wel_count = UCase(SQLescape(array_tmp(15,0)))
		wccl_instr_entrega = UCase(SQLescape(array_tmp(16,0)))
		wccl_cliclef_fact = UCase(SQLescape(array_tmp(17,0)))
		
	end if


end if

if Request.Form("validar") = "validar" then
	if Request.Form("wel_count") = "0" then
		'si no hay LTL dadas de alta, podemos modificar todo
		wccl_nombre = UCase(SQLescape(Request.Form("wccl_nombre")))
		wcclabreviacion = UCase(SQLescape(Request.Form("wcclabreviacion")))
		wccl_rfc = UCase(SQLescape(Request.Form("wccl_rfc")))
		wccl_adresse1 = UCase(SQLescape(Request.Form("wccl_adresse1")))
		wccl_adresse2 = UCase(SQLescape(Request.Form("wccl_adresse2")))
		wccl_numext = UCase(SQLescape(Request.Form("wccl_numext")))
		wccl_numint = UCase(SQLescape(Request.Form("wccl_numint")))
		wccl_codepostal = UCase(SQLescape(Request.Form("wccl_codepostal")))
		wccl_ville = SQLescape(Request.Form("wccl_ville"))
		wccltelephone = UCase(SQLescape(Request.Form("wccltelephone")))
		wcclfax = UCase(SQLescape(Request.Form("wcclfax")))
		wccl_cliclef = Session("array_client")(2,0)
		wcclcontacto = UCase(SQLescape(Request.Form("wcclcontacto")))
		wcclcontacto_correo = UCase(SQLescape(Request.Form("wcclcontacto_correo")))
		wccl_instr_entrega = UCase(SQLescape(Request.Form("wccl_instr_entrega")))
		wccl_cliclef_fact = UCase(SQLescape(Request.Form("wccl_cliclef_fact")))
	else
		'si hay LTLs, entonces solo se puede actualizar el RFC (a menos que ya este capturado) o las instrucciones de entrega y el correo
		if nvl(wccl_rfc) = "" then
		    wccl_rfc = UCase(SQLescape(Request.Form("wccl_rfc")))
		end if
		wccl_instr_entrega = UCase(SQLescape(Request.Form("wccl_instr_entrega")))
        wccl_cliclef_fact = UCase(SQLescape(Request.Form("wccl_cliclef_fact")))
        wcclcontacto_correo = UCase(SQLescape(Request.Form("wcclcontacto_correo")))
        
	end if
		
	if wcclclave <> "" then
		'Actualizamos un destinatario
		SQL = "UPDATE WEB_CLIENT_CLIENTE SET " & vbCrLf 
		SQL = SQL & " WCCL_NOMBRE = TRANSLATE('"& wccl_nombre &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " , WCCL_RFC = TRANSLATE('"& wccl_rfc &"', '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ—abcdefghijklmnopqrstuvwxyzÒ	,;.-_{}[]¥®+*ø°?=)(/:%$#!∞¨\~^&|', '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ—ABCDEFGHIJKLMNOPQRSTUVWXYZ—&') " & vbCrLf 
		SQL = SQL & " ,WCCL_ADRESSE1 = TRANSLATE('"& wccl_adresse1 &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCL_ADRESSE2 = TRANSLATE('"& wccl_adresse2 &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCL_NUMEXT = TRANSLATE('"& wccl_numext &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCL_NUMINT = TRANSLATE('"& wccl_numint &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCL_CODEPOSTAL = TRANSLATE('"& wccl_codepostal &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCL_VILLE = '"& wccl_ville &"' " & vbCrLf 
		SQL = SQL & " ,WCCLTELEPHONE = TRANSLATE('"& wccltelephone &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCLFAX = TRANSLATE('"& wcclfax &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCLABREVIACION = TRANSLATE('"& wcclabreviacion &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCL_CLICLEF = '"& wccl_cliclef &"' " & vbCrLf 
		SQL = SQL & " ,MODIFIED_BY = '"& Session("array_client")(0,0) &"' " & vbCrLf 
		SQL = SQL & " ,DATE_MODIFIED = SYSDATE " & vbCrLf 
		SQL = SQL & " ,WCCLCONTACTO = TRANSLATE('"& wcclcontacto &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCLCONTACTO_CORREO = TRANSLATE('"& wcclcontacto_correo &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCL_INSTR_ENTREGA = TRANSLATE('"& wccl_instr_entrega &"', '¡…Õ”⁄—∞|', 'AEIOUNo') " & vbCrLf 
		SQL = SQL & " ,WCCL_CLICLEF_FACT =  '"& wccl_cliclef_fact &"' " & vbCrLf 
		SQL = SQL & " WHERE WCCLCLAVE = '"& wcclclave &"' " & vbCrLf 
				
		'Response.Write Replace(SQL, vbCrLf, "<br>")
		Session("SQL") = SQL
		set rst = Server.CreateObject("ADODB.Recordset")
		rst.Open SQL, Connect(), 0, 1, 1	
		
		Response.Redirect "ltl_destinatarios.asp"
	else
		'insertamos un nuevos destinatario
		SQL = "SELECT SEQ_WEB_CLIENT_CLIENTE.nextval FROM DUAL "
        array_tmp = GetArrayRS(SQL)
        numWCCL = array_tmp(0,0)

		SQL = "INSERT INTO WEB_CLIENT_CLIENTE (" & vbCrLf 
		SQL = SQL & " WCCLCLAVE, WCCL_NOMBRE, " & vbCrLf 
		SQL = SQL & " WCCL_RFC, " & vbCrLf 
		SQL = SQL & " CREATED_BY, DATE_CREATED, " & vbCrLf 
		SQL = SQL & " WCCL_ADRESSE1, WCCL_ADRESSE2, " & vbCrLf 
		SQL = SQL & " WCCL_NUMEXT, WCCL_NUMINT, WCCL_CODEPOSTAL, " & vbCrLf 
		SQL = SQL & " WCCL_VILLE, WCCLTELEPHONE, WCCLFAX, " & vbCrLf 
		SQL = SQL & " WCCLABREVIACION, WCCL_CLICLEF, " & vbCrLf 
		SQL = SQL & " WCCLCONTACTO, WCCLCONTACTO_CORREO, WCCL_INSTR_ENTREGA) " & vbCrLf 
		SQL = SQL & " VALUES (" & numWCCL & " , TRANSLATE('"& wccl_nombre &"', '¡…Õ”⁄—∞|', 'AEIOUNo') ," & vbCrLf 
		SQL = SQL & " TRANSLATE('" & wccl_rfc & "', '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ—abcdefghijklmnopqrstuvwxyzÒ	,;.-_{}[]¥®+*ø°?=)(/:%$#!∞¨\~^&', '1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ—ABCDEFGHIJKLMNOPQRSTUVWXYZ—&'), " & vbCrLf 
		SQL = SQL & "     '"& Session("array_client")(0,0) &"', SYSDATE," & vbCrLf 
		SQL = SQL & "     TRANSLATE('"& wccl_adresse1 & "', '¡…Õ”⁄—∞|', 'AEIOUNo'), TRANSLATE('"& wccl_adresse2 & "', '¡…Õ”⁄—∞|', 'AEIOUNo')," & vbCrLf 
		SQL = SQL & "     TRANSLATE('" & wccl_numext & "', '¡…Õ”⁄—∞|', 'AEIOUNo'), TRANSLATE('"& wccl_numint & "', '¡…Õ”⁄—∞|', 'AEIOUNo'), TRANSLATE('" & wccl_codepostal & "', '¡…Õ”⁄—∞|', 'AEIOUNo')," & vbCrLf 
		SQL = SQL & "     '" & wccl_ville & "', TRANSLATE('" & wccltelephone & "', '¡…Õ”⁄—∞|', 'AEIOUNo'), TRANSLATE('" & wcclfax & "', '¡…Õ”⁄—∞|', 'AEIOUNo')," & vbCrLf 
		SQL = SQL & "     TRANSLATE('" & wcclabreviacion & "', '¡…Õ”⁄—∞|', 'AEIOUNo'), '" & wccl_cliclef & "', " & vbCrLf 
		SQL = SQL & "     TRANSLATE('" & wcclcontacto & "', '¡…Õ”⁄—∞|', 'AEIOUNo'), TRANSLATE('" & wcclcontacto_correo & "', '¡…Õ”⁄—∞|', 'AEIOUNo'), TRANSLATE('" & wccl_instr_entrega & "', '¡…Õ”⁄—∞|', 'AEIOUNo'))" & vbCrLf 
		'Response.Write Replace(SQL, vbCrLf, "<br>")
		Session("SQL") = SQL
		set rst = Server.CreateObject("ADODB.Recordset")
		rst.Open SQL, Connect(), 0, 1, 1	
		
		
		if Request.Form("json") = "ok" then
		    'desde ltl_captura_encabezado queremos recuperar los datos capturados.
		    SQL = "SELECT WCCL.WCCLCLAVE || '|' || NVL(DER.DER_ALLCLAVE, 1)  " & VbCrlf
            SQL = SQL & "   , INITCAP(WCCL.WCCL_NOMBRE || DECODE(WCCL.WCCLABREVIACION, NULL, NULL, ' (' || WCCL.WCCLABREVIACION || ')') || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')')     " & VbCrlf
            SQL = SQL & "   FROM WEB_CLIENT_CLIENTE WCCL  " & VbCrlf
            SQL = SQL & "   , ECIUDADES CIU   " & VbCrlf
            SQL = SQL & "   , EESTADOS EST   " & VbCrlf
            SQL = SQL & "   , EDESTINOS_POR_RUTA DER " & VbCrlf
            SQL = SQL & "   WHERE WCCL.WCCLCLAVE = " & numWCCL & VbCrlf
            SQL = SQL & "   AND CIU.VILCLEF = WCCL.WCCL_VILLE  " & VbCrlf
            SQL = SQL & "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO   " & VbCrlf
            'SQL = SQL & "   AND NVL(DER_TIPO_ENTREGA, 'FORANEO 5') <> 'FORANEO 5'   " & VbCrlf
            SQL = SQL & "   AND EST.EST_PAYCLEF = 'N3'   " & VbCrlf
            SQL = SQL & "   AND WCCL.WCCL_STATUS = 1 " & VbCrlf
            SQL = SQL & "   AND DER.DER_VILCLEF = CIU.VILCLEF " & VbCrlf
            SQL = SQL & "   AND DER.DER_ALLCLAVE > 0 "
		    array_tmp = GetArrayRS(SQL)
		    if IsArray(array_tmp) then
		        Response.ContentType = "application/json"
		        Response.Write "{ ""wcclclave"": """ & array_tmp(0,0) & """" 
		        Response.Write " , ""wcclnombre"": """ & Replace(array_tmp(1,0), """", "\""") & """ }"
                Response.End 
            'else
            '    Response.ContentType = "application/json"
		    '    Response.Write "{ ""error"": ""Esta ciudad es un FORANEO 5 no se puede crear la LTL desde esta pantalla.""}"
            '    Response.End 
            end if
		else
		    Response.Redirect "ltl_destinatarios.asp?msg=" & Server.URLEncode("Destinatario creado")
	    end if
	end if
	
	
elseif Request.Form("fusion") = "fusion" then
'fusion de destinatarios
    SQL = "SELECT NULL FROM WEB_CLIENT_CLIENTE WHERE WCCLCLAVE = " & Request.Form("wcclclave_fusion")
    SQL = SQL & " AND WCCL_CLICLEF IN (" & print_clinum() & ") " 
    array_tmp = GetArrayRS(SQL)
    
    if not IsArray(array_tmp) then
        'o el numero de dest no existe o no pertenece al cliente
        Response.Redirect "ltl_destinatarios.asp?msg=" & Server.URLEncode("No se encontro el destinatario para la fusion.")
    end if
    
    SQL = "UPDATE WEB_CLIENT_CLIENTE  " & vbCrLf 
    SQL = SQL & " SET WCCL_STATUS = 0  " & vbCrLf 
    SQL = SQL & " ,MODIFIED_BY = '"& Session("array_client")(0,0) &"_FUS' " & vbCrLf 
	SQL = SQL & " ,DATE_MODIFIED = SYSDATE " & vbCrLf 
    SQL = SQL & " WHERE WCCLCLAVE = " &  Request.Form("wcclclave") & vbCrLf 
    Session("SQL") = SQL
    set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open SQL, Connect(), 0, 1, 1	
	
	SQL = "UPDATE WEB_LTL  " & vbCrLf 
    SQL = SQL & " SET WEL_WCCLCLAVE = " & Request.Form("wcclclave_fusion")  & vbCrLf 
    SQL = SQL & " , WEL_WCCLCLAVE_OLD = WEL_WCCLCLAVE " & vbCrLf 
    SQL = SQL & " , WEL_ALLCLAVE_DEST = NVL(( " & vbCrLf 
    SQL = SQL & "     SELECT DER_ALLCLAVE " & vbCrLf 
    SQL = SQL & "     FROM EDESTINOS_POR_RUTA " & vbCrLf 
    SQL = SQL & "       , WEB_CLIENT_CLIENTE " & vbCrLf 
    SQL = SQL & "     WHERE DER_VILCLEF = WCCL_VILLE " & vbCrLf 
    SQL = SQL & "       AND WCCLCLAVE = " &  Request.Form("wcclclave_fusion") & vbCrLf 
    SQL = SQL & "       AND DER_ALLCLAVE IS NOT NULL " & vbCrLf 
    SQL = SQL & "       AND ROWNUM =1), 1) " & vbCrLf 
    SQL = SQL & " , MODIFIED_BY = '"& Session("array_client")(0,0) &"_FUS' " & vbCrLf 
	SQL = SQL & " , DATE_MODIFIED = SYSDATE " & vbCrLf 
	SQL = SQL & " , WEL_PRECIO_ESTIMADO = NULL " & vbCrLf 
	'volver a poner el tipo LTL
	SQL = SQL & " , WEL_WTLCLAVE = 1 " & vbCrLf 
    SQL = SQL & " WHERE WEL_WCCLCLAVE = " &  Request.Form("wcclclave") & vbCrLf 
    'evitar las modificaciones de destinatario en talones facturados
    SQL = SQL & "  and not exists ( " & VbCrlf
    SQL = SQL & "   select null " & VbCrlf
    SQL = SQL & "   from ETRANS_DETALLE_CROSS_DOCK " & VbCrlf
    SQL = SQL & "   where tdcdclave = wel_tdcdclave " & VbCrlf
    SQL = SQL & "   and tdcd_fctclef is not null) " & VbCrlf
    SQL = SQL & " and not exists ( " & VbCrlf
    SQL = SQL & "   select null " & VbCrlf
    SQL = SQL & "   from EDET_TRAD_FACTURA_CLIENTE_FACT " & VbCrlf
    SQL = SQL & "   where DTFF_TDCDCLAVE = wel_tdcdclave) "
    
    Session("SQL") = SQL
    set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open SQL, Connect(), 0, 1, 1	
	
	SQL = "UPDATE WEB_LTL_METODOS   " & VbCrlf
    SQL = SQL & "  SET WLMSTATUS = 0  " & VbCrlf
    SQL = SQL & "  , MODIFIED_BY = '"& Session("array_client")(0,0) &"_FUS' " & vbCrLf 
    SQL = SQL & "  , DATE_MODIFIED = SYSDATE  " & VbCrlf
    SQL = SQL & "  WHERE WLM_WELCLAVE IN (  " & VbCrlf
    SQL = SQL & "    SELECT WELCLAVE  " & VbCrlf
    SQL = SQL & "    FROM WEB_LTL " & VbCrlf
    SQL = SQL & "    WHERE WEL_WCCLCLAVE = " &  Request.Form("wcclclave") & vbCrLf 
    SQL = SQL & "   and not exists (  " & VbCrlf
    SQL = SQL & "    select null  " & VbCrlf
    SQL = SQL & "    from ETRANS_DETALLE_CROSS_DOCK  " & VbCrlf
    SQL = SQL & "    where tdcdclave = wel_tdcdclave  " & VbCrlf
    SQL = SQL & "    and tdcd_fctclef is not null)  " & VbCrlf
    SQL = SQL & "  and not exists (  " & VbCrlf
    SQL = SQL & "    select null  " & VbCrlf
    SQL = SQL & "    from EDET_TRAD_FACTURA_CLIENTE_FACT  " & VbCrlf
    SQL = SQL & "    where DTFF_TDCDCLAVE = wel_tdcdclave)  " & VbCrlf
    SQL = SQL & " ) " & VbCrlf
    SQL = SQL & "  AND WLMSTATUS = 1  " & VbCrlf
    
    Session("SQL") = SQL
    set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open SQL, Connect(), 0, 1, 1	
	
	SQL = "UPDATE WEB_LTL_CONCEPTOS   " & VbCrlf
    SQL = SQL & "  SET WLCSTATUS = 0  " & VbCrlf
    SQL = SQL & "  , MODIFIED_BY = '"& Session("array_client")(0,0) &"_FUS' " & vbCrLf 
    SQL = SQL & "  , DATE_MODIFIED = SYSDATE  " & VbCrlf
    SQL = SQL & "  WHERE WLC_WELCLAVE IN (  " & VbCrlf
    SQL = SQL & "    SELECT WELCLAVE  " & VbCrlf
    SQL = SQL & "    FROM WEB_LTL " & VbCrlf
    SQL = SQL & "    WHERE WEL_WCCLCLAVE = " &  Request.Form("wcclclave") & vbCrLf 
    SQL = SQL & "   and not exists (  " & VbCrlf
    SQL = SQL & "    select null  " & VbCrlf
    SQL = SQL & "    from ETRANS_DETALLE_CROSS_DOCK  " & VbCrlf
    SQL = SQL & "    where tdcdclave = wel_tdcdclave  " & VbCrlf
    SQL = SQL & "    and tdcd_fctclef is not null)  " & VbCrlf
    SQL = SQL & "  and not exists (  " & VbCrlf
    SQL = SQL & "    select null  " & VbCrlf
    SQL = SQL & "    from EDET_TRAD_FACTURA_CLIENTE_FACT  " & VbCrlf
    SQL = SQL & "    where DTFF_TDCDCLAVE = wel_tdcdclave)  " & VbCrlf
    SQL = SQL & " ) " & VbCrlf
    SQL = SQL & "  AND WLCSTATUS = 1  " & VbCrlf
    
    Session("SQL") = SQL
    set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open SQL, Connect(), 0, 1, 1	
	
	Response.Redirect "ltl_destinatarios.asp?msg=" & Server.URLEncode("° Destinatarios fusionados !")

else

dim script_include
 
script_include = "<!-- script for selects -->" & vbCrLf & _
				 "<script src=""include/js/DynamicOptionList.js"" type=""text/javascript"" language=""javascript""></script>"

Response.Write print_headers("Captura de Destinatario", "ltl", script_include, "", "initDynamicOptionLists();")
%>
<style type="text/css">
img {
	behavior:	url("include/js/pngbehavior.htc");
}
</style>

<script language="JavaScript" type="text/javascript">
	function _Get(id) {
		return document.getElementById(id);
	}
	
	function isRFC(sText) {
	  var ValidChars = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ&";
	  var isRFC=true;
	  var Char;

	  for (i = 0; i < sText.length && isRFC == true; i++) { 
	    Char = sText.charAt(i); 
	    if (ValidChars.indexOf(Char) == -1) {
	      isRFC = false;
	    }
	  }
	  return isRFC;
	}
	
	function verif_datos() {
		if (_Get("wccl_nombre").value == '') {
			alert('Favor de capturar el nombre completo.');
			return false;
		}
		else if (_Get("wccl_adresse1").value == '') {
			alert('Favor de capturar la calle.');
			return false;
		}
		else if (_Get("wccl_rfc").value != '' && (!isRFC(_Get("wccl_rfc").value) || _Get("wccl_rfc").value.length < 12)) {
			alert('Favor de capturar un RFC correcto.');
			return false;
		}
		else {
			_Get("validar").value = 'validar';
			return true;
		}
	}
	
	
	function IsNumeric(sText) {
	   var ValidChars = "0123456789";
	   var IsNumber=true;
	   var Char;

	   for (i = 0; i < sText.length && IsNumber == true; i++) { 
	     Char = sText.charAt(i); 
	     if (ValidChars.indexOf(Char) == -1) {
	       IsNumber = false;
	     }
	   }
	   return IsNumber;
	 }
	 
	 
	function verif_fusion() {
		if (_Get("wcclclave_fusion").value == '' || !IsNumeric(_Get("wcclclave_fusion").value)) {
			alert('Favor de capturar el numero del destinatario.');
		}
		else {
			_Get("fusion").value = 'fusion';
			_Get("del_wccl_form").submit();
		}
	}
</script>
	
<img border="0" width="0" src="images/pixel.gif" height="100">
	
<form id="wccl_form" name="wccl_form" action="<%=asp_self%>" method="post" onsubmit="verif_datos()">
<table id="tabla_wccl" border="0" cellspacing="0" width="95%" align="center">
<tr>
  <td class="titulo_trading"><b>Datos del destinatario</b>:</td>
</tr>
<tr>
  <td>
    <table style="border-width:1px;border-style:solid;border-color:red;" cellpadding="5" cellspacing="0" width="100%">
	  <tr> 
        <td colspan="3"><font color="red">Favor de no poner acentos en los campos (·, È, Ì..) y tampoco caracteres especiales como ∞, & ... </font><br><br>Nombre Completo del Destinatario:<font color="red">*</font>
          <br><input type="text" size="100" maxlength="100" name="wccl_nombre" id="wccl_nombre" value="<%=wccl_nombre%>">
        </td>
	  </tr>
	  <tr> 
		<td colspan="3">AbreviaciÛn:
			<br><input type="text" size="100" maxlength="100" name="wcclabreviacion" id="wcclabreviacion" value="<%=wcclabreviacion%>">
			<br><i><font color="red">Nota:</font>Este campo permite definir un nombre personalizado que va a 
			aparecer en las listas de destinatarios al lado del nombre completo.
			<br>Eso permite ubicar mas facilmente un destinatario cuando por ejemplo existen varios sucursales
			con el mismo nombre en una misma ciudad.</i>
	    </td>
	  </tr>
	  <tr> 
		<td colspan="3">RFC:
			<br><input type="text" size="20" maxlength="13" name="wccl_rfc" id="wccl_rfc" value="<%=wccl_rfc%>">
			<br><i><font color="red">Nota:</font>Este campo permite capturar el RFC del cliente. Favor de capturar sin espacios, guiones u otros caracteres no alfanumericos.</i>
	    </td>
	  </tr>
	  <tr> 
		<td>Calle:<font color="red">*</font>
			<br><input type="text" size="85" maxlength="100" name="wccl_adresse1" id="wccl_adresse1" value="<%=wccl_adresse1%>">
		</td>
		<td>N∞Exterior:
			<br><input type="text" size="10" maxlength="20" name="wccl_numext" id="wccl_numext" value="<%=wccl_numext%>">
		</td>
		<td>
			N∞Interior:<br><input type="text" size="10" maxlength="20" name="wccl_numint" id="wccl_numint" value="<%=wccl_numint%>">
		</td>
	  </tr>
	  <tr> 
		<td>Colonia:
			<br><input type="text" size="70" maxlength="100" name="wccl_adresse2" id="wccl_adresse2" value="<%=wccl_adresse2%>">
		</td>
		<td colspan="2">C.P.:
			<br><input type="text" size="10" maxlength="5" name="wccl_codepostal" id="wccl_codepostal" value="<%=wccl_codepostal%>">
		</td>
	  </tr>
	  <tr> 
		<td>TelÈfono:
			<br><input type="text" size="20" maxlength="200" name="wccltelephone" id="wccltelephone" value="<%=wccltelephone%>">
		</td>
		<td colspan="2">Fax:
			<br><input type="text" size="20" maxlength="200" name="wcclfax" id="wcclfax" value="<%=wcclfax%>">
		</td>
	  </tr>
	  <tr> 
		<td>Contacto:
			<br><input type="text" size="20" maxlength="200" name="wcclcontacto" id="wcclcontacto" value="<%=wcclcontacto%>">
		</td>
		<td colspan="2">Correo electronico contacto:
			<br><input type="text" class="light" size="60" maxlength="1000" name="wcclcontacto_correo" id="wcclcontacto_correo" value="<%=wcclcontacto_correo%>">
		</td>
	  </tr>
	  <tr valign="top">
	    <td>Estado:<font color="red">*</font>
			<br><select name="estado" id="estado" class="light">
			<%SQL = "SELECT EST.ESTESTADO " & VbCrlf
				SQL = SQL & "  , DECODE(EST_PAYCLEF, 'N3', NULL, 'G8', 'USA - ', 'D9', 'CAN - ', 'I6', 'GUA - ') || InitCap(EST.ESTNOMBRE)  " & VbCrlf
				SQL = SQL & "  , DECODE(EST.ESTESTADO, '" & wccl_estado & "', 'selected') " & VbCrlf
				SQL = SQL & " FROM EESTADOS EST  " & VbCrlf
				if Session("ltl_internacional") = "1" then
				    'agregar EEUU y Canada
				    SQL = SQL & "  WHERE EST.EST_PAYCLEF IN ('N3', 'G8', 'D9', 'I6') " & VbCrlf
				else
    				SQL = SQL & "  WHERE EST.EST_PAYCLEF = 'N3' " & VbCrlf
				end if
				SQL = SQL & "  ORDER BY DECODE(EST_PAYCLEF, 'N3', 1, 'G8', 2, 'D9', 3, 'I6', 4), EST.ESTNOMBRE "
				array_tmp = GetArrayRS(SQL)
				
			for i = 0 to Ubound(array_tmp,2)
				Response.Write "<option value="""& array_tmp(0,i) &""" "& array_tmp(2,i) & ">" & array_tmp(1,i) & vbTab  & vbCrLf
			next
			%>
			</select>
		</td>
		<td colspan="2">Ciudad:<font color="red">*</font>
			<br>
			<script type="text/javascript">
				
				var dol = new DynamicOptionList();
				dol.addDependentFields("estado","wccl_ville");
				dol.setFormName("wccl_form");
<%
			if Session("ltl_internacional") = "1" then
					 SQL = " SELECT  EST.ESTESTADO  "  & VbCrlf
					 SQL = SQL &  "  , InitCap(EST.ESTNOMBRE)  "  & VbCrlf
					 SQL = SQL &  "  , CIU.VILCLEF  "  & VbCrlf
					 SQL = SQL &  "  , InitCap(CIU.VILNOM)   "  & VbCrlf
					 SQL = SQL &  " FROM EESTADOS EST  "  & VbCrlf
					 SQL = SQL &  "  , ECIUDADES CIU   "  & VbCrlf
					 SQL = SQL &  " WHERE EST.EST_PAYCLEF IN ('N3', 'G8', 'D9', 'I6')  "  & VbCrlf
					 SQL = SQL &  "  AND EST.ESTESTADO = CIU.VIL_ESTESTADO   "  & VbCrlf
					 SQL = SQL &  "  ORDER BY CIU.VILNOM  "  

				else
					SQL = " SELECT  EST.ESTESTADO "  & VbCrlf
					SQL = SQL &  "   , InitCap(EST.ESTNOMBRE) "  & VbCrlf 
					SQL = SQL &  "   , CIU.VILCLEF "  & VbCrlf
					SQL = SQL &  "   , InitCap(CIU.VILNOM)  || DECODE(der_tipo_entrega, 'FORANEO 6', ' (Foraneo 6)')  "  & VbCrlf
					SQL = SQL &  "  FROM EESTADOS EST "  & VbCrlf
					SQL = SQL &  "   , ECIUDADES CIU  "  & VbCrlf
					SQL = SQL &  "   , edestinos_por_ruta der "  & VbCrlf
					SQL = SQL &  "  WHERE EST.EST_PAYCLEF = 'N3' "  & VbCrlf
					SQL = SQL &  "   and der.DER_VILCLEF = ciu.VILCLEF "  & VbCrlf
					SQL = SQL &  "   and der_allclave > 0  "  & VbCrlf
					SQL = SQL &  "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO  "  & VbCrlf


					' NAJIB 2015/08/21
'					SQL = SQL &  "    AND  NVL(DER_TIPO_ENTREGA, 'FORANEO 6') <> 'FORANEO 6' "  & VbCrlf
'					SQL = SQL &  "    union all"  & VbCrlf
'					SQL = SQL &  " SELECT  EST.ESTESTADO "  & VbCrlf
'					SQL = SQL &  "   , InitCap(EST.ESTNOMBRE) "  & VbCrlf
'					SQL = SQL &  "   , CIU.VILCLEF "  & VbCrlf
'					SQL = SQL &  "   , InitCap(CIU.VILNOM)  || DECODE(der_tipo_entrega, 'FORANEO 6', ' (Foraneo 6)') "  & VbCrlf
'					SQL = SQL &  "  FROM EESTADOS EST "  & VbCrlf
'					SQL = SQL &  "   , ECIUDADES CIU  "  & VbCrlf
'					SQL = SQL &  "   , edestinos_por_ruta der "  & VbCrlf
'					SQL = SQL &  "  WHERE EST.EST_PAYCLEF = 'N3' "  & VbCrlf
'					SQL = SQL &  "   and der.DER_VILCLEF = ciu.VILCLEF "  & VbCrlf
'					SQL = SQL &  "   and der_allclave > 0  "  & VbCrlf
'					SQL = SQL &  "    AND   "  & VbCrlf
'					SQL = SQL &  "           NVL(DER_TIPO_ENTREGA, 'FORANEO 6') = 'FORANEO 6'  "  & VbCrlf
'					SQL = SQL &  "           AND "  & VbCrlf
'					SQL = SQL &  "           EXISTS "  & VbCrlf
'					SQL = SQL &  "           (  "  & VbCrlf
'					SQL = SQL &  "              SELECT  NULL FROM ECLIENT_APLICA_CONCEPTOS CCO, EBASES_POR_CONCEPT BPC, EPARAMETRO_RESTRICT PAR, ECONCEPTOSHOJA CHO "  & VbCrlf
'					SQL = SQL &  "              WHERE CCO_CLICLEF IN ("& print_clinum &")  "  & VbCrlf
'					SQL = SQL &  "              AND BPCCLAVE = CCO_BPCCLAVE "  & VbCrlf
'					SQL = SQL &  "              AND CHOCLAVE = BPC_CHOCLAVE "  & VbCrlf
'					SQL = SQL &  "              AND CHONUMERO = 172 "  & VbCrlf
'					SQL = SQL &  "              AND PARCLAVE = BPC_PARCLAVE "  & VbCrlf
'					SQL = SQL &  "              AND PAR_VILCLEF_DEST = VILCLEF "  & VbCrlf
'					SQL = SQL &  "              AND NVL(PAR_VALOR_MAX, -1) != 0 "  & VbCrlf
'					SQL = SQL &  "           ) "  & VbCrlf
'					SQL = SQL &  "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO  "  & VbCrlf
					' NAJIB 2015/08/21

					SQL = SQL &  "   ORDER BY 4				"  & VbCrlf
				end if
				
				array_tmp = GetArrayRS(SQL)
				for i = 0 to Ubound(array_tmp,2)
					Response.Write "dol.forValue("""& array_tmp(0,i) & """).addOptionsTextValue(""" & array_tmp(3,i) & """,""" & array_tmp(2,i) & """);" & vbTab  & vbCrLf
				next
				if NVL(wccl_estado) <> "" then
					response.write  "dol.forValue(""" & wccl_estado & """).setDefaultOptions(""" & wccl_ville & """);"
				end if
				%>
			</script>
			<select name="wccl_ville" id="wccl_ville" class="light">
				<script type="text/javascript">dol.printOptions("wccl_ville");</script>
			</select><br>
			<i><font color="red">Nota:</font> Si la ciudad deseada no aparece en el listado <br>Favor de contactar su Centro de Servicio</i>
		</td>
	  </tr>
<%if IP_interna then%>
	  <tr> 
		<td colspan="3">Instrucciones de entrega:
			<br><textarea cols="100" rows="6" class="light" name="wccl_instr_entrega" id="wccl_instr_entrega"><%=wccl_instr_entrega%></textarea>
		</td>
	  </tr>
		<%'if Session("internal_login")= 2 then
		    SQL = "SELECT CLICLEF " & VbCrlf
		    SQL = SQL & " , InitCap(CLICLEF || '-' || CLINOM || ', ' || CLIADRESSE1  || ' ' || CLINUMEXT || ' ' || CLINUMINT  " & VbCrlf
            SQL = SQL & " || ', ' || CLIADRESSE2 || DECODE(CLICODEPOSTAL, NULL, NULL, ', CP ' || CLICODEPOSTAL) " & VbCrlf
            SQL = SQL & " || ', ' || VILNOM || ' ('|| ESTNOMBRE || ')')   " & VbCrlf
            SQL = SQL & " , DECODE('"& WCCL_CLICLEF_FACT &"', CLICLEF, 'selected') " & VbCrlf
            SQL = SQL & " FROM ECLIENT " & VbCrlf
            SQL = SQL & "   , ECIUDADES " & VbCrlf
            SQL = SQL & "   , EESTADOS " & VbCrlf
            SQL = SQL & " WHERE CLIRFC = '"& wccl_rfc &"' " & VbCrlf
            SQL = SQL & " AND CLISTATUS = 0 " & VbCrlf
            SQL = SQL & " AND VILCLEF = CLIVILLE " & VbCrlf
            SQL = SQL & " AND ESTESTADO = VIL_ESTESTADO"
		    array_tmp = GetArrayRS(SQL)
		    if IsArray(array_tmp) then%>
		        <tr>
		          <td colspan="3">Cliente a facturar:
		            <br><select name="WCCL_CLICLEF_FACT" id="WCCL_CLICLEF_FACT" class="light">
		                    <option value="">Ninguno
		                    <%for i = 0 to UBound(array_tmp, 2)
		                        Response.Write "<option value='"& array_tmp(0,i) &"' " & array_tmp(2,i) & ">" & array_tmp(1,i) & vbCrLf 
		                    next%>
		          </td>
		        </tr>
		    <%end if%>
		<%'end if%>
<%end if%>


	</table>
  </td>
</tr>
<%if UBound(Split(print_clinum, ",")) > 0 then%>
<tr><td><img src="images/pixel.gif" border="0" height="10" width="0"></td></tr>
<tr>
	<td class="titulo_trading"><b>Numero de cliente</b> <font color="red"><i>(Obligatorio)</i></font>:</td></td>
</tr>
<tr>
	<td>
	  <table style="border-width:1px;border-style:solid;border-color:red;" cellpadding="0" cellspacing="0" width="100%">
	   <%Call print_radio_client3(wccl_cliclef)%>
	  </table>
	</td>
</tr>
<%else
	Call print_radio_client3(wccl_cliclef)
end if
%>
<tr><td><img src="images/pixel.gif" border="0" height="10" width="0"></td></tr>
<tr>
	<td>
		<%'if NVL_num(wel_count) = "0" or NVL(wccl_rfc) = "" then%>
			<input id="btn_validar_wccl" name="btn_validar_wccl" type="submit" value="Validar" class="button_trading">
			<input type="hidden" id="validar" name="validar"  value="">
			<input type="hidden" id="json" name="json"  value="">
			<input type="hidden" id="wcclclave" name="wcclclave"  value="<%=wcclclave%>">
			<input type="hidden" id="loginId" name="loginId"  value="<%=Request("loginId")%>">
			<input type="hidden" id="wel_count" name="wel_count"  value="<%if  Session("array_client")(2,0) = "2399" then
			    Response.Write "0"
			else
			    Response.Write NVL_num(wel_count)
			end if%>">
			<%if NVL_num(wel_count) <> "0" and Session("array_client")(2,0) <> "2399" then%>
				<%if NVL(wccl_rfc) = "" then%>
			    	<div class="messages error">Este contacto tiene una o varias LTLs registradas, solo se puede actualizar el RFC, las instrucciones de entrega y el correo.</div>
			    <%elseif IP_interna then%>
			        <div class="messages error">Este contacto tiene una o varias LTLs registradas y un RFC capturado, solo se puede actualizar las instrucciones de entrega y el correo.</div>
			    <%end if%>
		    <%end if%>
		<%'else
			'<div class="messages error">Este contacto tiene una o varias LTLs registradas, no se puede modificar.</div>
		'end if%>
	</td>
</tr>
</table>
</form>
<br>
<br>

<%if Session("internal_login")= 2 and wcclclave <> "" then%>
<form id="del_wccl_form" name="del_wccl_form" action="<%=asp_self%>" method="post">
<table border="0" cellspacing="0" width="95%" align="center">
<tr>
  <td class="titulo_trading"><b>Fusion de destinatario</b>:</td>
</tr>
<tr>
  <td>
    <table style="border-width:1px;border-style:solid;border-color:red;" cellpadding="5" cellspacing="0" width="100%">
	  <tr> 
        <td>Fusionar este destinatario (n∞<b><%=wcclclave%></b>) con...
          <br><font color="red">Ojo: Verificar bien los datos ya que esta operacion afecta todos los talones anteriores.</font>
          <br><br><font color="red"><b>N∞ del destinatario correcto</b></font>
          <br><input type="text" size="15" maxlength="9" name="wcclclave_fusion" id="wcclclave_fusion" style="color:red">
        </td>
	  </tr>
	</table>
  </td>
</tr>
<tr>
  <td>
    <input type="hidden" id="wcclclave" name="wcclclave"  value="<%=wcclclave%>">
    <input type="hidden" id="fusion" name="fusion"  value="fusion">
    <input id="btn_fusion" name="btn_fusion" type="button" value="Fusion" class="button_trading" style="color:red" onclick="verif_fusion();">
  </td>
</tr>
</table>
</form>
<%end if%>
</body>
</html>
<%end if

'matamos la session en caso que sea con loginId
if Request("loginId") <> "" then
    Set Session("array_client")= nothing
end if
%>

