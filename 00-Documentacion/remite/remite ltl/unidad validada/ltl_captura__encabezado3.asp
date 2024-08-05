<%@ Language=VBScript %>
<% option explicit
%><!--#include file="include/include.asp"--><%
dim qa
    qa = ""
Response.Expires = 0
call check_session()

dim num_client, clef, i
dim disnom, dis_ville, dis_estado, disclef, arrayLTL, script_include, SQL, array_tmp, dis_vilclef, arraySMO, verPeso
dim wel_allclave_ori, welrecol_domicilio, wel_disclef, wel_manif_num, wel_fecha_recoleccion, wel_manif_fecha, wel_cliclef
dim hacer_corte, wel_manif_corte, forzar_remisiones
dim diponibles, sqlDisponibles, arrDisponibles
	diponibles = 0
	sqlDisponibles = "    SELECT COUNT(WELCLAVE) CANTIDAD FROM WEB_LTL WHERE WELSTATUS = 3 AND WEL_CLICLEF = '" & Session("array_client")(2,0) & "'"
	arrDisponibles = GetArrayRS(sqlDisponibles)
	
	if IsArray(arrDisponibles) then
		diponibles = CDbl(arrDisponibles(0,0))
	end if
	
	if diponibles = 0 then
		Response.Redirect "ltl_consulta" & qa & ".asp?msg=" & Server.URLEncode("El cliente no cuenta con NUIs disponibles para documentar. Favor de comunicarse con el area de facturacion!")
	end if

dim cambia_ciudad
dim saldo_disponible, saldo_clase
DIM array_Ori
	for each clef  in Request.Form
		if Left(clef,6) = "client" then
			num_client=num_client & "," & Request.Form(clef)
		end if	
	next


	num_client=mid(num_client,2) 'on enleve la virgule superflue

dim wel_welclave 
	wel_welclave = Request.Form("txtNUIorigen")
Dim sqlFolioSiguiente, arrFolioSiguiente, iFolioSiguiente
'sqlFolioSiguiente = "SELECT nvl(MIN(WELCLAVE),0) FROM WEB_LTL WHERE WELFACTURA = 'RESERVADO' AND WELSTATUS <> 0 AND WEL_CLICLEF = '" & Session("array_client")(2,0) & "'"
sqlFolioSiguiente = "SELECT nvl(MIN(WELCLAVE),0) FROM WEB_LTL WHERE WELSTATUS = 3 AND WEL_CLICLEF = '" & Session("array_client")(2,0) & "'"
sqlFolioSiguiente = sqlFolioSiguiente & "   AND WELFACTURA IN ('RESERVADO','APAR_" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "_TADO') " & VbCrlf
arrFolioSiguiente = GetArrayRS(sqlFolioSiguiente)
if IsArray(arrFolioSiguiente) then
	iFolioSiguiente = arrFolioSiguiente(0,0)
end if
iFolioSiguiente = apartarNUI(Session("array_client")(2,0),SQLEscape(request.serverVariables("REMOTE_ADDR")),iFolioSiguiente)
' JEMV>

dim cliclefXcobrar
	'cliclefXcobrar = ClienteXcobrar(Session("array_client")(2,0))
	
'<<CHG-DESA-19092023-01: Se agrega consulta para validar la relacion NUI-Cliente:
dim sqlValidaNUI, arrValidaNUI, bValidaNUI
	bValidaNUI = false
	sqlValidaNUI = " SELECT * FROM WEB_LTL WHERE WELCLAVE = '" & Request.Form("txtNUIorigen") & "' AND WEL_CLICLEF = '" & Session("array_client")(2,0) & "' " & VbCrlf
	Session("SQL") = sqlValidaNUI
	
	arrValidaNUI = GetArrayRS(sqlValidaNUI)
	
	if IsArray(arrValidaNUI) then
		bValidaNUI = true
	end if
'  CHG-DESA-19092023-01>>



'<<CHG-DESA-13062022-01: Se agregan variables y lógica para consultar la Clave de Empresa por Cliente.
	Dim sqlCveEmpresa, arrCveEmpresa, iCveEmpresa
	
	sqlCveEmpresa = " SELECT	 cte.cliclef	clave_cliente " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "			,cte.clitype	tipo_cliente " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "			,cte.clinom	nombre_cliente " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "			,cte.clirfc	rfc_cliente " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "			,liga.cet_empclave	cve_empresa " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "			,emp.empnombre	nombre_empresa " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "			,liga.cetfecini	fecha " & VbCrlf
	sqlCveEmpresa = " SELECT	 NVL(liga.cet_empclave,0)	cve_empresa " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & " FROM	 eclient cte " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "		,eclient_empresa_trading liga " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "		,eempresas   emp " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & " WHERE	 cte.cliclef	=	liga.cet_cliclef " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "	AND	emp.empclave	=	liga.cet_empclave  " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & "	AND	cte.cliclef		=	'" & num_client & "' " & VbCrlf
	sqlCveEmpresa = sqlCveEmpresa & " ORDER BY	1 " & VbCrlf
	
	iCveEmpresa = "0"
	Session("SQL") = sqlCveEmpresa
	arrCveEmpresa = GetArrayRS(sqlCveEmpresa)
	
	if IsArray(arrCveEmpresa) then
		iCveEmpresa = arrCveEmpresa(0,0)
	end if
'  CHG-DESA-13062022-01>>


' <<< CHG-20221101: Se agrega consulta para validar si el cliente tiene registrado un concepto por seguro:
	Dim sqlSeguro, arrSeguro, iCCOClave
	
	iCCOClave = -1
	sqlSeguro = ""
	
	sqlSeguro = sqlSeguro & " SELECT	CCOCLAVE, CCO_CLICLEF, CCO_BPCCLAVE, CCO_YFOCLEF, CCO_DOUCLEF, CCO_CHOCLAVE, CCO_PARCLAVE " & VbCrlf
	sqlSeguro = sqlSeguro & " FROM	ECLIENT_APLICA_CONCEPTOS " & VbCrlf
	sqlSeguro = sqlSeguro & " WHERE	CCO_CLICLEF	=	'" & num_client & "' --- CAMBIAR CLIENTE " & VbCrlf
	sqlSeguro = sqlSeguro & " 	AND	CCO_CLICLEF	NOT IN (9954,9955,9956,9910) " & VbCrlf
	sqlSeguro = sqlSeguro & " 	AND	EXISTS	( " & VbCrlf
	sqlSeguro = sqlSeguro & " 					SELECT	NULL " & VbCrlf
	sqlSeguro = sqlSeguro & " 					FROM	EBASES_POR_CONCEPT " & VbCrlf
	sqlSeguro = sqlSeguro & " 					WHERE	BPCCLAVE	=	CCO_BPCCLAVE " & VbCrlf
	sqlSeguro = sqlSeguro & " 						AND	BPC_CHOCLAVE	IN	(	SELECT	CHOCLAVE " & VbCrlf
	sqlSeguro = sqlSeguro & " 													FROM	ECONCEPTOSHOJA " & VbCrlf
	sqlSeguro = sqlSeguro & " 													WHERE	CHOTIPOIE		=	'I' " & VbCrlf
	sqlSeguro = sqlSeguro & " 														AND	CHONUMERO		=	183 -- CONCEPTO SEGURO DE MERCANCÍA  / NO SE CAMBIA " & VbCrlf
	sqlSeguro = sqlSeguro & " 														AND	CHO_EMPCLAVE	=	'" & iCveEmpresa & "' -- CAMBIAR EMPRESA " & VbCrlf
	sqlSeguro = sqlSeguro & " 												) " & VbCrlf
	sqlSeguro = sqlSeguro & " 				) " & VbCrlf
	
	Session("SQL") = sqlSeguro
	arrSeguro = GetArrayRS(sqlSeguro)
	
	if IsArray(arrSeguro) then
		iCCOClave = arrSeguro(0,0)
	end if
'     CHG-20221101   >>>


	'verificaciones del numero de recoleccion
	'oper5359_ELEC
	Dim array_recol, mi_traclave, mi_dxpclave
	if Request.Form("num_recol") <> "" then
		SQL = "SELECT TRACLAVE, TPI_MDECLAVE , TRA.* " & VbCrlf
		SQL = SQL & "  FROM ETRANSFERENCIA_TRADING TRA " & VbCrlf
		SQL = SQL & "    , ETRANS_PICKING  " & VbCrlf
		SQL = SQL & "    , EDISTRIBUTEUR " & VbCrlf
		SQL = SQL & "    , EDESTINOS_POR_RUTA  " & VbCrlf
		SQL = SQL & "  WHERE TRA_ALLCLAVE = DER_ALLCLAVE " & VbCrlf
		SQL = SQL & "  AND TRASTATUS = '1'  " & VbCrlf
		SQL = SQL & "  AND TRA_CLICLEF = DISCLIENT " & VbCrlf
		SQL = SQL & "  AND TRA_MEZTCLAVE_ORI = 0  " & VbCrlf
		SQL = SQL & "  AND TRA_MEZTCLAVE_DEST = 2  " & VbCrlf
		SQL = SQL & "  AND TRACONS_GENERAL = '" & SQLEscape(Request.Form("num_recol")) & "'" & VbCrlf
		SQL = SQL & "  AND TPI_TRACLAVE = TRACLAVE " & VbCrlf
		SQL = SQL & "  AND DISCLEF = '" & SQLEscape(Request.Form("DISCLEF")) & "'" & VbCrlf
		SQL = SQL & "  AND DER_VILCLEF = DISVILLE "
		array_recol = GetArrayRS(SQL)
		if not IsArray(array_recol) then
			Response.Redirect "ltl_consulta_manif" & qa & ".asp?msg=" & Server.URLEncode("No existe este numero de operacion de recoleccion, o no es de este cliente, o es de otro cedis!") 
		end if
		
		if (array_recol(1, 0) <> "5" and array_recol(1, 0) <> "6") then
			Response.Redirect "ltl_consulta_manif" & qa & ".asp?msg=" & Server.URLEncode("Esta recoleccion no fue dada de alta como siendo una recoleccion de Cross Dock/LTL, no puede servir para hacer esta entrada!")
		end if
		mi_traclave = array_recol(0, 0)
		
		SQL = " SELECT DXPCLAVE   " & VbCrlf
		SQL = SQL & "  FROM EDET_EXPEDICIONES  " & VbCrlf
		SQL = SQL & "  WHERE DXP_TRACLAVE = " & mi_traclave  & VbCrlf
		SQL = SQL & "  AND DXP_TIPO_ENTREGA IN ('RECOLECCION', 'RECOL. DEVOLUCION')  " & VbCrlf
		array_recol = GetArrayRS(SQL)
		if not IsArray(array_recol) then
			Response.Redirect "ltl_consulta_manif" & qa & ".asp?msg=" & Server.URLEncode("Esta recoleccion no se ha puesto en una expedicion de tipo RECOLECCION todavia!") 
		end if
		mi_dxpclave = array_recol(0, 0)
		
		SQL = " SELECT SUM(CDAD)  " & VbCrlf
		SQL = SQL & " FROM " & VbCrlf
		SQL = SQL & " ( " & VbCrlf
		SQL = SQL & " 	SELECT COUNT(0) CDAD " & VbCrlf
		SQL = SQL & " 	FROM ETRANS_ENTRADA TAE, " & VbCrlf
		SQL = SQL & "   ETRANSFERENCIA_TRADING TRA " & VbCrlf
		SQL = SQL & " 	WHERE TAE_DXPCLAVE = " & mi_dxpclave & VbCrlf
		SQL = SQL & " 	AND TRACLAVE = TAE_TRACLAVE " & VbCrlf
		SQL = SQL & " 	AND TRASTATUS = '1' " & VbCrlf
		SQL = SQL & " 	UNION ALL " & VbCrlf
		SQL = SQL & " 	SELECT COUNT(0) " & VbCrlf
		SQL = SQL & " 	FROM ETRANS_DETALLE_CROSS_DOCK, " & VbCrlf
		SQL = SQL & "   ETRANSFERENCIA_TRADING TRA " & VbCrlf
		SQL = SQL & " 	WHERE TDCD_DXPCLAVE_ORI = " & mi_dxpclave & VbCrlf
		SQL = SQL & " 	AND TDCDSTATUS = '1' " & VbCrlf
		SQL = SQL & " 	AND TRACLAVE = TDCD_TRACLAVE " & VbCrlf
		SQL = SQL & " 	AND TRASTATUS = '1' " & VbCrlf
		SQL = SQL & " ) " & VbCrlf
		array_recol = GetArrayRS(SQL)
		if CInt(array_recol(0,0)) > 0 then
			Response.Redirect "ltl_consulta_manif" & qa & ".asp?msg=" & Server.URLEncode("Con esta recoleccion ya se ha hecho una entrada. No puede servir para esta operacion!") 
		end if 
		
		SQL = "SELECT COUNT(0) " & VbCrlf
		SQL = SQL & "   FROM WEB_LTL " & VbCrlf
		SQL = SQL & "     , EDISTRIBUTEUR " & VbCrlf
		SQL = SQL & "   WHERE WEL_DXPCLAVE_RECOL = " & mi_dxpclave & VbCrlf
		SQL = SQL & "   AND WELSTATUS = 1 " & VbCrlf
		SQL = SQL & "   AND WEL_CLICLEF = DISCLIENT " & VbCrlf
		SQL = SQL & "   AND WEL_DISCLEF = '" & SQLEscape(Request.Form("DISCLEF")) & "' " & VbCrlf
		
		if CInt(array_recol(0,0)) > 0 then
			Response.Redirect "ltl_consulta_manif" & qa & ".asp?msg=" & Server.URLEncode("Esta recoleccion esta asociada en otro manifiesto!") 
		end if 
	end if
	'"<script language=""javascript"" type=""text/javascript"" src=""include/js/firebug_lite/firebug.js""></script>" & vbCrLf & _
	script_include = "<script language=""JavaScript"" src=""include/js/jquery-1.2.3.js""></script>" & vbCrLf & _
					 "<script language=""JavaScript"" src=""include/js/jquery.form.js""></script>" & vbCrLf & _
					 "<script language=""JavaScript"" src=""include/js/jquery-select.js""></script>" & vbCrLf & _
					 
					 "<script src=""include/js/DynamicOptionList.js"" type=""text/javascript"" language=""javascript""></script>"


'Contiene funcionalidad para obtener el nombre del módulo a registrar en la Bitácora:
	script_include = script_include & vbCrLf & "<script language=""JavaScript"" src=""include/js/functions.js?v=1""></script>"
	Response.Write print_headers_nocache("Captura Talon Ligado", "ltl", script_include, "", "ObtenerURI();")

	if Request.Form("etapa") = 1 then
		'response.write Request.Form("txtNUIorigen")
		'response.end
		SQL = "SELECT    WEL_ALLCLAVE_ORI " & vbCrLf	'0
		SQL = SQL & "		, WEL_DISCLEF " & vbCrLf	'1
		SQL = SQL & "		, WEL_ALLCLAVE_DEST " & vbCrLf	'2	
		SQL = SQL & "		, WEL_DIECLAVE " & vbCrLf	'3
		SQL = SQL & "		, TO_CHAR(WEL_FECHA_RECOLECCION,'DD/MM/YYYY hh24:mi') WEL_FECHA_RECOLECCION " & vbCrLf	'4
		SQL = SQL & "		, WELFACTURA " & vbCrLf	'5
		SQL = SQL & "		, WEL_ORDEN_COMPRA " & vbCrLf	'6
		SQL = SQL & "		, WELIMPORTE " & vbCrLf		'7
		SQL = SQL & "		, WELCDAD_REMISIONES" & vbCrLf	'8
		SQL = SQL & "		, WELRECOL_DOMICILIO" & vbCrLf	'9
		SQL = SQL & "		, WELENTREGA_DOMICILIO " & vbCrLf	'10
		SQL = SQL & "		, NVL(WEL_CDAD_BULTOS,0) WEL_CDAD_BULTOS " & vbCrLf	'11
		SQL = SQL & "		, WELPESO " & vbCrLf	'12
		SQL = SQL & "		, WELOBSERVACION " & vbCrLf	'13
		SQL = SQL & "		, WELVOLUMEN " & vbCrLf	'14
		SQL = SQL & "		, WEL_COLLECT_PREPAID " & vbCrLf	'15
		SQL = SQL & "		, WEL_MANIF_NUM " & vbCrLf	'16
		SQL = SQL & "		, WEL_MANIF_FECHA " & vbCrLf	'17
		SQL = SQL & "		, WEL_DXPCLAVE_RECOL " & vbCrLf		'18
		SQL = SQL & "		, WLAANEXO " & vbCrLf	'19
		SQL = SQL & "		, WEL_MANIF_CORTE " & vbCrLf		'20
		SQL = SQL & "		, WELSTATUS " & vbCrLf	'21
		SQL = SQL & "		, NVL(WEL_CDAD_TARIMAS,0) WEL_CDAD_TARIMAS " & vbCrLf	'22
		SQL = SQL & "		, NVL(WEL_CAJAS_TARIMAS,0) WEL_CAJAS_TARIMAS" & vbCrLf	'23
		SQL = SQL & "		, NVL(WELCDAD_CAJAS,0) WELCDAD_CAJAS " & vbCrLf	'24
		SQL = SQL & "		, WEL_CONTACTO_OCURRE_LOGIS " & vbCrLf	'25
		SQL = SQL & "		, WEL_FIRMA " & vbCrLf	'26
		SQL = SQL & "		, WEL_TALON_RASTREO " & vbCrLf	'27
		SQL = SQL & "		, WELCONS_GENERAL " & vbCrLf	'28
		SQL = SQL & "		, WLACLAVE " & vbCrLf	'29
		SQL = SQL & "		, WLAANEXO " & vbCrLf	'30
		SQL = SQL & "		, WLCCLAVE " & vbCrLf	'31
		SQL = SQL & "		, WLC_IMPORTE " & vbCrLf	'32
		SQL = SQL & "		, WLC_CHOCLAVE " & vbCrLf	'33
		SQL = SQL & "		, WPLCLAVE " & vbCrLf	'34
		SQL = SQL & "		, WPL_IDENTICAS " & vbCrLf	'35
		SQL = SQL & "		, WPL_TPACLAVE " & vbCrLf	'36
		SQL = SQL & "		, WPLLARGO " & vbCrLf	'37
		SQL = SQL & "		, WPLANCHO " & vbCrLf	'38
		SQL = SQL & "		, WPLALTO " & vbCrLf	'39
		SQL = SQL & "		, VIL.VILCLEF " & vbCrLf	'40
		SQL = SQL & "		, EST.ESTESTADO " & vbCrLf	'41
		SQL = SQL & "		, WPL_TARIMA_CLIENTE " & vbCrLf	'42
		SQL = SQL & "		, WPL_CDAD_EMPAQUES_X_BULTO " & vbCrLf	'43
		SQL = SQL & "		, DECODE(NVL(WPL_BULTO_TPACLAVE,0),0,NVL(WEL_CAJAS_TARIMAS,0)+ NVL(WELCDAD_CAJAS,0),WPL_BULTO_TPACLAVE ) WPL_BULTO_TPACLAVE " & vbCrLf	'44
		SQL = SQL & "		, TO_CHAR(WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL_CLICLEF) " & vbCrLf	'45
		SQL = SQL & "		, DIS.DISCLEF " & vbCrLf '46
		SQL = SQL & "		, CIU_ORI.VILCLEF " & vbCrLf '47
		SQL = SQL & "		, EST_ORI.ESTESTADO " & vbCrLf '48
		SQL = SQL & "		, WEL.WEL_PRECIO_ESTIMADO " & vbCrLf '49
	    
		SQL = SQL & "     FROM WEB_LTL WEL " & vbCrLf
		SQL = SQL & "LEFT JOIN WEB_LTL_ANEXOS WLA ON WLA.WLA_WELCLAVE = WEL.WELCLAVE" & vbCrLf
		SQL = SQL & "LEFT JOIN WEB_LTL_CONCEPTOS WLC ON WLC_WELCLAVE = WEL.WELCLAVE " & vbCrLf
		SQL = SQL & "LEFT JOIN TB_LOGIS_WPALETA_LTL WPL ON WPL_WELCLAVE = WEL.WELCLAVE " & vbCrLf
		 SQL = SQL & " 	LEFT JOIN	EDIRECCIONES_ENTREGA DIE ON WEL.WEL_DIECLAVE = DIE.DIECLAVE "	&	VbCrlf
		SQL = SQL & " 	LEFT JOIN	ECIUDADES VIL ON DIE.DIEVILLE = VIL.VILCLEF "	&	VbCrlf
		SQL = SQL & " 	LEFT JOIN	EESTADOS EST ON VIL.VIL_ESTESTADO = EST.ESTESTADO "	&	VbCrlf
		SQL = SQL & " 	LEFT JOIN	EALMACENES_LOGIS AL ON WEL.WEL_ALLCLAVE_DEST = AL.ALLCLAVE "	&	VbCrlf
		SQL = SQL & " 	INNER JOIN EDISTRIBUTEUR DIS ON DIS.DISCLEF = WEL.WEL_DISCLEF "	&	VbCrlf
		SQL = SQL & " 	LEFT JOIN ECIUDADES CIU_ORI ON CIU_ORI.VILCLEF = DIS.DISVILLE "	&	VbCrlf
		SQL = SQL & " 	LEFT JOIN EESTADOS EST_ORI ON EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO "	&	VbCrlf
		SQL = SQL & "    WHERE WEL_CLICLEF	='" & Session("array_client")(2,0) & "' " & vbCrLf
		SQL = SQL & "	  AND WEL.WELCLAVE	='" & Request.Form("txtNUIorigen") & "' " & vbCrLf
	
		Session("SQL") = SQL
	'RESPONSE.WRITE SQL
	'response.end
		array_Ori = GetArrayRS(SQL)
	
		
	
	end if 
%>
	<style type="text/css">
		img {
			behavior:	url("include/js/pngbehavior.htc");
		}
		div.wrapper {
			margin-bottom: 5px;
		}
		/*td {
			border: thin dotted red;
		}*/
		.mandatory{
			/*text-decoration: underline;
			font-style: italic;
			font-weight: bold;*/
		}
		.mandatory:after{
			content: "*";
			color: red;
		}
		.not-set{
			font-weight: bold;
			color: red;
		}
		th {
			font-size: 8px;
			font-family: Verdana, arial, helvetica;
		}
        .disabled{
            background: #ccc;
            font-size: 10px;
            font-family: verdana,arial;
            font-weight: bold;
        }
	</style>
<%Randomize%>


<%
select case Request.Form("etapa")
	case ""
		%>
			<div id="dv_top" style="padding-top:50px;">
				&nbsp;
			</div>
			<form id="ligado_form" name="ligado_form" action="<%=asp_self%>" method="post">
				<input type="hidden" name="etapa" value="1" />
				<br><br>
				<br><br>
				<!-- <<<<<<< CHG-DESA-05-04-2024 -->				
					<%if Request.QueryString("msg") <> "" then%>
						<div style="text-align:center " class="messages error">
						<%=Request.QueryString("msg")%>
						</div>
					<%end if%>
				<!-- CHG-DESA-05-04-2024 >>>>>>> -->	
				<table align="center" width="90%" border="1" class="datos">
					<tr align=left> 
						<td  class="titulo_trading">Talon ligado 
							<%
							if Request.Form("rbtTipo") = "T" then
								'Response.write " (Total)"
							else
								'Response.write " (Parcial)"
							end if
							%>
							:
						</td>
					</tr>
					<tr>
						<td> 
							<table align="center" width="100%" border="0" class="datos">
								<tr valign="top" class="datos">
									<td>
										NUI al que se crear&aacute; el Tal&oacute;n Ligado:
										<input type="text" name="txtNUIorigen" id="txtNUIorigen" />
										&nbsp;&nbsp;
									</td>
								</tr>
								<tr>
									<td align="left">
										<table>
											<tr>
												<td>
													<input type="radio" name="rbtTipo" id="rbtTipoT" value="T" checked/>
												</td>
												<td>
													Total
												</td>
												<td>
													<input type="radio" name="rbtTipo" id="rbtTipoP" value="P" />
												</td>
												<td>
													Parcial
												</td>
											</tr>
										</table>
									</td>
								</tr>
								<tr>
									<td>
										<input type="submit" id="button_guardar_ltl" value="Enviar" class="button_trading" style="margin-bottom: 2px; float:left" />
									</td>
								</tr>
							</table>
						</td>
					</tr>
				</table>
			</form>
		<%
	case "1"
		if Request.Form("rbtTipo") = "T" then
			'Total:
			%>
			
			
			<% '<<<<<<< CHG-DESA-05-04-2024 
				if Request.Form("txtNUIorigen") = "" then
					Response.Redirect "ltl_captura__encabezado3.asp?msg=Es necesario ingresar un NUI" 
				end if
				' CHG-DESA-05-04-2024 >>>>> 
			%> 
			

				<form id="manifesto_form" name="manifesto_form" action="ltl_captura_encabezado_process_ligado<%=qa%>.asp?q=<%=Rnd%>" method="post">
					<input type="hidden" name="etapa" value="2" />
					<br><br>
					<br><br>
					<table align="center"  width="750px" border="1" class="datos">
						<tr align="left">
							<td  class="titulo_trading">Talon ligado 
								<%
								if Request.Form("rbtTipo") = "T" then
									Response.write " (Total)"
								else
									Response.write " (Parcial)"
								end if
								%>
								:
							</td>
						</tr>
						<tr>
							<td>
									<div class="wrapper">
										<table>
											<tr>
												<td align="right">
													<i>
														<span class="mandatory " title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n">NUI Origen:</span>
													</i>
												</td>
												<td colspan="5">
													<input type="text" name="wel_welClave" id="wel_welClave" class="light disabled" readonly="readonly" size="35" maxlength="100" value="<%=Request.Form("txtNUIorigen")%>" />
												</td>
											</tr>
											<tr>
												<td align="right">
													<span class="mandatory" title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n">NUI:</span>
												</td>
												<td colspan="5">
													<input type="text" name="welClave" id="welClave" class="light disabled" readonly="readonly" size="35" maxlength="100" value="<%=iFolioSiguiente%>" title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n" />
												</td>
											</tr>
											<tr>
												<td align="right"><span class="mandatory">Remitente:</span></td>		
												<td colspan="5">
													<%
														SQL = "SELECT DIS.DISCLEF " & VbCrlf
														SQL = SQL & " , INITCAP(DIS.DISNOM || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')') " & VbCrlf
														'SQL = SQL & " , DECODE(DIS.DISCLEF, '"& print_login_remitente &"', 'selected', NULL) " & VbCrlf
														SQL = SQL & " FROM EDISTRIBUTEUR DIS " & VbCrlf
														SQL = SQL & " , ECIUDADES CIU " & VbCrlf
														SQL = SQL & " , EESTADOS EST " & VbCrlf
														SQL = SQL & " WHERE DISCLIENT IN ("& Session("array_client")(2,0) &") " & VbCrlf
														SQL = SQL & " AND DIS.DISETAT = 'A' " & VbCrlf
														SQL = SQL & " AND CIU.VILCLEF = DIS.DISVILLE " & VbCrlf
														SQL = SQL & " AND EST.ESTESTADO = CIU.VIL_ESTESTADO "
															SQL = SQL & " ORDER BY DISNOM"
														array_tmp = GetArrayRS(SQL)
														if IsArray(array_tmp) then
													%> 
													<select id="wel_disclef" name="wel_disclef" class="light" style="width: 70%;">
														<option value="" selected="selected">Seleccione</option>
														<%For i = 0 to Ubound(array_tmp,2)
															Response.Write "<option value="""& array_tmp(0,i) &""" >" & array_tmp(1,i) & "</option>" & vbCrLf & vbTab
														Next%>
													</select> 
													<%end if %>
												</td>
											</tr>
											
											<%
												'<<CHG-DESA-19092023-01: Se agrega mensaje indicando que el NUI no corresponde al cliente:
												If bValidaNUI = false then
													%>
														<tr>
															<td colspan="6" align="center" class="error">
																El NUI <b><%=Request.Form("txtNUIorigen")%></b> no corresponde al Cliente <b><%=Session("array_client")(2,0)%></b>.<br/>
																Favor de validar.
															</td>
														</tr>
													<%
													Response.End
												end if
												'  CHG-DESA-19092023-01>>
											%>

											<tr>
												<td align="right"><span class="mandatory">Destinatario:</span></td>
												<td colspan="2">
													<%  SQL = "SELECT  " & VbCrlf
														SQL = SQL & " DISTINCT estestado, EST.ESTNOMBRE  " & VbCrlf
														SQL = SQL & " ,'' /*DECODE(estestado,'" & array_Ori(48,0)& "','selected','')*/   " & VbCrlf
														SQL = SQL & " FROM  " & VbCrlf
														SQL = SQL & "  ECLIENT_CLIENTE  CCL  " & VbCrlf
														SQL = SQL & "  , EDIRECCIONES_ENTREGA DIR  " & VbCrlf
														SQL = SQL & "  , ECIUDADES CIU  " & VbCrlf
														SQL = SQL & "  , EESTADOS EST  " & VbCrlf
														SQL = SQL & "  WHERE   " & VbCrlf
														SQL = SQL & "   CIU.VILCLEF = CCL.CCL_VILLE  " & VbCrlf
														SQL = SQL & "   AND CCL.CCL_STATUS = 1  " & VbCrlf
														SQL = SQL & "   and die_cclclave = cclclave  " & VbCrlf
														SQL = SQL & "  AND DIE_STATUS = 1 " & VbCrlf            
														SQL = SQL & "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO   " & VbCrlf
														SQL = SQL & "   AND EST.EST_PAYCLEF = 'N3'  " & VbCrlf
														SQL = SQL & "   ORDER BY 2  " & VbCrlf            
														'RESPONSE.WRITE SQL
														array_tmp = GetArrayRS(SQL) 
														If IsArray(array_tmp) Then%>
															<select name="LE_ESTESTADO" id="LE_ESTESTADO" class="light ">
																<option> Estado </option>
																<%For i = 0 To Ubound(array_tmp,2)
																	Response.Write "<option value=""" & array_tmp(0,i) & """ "& array_tmp(2,i) &">"
																	Response.Write array_tmp(1,i) & "</option>" & VbCrLf
																Next%>
															</select>
														<%Else 
															Response.Write "<p>Something bad went wrong</p>"
														End If%>
												</td>
												<td colspan="2">
													<div id="CIUDADES">
														<select name="LA_CIUDAD" id="LA_CIUDAD" class="light " >
														<option value="<%=array_Ori(47,0) %>">Ciudad</option>
														</select>
													</div>
												</td>
												<td></td>
											</tr>					
											<tr>
												<td>&nbsp;</td>
												<td colspan="5" align="left">
													<select name="wel_dieclave" id="wel_dieclave" class="light " style="width: 70%;" >
														<option value="<%=array_Ori(46,0) %>">Destinatario</option>
													</select>
												</td>
											</tr>
											<tr>
												<td></td>
												<td colspan="5">
													<input type="button" name="btnListaCompletaLogis" id="btnListaCompletaLogis" value="lista completa" class="button_trading" onclick="javascript:logis_sin_filtro();">
													<input type="button" name="btnListaCompleta" id="btnListaCompleta" value="lista completa" class="button_trading" onclick="javascript:sin_filtro();">								
												</td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td colspan="6">
													<b><span style="text-align: center;">
														Para agregar nuevo destinatario enviar un correo a <font color="blue">admin_destinatarios@logis.com.mx</font> y su ejecutivo de Atencion a Cliente
													</span></b>
												</td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr >
												<td align="right"><span id="contacto" class="mandatory">Contacto:</span></td>
												<td colspan="2">
													<input type="text" id="le_contacto"  name="le_contacto" class="light" size="30"> 
												</td>
												<td align="right"><span id="phone" class="mandatory">Tel&eacute;fono:</span></td>
												<td>
													<input type="text" id="le_phone" name="le_phone" class="light" size="20"> 
													<script>
														document.getElementById("contacto").style.display = "none";
														document.getElementById("le_contacto").style.display = "none";
														document.getElementById("phone").style.display = "none";
														document.getElementById("le_phone").style.display = "none";
														document.getElementById("btnListaCompletaLogis").style.display = "none";
													</script>
												</td>
												<td>&nbsp;</td>
											</tr>
											<!--<tr>
												<td align="right"><span>M&eacute;todo de Entrega:</span></td>
												<td colspan="2"> 
													&nbsp;&nbsp;&nbsp;&nbsp;<span>Ocurre Logis</span>
													<input type="checkbox" class="light" id="ocurre_oficina" name="ocurre_oficina" value="S" onclick="calc();"> 
												</td>
												<td colspan="3">
													&nbsp;&nbsp;&nbsp;&nbsp;<span id="entrega_dol">Entrega a domicilio</span>
													<input type="checkbox" class="light" id="welentrega_domicilio" name="welentrega_domicilio" value="S"> 
												</td>
											</tr>-->
											<tr>					
												<td align="right" class="lil_red"><span id="l_welfactura">No. Referencia:</span></td>
												<td colspan="4">
													<input type="text" name="welfactura" id="welfactura" class="light disabled" readonly size="35" maxlength="50" value="<%=array_Ori(5,0) %>">
												</td>
												<td>&nbsp;</td>
											</tr>
											<tr>					
												<td align="right" class="lil_red"><span id="l_wel_orden_compra">No. Documento:</span></td>
												<td colspan="4">
													
													<input type="text" name="wel_orden_compra" id="wel_orden_compra" class="light disabled" readonly size="35" maxlength="50" value="<%= array_Ori(6,0) %>" />
												</td>
												<td>&nbsp;</td>
											</tr>
											<tr>
												<td align="right">Pagado / Por Cobrar:</td>
												<td colspan="2">
													<%
														if cliclefXcobrar = true then
															%>
																<select id="wel_collect_prepaid" name="wel_collect_prepaid" class="light disabled" disabled>
																	<option value="POR COBRAR">Por Cobrar</option>
																</select>
															<%
														else
															%>
																<select id="wel_collect_prepaid" name="wel_collect_prepaid" class="light disabled" readonly disabled>
																	<option value="PREPAGADO">Prepagado
																</select>
															<%
														end if
													%>
												</td>
												<td colspan="3"></td>
											</tr>
											<tr>
												<td align="right">A cargo de:</td>
												<td colspan="2">
													<select id="WEL_A_CARGO_DE" name="WEL_A_CARGO_DE" class="light">
														<option value="CLIENTE" selected="selected">Cliente</option>
														<option value="LOGIS">Logis</option>
													</select>
												</td>
												<td colspan="3"></td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td align="right"><span>Cant. Bultos Totales:</span></td>
												<td>
													<input type="hidden" id="wel_cdad_bultos" name="wel_cdad_bultos" value="<%=array_Ori(11,0) %>">
													<input type="text"  class="light disabled" readonly id="wel_cdad_bultosAux" name="wel_cdad_bultosAux" size="10" maxlength="12" value="<%=array_Ori(11,0) %>	">
												</td>
												<td align="right"> <span class="mandatory">Cant. Tarimas:</span></td>
												<td><input type="text" class="light solo-numero disabled" readonly id="wel_cdad_tarimas" name="wel_cdad_tarimas" size="10" maxlength="12" onkeyup="recalculaEmbalaje();" value="<%=array_Ori(22,0) %>" ></td>
												<td align="right"><span style="font-style: italic;">Que contienen</span>&nbsp;&nbsp;<span class="mandatory">Cant. Cajas Totales:</span></td>
												<td><input type="text" name="wel_cajas_tarimas" id="wel_cajas_tarimas" class="light solo-numero disabled" readonly size="10" maxlength="14" value="<%=array_Ori(23,0) %>" ></td>
											</tr>
											<tr>
												<td colspan="3" align="right">
													<span style="font-weight: bold;">&iquest;Desea detallar la cantidad de cajas por tarima?</span>
												</td>
												<td align="Left">
													<%
														SQL = "SELECT  WPL_TARIMA_CLIENTE " & VbCrlf
														SQL = SQL & "	, WPL_CDAD_EMPAQUES_X_BULTO " & VbCrlf
														SQL = SQL & "	, WPL_BULTO_TPACLAVE " & VbCrlf
														SQL = SQL & "FROM TB_LOGIS_WPALETA_LTL WPL " & VbCrlf
														SQL = SQL & "WHERE WPL_WELCLAVE ='"&  Request.Form("txtNUIorigen") &"' " & VbCrlf
													    array_tmp = GetArrayRS(SQL)
														'response.write sql
														'response.end
														If IsArray(array_tmp) and array_Ori(22,0) <> "0" Then
														%>
													<input type="checkbox" name="detalle_tarimas" id="detalle_tarimas" value="S"  checked="checked" disabled" >
													<%
														else
														
														%>
													<input type="checkbox" name="detalle_tarimas" id="detalle_tarimas" value="S" onclick="JavaScript:show_detalle_tarimas();"  disabled>
													<%
														end if
														%>
												</td>
												<td colspan="2">&nbsp;</td>
											</tr>
											<% If IsArray(array_tmp) and array_Ori(22,0) <> "0" Then %>
											<tr id="bloque_detalle_tarimass" >
											<% 
												else 
												%>
											<tr id="bloque_detalle_tarimas" style="display: none;">
											<%
												end if %>
												<td colspan="3"></td>
												<td colspan="3">
													<table id="tableEmbalajes" style="border: thin solid gray;">
														<thead>
															<th width="10%">Tarima</th>
															<th width="70%">No. Tarima (cliente)</th>
															<th width="20%"><span class="mandatory">Cant. Cajas o Asimilables</span></th>
														</thead>
														<tbody>
														<% If IsArray(array_tmp) and array_Ori(22,0) <> "0" Then 
																dim row
																for row = 0 to ubound(array_tmp,2)  

																	Response.Write "<tr id='row_" & row + 1 & "'>"
																	  response.write  "<td align=""right"" width=""10%"" ><span>"& row + 1 & "</span></td>"
																	  response.write  "<td align=""center"" width=""70%""><input type=""text"" id=""tarima_cliente_" & row + 1 & """ name=""tarima_cliente_" & row + 1 & """ size=""30"" maxlength=""30"" class=""disabled"" value=""" & array_tmp(0,row )& """ readonly ></td>"
																	  response.write  "<td align=""Left"" width=""20%""><input type=""text"" id=""cdad_cajas_" & row + 1 &""" name=""cdad_cajas_" & row + 1 & """ size=""10"" maxlength=""10"" class=""light just-added disabled"" value=""" & array_tmp(1,row )& """ readonly ></td>"
																	  response.write  "</tr>"
															next 
																end if %>

														</tbody>
													</table>
												</td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td colspan="2">&nbsp;</td>
												<td align="right"><span class="mandatory">Cant. Cajas o Asimilables:</td>
												<td colspan="2"><input type="text" name="welcdad_cajas" id="welcdad_cajas" class="light solo-numero disabled" size="10" maxlength="12" value="<%=array_Ori(24,0) %>" readonly>
													<%  
														SQL = "SELECT TPACLAVE, InitCap(NVL(TPADESCRIPCION_WEB,TPADESCRIPCION)), DECODE(TPACLAVE, NVL('" & array_Ori(36,0) & "',0), 'selected', NULL) " & VbCrlf
														SQL = SQL & "  FROM ETIPOS_PALETA " & VbCrlf
														SQL = SQL & "  WHERE TPA_STCCLAVE IS NULL " & VbCrlf
														SQL = SQL & "  AND NVL(TPAWEB,'N') = 'S' " & VbCrlf
														SQL = SQL & " UNION " & VbCrlf
														SQL = SQL & " SELECT TPACLAVE, InitCap(NVL(TPADESCRIPCION_WEB,TPADESCRIPCION)), DECODE(TPACLAVE, NVL('" & array_Ori(36,0) & "',0), 'selected', NULL) " & VbCrlf
														SQL = SQL & " FROM ETIPOS_PALETA " & VbCrlf
														SQL = SQL & " WHERE TPA_STCCLAVE IS NULL " & VbCrlf
														SQL = SQL & " AND NVL(TPAWEB,'N') = 'S' " & VbCrlf
														SQL = SQL & " AND TPACLAVE = 9 " & VbCrlf
														SQL = SQL & "  ORDER BY 2  "
														Session("SQL") = SQL
														
														array_tmp = GetArrayRS(SQL) 
														If IsArray(array_tmp) Then%>
															<select id="tpa_caja" name="tpa_caja" class="light required disabled" >
																<%For i = 0 To Ubound(array_tmp, 2)
																	Response.Write "<option value=""" & array_tmp(0,i) & """" & array_tmp(2,i)  & ">"
																	Response.Write array_tmp(1,i) & "</option>" & VbCrLf
																Next%>
															</select>
														<%Else 
															Response.Write "<p>Something bad went wrong</p>"
														End If%>
												</td>
												<td><input type="text"  class="light disabled" id="welcdad_cajasAux" name="welcdad_cajasAux" size="10" readonly maxlength="14" value="<%=array_Ori(24,0) %>"></td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td align="right">Total del Registro:</td>
												<td><input type="text"  class="light disabled" id="totalRegAux" name="totalRegAux" size="10" readonly maxlength="14" value="<%=array_Ori(11,0) %>"></td>
												<td>&nbsp;</td>
												<td><input type="text"  class="light disabled" id="totalReg2Aux" name="totalReg2Aux" size="10" readonly maxlength="14" value="<%=array_Ori(11,0) %>"></td>
												<td>&nbsp;</td>
												<td><input type="text"  class="light disabled" id="totalReg3Aux" name="totalReg3Aux" size="10" readonly maxlength="14" value="<%=array_Ori(44,0) %>" ></td>
											</tr>						
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td align="right"><span id="l_welimporte">Valor Mercancia:</span></td>
												<td><input type="text" name="welimporte" id="welimporte" class="light solo-numero-dec disabled" readonly size="10" maxlength="14" value="<%=array_Ori(7,0) %>"></td>
												<td colspan="4">&nbsp;</td>
											</tr>
											<tr>
												<td align="right"><span class="mandatory">Cant. Anexos:</span></td>	
												<%	Dim anexos
														SQL = "SELECT WLAANEXO " & VbCrLf
														SQL = SQL & "FROM  WEB_LTL_ANEXOS " & VbCrLf
														SQL = SQL & "WHERE WLA_WELCLAVE='" & Request.Form("txtNUIorigen") & "' " & VbCrLf 
														Session("SQL") = SQL
														'response.write sql
														array_tmp = GetArrayRS(SQL) 
														if IsArray(array_tmp) then
															for i=0 to UBound(array_tmp,2)
																anexos = anexos & array_tmp(0,i) & vbCrLf
															next
														else
															i = 0
															anexos = "."
														end if
														%>
												<td><input type="text" name="welCdadAnexos" id="welCdadAnexos" class="light solo-numero disabled" readonly size="10" maxlength="14" value="<%=i %>"></td>
												<td colspan="4">&nbsp;</td>
											</tr>
											<tr>
												<td align="right"><span class="mandatory">Anexos:</span><br><span style="font-style: italic;">(uno por linea)</span></td>
												<td colspan="5">
													
													<textarea cols="40" rows="3" class="light disabled" readonly name="anexos" id="anexos"><%=anexos %></textarea>
												</td>
											</tr>
											<tr>
												<td align="right"><span class="mandatory">Dice contener:</span></td>
												<td colspan="5">
													<span style="float:left">
														<!-- lunes, 24 de abril de 2023 04:00 p. m.: Se habilita campo a solicitud de Elyan Galvan Vargas - SMO <elyangv@logis.com.mx>  -->
														<textarea cols="40" rows="3" class="light " name="welobservacion" id="welobservacion"><%=array_Ori(13,0) %></textarea>
														<%if print_login_wel_observacion <> "" then%>
															<br><b><i>Observacion permanente:</i></b><br><%=Replace(print_login_wel_observacion, vbLf, "<br>")%>
														<%end if%>
													</span>
												</td>
											</tr>
											<tr>
												<td colspan="6"><input type="hidden" name="welcdad_remisiones" id="welcdad_remisiones" class="light" size="10" maxlength="6"></td>
											</tr>
											<%
												'if verPeso = ".0." then 
													%>
														<tr>
															<!--<td style="display: none;">Peso (kg)</td>-->
															<td><input type="hidden" name="welpeso" id="welpeso" class="light" value="<%=array_Ori(12,0)%>" /></td>
															<td><input type="hidden" name="welvolumen" id="welvolumen" class="light" value="<%=array_Ori(14,0)%>" /></td>
														</tr>
													<%
												'end if
											%> 
										</table>
									</div>
										<!-- cambio tarimas -->				
										
										
									<div class="wrapper">										
										<br>		
										<span style="float:left;margin-left:5px;">
											<input type="submit" id="button_guardar_ltl" value="Guardar" class="button_trading" style="margin-bottom: 2px; float:left"/>
											<img src="images/Throbber-mac.gif" id="throbber_wel" class="escondido" style="margin-bottom: -2px;float:left">
											<input type="button" id="button_cancelar" value="Cancelar" class="titulo_inicio" style="margin-left:50px;margin-bottom: 2px; float:left" onclick="window.location.href='<%=asp_self%>';" />
										</span>
									</div>
									<br style="clear:both;"/>

									<input type="hidden" name="wel_manif_num" id="wel_manif_num" value="">
									<input type="hidden" name="wel_manif_fecha" id="wel_manif_fecha" value="">
									<input type="hidden" name="wel_fecha_recoleccion" id="wel_fecha_recoleccion" value="<%=array_Ori(4,0)%>">
									<input type="hidden" name="welrecol_domicilio" id="welrecol_domicilio" value="<%=array_Ori(9,0)%>">
								<!--<MRG: Guardar wel_allclave_ori correcto--> 
									<input type="hidden" name="wel_allclave_ori" id="wel_allclave_ori" value="">
								<!--MRG>-->
									<!--<input type="hidden" name="wel_disclef" id="wel_disclef" value="<%=array_Ori(3,0)%>">-->
									<input type="hidden" name="wel_cliclef" id="wel_cliclef" value="<%=Session("array_client")(2,0)%>">
									<input type="hidden" name="hacer_corte" id="hacer_corte" value="">
									<input type="hidden" name="wel_manif_corte" id="wel_manif_corte" value="<%=array_Ori(20,0)%>">
									<input type="hidden" name="wel_dxpclave_recol" id="wel_dxpclave_recol" value="<%=array_Ori(18,0)%>">  
									<input type="hidden" name="WEL_WTLCLAVE" id="WEL_WTLCLAVE" value="1" />
	
									<!--<input type="b"-->
									
									<!-- <<< CHG-20221101: Se agrega clave de la empresa para validar seguro -->
									<input type="hidden" name="iCveEmpresa" id="iCveEmpresa" value="<%=iCveEmpresa%>">
									<input type="hidden" name="iCCOClave" id="iCCOClave" value="<%=iCCOClave%>">
									<!--     CHG-20221101 >>> -->
									<!-- Se agrega instrucción para insertar en bitácora: -->
										<input type="hidden" name="WBD_MODULO" id="WBD_MODULO" />

							</td>
						</tr>
					</table>
				</form>
			<%
		else
		
		'<<<<<<< CHG-DESA-05-04-2024 
		if Request.Form("txtNUIorigen") = "" then
			Response.Redirect "ltl_captura__encabezado3.asp?msg=Es necesario ingresar un NUI" 
		end if
		' CHG-DESA-05-04-2024 >>>>> 
		
			'Parcial:
			%>
				<form id="manifesto_form" name="manifesto_form" action="ltl_captura_encabezado_process_ligado<%=qa%>.asp?q=<%=Rnd%>" method="post">
					<input type="hidden" name="etapa" value="2" />
					<br><br>
					<br><br>
					<table align="center"  width="750px" border="1" class="datos">
						<tr align="left">
							<td  class="titulo_trading">Talon ligado 
								<%
								if Request.Form("rbtTipo") = "T" then
									Response.write " (Total)"
								else
									Response.write " (Parcial)"
								end if
								%>
								:
							</td>
						</tr>
						<tr>
							<td>
									<div class="wrapper">
										<table>
											<tr>
												<td align="right">
													<i>
														<span class="mandatory " title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n">NUI Origen:</span>
													</i>
												</td>
												<td colspan="5">
													<input type="text" name="wel_welClave" id="wel_welClave" class="light disabled" readonly="readonly" size="35" maxlength="100"  value="<%=Request.Form("txtNUIorigen")%>" />
												</td>
											</tr>
											<tr>
												<td align="right">
													<span class="mandatory" title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n">NUI:</span>
												</td>
												<td colspan="5">
													<input type="text" name="welClave" id="welClave" class="light disabled" readonly="readonly" size="35" maxlength="100" value="<%=iFolioSiguiente%>" title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n" />
												</td>
											</tr>
											<tr>
												<td align="right"><span class="mandatory">Remitente:</span></td>		
												<td colspan="5">
													<%
														SQL = "SELECT DIS.DISCLEF " & VbCrlf
														SQL = SQL & " , INITCAP(DIS.DISNOM || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')') " & VbCrlf
														'SQL = SQL & " , DECODE(DIS.DISCLEF, '"& print_login_remitente &"', 'selected', NULL) " & VbCrlf
														SQL = SQL & " FROM EDISTRIBUTEUR DIS " & VbCrlf
														SQL = SQL & " , ECIUDADES CIU " & VbCrlf
														SQL = SQL & " , EESTADOS EST " & VbCrlf
														SQL = SQL & " WHERE DISCLIENT IN ("& Session("array_client")(2,0) &") " & VbCrlf
														SQL = SQL & " AND DIS.DISETAT = 'A' " & VbCrlf
														SQL = SQL & " AND CIU.VILCLEF = DIS.DISVILLE " & VbCrlf
														SQL = SQL & " AND EST.ESTESTADO = CIU.VIL_ESTESTADO "
															SQL = SQL & " ORDER BY DISNOM"
														array_tmp = GetArrayRS(SQL)
														if IsArray(array_tmp) then
													%> 
													<select id="wel_disclef" name="wel_disclef" class="light" style="width: 70%;">
														<option value="" selected="selected">Seleccione</option>
														<%For i = 0 to Ubound(array_tmp,2)
															Response.Write "<option value="""& array_tmp(0,i) &"""  >" & array_tmp(1,i) & "</option>" & vbCrLf & vbTab 
														Next%>
													</select> 
													<%end if %>
												</td>

											</tr>
											<tr>
												<td align="right"><span class="mandatory">Destinatario:</span></td>
												<td colspan="2">
													<%  SQL = "SELECT  " & VbCrlf
														SQL = SQL & " DISTINCT estestado, EST.ESTNOMBRE  " & VbCrlf
														SQL = SQL & " ,'' /*DECODE(estestado,'" & array_Ori(48,0)& "','selected','')*/   " & VbCrlf
														SQL = SQL & " FROM  " & VbCrlf
														SQL = SQL & "  ECLIENT_CLIENTE  CCL  " & VbCrlf
														SQL = SQL & "  , EDIRECCIONES_ENTREGA DIR  " & VbCrlf
														SQL = SQL & "  , ECIUDADES CIU  " & VbCrlf
														SQL = SQL & "  , EESTADOS EST  " & VbCrlf
														SQL = SQL & "  WHERE   " & VbCrlf
														SQL = SQL & "   CIU.VILCLEF = CCL.CCL_VILLE  " & VbCrlf
														SQL = SQL & "   AND CCL.CCL_STATUS = 1  " & VbCrlf
														SQL = SQL & "   and die_cclclave = cclclave  " & VbCrlf
														SQL = SQL & "  AND DIE_STATUS = 1 " & VbCrlf            
														SQL = SQL & "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO   " & VbCrlf
														SQL = SQL & "   AND EST.EST_PAYCLEF = 'N3'  " & VbCrlf
														SQL = SQL & "   ORDER BY 2  " & VbCrlf            
														'RESPONSE.WRITE SQL
														array_tmp = GetArrayRS(SQL) 
														If IsArray(array_tmp) Then%>
															<select name="LE_ESTESTADO" id="LE_ESTESTADO" class="light ">
																<option> Estado </option>
																<%For i = 0 To Ubound(array_tmp,2)
																	Response.Write "<option value=""" & array_tmp(0,i) & """ "& array_tmp(2,i) &">"
																	Response.Write array_tmp(1,i) & "</option>" & VbCrLf
																Next%>
															</select>
														<%Else 
															Response.Write "<p>Something bad went wrong</p>"
														End If%>
													
												</td>
												<td colspan="2">
													<div id="CIUDADES">
														<select name="LA_CIUDAD" id="LA_CIUDAD" class="light " >
														<option value="<%=array_Ori(47,0) %>">Ciudad</option>
														</select>
													</div>
												</td>
												<td></td>
											</tr>					
											<tr>
												<td>&nbsp;</td>
												<td colspan="5" align="left">
													<select name="wel_dieclave" id="wel_dieclave" class="light " style="width: 70%;" >
														<option value="<%=array_Ori(46,0) %>">Destinatario</option>
													</select>
												</td>
											</tr>
											<tr>
												<td></td>
												<td colspan="5">
													<input type="button" name="btnListaCompletaLogis" id="btnListaCompletaLogis" value="lista completa" class="button_trading" onclick="javascript:logis_sin_filtro();">
													<input type="button" name="btnListaCompleta" id="btnListaCompleta" value="lista completa" class="button_trading" onclick="javascript:sin_filtro();">								
												</td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td colspan="6">
													<b><span style="text-align: center;">
														Para agregar nuevo destinatario enviar un correo a <font color="blue">admin_destinatarios@logis.com.mx</font> y su ejecutivo de Atencion a Cliente
													</span></b>
												</td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr >
												<td align="right"><span id="contacto" class="mandatory">Contacto:</span></td>
												<td colspan="2">
													<input type="text" id="le_contacto"  name="le_contacto" class="light" size="30"> 
												</td>
												<td align="right"><span id="phone" class="mandatory">Tel&eacute;fono:</span></td>
												<td>
													<input type="text" id="le_phone" name="le_phone" class="light" size="20"> 
													<script>
														document.getElementById("contacto").style.display = "none";
														document.getElementById("le_contacto").style.display = "none";
														document.getElementById("phone").style.display = "none";
														document.getElementById("le_phone").style.display = "none";
														document.getElementById("btnListaCompletaLogis").style.display = "none";
													</script>
												</td>
												<td>&nbsp;</td>
											</tr>
											<!--<tr>
												<td align="right"><span>M&eacute;todo de Entrega:</span></td>
												<td colspan="2"> 
													&nbsp;&nbsp;&nbsp;&nbsp;<span>Ocurre Logis</span>
													<input type="checkbox" class="light" id="ocurre_oficina" name="ocurre_oficina" value="S" onclick="calc();"> 
												</td>
												<td colspan="3">
													&nbsp;&nbsp;&nbsp;&nbsp;<span id="entrega_dol">Entrega a domicilio</span>
													<input type="checkbox" class="light" id="welentrega_domicilio" name="welentrega_domicilio" value="S"> 
												</td>
											</tr>-->
											<tr>					
												<td align="right" class="lil_red"><span id="l_welfactura">No. Referencia:</span></td>
												<td colspan="4">
													<input type="text" name="welfactura" id="welfactura" class="light" size="35" maxlength="50" value="<%=array_Ori(5,0) %>">
												</td>
												<td>&nbsp;</td>
											</tr>
											<tr>					
												<td align="right" class="lil_red"><span id="l_wel_orden_compra">No. Documento:</span></td>
												<td colspan="4">
													<input type="text" name="wel_orden_compra" id="wel_orden_compra" class="light "  size="35" maxlength="50" value="<%=array_Ori(6,0) %>" />
												</td>
												<td>&nbsp;</td>
											</tr>
											<tr>
												<td align="right">Pagado / Por Cobrar:</td>
												<td colspan="2">
													<%
														if cliclefXcobrar = true then
															%>
																<select id="wel_collect_prepaid" name="wel_collect_prepaid" class="light " >
																	<option value="POR COBRAR">Por Cobrar</option>
																</select>
															<%
														else
															%>
																<select id="wel_collect_prepaid" name="wel_collect_prepaid" class="light " readonly >
																	<option value="PREPAGADO">Prepagado
																</select>
															<%
														end if
													%>
												</td>
												<td colspan="3"></td>
											</tr>
											<tr>
												<td align="right">A cargo de:</td>
												<td colspan="2">
													<select id="WEL_A_CARGO_DE" name="WEL_A_CARGO_DE" class="light">
														<option value="CLIENTE" selected="selected">Cliente</option>
														<option value="LOGIS">Logis</option>
													</select>
												</td>
												<td colspan="3"></td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td align="right"><span>Cant. Bultos Totales:</span></td>
												<td>
													<input type="hidden" id="wel_cdad_bultos" name="wel_cdad_bultos" value="<%=array_Ori(11,0) %>">
													<input type="text"  class="light "  id="wel_cdad_bultosAux" disabled name="wel_cdad_bultosAux" size="10" maxlength="12" value="<%=array_Ori(11,0) %>">
												</td>
												<td align="right"> <span class="mandatory">Cant. Tarimas:</span></td>
												<td><input type="text" class="light solo-numero "  id="wel_cdad_tarimas" name="wel_cdad_tarimas" size="10" maxlength="12" onkeyup="recalculaEmbalaje();" value="<%=array_Ori(22,0) %>" ></td>
												<td align="right"><span style="font-style: italic;">Que contienen</span>&nbsp;&nbsp;<span class="mandatory">Cant. Cajas Totales:</span></td>
												<td><input type="text" name="wel_cajas_tarimas" id="wel_cajas_tarimas" class="light solo-numero "  size="10" maxlength="14" value="<%=array_Ori(23,0) %>" ></td>
											</tr>
											<tr>
												<td colspan="3" align="right">
													<span style="font-weight: bold;">&iquest;Desea detallar la cantidad de cajas por tarima?</span>
												</td>
												<td align="Left">
													<input type="checkbox" name="detalle_tarimas" id="detalle_tarimas" value="S" onclick="JavaScript:show_detalle_tarimas();" >
												</td>

												<td colspan="2">&nbsp;</td>
											</tr>
											<tr id="bloque_detalle_tarimas" style="display: none;">
												<td colspan="3"></td>
												<td colspan="3">
													<table id="tableEmbalaje" style="border: thin solid gray;">
														<thead>
															<th width="10%">Tarima</th>
															<th width="70%">No. Tarima (cliente)</th>
															<th width="20%"><span class="mandatory">Cant. Cajas o Asimilables</span></th>
														</thead>
														<tbody></tbody>
													</table>
												</td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td colspan="2">&nbsp;</td>
												<td align="right"><span class="mandatory">Cant. Cajas o Asimilables:</td>
												<td colspan="2"><input type="text" name="welcdad_cajas" id="welcdad_cajas" class="light solo-numero " size="10" maxlength="12" value="<%=array_Ori(24,0) %>" >
													<%  
														SQL = "SELECT TPACLAVE, InitCap(NVL(TPADESCRIPCION_WEB,TPADESCRIPCION)), DECODE(TPACLAVE,NVL('" & array_Ori(36,0) & "',0), 'selected', NULL) " & VbCrlf
														SQL = SQL & "  FROM ETIPOS_PALETA " & VbCrlf
														SQL = SQL & "  WHERE TPA_STCCLAVE IS NULL " & VbCrlf
														SQL = SQL & "  AND NVL(TPAWEB,'N') = 'S' " & VbCrlf
														SQL = SQL & " UNION " & VbCrlf
														SQL = SQL & " SELECT TPACLAVE, InitCap(NVL(TPADESCRIPCION_WEB,TPADESCRIPCION)), DECODE(TPACLAVE, NVL('" & array_Ori(36,0) & "',0), 'selected', NULL) " & VbCrlf
														SQL = SQL & " FROM ETIPOS_PALETA " & VbCrlf
														SQL = SQL & " WHERE TPA_STCCLAVE IS NULL " & VbCrlf
														SQL = SQL & " AND NVL(TPAWEB,'N') = 'S' " & VbCrlf
														SQL = SQL & " AND TPACLAVE = 9 " & VbCrlf
														SQL = SQL & "  ORDER BY 2  "
														Session("SQL") = SQL
														
														array_tmp = GetArrayRS(SQL) 
														If IsArray(array_tmp)  Then%>
															<select id="tpa_caja" name="tpa_caja" class="light required " >
																<%For i = 0 To Ubound(array_tmp, 2)
																	Response.Write "<option value=""" & array_tmp(0,i) & """" & array_tmp(2,i)  & ">"
																	Response.Write array_tmp(1,i) & "</option>" & VbCrLf
																Next%>
															</select>
														<%Else 
															Response.Write "<p>Something bad went wrong</p>"
														End If%>
												</td>
												<td><input type="text" disabled class="light" id="welcdad_cajasAux" name="welcdad_cajasAux" size="10" maxlength="14" value="<%=array_Ori(24,0) %>"></td>
											</tr>
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td align="right">Total del Registro:</td>
												<td><input type="text" disabled class="light" id="totalRegAux" name="totalRegAux" size="10" maxlength="14" value="<%=array_Ori(11,0) %>"></td>
												<td>&nbsp;</td>
												<td><input type="text" disabled class="light" id="totalReg2Aux" name="totalReg2Aux" size="10" maxlength="14" value="<%=array_Ori(11,0) %>"></td>
												<td>&nbsp;</td>
												<td><input type="text" disabled class="light" id="totalReg3Aux" name="totalReg3Aux" size="10" maxlength="14" value="<%=array_Ori(44,0) %>"></td>
											</tr>						
											<tr>
												<td colspan="6">&nbsp;</td>
											</tr>
											<tr>
												<td align="right"><span id="l_welimporte">Valor Mercancia:</span></td>
												<td><input type="text" name="welimporte" id="welimporte" class="light solo-numero-dec "  size="10" maxlength="14" value="<%=array_Ori(7,0) %>"></td>
												<td colspan="4">&nbsp;</td>
											</tr>
											<tr>
												<td align="right"><span class="mandatory">Cant. Anexos:</span></td>	
												<%	
														SQL = "SELECT WLAANEXO " & VbCrLf
														SQL = SQL & "FROM  WEB_LTL_ANEXOS " & VbCrLf
														SQL = SQL & "WHERE WLA_WELCLAVE='" & Request.Form("txtNUIorigen") & "' " & VbCrLf 
														Session("SQL") = SQL
														'response.write sql
														array_tmp = GetArrayRS(SQL) 
														if IsArray(array_tmp) then
															for i=0 to UBound(array_tmp,2)
																anexos = anexos & array_tmp(0,i) & vbCrLf
															next
														end if
														%>
												<td><input type="text" name="welCdadAnexos" id="welCdadAnexos" class="light solo-numero "  size="10" maxlength="14" value="<%=i %>"></td>
												<td colspan="4">&nbsp;</td>
											</tr>
											<tr>
												<td align="right"><span class="mandatory">Anexos:</span><br><span style="font-style: italic;">(uno por linea)</span></td>
												<td colspan="5">
													<textarea cols="40" rows="3" class="light "  name="anexos" id="anexos"><%=anexos %></textarea>
												</td>
											</tr>
											<tr>
												<td align="right"><span class="mandatory">Dice contener:</span></td>
												<td colspan="5">
													<span style="float:left">
														<textarea cols="40" rows="3" class="light "  name="welobservacion" id="welobservacion"><%=array_Ori(13,0) %></textarea>
														<%if print_login_wel_observacion <> "" then%>
															<br><b><i>Observacion permanente:</i></b><br><%=Replace(print_login_wel_observacion, vbLf, "<br>")%>
														<%end if%>
													</span>
												</td>
											</tr>
											<tr>
												<td colspan="6"><input type="hidden" name="welcdad_remisiones" id="welcdad_remisiones" class="light" size="10" maxlength="6"></td>
											</tr>
											<%if verPeso = ".0." then %>
											<tr>
												<td style="display: none;">Peso (kg)</td>
												<td colspan="5"><input type="hidden" name="welpeso" id="welpeso" class="light" size="10" maxlength="6"></td>
											</tr>
											<%end if %> 
										</table>
									</div>
										<!-- cambio tarimas -->				
										
										
									<div class="wrapper">										
										<br>		
										<span style="float:left;margin-left:5px;">
											<input type="submit" id="button_guardar_ltl" value="Guardar" class="button_trading" style="margin-bottom: 2px; float:left"/>
											<img src="images/Throbber-mac.gif" id="throbber_wel" class="escondido" style="margin-bottom: -2px;float:left">
											<input type="button" id="button_cancelar" value="Cancelar" class="titulo_inicio" style="margin-left:50px;margin-bottom: 2px; float:left" onclick="window.location.href='<%=asp_self%>';" />
										</span>
									</div>
									<br style="clear:both;"/>

									<input type="hidden" name="wel_manif_num" id="wel_manif_num" value="">
									<input type="hidden" name="wel_manif_fecha" id="wel_manif_fecha" value="">
									<input type="hidden" name="wel_fecha_recoleccion" id="wel_fecha_recoleccion" value="<%=array_Ori(4,0)%>">
									<input type="hidden" name="welrecol_domicilio" id="welrecol_domicilio" value="<%=array_Ori(9,0)%>">
								<!--<MRG: Guardar wel_allclave_ori correcto-->
									<input type="hidden" name="wel_allclave_ori" id="wel_allclave_ori" value="">
								<!--MRG>-->
									<!--<input type="hidden" name="wel_disclef" id="wel_disclef" value="<%=array_Ori(3,0)%>">-->
									<input type="hidden" name="wel_cliclef" id="wel_cliclef" value="<%=Session("array_client")(2,0)%>">
									<input type="hidden" name="hacer_corte" id="hacer_corte" value="">
									<input type="hidden" name="wel_manif_corte" id="wel_manif_corte" value="<%=array_Ori(20,0)%>">
									<input type="hidden" name="wel_dxpclave_recol" id="wel_dxpclave_recol" value="<%=array_Ori(18,0)%>"> 
									<input type="hidden" name="WEL_WTLCLAVE" id="WEL_WTLCLAVE" value="1" />
									<!--<input type="b"-->
									
									<!-- <<< CHG-20221101: Se agrega clave de la empresa para validar seguro -->
									<input type="hidden" name="iCveEmpresa" id="iCveEmpresa" value="<%=iCveEmpresa%>">
									<input type="hidden" name="iCCOClave" id="iCCOClave" value="<%=iCCOClave%>">
									<!--     CHG-20221101 >>> -->
									<!-- <<CHG-DESA-20230117: Se agrega instrucción para insertar en bitácora. -->
										<input type="hidden" name="WBD_MODULO" id="WBD_MODULO" />
									<!--   CHG-DESA-20230117>> -->

							</td>
						</tr>
					</table>
				</form>
			<%
		end if
	case else
end select
%>
<script type="text/javascript">
       // bind 'myForm' and provide a simple callback function 
    $(document).ready(function () {
        // bind 'myForm' and provide a simple callback function 
		
        $('#manifesto_form').ajaxForm({
            beforeSubmit: validarForm,
            dataType: 'json',
            success: processJson,
            error: processError,
            timeout: 180000
        });
       
        //$('#add_dieclave').click(load_dieclave);
        $("#throbber_wel").hide();
    });
    $(function () {
        $('#LE_ESTESTADO').ready(function () {
            $.ajaxSetup({ async: false })
            $('#LA_CIUDAD').load('ajax_ciudades<%=qa%>.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val() + '&LA_CIUDAD=' + $('#LA_CIUDAD').val());
            $.ajaxSetup({ async: true })
            con_filtro();

        });
    });
    $(function () {
        $('#LA_CIUDAD').ready(function () {
            con_filtro();
        });
    });
    $(function () {
		$('#LE_ESTESTADO').change(function () {
			
            $.ajaxSetup({ async: false })
            $('#LA_CIUDAD').load('ajax_ciudades<%=qa%>.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
            $.ajaxSetup({ async: true })
            con_filtro();

        });
    });
    /*<MRG: Guardar wel_allclave_ori correcto*/
	 $(function () {
         $('#wel_disclef').change(function () {
			 
             ref_json =  'wel_disclef=' + $("#wel_disclef").val();
            
             $.ajaxSetup({ async: false })
             $.ajax({
                 type: "GET",
                 url: "ajax_almacen.asp",
                 data: ref_json,
                 dataType: 'text',
                 success: function (data) {
					 if (data != "") {
			             document.getElementById("wel_allclave_ori").value = data;
                     }
                     
                 }
             });

        });
	 });
	/*MRG>*/
	function processJson(data) {
		var qa = "";
        //insertamos el talon creado
        if (data.error != '') {
            alert(data.error);
        } else {

            /* < JEMV: valida si se documentó la LTL: */
            if (data.welclave != "-1") {
                // <JEMV 02/03/2022 - Presento toda la información del manifiesto:
                //$('#ltl_datos tr:not(:first-child)').remove();
                //$("#ltl_datos").append(data.Tabla);
                //$("#wel_manif_num").val(data.wel_manif_num);
                //$("#wel_manif_corte").val(data.wel_manif_corte);
                //$("#wel_manif_num_view").text(data.wel_manif_num);
                //$("#wel_manif_corte_view").text(data.wel_manif_corte);
                //$("#print_etiquetas_manif").show();
                ///* <JEMV */
                //$("#welClave").val(data.folioSiguiente);
                location.href = "ltl_consulta.asp?tipo=1&msg=Se ha creado el NUI " + data.welclave + " correctamente!";
            }
			else {
				alert(data.error);
                //$("#ltl_datos").append("<tr valign='center' align='center'>"
                //    + "<td colspan='8'>" + data.error + "</td>"
                //    + "</tr>"
                //);
            }
        }

        //restablecer los controls
       
    }
    function processError(msg, url, line) {
        var data;
        if (msg.response.indexOf("{") != -1 && msg.response.indexOf("}") != -1) {
           // $("#ltl_datos").append(msg.response);
			alert(msg.response);
        }
        
	}
    function load_dieclave(event) {
        event.preventDefault();
        if ($('#wccl_form').html() == null) {
            $('#new_dieclave').load('ltl_destinatarios_captura<%=qa%>.asp?json=ok #wccl_form', activate_wccl);
        } else {
            $('#wccl_form').show();
        }
    }
    $(function () {
        $('#wel_cdad_tarimas, #welcdad_cajas').change(function () {
            var tarimas = 0;
            var cajas = 0;
            if ($('#wel_cdad_tarimas').val() != "") {
                tarimas = parseFloat($('#wel_cdad_tarimas').val());
            }
            if ($('#welcdad_cajas').val() != "") {
                cajas = parseFloat($('#welcdad_cajas').val());
            }
            $('#wel_cdad_bultos').val((tarimas + cajas));
            $('#wel_cdad_bultosAux').val((tarimas + cajas));
            $('#totalRegAux').val((tarimas + cajas));
            $('#totalReg2Aux').val((tarimas + cajas));
        });
    });

    $(function () {
        $('#wel_cajas_tarimas, #welcdad_cajas').change(function () {
            var cajastarimas = 0;
            var cajas = 0;

            if ($('#wel_cajas_tarimas').val() != "") {
                cajastarimas = parseFloat($('#wel_cajas_tarimas').val());
            }

            if ($('#welcdad_cajas').val() != "") {
                cajas = parseFloat($('#welcdad_cajas').val());
            }

            $('#welcdad_cajasAux').val(cajas);
            $('#totalReg3Aux').val((cajastarimas + cajas));
        });
    });


    $(function () {
		$('#LA_CIUDAD').change(function () {
           
            con_filtro();
        });
    });

	function con_filtro() {
		

		if ($('#wel_dieclave').val() != null) {
            
			$('#wel_dieclave').load('ajax_dest_con_filtro<%=qa%>.asp?LA_CIUDAD=' + $('#LA_CIUDAD').val() + "&destinatario=" + $('#wel_dieclave').val().split("|")[0]);
		}
		else {
            
        } $('#wel_dieclave').load('ajax_dest_con_filtro<%=qa%>.asp?LA_CIUDAD=' + $('#LA_CIUDAD').val() );
    }

    function sin_filtro() {
        $('#wel_dieclave').load('ajax_dest<%=qa%>.asp?LA_CIUDAD=' + $('#LA_CIUDAD').val());
    }

    function logis_filtro() {
        $('#wel_dieclave').load('ajax_logis<%=qa%>.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
    }

    function logis_sin_filtro() {
        $('#wel_dieclave').load('ajax_logis_completo.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
    }



    function show_detalle_tarimas() {
        if ($("#detalle_tarimas").attr('checked')) {
            //if($("#wel_cdad_tarimas").val() && !isNaN($("#wel_cdad_tarimas").val())) {
            $("#bloque_detalle_tarimas").toggle();
            cargaembalaje();
            //}
        } else {
            //if($("#wel_cdad_tarimas").val() && !isNaN($("#wel_cdad_tarimas").val())) {
            limpiarembalaje();
            $("#bloque_detalle_tarimas").toggle();
            //}
        }
    }

    function cargaembalaje() {
        var x;
        for (x = 1; x <= $("#wel_cdad_tarimas").val(); x = x + 1) {
            addEmbalajes(x);
        }

        $(".just-added").keyup(function () {
            this.value = (this.value + '').replace(/[^0-9]/g, '');
        });
    }

    function limpiarembalaje() {
        var x;
        var len = $("#tableEmbalaje > tbody").children().length;
        for (x = 1; x <= len; x = x + 1) {
            $('#row_' + x).remove();
        }
    }

	function addEmbalajes(row) {
        $("#tableEmbalaje > tbody:last-child").append("<tr id=\"row_" + row + "\">"
            + "<td align=\"right\" width=\"10%\"><span>" + row + "</span></td>"
            + "<td align=\"center\" width=\"70%\"><input type=\"text\" id=\"tarima_cliente_" + row + "\" name=\"tarima_cliente_" + row + "\" size=\"30\" maxlength=\"30\"></td>"
            + "<td align=\"Left\" width=\"20%\"><input type=\"text\" id=\"cdad_cajas_" + row + "\" name=\"cdad_cajas_" + row + "\" size=\"10\" maxlength=\"10\" class=\"light just-added\"></td>"
            + "</tr>");
    }

    function recalculaEmbalaje() {
        if ($("#detalle_tarimas").attr('checked')) {
            limpiarembalaje();
            cargaembalaje();
        }
    }

    function validarForm(formData, jqForm, options) {
        // jqForm is a jQuery object which wraps the form DOM element 
        // 
        // To validate, we can access the DOM elements directly and return true 
        // only if the values of both the username and password fields evaluate 
        // to true 
        var form = jqForm[0];
        var resp = true;
        var msg;
		
        if (!$("#wel_dieclave").val() || $("#wel_dieclave").val().indexOf("|") < 0) {
            alert('Favor de seleccionar un destinatario.');
            return false;
        }
        if ($("#ocurre_oficina").attr('checked')) {
            if (!$("#le_contacto").val() && !$("#le_phone").val()) {
                alert('Favor de capturar el Contacto y/o el teléfono.');
                return false;
            }
        }
				<%
            '<<20230803: Las cuentas internas no tendrán estas validaciones:
        if CInt(Session("array_client")(2, 0)) < 9900 or CInt(Session("array_client")(2, 0)) > 9999 then
            %>
					if (!$("#wel_cdad_tarimas").val() || isNaN($("#wel_cdad_tarimas").val())) {
            alert('Favor de capturar la cantidad de tarimas.');
            return false;
        }
        if (!$("#wel_cajas_tarimas").val() || isNaN($("#wel_cajas_tarimas").val())) {
            alert('Favor de capturar la cantidad de cajas totales.');
            return false;
        }
        if (!$("#welCdadAnexos").val() || isNaN($("#welCdadAnexos").val())) {
            alert('Favor de capturar la cantidad de anexos.');
            return false;
        }
        if (!$("#anexos").val()) {
            alert('Favor de capturar los anexos, uno por línea.');
            return false;
        }
        if (!$("#welobservacion").val()) {
            alert('Favor de capturar el detalle de lo que dice contener.');
            return false;
        }
				<%
            end if
				'  20230803>>
            %>
				if (!$("#welcdad_cajas").val() || isNaN($("#welcdad_cajas").val())) {
                alert('Favor de capturar la cantidad de cajas o asimilables.');
                return false;
            }
        if (isNaN($("#wel_cdad_bultos").val())) {
            alert('Favor de capturar la cantidad de bultos.');
            return false;
        }
        if (isNaN(form.welimporte.value)) {
            alert('Favor de capturar un importe numerico o dejarlo vacio.');
            return false;
        }

        /*	<<< CHG-20221101: Se agrega validación para forzar a capturar el valor de mercancía cuando el cliente tiene configurado el Seguro de Mercancía.	*/
        if ($("#iCCOClave").val() != "-1" && $("#iCCOClave").val() != "" && $("#iCCOClave").val() != "undefined" && $("#iCCOClave").val() != undefined) {
            if ($("#welimporte").val() == "") {
                $('#welimporte').addClass("not-set");
                $('#l_welimporte').addClass("not-set");

                alert('Error: Cliente con tarifa de seguro, falta capturar Valor de la Mercancía.');
                return false;
            }
            /*	<<< CHG-20230404: Se agrega validación para forzar a que la cantidad capturada sea mayor a cero.	*/
            else {
                if (parseFloat($("#welimporte").val()) <= 0) {
                    $('#welimporte').addClass("not-set");
                    $('#l_welimporte').addClass("not-set");

                    alert('Error: Cliente con tarifa de seguro, el Valor de la Mercancia debe ser mayor a cero.');
                    return false;
                }
            }
            /*	    CHG-20230404 >>>	*/
        }
        /*	    CHG-20221101 >>>	*/

        if ($("#detalle_tarimas").attr('checked')) {
            var len = $("#wel_cdad_tarimas").val();
            var acc = 0;

            for (x = 1; x <= len; x++) {
                if (!$("#cdad_cajas_" + x).val() || isNaN($("#cdad_cajas_" + x).val()) || parseInt($("#cdad_cajas_" + x).val()) == 0) {
                    alert('Favor de capturar la cantidad de cajas por tarima para todas las tarimas.');
                    return false;
                }

                acc = acc + parseInt($("#cdad_cajas_" + x).val());
            }

            if (acc > 0 && acc != parseInt($("#wel_cajas_tarimas").val())) {
                alert('El total de cajas en el detalle de tarimas no coincide con el total de cajas por tarima: ' + (acc) + ' <> ' + $("#wel_cajas_tarimas").val());
                return false;
            }
        }
       
        msg = "";
        if (!$('#welfactura').val()) {
            $('#l_welfactura').addClass("not-set");
            msg = msg + "- N\u00B0 Referencia|";
        } else {
            $('#l_welfactura').removeClass("not-set");
        }
        /*
		if (!$('#wel_orden_compra').val()) {
            $('#l_wel_orden_compra').addClass("not-set");
            msg = msg + "- N\u00B0 Documento|";
        } else {
            $('#l_wel_orden_compra').removeClass("not-set");
        }
		*/        
        if (!$('#welfactura').val() || !$('#wel_orden_compra').val() || !$('#welimporte').val()) {
            var el = msg.split("|");

            if (el.length > 0) {
                if (el[0] != "") {
                    msg = "No ha capturado los siguientes datos:\n";

                    for (x = 0; x < el.length; x++)
                        msg = msg + el[x] + "\n";

                    resp = confirm(msg + "\u00BFconfirma registrar el tal\u00F3n?");

                    if (!resp) return resp;
                }
            }
        }

        $("#button_guardar_ltl").attr("disabled", "disabled");
        $("#button_guardar_ltl").val("Guardando...");
		$("#throbber_wel").show();
        return resp;
    }
</script> 