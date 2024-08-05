<%@ Language=VBScript %>
<% option explicit
%><!--#include file="include/include.asp"--><%
'timer :
Dim StopWatch(19)
	StartTimer 1

Response.Expires = 0
dim array_usr, SQL, loginId
dim array_factur,sql_factur,iRowfactur,iRowwel
dim SQL2, arrayTmp
dim filtroFolio
'<<<< se declara variable
dim filtro_doc_fte2
dim join_doc_fte_ltl1
'>>>>
dim arrStatus
dim noMenu
dim tarimas_logis
dim num_client, clef
Dim idConv, i
dim fromNUI, toNUI, tmpNUI
Dim PageSize, PageNum
dim es_doc_fte, es_con_fact
dim join_doc_fte_ltl, join_doc_fte_cd, filtro_doc_fte, tbl_doc_fte
Dim  FolSelect, rst, script_include, style_include, Filtro2
Dim arrayTemp, Filtro, entry_num, entry_to,filtro_union, arrayLTL, arrayCredito, impresionTalon
Dim ArrayEvidencias
Dim index_wel
dim reporte
dim Consec_1, Consec_2
Dim SQL_E,arrayEnt
Dim ArrayTariLogis,SQLTariLogis

'variables para concatenar facturas
Dim FechaFactura, NumFactura, FechaRevision, NumFolio
Dim Filtro_old, Filtro2_old, Filtro_new, Filtro2_new
Dim iRows, iCols, iRowLoop, iColLoop, iStop, iStart
Dim iRows2, iCols2


PageSize = 20
es_doc_fte = false
es_con_fact = false
filtroFolio = false
tbl_doc_fte = ""
filtro_doc_fte = ""
join_doc_fte_cd = ""
join_doc_fte_ltl = ""


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
	Session("SQL") = SQL
	array_usr = GetArrayRS(SQL)
	
	if IsArray(array_usr) and Request.QueryString("id") <> "" then
		'si no llegamos a esta pagina con un id de folio entonces se desconecta
		Session("array_client")= array_usr
		'guardamos el ID para los URL
		loginId = "&loginId=" & Request("loginId")
	end if
end if

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'L�gica para mostrar u ocultar el bot�n cancelar de la pantalla de Consulta LTL:
SQL = " SELECT NVL(NCREDITO_MONTO,0) FROM WEB_LOTS WHERE LOTE = 1 "
Session("SQL") = SQL
arrayTmp = GetArrayRS(SQL)

if IsArray(arrayTmp) then
	if arrayTmp(0,0) = "1" then
		mostrarBotonCancelar = true
	else
		mostrarBotonCancelar = false
	end if
end if
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

if Request("noMenu") <> "" then
	noMenu = "&noMenu=" & Request("noMenu")
end if
'<<<<<< se pasa toda la validación de criterios
if Request.Form("Criterio_1") <> "" then 
			if Request.Form("Criterio_1") = "rango_nuis" then
'			 join_doc_fte_ltl = "	AND	FD.NUI BETWEEN '" & SQLEscape(Request.Form("txtCriterioNui1")) & "' AND '" & SQLEscape(Request.Form("txtCriterioNui2")) & "' " & vbCrLf
'			 join_doc_fte_ltl1 = "	AND	WEL.WELCLAVE	=	FD.NUI " & vbCrLf
			 join_doc_fte_ltl = "	AND	WEL.WELCLAVE BETWEEN '" & SQLEscape(Request.Form("txtCriterioNui1")) & "' AND '" & SQLEscape(Request.Form("txtCriterioNui2")) & "' " & vbCrLf
			 join_doc_fte_ltl1 = "	 " & vbCrLf

			else if Request.Form("Criterio_1") = "rango_factura" then
			join_doc_fte_ltl = "	AND	FD.NO_FACTURA IN ('" & SQLEscape(Request.Form("txtCriterioFac1")) & "','" & SQLEscape(Request.Form("txtCriterioFac2")) & "') " & vbCrLf
			join_doc_fte_ltl1 = "	AND	WEL.WELCLAVE	=	FD.NUI " & vbCrLf

			else if Request.Form("Criterio_1") = "doc_fuente_new" then
			join_doc_fte_ltl1 = "SELECT DISTINCT FD.DOCUMENTO_FUENTE " & vbCrLf
			filtro_doc_fte2 = "	AND FD.DOCUMENTO_FUENTE IN ('" & SQLEscape(Request.Form("txtCriterio2")) & "','" & SQLEscape(Request.Form("txtCriterio3")) & "')" & vbCrLf

			else if Request.Form("Criterio_1") = "doc_fuente" then 
			tbl_doc_fte = "	,EFACTURAS_DOC FD	" & vbCrLf
			join_doc_fte_ltl = "	AND	WEL.WELCLAVE	=	FD.NUI " & vbCrLf
			join_doc_fte_cd = "		AND	WCD.WCDCLAVE	=	FD.NUI " & vbCrLf
			filtro_doc_fte = "		AND FD.DOCUMENTO_FUENTE	=	'" & SQLEscape(Request.Form("txtCriterio2")) & "' " & vbCrLf		
				end if
			end if	
		end if
	end if
end if
'''''''''''''' >>>>>>>>>>>>>>>>>>>>>>>
call check_session()
tarimas_logis = False

'verificar si el cliente documenta tarimas Logis
'esas tarimas pueden no tener la misma cantidad de detalle de bultos que el encabezado.
SQL = "SELECT COUNT(0) " & vbCrLf
SQL = SQL & " FROM ECLIENT_MODALIDADES " & vbCrLf
SQL = SQL & " WHERE CLM_CLICLEF = " & SQLEscape(Session("array_client")(2,0))
SQL = SQL & " AND CLM_MOECLAVE = 27 " & vbCrLf

Session("SQL") = SQL
arrayLTL = GetArrayRS(SQL)

if arrayLTL(0,0) > "0" then
	tarimas_logis = True
end if

for each clef  in Request.Form
	if Left(clef,6) = "client" then
		num_client=num_client & "," & Request.Form(clef)
	end if
next

num_client = mid(num_client,2) 'on enleve la virgule superflue
if	num_client <> "" or Request.QueryString("tipo") = "1" or Request.form("manif_num") <> "" _
	or Request.Form("etapa") <> "" or Request.QueryString("id") <> ""  then
		session ("tab_ltl") = ""
		set session ("tab_ltl") = nothing
end if

if num_client = "" then
	num_client = print_clinum
end if

if num_client <> "" then
	es_doc_fte = es_captura_con_doc_fuente(num_client)
end if
if num_client <> "" then
	es_con_fact = es_captura_con_factura(num_client)
end if

if Request.Form("Criterio_1") = "rango_nuis" then
	Filtro = " AND WEL.WEL_CLICLEF IN ("& num_client &") " & VbCrlf & _
			 " AND WEL.WELSTATUS != 3 " & VbCrlf
else
	Filtro = " AND WEL.WEL_CLICLEF IN ("& num_client &") " & VbCrlf & _
			 " AND WEL.DATE_CREATED > SYSDATE - DECODE(WEL_CLICLEF, 3528, 90, 365) " & VbCrlf & _
			 " AND WEL.WELSTATUS != 3 " & VbCrlf
end if
Filtro2 = Filtro

'estamos creando un manifiesto, verificamos que la fecha de recoleccion sea coherente.
if Request.Form("etapa") = "1" and Request.Form("fecha_recoleccion") <> "" then
	SQL = "SELECT 1 " & VbCrlf
	SQL = SQL & " FROM DUAL " & VbCrlf
	SQL = SQL & " WHERE TO_DATE('"& Request.Form("fecha_recoleccion") &"', 'DD/MM/YYYY') BETWEEN TRUNC(SYSDATE) -6 AND TRUNC(SYSDATE) + 6"
	
	Session("SQL") = SQL
	arrayTemp = GetArrayRS(SQL)
	
	if not IsArray(arrayTemp) then
		Response.Redirect "ltl_consulta.asp?tipo=1&msg=" & Server.URLEncode("La fecha de recoleccion no puede ser superior o inferior a 5 dias.")
	end if
end if

if Request.Form("etapa") = "2" then
	if Request.Form("check_welclave")="" then
		Response.write "Selecciona al menos una LTL"
		Response.end
	end if
	
	Set rst = Server.CreateObject("ADODB.Recordset")
	
	'creamos un nuevo convertidor
	SQL = "SELECT SEQ_WLCONVERTIDOR.nextval FROM DUAL"
	
	Session("SQL") = SQL
	idConv = GetArrayRS(SQL)(0,0)
	
	Set rst = Server.CreateObject("ADODB.Recordset")
	
	SQL = "INSERT INTO WLCONVERTIDOR (WLCCLAVE, WLCSTATUS, CREATED_BY, DATE_CREATED, WLC_CLICLEF)  " & vbCrLf
	SQL = SQL & " VALUES("& idConv &", 1, UPPER('"& Session("array_client")(0,0) &"'), SYSDATE, " & Session("array_client")(2,0) & ") "
	
	Session("SQL") = SQL
	rst.Open SQL, Connect(), 0, 1, 1
	
	'insercion en el detalle de convertidor
	for i = 0 to UBound(Split(Request.Form("check_welclave"), ","))
		SQL = "SELECT WEL_CDAD_BULTOS  " & vbCrLf
		SQL = SQL & "FROM WEB_LTL " & vbCrLf
		SQL = SQL & "WHERE WELCLAVE = '" & SQLEscape(Split(Request.Form("check_welclave"), ",")(i)) & "'" & vbCrLf
		
		Session("SQL") = SQL
		arrayTemp = GetArrayRS(SQL)
		
		SQL = " INSERT INTO WLDET_CONVERTIDOR ( " & vbCrLf
		SQL = SQL & "	WLDCLAVE, WLD_WELCLAVE, WLD_WLCCLAVE " & vbCrLf
		SQL = SQL & "	, DATE_CREATED, CREATED_BY, WLD_CDAD_BULTOS)  " & vbCrLf
		SQL = SQL & " VALUES ( SEQ_WLDET_CONVERTIDOR.nextval, '"& SQLEscape(Split(Request.Form("check_welclave"), ",")(i)) & "', " & idConv & vbCrLf
		SQL = SQL & "	, SYSDATE, UPPER('"& Session("array_client")(0,0) &"'), "& arrayTemp(0,0) &" ) "
		
		Session("SQL") = SQL
		rst.Open SQL, Connect(), 0, 1, 1
	next
	
	SQL = "UPDATE WEB_LTL  " & VbCrlf
	SQL = SQL & "   SET WEL_MANIF_NUM =( " & VbCrlf
	SQL = SQL & " 		SELECT NVL(MAX(WEL_MANIF_NUM)+1,1) " & VbCrlf
	SQL = SQL & "  		FROM WEB_LTL " & VbCrlf
	SQL = SQL & "  		WHERE WEL_CLICLEF IN ( " & print_clinum & " ) )" & VbCrlf
	SQL = SQL & "   ,WEL_MANIF_FECHA = SYSDATE    " & VbCrlf
	
	if Request.Form("fecha_recoleccion") <> "" then
		SQL = SQL & "   ,WEL_FECHA_RECOLECCION = TO_DATE('"& Request.Form("fecha_recoleccion") &" "& Request.Form("hora_recoleccion") &":"& Request.Form("minutos_recoleccion") &"', 'DD/MM/YYYY hh24:mi')"
	end if
	
	SQL = SQL & " WHERE WELCLAVE IN ("& Request.Form("check_welclave")& ")"
	SQL = SQL & "  AND WEL_CLICLEF IN ( " & print_clinum & " )"
	
	Session("SQL") = SQL
	rst.Open SQL, Connect(), 0, 1, 1
	
	SQL2 = "SELECT COUNT(0) FROM WEB_CAPTURA_PARAMETROS WHERE WCP_CLICLEF = " & Session("array_client")(2,0) & " AND NVL(WCP_CAPTURA_MANIF_II,'N') = 'P' OR NVL(WCP_CAPTURA_MANIF_II,'N') = 'S' "
	
	Session("SQL") = SQL
	arrayTmp = GetArrayRS(SQL2)
	
	if arrayTmp(0, 0) > "0" then
		Response.Redirect "ltl_consulta_manif3.asp?msg="& Server.URLEncode("Manifiesto creado.")& "&id=" & Request.Form("check_welclave")&""
	else
		Response.Redirect "ltl_consulta_manif.asp?msg="& Server.URLEncode("Manifiesto creado.")& "&id=" & Request.Form("check_welclave")&""
	end if
elseif Request.Form("etapa")= "1" then
	'creacion del manifiesto, agregar indices
	index_wel = "/*+INDEX(WEL IDX_WEL_DIS_MANIF)*/"
	Filtro = Filtro &  " AND WEL.WELSTATUS = 1  " & VbCrlf
	Filtro = Filtro &  " AND WEL.WEL_HAY_MANIF = 0  " & VbCrlf
	Filtro = Filtro &  " AND WEL.WEL_DISCLEF = " & Request.Form("DISCLEF")  & VbCrlf
	if Request.Form("Criterio_1") <> "rango_nuis" and Request.Form("Criterio_1") <> "rango_factura" then
		Filtro = Filtro &  " AND WEL.DATE_CREATED > SYSDATE - 30 "  & VbCrlf
	end if
	
	Filtro2 = Filtro2 &  " AND WEL.WELSTATUS = 1  " & VbCrlf
	Filtro2 = Filtro2 &  " AND WEL.WEL_HAY_MANIF = 0  " & VbCrlf
	Filtro2 = Filtro2 &  " AND WEL.WEL_DISCLEF = " & Request.Form("DISCLEF")  & VbCrlf
	if Request.Form("Criterio_1") <> "rango_nuis" and Request.Form("Criterio_1") <> "rango_factura" then
		Filtro2 = Filtro2 &  " AND WEL.DATE_CREATED > SYSDATE - 30 "  & VbCrlf
	end if
	
	if Request.Form("recoleccion_domicilio") <>"" then
		Filtro = Filtro & "  AND WEL.WELRECOL_DOMICILIO = '" & Request.Form("recoleccion_domicilio") & "' AND TRA.TRACLAVE IS NULL " & VbCrlf
		Filtro2= Filtro2 & "  AND WEL.WELRECOL_DOMICILIO = '" & Request.Form("recoleccion_domicilio") & "' AND TRA.TRACLAVE IS NULL " & VbCrlf
	else
		Filtro = Filtro & " AND WEL.WELRECOL_DOMICILIO = 'N' " & VbCrlf
		Filtro2 =Filtro2 &  " AND WEL.WELRECOL_DOMICILIO = 'N' " & VbCrlf
	end if
end if

entry_num = Request.Form("entry_num")
entry_to = Request.Form("entry_to")

if entry_num = "" and entry_to = "" and Request.Form("etapa") <> "1" and Request.Form("manif_num")="" and  Request.QueryString("id")=""  then
	if Request.Form("Criterio_1") <> "rango_nuis" and Request.Form("Criterio_1") <> "rango_factura" then
	Filtro = Filtro & " AND WEL.DATE_CREATED > sysdate - 30 " & VbCrlf	
	Filtro2 = Filtro2 & " AND WEL.DATE_CREATED > sysdate - 30 " & VbCrlf
	end if
end if

'########################
'## Criterios de fecha ##
'########################
select case Request.Form("Criterio_1")
	case "fecha_creacion"	'por fecha de creacion
		if entry_num = "" and entry_to = "" then
			Filtro = Filtro & " AND WEL.DATE_CREATED > sysdate - 30 "
			Filtro2 = Filtro2 & " AND WEL.DATE_CREATED > sysdate - 30 "
		else
			Filtro = Filtro & " AND trunc(WEL.DATE_CREATED) < to_date('" & SQLEscape(entry_to) & "', 'DD/MM/YYYY') + 1  AND trunc(WEL.DATE_CREATED) >= to_date('" & SQLEscape(entry_num) & "', 'DD/MM/YYYY')  "
			Filtro2 = Filtro2 & " AND trunc(WEL.DATE_CREATED) < to_date('" & SQLEscape(entry_to) & "', 'DD/MM/YYYY') + 1  AND trunc(WEL.DATE_CREATED) >= to_date('" & SQLEscape(entry_num) & "', 'DD/MM/YYYY')  "
		end if
		
	case "talon"
		if IsNumeric(SQLEscape(entry_num)) and IsNumeric(SQLEscape(entry_to)) then
			Filtro = Filtro & " AND WEL.WELCONS_GENERAL BETWEEN " & SQLEscape(entry_num) & " AND " & SQLEscape(entry_to)
			Filtro2 = Filtro2 & " AND WEL.WELCONS_GENERAL BETWEEN " & SQLEscape(entry_num) & " AND " & SQLEscape(entry_to)
		else
			Consec_1 = 0
			Consec_2 = 0
			
			if InStr(SQLEscape(entry_num),"-") > 0 then
				Consec_1 = split(SQLEscape(entry_num),"-")(0)
			end if
			
			if InStr(SQLEscape(entry_to),"-") > 0 then
				Consec_2 = split(SQLEscape(entry_to),"-")(0)
			end if
			
			Filtro = Filtro & " AND WEL.WELCONS_GENERAL BETWEEN " & Consec_1 & " AND " & Consec_2
			Filtro2 = Filtro2 & " AND WEL.WELCONS_GENERAL BETWEEN " & Consec_1 & " AND " & Consec_2
		end if
	
	case "recolec_pend"
		Filtro = Filtro & " AND TAE.TAEFECHALLEGADA IS NULL AND TRA.TRACLAVE IS NULL AND WEL.WELSTATUS=1"
		Filtro2 = Filtro2 & " AND TAE.TAEFECHALLEGADA IS NULL AND TRA.TRACLAVE IS NULL AND WEL.WELSTATUS=1"
	
	case "fecha_entrega"
		Filtro = Filtro & " AND DECODE(dxp.DXP_TIPO_ENTREGA,'TRASLADO',DXP2.DXP_FECHA_ENTREGA,DXP.DXP_FECHA_ENTREGA) BETWEEN to_date('" & SQLEscape(entry_num) & "', 'DD/MM/YYYY')  AND to_date('" & SQLEscape(entry_to) & "', 'DD/MM/YYYY')+1 "
		Filtro2 = Filtro2 & " AND DECODE(dxp.DXP_TIPO_ENTREGA,'TRASLADO',DXP.DXP_FECHA_ENTREGA) BETWEEN to_date('" & SQLEscape(entry_num) & "', 'DD/MM/YYYY')  AND to_date('" & SQLEscape(entry_to) & "', 'DD/MM/YYYY')+1 "
	
	case "entrega_pend"
		Filtro = Filtro &  " AND DECODE(dxp.DXP_TIPO_ENTREGA,'TRASLADO',DECODE(DXP2.DXP_FECHA_ENTREGA,NULL,'POR ENTREGAR'),DECODE(DXP.DXP_FECHA_ENTREGA,NULL,'POR ENTREGAR')) ='POR ENTREGAR' AND TRA.TRACLAVE IS NOT NULL"
		Filtro2= Filtro2 & " AND DECODE(DXP.DXP_FECHA_ENTREGA,NULL,'POR ENTREGAR') ='POR ENTREGAR' AND TRA.TRACLAVE IS NOT NULL"
	
	case "nui"
		'Se agregan controles para consultar un rango de NUI's.
		fromNUI = SQLEscape(Request.Form("from_NUI"))
		toNUI = SQLEscape(Request.Form("to_NUI"))
		
		if fromNUI > toNUI then
			tmpNUI = toNUI
			toNUI = fromNUI
			fromNUI = tmpNUI
		end if
		
		Filtro = Filtro &  " AND WELCLAVE BETWEEN '" & fromNUI & "' AND '" & toNUI & "' " & VbCrlf
		Filtro2 = Filtro2 &  " AND WELCLAVE BETWEEN '" & fromNUI & "' AND '" & toNUI & "' " & VbCrlf
		Filtro_old = Filtro_old &  " AND WELCLAVE BETWEEN '" & fromNUI & "' AND '" & toNUI & "' " & VbCrlf
		Filtro2_old = Filtro2_old &  " AND WELCLAVE BETWEEN '" & fromNUI & "' AND '" & toNUI & "' " & VbCrlf
		Filtro_new = Filtro_new &  " AND WELCLAVE BETWEEN '" & fromNUI & "' AND '" & toNUI & "' " & VbCrlf
		Filtro2_new = Filtro2_new &  " AND WELCLAVE BETWEEN '" & fromNUI & "' AND '" & toNUI & "' " & VbCrlf
end select


'##########################
'##   Criterios Varios   ##
'##########################

'destinatarios, ciudades y estados
select case Request.Form("criterio_3")
	case "ltl_destinatarios_3"
		if Request.Form("ltl_destinatarios_3_ok")<>"" then
			Filtro_old = " AND WCCL.WCCLCLAVE IN (" & Request.Form("ltl_destinatarios_3_ok") & ") " & VbCrlf
			Filtro2_old = " AND WCCL.WCCLCLAVE IN (" & Request.Form("ltl_destinatarios_3_ok") & ") " & VbCrlf
			Filtro_new = " AND DIR.DIECLAVE IN (" & Request.Form("ltl_destinatarios_3_ok") & ") " & VbCrlf
			Filtro2_new = " AND DIR.DIECLAVE IN (" & Request.Form("ltl_destinatarios_3_ok") & ") " & VbCrlf
		end if
	
	case "ltl_ciudad_3"
		if Request.Form("ltl_ciudad_3_ok")<>"" then
			Filtro = Filtro & " AND CIU_DEST.VILCLEF IN ( " & Trim(Request.Form("ltl_ciudad_3_ok")) & ")"  & VbCrlf
			Filtro2 = Filtro2 & " AND CIU_DEST.VILCLEF IN ( " & Trim(Request.Form("ltl_ciudad_3_ok")) & ")"  & VbCrlf
		end if
	
	case "ltl_estado_3"
		if Request.Form("ltl_estado_3_ok")<>"" then
			Filtro = Filtro & " AND EST_DEST.ESTESTADO IN ( " & Trim(Request.Form("ltl_estado_3_ok")) & ")"  & VbCrlf
			Filtro2 = Filtro2 & " AND EST_DEST.ESTESTADO IN ( " & Trim(Request.Form("ltl_estado_3_ok")) & ")"  & VbCrlf
		end if
end select

if Request.QueryString("id") <> "" and IsNumeric(Request.QueryString("id")) then
	Filtro = Filtro & " AND WEL.WELCLAVE IN ( " & SQLEscape(Request.QueryString("id")) & ")"   & VbCrlf
	Filtro2 = Filtro2 & " AND WEL.WELCLAVE IN ( " & SQLEscape(Request.QueryString("id")) & ")"	 & VbCrlf
elseif Request.Form("manif_num")<>"" then
	Filtro = Filtro & " AND WEL.WEL_MANIF_NUM = (" & Request.Form("manif_num") & ")  "  & VbCrlf
	Filtro2 = Filtro2 & " AND WEL.WEL_MANIF_NUM = (" & Request.Form("manif_num") & ")  "  & VbCrlf
end if

script_include = "<!-- main calendar program -->" & vbCrLf & _
				 "<script type=""text/javascript"" src=""include/jscalendar/calendar.js""></script>" & vbCrLf & _
				 "<!-- language for the calendar -->" & vbCrLf & _
				 "<script type=""text/javascript"" src=""include/jscalendar/lang/calendar-es.js""></script>" & vbCrLf & _
				 "<!-- the following script defines the Calendar.setup helper function, which makes" & vbCrLf & _
				 "      adding a calendar a matter of 1 or 2 lines of code. -->" & vbCrLf & _
				 "<script type=""text/javascript"" src=""include/jscalendar/calendar-setup.js""></script>" & vbCrLf & _
				 "<script language=""JavaScript"" src=""include/js/tigra_tables.js""></script>" & vbCrLf & _
				 "<script type=""text/javascript"" src=""./include/js/jquery-1.2.3.js""></script>" & vbCrLf

style_include = "<!-- calendar stylesheet -->" & vbCrLf & _
				"<link rel=""stylesheet"" type=""text/css"" media=""all"" href=""include/jscalendar/skins/aqua/theme.css"" title=""Aqua"" />" & vbCrLf

if Request.QueryString("noMenu") = "1" then
	Response.Write "<html><head><title>Logis | Consulta LTL</title>" & vbCrLf
	Response.Write script_include & vbCrLf
	Response.Write style_include & vbCrLf
	Response.Write "<link rel=""stylesheet"" type=""text/css"" href=""./include/css/logis.css"">" & vbCrLf
	Response.Write "<link rel=""stylesheet"" type=""text/css"" href=""./include/menu/menu.css"">" & vbCrLf
	Response.Write "</head><body style=""margin-top: 0;"">"
else
	Response.Write print_headers("Consulta LTL", "ltl", script_include, style_include, "")
	Response.Write "<img border=""0"" width=""0"" src=""images/pixel.gif"" height=""100"">"
end if

'affichage du popup pour la fonction filtre_col
call print_popup()
%>
<div id="menu" style="text-align:center; z-index:1;">
<%
	call print_saldo_monedero
	'contador y paginador
'<<<<<<< se reemplaza toda la linea
	if not IsArray (session("tab_ltl")) then
	'if Request.Form("Criterio_1") = "doc_fuente_new" then
	'	SQL = join_doc_fte_ltl1
	'else
		SQL = " SELECT " & index_wel & "  WEL.WELCLAVE, WEL.DATE_CREATED " & VbCrlf
	'end if
		SQL = SQL & " FROM WEB_LTL WEL" & VbCrlf
		SQL = SQL & "  , EDIRECCIONES_ENTREGA DIR " & VbCrlf
		SQL = SQL & "  , ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
		SQL = SQL & "  , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
		SQL = SQL & "  , ETRANS_ENTRADA TAE  " & VbCrlf
		SQL = SQL & "  , EDET_EXPEDICIONES DXP " & VbCrlf
		SQL = SQL & "  , EDET_EXPEDICIONES DXP2 " & VbCrlf
		SQL = SQL & "  , ECIUDADES CIU_DEST  " & VbCrlf
		SQL = SQL & "  , EESTADOS EST_DEST  " & VbCrlf
		
		'<<<<< se agrega la tabla de EFACTURAS_DOC
			if es_doc_fte = true or es_con_fact = true then 'or Request.Form("Criterio_1") = "rango_nuis" then
				SQL = SQL & VbCrlf & "	,EFACTURAS_DOC FD	" & VbCrlf
			end if
		'>>>>>>
		SQL = SQL & " WHERE DIR.DIECLAVE = WEL.WEL_DIECLAVE " & VbCrlf
		'<<<< se insertan los filtros 
			if Request.Form("Criterio_1") = "doc_fuente_new" then '--pclp--
				SQL = SQL & filtro_doc_fte2
			end if
			if Request.Form("Criterio_1") = "rango_nuis" then '--pclp---
				SQL = SQL & join_doc_fte_ltl1
				SQL = SQL & join_doc_fte_ltl
			end if
			if Request.Form("Criterio_1") = "rango_factura" then '--pclp---
				SQL = SQL & join_doc_fte_ltl1
				SQL = SQL & join_doc_fte_ltl
				SQL = SQL & filtro_doc_fte
			end if
		'>>>>>>>>>
		
		SQL = SQL &  Filtro
		SQL = SQL &  Filtro_new
		
		SQL = SQL & "  AND WEL.WEL_DIECLAVE IS NOT NULL " & VbCrlf
		SQL = SQL & "  AND TDCD.TDCDCLAVE = WEL.WEL_TDCDCLAVE " & VbCrlf
		SQL = SQL & "  AND TRA.TRACLAVE = WEL.WEL_TRACLAVE  " & VbCrlf
		SQL = SQL & "  AND TRA.TRASTATUS = '1' " & VbCrlf
		SQL = SQL & "  AND TAE.TAE_TRACLAVE = TRA.TRACLAVE  " & VbCrlf
		SQL = SQL & "  AND DXP.DXP_TDCDCLAVE(+) = TDCD.TDCDCLAVE " & VbCrlf
		SQL = SQL & "  AND DXP2.DXPCLAVE =  (    " & VbCrlf
		SQL = SQL & "       SELECT NVL(MAX(DEX.DXPCLAVE),DXP.DXPCLAVE) " & VbCrlf
		SQL = SQL & "       FROM EDET_EXPEDICIONES DEX " & VbCrlf
		SQL = SQL & "   	  WHERE DEX.DXP_TIPO_ENTREGA = 'DIRECTO' " & VbCrlf
		SQL = SQL & "         CONNECT BY PRIOR DEX.DXPCLAVE = DEX.DXP_DXPCLAVE   " & VbCrlf
		SQL = SQL & "         START WITH DEX.DXPCLAVE = (  " & VbCrlf
		SQL = SQL & "    		   	 SELECT DXPCLAVE  " & VbCrlf
		SQL = SQL & "              FROM WEB_LTL WEL2  " & VbCrlf
		SQL = SQL & "                , ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
		SQL = SQL & "    			   , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
		SQL = SQL & "    			   , EDET_EXPEDICIONES DXP " & VbCrlf
		SQL = SQL & "              WHERE WEL2.WELCLAVE = WEL.WELCLAVE " & VbCrlf
		SQL = SQL & "    			   AND TDCD.TDCDCLAVE = WEL.WEL_TDCDCLAVE  " & VbCrlf
		SQL = SQL & "    			   AND TRA.TRACLAVE = TDCD.TDCD_TRACLAVE  " & VbCrlf
		SQL = SQL & "                AND DXP.DXP_TDCDCLAVE = TDCD.TDCDCLAVE  " & VbCrlf
		SQL = SQL & "                AND TRA.TRASTATUS = '1'  " & VbCrlf
		SQL = SQL & "         )		 " & VbCrlf
		SQL = SQL & "   	)	 " & VbCrlf
		SQL = SQL & "  AND CIU_DEST.VILCLEF = DIR.DIEVILLE  " & VbCrlf
		SQL = SQL & "  AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
		
		SQL = SQL & " UNION " & VbCrlf
		
		'mostrar los talones que no tienen entrega (DXPCLAVE IS NULL)
			'if Request.Form("Criterio_1") = "doc_fuente_new" then
			'	SQL = SQL & join_doc_fte_ltl1
			'else
		SQL = SQL & " SELECT " & index_wel & " DISTINCT WEL.WELCLAVE, WEL.DATE_CREATED " & VbCrlf
			'end if
		SQL = SQL & " FROM WEB_LTL WEL " & VbCrlf
		SQL = SQL & "  , EDIRECCIONES_ENTREGA DIR " & VbCrlf
		SQL = SQL & "  , ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
		SQL = SQL & "  , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
		SQL = SQL & "  , ETRANS_ENTRADA TAE  " & VbCrlf
		SQL = SQL & "  , EDET_EXPEDICIONES DXP " & VbCrlf
		SQL = SQL & "  , ECIUDADES CIU_DEST  " & VbCrlf
		SQL = SQL & "  , EESTADOS EST_DEST  " & VbCrlf
		'<<<<< se agrega la tabla de EFACTURAS_DOC
			if es_doc_fte = true or es_con_fact = true or Request.Form("Criterio_1") = "rango_nuis" then
				SQL = SQL & VbCrlf & "	,EFACTURAS_DOC FD	" & VbCrlf
			end if
		'>>>>>>
		SQL = SQL & " WHERE DIR.DIECLAVE = WEL.WEL_DIECLAVE " & VbCrlf
		'<<<< se insertan los filtros 
			if Request.Form("Criterio_1") = "doc_fuente_new" then '--pclp--
				SQL = SQL & filtro_doc_fte2 
			end if
			if Request.Form("Criterio_1") = "rango_nuis" then '--pclp---
				SQL = SQL & join_doc_fte_ltl1
				SQL = SQL & join_doc_fte_ltl
			end if
			if Request.Form("Criterio_1") = "rango_factura" then '--pclp---
				SQL = SQL & join_doc_fte_ltl1
				SQL = SQL & join_doc_fte_ltl
				SQL = SQL & filtro_doc_fte
			end if
		'>>>>>>>>>
		
		SQL = SQL & Filtro2 
		SQL = SQL & Filtro2_new
		
		SQL = SQL & "  AND WEL.WEL_DIECLAVE IS NOT NULL " & VbCrlf
		SQL = SQL & "  AND TDCD.TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE " & VbCrlf
		SQL = SQL & "  AND TRA.TRACLAVE(+) = WEL.WEL_TRACLAVE  " & VbCrlf
		SQL = SQL & "  AND TRA.TRASTATUS(+) = '1' " & VbCrlf
		SQL = SQL & "  AND TDCD.TDCDSTATUS(+) = '1' " & VbCrlf
		SQL = SQL & "  AND TAE.TAE_TRACLAVE(+) = TRA.TRACLAVE  " & VbCrlf
		SQL = SQL & "  AND DXP.DXP_TDCDCLAVE(+) = TDCD.TDCDCLAVE " & VbCrlf
		SQL = SQL & "  AND DXP.DXPCLAVE IS NULL " & VbCrlf
		SQL = SQL & "  AND CIU_DEST.VILCLEF = DIR.DIEVILLE  " & VbCrlf
		SQL = SQL & "  AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
		
		SQL = SQL & " UNION " & VbCrlf
			'if Request.Form("Criterio_1") = "doc_fuente_new" then
			'	SQL = SQL & join_doc_fte_ltl1
			'else
		SQL = SQL & " SELECT " & index_wel & "  WEL.WELCLAVE, WEL.DATE_CREATED " & VbCrlf
			'end if
		SQL = SQL & " FROM WEB_LTL WEL" & VbCrlf
		SQL = SQL & "  , WEB_CLIENT_CLIENTE WCCL " & VbCrlf
		SQL = SQL & "  , ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
		SQL = SQL & "  , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
		SQL = SQL & "  , ETRANS_ENTRADA TAE  " & VbCrlf
		SQL = SQL & "  , EDET_EXPEDICIONES DXP " & VbCrlf
		SQL = SQL & "  , EDET_EXPEDICIONES DXP2 " & VbCrlf
		SQL = SQL & "  , ECIUDADES CIU_DEST  " & VbCrlf
		SQL = SQL & "  , EESTADOS EST_DEST  " & VbCrlf
		'<<<<< se agrega la tabla de EFACTURAS_DOC
			if es_doc_fte = true or es_con_fact = true or Request.Form("Criterio_1") = "rango_nuis" then
				SQL = SQL & VbCrlf & "	,EFACTURAS_DOC FD	" & VbCrlf
			end if
		'>>>>>>
		SQL = SQL & " WHERE WCCL.WCCLCLAVE = WEL.WEL_WCCLCLAVE " & VbCrlf
		'<<<< se insertan los filtros 
			if Request.Form("Criterio_1") = "doc_fuente_new" then '--pclp--
				SQL = SQL & filtro_doc_fte2 
			end if
			if Request.Form("Criterio_1") = "rango_nuis" then '--pclp---
				SQL = SQL & join_doc_fte_ltl1
				SQL = SQL & join_doc_fte_ltl
			end if
			if Request.Form("Criterio_1") = "rango_factura" then '--pclp---
				SQL = SQL & join_doc_fte_ltl1
				SQL = SQL & join_doc_fte_ltl
				SQL = SQL & filtro_doc_fte
			end if
		'>>>>>>>>>
		
		SQL = SQL & "  AND WEL.WEL_DIECLAVE IS NULL " & VbCrlf
		
		SQL = SQL &  Filtro
		SQL = SQL &  Filtro_old
		
		SQL = SQL & "  AND WEL.WEL_WCCLCLAVE IS NOT NULL " & VbCrlf
		SQL = SQL & "  AND TDCD.TDCDCLAVE = WEL.WEL_TDCDCLAVE " & VbCrlf
		SQL = SQL & "  AND TRA.TRACLAVE = WEL.WEL_TRACLAVE  " & VbCrlf
		SQL = SQL & "  AND TRA.TRASTATUS = '1' " & VbCrlf
		SQL = SQL & "  AND TAE.TAE_TRACLAVE = TRA.TRACLAVE  " & VbCrlf
		SQL = SQL & "  AND DXP.DXP_TDCDCLAVE(+) = TDCD.TDCDCLAVE " & VbCrlf
		SQL = SQL & "  AND DXP2.DXPCLAVE =  (    " & VbCrlf
		SQL = SQL & "       SELECT NVL(MAX(DEX.DXPCLAVE),DXP.DXPCLAVE) " & VbCrlf
		SQL = SQL & "       FROM EDET_EXPEDICIONES DEX " & VbCrlf
		SQL = SQL & "   	  WHERE DEX.DXP_TIPO_ENTREGA = 'DIRECTO' " & VbCrlf
		SQL = SQL & "         CONNECT BY PRIOR DEX.DXPCLAVE = DEX.DXP_DXPCLAVE   " & VbCrlf
		SQL = SQL & "         START WITH DEX.DXPCLAVE = (  " & VbCrlf
		SQL = SQL & "    		   	 SELECT DXPCLAVE  " & VbCrlf
		SQL = SQL & "              FROM WEB_LTL WEL2  " & VbCrlf
		SQL = SQL & "                , ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
		SQL = SQL & "    			   , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
		SQL = SQL & "    			   , EDET_EXPEDICIONES DXP " & VbCrlf
		SQL = SQL & "              WHERE WEL2.WELCLAVE = WEL.WELCLAVE " & VbCrlf
		SQL = SQL & "    			   AND TDCD.TDCDCLAVE = WEL.WEL_TDCDCLAVE  " & VbCrlf
		SQL = SQL & "    			   AND TRA.TRACLAVE = TDCD.TDCD_TRACLAVE  " & VbCrlf
		SQL = SQL & "                AND DXP.DXP_TDCDCLAVE = TDCD.TDCDCLAVE  " & VbCrlf
		SQL = SQL & "                AND TRA.TRASTATUS = '1'  " & VbCrlf
		SQL = SQL & "         )		 " & VbCrlf
		SQL = SQL & "   	)	 " & VbCrlf
		SQL = SQL & "  AND CIU_DEST.VILCLEF = WCCL.WCCL_VILLE  " & VbCrlf
		SQL = SQL & "  AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
		
		SQL = SQL & " UNION " & VbCrlf
		
		'mostrar los talones que no tienen entrega (DXPCLAVE IS NULL)
			'if Request.Form("Criterio_1") = "doc_fuente_new" then
			'	SQL = SQL & join_doc_fte_ltl1
			'else
		SQL = SQL & " SELECT " & index_wel & " DISTINCT WEL.WELCLAVE, WEL.DATE_CREATED " & VbCrlf
			'end if
		SQL = SQL & " FROM WEB_LTL WEL " & VbCrlf
		SQL = SQL & "  , WEB_CLIENT_CLIENTE WCCL " & VbCrlf
		SQL = SQL & "  , ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
		SQL = SQL & "  , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
		SQL = SQL & "  , ETRANS_ENTRADA TAE  " & VbCrlf
		SQL = SQL & "  , EDET_EXPEDICIONES DXP " & VbCrlf
		SQL = SQL & "  , ECIUDADES CIU_DEST  " & VbCrlf
		SQL = SQL & "  , EESTADOS EST_DEST  " & VbCrlf
		'<<<<< se agrega la tabla de EFACTURAS_DOC
			if es_doc_fte = true or es_con_fact = true or Request.Form("Criterio_1") = "rango_nuis" then
				SQL = SQL & VbCrlf & "	,EFACTURAS_DOC FD	" & VbCrlf
			end if
		
		SQL = SQL & " WHERE WCCL.WCCLCLAVE = WEL.WEL_WCCLCLAVE " & VbCrlf
		'<<<< se insertan los filtros 
			if Request.Form("Criterio_1") = "doc_fuente_new" then '--pclp--
				SQL = SQL & filtro_doc_fte2 
			end if
			if Request.Form("Criterio_1") = "rango_nuis" then '--pclp---
				SQL = SQL & join_doc_fte_ltl1
				SQL = SQL & join_doc_fte_ltl
			end if
			if Request.Form("Criterio_1") = "rango_factura" then '--pclp---
				SQL = SQL & join_doc_fte_ltl1
				SQL = SQL & join_doc_fte_ltl
				SQL = SQL & filtro_doc_fte
			end if
		'>>>>>>>>>
		
		SQL = SQL & "  AND WEL.WEL_DIECLAVE IS NULL " & VbCrlf
		
		SQL = SQL & Filtro2
		SQL = SQL & Filtro2_old
		
		SQL = SQL & "  AND WEL.WEL_WCCLCLAVE IS NOT NULL " & VbCrlf
		SQL = SQL & "  AND TDCD.TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE " & VbCrlf
		SQL = SQL & "  AND TRA.TRACLAVE(+) = WEL.WEL_TRACLAVE  " & VbCrlf
		SQL = SQL & "  AND TRA.TRASTATUS(+) = '1' " & VbCrlf
		SQL = SQL & "  AND TDCD.TDCDSTATUS(+) = '1' " & VbCrlf
		SQL = SQL & "  AND TAE.TAE_TRACLAVE(+) = TRA.TRACLAVE  " & VbCrlf
		SQL = SQL & "  AND DXP.DXP_TDCDCLAVE(+) = TDCD.TDCDCLAVE " & VbCrlf
		SQL = SQL & "  AND DXP.DXPCLAVE IS NULL " & VbCrlf
		SQL = SQL & "  AND CIU_DEST.VILCLEF = WCCL.WCCL_VILLE  " & VbCrlf
		SQL = SQL & "  AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
		
		'<<<20240129: Agrego nueva consulta sólo para el caso de filtrar por documento fuente:
			if es_doc_fte = true and Request.Form("Criterio_1") = "doc_fuente_new" then
				SQL = SQL & "	UNION " & VbCrlf
				SQL = "		SELECT /*index_wel*/ DISTINCT WEL.WELCLAVE, WEL.DATE_CREATED " & VbCrlf
				SQL = SQL & "		FROM WEB_LTL WEL " & VbCrlf
				SQL = SQL & "			LEFT JOIN EFACTURAS_DOC FD " & VbCrlf
				SQL = SQL & "				ON	WEL.WELCLAVE = FD.NUI " & VbCrlf
				SQL = SQL & "		WHERE	DOCUMENTO_FUENTE IN ('" & Request.Form("txtCriterio2") & "','" & Request.Form("txtCriterio3") & "') " & VbCrlf
			end if
		'   20240129>>>
		
		SQL = SQL & " ORDER BY 2 DESC "
		
		response.write "<div id='dvQuery' style='visibility:collapse;display:none;'>" & Replace(SQL,vbCrLf,"<br>") & "</div>"
		'Response.end
		
		Session("SQL") = SQL
		arrayTemp = GetArrayRS(SQL)
		session ("tab_ltl") = arrayTemp
	end if
	'>>>>>>>>>>
	
	if isArray(Session ("tab_ltl")) Then
		arrayTemp = Session ("tab_ltl")
	end if
	if not IsArray(arrayTemp) then
		response.write "No records found !"
		Response.End
	end if
	
	'initialisation des num de page
	PageNum = Request("PageNum")
	if Not IsNumeric(PageNum) or Len(PageNum) = 0 then
		PageNum = 1
	else
		PageNum = CInt(PageNum)
	end if
	
	iRows = UBound(arrayTemp , 2)
	iCols = UBound(arrayTemp , 1)
	
	If iRows > (PageNum * PageSize ) Then
		iStop = PageNum * PageSize - 1
	Else
		iStop = iRows
	End If
	
	iStart = (PageNum -1 )* PageSize
	
	If iStart > iRows then
		'inutile en principe... mais bon si on modifie la variable pagenum...
		iStart = iStop - PageSize
	End If
	
	if Request.Form("etapa") = "1" then
		'si estamos creando un manifiesto entonces tenemos que agarar todos los talones
		iStart	 = 0
		iStop = UBound(arrayTemp , 2)
	end if
	
	'selection des 20 num de folios
	For iRowLoop = iStart to iStop
		if (iRowLoop >= 0 and iRowLoop <= UBound(arrayTemp , 2) ) then
			FolSelect = FolSelect & ", " & CSTR(arrayTemp(0,iRowLoop))
		end if
	Next
	FolSelect = Mid(FolSelect,3,Len (FolSelect))
	
	
	''''''''''''''
	'query rapido'
	SQL = "SELECT /*+ORDERED USE_nl(WEL DIR EAL_DEST EAL_ORI EST_DEST EST_ORI CIU_DEST CIU_ORI DTFF FCT dxp2)*/ DISTINCT WEL.WEL_CLICLEF	CLICLEF " & VbCrlf
	SQL = SQL & " , InitCap(CLI.CLINOM)	CLINOM " & VbCrlf
	
	'Se agrega IF para obtener el DOCUMENTO_FUENTE:
	If es_cross_dock(SQLEscape(Session("array_client")(2,0))) = true then
		SQL = SQL & " , '''' || TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(CLI.CLICLEF) REFERENCIA " & VbCrlf
	elseif es_doc_fte = true then		
	'<<2024-03-08: Se actualiza la forma de obtener la referencia a mostrar en la consulta:
		SQL = SQL & VbCrlf &  "  , '''' || NVL(NVL((SELECT LISTAGG(TO_CHAR(DF_FACT.DOCUMENTO_FUENTE), ', ') WITHIN GROUP (ORDER BY DF_FACT.DOCUMENTO_FUENTE DESC) DOCUMENTO_FUENTE FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI),WEL.WEL_ORDEN_COMPRA),WEL.WELFACTURA) REFERENCIA " & VbCrlf
	'  2024-03-08>>	
	'Se agrega IF para obtener la FACTURA:
	elseif es_con_fact = true then
		'<<<<< CHG-DESA-06032024: se agrega NVL para que obtenga la Factura de EFACTURAS_DOC y si no la encuentra se obtenga de WEB_LTL:
			'SQL = SQL & VbCrlf &  "  , (SELECT LISTAGG(TO_CHAR(DF_FACT.NO_FACTURA), ', ') WITHIN GROUP (ORDER BY DF_FACT.NO_FACTURA DESC) NO_FACTURA FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI) REFERENCIA " & VbCrlf
			SQL = SQL & VbCrlf &  "  , '''' || NVL((SELECT LISTAGG(TO_CHAR(DF_FACT.NO_FACTURA), ', ') WITHIN GROUP (ORDER BY DF_FACT.NO_FACTURA DESC) NO_FACTURA FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI),WEL.WELFACTURA) REFERENCIA " & VbCrlf
		'       CHG-DESA-06032024 >>>>>
	else
		SQL = SQL & " , '''' || TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(CLI.CLICLEF)	REFERENCIA " & VbCrlf
	end if
	
	SQL = SQL & " , '''' || WEL.WELFACTURA	FACTURA " & VbCrlf
	SQL = SQL & " , WEL.WEL_CDAD_BULTOS	CDAD_BULTOS " & VbCrlf
	SQL = SQL & " , EAL_ORI.ALLCODIGO	COD_ORIGEN " & VbCrlf
	SQL = SQL & " , InitCap(EAL_ORI.ALLNOMBRE)	NOM_ORIGEN " & VbCrlf
	SQL = SQL & " , InitCap(NVL(WVM_NOMBRE, DIS.DISNOM))	DIST_DESTINO " & VbCrlf
	SQL = SQL & " , InitCap(NVL(CIU_WVM.VILNOM, CIU_ORI.VILNOM) || ' ('|| NVL(EST_WVM.ESTNOMBRE, EST_ORI.ESTNOMBRE) || ')')	DIR_DESTINO " & VbCrlf
	SQL = SQL & " , EAL_DEST.ALLCODIGO	COD_DESTINO " & VbCrlf
	SQL = SQL & " , InitCap(EAL_DEST.ALLNOMBRE)	ALM_DESTINO " & VbCrlf
	SQL = SQL & " , InitCap(DIR.DIENOMBRE)	NOM_DESTINO " & VbCrlf
	SQL = SQL & " , InitCap(CIU_DEST.VILNOM)	CIUDAD_DESTINO " & VbCrlf
	SQL = SQL & " , InitCap(EST_DEST.ESTNOMBRE)	ESTADO_DESTINO " & VbCrlf
	SQL = SQL & " , TO_CHAR(NVL(TAE.TAEFECHALLEGADA,TAE.TAE_FECHA_RECOLECCION), 'DD/MM/YYYY hh24:mi')	FECHA_RECOLECCION " & VbCrlf
	SQL = SQL & " , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY hh24:mi')	FECHA_LLEGADA " & VbCrlf
	SQL = SQL & " , NVL(TO_CHAR(DXP2.DXP_FECHA_ENTREGA, 'DD/MM/YYYY hh24:mi'),TO_CHAR(DXP.DXP_FECHA_ENTREGA, 'DD/MM/YYYY hh24:mi'))	FECHA_ENTREGA "  & VbCrlf
	SQL = SQL & " , DECODE(WEL.WELSTATUS, 0, 'rojo', 2, 'naranja', 3, 'naranja', 'verde')	COLOR_ESTATUS " & VbCrlf
	SQL = SQL & " , DECODE(WEL.WELSTATUS, 0, 'Can', 2, 'StdBy', 3, 'Reserv.', 'Act')	ESTATUS " & VbCrlf
	SQL = SQL & " , WEL.WELCLAVE	NUI " & VbCrlf
	SQL = SQL & " , WEL.WELRECOL_DOMICILIO	RECOL_DOMICILIO " & VbCrlf
	SQL = SQL & " , NVL(WEL.WEL_TALON_RASTREO, WEL.WEL_FIRMA) AS TRACKING " & VbCrlf
	SQL = SQL & " , WEL.WEL_MANIF_NUM	MANIFIESTO" & VbCrlf
	SQL = SQL & " , WEL.WELVOLUMEN	VOLUMEN " & VbCrlf
	SQL = SQL & " , WEL.WELPESO	PESO " & VbCrlf
	SQL = SQL & " , WEL.WELIMPORTE	IMPORTE " & VbCrlf
	SQL = SQL & " , NULL	STATUS " & VbCrlf
	SQL = SQL & " , NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO)	PRECIO " & VbCrlf
	SQL = SQL & " , ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (TIVTASA / 100),2)	IVA " & VbCrlf
	SQL = SQL & " , ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (1 + (TIVTASA / 100)),2)	TOTAL " & VbCrlf
	SQL = SQL & " , RDE.RDECONS_GENERAL	CONSECUTIVO_EVIDENCIAS " & VbCrlf
	SQL = SQL & " , NULL " & VbCrlf
	SQL = SQL & " , NULL " & VbCrlf
	SQL = SQL & " , NULL	FCTNUMERO --FAC.FCTNUMERO  " & VbCrlf
	SQL = SQL & "  , NULL	FOLFOLIO  --FAC.FOLFOLIO " & VbCrlf
	SQL = SQL & "  , WEL.WEL_TDCDCLAVE	TDCDCLAVE --FAC.TDCDCLAVE" & VbCrlf
	SQL = SQL & "  , NULL	FCTCLEF --FAC.FCTCLEF " & VbCrlf
	SQL = SQL & " , InitCap(NVL(WEL.WEL_COLLECT_PREPAID, 'PREPAGADO'))	PREGAGADO " & VbCrlf
	SQL = SQL & " , DECODE(WEL.WEL_COLLECT_PREPAID, 'POR COBRAR', 'COD', 'Prep')	CVE_PREGAGADO " & VbCrlf
	SQL = SQL & " , CLI.CCL_RFC	RFC " & VbCrlf
	SQL = SQL & " , DECODE(NDV.NDV_FECHA_CANCELADO, NULL, 'N', 'S')	NOTA_VTA_FECHA_CANCEL " & VbCrlf
	SQL = SQL & " , NDV.NDVCLAVE	NOTA_VTA_CLAVE " & VbCrlf
	SQL = SQL & " , NULL	FCTCLIENT --FAC.FCTCLIENT " & VbCrlf
	SQL = SQL & " , NULL	TDCD_FCTCLEF --FAC.TDCD_FCTCLEF " & VbCrlf
	
	if tarimas_logis then
		'no verificar la cantidad de bultos contra el detalle
		SQL = SQL & " , DECODE(SIGN(WEL.WELVOLUMEN), 1, DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), 'MODIF')	PRINT_MODIF " & vbCrLf
	else
		SQL = SQL & " , DECODE(WEL.WEL_CDAD_BULTOS, (SELECT SUM(WPL_IDENTICAS) FROM WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), (SELECT SUM(WPL_IDENTICAS) FROM TB_LOGIS_WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), 'MODIF')	PRINT_MODIF " & vbCrLf
	end if
	
	SQL = SQL & " , WTLTIPO	TIPO " & VbCrlf
	SQL = SQL & " , WTL_ABREV	CVE_TIPO " & VbCrlf
	SQL = SQL & " , TO_CHAR(WEL_ORI.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL_ORI.WEL_CLICLEF)	TALON " & VbCrlf
	SQL = SQL & " , NVL(WEL_ORI.WEL_TALON_RASTREO, WEL_ORI.WEL_FIRMA) AS WEL_FIRMA_ORI  " & VbCrlf
	SQL = SQL & " , (SELECT 1 FROM ECLIENT_APLICA_CONCEPTOS CCO, EBASES_POR_CONCEPT BPC, ECONCEPTOSHOJA WHERE CCO_CLICLEF = WEL.WEL_CLICLEF AND BPCCLAVE = CCO_BPCCLAVE AND CHOCLAVE = BPC_CHOCLAVE AND CHONUMERO IN (240, 241) AND ROWNUM = 1 )	APLICA_CONCEPTO " & VbCrlf
	SQL = SQL & " , NVL(WEL.WEL_PRECIO_MANUAL, 'N')	PRECIO_MANUAL " & VbCrlf
	SQL = SQL & " , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY hh24:mi')	FECHA_RECOLECCION " & VbCrlf
	SQL = SQL & " ,  (SELECT /*+INDEX(WAS IDX_WAS_TDCDCLAVE)*/ COUNT(0)  " & VbCrlf
	SQL = SQL & "  FROM ETRANS_DETALLE_CROSS_DOCK TDCD, WEB_ARCHIVOS_ESCANEADOS WAS " & VbCrlf
	SQL = SQL & "  WHERE TDCDFACTURA = TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) " & VbCrlf
	SQL = SQL & "    AND WAS_TDCDCLAVE = TDCDCLAVE " & VbCrlf
	SQL = SQL & "    AND WAS_UPLOAD_WEB IS NOT NULL " & VbCrlf
	SQL = SQL & "  )	ARCHIVOS_ESCANEADOS " & VbCrlf
	SQL = SQL & " , DECODE(NVL(TDCD.TDCDSTATUS, 0), 1, DECODE(TRA.TRASTATUS, '1', 1, 0), 0)	STATUS_TRACKING " & VbCrlf
	SQL = SQL & " , WEL.WELSTATUS	STATUS_GUIA " & vbCrLf
	SQL = SQL & " , DIR.DIECLAVE	DIECLAVE " & vbCrLf
	SQL = SQL & " , WEL.DATE_CREATED	DATE_CREATED " & vbCrLf
	SQL = SQL & " , REPLACE(REPLACE(WEL.WELARCHIVO_CARGA, '.DAT', ''), '.xls', '')	ARCHIVO_CARGA " & vbCrLf
	
	'====NUMERO DE ETIQUETAS
	SQL = SQL & " , NVL( " & vbCrLf
	SQL = SQL & "    (SELECT COUNT(0) " & vbCrLf
	SQL = SQL & "    FROM ETRANS_ETIQUETAS_BULTOS TEB " & vbCrLf
	SQL = SQL & "    ,EIMPRESION_ETIQUETA_LOG " & vbCrLf
	SQL = SQL & "    WHERE WEL.WELCLAVE=TEB.TEB_WELCLAVE " & vbCrLf
	SQL = SQL & "    AND IEL_TEBCLAVE=TEB.TEBCLAVE " & vbCrLf
	SQL = SQL & "    AND TEB.TEBSTATUS=1 " & vbCrLf
	SQL = SQL & "    AND WEL.WEL_ALLCLAVE_ORI=1 ) " & vbCrLf
	SQL = SQL & "  ,0)	IMPRESION_ETIQUETAS " & vbCrLf
	SQL = SQL & "    ,WEL.WEL_WTLCLAVE	TIPO_NUI " & vbCrLf
	
	'===FUERA RUTA
	SQL = SQL & " ,  WEL.wel_cafrclave	CTE_AUTORIZA_FUERA_RUTA " & VbCrlf
	SQL = SQL & " , CAFR_PDF	PDF_AUTORIZA_FUERA_RUTA " & VbCrlf
	SQL = SQL & " , WEL.wel_validacion_status	VALIDACION_NUI " & VbCrlf
	
	SQL = SQL & " , 'WCCLCLAVE'	CVE_PROVEEDOR " & VbCrlf
	SQL = SQL & " , WEL.WEL_FIRMA FIRMA " & VbCrlf
	'<2024-07-31
	SQL = SQL & " , TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF)	TALON_FACTURA " & VbCrlf
	' 2024-07-31>
	SQL = SQL & " FROM WEB_LTL WEL " & VbCrlf
	SQL = SQL & " , ECLIENT CLI " & VbCrlf
	SQL = SQL & " , ETRANSFERENCIA_TRADING TRA " & VbCrlf
	SQL = SQL & " , ETRANS_ENTRADA TAE " & VbCrlf
	SQL = SQL & " , EALMACENES_LOGIS EAL_ORI " & VbCrlf
	SQL = SQL & " , EALMACENES_LOGIS EAL_DEST " & VbCrlf
	SQL = SQL & " , EDISTRIBUTEUR DIS " & VbCrlf
	SQL = SQL & " , ECIUDADES CIU_ORI " & VbCrlf
	SQL = SQL & " , EESTADOS EST_ORI " & VbCrlf
	SQL = SQL & " , WEB_LTL_VENTA_MOSTRADOR WVM " & VbCrlf
	SQL = SQL & " , ECIUDADES CIU_WVM " & VbCrlf
	SQL = SQL & " , EESTADOS EST_WVM " & VbCrlf
	SQL = SQL & " , EDIRECCIONES_ENTREGA DIR " & VbCrlf
	SQL = SQL & " , ECLIENT_CLIENTE CLI " & VbCrlf
	SQL = SQL & " , ECIUDADES CIU_DEST " & VbCrlf
	SQL = SQL & " , EESTADOS EST_DEST " & VbCrlf
	SQL = SQL & " , ETRANS_DETALLE_CROSS_DOCK TDCD" & VbCrlf
	SQL = SQL & " , EDET_EXPEDICIONES DXP" & VbCrlf
	SQL = SQL & " , EDET_EXPEDICIONES DXP2" & VbCrlf
	SQL = SQL & " , ERELACION_DE_EVIDENCIAS RDE" & VbCrlf
	SQL = SQL & " , ENOTA_DE_VENTA NDV " & VbCrlf
	SQL = SQL &  "   , WTIPO_LTL " & VbCrlf
	SQL = SQL &  "   , WEB_LTL WEL_ORI " & VbCrlf
	SQL = SQL &  "   , ETASAS_IVA " & VbCrlf
	
	'===FUERA RUTA
	SQL = SQL &  "   , ECLIENT_AUTORIZA_FUERA_RUTA " & VbCrlf
	
	
	
	'Se agrega TABLA para obtener el DOCUMENTO_FUENTE o la FACTURA segun la Configuracion del Cliente:
	if es_doc_fte = true or es_con_fact = true then
		SQL = SQL & VbCrlf & "	,EFACTURAS_DOC FD	" & VbCrlf
	elseif Request.Form("Criterio_1") = "doc_fuente" then
		SQL = SQL & tbl_doc_fte
	end if
	
	SQL = SQL & " WHERE CLI.CLICLEF = WEL.WEL_CLICLEF " & VbCrlf
	SQL = SQL & " AND TRA.TRACLAVE = WEL.WEL_TRACLAVE " & VbCrlf
	SQL = SQL & " AND tdcd.tdcdCLAVE = WEL.WEL_TDCDCLAVE " & VbCrlf
	SQL = SQL & " AND TAE.TAE_TRACLAVE = TRA.TRACLAVE " & VbCrlf
	SQL = SQL & " AND TRA.TRASTATUS = '1' " & VbCrlf
	SQL = SQL & " AND TDCD.TDCDSTATUS = '1' " & VbCrlf
	SQL = SQL & " AND WEL.WEL_TRACLAVE  = DXP.dxp_traclave(+) " & VbCrlf
	SQL = SQL & " AND WEL.WEL_TDCDCLAVE = DXP.dxp_tdcdclave(+) " & VbCrlf
	SQL = SQL & " AND DIR.DIE_CCLCLAVE = CLI.CCLCLAVE " & VbCrlf
	SQL = SQL & "  AND WEL.WEL_DIECLAVE IS NOT NULL " & VbCrlf
	SQL = SQL & " AND WEL.WEL_CAFRCLAVE = CAFRCLAVE(+) "  & VbCrlf
	
	'<<<< se insertan los filtros 
		if Request.Form("Criterio_1") = "doc_fuente_new" then '--pclp--
			SQL = SQL & filtro_doc_fte2 
			SQL = SQL &	filtro_doc_fte
		end if
		if Request.Form("Criterio_1") = "rango_nuis" then '--pclp---
			SQL = SQL & join_doc_fte_ltl
			SQL = SQL & filtro_doc_fte
		end if

		if Request.Form("Criterio_1") = "rango_factura" then '--pclp---
			SQL = SQL & join_doc_fte_ltl
			SQL = SQL & filtro_doc_fte
		end if
	'>>>>>>>>>
	
	if UBound(Split(FolSelect, ",")) > 1000 then
		SQL = SQL & "   AND (WEL.WELCLAVE IN ( "
		
		for i = 0 to UBound(Split(FolSelect, ","))
			SQL = SQL & Split(FolSelect, ",")(i)
			
			if i mod 999 = 0 and i <> 0 then
				SQL = SQL & "   ) "
				
				if i <> UBound(Split(FolSelect, ",")) then
					SQL = SQL & " OR WEL.WELCLAVE IN ("
				end if
			elseif i <> UBound(Split(FolSelect, ",")) then
				SQL = SQL & ","
			end if
			
			if i mod 100 = 0 then
				SQL = SQL & vbCrLf
			end if
		next
		
		SQL = SQL & "  )) " & VbCrlf
	else
		SQL = SQL & " AND WEL.WELCLAVE IN ("& FolSelect &") " & VbCrlf
	end if
	
	SQL = SQL & " AND EAL_ORI.ALLCLAVE = WEl.WEL_ALLCLAVE_ORI " & VbCrlf
	SQL = SQL & " AND EAL_DEST.ALLCLAVE = WEl.WEL_ALLCLAVE_DEST " & VbCrlf
	SQL = SQL & " AND DIS.DISCLEF = WEL.WEL_DISCLEF " & VbCrlf
	SQL = SQL & " AND CIU_ORI.VILCLEF(+) = DIS.DISVILLE " & VbCrlf
	SQL = SQL & " AND EST_ORI.ESTESTADO(+) = CIU_ORI.VIL_ESTESTADO " & VbCrlf
	SQL = SQL & " AND WVM_WELCLAVE(+) = WEL.WELCLAVE " & VbCrlf
	SQL = SQL & " AND CIU_WVM.VILCLEF(+) = WVM_VILLE " & VbCrlf
	SQL = SQL & " AND EST_WVM.ESTESTADO(+) = CIU_WVM.VIL_ESTESTADO " & VbCrlf
	SQL = SQL & " AND DIR.DIECLAVE = WEL.WEL_DIECLAVE " & VbCrlf
	SQL = SQL & " AND CIU_DEST.VILCLEF = DIR.DIEVILLE " & VbCrlf
	SQL = SQL & " AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO " & VbCrlf
	SQL = SQL & " AND DXP.DXP_RDECLAVE = RDE.RDECLAVE(+)"  & VbCrlf
	SQL = SQL &  "  AND DXP2.DXPCLAVE =  (   " & VbCrlf
	SQL = SQL &  "      SELECT NVL(MAX(DEX.DXPCLAVE),DXP.DXPCLAVE)"  & VbCrlf
	SQL = SQL &  "      FROM EDET_EXPEDICIONES DEX"  & VbCrlf
	SQL = SQL &  "  	WHERE DEX.DXP_TIPO_ENTREGA = 'DIRECTO'"  & VbCrlf
	SQL = SQL & "					AND DEX.DXP_ID_OP = wel.WEL_ID_OP "  & VbCrlf
	SQL = SQL &  "  	)	"  & VbCrlf
	SQL = SQL &  " AND NDV.NDV_TDCDCLAVE(+) = TDCD.TDCDCLAVE"  & VbCrlf
	SQL = SQL &  "   AND WTLCLAVE = WEL.WEL_WTLCLAVE  " & VbCrlf
	SQL = SQL &  "   AND WEL_ORI.WELCLAVE(+) = WEL.WEL_WELCLAVE  " & VbCrlf
	SQL = SQL &  "   AND TRUNC(WEL.DATE_CREATED) BETWEEN TIVFECINI AND TIVFECFIN " & VbCrlf
	SQL = SQL &  "   AND TIVTASA >= 15 " & VbCrlf
	SQL = SQL & " AND NVL(TIV_PAYSAAIM3, 'MEX') = 'MEX' " & VbCrlf
	
	'Se agrega JOIN para obtener el DOCUMENTO_FUENTE o la FACTURA segun la Configuracion del Cliente:
	if es_doc_fte = true or es_con_fact = true then
		SQL = SQL & VbCrlf & "	AND	WEL.WELCLAVE = FD.NUI(+)	" & VbCrlf
	end if
	
	'mostrar los talones que no tienen entrega (DXPCLAVE IS NULL)
	SQL = SQL &  " union all SELECT /*+USE_nl(WEL DIR EAL_DEST EAL_ORI EST_DEST EST_ORI CIU_DEST CIU_ORI DTFF)*/ WEL.WEL_CLICLEF "  & VbCrlf
	SQL = SQL &  "  , InitCap(CLI.CLINOM) "  & VbCrlf
	
	'Se agrega IF para obtener el DOCUMENTO_FUENTE:
	If es_cross_dock(SQLEscape(Session("array_client")(2,0))) = true then
		SQL = SQL & " , '''' || TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(CLI.CLICLEF) REFERENCIA " & VbCrlf
	elseif es_doc_fte = true then		
	'<<2024-03-08: Se actualiza la forma de obtener la referencia a mostrar en la consulta:
		'SQL = SQL & VbCrlf &  "  , (SELECT LISTAGG(TO_CHAR(DF_FACT.DOCUMENTO_FUENTE), ', ') WITHIN GROUP (ORDER BY DF_FACT.DOCUMENTO_FUENTE DESC) DOCUMENTO_FUENTE FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI) REFERENCIA " & VbCrlf
		SQL = SQL & VbCrlf &  "  , '''' || NVL(NVL((SELECT LISTAGG(TO_CHAR(DF_FACT.DOCUMENTO_FUENTE), ', ') WITHIN GROUP (ORDER BY DF_FACT.DOCUMENTO_FUENTE DESC) DOCUMENTO_FUENTE FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI),WEL.WEL_ORDEN_COMPRA),WEL.WELFACTURA) REFERENCIA " & VbCrlf
	'  2024-03-08>>		
	'Se agrega IF para obtener la FACTURA:
	elseif es_con_fact = true then
		'<<<<< CHG-DESA-06032024: se agrega NVL para que obtenga la Factura de EFACTURAS_DOC y si no la encuentra se obtenga de WEB_LTL:
			'SQL = SQL & VbCrlf &  "  , (SELECT LISTAGG(TO_CHAR(DF_FACT.NO_FACTURA), ', ') WITHIN GROUP (ORDER BY DF_FACT.NO_FACTURA DESC) NO_FACTURA FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI) REFERENCIA " & VbCrlf
			SQL = SQL & VbCrlf &  "  , '''' || NVL((SELECT LISTAGG(TO_CHAR(DF_FACT.NO_FACTURA), ', ') WITHIN GROUP (ORDER BY DF_FACT.NO_FACTURA DESC) NO_FACTURA FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI),WEL.WELFACTURA) REFERENCIA " & VbCrlf
		'       CHG-DESA-06032024 >>>>>
	else
		SQL = SQL &  "  , '''' || TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(CLI.CLICLEF) REFERENCIA " & VbCrlf
	end if
	
	SQL = SQL &  "  , '''' || WEL.WELFACTURA "  & VbCrlf
	SQL = SQL &  "  , WEL.WEL_CDAD_BULTOS "  & VbCrlf
	SQL = SQL &  "  , EAL_ORI.ALLCODIGO " & VbCrlf
	SQL = SQL &  "  , InitCap(EAL_ORI.ALLNOMBRE) " & VbCrlf
	SQL = SQL & " , InitCap(NVL(WVM_NOMBRE, DIS.DISNOM)) " & VbCrlf
	SQL = SQL & " , InitCap(NVL(CIU_WVM.VILNOM, CIU_ORI.VILNOM) || ' ('|| NVL(EST_WVM.ESTNOMBRE, EST_ORI.ESTNOMBRE) || ')') " & VbCrlf
	SQL = SQL &  "  , EAL_DEST.ALLCODIGO "  & VbCrlf
	SQL = SQL &  "  , InitCap(EAL_DEST.ALLNOMBRE) "  & VbCrlf
	SQL = SQL &  "  , InitCap(DIR.DIENOMBRE) " & vbCrLf
	SQL = SQL & " , InitCap(CIU_DEST.VILNOM) " & VbCrlf
	SQL = SQL & " , InitCap(EST_DEST.ESTNOMBRE) " & VbCrlf
	SQL = SQL &  "  , TO_CHAR(NVL(TAE.TAEFECHALLEGADA,TAE.TAE_FECHA_RECOLECCION), 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL &  "  , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL &  "  , TO_CHAR(DXP.DXP_FECHA_ENTREGA, 'DD/MM/YYYY hh24:mi')"  & VbCrlf
	SQL = SQL & " , DECODE(WEL.WELSTATUS, 0, 'rojo', 2, 'naranja', 3, 'naranja', 'verde') " & VbCrlf
	SQL = SQL & " , DECODE(WEL.WELSTATUS, 0, 'Can', 2, 'StdBy', 3, 'Reserv.', 'Act') " & VbCrlf
	SQL = SQL &  "  , WEL.WELCLAVE " & VbCrlf
	SQL = SQL &  "  , WEL.WELRECOL_DOMICILIO " & VbCrlf
	SQL = SQL &  "  , NVL(WEL.WEL_TALON_RASTREO, WEL.WEL_FIRMA) AS WEL_FIRMA " & VbCrlf
	SQL = SQL &  "  , WEL.WEL_MANIF_NUM" & VbCrlf
	SQL = SQL &  "  , WEL.WELVOLUMEN " & VbCrlf
	SQL = SQL &  "  , WEL.WELPESO " & VbCrlf
	SQL = SQL &  "  , WEL.WELIMPORTE " & VbCrlf
	SQL = SQL &  "  , NULL STATUS " & VbCrlf
	SQL = SQL &  "  , NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) " & VbCrlf
	SQL = SQL & " , ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (TIVTASA / 100),2) " & VbCrlf
	SQL = SQL & " , ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (1 + (TIVTASA / 100)),2) " & VbCrlf
	SQL = SQL &  "  , NULL RDECONS_GENERAL" & VbCrlf
	SQL = SQL &  "  , NULL FCTDATEFACTURE  " & VbCrlf
	SQL = SQL &  "  , NULL DDRDATEREVISION  " & VbCrlf
	SQL = SQL &  "  , NULL FCTNUMERO " & VbCrlf
	SQL = SQL &  "  , NULL FOLFOLIO " & VbCrlf
	SQL = SQL &  "  , NULL TDCDCLAVE " & VbCrlf
	SQL = SQL &  "  , NULL FCTCLEF " & VbCrlf
	SQL = SQL & " , InitCap(NVL(WEL.WEL_COLLECT_PREPAID, 'PREPAGADO')) " & VbCrlf
	SQL = SQL & " , DECODE(WEL.WEL_COLLECT_PREPAID, 'POR COBRAR', 'COD', 'Prep') " & VbCrlf
	SQL = SQL & " , CLI.CCL_RFC " & VbCrlf
	SQL = SQL & " , NULL NDV_FECHA_CANCELADO  " & VbCrlf
	SQL = SQL & " , NULL NDVCLAVE " & VbCrlf
	SQL = SQL & " , NULL FCTCLIENT " & VbCrlf
	SQL = SQL & " , NULL TDCD_FCTCLEF " & VbCrlf
	
	'no verificar la cantidad de bultos contra el detalle
	if tarimas_logis then
		SQL = SQL & " , DECODE(SIGN(WEL.WELVOLUMEN), 1, DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), 'MODIF') " & vbCrLf
	else
		SQL = SQL & " , DECODE(WEL.WEL_CDAD_BULTOS, (SELECT SUM(WPL_IDENTICAS) FROM WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), (SELECT SUM(WPL_IDENTICAS) FROM TB_LOGIS_WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), 'MODIF') " & vbCrLf
	end if
	
	SQL = SQL & " , WTLTIPO  " & VbCrlf
	SQL = SQL & " , WTL_ABREV  " & VbCrlf
	SQL = SQL & " , TO_CHAR(WEL_ORI.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL_ORI.WEL_CLICLEF)  " & VbCrlf
	SQL = SQL & " , NVL(WEL_ORI.WEL_TALON_RASTREO, WEL_ORI.WEL_FIRMA) AS WEL_FIRMA_ORI  " & VbCrlf
	SQL = SQL & " , (SELECT 1 FROM ECLIENT_APLICA_CONCEPTOS CCO, EBASES_POR_CONCEPT BPC, ECONCEPTOSHOJA WHERE CCO_CLICLEF = WEL.WEL_CLICLEF AND BPCCLAVE = CCO_BPCCLAVE AND CHOCLAVE = BPC_CHOCLAVE AND CHONUMERO IN (240, 241) AND ROWNUM = 1 )  " & VbCrlf
	SQL = SQL & " , NVL(WEL.WEL_PRECIO_MANUAL, 'N')  " & VbCrlf
	SQL = SQL & " , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL & " , 0 " & VbCrlf
	SQL = SQL & " , DECODE(NVL(TDCD.TDCDSTATUS, 0), 1, DECODE(TRA.TRASTATUS, '1', 1, 0), 0) " & VbCrlf
	SQL = SQL & " , WEL.WELSTATUS " & vbCrLf
	SQL = SQL & " , DIR.DIECLAVE " & vbCrLf
	SQL = SQL & " , WEL.DATE_CREATED " & vbCrLf
	SQL = SQL & " , REPLACE(REPLACE(WEL.WELARCHIVO_CARGA, '.DAT', ''),'.xls','') " & vbCrLf
	
	'====NUMERO DE ETIQUETAS
	SQL = SQL & " , NVL( " & vbCrLf
	SQL = SQL & "    (SELECT COUNT(0) " & vbCrLf
	SQL = SQL & "    FROM ETRANS_ETIQUETAS_BULTOS TEB " & vbCrLf
	SQL = SQL & "    ,EIMPRESION_ETIQUETA_LOG " & vbCrLf
	SQL = SQL & "    WHERE WEL.WELCLAVE=TEB.TEB_WELCLAVE " & vbCrLf
	SQL = SQL & "    AND IEL_TEBCLAVE=TEB.TEBCLAVE " & vbCrLf
	SQL = SQL & "    AND TEB.TEBSTATUS=1 " & vbCrLf
	SQL = SQL & "    AND WEL.WEL_ALLCLAVE_ORI=1 ) " & vbCrLf
	SQL = SQL & "  ,0) IMPRESION_ETIQUETAS " & vbCrLf
	SQL = SQL & "    ,WEL.WEL_WTLCLAVE " & vbCrLf
	SQL = SQL & " ,  WEL.wel_cafrclave " & VbCrlf
	SQL = SQL & " ,  CAFR_PDF " & VbCrlf
	SQL = SQL & " , WEL.wel_validacion_status" & VbCrlf
	SQL = SQL & " , 'WCCLCLAVE' " & VbCrlf
	SQL = SQL & " , WEL.WEL_FIRMA " & VbCrlf
	'<2024-07-31
	SQL = SQL & " , TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF)	TALON_FACTURA " & VbCrlf
	' 2024-07-31>
	SQL = SQL &  "   FROM WEB_LTL WEL " & VbCrlf
	SQL = SQL &  "   , ECLIENT CLI " & VbCrlf
	SQL = SQL &  "   , ETRANSFERENCIA_TRADING TRA " & VbCrlf
	SQL = SQL &  "   , ETRANS_ENTRADA TAE " & VbCrlf
	SQL = SQL &  "   , EALMACENES_LOGIS EAL_ORI " & VbCrlf
	SQL = SQL &  "   , EALMACENES_LOGIS EAL_DEST " & VbCrlf
	SQL = SQL &  "   , EDISTRIBUTEUR DIS " & VbCrlf
	SQL = SQL &  "   , ECIUDADES CIU_ORI " & VbCrlf
	SQL = SQL &  "   , EESTADOS EST_ORI " & VbCrlf
	SQL = SQL & "    , WEB_LTL_VENTA_MOSTRADOR WVM " & VbCrlf
	SQL = SQL & "    , ECIUDADES CIU_WVM " & VbCrlf
	SQL = SQL & "    , EESTADOS EST_WVM " & VbCrlf
	SQL = SQL &  "   , EDIRECCIONES_ENTREGA DIR " & VbCrlf
	SQL = SQL &  "   , ECLIENT_CLIENTE CLI " & VbCrlf
	SQL = SQL &  "   , ECIUDADES CIU_DEST " & VbCrlf
	SQL = SQL &  "   , EESTADOS EST_DEST " & VbCrlf
	SQL = SQL &  "   , ETRANS_DETALLE_CROSS_DOCK TDCD" & VbCrlf
	SQL = SQL &  "   , EDET_EXPEDICIONES DXP" & VbCrlf
	SQL = SQL &  "   , WTIPO_LTL " & VbCrlf
	SQL = SQL &  "   , WEB_LTL WEL_ORI " & VbCrlf
	SQL = SQL &  "   , ETASAS_IVA " & VbCrlf 
	
	'== FUERA DE RUTA
	SQL = SQL &  "   , ECLIENT_AUTORIZA_FUERA_RUTA " & VbCrlf
	
	
	
	'Se agrega TABLA para obtener el DOCUMENTO_FUENTE o la FACTURA segun la Configuracion del Cliente:
	if es_doc_fte = true or es_con_fact = true then
		SQL = SQL & VbCrlf & "	,EFACTURAS_DOC FD	" & VbCrlf
	elseif Request.Form("Criterio_1") = "doc_fuente" then
		SQL = SQL & tbl_doc_fte
	end if
	
	SQL = SQL &  " WHERE CLI.CLICLEF = WEL.WEL_CLICLEF " & VbCrlf
	SQL = SQL &  "   AND TRA.TRACLAVE(+) = WEL.WEL_TRACLAVE " & VbCrlf
	SQL = SQL &  "   AND TDCD.TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE" & VbCrlf
	SQL = SQL &  "   AND TAE.TAE_TRACLAVE(+) = TRA.TRACLAVE " & VbCrlf
	SQL = SQL &  "   AND TRA.TRASTATUS(+) = '1' " & VbCrlf
	SQL = SQL &  "   AND TDCD.TDCDSTATUS(+) = '1' " & VbCrlf
	SQL = SQL &  "   and DXP.DXP_TRACLAVE(+) = WEL.WEL_TRACLAVE " & VbCrlf
	SQL = SQL &  "   and DXP.DXP_TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE" & VbCrlf
	SQL = SQL & "  AND WEL.WEL_DIECLAVE IS NOT NULL " & VbCrlf
	
	'== FUERA DE RUTA
	SQL = SQL & " AND wel.WEL_CAFRCLAVE = CAFRCLAVE(+) "  & VbCrlf
	
	'<<<<<< se insertan los fitros necesarios
		if Request.Form("Criterio_1") = "doc_fuente_new" then '--pclp--
			SQL = SQL & filtro_doc_fte2 
			SQL = SQL &	filtro_doc_fte
		end if
		if Request.Form("Criterio_1") = "rango_nuis" then '--pclp--
			SQL = SQL & join_doc_fte_ltl
			SQL = SQL & filtro_doc_fte
		end if
		if Request.Form("Criterio_1") = "rango_factura" then '--pclp---
			SQL = SQL & join_doc_fte_ltl
			SQL = SQL & filtro_doc_fte
		end if
	'>>>>>>>>>>>>>>
	
	if UBound(Split(FolSelect, ",")) > 1000 then
		SQL = SQL & "   AND (WEL.WELCLAVE IN ( "
		
		for i = 0 to UBound(Split(FolSelect, ","))
			SQL = SQL & Split(FolSelect, ",")(i)
			
			if i mod 999 = 0 and i <> 0 then
				SQL = SQL & "   ) "
				
				if i <> UBound(Split(FolSelect, ",")) then
					SQL = SQL & " OR WEL.WELCLAVE IN ("
				end if
			elseif i <> UBound(Split(FolSelect, ",")) then
				SQL = SQL & ","
			end if
			
			if i mod 100 = 0 then
				SQL = SQL & vbCrLf
			end if
		next
		
		SQL = SQL & "  )) "
	else
		SQL = SQL & "    AND WEL.WELCLAVE IN ("& FolSelect &") " & VbCrlf
	end if
	
	SQL = SQL &  "   and dxp.DXPCLAVE is null " & VbCrlf
	SQL = SQL &  "   AND dxp.DXP_FECHA_ENTREGA IS NULL" & VbCrlf
	SQL = SQL &  "   AND EAL_ORI.ALLCLAVE = WEl.WEL_ALLCLAVE_ORI " & VbCrlf
	SQL = SQL &  "   AND EAL_DEST.ALLCLAVE = WEl.WEL_ALLCLAVE_DEST " & VbCrlf
	SQL = SQL &  "   AND DIS.DISCLEF = WEL.WEL_DISCLEF " & VbCrlf
	SQL = SQL &  "   AND CIU_ORI.VILCLEF(+) = DIS.DISVILLE " & VbCrlf
	SQL = SQL &  "   AND EST_ORI.ESTESTADO(+) = CIU_ORI.VIL_ESTESTADO " & VbCrlf
	SQL = SQL & "    AND WVM_WELCLAVE(+) = WEL.WELCLAVE " & VbCrlf
	SQL = SQL & "    AND CIU_WVM.VILCLEF(+) = WVM_VILLE " & VbCrlf
	SQL = SQL & "    AND EST_WVM.ESTESTADO(+) = CIU_WVM.VIL_ESTESTADO " & VbCrlf
	SQL = SQL &  "   AND DIR.DIECLAVE = WEL.WEL_DIECLAVE " & VbCrlf
	SQL = SQL &  "   AND CIU_DEST.VILCLEF = DIR.DIEVILLE " & VbCrlf
	SQL = SQL &  "   AND CLI.CCLCLAVE = DIR.DIE_CCLCLAVE " & VbCrlf
	SQL = SQL &  "   AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO " & VbCrlf
	SQL = SQL &  "   AND WTLCLAVE = WEL.WEL_WTLCLAVE  " & VbCrlf
	SQL = SQL &  "   AND WEL_ORI.WELCLAVE(+) = WEL.WEL_WELCLAVE  " & VbCrlf
	SQL = SQL &  "   AND TRUNC(WEL.DATE_CREATED) BETWEEN TIVFECINI AND TIVFECFIN " & VbCrlf
	SQL = SQL &  "   AND TIVTASA >= 15 " & VbCrlf
	SQL = SQL & " AND NVL(TIV_PAYSAAIM3, 'MEX') = 'MEX' " & VbCrlf
	
	'Se agrega JOIN para obtener el DOCUMENTO_FUENTE o la FACTURA segun la Configuracion del Cliente:
	if es_doc_fte = true or es_con_fact = true then
		SQL = SQL & VbCrlf & "	AND	WEL.WELCLAVE = FD.NUI(+)	" & VbCrlf
	end if
	
	SQL = SQL & " UNION " & VbCrlf
	SQL = SQL &  "SELECT /*+ORDERED USE_nl(WEL WCCL EAL_DEST EAL_ORI EST_DEST EST_ORI CIU_DEST CIU_ORI DTFF FCT dxp2)*/ DISTINCT WEL.WEL_CLICLEF " & VbCrlf
	SQL = SQL & " , InitCap(CLI.CLINOM) " & VbCrlf
	
	'Se agrega IF para obtener el DOCUMENTO_FUENTE:
	If es_cross_dock(SQLEscape(Session("array_client")(2,0))) = true then
		SQL = SQL & " , '''' || TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(CLI.CLICLEF) REFERENCIA " & VbCrlf
	elseif es_doc_fte = true then
	'<<2024-03-08: Se actualiza la forma de obtener la referencia a mostrar en la consulta:
		'SQL = SQL & VbCrlf &  "  , (SELECT LISTAGG(TO_CHAR(DF_FACT.DOCUMENTO_FUENTE), ', ') WITHIN GROUP (ORDER BY DF_FACT.DOCUMENTO_FUENTE DESC) DOCUMENTO_FUENTE FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI) REFERENCIA " & VbCrlf
		SQL = SQL & VbCrlf &  "  , '''' || NVL(NVL((SELECT LISTAGG(TO_CHAR(DF_FACT.DOCUMENTO_FUENTE), ', ') WITHIN GROUP (ORDER BY DF_FACT.DOCUMENTO_FUENTE DESC) DOCUMENTO_FUENTE FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI),WEL.WEL_ORDEN_COMPRA),WEL.WELFACTURA) REFERENCIA " & VbCrlf
	'  2024-03-08>>	
	'Se agrega IF para obtener la FACTURA:
	elseif es_con_fact = true then
		'<<<<< CHG-DESA-06032024: se agrega NVL para que obtenga la Factura de EFACTURAS_DOC y si no la encuentra se obtenga de WEB_LTL:
			'SQL = SQL & VbCrlf &  "  , (SELECT LISTAGG(TO_CHAR(DF_FACT.NO_FACTURA), ', ') WITHIN GROUP (ORDER BY DF_FACT.NO_FACTURA DESC) NO_FACTURA FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI) REFERENCIA " & VbCrlf
			SQL = SQL & VbCrlf &  "  , '''' || NVL((SELECT LISTAGG(TO_CHAR(DF_FACT.NO_FACTURA), ', ') WITHIN GROUP (ORDER BY DF_FACT.NO_FACTURA DESC) NO_FACTURA FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI),WEL.WELFACTURA) REFERENCIA " & VbCrlf
		'       CHG-DESA-06032024 >>>>>
	else
		SQL = SQL & " , '''' || TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(CLI.CLICLEF) REFERENCIA " & VbCrlf
	end if
	
	SQL = SQL & " , '''' || WEL.WELFACTURA " & VbCrlf
	SQL = SQL & " , WEL.WEL_CDAD_BULTOS " & VbCrlf
	SQL = SQL & " , EAL_ORI.ALLCODIGO " & VbCrlf
	SQL = SQL & " , InitCap(EAL_ORI.ALLNOMBRE) " & VbCrlf
	SQL = SQL & " , InitCap(NVL(WVM_NOMBRE, DIS.DISNOM)) " & VbCrlf
	SQL = SQL & " , InitCap(NVL(CIU_WVM.VILNOM, CIU_ORI.VILNOM) || ' ('|| NVL(EST_WVM.ESTNOMBRE, EST_ORI.ESTNOMBRE) || ')') " & VbCrlf
	SQL = SQL & " , EAL_DEST.ALLCODIGO " & VbCrlf
	SQL = SQL & " , InitCap(EAL_DEST.ALLNOMBRE) " & VbCrlf
	SQL = SQL & " , InitCap(WCCL.WCCL_NOMBRE) " & VbCrlf
	SQL = SQL & " , InitCap(CIU_DEST.VILNOM) " & VbCrlf
	SQL = SQL & " , InitCap(EST_DEST.ESTNOMBRE) " & VbCrlf
	SQL = SQL & " , TO_CHAR(NVL(TAE.TAEFECHALLEGADA,TAE.TAE_FECHA_RECOLECCION), 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL & " , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL & " , NVL(TO_CHAR(DXP2.DXP_FECHA_ENTREGA, 'DD/MM/YYYY hh24:mi'),TO_CHAR(DXP.DXP_FECHA_ENTREGA, 'DD/MM/YYYY hh24:mi'))"  & VbCrlf
	SQL = SQL & " , DECODE(WEL.WELSTATUS, 0, 'rojo', 2, 'naranja', 3, 'naranja', 'verde') " & VbCrlf
	SQL = SQL & " , DECODE(WEL.WELSTATUS, 0, 'Can', 2, 'StdBy', 3, 'Reserv.', 'Act') " & VbCrlf
	SQL = SQL & " , WEL.WELCLAVE " & VbCrlf
	SQL = SQL & " , WEL.WELRECOL_DOMICILIO " & VbCrlf
	SQL = SQL & " , NVL(WEL.WEL_TALON_RASTREO, WEL.WEL_FIRMA) AS WEL_FIRMA " & VbCrlf
	SQL = SQL & " , WEL.WEL_MANIF_NUM" & VbCrlf
	SQL = SQL & " , WEL.WELVOLUMEN " & VbCrlf
	SQL = SQL & " , WEL.WELPESO " & VbCrlf
	SQL = SQL & " , WEL.WELIMPORTE " & VbCrlf
	SQL = SQL & " , NULL STATUS " & VbCrlf
	SQL = SQL & " , NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) " & VbCrlf
	SQL = SQL & " , ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (TIVTASA / 100),2) " & VbCrlf
	SQL = SQL & " , ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (1 + (TIVTASA / 100)),2) " & VbCrlf
	SQL = SQL & " , RDE.RDECONS_GENERAL" & VbCrlf
	SQL = SQL & " , NULL " & VbCrlf
	SQL = SQL & " , NULL " & VbCrlf
	SQL = SQL & " , NULL FCTNUMERO --FAC.FCTNUMERO  " & VbCrlf
	SQL = SQL & "  , NULL  FOLFOLIO  --FAC.FOLFOLIO " & VbCrlf
	SQL = SQL & "  , WEL.WEL_TDCDCLAVE TDCDCLAVE --FAC.TDCDCLAVE" & VbCrlf
	SQL = SQL & "  , NULL FCTCLEF --FAC.FCTCLEF " & VbCrlf
	SQL = SQL & " , InitCap(NVL(WEL.WEL_COLLECT_PREPAID, 'PREPAGADO')) " & VbCrlf
	SQL = SQL & " , DECODE(WEL.WEL_COLLECT_PREPAID, 'POR COBRAR', 'COD', 'Prep') " & VbCrlf
	SQL = SQL & " , WCCL.WCCL_RFC " & VbCrlf
	SQL = SQL & " , DECODE(NDV.NDV_FECHA_CANCELADO, NULL, 'N', 'S') " & VbCrlf
	SQL = SQL & " , NDV.NDVCLAVE " & VbCrlf
	SQL = SQL & " , NULL FCTCLIENT --FAC.FCTCLIENT " & VbCrlf
	SQL = SQL & " , NULL TDCD_FCTCLEF --FAC.TDCD_FCTCLEF " & VbCrlf
	
	'no verificar la cantidad de bultos contra el detalle
	if tarimas_logis then
		SQL = SQL & " , DECODE(SIGN(WEL.WELVOLUMEN), 1, DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), 'MODIF') " & vbCrLf
	else
		SQL = SQL & " , DECODE(WEL.WEL_CDAD_BULTOS, (SELECT SUM(WPL_IDENTICAS) FROM WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), (SELECT SUM(WPL_IDENTICAS) FROM TB_LOGIS_WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), 'MODIF') " & vbCrLf
	end if
	
	SQL = SQL & " , WTLTIPO  " & VbCrlf
	SQL = SQL & " , WTL_ABREV  " & VbCrlf
	SQL = SQL & " , TO_CHAR(WEL_ORI.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL_ORI.WEL_CLICLEF)  " & VbCrlf
	SQL = SQL & " , NVL(WEL_ORI.WEL_TALON_RASTREO, WEL_ORI.WEL_FIRMA) AS WEL_FIRMA_ORI  " & VbCrlf
	SQL = SQL & " , (SELECT 1 FROM ECLIENT_APLICA_CONCEPTOS CCO, EBASES_POR_CONCEPT BPC, ECONCEPTOSHOJA WHERE CCO_CLICLEF = WEL.WEL_CLICLEF AND BPCCLAVE = CCO_BPCCLAVE AND CHOCLAVE = BPC_CHOCLAVE AND CHONUMERO IN (240, 241) AND ROWNUM = 1 )  " & VbCrlf
	SQL = SQL & " , NVL(WEL.WEL_PRECIO_MANUAL, 'N')  " & VbCrlf
	SQL = SQL & " , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL & " ,  (SELECT /*+INDEX(WAS IDX_WAS_TDCDCLAVE)*/ COUNT(0)  " & VbCrlf
	SQL = SQL & "  FROM ETRANS_DETALLE_CROSS_DOCK TDCD, WEB_ARCHIVOS_ESCANEADOS WAS " & VbCrlf
	SQL = SQL & "  WHERE TDCDFACTURA = TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) " & VbCrlf
	SQL = SQL & "    AND WAS_TDCDCLAVE = TDCDCLAVE " & VbCrlf
	SQL = SQL & "    AND WAS_UPLOAD_WEB IS NOT NULL " & VbCrlf
	SQL = SQL & "  )  " & VbCrlf
	SQL = SQL & " , DECODE(NVL(TDCD.TDCDSTATUS, 0), 1, DECODE(TRA.TRASTATUS, '1', 1, 0), 0) " & VbCrlf
	SQL = SQL & " , WEL.WELSTATUS " & vbCrLf
	SQL = SQL & " , WCCL.WCCLCLAVE " & vbCrLf
	SQL = SQL & " , WEL.DATE_CREATED " & vbCrLf
	SQL = SQL & " , REPLACE(REPLACE(WEL.WELARCHIVO_CARGA, '.DAT', ''), '.xls', '') " & vbCrLf
	
	'====NUMERO DE ETIQUETAS
	SQL = SQL & " , NVL( " & vbCrLf
	SQL = SQL & "    (SELECT COUNT(0) " & vbCrLf
	SQL = SQL & "    FROM ETRANS_ETIQUETAS_BULTOS TEB " & vbCrLf
	SQL = SQL & "    ,EIMPRESION_ETIQUETA_LOG " & vbCrLf
	SQL = SQL & "    WHERE WEL.WELCLAVE=TEB.TEB_WELCLAVE " & vbCrLf
	SQL = SQL & "    AND IEL_TEBCLAVE=TEB.TEBCLAVE " & vbCrLf
	SQL = SQL & "    AND TEB.TEBSTATUS=1 " & vbCrLf
	SQL = SQL & "    AND WEL.WEL_ALLCLAVE_ORI=1 ) " & vbCrLf
	SQL = SQL & "  ,0) IMPRESION_ETIQUETAS " & vbCrLf
	SQL = SQL & "    ,WEL.WEL_WTLCLAVE " & vbCrLf
	SQL = SQL & " ,  WEL.wel_cafrclave " & VbCrlf
	SQL = SQL & " , CAFR_PDF " & VbCrlf
	SQL = SQL & " , WEL.wel_validacion_status" & VbCrlf
	SQL = SQL & " , 'DIECLAVE' " & VbCrlf
	SQL = SQL & " , WEL.WEL_FIRMA " & VbCrlf
	'<2024-07-31
	SQL = SQL & " , TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF)	TALON_FACTURA " & VbCrlf
	' 2024-07-31>
	SQL = SQL & " FROM WEB_LTL WEL " & VbCrlf
	SQL = SQL & " , ECLIENT CLI " & VbCrlf
	SQL = SQL & " , ETRANSFERENCIA_TRADING TRA " & VbCrlf
	SQL = SQL & " , ETRANS_ENTRADA TAE " & VbCrlf
	SQL = SQL & " , EALMACENES_LOGIS EAL_ORI " & VbCrlf
	SQL = SQL & " , EALMACENES_LOGIS EAL_DEST " & VbCrlf
	SQL = SQL & " , EDISTRIBUTEUR DIS " & VbCrlf
	SQL = SQL & " , ECIUDADES CIU_ORI " & VbCrlf
	SQL = SQL & " , EESTADOS EST_ORI " & VbCrlf
	SQL = SQL & " , WEB_LTL_VENTA_MOSTRADOR WVM " & VbCrlf
	SQL = SQL & " , ECIUDADES CIU_WVM " & VbCrlf
	SQL = SQL & " , EESTADOS EST_WVM " & VbCrlf
	SQL = SQL & " , WEB_CLIENT_CLIENTE WCCL " & VbCrlf
	SQL = SQL & " , ECIUDADES CIU_DEST " & VbCrlf
	SQL = SQL & " , EESTADOS EST_DEST " & VbCrlf
	SQL = SQL & " , ETRANS_DETALLE_CROSS_DOCK TDCD" & VbCrlf
	SQL = SQL & " , EDET_EXPEDICIONES DXP" & VbCrlf
	SQL = SQL & " , EDET_EXPEDICIONES DXP2" & VbCrlf
	SQL = SQL & " , ERELACION_DE_EVIDENCIAS RDE" & VbCrlf
	SQL = SQL & " , ENOTA_DE_VENTA NDV " & VbCrlf
	SQL = SQL &  "   , WTIPO_LTL " & VbCrlf
	SQL = SQL &  "   , WEB_LTL WEL_ORI " & VbCrlf
	SQL = SQL &  "   , ETASAS_IVA " & VbCrlf
	
	' == FUERA DE RUTA
	SQL = SQL &  "   , ECLIENT_AUTORIZA_FUERA_RUTA " & VbCrlf
	
	
	
	'Se agrega TABLA para obtener el DOCUMENTO_FUENTE o la FACTURA segun la Configuracion del Cliente:
	if es_doc_fte = true or es_con_fact = true then
		SQL = SQL & VbCrlf & "	,EFACTURAS_DOC FD	" & VbCrlf
	elseif Request.Form("Criterio_1") = "doc_fuente" then
		SQL = SQL & tbl_doc_fte
	end if
	
	SQL = SQL & " WHERE CLI.CLICLEF = WEL.WEL_CLICLEF " & VbCrlf
	SQL = SQL & " AND TRA.TRACLAVE = WEL.WEL_TRACLAVE " & VbCrlf
	SQL = SQL & " AND tdcd.tdcdCLAVE = WEL.WEL_TDCDCLAVE " & VbCrlf
	SQL = SQL & " AND TAE.TAE_TRACLAVE = TRA.TRACLAVE " & VbCrlf
	SQL = SQL & " AND TRA.TRASTATUS = '1' " & VbCrlf
	SQL = SQL & " AND TDCD.TDCDSTATUS = '1' " & VbCrlf
	SQL = SQL & " AND WEL.WEL_TRACLAVE  = DXP.dxp_traclave(+) " & VbCrlf
	SQL = SQL & " AND WEL.WEL_TDCDCLAVE = DXP.dxp_tdcdclave(+) " & VbCrlf
	SQL = SQL & "  AND WEL.WEL_WCCLCLAVE IS NOT NULL " & VbCrlf
	SQL = SQL & " AND WEL.WEL_CAFRCLAVE = CAFRCLAVE(+) " & VbCrlf
	' <<<<<<< se insertan los filtros necesarios
		if Request.Form("Criterio_1") = "doc_fuente_new" then '--pclp--
			SQL = SQL & filtro_doc_fte2 
			SQL = SQL &	filtro_doc_fte
		end if
		if Request.Form("Criterio_1") = "rango_nuis" then '--pclp--
			SQL = SQL & join_doc_fte_ltl
			SQL = SQL & filtro_doc_fte
		end if
			if Request.Form("Criterio_1") = "rango_factura" then '--pclp---
			SQL = SQL & join_doc_fte_ltl
			SQL = SQL & filtro_doc_fte
		end if
	'>>>>>>>>>>
	if UBound(Split(FolSelect, ",")) > 1000 then
		SQL = SQL & "   AND (WEL.WELCLAVE IN ( "
		
		for i = 0 to UBound(Split(FolSelect, ","))
			SQL = SQL & Split(FolSelect, ",")(i)
			
			if i mod 999 = 0 and i <> 0 then
				SQL = SQL & "   ) "
				
				if i <> UBound(Split(FolSelect, ",")) then
					SQL = SQL & " OR WEL.WELCLAVE IN ("
				end if
			elseif i <> UBound(Split(FolSelect, ",")) then
				SQL = SQL & ","
			end if
			
			if i mod 100 = 0 then
				SQL = SQL & vbCrLf
			end if
		next
		
		SQL = SQL & "  )) " & VbCrlf
	else
		SQL = SQL & " AND WEL.WELCLAVE IN ("& FolSelect &") " & VbCrlf
	end if
	
	SQL = SQL & " AND EAL_ORI.ALLCLAVE = WEl.WEL_ALLCLAVE_ORI " & VbCrlf
	SQL = SQL & " AND EAL_DEST.ALLCLAVE = WEl.WEL_ALLCLAVE_DEST " & VbCrlf
	SQL = SQL & " AND DIS.DISCLEF = WEL.WEL_DISCLEF " & VbCrlf
	SQL = SQL & " AND CIU_ORI.VILCLEF(+) = DIS.DISVILLE " & VbCrlf
	SQL = SQL & " AND EST_ORI.ESTESTADO(+) = CIU_ORI.VIL_ESTESTADO " & VbCrlf
	SQL = SQL & " AND WVM_WELCLAVE(+) = WEL.WELCLAVE " & VbCrlf
	SQL = SQL & " AND CIU_WVM.VILCLEF(+) = WVM_VILLE " & VbCrlf
	SQL = SQL & " AND EST_WVM.ESTESTADO(+) = CIU_WVM.VIL_ESTESTADO " & VbCrlf
	SQL = SQL & " AND WCCL.WCCLCLAVE = WEL.WEL_WCCLCLAVE " & VbCrlf
	SQL = SQL & " AND WEL.WEL_DIECLAVE IS NULL" & VbCrlf
	SQL = SQL & " AND CIU_DEST.VILCLEF = WCCL.WCCL_VILLE " & VbCrlf
	SQL = SQL & " AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO " & VbCrlf
	SQL = SQL & " AND DXP.DXP_RDECLAVE = RDE.RDECLAVE(+)"  & VbCrlf
	SQL = SQL &  "  AND DXP2.DXPCLAVE =  (   " & VbCrlf
	SQL = SQL &  "      SELECT NVL(MAX(DEX.DXPCLAVE),DXP.DXPCLAVE)"  & VbCrlf
	SQL = SQL &  "      FROM EDET_EXPEDICIONES DEX"  & VbCrlf
	SQL = SQL &  "  	WHERE DEX.DXP_TIPO_ENTREGA = 'DIRECTO'"  & VbCrlf
	SQL = SQL & "					AND DEX.DXP_ID_OP = wel.WEL_ID_OP "  & VbCrlf
	SQL = SQL &  "  	)	"  & VbCrlf
	SQL = SQL &  " AND NDV.NDV_TDCDCLAVE(+) = TDCD.TDCDCLAVE"  & VbCrlf
	SQL = SQL &  "   AND WTLCLAVE = WEL.WEL_WTLCLAVE  " & VbCrlf
	SQL = SQL &  "   AND WEL_ORI.WELCLAVE(+) = WEL.WEL_WELCLAVE  " & VbCrlf
	SQL = SQL &  "   AND TRUNC(WEL.DATE_CREATED) BETWEEN TIVFECINI AND TIVFECFIN " & VbCrlf
	SQL = SQL &  "   AND TIVTASA >= 15 " & VbCrlf
	SQL = SQL & " AND NVL(TIV_PAYSAAIM3, 'MEX') = 'MEX' " & VbCrlf
	
	'Se agrega JOIN para obtener el DOCUMENTO_FUENTE o la FACTURA segun la Configuracion del Cliente:
	if es_doc_fte = true or es_con_fact = true then
		SQL = SQL & VbCrlf & "	AND	WEL.WELCLAVE = FD.NUI(+)	" & VbCrlf
	end if
	
	'mostrar los talones que no tienen entrega (DXPCLAVE IS NULL)
	SQL = SQL &  " union all SELECT /*+USE_nl(WEL WCCL EAL_DEST EAL_ORI EST_DEST EST_ORI CIU_DEST CIU_ORI DTFF)*/ WEL.WEL_CLICLEF "  & VbCrlf
	SQL = SQL &  "  , InitCap(CLI.CLINOM) "  & VbCrlf
	
	
	
	'Se agrega IF para obtener el DOCUMENTO_FUENTE:
	
	If es_cross_dock(SQLEscape(Session("array_client")(2,0))) = true then
		SQL = SQL & " , '''' || TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(CLI.CLICLEF) REFERENCIA " & VbCrlf
	elseif es_doc_fte = true then
		'SQL = SQL & VbCrlf &  "  , FD.DOCUMENTO_FUENTE " & VbCrlf
		'<<2024-03-08: Se actualiza la forma de obtener la referencia a mostrar en la consulta:
			'SQL = SQL & VbCrlf &  "  , (SELECT LISTAGG(TO_CHAR(DF_FACT.DOCUMENTO_FUENTE), ', ') WITHIN GROUP (ORDER BY DF_FACT.DOCUMENTO_FUENTE DESC) DOCUMENTO_FUENTE FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI) REFERENCIA " & VbCrlf
			SQL = SQL & VbCrlf &  "  , '''' || NVL(NVL((SELECT LISTAGG(TO_CHAR(DF_FACT.DOCUMENTO_FUENTE), ', ') WITHIN GROUP (ORDER BY DF_FACT.DOCUMENTO_FUENTE DESC) DOCUMENTO_FUENTE FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI),WEL.WEL_ORDEN_COMPRA),WEL.WELFACTURA) REFERENCIA " & VbCrlf
		'  2024-03-08>>
		'Se agrega IF para obtener la FACTURA:
		elseif es_con_fact = true then
		'<<< CHG-DESA-13052024 se agrega NVL para que obtenga la Factura de EFACTURAS_DOC y si no la encuentra se obtenga de WEB_LTL: 
		 'SQL = SQL & VbCrlf &  "  , (SELECT LISTAGG(TO_CHAR(DF_FACT.DOCUMENTO_FUENTE), ', ') WITHIN GROUP (ORDER BY DF_FACT.DOCUMENTO_FUENTE DESC) DOCUMENTO_FUENTE FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI) REFERENCIA " & VbCrlf
		SQL = SQL & VbCrlf &  "  , '''' || NVL((SELECT LISTAGG(TO_CHAR(DF_FACT.NO_FACTURA), ', ') WITHIN GROUP (ORDER BY DF_FACT.NO_FACTURA DESC) NO_FACTURA FROM EFACTURAS_DOC DF_FACT WHERE DF_FACT.NUI = FD.NUI),WEL.WELFACTURA) REFERENCIA " & VbCrlf
		' CHG-DESA-13052024 >>>
	else
		SQL = SQL &  "  , '''' || TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(CLI.CLICLEF) REFERENCIA " & VbCrlf
	end if
	
	SQL = SQL &  "  , '''' || WEL.WELFACTURA "  & VbCrlf
	SQL = SQL &  "  , WEL.WEL_CDAD_BULTOS "  & VbCrlf
	SQL = SQL &  "  , EAL_ORI.ALLCODIGO " & VbCrlf
	SQL = SQL &  "  , InitCap(EAL_ORI.ALLNOMBRE) " & VbCrlf
	SQL = SQL & " , InitCap(NVL(WVM_NOMBRE, DIS.DISNOM)) " & VbCrlf
	SQL = SQL & " , InitCap(NVL(CIU_WVM.VILNOM, CIU_ORI.VILNOM) || ' ('|| NVL(EST_WVM.ESTNOMBRE, EST_ORI.ESTNOMBRE) || ')') " & VbCrlf
	SQL = SQL &  "  , EAL_DEST.ALLCODIGO "  & VbCrlf
	SQL = SQL &  "  , InitCap(EAL_DEST.ALLNOMBRE) "  & VbCrlf
	SQL = SQL &  "  , InitCap(WCCL.WCCL_NOMBRE) " & vbCrLf
	SQL = SQL & " , InitCap(CIU_DEST.VILNOM) " & VbCrlf
	SQL = SQL & " , InitCap(EST_DEST.ESTNOMBRE) " & VbCrlf
	SQL = SQL &  "  , TO_CHAR(NVL(TAE.TAEFECHALLEGADA,TAE.TAE_FECHA_RECOLECCION), 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL &  "  , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL &  "  , TO_CHAR(DXP.DXP_FECHA_ENTREGA, 'DD/MM/YYYY hh24:mi')"  & VbCrlf
	SQL = SQL & " , DECODE(WEL.WELSTATUS, 0, 'rojo', 2, 'naranja', 3, 'naranja', 'verde') " & VbCrlf
	SQL = SQL & " , DECODE(WEL.WELSTATUS, 0, 'Can', 2, 'StdBy', 3, 'Reserv.', 'Act') " & VbCrlf
	SQL = SQL &  "  , WEL.WELCLAVE " & VbCrlf
	SQL = SQL &  "  , WEL.WELRECOL_DOMICILIO " & VbCrlf
	SQL = SQL &  "  , NVL(WEL.WEL_TALON_RASTREO, WEL.WEL_FIRMA) AS WEL_FIRMA " & VbCrlf
	SQL = SQL &  "  , WEL.WEL_MANIF_NUM" & VbCrlf
	SQL = SQL &  "  , WEL.WELVOLUMEN " & VbCrlf
	SQL = SQL &  "  , WEL.WELPESO " & VbCrlf
	SQL = SQL &  "  , WEL.WELIMPORTE " & VbCrlf
	SQL = SQL &  "  , NULL STATUS " & VbCrlf
	SQL = SQL &  "  , NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) " & VbCrlf
	SQL = SQL & " , ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (TIVTASA / 100),2) " & VbCrlf
	SQL = SQL & " , ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (1 + (TIVTASA / 100)),2) " & VbCrlf
	SQL = SQL &  "  , NULL RDECONS_GENERAL" & VbCrlf
	SQL = SQL &  "  , NULL FCTDATEFACTURE  " & VbCrlf
	SQL = SQL &  "  , NULL DDRDATEREVISION  " & VbCrlf
	SQL = SQL &  "  , NULL FCTNUMERO " & VbCrlf
	SQL = SQL &  "  , NULL FOLFOLIO " & VbCrlf
	SQL = SQL &  "  , NULL TDCDCLAVE " & VbCrlf
	SQL = SQL &  "  , NULL FCTCLEF " & VbCrlf
	SQL = SQL & " , InitCap(NVL(WEL.WEL_COLLECT_PREPAID, 'PREPAGADO')) " & VbCrlf
	SQL = SQL & " , DECODE(WEL.WEL_COLLECT_PREPAID, 'POR COBRAR', 'COD', 'Prep') " & VbCrlf
	SQL = SQL & " , WCCL.WCCL_RFC " & VbCrlf
	SQL = SQL & " , NULL NDV_FECHA_CANCELADO  " & VbCrlf
	SQL = SQL & " , NULL NDVCLAVE " & VbCrlf
	SQL = SQL & " , NULL FCTCLIENT " & VbCrlf
	SQL = SQL & " , NULL TDCD_FCTCLEF " & VbCrlf
	
	'no verificar la cantidad de bultos contra el detalle
	if tarimas_logis then
		SQL = SQL & " , DECODE(SIGN(WEL.WELVOLUMEN), 1, DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), 'MODIF') " & vbCrLf
	else
		SQL = SQL & " , DECODE(WEL.WEL_CDAD_BULTOS, (SELECT SUM(WPL_IDENTICAS) FROM WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), (SELECT SUM(WPL_IDENTICAS) FROM TB_LOGIS_WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WEL.WELFACTURA, '_PENDIENTE_', 'MODIF', DECODE(WEL.WELOBSERVACION, '_PENDIENTE_', 'MODIF', 'PRINT')), 'MODIF') " & vbCrLf
	end if    
	
	SQL = SQL & " , WTLTIPO  " & VbCrlf
	SQL = SQL & " , WTL_ABREV  " & VbCrlf
	SQL = SQL & " , TO_CHAR(WEL_ORI.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL_ORI.WEL_CLICLEF)  " & VbCrlf
	SQL = SQL & " , NVL(WEL_ORI.WEL_TALON_RASTREO, WEL_ORI.WEL_FIRMA) AS WEL_FIRMA_ORI  " & VbCrlf
	SQL = SQL & " , (SELECT 1 FROM ECLIENT_APLICA_CONCEPTOS CCO, EBASES_POR_CONCEPT BPC, ECONCEPTOSHOJA WHERE CCO_CLICLEF = WEL.WEL_CLICLEF AND BPCCLAVE = CCO_BPCCLAVE AND CHOCLAVE = BPC_CHOCLAVE AND CHONUMERO IN (240, 241) AND ROWNUM = 1 )  " & VbCrlf
	SQL = SQL & " , NVL(WEL.WEL_PRECIO_MANUAL, 'N')  " & VbCrlf
	SQL = SQL & " , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY hh24:mi') " & VbCrlf
	SQL = SQL & " , 0 "  & VbCrlf
	SQL = SQL & " , DECODE(NVL(TDCD.TDCDSTATUS, 0), 1, DECODE(TRA.TRASTATUS, '1', 1, 0), 0) " & VbCrlf
	SQL = SQL & " , WEL.WELSTATUS " & vbCrLf
	SQL = SQL & " , WCCL.WCCLCLAVE " & vbCrLf
	SQL = SQL & " , WEL.DATE_CREATED " & vbCrLf
	SQL = SQL & " , REPLACE(REPLACE(WEL.WELARCHIVO_CARGA, '.DAT', ''),'.xls','') " & vbCrLf
	
	'====NUMERO DE ETIQUETAS
	SQL = SQL & " , NVL( " & vbCrLf
	SQL = SQL & "    (SELECT COUNT(0) " & vbCrLf
	SQL = SQL & "    FROM ETRANS_ETIQUETAS_BULTOS TEB " & vbCrLf
	SQL = SQL & "    ,EIMPRESION_ETIQUETA_LOG " & vbCrLf
	SQL = SQL & "    WHERE WEL.WELCLAVE=TEB.TEB_WELCLAVE " & vbCrLf
	SQL = SQL & "    AND IEL_TEBCLAVE=TEB.TEBCLAVE " & vbCrLf
	SQL = SQL & "    AND TEB.TEBSTATUS=1 " & vbCrLf
	SQL = SQL & "    AND WEL.WEL_ALLCLAVE_ORI=1 ) " & vbCrLf
	SQL = SQL & "  ,0) IMPRESION_ETIQUETAS " & vbCrLf
	SQL = SQL & "    ,WEL.WEL_WTLCLAVE " & vbCrLf
	SQL = SQL & " ,  WEL.wel_cafrclave " & VbCrlf
	SQL = SQL & " ,  CAFR_PDF " & VbCrlf
	SQL = SQL & " , WEL.wel_validacion_status" & VbCrlf
	SQL = SQL & " , 'DIECLAVE' " & VbCrlf
	SQL = SQL & " , WEL.WEL_FIRMA " & VbCrlf
	'<2024-07-31
	SQL = SQL & " , TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF)	TALON_FACTURA " & VbCrlf
	' 2024-07-31>
	SQL = SQL &  "   FROM WEB_LTL WEL " & VbCrlf
	SQL = SQL &  "   , ECLIENT CLI " & VbCrlf
	SQL = SQL &  "   , ETRANSFERENCIA_TRADING TRA " & VbCrlf
	SQL = SQL &  "   , ETRANS_ENTRADA TAE " & VbCrlf
	SQL = SQL &  "   , EALMACENES_LOGIS EAL_ORI " & VbCrlf
	SQL = SQL &  "   , EALMACENES_LOGIS EAL_DEST " & VbCrlf
	SQL = SQL &  "   , EDISTRIBUTEUR DIS " & VbCrlf
	SQL = SQL &  "   , ECIUDADES CIU_ORI " & VbCrlf
	SQL = SQL &  "   , EESTADOS EST_ORI " & VbCrlf
	SQL = SQL & "    , WEB_LTL_VENTA_MOSTRADOR WVM " & VbCrlf
	SQL = SQL & "    , ECIUDADES CIU_WVM " & VbCrlf
	SQL = SQL & "    , EESTADOS EST_WVM " & VbCrlf
	SQL = SQL &  "   , WEB_CLIENT_CLIENTE WCCL " & VbCrlf
	SQL = SQL &  "   , ECIUDADES CIU_DEST " & VbCrlf
	SQL = SQL &  "   , EESTADOS EST_DEST " & VbCrlf
	SQL = SQL &  "   , ETRANS_DETALLE_CROSS_DOCK TDCD" & VbCrlf
	SQL = SQL &  "   , EDET_EXPEDICIONES DXP" & VbCrlf
	SQL = SQL &  "   , WTIPO_LTL " & VbCrlf
	SQL = SQL &  "   , WEB_LTL WEL_ORI " & VbCrlf
	SQL = SQL &  "   , ETASAS_IVA " & VbCrlf
	
	' == FUERA DE RUTA'
	SQL = SQL &  "   , ECLIENT_AUTORIZA_FUERA_RUTA " & VbCrlf
	
	
	
	'Se agrega TABLA para obtener el DOCUMENTO_FUENTE o la FACTURA segun la Configuracion del Cliente:
	if es_doc_fte = true or es_con_fact = true then
		SQL = SQL & VbCrlf & "	,EFACTURAS_DOC FD	" & VbCrlf
	elseif Request.Form("Criterio_1") = "doc_fuente" then
		SQL = SQL & tbl_doc_fte
	end if
	
	SQL = SQL &  " WHERE CLI.CLICLEF = WEL.WEL_CLICLEF " & VbCrlf
	SQL = SQL &  "   AND TRA.TRACLAVE(+) = WEL.WEL_TRACLAVE " & VbCrlf
	SQL = SQL &  "   AND TDCD.TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE" & VbCrlf
	SQL = SQL &  "   AND TAE.TAE_TRACLAVE(+) = TRA.TRACLAVE " & VbCrlf
	SQL = SQL &  "   AND TRA.TRASTATUS(+) = '1' " & VbCrlf
	SQL = SQL &  "   AND TDCD.TDCDSTATUS(+) = '1' " & VbCrlf
	SQL = SQL &  "   and DXP.DXP_TRACLAVE(+) = WEL.WEL_TRACLAVE " & VbCrlf
	SQL = SQL &  "   and DXP.DXP_TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE" & VbCrlf
	SQL = SQL & "  AND WEL.WEL_WCCLCLAVE IS NOT NULL " & VbCrlf
	
	' == FUERA DE RUTA:
	SQL = SQL & " AND wel.WEL_CAFRCLAVE = CAFRCLAVE(+) "  & VbCrlf
	
	' <<<<<<<<<< se insertan los filtros necesarios
		if Request.Form("Criterio_1") = "doc_fuente_new" then '--pclp--
			SQL = SQL & filtro_doc_fte2 
			SQL = SQL &	filtro_doc_fte
		end if

		if Request.Form("Criterio_1") = "rango_nuis" then '--pclp--
			SQL = SQL & join_doc_fte_ltl
			SQL = SQL & filtro_doc_fte
		end if
		if Request.Form("Criterio_1") = "rango_factura" then '--pclp---
			SQL = SQL & join_doc_fte_ltl
			SQL = SQL & filtro_doc_fte
		end if
	'>>>>>>>>>>>
	
	if UBound(Split(FolSelect, ",")) > 1000 then
		SQL = SQL & "   AND (WEL.WELCLAVE IN ( " & VbCrlf
		for i = 0 to UBound(Split(FolSelect, ","))
			SQL = SQL & Split(FolSelect, ",")(i)
			
			if i mod 999 = 0 and i <> 0 then
				SQL = SQL & "   ) "
				if i <> UBound(Split(FolSelect, ",")) then
					SQL = SQL & " OR WEL.WELCLAVE IN ("
				end if
			elseif i <> UBound(Split(FolSelect, ",")) then
				SQL = SQL & ","
			end if
			
			if i mod 100 = 0 then
				SQL = SQL & vbCrLf
			end if
		next
		
		SQL = SQL & "  )) " & VbCrlf
	else
		SQL = SQL & "    AND WEL.WELCLAVE IN ("& FolSelect &") " & VbCrlf
	end if
	
	SQL = SQL &  "   and dxp.DXPCLAVE is null " & VbCrlf
	SQL = SQL &  "   AND dxp.DXP_FECHA_ENTREGA IS NULL" & VbCrlf
	SQL = SQL &  "   AND EAL_ORI.ALLCLAVE = WEl.WEL_ALLCLAVE_ORI " & VbCrlf
	SQL = SQL &  "   AND EAL_DEST.ALLCLAVE = WEl.WEL_ALLCLAVE_DEST " & VbCrlf
	SQL = SQL &  "   AND DIS.DISCLEF = WEL.WEL_DISCLEF " & VbCrlf
	SQL = SQL &  "   AND CIU_ORI.VILCLEF(+) = DIS.DISVILLE " & VbCrlf
	SQL = SQL &  "   AND EST_ORI.ESTESTADO(+) = CIU_ORI.VIL_ESTESTADO " & VbCrlf
	SQL = SQL & "    AND WVM_WELCLAVE(+) = WEL.WELCLAVE " & VbCrlf
	SQL = SQL & "    AND CIU_WVM.VILCLEF(+) = WVM_VILLE " & VbCrlf
	SQL = SQL & "    AND EST_WVM.ESTESTADO(+) = CIU_WVM.VIL_ESTESTADO " & VbCrlf
	SQL = SQL &  "   AND WCCL.WCCLCLAVE = WEL.WEL_WCCLCLAVE " & VbCrlf
	SQL = SQL & "  AND WEL.WEL_DIECLAVE IS NULL " & VbCrlf
	SQL = SQL &  "   AND CIU_DEST.VILCLEF = WCCL.WCCL_VILLE " & VbCrlf
	SQL = SQL &  "   AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO " & VbCrlf
	SQL = SQL &  "   AND WTLCLAVE = WEL.WEL_WTLCLAVE  " & VbCrlf
	SQL = SQL &  "   AND WEL_ORI.WELCLAVE(+) = WEL.WEL_WELCLAVE  " & VbCrlf
	SQL = SQL &  "   AND TRUNC(WEL.DATE_CREATED) BETWEEN TIVFECINI AND TIVFECFIN " & VbCrlf
	SQL = SQL &  "   AND TIVTASA >= 15 " & VbCrlf
	SQL = SQL & " AND NVL(TIV_PAYSAAIM3, 'MEX') = 'MEX' " & VbCrlf
	
	'Se agrega JOIN para obtener el DOCUMENTO_FUENTE o la FACTURA segun la Configuracion del Cliente:
	if es_doc_fte = true or es_con_fact = true then
		SQL = SQL & VbCrlf & "	AND	WEL.WELCLAVE = FD.NUI(+)	" & VbCrlf
	end if
	
	SQL = SQL & " ORDER BY 57 DESC" & VbCrlf
	Session("SQL") = SQL
	response.write "<div id='dvQuery' style='visibility:collapse;display:none;'>" & Replace(SQL,vbCrLf,"<br>") & "</div>"
	'response.end
	arrayLTL = GetArrayRS(SQL)
	
	if IsArray(arrayLTL) then
		es_doc_fte = es_captura_con_doc_fuente(arrayLTL(0,0))
		es_con_fact = es_captura_con_factura(num_client)
	else
		es_doc_fte = es_captura_con_doc_fuente(num_client)
		es_con_fact = es_captura_con_factura(num_client)
	end if
	
	if isArray(arrayLTL) then
		For iRowwel = 0 to UBound(arrayLTL,2)
			if arrayLTL(35,iRowwel)<>"" then
				SQL_factur = "			SELECT FCTDATEFACTURE  " & VbCrlf
				SQL_factur = SQL_factur & "	 , DDRDATEREVISION  " & VbCrlf
				SQL_factur = SQL_factur & "	 , FCTNUMERO " & VbCrlf
				SQL_factur = SQL_factur & "	 , FOLFOLIO " & VbCrlf
				SQL_factur = SQL_factur & "	 , FCTCLEF " & VbCrlf
				SQL_factur = SQL_factur & "	 , FCTCLIENT " & VbCrlf
				SQL_factur = SQL_factur & "	 , FCTCLEF TDCD_FCTCLEF " & VbCrlf
				SQL_factur = SQL_factur & "   FROM EDET_TRAD_FACTURA_CLIENTE_FACT DTFF   " & VbCrlf
				SQL_factur = SQL_factur & "	 , EDET_TRAD_FACTURA_CLIENTE DTFC   " & VbCrlf
				SQL_factur = SQL_factur & "	 , ETRAD_FACTURA_CLIENTE TFC  " & VbCrlf
				SQL_factur = SQL_factur & "	 , EFOLIOS FOL  " & VbCrlf
				SQL_factur = SQL_factur & "	 , EFACTURAS FCT  " & VbCrlf
				SQL_factur = SQL_factur & "	 , EDETAILDOCREV DDR " & VbCrlf
				SQL_factur = SQL_factur & "	 , ECONCEPTOSHOJA  " & VbCrlf
				SQL_factur = SQL_factur & "	 WHERE DTFF.DTFF_TDCDCLAVE = " & arrayLTL(35,iRowwel) & VbCrlf
				SQL_factur = SQL_factur & "	 AND DTFC.DTFCCLAVE = DTFF.DTFF_DTFCCLAVE  " & VbCrlf
				SQL_factur = SQL_factur & "	 AND TFC.TFCCLAVE = DTFC.DTFC_TFCCLAVE  " & VbCrlf
				SQL_factur = SQL_factur & "	 AND FOL.FOLCLAVE = TFC.TFC_FOLCLAVE  " & VbCrlf
				SQL_factur = SQL_factur & "	 AND FCT.FCTFOLIO = TFC.TFC_FOLCLAVE              " & VbCrlf
				SQL_factur = SQL_factur & "	 AND FCT_YFACLEF  = '1'  " & VbCrlf
				SQL_factur = SQL_factur & "	 AND DDR.DDRDOCUMENT(+) = FCT.FCTCLEF  " & VbCrlf
				SQL_factur = SQL_factur & "	 AND CHOCLAVE = DTFC.DTFC_CHOCLAVE      " & VbCrlf
				SQL_factur = SQL_factur & "	 AND CHONUMERO = 172     " & VbCrlf
				SQL_factur = SQL_factur & "   UNION  " & VbCrlf
				SQL_factur = SQL_factur & "   SELECT FCTDATEFACTURE  " & VbCrlf
				SQL_factur = SQL_factur & "	 , DDRDATEREVISION " & VbCrlf
				SQL_factur = SQL_factur & "	 , FCTNUMERO " & VbCrlf
				SQL_factur = SQL_factur & "	 , FOLFOLIO " & VbCrlf
				SQL_factur = SQL_factur & "	 , FCTCLEF " & VbCrlf
				SQL_factur = SQL_factur & "	 , FCTCLIENT " & VbCrlf
				SQL_factur = SQL_factur & "	 , TDCD_FCTCLEF  " & VbCrlf
				SQL_factur = SQL_factur & "   FROM ETRANS_DETALLE_CROSS_DOCK " & VbCrlf
				SQL_factur = SQL_factur & "	 , EFACTURAS FCT  " & VbCrlf
				SQL_factur = SQL_factur & "	 , EDETAILDOCREV DDR " & VbCrlf
				SQL_factur = SQL_factur & "	 , EFOLIOS FOL  " & VbCrlf
				SQL_factur = SQL_factur & "	 WHERE TDCDCLAVE = " & arrayLTL(35,iRowwel) &   VbCrlf
				SQL_factur = SQL_factur & "	 AND FCTCLEF = TDCD_FCTCLEF  " & VbCrlf
				SQL_factur = SQL_factur & "	 AND FCT_YFACLEF = '1'  " & VbCrlf
				SQL_factur = SQL_factur & "	 AND FOL.FOLCLAVE = FCT.FCTFOLIO  " & VbCrlf
				SQL_factur = SQL_factur & "	 AND DDR.DDRDOCUMENT(+) = FCT.FCTCLEF " & VbCrlf
				SQL_factur = SQL_factur & "	 AND EXISTS (  " & VbCrlf
				SQL_factur = SQL_factur & "	   SELECT NULL  " & VbCrlf
				SQL_factur = SQL_factur & "	   FROM EDETAILFACTURE  " & VbCrlf
				SQL_factur = SQL_factur & "		 , ECONCEPTOSHOJA  " & VbCrlf
				SQL_factur = SQL_factur & "	   WHERE DTFFACTURE = FCTCLEF  " & VbCrlf
				SQL_factur = SQL_factur & "		 AND CHOCLAVE = DTF_CHOCLAVE    " & VbCrlf
				SQL_factur = SQL_factur & "		 AND CHONUMERO = 172 ) " & VbCrlf
				
				Session("SQL") = SQL_factur
				array_factur = GetArrayRS(SQL_factur)
				
				if isArray(array_factur) then
					arrayLTL(34,iRowwel)=array_factur(3,iRowfactur)
					arrayLTL(36,iRowwel)=array_factur(4,iRowfactur)
					arrayLTL(42,iRowwel)=array_factur(5,iRowfactur)
					arrayLTL(43,iRowwel)=array_factur(6,iRowfactur)
				end if
			end if
		next
	end if
%>
<style type="text/css">
	img
	{
		behavior:	url("include/js/pngbehavior.htc");
	}
</style>
<script language="javascript">
	//<!--
		function quitar_manifiesto(welclave)
		{
			document.quitar_manifiesto.welclave.value = welclave;
			if (confirm(' Esta seguro de eliminar el talon del manifiesto ?') == true)
			{
				document.quitar_manifiesto.submit();
			}
		}
		function desactivar_ltl(welclave, welstatus)
		{
			document.desactivar_ltl.welclave.value = welclave;
			document.desactivar_ltl.welstatus.value = welstatus;
			if (welstatus == 0)
			{
				if (confirm(' Esta seguro de desactivar esta LTL ?') == true)
				{
					document.desactivar_ltl.submit();
				}
			}
			else
			{
				if (confirm(' Esta seguro de reactivar esta LTL ?') == true)
				{
					document.desactivar_ltl.submit();
				}
			}
		}
		function borrar_tarifa_ltl(welclave)
		{
			document.desactivar_ltl.welclave.value = welclave;
			document.desactivar_ltl.etapa.value = 3;
			if (confirm(' Esta seguro de borar la tarifa de esta LTL ?') == true)
			{
				document.desactivar_ltl.submit();
			}
		}
		function _Get(id)
		{
			return document.getElementById(id);
		}
		function display_fecha()
		{
			if (_Get("recoleccion_domicilio").checked)
			{
				_Get("fecha_div").className = 'visible td';
			}
			else
			{
				_Get("fecha_div").className = 'escondido';
			}
		}
		function validarManifesto()
		{
			var i=0;
			var LTLselected = false;
			
			//verificamos que a lo menos 1 LTL sea selccionada
			dml=document.forms["ltl_form"];
			len = document.forms["ltl_form"].elements.length;
			
			for( i=0 ; i<len ; i++)
			{
				if (dml.elements[i].name== 'check_welclave')
				{
					if (dml.elements[i].checked)
					{
						LTLselected = true;
					}
				}
			}
			if (!LTLselected)
			{
				alert('Seleccionar a lo menos una LTL.');
			}
			else
			{
				_Get("ltl_form").submit();
			}
		}
	//-->
</script>
<form name="quitar_manifiesto" id="quitar_manifiesto"  action="ltl_captura.asp" method="post">
	<input type="hidden" name="etapa" value="5" />
	<input type="hidden" name="welclave" value="" />
	<input type="hidden" name="welstatus" value="" />
	<input type="hidden" name="noMenu" value="<%=Request("noMenu")%>" />
	<input type="hidden" name="loginId" value="<%=Request("loginId")%>" />
</form>
<form name="desactivar_ltl" id="desactivar_ltl" action="ltl_captura.asp" method="post">
	<input type="hidden" name="etapa" value="2" />
	<input type="hidden" name="welclave" value="" />
	<input type="hidden" name="welstatus" value="0" />
	<input type="hidden" name="noMenu" value="<%=Request("noMenu")%>" />
	<input type="hidden" name="loginId" value="<%=Request("loginId")%>" />
</form>
<table class="datos" width="100%">
	<tr>
		<input type="hidden" id="ltl_destinatarios_3_ok" name="ltl_destinatarios_3_ok" value="55747"/>
		<input type="hidden" id="ltl_ciudad_3_ok" name="ltl_ciudad_3_ok" disabled="" value=""/>
		<input type="hidden" id="ltl_estado_3_ok" name="ltl_estado_3_ok" disabled="" value=""/>
		<%
			if Request.Form("etapa") <> "1" then
				reporte = "ltl_consulta-dl.asp?tipo=1" & noMenu & loginId
				
				'para ver el download por correo, debemos de tener los siguientes criterios
				'(en caso de llegar desde criterios multiples):
				'	- tipo de fecha (criterio_1) = fecha_entrega o fecha_creacion
				'	- no hay segundo criterio seleccionado
				'	Si tipo=1 entonces es la consulta normal de talon, entonces ponemos 30 dias
				
				if Request.QueryString("tipo") = "1" then
					SQL = "SELECT TO_CHAR(SYSDATE-29, 'DD/MM/YYYY'),  TO_CHAR(SYSDATE, 'dd/mm/YYYY') FROM DUAL "
					Session("SQL") = SQL
					arrayTemp = GetArrayRS(SQL)
					reporte = "ltl_consulta-dl2.asp?tipo=1" & noMenu & loginId & "&entry_num=" & arrayTemp(0, 0) & "&entry_to=" & arrayTemp(1, 0) & "&fromWeb=1"
				end if
				
				if (Request("criterio_1") = "fecha_creacion" or Request("criterio_1") = "fecha_entrega") _
					and (Request("ltl_destinatarios_3_ok") = "" and Request("ltl_ciudad_3_ok") = "" and Request("ltl_estado_3_ok") = "") then
					reporte = "ltl_consulta-dl2.asp?tipo=1" & noMenu & loginId & "&entry_num=" & Request("entry_num") & "&entry_to=" & Request("entry_to")
				end if
				%>
					<td align="right">
						<a href="<%=reporte%>">
							<img src="./images/document-save.png" style="width:22px; height:22px; border:none; vertical-align:middle;" alt="Download" />
						</a>
						<a href="<%=reporte%>">
							Download
						</a>
						<br/>
						<a href="ltl_consulta-dl.asp?detalle=1<%=noMenu%><%=loginId%>">
							Detalle bultos
						</a>
						<br/>
						<img src="./images/blank.gif" height="15px" />
						<a href="ltl_consulta-dl.asp?tipo=txt<%=noMenu%><%=loginId%>">
							<img src="./images/notepad.gif" style="border:none; vertical-align:middle;" alt="Download txt" />
						</a>
						<a href="ltl_consulta-dl.asp?tipo=txt<%=noMenu%><%=loginId%>">
							Download txt
						</a>
					</td>
				<%
			end if
		%>
	</tr>
</table>
<%
	if Request.QueryString("msg") <> "" then
		%>
			<div class="messages error">
				<%=Request.QueryString("msg")%>
			</div>
		<%
	end if
	if Request.QueryString("msg_ok") <> "" then
		%>
			<div class="message message-success">
				<%=Request.QueryString("msg_ok")%>
			</div>
		<%
	end if

	call print_saldo_monedero

	if Session("array_client")(2,0) = "9903" then
		%>
			<center>
				<div style="font-size:20px; color:red; font-weight: bold;">
					Ya no se deben documentar talones en la cuenta 9903, favor de utilizar el cliente 9929.
				</div>
			</center>
		<%
	end if
	
	if Request.Form("manif_num") <>"" then
		%>
			<center>
				<font color="red">
					Detalle del Manifiesto: <b><%=Request.Form("manif_num")%></b>
				</font>
			</center>
		<%
	end if
%>
<script language="javascript">
	function select_fct_clef(xFactura)
	{
		document.fct_clef.xFactura.value = xFactura;
		document.fct_clef.submit();
	}
</script>
<form name="fct_clef" action="invoice-det.asp" method="post">
	<input type="hidden" name="xFactura" value="" />
	<input type="hidden" name="xTipo" value="1" />
</form>
<script language="javascript">
	function select_tdcd_clave(tdcd)
	{
		document.tdcd_clave.tdcd.value = tdcd;
		document.tdcd_clave.submit();
	}
</script>
<form name="tdcd_clave" action="ltl_invoice-det-dl.asp" method="post">
	<input type="hidden" name="tdcd" value="" />
</form>
<script language="javascript">
	function modif_talon(welclave)
	{
		document.modif_talon.welclave.value = welclave;
		document.modif_talon.submit();
	}
</script>
<form name="modif_talon" action="ltl_captura_enc_modif.asp" method="post">
	<input type="hidden" name="welclave" value="" />
</form>
<script language="javascript">
	function modif_peso_talon(welclave)
	{
		document.modif_peso_talon.welclave.value = welclave;
		document.modif_peso_talon.submit();
	}
</script>
<form name="modif_peso_talon" action="ltl_captura_concepto.asp" method="post">
	<input type="hidden" name="welclave" value="" />
</form>
<%
	if Request.Form("etapa")= "1" then
		'creacion de manifiesto, buscamos si existe una carga por archivos.
		SQL = "SELECT DISTINCT REPLACE(REPLACE(WELARCHIVO_CARGA, '.DAT', ''),'.xls','') "
		'poner la fecha por rango de 5mn para no tener duplicados en caso que un archivo se tarde mas de un minuto en cargarse
		SQL = SQL & "   , TO_CHAR(DATE_CREATED, 'DD/MM/YYYY HH24:') || TRUNC(TO_CHAR(DATE_CREATED, 'MI') / 5) * 5 "
		SQL = SQL & " FROM WEB_LTL WEL " & vbCrLf
		
		if UBound(Split(FolSelect, ",")) > 1000 then
			SQL = SQL & "   WHERE (WEL.WELCLAVE IN ( "
			
			for i = 0 to UBound(Split(FolSelect, ","))
				SQL = SQL & Split(FolSelect, ",")(i)
				
				if i mod 999 = 0 and i <> 0 then
					SQL = SQL & "   ) "
					
					if i <> UBound(Split(FolSelect, ",")) then
						SQL = SQL & " OR WEL.WELCLAVE IN ("
					elseif i <> UBound(Split(FolSelect, ",")) then
						SQL = SQL & ","
					end if
				end if
				
				if i mod 100 = 0 then
					SQL = SQL & vbCrLf
				end if
			next
			SQL = SQL & "  )) " & vbCrLf
		else
			SQL = SQL & "   WHERE WEL.WELCLAVE IN ("& FolSelect &") " & VbCrlf
		end if
		
		SQL = SQL & " AND WELARCHIVO_CARGA IS NOT NULL " & VbCrlf
		SQL = SQL & " ORDER BY 1 " & vbCrLf
		
		Session("SQL") = SQL
		arrayTemp = GetArrayRS(SQL)
		
		if IsArray(arrayTemp) then
			Response.Write "<table border='0' valign='top'>" & vbCrLf
			Response.Write "<tr><td colspan='2'>Seleccionar un archivo de carga:</td></tr>" & vbCrLf
			Response.Write "<tr valign='top'><td>"
			Response.Write "<input type='checkbox' class='archivo_carga' value=''>Sin archivo de carga<br>" & vbCrLf
			
			for i = 0 to UBound(arrayTemp, 2)
				Response.Write "<input type='checkbox' class='archivo_carga' value='"& arrayTemp(0, i) &"'>"& arrayTemp(0, i) &" - "& arrayTemp(1, i) &"<br>" & vbCrLf
				
				if i = UBound(arrayTemp, 2) \ 2 then
					Response.Write "</td><td>"
				end if
			next
			
			Response.Write "</td></tr></table><br>" & vbCrLf
			%>
				<script language="javascript">
					$(document).ready(function()
					{
						$('.archivo_carga').change(function()
						{
							$('.archivo_carga').each(function(index, elt)
							{
								if ($(this).is(':checked'))
								{
									//mostrar las lineas del archivo de carga y palomearlas
									$('table.datos tbody tr.c' + $(this).val()).show();
									$('table.datos tbody tr.c' + $(this).val() + ' input[type=checkbox]').attr('checked', 'checked');
								}
								else
								{
									//si no esconderlas
									$('table.datos tbody tr.c' + $(this).val()).hide();
									$('table.datos tbody tr.c' + $(this).val() + ' input[type=checkbox]').removeAttr('checked');
								}
							});
						});
					});
				</script>
			<%
		end if
	end if
%>
<form id="ltl_form" name="ltl_form" action="<%=asp_self%>" method="post">
	<table class="datos" id="ltl_datos" align="center" BORDER="1" cellpadding="2" cellspacing="0" width="1480">
		<thead>
			<tr class="titulo_trading_bold" valign="center" align="center">
				<%
					if Request.Form("etapa") = "1" then
						%>
							<td>Anexar </td>
						<%
					end if
				%>
				<td title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n">NUI</td>
				<!-- Se elimina columna a solicitud de O.D. 26/12/2023
					<td>Tipo</td>
				-->
				<td>
					<%
					If es_cross_dock(SQLEscape(Session("array_client")(2,0))) = true then
					%>
							Talon
					<%
					elseif es_doc_fte = true then
						%>
							Documento Fuente
						<%
					elseif es_con_fact = true then
						%>
							Factura
						<%
					else
						%>
							Talon
						<%
					end if
				%>
				</td>
				<td>Status</td>
				<td>Acciones</td>
				<td>Referencia</td>
				<td>Manifiesto</td>
				<td>Cdad Bultos</td>
				<td>CEDIS Origen</td>
				<td>Remitente</td>
				<td>Ciudad (estado)</td>
				<td>Destinatario</td>
				<td>Ciudad (estado)</td>
				<td>Recol.<br>Domicilio</td>
				<td>Importe<br>LTL</td>
				<td>Tipo</td>
				<td>Fecha<br>Recoleccion</td>
				<td>Fecha<br>Transf. Logis</td>
				<td>Fecha<br>Entrega</td>
				<td>N&deg;<br>Autorizacion</td>
				<td>Status</td>
			</tr>
		</thead>
		<tbody>
			<%
				if isArray(arrayLTL) then
					For iRowLoop = 0 to UBound(arrayLTL,2)
						arrStatus = obtieneStatusTalon(arrayLTL(21,iRowLoop))
						%>
							<tr align=center class="c<%=arrayLTL(57, iRowLoop)%>">
								<%
									if Request.Form("etapa") = "1" then
										%>
											<td class="td_Check">
												<input type="checkbox" name="check_welclave" value="<%=arrayLTL(19,iRowLoop)%>" />
											</td>
										<%
									end if
								%>
								<td class="td_NUI">
									<%=arrayLTL(19,iRowLoop)%>
								</td>
								<td class="td_NoTalon">
									<label name="lblNoTalon" onClick="location.href='ltl_tracking.asp?track_num=<%=arrayLTL(64,iRowLoop)%><%=noMenu%><%=loginId%>'">
										<a href="ltl_tracking.asp?track_num=<%=arrayLTL(64,iRowLoop)%><%=noMenu%><%=loginId%>" onmouseover="return overlib('Seguimiento de la carga.');" onmouseout="return nd();">
											<!--
											<%=filtre_col(Mid(arrayLTL(2,iRowLoop), 2),110,"")%>
											-->
											<%
												If es_doc_fte = true Then
													Response.Write filtre_col(Mid(arrayLTL(2,iRowLoop), 2),110,"")
												Else
													If esNUIrecoleccion(arrayLTL(19,iRowLoop)) Then
														Response.Write arrayLTL(65,iRowLoop)
													Else
														Response.Write filtre_col(Mid(arrayLTL(2,iRowLoop), 2),110,"")
													End If
												End If
											%>
											<!-- 2024-07-31 -->
										</a>
									</label>
									<%
										if NVL(arrayLTL(48,iRowLoop)) <> "" then
											%>
												<br/>Talon Ori:
												<a href="ltl_tracking.asp?track_num=<%=arrayLTL(48,iRowLoop)%>" onmouseover="return overlib('Seguimiento del LTL');" onmouseout="return nd();">
													<%=arrayLTL(47,iRowLoop)%>
												</a>
											<%
										end if
									%>
								</td>
								<%
									response.Write arrStatus(2)
								%>
								<%
									
								%>
								<td class="td_Acciones">
									<%
										impresionTalon = ""
										impresionTalon = "<a href=""ltl_print_talon.asp?id=" & arrayLTL(19,iRowLoop) & "&update=" & Server.URLEncode (NVL(arrayLTL(29,iRowLoop))) & noMenu & loginId & """ style='text-decoration:none;'><img src=""./images/document-print.png"" style=""border:none;cursor:pointer; width: 16px; height: 16px;"" onmouseover=""return overlib('Imprimir el talon de LTL');"" onmouseout=""return nd();""></a>"
										if arrayLTL(0,iRowLoop) = "4435" or arrayLTL(0,iRowLoop) = "7824" or arrayLTL(0,iRowLoop) = "13073" or arrayLTL(0,iRowLoop) ="17012"  or arrayLTL(0,iRowLoop) ="18262" or arrayLTL(0,iRowLoop) ="17503" or arrayLTL(0,iRowLoop) ="19824" or arrayLTL(0,iRowLoop) ="19811" or arrayLTL(0,iRowLoop) ="19814" then
											impresionTalon = impresionTalon & "&nbsp;&nbsp;&nbsp;" & "<a href='/cgi/rwcgi60.exe/run?db_logis+OPER6304_conformidad_helvex.rdf+welclave="& arrayLTL(19,iRowLoop) &"+destype=cache+desformat=pdf' style='text-decoration:none;'>" & _
															"<img src='./images/edit-paste.png' style='border:none;cursor:pointer; width: 16px; height: 16px;' onmouseover=""return overlib('Imprimir acta de conformidad');"" onmouseout=""return nd();""></a>"
										end if
										
										if arrayLTL(54,iRowLoop) <> "3" then
											'si es reservado, no desplegar nada
											if arrayLTL(44,iRowLoop) = "PRINT" then
												Response.Write impresionTalon
											else
												%>
													<a href="javascript:modif_talon(<%=arrayLTL(19,iRowLoop)%>)" style="text-decoration:none;">
														<img src="./images/accessories-text-editor.png" style="border:none; cursor:pointer; width: 16px; height: 16px" onmouseover="return overlib('Actualizar el talon.');" onmouseout="return nd();" />
													</a>
												<%
											end if
											
											'recuperar la opcion de cancelar los talones
											SQL = "SELECT COUNT(0)  " & VbCrlf
											SQL = SQL & " FROM ECLIENT_MODALIDADES " & VbCrlf
											SQL = SQL & " WHERE CLM_CLICLEF IN ("& print_clinum &")" & VbCrlf
											SQL = SQL & " AND CLM_MOECLAVE = 20	 "
											
											Session("SQL") = SQL
											ArrayEvidencias  = GetArrayRS(SQL)
											
											if CInt(ArrayEvidencias(0,0)) > 0 then
												if (arrayLTL(18,iRowLoop) = "Act" or arrayLTL(18,iRowLoop) = "StdBy") and arrayLTL(53,iRowLoop) = "0" then
													if mostrarBotonCancelar = true then
														%> 
															&nbsp;&nbsp;
															<a href="javascript:desactivar_ltl(<%=arrayLTL(19,iRowLoop)%>, 0);"  style="text-decoration:none;">
																<img src="./images/edit-delete.png" style="border:none; cursor:pointer; width: 16px; height: 16px;" onmouseover="return overlib('Cancelar la LTL');" onmouseout="return nd();" alt="Cancelar LTL" />
															</a>
														<%
													end if
												end if
												
												if Session("internal_login")= 2 and (arrayLTL(18,iRowLoop) = "Can" or arrayLTL(18,iRowLoop) = "StdBy") then
													%>
														&nbsp;&nbsp;
														<a href="javascript:desactivar_ltl(<%=arrayLTL(19,iRowLoop)%>, 1);"  style="text-decoration:none;">
															<img src="./images/tick.png" style="border:none; cursor:pointer; width: 12px; height: 12px;" onmouseover="return overlib('Reactivar la LTL');" onmouseout="return nd();" alt="Reactivar LTL" />
														</a>
													<%
												end if
											end if
											<!-- <<< CHG-DESA-130502024 se comenta la condicion para mostrar las etiquetas ahora se muestra a todos-->
											'if  (arrayLTL(58,iRowLoop)="0" ) or (arrayLTL(58,iRowLoop)<>"0" AND Session("reimpresion_etiquetas")="S") then  	'BLOQUEAR REIMPRESION DE ETIQUETAS
											'	if arrayLTL(16,iRowLoop) <> "" Then
													%>
														<!-- <input type="hidden" /> -->
													<%
											'	Else
													%>
														&nbsp;&nbsp;
														<a href="<%=asp_self()%>?etiquetas=1&id=<%=arrayLTL(19,iRowLoop)%><%=noMenu%><%=loginId%>"  style="text-decoration:none;">
															<img src="./images/label.gif" style="border:none; cursor:pointer;" onmouseover="return overlib('Imprimir las etiquetas.');" onmouseout="return nd();" alt="Imprimir etiquetas" />
														</a>
													<%
											'	End If
											'end if 'FIN BLOQUEAR REIMPRESION DE ETIQUETAS
											<!-- CHG-DESA-130502024 >>> -->
											if Session("internal_login")= 2 and NVL(arrayLTL(36,iRowLoop)) = "" then   'No tiene factura
												%>
													&nbsp;&nbsp;
													<a href="javascript:borrar_tarifa_ltl(<%=arrayLTL(19,iRowLoop)%>);" style="text-decoration:none;">
														<img src="./images/emblem-important.png" style="border:none; cursor:pointer; width: 16px; height: 16px;" onmouseover="return overlib('Borrar la tarifa');" onmouseout="return nd();" alt="Borrar la tarifa" />
													</a>
												<%
											end if
											if arrayLTL(45,iRowLoop) <> "PAQUETERIA" and ((arrayLTL(45,iRowLoop) = "MENSAJERIA" and NVL(arrayLTL(34,iRowLoop)) = "") or (Session("internal_login")= 2 and NVL(arrayLTL(34,iRowLoop)) = ""  and NVL(arrayLTL(50,iRowLoop)) = "N")) and NVL(arrayLTL(49,iRowLoop)) = "1" then
												%>
													&nbsp;&nbsp;
													<a href="javascript:modif_peso_talon(<%=arrayLTL(19,iRowLoop)%>);" style="text-decoration:none;">
														<img src="./images/list-add-16x16.png" style="border:none; cursor:pointer; width: 16px; height: 16px;" 
															<%
																if arrayLTL(45,iRowLoop) <> "MENSAJERIA" then
																	Response.Write " onmouseover=""return overlib('Agregar un cargo/credito');"" onmouseout=""return nd();"" alt=""Agregar un cargo/credito"""
																else
																	Response.Write " onmouseover=""return overlib('Modificar el peso');"" onmouseout=""return nd();"" alt=""Modificar el peso"""
																end if
															%>
														>
													</a>
												<%
											end if
											
											'recuperar la opcion de ver las evidencias
											SQL = "SELECT COUNT(0)  " & VbCrlf
											SQL = SQL & " FROM ECLIENT_MODALIDADES " & VbCrlf
											SQL = SQL & " WHERE CLM_CLICLEF IN ("& print_clinum &")" & VbCrlf
											SQL = SQL & " AND CLM_MOECLAVE = 10	 "
											
											Session("SQL") = SQL
											ArrayEvidencias = GetArrayRS(SQL)
											
											if (CInt(ArrayEvidencias(0,0)) > 0 ) and CInt(NVL_num(arrayLTL(52,iRowLoop))) > 0 then
												%>
													&nbsp;&nbsp;
													<a href="ltl_tracking.asp?track_num=<%=arrayLTL(21,iRowLoop)%><%=noMenu%><%=loginId%>#evidencias" onmouseover="return overlib('Ver las evidencias');" onmouseout="return nd();" style="text-decoration:none;">
														<img src="./images/system-search.png" style="border:none; cursor:pointer; width: 16px; height: 16px;" onmouseover="return overlib('Ver las evidencias');" onmouseout="return nd();" alt="Ver las evidencias" />
													</a>
												<%
											end if
											%>
												&nbsp;&nbsp;
												<a href="ltl_destinatarios_captura.asp?wcclclave=<%=arrayLTL(55,iRowLoop)%>" onmouseover="return overlib('Modificar el destinatario');" onmouseout="return nd();" style="text-decoration:none;">
													<img src="./images/contact-new.png" style="border:none; cursor:pointer; width: 16px; height: 16px;" onmouseover="return overlib('Modificar el destinatario');" onmouseout="return nd();" alt="Modificar el destinatario" />
												</a>
											<%
											if arrayLTL(44,iRowLoop) = "PRINT" then
												if  Session("ltl_internacional") = "1" and arrayLTL(59,iRowLoop)="5" then '
													%>
														&nbsp;&nbsp;&nbsp;
														<a href='/cgi/rwcgi60.exe/run?db_logis+OPER6304_web_ltl_metodos_2.rdf+welclave=<%=arrayLTL(19,iRowLoop)%>+display_importe=S+destype=cache+desformat=pdf' style="text-decoration:none;">
															<img src='./images/edit-paste.png' style='border:none;cursor:pointer; width: 16px; height: 16px;' onmouseover="return overlib('Imprimir el resumen de cargos');" onmouseout='return nd();' />
														</a>
													<%
												else
													%>
														&nbsp;&nbsp;&nbsp;
														<a href='/cgi/rwcgi60.exe/run?db_logis+OPER6304_web_ltl_metodos.rdf+welclave=<%=arrayLTL(19,iRowLoop)%>+display_importe=S+destype=cache+desformat=pdf' style="text-decoration:none;">
															<img src='./images/edit-paste.png' style='border:none;cursor:pointer; width: 16px; height: 16px;' onmouseover="return overlib('Imprimir el resumen de cargos');" onmouseout='return nd();' />
														</a>
													<%
												end if
											end if
											
											if NVL(arrayLTL(61,iRowLoop)) = "" then
											else
												%>
													&nbsp;&nbsp;&nbsp;
													<a href='/////192.168.0.103/cove_archivos/<%=arrayLTL(61,iRowLoop)%>' style="text-decoration:none;">
														<img src='./images/pdf.gif' style='border:none;cursor:pointer; width: 16px; height: 16px;' onmouseover="return overlib('Ver autorizacion <%=arrayLTL(60,iRowLoop)%>');" onmouseout='return nd();' />
													</a>
												<%
											end if
										end if
									%>
									<!--Eliminar talon de Manifiesto-->
									<%
										SQL_E = " SELECT WLD.WLD_WLCCLAVE ,WEL.WELCLAVE,WEL_MANIF_NUM  " & VbCrlf
										SQL_E =  SQL_E & " ,(SELECT COUNT(0) FROM ETRANSFERENCIA_TRADING TRA " & VbCrlf
										SQL_E =  SQL_E & " WHERE WEL.WEL_TRACLAVE = TRA.TRACLAVE AND TRA.TRASTATUS = '1' AND ROWNUM=1) ENTRADA  " & VbCrlf
										SQL_E =  SQL_E & " ,  " & VbCrlf
										SQL_E =  SQL_E & " ( " & VbCrlf
										SQL_E =  SQL_E & " select count(0) from dual " & VbCrlf
										SQL_E =  SQL_E & " where exists " & VbCrlf
										SQL_E =  SQL_E & " ( " & VbCrlf
										SQL_E =  SQL_E & "   SELECT NULL " & VbCrlf
										SQL_E =  SQL_E & " FROM WLDET_CONVERTIDOR WLD1  " & VbCrlf
										SQL_E =  SQL_E & " where wld1.WLD_WELCLAVE =wld.WLD_WELCLAVE " & VbCrlf
										SQL_E =  SQL_E & " and WLD1.WLD_WLCCLAVE <> WLD.WLD_WLCCLAVE " & VbCrlf
										SQL_E =  SQL_E & " union all " & VbCrlf
										SQL_E =  SQL_E & " SELECT NULL " & VbCrlf
										SQL_E =  SQL_E & " FROM WLDET_CONVERTIDOR WLD1  " & VbCrlf
										SQL_E =  SQL_E & " where wld1.WLD_WELCLAVE <> wld.WLD_WELCLAVE " & VbCrlf
										SQL_E =  SQL_E & " and WLD1.WLD_WLCCLAVE = WLD.WLD_WLCCLAVE " & VbCrlf
										SQL_E =  SQL_E & " )) " & VbCrlf
										SQL_E =  SQL_E & " CONVERTIDOR  " & VbCrlf
										SQL_E =  SQL_E & " FROM WEB_LTL WEL ,WLDET_CONVERTIDOR WLD " & VbCrlf
										SQL_E =  SQL_E & " WHERE ROWNUM=1 AND WEL.WELCLAVE = WLD.WLD_WELCLAVE(+) " & VbCrlf
										SQL_E =  SQL_E & "  AND WEL.WEL_CLICLEF IN ("& print_clinum &") AND WEL.WELCLAVE= (" & arrayLTL(19,iRowLoop)  & ") " 
										
										Session("SQL") = SQL_E
										arrayEnt = GetArrayRS(SQL_E)
										
										if (arrayLTL(18,iRowLoop) = "Act" or arrayLTL(18,iRowLoop) = "StdBy") and  IsArray(arrayEnt)  and cint(arrayEnt(3,0))=0 and cint(arrayEnt(4,0))=0  and Request.Form("manif_num") <>""  then
											%>
												&nbsp;&nbsp;
												<a href="javascript:quitar_manifiesto(<%=arrayLTL(19,iRowLoop)%>);" style="text-decoration:none;">
													<img src="./images/publish_x.png" style="border:none; cursor:pointer; width: 16px; height: 16px;" onmouseover="return overlib('Quitar talon del manifiesto');" onmouseout="return nd();" alt="Quitar talon del manifiesto" />
												</a>
											<%
										end if
									%>
								</td>
								<td name="tdFactura">
									<%
										Response.Write filtre_col(Mid(arrayLTL(3,iRowLoop), 2),110,"")
										'<<20230925: Se agrega opci�n para agregar Facturas a NUI's registrados con DocumentoFuente.
										if es_doc_fte = true then
											%>
												<br/>
												<a href="registrar_factura.asp?n=<%=arrayLTL(19,iRowLoop)%>">
													<img src="./images/img_cusbro02.jpg" style="border:none; cursor:pointer; width: 14px; height: 15px;" onmouseover="return overlib('Registrar Factura');" onmouseout="return nd();" alt="Registrar Factura" />
												</a>
											<%
										end if
										'  20230925>>
									%>
								</td>
								<td class="td_Manifiesto">
									<%
										SQL2 = "SELECT COUNT(0) FROM WEB_CAPTURA_PARAMETROS WHERE WCP_CLICLEF = " & Session("array_client")(2,0) & " AND NVL(WCP_CAPTURA_MANIF_II,'N') = 'P' OR NVL(WCP_CAPTURA_MANIF_II,'N') = 'S' "
										Session("SQL") = SQL2
										arrayTmp = GetArrayRS(SQL2)
										
										if arrayTmp(0, 0) > "0" then
											if arrayLTL(22,iRowLoop) <> "" then
												Response.Write "<a href=""ltl_consulta_manif3.asp?manif_num=" & arrayLTL(22,iRowLoop) & """ onmouseover=""return overlib('Ver Manifiesto');"" onmouseout=""return nd();"">" & arrayLTL(22,iRowLoop) & "</a>"
											else
												Response.Write "&nbsp;"
											end if
										Else
											if arrayLTL(22,iRowLoop) <> "" then
												Response.Write "<a href=""ltl_consulta_manif.asp?manif_num=" & arrayLTL(22,iRowLoop) & """ onmouseover=""return overlib('Ver Manifiesto');"" onmouseout=""return nd();"">" & arrayLTL(22,iRowLoop) & "</a>"
											else
												Response.Write "&nbsp;"
											end if
										end if
									%>
								</td>
								<td class="td_CdadBultos">
									<%
										SQLTariLogis = " select sum(decode(wpl_tpaclave,54,NVL(wpl_cdad_empaques_x_bulto*WPL_IDENTICAS,WPL_IDENTICAS),WPL_IDENTICAS)) cdad " & VbCrlf
										SQLTariLogis = SQLTariLogis & " from wpaleta_ltl " & VbCrlf
										SQLTariLogis = SQLTariLogis & " WHERE WPL_WELCLAVE = " & arrayLTL(19,iRowLoop) 
										SQLTariLogis = SQLTariLogis & " group by WPL_WELCLAVE " & VbCrlf
										
										Session("SQL") = SQLTariLogis
										ArrayTariLogis = GetArrayRS(SQLTariLogis)
										
										if isArray(ArrayTariLogis) then
											if ArrayTariLogis(0,0)="0"  then
												%>
													<%=arrayLTL(4,iRowLoop)%>
												<%
											else
												%>
													<%=ArrayTariLogis(0,0)%>
												<%
											end if
										else
											%>
												<%=arrayLTL(4,iRowLoop)%>
											<%
										end if
									%>
								</td>
								<td class="td_CedisOri">
									<a href="javascript:void(0);" onmouseover="return overlib('<%=JSescape(arrayLTL(6,iRowLoop))%>');" onmouseout="return nd();">
										<%=arrayLTL(5,iRowLoop)%>
									</a>
								</td>
								<td class="td_Remitente">
									<%=filtre_col(arrayLTL(7,iRowLoop),110,"")%>
								</td>
								<td class="td_CiudadEstadoRemi">
									<%=filtre_col(arrayLTL(8,iRowLoop),110,"")%>
								</td>
								<td class="td_Destinatario">
									<%=filtre_col(arrayLTL(11,iRowLoop),110,"")%>
								</td>
								<td class="td_CiudadEstadoDest">
									<%=filtre_col(arrayLTL(12,iRowLoop) & " (" & arrayLTL(13,iRowLoop) & ")",110,"")%>
								</td>
								<td class="td_RecolDomicilio">
									<%=arrayLTL(20,iRowLoop)%>
								</td>
								<td class="td_Importe">
									<%
										if arrayLTL(29,iRowLoop) <> "" then
											Response.Write FormatNumber(arrayLTL(29,iRowLoop),2)
										end if
									%>
								</td>
								<td class="td_Tipo">
									<a href="javascript:void(0);" onmouseover="return overlib('<%=JSescape(arrayLTL(37,iRowLoop))%>');" onmouseout="return nd();">
										<%=arrayLTL(38,iRowLoop)%>
									</a>
								</td>
								<td class="td_FechaRecoleccion">
									<%=arrayLTL(51,iRowLoop)%>
								</td>
								<td class="td_FechaTransLogis">
									<%=arrayLTL(14,iRowLoop)%>
								</td>
								<td class="td_FechaEntrega">
									<%=arrayLTL(16,iRowLoop)%>
								</td>
								<td class="td_NoAutorizacion">
									<%=NVL(arrayLTL(60,iRowLoop))%>
								</td>
								<td class="td_Status">
									<%=NVL(arrayLTL(62,iRowLoop))%>
								</td>
							</tr>
						<%
					next
				end if
				
				if Request.Form("etapa") = "1" then
					'generar un manifiesto
					%>
						<tr>
							<td colspan="19">
								&nbsp;
								<script language = "Javascript">
									<!--
										/**
										 * DHTML check all/clear all links script. Courtesy of SmartWebby.com (http://www.smartwebby.com/dhtml/)
										 */
										 //var form='form_name' //Give the form name here
										 function SetChecked(val,chkName,form)
										 {
											dml=document.forms[form];
											len = document.forms[form].elements.length;
											var i=0;
											
											for( i=0 ; i<len ; i++)
											{
												if (dml.elements[i].name==chkName)
												{
													dml.elements[i].checked=val;
												}
											}
										}
									// -->
								</script>
								<a href="javascript:SetChecked(1,'check_welclave','ltl_form')">
									<font face="Arial, Helvetica, sans-serif" size="0">
										Seleccionar todo
									</font>
								</a>
								&nbsp;&nbsp;&nbsp;
								<a href="javascript:SetChecked(0,'check_welclave','ltl_form')">
									<font face="Arial, Helvetica, sans-serif" size="0">
										Quitar todo
									</font>
								</a>
							</td>
						</tr>
						<%'seleccion y creacion de manifesto%>
						<tr align="left" class="impresion">
							<td colspan="19" class="titulo_trading">
								Crear Manifiesto:
							</td>
						</tr>
						<tr class="impresion">
							<td colspan="19">
								&nbsp;&nbsp;&nbsp;
								<img src="./images/edit-paste.png" style="border:none;cursor:pointer; width: 22px; height: 22px;" onclick="validarManifesto();" onmouseover="return overlib('Validar peticin de Manifiesto');" onmouseout="return nd();" alt="Validar manifiesto" />
								<input type="hidden" name="etapa" value="2" />
								<%
									if Request.Form("recoleccion_domicilio") = "S" then
										%>
											<input type="hidden" name="fecha_recoleccion" value="<%=Request.Form("fecha_recoleccion")%>" />
											<input type="hidden" name="hora_recoleccion" value="<%=Request.Form("hora_recoleccion")%>" />
											<input type="hidden" name="minutos_recoleccion" value="<%=Request.Form("minutos_recoleccion")%>" />
										<%
									end if
								%>
								<input type="hidden" name="disclef" value="<%=Request.Form("disclef")%>" />
							</td>
						</tr>
						<%'fin manifiesto%>
					<%
				end if
			%>
		</tbody>
	</table>
</form>
<%
	if Request.QueryString("etiquetas") = "1" then
		%>
			<br/><br/>
			<table class="datos" align="center" border="1" cellpadding="2" cellspacing="0">
				<tr class="titulo_trading" align="center">
					<td>
						&nbsp;Impresora&nbsp;Zebra&nbsp;
					</td>
					<td>
						&nbsp;
						Avery N<a href="http://www.avery.com.mx/products/add_to_cart.jsp?upc=7278265263&catalog_code=WEB03">5263</a>
						&nbsp;
					</td>
				</tr>
				<tr align="center">
					<td align="left">
						<!-- <<< CHG-DESA-13052024 Se agrega la referencia al nuevo modulo de etiquetas -->
						<form action="print_label.asp?nui=<%=Request.QueryString("id")%>" method="post" name="form_etiquetas" onsubmit='_Get("btnEnviar").disabled=true'>
							<input type="radio" name="tipo" value="zebra" checked /> TLP-2844 <font color="red">Z</font><br/>
							<!--<input type="radio" name="tipo" value="zebra_EPL" /> TLP-2844<br/>-->
							<input type="radio" name="tipo" value="hoja" /> Hoja (tama&ntilde;o carta)<br/>
							<br/>&iquest; Tipo de etiqueta ?<br/>
							<input type="radio" name="tipo_etiq" value="chico" checked /> Chica<br/>
							<input type="radio" name="tipo_etiq" value="grande" /> Grande<br/><br/>
							De <input type="text" size="3" class="light" value="1" name="ini_etiquetas" />
							A  <input type="text" size="3" class="light" value="<%=arrayLTL(4,0)%>" name="fin_etiquetas"/>
							<br/>
							<input type="hidden" name="id" value="<%=Request.QueryString("id")%>" />
							<input type="hidden" name="loginId" value="<%=Request("loginId")%>" />
							<input type="hidden" name="noMenu" value="<%=Request("noMenu")%>" />
							<input type="submit" id="btnEnviar" name="Validar" value="Validar" class="button_trading" />
							<input type="hidden" name="nui" value="<%=Request.QueryString("id")%>" />
							<!-- CHG-DESA-13052024 >>> -->
						</form>
					</td>
					<td>
						<!-- <<< CHG-DESA-13052024 Se agrega la referencia al nuevo modulo de etiquetas -->
						<form action="print_label.asp" method="post" name="form_etiquetas2">
							&iquest; Cu&aacute;ntas etiquetas faltan en la 1<sup>a</sup> hoja ?
							<br/><input type="text" name="num_faltantes" value="0" class="light" maxlength="2" size="2" />
							<input type="hidden" name="tipo" value="avery" />
							<input type="hidden" name="id" value="<%=Request.QueryString("id")%>" />
							<input type="hidden" name="loginId" value="<%=Request("loginId")%>" />
							<input type="hidden" name="noMenu" value="<%=Request("noMenu")%>" />
							<input type="submit" name="Validar" value="Validar" class="button_trading" />
							<input type="hidden" name="nui" value="<%=Request.QueryString("id")%>" />
						<!-- CHG-DESA-13052024 >>> -->
						</form>
					</td>
				</tr>
			</table>
		<%
	end if
	
	'para la venta de mostrador, mostrar un link para volver a capturar un cliente con el mismo remitente
	if CLng(Session("array_client")(2,0)) > 999000 _
	   and CLng(Session("array_client")(2,0)) < 1000000 then
		if Request.QueryString("id") <> "" then
			%>
				<div style="text-align: left;">
					<a href="vp_captura.asp?id=<%=Request.QueryString("id")%>">
						Capturar un nuevo talon con el <b>mismo</b> remitente
					</a>
				</div>
			<%
		elseif UBound(arrayLTL, 2) = 0 then
			%>
				<div style="text-align: left;">
					<a href="vp_captura.asp?id=<%=arrayLTL(19, 0)%>">
						Capturar un nuevo talon con el <b>mismo</b> remitente
					</a>
				</div>
			<%
		end if
	end if
%>
</div>
<script language="JavaScript">
	<!--
		tigra_tables('ltl_datos', 1, 0, '#ffffff', '#ffffcc', '#ffcc66', '#cccccc');
	// -->
</script>
<%
	'NB : iRows contient le dernier indice du tableau donc nb_lignes -1 !
%>
<script language="javascript">
	function next_page(page_num)
	{
		document.next_page.PageNum.value = page_num;
		document.next_page.submit();
	}
</script>
<form name=next_page method=post>
	<input type="hidden" name="PageNum" value="<%=TAGEscape(Request.Form("PageNum"))%>" />
</form>
<%
	if Request.Form ("etapa") = "" then
		call BuildNav2(PageNum, PageSize, iRows +1,"next_page")
	end if
	
	'fin timer
	Response.Write "<br><br>"
	StopTimer(1)
%>
</body>
</html>
<%
	'matamos la session en caso que sea con loginId
	if Request("loginId") <> "" then
		Set Session("array_client")= nothing
	end if
%>