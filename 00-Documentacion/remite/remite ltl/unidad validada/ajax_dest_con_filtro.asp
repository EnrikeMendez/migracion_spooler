<%@ Language=VBScript %>
<% option explicit 
%><!--#include file="include/include.asp"-->
<%
Dim rst, SQL,array_tmp, i
Dim le_date_fin, ext_file, ext_ext_file
Dim le_vilclef, le_estado, le_ciudad, le_categoria, le_cargo 

call check_session()
Server.ScriptTimeout = 3000


If Request.QueryString("tipo") = "DIECLAVE" then
		SQL = "SELECT  /*+ INDEX(DEC UK_DIR_ENTR_CLI_LIGA) use_nl(DEC EST CIU DER DIE CCL)*/  " & VbCrlf
		SQL = SQL & "  	  DISTINCT DIE.DIECLAVE  " & VbCrlf
		SQL = SQL & "  	  , DIE.DIE_CCLCLAVE  " & VbCrlf
		SQL = SQL & "     , NVL(DEC_DIECLAVE_ENTREGA, DEC_DIECLAVE)  " & VbCrlf
		SQL = SQL & "     , REPLACE(REPLACE(initcap(NVL(DIE_A_ATENCION_DE, DIENOMBRE) || ' - ' || DIEADRESSE1 || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')' ), CHR(10), NULL), CHR(13), NULL)  " & VbCrlf
		SQL = SQL & "     || DECODE(DER_TIPO_ENTREGA, 'FORANEO 5', ' - FORANEO 5', NULL) " & vbCrLf
		If Request.QueryString("DIECLAVE") <> "" Then
			SQL = SQL & "     , DECODE(TO_CHAR(DIE.DIECLAVE),'" & Request.QueryString("DIECLAVE") & "',' selected ', NULL)   " & VbCrlf
		Else
			SQL = SQL & "     , NULL   " & VbCrlf
		End If
		SQL = SQL & "   FROM EDIRECCION_ENTR_CLIENTE_LIGA DEC  " & VbCrlf
		SQL = SQL & "     , EDIRECCIONES_ENTREGA DIE  " & VbCrlf
		SQL = SQL & "     , ECIUDADES CIU  " & VbCrlf
		SQL = SQL & "     , EESTADOS EST " & VbCrlf
		SQL = SQL & " 	  , ECLIENT_CLIENTE CCL " & VbCrlf
		SQL = SQL & "   , EDESTINOS_POR_RUTA " & VbCrlf
		SQL = SQL & "   WHERE DEC_CLICLEF IN ("& print_clinum &")   " & VbCrlf
		SQL = SQL & "     AND DIE.DIECLAVE = DEC.DEC_DIECLAVE  " & VbCrlf
		SQL = SQL & "     AND CIU.VILCLEF = DIEVILLE  " & VbCrlf
		SQL = SQL & "     AND EST.ESTESTADO = CIU.VIL_ESTESTADO " & VbCrlf
		SQL = SQL & " 	  AND CCL.CCLCLAVE = DIE.DIE_CCLCLAVE  " & VbCrlf
		SQL = SQL & " 	  AND ( ( CCL.CCL_STATUS = 1 ) or ( 0 IN ("& print_clinum &"))) " & VbCrlf
		'< CHG-DESA-26012022-02: Se filtran destinatarios activos 
		SQL = SQL & "     AND DIE.DIE_STATUS = 1 " & VbCrlf
		' CHG-DESA-26012022-02 >
		SQL = SQL & "     AND DER_VILCLEF = VILCLEF " & VbCrlf
		'20171010 -- >
		SQL = SQL & "     AND DER_TIPO_ENTREGA NOT IN ('INSEGURO', 'INVALIDO') " & VbCrlf
		'20171010 < --
		'20180430 -- > Restriccion por cliente
		SQL = SQL & "     AND SF_LOGIS_CLIENTE_RESTRIC(DEC_CLICLEF, DER_TIPO_ENTREGA) = 1 " & VbCrlf
		'20180430 < --
		if Request.QueryString("DIE_CCLCLAVE") <> "" Then
			SQL = SQL & "     AND TO_CHAR(DIE_CCLCLAVE) = '" & Request.QueryString("DIE_CCLCLAVE")  & "' " & VbCrlf
		End If
		if Request.QueryString("dieclave_restrict") <> "''" Then
			SQL = SQL & "   AND upper(REPLACE(REPLACE(initcap(NVL(DIE_A_ATENCION_DE, DIENOMBRE) || ' - ' || DIEADRESSE1 || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')' ), CHR(10), NULL), CHR(13), NULL)  " & VbCrlf
			SQL = SQL & "     || DECODE(DER_TIPO_ENTREGA, 'FORANEO 5', ' - FORANEO 5', NULL)) LIKE (upper('%" & Request.QueryString("dieclave_restrict") & "%'))"
		end if
		'if Request.QueryString("lista") = "2" Then
			'SQL = SQL & " AND NVL(DEC_DIECLAVE_ENTREGA, DEC_DIECLAVE) <> " & Request.QueryString("DIE_CCLCLAVE") & VbCrlf
		'End If
		SQL = SQL & "   ORDER BY 4" 

		array_tmp = GetArrayRS(SQL) 
		If IsArray(array_tmp) Then
		    For i = 0 To Ubound(array_tmp,2)
		    	'Response.Write "<option value=""" & array_tmp(0,i) & "|" & array_tmp(2,i) & "|" & array_tmp(3,i) & """>"
		    	'Response.Write array_tmp(1,i) & "</option>" & VbCrLf
		    	Response.Write "<option value=""" & array_tmp(0,i) & """" & array_tmp(4,i)  & ">"
				Response.Write array_tmp(3,i) & "</option>" & VbCrLf
		    Next
		else
			If Request.QueryString("lista") = "2" Then
				Response.Write "<option> Direccion de entrega final</option>"
			Else
				Response.Write "<option> Direccion de entrega </option>"
			End If
		end if
ElseIf Request.QueryString("tipo") = "CCLCLAVE" then
	If Request.QueryString("LA_CIUDAD") <> "Ciudad" And Request.QueryString("logis") <> "si" Then
		SQL = "  SELECT /*+ordered index(UK_ECLIENT_CLIENTE_LIGA CIL) USE_NL(CIL CCL EST CIU)*/   " & VbCrlf
		SQL = SQL & "   DISTINCT CCL.CCLCLAVE  " & VbCrlf
		SQL = SQL & "   , INITCAP(CCL_NOMBRE || ' - ' || CCL_ADRESSE1 || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')')  " & VbCrlf
		SQL = SQL & "     || DECODE(DER_TIPO_ENTREGA, 'FORANEO 5', ' - FORANEO 5', NULL) " & vbCrLf
		SQL = SQL & "   , NULL  " & VbCrlf
		SQL = SQL & " FROM ECLIENT_CLIENTE_LIGA CIL " & VbCrlf
		SQL = SQL & "   , ECLIENT_CLIENTE  CCL " & VbCrlf
		SQL = SQL & "   , ECIUDADES CIU  " & VbCrlf
		SQL = SQL & "   , EESTADOS EST " & VbCrlf
		SQL = SQL & "   , EDESTINOS_POR_RUTA " & VbCrlf
		SQL = SQL & " WHERE CCL.CCLCLAVE = CIL.CIL_CCLCLAVE " & VbCrlf
		If Request.QueryString("completa") <> "si" Then
			SQL = SQL & "   AND CIL.CIL_CLICLEF IN ("& print_clinum &") " & VbCrlf
		End If
		SQL = SQL & "   AND CIU.VILCLEF = CCL.CCL_VILLE " & VbCrlf
		SQL = SQL & "   AND CIU.VILCLEF = " & Request.QueryString("LA_CIUDAD") & VbCrlf
		if Request.QueryString("destinatario_restrict") <> "''" Then
			SQL = SQL & "   AND upper(INITCAP(CCL_NOMBRE || ' - ' || CCL_ADRESSE1 || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')')) LIKE (upper('%" & Request.QueryString("destinatario_restrict") & "%'))"
		end if
		If Request.QueryString("completa") <> "si" Then
			SQL = SQL & "   AND ( ( CCL.CCL_STATUS = 1 ) or ( 0 IN ("& print_clinum &")))" & VbCrlf
		Else
			SQL = SQL & "   AND ( CCL.CCL_STATUS = 1 )" & VbCrlf
		End IF
		SQL = SQL & "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO  " & VbCrlf
		SQL = SQL & "   AND EST.EST_PAYCLEF = 'N3'  " & VbCrlf
		'20180430 -- > Restriccion por cliente
		SQL = SQL & "   AND SF_LOGIS_CLIENTE_RESTRIC(CIL.CIL_CLICLEF, DER_TIPO_ENTREGA) = 1 " & VbCrlf
		'20180430 < --
		If Request.QueryString("completa") <> "si" Then
			SQL = SQL & "   AND EXISTS( SELECT NULL " & VbCrlf
			SQL = SQL & "     FROM EDIRECCION_ENTR_CLIENTE_LIGA DEC  " & VbCrlf
			SQL = SQL & "       ,EDIRECCIONES_ENTREGA DIE  " & VbCrlf
			SQL = SQL & "     WHERE DEC_CLICLEF IN ("& print_clinum &")   " & VbCrlf
			SQL = SQL & "  	    AND DIE.DIE_CCLCLAVE = CCL.CCLCLAVE " & VbCrlf
			SQL = SQL & "       AND DIE.DIECLAVE = DEC.DEC_DIECLAVE  " & VbCrlf
		'< CHG-DESA-26012022-02: Se filtran destinatarios activos 
			SQL = SQL & "     AND DIE.DIE_STATUS = 1 " & VbCrlf
		' CHG-DESA-26012022-02 >
			SQL = SQL & "  	    AND ROWNUM=1) " & VbCrlf
		End If
		SQL = SQL & "   AND DER_VILCLEF = VILCLEF " & VbCrlf
		SQL = SQL & " ORDER BY 2"

		array_tmp = GetArrayRS(SQL) 
		If IsArray(array_tmp) Then
		    For i = 0 To Ubound(array_tmp,2)
		    	'Response.Write "<option value=""" & array_tmp(0,i) & "|" & array_tmp(2,i) & "|" & array_tmp(3,i) & """>"
		    	'Response.Write array_tmp(1,i) & "</option>" & VbCrLf
		    	Response.Write "<option value=""" & array_tmp(0,i) & """" & array_tmp(2,i)  & ">"
				Response.Write array_tmp(1,i) & "</option>" & VbCrLf
		    Next
		else
			Response.Write "<option> Destinario </option>"
		end if
	Elseif Request.QueryString("LE_ESTESTADO") <> "Estado" And Request.QueryString("logis") = "si" Then
		SQL = "  SELECT /*+ordered index(UK_ECLIENT_CLIENTE_LIGA CIL) USE_NL(CIL CCL EST CIU)*/   " & VbCrlf
        SQL = SQL & " DISTINCT CCL.CCLCLAVE  " & VbCrlf
        SQL = SQL & " , INITCAP(CCL_NOMBRE || ' - ' || CCL_ADRESSE1 || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')')  " & VbCrlf
        SQL = SQL & " || DECODE(DER_TIPO_ENTREGA, 'FORANEO 5', ' - FORANEO 5', NULL) " & VbCrlf
        SQL = SQL & " , NULL  " & VbCrlf
        SQL = SQL & " , EST.ESTESTADO " & VbCrlf
        SQL = SQL & " FROM ECLIENT_CLIENTE_LIGA CIL " & VbCrlf
        SQL = SQL & " , ECLIENT_CLIENTE  CCL " & VbCrlf
        SQL = SQL & " , ECIUDADES CIU  " & VbCrlf
        SQL = SQL & " , EESTADOS EST " & VbCrlf
        SQL = SQL & " , EDESTINOS_POR_RUTA " & VbCrlf
        SQL = SQL & " WHERE CCL.CCLCLAVE = CIL.CIL_CCLCLAVE " & VbCrlf
       	SQL = SQL & " AND CIU.VILCLEF = CCL.CCL_VILLE " & VbCrlf
       	SQL = SQL & " AND ( CCL.CCL_STATUS = 1 ) " & VbCrlf
       	SQL = SQL & " AND EST.ESTESTADO = CIU.VIL_ESTESTADO " & VbCrlf  
       	SQL = SQL & " AND EST.ESTESTADO = " & Request.QueryString("LE_ESTESTADO") & VbCrlf
       	SQL = SQL & " AND EST.EST_PAYCLEF = 'N3'  " & VbCrlf
       	SQL = SQL & " AND DER_VILCLEF = VILCLEF " & VbCrlf
        SQL = SQL & " AND CCL_NUMERO = 25663 " & VbCrlf
     	SQL = SQL & " ORDER BY 2"

		array_tmp = GetArrayRS(SQL) 
		If IsArray(array_tmp) Then
		    For i = 0 To Ubound(array_tmp,2)
		    	'Response.Write "<option value=""" & array_tmp(0,i) & "|" & array_tmp(2,i) & "|" & array_tmp(3,i) & """>"
		    	'Response.Write array_tmp(1,i) & "</option>" & VbCrLf
		    	Response.Write "<option value=""" & array_tmp(0,i) & """" & array_tmp(2,i)  & ">"
				Response.Write array_tmp(1,i) & "</option>" & VbCrLf
		    Next
		else
			Response.Write "<option> Destinario </option>"
		end if
	else
		Response.Write "<option> Destinario </option>"
	End If
Else
	if Request.QueryString("LA_CIUDAD") <> "Ciudad" then

		'SQL = "SELECT  " & VbCrlf
		'SQL = SQL & " 	DISTINCT dir.dieclave , INITCAP( NVL(DIE_A_ATENCION_DE, DIENOMBRE) || ' - ' || DIEADRESSE1 || ' - ' || DIEADRESSE2 || ' - ' || der_tipo_entrega), NVL(DER.DER_ALLCLAVE, 1), CCL.ccl_rfc, CCL.CCLCLAVE  " & VbCrlf
		'SQL = SQL & " FROM  " & VbCrlf
		'SQL = SQL & "  ECLIENT_CLIENTE  CCL  " & VbCrlf
		'SQL = SQL & "  , EDIRECCIONES_ENTREGA DIR  " & VbCrlf
		'SQL = SQL & "  , ECIUDADES CIU  " & VbCrlf
		'SQL = SQL & "  , EESTADOS EST  " & VbCrlf
		'SQL = SQL & "  , EDESTINOS_POR_RUTA DER  " & VbCrlf
		'SQL = SQL & "  , EDIRECCION_ENTR_CLIENTE_LIGA DIL  " & VbCrlf
		'SQL = SQL & "  WHERE   " & VbCrlf
		'SQL = SQL & "   CIU.VILCLEF = DIR.DIEVILLE  " & VbCrlf
		'SQL = SQL & "   AND DIL.DEC_DIECLAVE = DIECLAVE  " & VbCrlf
		'SQL = SQL & "   AND DIL.DEC_CLICLEF = " & Session("array_client")(2,0) & VbCrlf
		'SQL = SQL & "   AND CCL.CCL_STATUS = 1  " & VbCrlf
		'SQL = SQL & "   AND DIE_STATUS = 1 " & VbCrlf
		'SQL = SQL & "   and die_cclclave = cclclave  " & VbCrlf
		'SQL = SQL & "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO   " & VbCrlf
		'SQL = SQL & "   AND DER.DER_VILCLEF = CIU.VILCLEF " & VbCrlf
		'SQL = SQL & "   AND DER.DER_ALLCLAVE > 0 " & VbCrlf
		'SQL = SQL & "   AND EST.EST_PAYCLEF = 'N3'  " & VbCrlf
		'SQL = SQL & "   AND DIR.DIE_STATUS = 1  " & VbCrlf
		'if Request.QueryString("codepostal") <> "" Then	
		'		SQL = SQL & "   AND DIR.DIECODEPOSTAL = '" & Request.QueryString("codepostal") & "'"
		'end if	
		'SQL = SQL & "   and CIU.VILCLEF = " & Request.QueryString("LA_CIUDAD")
		'if Request.QueryString("destinatario_restrict") <> "''" Then
		'	SQL = SQL & "   and upper(INITCAP( NVL(DIE_A_ATENCION_DE, DIENOMBRE) || ' - ' || DIEADRESSE1 || ' - ' || DIEADRESSE2 || ' - ' || der_tipo_entrega)) like (upper('%" & Request.QueryString("destinatario_restrict") & "%'))"
		'end if
		'SQL = SQL & "   order by 2"
		SQL = "        SELECT /*+ INDEX(DEC UK_DIR_ENTR_CLI_LIGA) use_nl(DEC EST CIU DER DIE CCL)*/  " & VbCrlf
		'20181011 -- >
		'SQL = SQL & "      DIE.DIECLAVE " & VbCrlf
		SQL = SQL & "       DISTINCT DIE.DIECLAVE " & VbCrlf
		'20181011 < --
		SQL = SQL & "       , INITCAP(NVL(DIE_A_ATENCION_DE, DIENOMBRE) || ' - ' || DIEADRESSE1 || ' - ' || DIEADRESSE2 || ' - ' || DER_TIPO_ENTREGA) " & VbCrlf
		SQL = SQL & "       , NVL(DER_ALLCLAVE, 1) " & VbCrlf
		SQL = SQL & "       , CCL.CCL_RFC " & VbCrlf
		SQL = SQL & "       , CCL.CCLCLAVE " & VbCrlf
		SQL = SQL & "    FROM EDIRECCION_ENTR_CLIENTE_LIGA   DEC " & VbCrlf
		SQL = SQL & "         , EDIRECCIONES_ENTREGA         DIE " & VbCrlf
		SQL = SQL & "         , ECIUDADES                    CIU " & VbCrlf
		SQL = SQL & "         , EESTADOS                     EST " & VbCrlf
		SQL = SQL & "         , ECLIENT_CLIENTE              CCL " & VbCrlf
		SQL = SQL & "         , EDESTINOS_POR_RUTA " & VbCrlf
		SQL = SQL & "   WHERE DEC_CLICLEF IN (" & Session("array_client")(2,0) & ") " & VbCrlf
		SQL = SQL & "     AND DIE.DIECLAVE = DEC.DEC_DIECLAVE " & VbCrlf
		SQL = SQL & "     AND CIU.VILCLEF = DIEVILLE " & VbCrlf
		SQL = SQL & "     AND EST.ESTESTADO = CIU.VIL_ESTESTADO " & VbCrlf
		SQL = SQL & "     AND CCL.CCLCLAVE = DIE.DIE_CCLCLAVE " & VbCrlf
		SQL = SQL & "     AND ((CCL.CCL_STATUS = 1) OR (0 IN (" & Session("array_client")(2,0) & "))) " & VbCrlf
		SQL = SQL & "     AND DER_VILCLEF = VILCLEF " & VbCrlf
		SQL = SQL & "     AND DER_TIPO_ENTREGA NOT IN ('INSEGURO', 'INVALIDO') " & VbCrlf
		'20180430 -- > Restriccion por cliente
		SQL = SQL & "     AND SF_LOGIS_CLIENTE_RESTRIC(DEC_CLICLEF, DER_TIPO_ENTREGA) = 1 " & VbCrlf
		'20180430 < --
		'< CHG-DESA-26012022-02: Se filtran destinatarios activos 
		SQL = SQL & "     AND DIE.DIE_STATUS = 1 " & VbCrlf
		' CHG-DESA-26012022-02 >
		'SQL = SQL & "     AND DIE.DIE_CCLCLAVE = 40593 " & VbCrlf
		SQL = SQL & "     AND CIU.VILCLEF = " & Request.QueryString("LA_CIUDAD") & VbCrlf
		if Request.QueryString("destinatario_restrict") <> "''" Then
			SQL = SQL & " AND upper(INITCAP(NVL(DIE_A_ATENCION_DE, DIENOMBRE) || ' - ' || DIEADRESSE1 || ' - ' || DIEADRESSE2 || ' - ' || DER_TIPO_ENTREGA)) like (upper('%" & Request.QueryString("destinatario_restrict") & "%'))"
		end if
		SQL = SQL & " ORDER BY 2 "

		array_tmp = GetArrayRS(SQL) 
		If IsArray(array_tmp) Then
					
		    For i = 0 To Ubound(array_tmp,2)
		    	if Request.QueryString("filtro") = "1" Then
		    		Response.Write "<option value=""" & array_tmp(0,i) & "|" & array_tmp(4,i) & """>"
		    	Else
					Response.Write "<option value=""" & array_tmp(0,i) & "|" & array_tmp(2,i) & "|" & array_tmp(3,i) & """>"
				End If
		      Response.Write array_tmp(1,i) & "</option>" & VbCrLf
		    Next

		else
			
			Response.Write "<option> Destinario </option>"

		end if
	else
		Response.Write "<option> Destinario </option>"
	end if
End If
Response.End()
%>
