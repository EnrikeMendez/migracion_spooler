<%@ Language=VBScript %>
<% option explicit
%><!--#include file="include/include.asp"--><%
dim qa
	qa = ""
Response.Expires = 0
call check_session()

dim num_client, clef, i
dim disnom, dis_ville, dis_estado, disclef, arrayLTL, script_include, SQL, array_tmp
dim wel_allclave_ori, welrecol_domicilio, wel_disclef, wel_manif_num, wel_fecha_recoleccion, wel_manif_fecha, wel_cliclef
dim status, status_color
dim dump

dim cambia_ciudad 


	for each clef  in Request.Form
		if Left(clef,6) = "client" then
			num_client=num_client & "," & Request.Form(clef)
		end if  
	next

	num_client=mid(num_client,2) 'on enleve la virgule superflue


	Dim sqlFolioSiguiente, arrFolioSiguiente, iFolioSiguiente
		sqlFolioSiguiente = "SELECT nvl(MIN(WELCLAVE),0) FROM WEB_LTL WHERE WELFACTURA = 'RESERVADO' AND WELSTATUS <> 0 AND WEL_CLICLEF = '" & num_client & "'"
		arrFolioSiguiente = GetArrayRS(sqlFolioSiguiente)
	if not IsArray(arrFolioSiguiente) then
    Response.Write "<center><font color='#900C3F'>El cliente " & Session("array_client")(2,0) & " no cuenta con folios reservados disponibles para documentar, favor de verificarlo con el &aacute;rea de facturaci&oacute;n.</font></center>"
    Response.End 
else
	if arrFolioSiguiente(0, 0) = "0" then
		Response.Write "<center><font color='#900C3F'>El cliente " & Session("array_client")(2,0) & " no cuenta con folios reservados disponibles para documentar, favor de verificarlo con el &aacute;rea de facturaci&oacute;n.</font></center>"
		Response.End 
	else
		iFolioSiguiente = arrFolioSiguiente(0, 0)
	end if
end if


	script_include = "<script language=""JavaScript"" src=""include/js/jquery-1.2.3.js""></script>" & vbCrLf & _
					"<script language=""JavaScript"" src=""include/js/jquery.form.js""></script>" & vbCrLf & _
					"<script language=""JavaScript"" src=""include/js/jquery-select.js""></script>" & vbCrLf & _
					"<script language=""javascript"" type=""text/javascript"" src=""include/js/firebug_lite/firebug.js""></script>" & vbCrLf & _
					"<script src=""include/js/DynamicOptionList.js"" type=""text/javascript"" language=""javascript""></script>"

	Response.Write print_headers("Encabezado LTL", "ltl", script_include, "", "")

%>
	<img src="images/pixel.gif" width="0" height="100" border="0">
	<div id="menu" style="text-align:center; z-index:1;">
	<style type="text/css">
		img {
			behavior: url("include/js/pngbehavior.htc");
		}
		.disabled{
            background: #ccc;
            font-size: 10px;
            font-family: verdana,arial;
            font-weight: bold;
        }
	</style>

<%	if Request.Form("wel_manif_num") = "" then
		'estamos creando un nuevo manifiesto, recuperamos los datos del remitente
		SQL = "SELECT InitCap(DISNOM) " & VbCrlf
		SQL = SQL & "   , InitCap(VILNOM) " & VbCrlf
		SQL = SQL & "   , InitCap(ESTNOMBRE)  " & VbCrlf
		SQL = SQL & "   , DISCLIENT  " & VbCrlf
		SQL = SQL & "   , DISCLEF  " & VbCrlf
		SQL = SQL & " FROM EDISTRIBUTEUR  " & VbCrlf
		SQL = SQL & "   , ECIUDADES " & VbCrlf
		SQL = SQL & "   , EESTADOS " & VbCrlf
		SQL = SQL & " WHERE DISCLEF = '" & SQLEscape(Request.Form("DISCLEF")) & "'" & VbCrlf
		SQL = SQL & "   AND VILCLEF = DISVILLE " & VbCrlf
		SQL = SQL & "   AND ESTESTADO = VIL_ESTESTADO"
		arrayLTL = GetArrayRS(SQL)

		if not IsArray(arrayLTL) then
			Response.Write "Datos de remitente incorrectos."
			Response.End 
		end if

		disnom = arrayLTL(0,0)
		dis_ville = arrayLTL(1,0)
		dis_estado = arrayLTL(2,0)
		wel_cliclef = arrayLTL(3,0)
		wel_disclef = arrayLTL(4,0) 
		if Request.Form("recoleccion_domicilio") = "S" then
			wel_fecha_recoleccion = Request.Form("fecha_recoleccion") &" "& Request.Form("hora_recoleccion") &":"& Request.Form("minutos_recoleccion")
		end if

		'vamos a poner la fecha de llegada aqui
		'luego se usara para hacer la entrada del manifiesto
		wel_manif_fecha = Request.Form("fecha_entrada") &" "& Request.Form("hora_entrada") &":"& Request.Form("minutos_entrada")

	else
		'estamos modificando un manifiesto recuperamos los datos de remitente y los talones
		SQL = "SELECT DISTINCT WEL_MANIF_NUM " & VbCrlf
		SQL = SQL & "   , TO_CHAR(WEL_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI') " & VbCrlf
		SQL = SQL & "   , InitCap(DISNOM) " & VbCrlf
		SQL = SQL & "   , InitCap(VILNOM) " & VbCrlf
		SQL = SQL & "   , InitCap(ESTNOMBRE)  " & VbCrlf
		SQL = SQL & "   , WEL_CLICLEF  " & VbCrlf
		SQL = SQL & "   , WEL_DISCLEF  " & VbCrlf
		SQL = SQL & "   , TO_CHAR(WEL_MANIF_FECHA, 'dd/mm/YYYY HH24:MI') " & VbCrlf
		SQL = SQL & " FROM WEB_LTL  " & VbCrlf
		SQL = SQL & "   , EDISTRIBUTEUR  " & VbCrlf
		SQL = SQL & "   , ECIUDADES " & VbCrlf
		SQL = SQL & "   , EESTADOS " & VbCrlf
		SQL = SQL & " WHERE WEL_MANIF_NUM = " & SQLEscape(Request.Form("WEL_MANIF_NUM")) & VbCrlf
		SQL = SQL & "  AND WEL_CLICLEF IN (" & num_client & ") " &  VbCrlf
		SQL = SQL & "   AND DISCLEF = WEL_DISCLEF " & VbCrlf
		SQL = SQL & "   AND VILCLEF = DISVILLE " & VbCrlf
		SQL = SQL & "   AND ESTESTADO = VIL_ESTESTADO"

		arrayLTL = GetArrayRS(SQL)

		if not IsArray(arrayLTL) then
			Response.Write "Datos de manifiesto incorrectos."
			Response.End 
		end if

		wel_manif_num = arrayLTL(0,0) 
		wel_fecha_recoleccion = arrayLTL(1,0) 
		disnom = arrayLTL(2,0)
		dis_ville = arrayLTL(3,0)
		dis_estado = arrayLTL(4,0)
		wel_cliclef = arrayLTL(5,0)
		wel_disclef = arrayLTL(6,0)
		wel_manif_fecha = arrayLTL(7,0)
	end if


	'recuperamos el CEDIS del remitente
	SQL = " SELECT DER_ALLCLAVE  " & vbCrLf 
	SQL = SQL & " FROM EDESTINOS_POR_RUTA  " & vbCrLf
	SQL = SQL & " , EDISTRIBUTEUR " & vbCrLf
	SQL = SQL & " WHERE DISCLEF = " & wel_disclef & vbCrLf
	SQL = SQL & " AND DER_VILCLEF = DISVILLE " & vbCrLf
	SQL = SQL & " AND DER_ALLCLAVE > 0  " & vbCrLf
	arrayLTL = GetArrayRS(SQL)
	if IsArray(arrayLTL) then
		wel_allclave_ori = arrayLTL(0,0)

		'buscar si hay un cedis de remitente forzado
		SQL = "  SELECT DIS_ALLCLAVE " & VbCrlf
		SQL = SQL & "   FROM EDISTRIBUTEUR " & VbCrlf
		SQL = SQL & "   WHERE DISCLEF = " & wel_disclef & vbCrLf
		SQL = SQL & "   AND DIS_ALLCLAVE IS NOT NULL "
		arrayLTL = GetArrayRS(SQL)
		if IsArray(arrayLTL) then
			wel_allclave_ori = arrayLTL(0,0)  
		end if

	else
		wel_allclave_ori = 1 
	end if

	call print_saldo_monedero
%>
	<table class="datos" id="ltl_manif" align="center" BORDER="1" cellpadding="2" cellspacing="0" width="800">
		<thead>
			<tr class="titulo_trading_bold" valign="center" align="center"> 
				<td>N° Cliente</td>
				<td>N° Manifiesto</td>
				<td>Recoleccion a Domicilio</td>
				<td>Fecha Llegada</td>
				<td>Remitente</td>
				<td>Ciudad</td>
				<td>Estado</td>
				<td>Etiq.</td>
			</tr>
		</thead>
		<tbody>
			<tr valign="center" align="center"> 
				<td>&nbsp;<%=wel_cliclef%></td>
				<td id="wel_manif_num_view">&nbsp;<%=wel_manif_num%></td>
				<td>&nbsp;
					<%if NVL(wel_fecha_recoleccion) = "" then
						Response.Write "No"
						welrecol_domicilio = "N"
					else
						Response.Write "Si: " & wel_fecha_recoleccion
						welrecol_domicilio = "S"
					end if%>
				</td>
				<td>&nbsp;<%=wel_manif_fecha%></td>
				<td>&nbsp;<%=disnom%></td>
				<td>&nbsp;<%=dis_ville%></td>
				<td>&nbsp;<%=dis_estado%></td>
				<td>&nbsp;<a href='javascript:imprimirEtiquetas($("#wel_manif_num_view").text(), "S")' class="escondido" id="print_etiquetas_manif"><img src='./images/label.gif' style='border:none; cursor:pointer;' alt='Imprimir etiquetas'></a> </td>
			</tr>  
		</tbody>
	</table>
	<br>
	<br>

	<table class="datos" id="ltl_datos" align="center" BORDER="1" cellpadding="2" cellspacing="0" width="800">
		<thead>
			<tr class="titulo_trading_bold" valign="center" align="center"> 
				<td title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n">NUI</td>
				<td>N° Talon</td>
				<td>Cdad Bultos</td>
				<td>Destinatario</td>
				<td>Ciudad (estado)</td>
				<td>Cedis Dest</td>
				<td>Tipo</td>
				<td>Acciones</td>
				<td>Status</td>
			</tr>
		</thead>
		<tbody>
			<% arrayLTL = ""
			
			if NVL(wel_manif_num) <> "" then
				SQL = " SELECT WELCLAVE " & VbCrlf
				SQL = SQL & "   , TO_CHAR(WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL_CLICLEF) " & VbCrlf
				SQL = SQL & "   , WEL_CDAD_BULTOS " & VbCrlf
				SQL = SQL & "   , WEL_MANIF_NUM " & VbCrlf
				SQL = SQL & "   , InitCap(WCCL_NOMBRE) " & VbCrlf
				SQL = SQL & "   , InitCap(VILNOM) " & VbCrlf
				SQL = SQL & "   , InitCap(ESTNOMBRE) " & VbCrlf
				SQL = SQL & "   , DECODE(WEL_COLLECT_PREPAID, 'PREPAGADO', 'Prep', 'COD') " & VbCrlf
				SQL = SQL & "   , ALLCODIGO " & vbCrLf 
				SQL = SQL & "   , WELSTATUS " & vbCrLf 
				SQL = SQL & " FROM WEB_LTL " & VbCrlf
				SQL = SQL & "   , WEB_CLIENT_CLIENTE " & VbCrlf
				SQL = SQL & "   , ECIUDADES " & VbCrlf
				SQL = SQL & "   , EESTADOS " & VbCrlf
				SQL = SQL & "   , EALMACENES_LOGIS " & VbCrlf
				SQL = SQL & " WHERE WEL_MANIF_NUM =  " & wel_manif_num  & VbCrlf
				SQL = SQL & "   AND WEL_CLICLEF = " & wel_cliclef & VbCrlf
				SQL = SQL & "   AND WCCLCLAVE = WEL_WCCLCLAVE " & VbCrlf
				SQL = SQL & "   AND VILCLEF = WCCL_VILLE " & VbCrlf
				SQL = SQL & "   AND ESTESTADO = VIL_ESTESTADO " & vbCrLf
				SQL = SQL & "   AND ALLCLAVE = WEL_ALLCLAVE_DEST "


				SQL = SQL & " UNION "


				SQL = SQL & " SELECT WELCLAVE " & VbCrlf
				SQL = SQL & "   , TO_CHAR(WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL_CLICLEF) " & VbCrlf
				SQL = SQL & "   , WEL_CDAD_BULTOS " & VbCrlf
				SQL = SQL & "   , WEL_MANIF_NUM " & VbCrlf
				SQL = SQL & "   , InitCap(DIENOMBRE) " & VbCrlf
				SQL = SQL & "   , InitCap(VILNOM) " & VbCrlf
				SQL = SQL & "   , InitCap(ESTNOMBRE) " & VbCrlf
				SQL = SQL & "   , DECODE(WEL_COLLECT_PREPAID, 'PREPAGADO', 'Prep', 'COD') " & VbCrlf
				SQL = SQL & "   , ALLCODIGO " & vbCrLf 
				SQL = SQL & "   , WELSTATUS " & vbCrLf 
				SQL = SQL & " FROM WEB_LTL " & VbCrlf
				SQL = SQL & "   , EDIRECCIONES_ENTREGA " & VbCrlf
				SQL = SQL & "   , ECIUDADES " & VbCrlf
				SQL = SQL & "   , EESTADOS " & VbCrlf
				SQL = SQL & "   , EALMACENES_LOGIS " & VbCrlf
				SQL = SQL & " WHERE WEL_MANIF_NUM =  " & wel_manif_num  & VbCrlf
				SQL = SQL & "   AND WEL_CLICLEF = " & wel_cliclef & VbCrlf
				SQL = SQL & "   AND DIECLAVE = WEL_DIECLAVE " & VbCrlf
				SQL = SQL & "  AND DIE_STATUS = 1 " & VbCrlf    
				SQL = SQL & "   AND VILCLEF = DIEVILLE " & VbCrlf
				SQL = SQL & "   AND ESTESTADO = VIL_ESTESTADO " & vbCrLf
				SQL = SQL & "   AND ALLCLAVE = WEL_ALLCLAVE_DEST "    

				arrayLTL = GetArrayRS(SQL)
			end if
			if IsArray(arrayLTL) then
				for i = 0 to UBound(arrayLTL, 2)%>
					<tr valign='center' align='center'>
						<td><%=arrayLTL(0, i)%></td>
						<td><%=arrayLTL(1, i)%></td>
						<td><%=arrayLTL(2, i)%></td>
						<td><%=arrayLTL(4, i)%></td>
						<td><%=arrayLTL(5, i)%> (<%=arrayLTL(6, i)%>)</td>
						<td><%=arrayLTL(8, i)%></td>
						<td><%=arrayLTL(7, i)%></td>
						<td><a href='javascript:imprimirEtiquetas(<%=arrayLTL(0, i)%>)'><img src='./images/label.gif' style='border:none; cursor:pointer;' alt='Imprimir etiquetas'></a> </td>
						<%
						status = ""
						status_color = ""
						if arrayLTL(9, i) = "1" then
							status = "Act"
							status_color = "verde"
						elseif arrayLTL(9, i) = "2" then 
							status = "StdBy"
							status_color = "naranja"
						end if
						%>
						<td class="<%=status_color%>">
							<%=status%>
						</td>
					</tr>  
				<%next
			end if
			%>
		</tbody>
	</table>
	<br>
	<br>


	<% 
	SQL = "select sign(to_date(logis.fec_ini_die_ltl(),'dd/mm/yy')-sysdate) from dual" & vbCrLf
	array_tmp = GetArrayRS(SQL)
	cambia_ciudad = array_tmp(0,0)

	'? ***
	'cancelar la insercion de registro de tracking SQL

	if cambia_ciudad = "666" then  ' a remettre a 1'

	%>

		<script type="text/javascript"> 
			// wait for the DOM to be loaded 
			$(document).ready(function() { 
				// bind 'myForm' and provide a simple callback function 
				$('#ltl_form').ajaxForm({ 
					beforeSubmit:  validarForm,
					dataType:  'json', 
					success:   processJson,
					error: processError,
					timeout: 50000
				}); 
				$('#destinatario_restrict').focus();
				//$('#add_wcclclave').click(load_wcclclave);
				$("#throbber_wel").hide();
			}); 

			function validarForm(formData, jqForm, options) { 
			// jqForm is a jQuery object which wraps the form DOM element 
			// 
			// To validate, we can access the DOM elements directly and return true 
			// only if the values of both the username and password fields evaluate 
			// to true 

				var form = jqForm[0]; 
				if (!form.wel_wcclclave.value || !form.wel_cdad_bultos.value || isNaN(form.wel_cdad_bultos.value)) { 
					alert('Favor de capturar un destinatario y una cantidad de bultos.'); 
				return false; 
				}
				$("#button_guardar_ltl").attr("disabled", "disabled");
				$("#button_guardar_ltl").val("Guardando...");
				$("#throbber_wel").show();
			}

			function processError(msg, url, line) {
				//alert('Hubo un error.');
				resetForm();
			}

			function processJson(data) { 
				//insertamos el talon creado
				if (data.error != '') {
					alert(data.error);
				} else {
                    
					$("#ltl_datos").append
						
						("<tr valign='center' align='center'>"
                        + "<td>" + data.welclave + "</td>"
						+  "<td>" + data.talon + "</td>"
						+  "<td>" + data.wel_cdad_bultos + "</td>"
						+  "<td>" + data.wcclnombre + "</td>" 
						+  "<td>" + data.wccl_vil + " (" + data.wccl_est + ")</td>"
						+  "<td>" + data.wel_allclave_dest + "</td>" 
						+  "<td>" + data.wel_collect_prepaid + "</td>" 
						+  "<td><a href='javascript:imprimirEtiquetas(" + data.welclave + ")'><img src='./images/label.gif' style='border:none; cursor:pointer;' alt='Imprimir etiquetas'></a> </td>"
						+  "<td class='" + data.welstatus_color + "'>" + data.welstatus + "</td>"
						+  "</tr>"
					);
					
					$("#welClave").val(data.iFolioSiguiente);
					$("#wel_manif_num").val(data.wel_manif_num);
					$("#wel_manif_num_view").text(data.wel_manif_num);
					$("#print_etiquetas_manif").show();
				}
				//restablecer los controls
				resetForm();
			}

			function resetForm() {
				$("#button_guardar_ltl").attr("disabled", "");
				$("#button_guardar_ltl").val("Guardar");
				$("#throbber_wel").hide();
				$("#button_guardar_ltl").val("Guardar");

				$('#destinatario_restrict').val('');
				$('#wel_cdad_bultos').val('');
				$('#wel_collect_prepaid').selectOptions('PREPAGADO');
				f32_FillSel(document.getElementById("destinatario_restrict"),'wel_wcclclave');
				$('#destinatario_restrict').focus();
			}

			function imprimirEtiquetas(id, manif) {
				var etiq = window.open('ltl_etiquetas_print<%=qa%>.asp?popup=si&tipo=zebra&id=' + id + '&manif=' + manif, '','resizable=yes, location=no, width=200, height=100, menubar=no, status=no, scrollbars=no, menubar=no');
			}

			function f32_FillSel(f32_tb,f32_id){
				f32_tv=f32_tb.value.toLowerCase();
				f32_id=document.getElementById(f32_id);
				if (!f32_id.ary){
					f32_id.sary=new Array();
					f32_id.ary=new Array();
					for (f32_0=0;f32_0<f32_id.options.length;f32_0++){
						f32_id.ary[f32_0]=[f32_id.options[f32_0].text,f32_id.options[f32_0].value];
					}
				}
				f32_ary=new Array();
				for (f32_0=0;f32_0<f32_id.ary.length;f32_0++){
					if (f32_id.ary[f32_0][0].toLowerCase().match( f32_tv)){
						//&&f32_tv!=''&&f32_tv!=' '
						f32_ary[f32_ary.length]=f32_id.ary[f32_0];
					}
				}
				f32_id.options.length=0;
				if (f32_id.sary!=f32_ary){
					for (f32_1=0;f32_1<f32_ary.length;f32_1++){
						f32_id.options[f32_id.options.length]=new Option(f32_ary[f32_1][0],f32_ary[f32_1][1],true,true);
					}
				}
				f32_id.selectedIndex=0;
				f32_id.sary=f32_ary;
				f32_tb.focus();
			}
        </script> 

		<script language="JavaScript" type="text/javascript">
			//scripts para cargar el form del nuevo destinatario
			function load_wcclclave(event) {
				event.preventDefault();
				if ($('#wccl_form').html() == null) {
					$('#new_wcclclave').load('ltl_destinatarios_captura<%=qa%>.asp?json=ok #wccl_form', activate_wccl);
				} else {
					$('#wccl_form').show();
				}
			}

			function activate_wccl() {
				var dol = new DynamicOptionList();
				dol.addDependentFields("estado","wccl_ville");
				dol.setFormName("wccl_form");
				<%
				''consulta solo ciudades con CEDIS asociados
				SQL = " SELECT /*+ordered index(EST I_EST_PAYCLEF) index(CIU I_VIL_ESTESTADO) index(DER IDX_DER_VILCLEF) use_nl(EST CIU DER)*/ EST.ESTESTADO "  & VbCrlf
				SQL = SQL &  "   , InitCap(EST.ESTNOMBRE) "  & VbCrlf
				SQL = SQL &  "   , CIU.VILCLEF "  & VbCrlf
				SQL = SQL &  "   , InitCap(CIU.VILNOM) "  & VbCrlf
				SQL = SQL &  "  FROM EESTADOS EST "  & VbCrlf
				SQL = SQL &  "   , ECIUDADES CIU  "  & VbCrlf
				SQL = SQL &  "   , edestinos_por_ruta der"  & VbCrlf
				SQL = SQL &  "  WHERE EST.EST_PAYCLEF = 'N3' "  & VbCrlf
				SQL = SQL &  "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO  "  & VbCrlf
				SQL = SQL &  "   and der.DER_VILCLEF = ciu.VILCLEF "  & VbCrlf
				SQL = SQL &  "   and nvl(der.DER_TIPO_ENTREGA, 'FORANEO 6') <> 'FORANEO 6' "  & VbCrlf
				SQL = SQL &  "   and der_allclave > 0  "  & VbCrlf
				SQL = SQL &  "   ORDER BY CIU.VILNOM"    	
				array_tmp = GetArrayRS(SQL)
					
				for i = 0 to Ubound(array_tmp,2)
					Response.Write "dol.forValue("""& array_tmp(0,i) & """).addOptionsTextValue(""" & array_tmp(3,i) & """,""" & array_tmp(2,i) & """);" & vbTab  & vbCrLf
				next
				%>
				initDynamicOptionLists();
				$('#tabla_wccl').attr('width', '100%');
				$('#wccl_form').removeAttr('onsubmit');
				$('#validar').val('validar');
				$('#json').val('ok');
				$('#btn_validar_wccl').val('Guardar');
				$("#btn_validar_wccl").after('<img src="images/Throbber-mac.gif" id="throbber_wccl" style="margin-bottom: -2px;margin-left: 2px">');
				$("#throbber_wccl").hide();

				$('#wccl_form').ajaxForm({ 
					beforeSubmit:  validarWcclForm,
					dataType:  'json', 
					success:   processWcclJson,
					error: processWcclError,
					timeout: 50000
				}); 
			}

			function validarWcclForm(formData, jqForm, options) { 
				// jqForm is a jQuery object which wraps the form DOM element 
				// 
				// To validate, we can access the DOM elements directly and return true 
				// only if the values of both the username and password fields evaluate 
				// to true 

				var form = jqForm[0]; 
				if (!form.wccl_nombre.value || !form.wccl_adresse1.value) { 
					alert('Favor de capturar el nombre y la calle.'); 
					return false; 
				}
				if (form.wccl_rfc.value != '' && (!isRFC(form.wccl_rfc.value) || form.wccl_rfc.value.length < 12)) {
					alert('Favor de capturar un RFC correcto.');
					return false;
				}
				$("#btn_validar_wccl").attr("disabled", "disabled");
				$("#btn_validar_wccl").val("Guardando...");
				$("#throbber_wccl").show();
			}

			function isRFC(sText) {
				var ValidChars = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
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

			function processWcclError(msg, url, line) {
				alert('Hubo un error al guardar el destinatario.');
				resetWcclForm();
			}

			function processWcclJson(data) { 
				//insertamos el talon creado
				$("#wel_wcclclave").addOption(data.wcclclave, data.wcclnombre);

				//restablecer los controls
				resetWcclForm();
			}

			function resetWcclForm() {
				$("#btn_validar_wccl").attr("disabled", "");
				$("#btn_validar_wccl").val("Guardar");
				$("#throbber_wccl").hide();
				$('#wccl_form').resetForm();
				$('#wel_cdad_bultos').focus();
				$('#wccl_form').hide();    
			}
		</script>

		<div style="width: 700px; margin-left:auto; margin-right: auto; border: thin solid red; text-align:left">
			<div class="titulo_trading_bold" style="width: 694px; text-align:left; padding: 3px; margin-bottom:5px">Nuevo talon:</div>
			<%Randomize%>
			<form id="ltl_form" name="ltl_form" action="ltl_captura_encabezado_process<%=qa%>.asp?q=<%=Rnd%>" method="post">

				
				Destinatario: 
				<input type="text" id="destinatario_restrict" class="light" size="20" onkeyup="f32_FillSel(this,'wel_wcclclave');"> <i>(Criterio de restriccion)</i>
				<br>
				<%SQL = "SELECT /*+ ORDERED USE_NL(WCCL CIU DER EST) */ WCCL.WCCLCLAVE   " & VbCrlf
				SQL = SQL & "    , INITCAP(WCCL.WCCL_NOMBRE || DECODE(replace(WCCLABREVIACION, WCCL_NOMBRE, null), NULL, NULL, ' (' || replace(WCCLABREVIACION, WCCL_NOMBRE, null) || ')') || ' - ' || WCCL_ADRESSE1 || ' '  || WCCL_NUMEXT || ' ' || WCCL_NUMINT || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')')"
				SQL = SQL & "    , NVL(DER.DER_ALLCLAVE, 1)  " & VbCrlf
				SQL = SQL & "    FROM WEB_CLIENT_CLIENTE WCCL   " & VbCrlf
				SQL = SQL & "    , ECIUDADES CIU    " & VbCrlf
				SQL = SQL & "    , EESTADOS EST    " & VbCrlf
				SQL = SQL & "    , EDESTINOS_POR_RUTA DER  " & VbCrlf
				SQL = SQL & "    WHERE WCCL.WCCL_CLICLEF IN ("& print_clinum &")   " & VbCrlf
				SQL = SQL & "    AND CIU.VILCLEF = WCCL.WCCL_VILLE   " & VbCrlf
				SQL = SQL & "    AND EST.ESTESTADO = CIU.VIL_ESTESTADO    " & VbCrlf
				SQL = SQL & "    AND EST.EST_PAYCLEF = 'N3'    " & VbCrlf
				SQL = SQL & "    AND WCCL.WCCL_STATUS = 1  " & VbCrlf
				SQL = SQL & "    AND DER.DER_VILCLEF = WCCL_VILLE  " & VbCrlf
				SQL = SQL & "    AND DER.DER_ALLCLAVE > 0 " & VbCrlf
				SQL = SQL & "    AND DER.DER_TIPO_ENTREGA <> 'FORANEO 6' " & VbCrlf
				SQL = SQL & "    ORDER BY 2"
				array_tmp = GetArrayRS(SQL)
				if IsArray(array_tmp) then
					%><select id="wel_wcclclave" name="wel_wcclclave" class="light" style="width: 690px"><%
						For i = 0 to Ubound(array_tmp,2)
							Response.Write "<option value="""& array_tmp(0,i) & "|" & array_tmp(2,i) &""">" & array_tmp(1,i) & vbCrLf & vbTab 
						Next
					%></select><%
				else
					Response.Write "<font color=""red"">No hay destinatarios.</font>"	', favor de capturar los
				end if
				%>
				&nbsp;&nbsp;&nbsp;
				Cdad Bultos
				<input type="text" class="light" id="wel_cdad_bultos" name="wel_cdad_bultos" size="10" maxlength="12">&nbsp;&nbsp;&nbsp;
				<!--Entrega a domicilio
				<input type="checkbox" class="light" id="welentrega_domicilio" name="welentrega_domicilio" value="S"> 
				-->
				<select id="wel_collect_prepaid" name="wel_collect_prepaid" class="light">
					<option value="PREPAGADO">Prepagado
					<option value="POR COBRAR">Por Cobrar
				</select>
				
				<input type="hidden" name="wel_manif_num" id="wel_manif_num" value="<%=wel_manif_num%>">
				<input type="hidden" name="wel_manif_fecha" id="wel_manif_fecha" value="<%=wel_manif_fecha%>">
				<input type="hidden" name="wel_fecha_recoleccion" id="wel_fecha_recoleccion" value="<%=wel_fecha_recoleccion%>">
				<input type="hidden" name="welrecol_domicilio" id="welrecol_domicilio" value="<%=welrecol_domicilio%>">
				<input type="hidden" name="wel_allclave_ori" id="wel_allclave_ori" value="<%=wel_allclave_ori%>">
				<input type="hidden" name="wel_disclef" id="wel_disclef" value="<%=wel_disclef%>">
				<input type="hidden" name="wel_cliclef" id="wel_cliclef" value="<%=wel_cliclef%>">
				<input type="hidden" name="corte" id="corte" value="<%=Request("corte")%>">

				<input type="submit" id="button_guardar_ltl" value="Guardar" class="button_trading" style="margin-bottom: 2px"/>
				<img src="images/Throbber-mac.gif" id="throbber_wel" class="escondido" style="margin-bottom: -2px">
				<br />
				<% ' <a href="#" id="add_wcclclave">Agregar un destinatario</a> %>
			</form>
			<div id="new_wcclclave"></div>
		</div>

		<script language="JavaScript">
			<!--
			//tigra_tables('ltl_datos', 1, 0, '#ffffff', '#ffffcc', '#ffcc66', '#cccccc');
			// -->
		</script>
	</BODY>
	</HTML>

<%
	else
%>
		<script type="text/javascript"> 
			// wait for the DOM to be loaded 
			$(document).ready(function() { 
			// bind 'myForm' and provide a simple callback function 
				$('#ltl_form').ajaxForm({ 
					beforeSubmit:  validarForm,
					dataType:  'json', 
					success:   processJson,
					error: processError,
					timeout: 50000
				}); 
				$('#destinatario_restrict').focus();
				$('#add_dieclave').click(load_dieclave);
				$("#throbber_wel").hide();
			}); 

			function validarForm(formData, jqForm, options) { 
				// jqForm is a jQuery object which wraps the form DOM element 
				// 
				// To validate, we can access the DOM elements directly and return true 
				// only if the values of both the username and password fields evaluate 
				// to true 

				var form = jqForm[0]; 
				if (!form.wel_dieclave.value || !form.wel_cdad_bultos.value || isNaN(form.wel_cdad_bultos.value)) { 
					alert('Favor de capturar un destinatario y una cantidad de bultos.'); 
					return false; 
				}
				$("#button_guardar_ltl").attr("disabled", "disabled");
				$("#button_guardar_ltl").val("Guardando...");
				$("#throbber_wel").show();
			}
			
			function processError(msg, url, line) {
				alert('Hubo un error.');
				resetForm();
			}

			function processJson(data) { 
				//insertamos el talon creado
				if (data.error != '') {
					alert(data.error);
				} else {
					$("#ltl_datos").append("<tr valign='center' align='center'>"
                        + "<td>" + data.welclave + "</td>"
						+  "<td>" + data.talon + "</td>"
						+  "<td>" + data.wel_cdad_bultos + "</td>"
						+  "<td>" + data.dienombre + "</td>" 
						+  "<td>" + data.dievil + " (" + data.dieest + ")</td>"
						+  "<td>" + data.wel_allclave_dest + "</td>" 
						+  "<td>" + data.wel_collect_prepaid + "</td>" 
						+  "<td><a href='javascript:imprimirEtiquetas(" + data.welclave + ")'><img src='./images/label.gif' style='border:none; cursor:pointer;' alt='Imprimir etiquetas'></a> </td>"
						+  "<td class='" + data.welstatus_color + "'>" + data.welstatus + "</td>"
						+  "</tr>"
					);
					
					$("#welClave").val(data.iFolioSiguiente);
					$("#wel_manif_num").val(data.wel_manif_num);
					$("#wel_manif_num_view").text(data.wel_manif_num);
					$("#print_etiquetas_manif").show();
				}

				//restablecer los controls
				resetForm();
			}

			function resetForm() {
				$("#button_guardar_ltl").attr("disabled", "");
				$("#button_guardar_ltl").val("Guardar");
				$("#throbber_wel").hide();
				$("#button_guardar_ltl").val("Guardar");

				$('#destinatario_restrict').val('');
				$('#wel_cdad_bultos').val('');
				$('#wel_collect_prepaid').selectOptions('PREPAGADO');
				f32_FillSel(document.getElementById("destinatario_restrict"),'wel_dieclave');
				$('#destinatario_restrict').focus();
			}

			function imprimirEtiquetas(id, manif) {
				var etiq = window.open('ltl_etiquetas_print<%=qa%>.asp?popup=si&tipo=zebra&id=' + id + '&manif=' + manif, '','resizable=yes, location=no, width=200, height=100, menubar=no, status=no, scrollbars=no, menubar=no');
			}

			function f32_FillSel(f32_tb,f32_id){
				f32_tv=f32_tb.value.toLowerCase();
				f32_id=document.getElementById(f32_id);
				if (!f32_id.ary){
					f32_id.sary=new Array();
					f32_id.ary=new Array();
					for (f32_0=0;f32_0<f32_id.options.length;f32_0++){
						f32_id.ary[f32_0]=[f32_id.options[f32_0].text,f32_id.options[f32_0].value];
					}
				}
				f32_ary=new Array();
				for (f32_0=0;f32_0<f32_id.ary.length;f32_0++){
					if (f32_id.ary[f32_0][0].toLowerCase().match( f32_tv)){
						//&&f32_tv!=''&&f32_tv!=' '
						f32_ary[f32_ary.length]=f32_id.ary[f32_0];
					}
				}
				f32_id.options.length=0;
				if (f32_id.sary!=f32_ary){
					for (f32_1=0;f32_1<f32_ary.length;f32_1++){
						f32_id.options[f32_id.options.length]=new Option(f32_ary[f32_1][0],f32_ary[f32_1][1],true,true);
					}	
				}
				f32_id.selectedIndex=0;
				f32_id.sary=f32_ary;
				f32_tb.focus();
			}
        </script> 

		<script language="JavaScript" type="text/javascript">
			//scripts para cargar el form del nuevo destinatario
			function load_dieclave(event) {
				event.preventDefault();
				if ($('#wccl_form').html() == null) {
					$('#new_dieclave').load('ltl_destinatarios_captura<%=qa%>.asp?json=ok #wccl_form', activate_wccl);
				} else {
					$('#wccl_form').show();
				}
			}

			function activate_wccl() {
				var dol = new DynamicOptionList();
				dol.addDependentFields("estado","dieville");
				dol.setFormName("wccl_form");
				
				<%
					''consulta solo ciudades con CEDIS asociados
					SQL = " SELECT /*+ordered index(EST I_EST_PAYCLEF) index(CIU I_VIL_ESTESTADO) index(DER IDX_DER_VILCLEF) use_nl(EST CIU DER)*/ EST.ESTESTADO "  & VbCrlf
					SQL = SQL &  "   , InitCap(EST.ESTNOMBRE) "  & VbCrlf
					SQL = SQL &  "   , CIU.VILCLEF "  & VbCrlf
					SQL = SQL &  "   , InitCap(CIU.VILNOM) "  & VbCrlf
					SQL = SQL &  "  FROM EESTADOS EST "  & VbCrlf
					SQL = SQL &  "   , ECIUDADES CIU  "  & VbCrlf
					SQL = SQL &  "   , edestinos_por_ruta der"  & VbCrlf
					SQL = SQL &  "  WHERE EST.EST_PAYCLEF = 'N3' "  & VbCrlf
					SQL = SQL &  "   AND EST.ESTESTADO = CIU.VIL_ESTESTADO  "  & VbCrlf
					SQL = SQL &  "   and der.DER_VILCLEF = ciu.VILCLEF "  & VbCrlf
					SQL = SQL &  "   and nvl(der.DER_TIPO_ENTREGA, 'FORANEO 6') <> 'FORANEO 6' "  & VbCrlf
					SQL = SQL &  "   and der_allclave > 0  "  & VbCrlf
					SQL = SQL &  "   ORDER BY CIU.VILNOM"     
					array_tmp = GetArrayRS(SQL)
					
					for i = 0 to Ubound(array_tmp,2)
						Response.Write "dol.forValue("""& array_tmp(0,i) & """).addOptionsTextValue(""" & array_tmp(3,i) & """,""" & array_tmp(2,i) & """);" & vbTab  & vbCrLf
					next
				%>
				initDynamicOptionLists();
				$('#tabla_wccl').attr('width', '100%');
				$('#wccl_form').removeAttr('onsubmit');
				$('#validar').val('validar');
				$('#json').val('ok');
				$('#btn_validar_wccl').val('Guardar');
				$("#btn_validar_wccl").after('<img src="images/Throbber-mac.gif" id="throbber_wccl" style="margin-bottom: -2px;margin-left: 2px">');
				$("#throbber_wccl").hide();

				$('#wccl_form').ajaxForm({ 
					beforeSubmit:  validarWcclForm,
					dataType:  'json', 
					success:   processWcclJson,
					error: processWcclError,
					timeout: 50000
				}); 
			}

			function validarWcclForm(formData, jqForm, options) { 
				// jqForm is a jQuery object which wraps the form DOM element 
				// 
				// To validate, we can access the DOM elements directly and return true 
				// only if the values of both the username and password fields evaluate 
				// to true 

				var form = jqForm[0]; 
				if (!form.dienombre.value || !form.dieadresse1.value) { 
					alert('Favor de capturar el nombre y la calle.'); 
					return false; 
				}
				if (form.die_rfc.value != '' && (!isRFC(form.die_rfc.value) || form.die_rfc.value.length < 12)) {
					alert('Favor de capturar un RFC correcto.');
					return false;
				}
				$("#btn_validar_wccl").attr("disabled", "disabled");
				$("#btn_validar_wccl").val("Guardando...");
				$("#throbber_wccl").show();
			}

			function isRFC(sText) {
				var ValidChars = "1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ";
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

			function processWcclError(msg, url, line) {
				alert('Hubo un error al guardar el destinatario.');
				resetWcclForm();
			}

			function processWcclJson(data) { 
				//insertamos el talon creado
				$("#wel_dieclave").addOption(data.dieclave, data.wcclnombre);

				//restablecer los controls
				resetWcclForm();
			}

			function resetWcclForm() {
				$("#btn_validar_wccl").attr("disabled", "");
				$("#btn_validar_wccl").val("Guardar");
				$("#throbber_wccl").hide();
				$('#wccl_form').resetForm();
				$('#wel_cdad_bultos').focus();
				$('#wccl_form').hide();    
			}
		</script>

		<div style="width: 700px; margin-left:auto; margin-right: auto; border: thin solid red; text-align:left">
			<div class="titulo_trading_bold" style="width: 694px; text-align:left; padding: 3px; margin-bottom:5px">Nuevo talon:</div>
			<%Randomize%>
			<form id="ltl_form" name="ltl_form" action="ltl_captura_encabezado_process<%=qa%>.asp?q=<%=Rnd%>" method="post">
				<span class="mandatory" title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n" style="padding-left: 10px;">NUI:</span>
				<input type="text" name="welClave" id="welClave" class="light disabled" readonly="readonly" size="35" maxlength="100" value="<%=iFolioSiguiente%>" title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n" />
				<br>
				<br>
				&nbsp;&nbsp;&nbsp;Destinatario:
				<br>
				<br>
				<script type="text/javascript">
					$(function() {
						$('#LE_ESTESTADO').change(function(){
						if (document.getElementById('ocurre_oficina').checked) {
							logis_filtro();
						} else{
								$.ajaxSetup({async: false})
								$('#LA_CIUDAD').load('ajax_ciudades.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());  
								$.ajaxSetup({async: true})
								con_filtro();
							};
						});
					});

					$(function() {
						$('#LA_CIUDAD').change(function(){
							con_filtro();
						});
					});

					function con_filtro() {
						$('#wel_dieclave').load('ajax_dest_con_filtro<%=qa%>.asp?LA_CIUDAD=' + $('#LA_CIUDAD').val() + '&destinatario_restrict=' + $('#destinatario_restrict').val());
					}

					function sin_filtro() {
						$('#wel_dieclave').load('ajax_dest<%=qa%>.asp?LA_CIUDAD=' + $('#LA_CIUDAD').val() + '&destinatario_restrict=' + $('#destinatario_restrict').val());
					}

					function logis_filtro() {
						$('#wel_dieclave').load('ajax_logis.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
					}

					function logis_sin_filtro() {
						$('#wel_dieclave').load('ajax_logis_completo.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
					}

					function calc() {
						if (document.getElementById('ocurre_oficina').checked) 
						{     
							document.getElementById("cache").style.display = "none";
							document.getElementById("LA_CIUDAD").style.display = "none";
							document.getElementById("btnListaCompleta").style.display = "none";
							document.getElementById("btnListaCompletaLogis").style.display = "block";
							document.getElementById("contacto").style.display = "block";
							
							logis_filtro();
							
						} else {
						
							document.getElementById("cache").style.display = "block";
							document.getElementById("LA_CIUDAD").style.display = "block";
							document.getElementById("btnListaCompleta").style.display = "block";
							document.getElementById("btnListaCompletaLogis").style.display = "none";
							document.getElementById("contacto").style.display = "none";

						}
					}
				</script> 

				<%  SQL = "SELECT  " & VbCrlf
				SQL = SQL & " DISTINCT estestado, EST.ESTNOMBRE  " & VbCrlf
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

				array_tmp = GetArrayRS(SQL) 
				If IsArray(array_tmp) Then
					%>
					&nbsp;&nbsp;&nbsp;<select name="LE_ESTESTADO" id="LE_ESTESTADO" class="light">
						<option> Estado </option>
						<%   
							For i = 0 To Ubound(array_tmp,2)
								Response.Write "<option value=""" & array_tmp(0,i) & """>"
								Response.Write array_tmp(1,i) & "</option>" & VbCrLf
							Next

						%>
					</select>
					<% 
				Else 
					Response.Write "<p>Something bad went wrong</p>"
				End If 
				%> 
				<div id="CIUDADES">
					&nbsp;&nbsp;&nbsp;<select name="LA_CIUDAD" id="LA_CIUDAD" class="light">
						<option> Ciudad </option>
					</select>

				</div>
				<br>
				&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Ocurre Logis
				<input type="checkbox" class="light" id="ocurre_oficina" name="ocure_oficina" value="S" onclick="calc();"> 
				&nbsp;&nbsp;
				<br>
				<p id="cache">
				&nbsp;&nbsp;&nbsp;Destinatario: 
				<input type="text" id="destinatario_restrict" class="light" size="20" onkeyup="con_filtro();"> <i>(Criterio de restriccion)</i>
				<div id="DESTINACION">
					&nbsp;&nbsp;&nbsp;<select name="wel_dieclave" id="wel_dieclave" class="light">
						<option> Destinatario </option>
					</select>
					&nbsp;&nbsp;&nbsp;<input type="button" name="btnListaCompletaLogis" id="btnListaCompletaLogis" value="lista completa" class="button_trading" onclick="javascript:logis_sin_filtro();">
					<br> 
					<br>					
					&nbsp;&nbsp;&nbsp;<input type="button" name="btnListaCompleta" id="btnListaCompleta" value="lista completa" class="button_trading" onclick="javascript:sin_filtro();">
					<br>
				</div>
				<div class="wrapper">
					</p>
					<p>
					&nbsp;&nbsp;&nbsp;Para agregar nuevo destinatario enviar un correo a <font color="blue">admin_destinatarios@logis.com.mx</font> y su ejecutivo de Atencion a Cliente
					</p>
					<p id="contacto">
						Contacto: 
						<input type="text" id="le_contacto" class="light" size="20"> 
					</p>
					
					<script>
						document.getElementById("contacto").style.display = "none";
						document.getElementById("btnListaCompletaLogis").style.display = "none";
					</script>

					&nbsp;&nbsp;&nbsp;
					Cdad Bultos
					<input type="text" class="light" id="wel_cdad_bultos" name="wel_cdad_bultos" size="10" maxlength="12">&nbsp;&nbsp;&nbsp;
					<!--Entrega a domicilio
					<input type="checkbox" class="light" id="welentrega_domicilio" name="welentrega_domicilio" value="S"> 
					-->
					<select id="wel_collect_prepaid" name="wel_collect_prepaid" class="light">
						<option value="PREPAGADO">Prepagado
						<option value="POR COBRAR">Por Cobrar
					</select>
					
					<input type="hidden" name="wel_manif_num" id="wel_manif_num" value="<%=wel_manif_num%>">
					<input type="hidden" name="wel_manif_fecha" id="wel_manif_fecha" value="<%=wel_manif_fecha%>">
					<input type="hidden" name="wel_fecha_recoleccion" id="wel_fecha_recoleccion" value="<%=wel_fecha_recoleccion%>">
					<input type="hidden" name="welrecol_domicilio" id="welrecol_domicilio" value="<%=welrecol_domicilio%>">
					<input type="hidden" name="wel_allclave_ori" id="wel_allclave_ori" value="<%=wel_allclave_ori%>">
					<input type="hidden" name="wel_disclef" id="wel_disclef" value="<%=wel_disclef%>">
					<input type="hidden" name="wel_cliclef" id="wel_cliclef" value="<%=wel_cliclef%>">
					<input type="hidden" name="corte" id="corte" value="<%=Request("corte")%>">

					<input type="submit" id="button_guardar_ltl" value="Guardar" class="button_trading" style="margin-bottom: 2px"/>
					<img src="images/Throbber-mac.gif" id="throbber_wel" class="escondido" style="margin-bottom: -2px">
					<br />
				</div>
			</form>
			<div id="new_dieclave"></div>
		</div>

		<script language="JavaScript">
			<!--
			//tigra_tables('ltl_datos', 1, 0, '#ffffff', '#ffffcc', '#ffcc66', '#cccccc');
			// -->
		</script>
		</BODY>
		</HTML>
<%
	end if
%>