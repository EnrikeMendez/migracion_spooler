<%@ Language=VBScript %>
<% option explicit 
%><!--#include file="include/include.asp"-->
<%
Dim rst, SQL,array_tmp, i
Dim le_date_fin, ext_file, ext_ext_file
Dim le_vilclef, le_estado, le_ciudad, le_categoria, le_cargo 

call check_session()
Server.ScriptTimeout = 3000

if Request.QueryString("LA_CIUDAD") <> "Ciudad" then

	SQL = "SELECT  " & VbCrlf
	SQL = SQL & " 	DISTINCT dir.dieclave , INITCAP( NVL(DIE_A_ATENCION_DE, DIENOMBRE) || ' - ' || DIEADRESSE1 || ' - ' || DIEADRESSE2 || ' - ' || der_tipo_entrega), NVL(DER.DER_ALLCLAVE, 1), CCL.ccl_rfc, CCL.CCLCLAVE  " & VbCrlf
	SQL = SQL & " FROM  " & VbCrlf
	SQL = SQL & "  ECLIENT_CLIENTE  CCL  " & VbCrlf
	SQL = SQL & "  , EDIRECCIONES_ENTREGA DIR  " & VbCrlf
	SQL = SQL & "  , ECIUDADES CIU  " & VbCrlf
	SQL = SQL & "  , EESTADOS EST  " & VbCrlf
	SQL = SQL & "  , EDESTINOS_POR_RUTA DER  " & VbCrlf
	SQL = SQL & "  WHERE   " & VbCrlf
	SQL = SQL & "   CIU.VILCLEF = DIR.DIEVILLE  " & VbCrlf
	SQL = SQL & "   AND CCL.CCL_STATUS = 1  " & VbCrlf
	SQL = SQL & "   and die_cclclave = cclclave  " & VbCrlf
	SQL = SQL & "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO   " & VbCrlf
	SQL = SQL & "   AND DER.DER_VILCLEF = CIU.VILCLEF " & VbCrlf
	SQL = SQL & "   AND DER.DER_ALLCLAVE > 0 " & VbCrlf
	SQL = SQL & "   AND EST.EST_PAYCLEF = 'N3'  " & VbCrlf
	SQL = SQL & "   AND DIR.DIE_STATUS = 1  " & VbCrlf
	'20180430 -- > Restriccion por cliente
	SQL = SQL & "   AND SF_LOGIS_CLIENTE_RESTRIC(" & Session("array_client")(2,0) & ", DER_TIPO_ENTREGA) = 1 " & VbCrlf
	'20180430 < --
	if Request.QueryString("codepostal") <> "" Then	
			SQL = SQL & "   AND DIR.DIECODEPOSTAL = '" & Request.QueryString("codepostal") & "'"
	end if
	SQL = SQL & "   and CIU.VILCLEF = " & Request.QueryString("LA_CIUDAD")
	if Request.QueryString("destinatario_restrict") <> "''" Then
		SQL = SQL & "   and upper(INITCAP( NVL(DIE_A_ATENCION_DE, DIENOMBRE) || ' - ' || DIEADRESSE1 || ' - ' || DIEADRESSE2 || ' - ' || der_tipo_entrega)) like (upper('%" & Request.QueryString("destinatario_restrict") & "%'))"
	end if
	SQL = SQL & "   order by 2"

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

Response.End()
%>
