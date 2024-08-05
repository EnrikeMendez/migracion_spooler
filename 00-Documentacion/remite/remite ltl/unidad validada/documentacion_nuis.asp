<%@ Language=VBScript %>
<% option explicit
%><!--#include file="include/include.asp"--><%

Response.Expires = 0
call check_session()

dim esTaCu
dim reco, sTalon
dim ConFactura, ConDocFuente
dim saldo_disponible, saldo_clase
dim script_include, style_include
dim num_client, nom_client, clef, i
dim welfactura, hdn_welfactura, welimporte
dim mi_traclave, mi_dxpclave, mi_distclave
dim iCCOClave, iCveEmpresa, iFolioSiguiente
dim wel_manif_num, wel_manif_corte, wel_manif_fecha
dim disnom, dis_ville, dis_estado, disclef, dis_vilclef
dim hacer_corte, forzar_remisiones, verPeso, cambia_ciudad
dim SQL, sqlTalon, sqlSeguro, sqlCveEmpresa, sqlFolioSiguiente
dim wel_allclave_ori, welrecol_domicilio, wel_disclef, wel_fecha_recoleccion, wel_cliclef
dim arrTalon, arrSeguro, array_recol, arrCveEmpresa, arrFolioSiguiente, arrayLTL, array_tmp, arraySMO, arrNum

'Variables que requieren ser inicializadas:
esTaCu = 0
welimporte = 0
mi_distclave = ""
ConFactura = false
ConDocFuente = false

'if Request.QueryString("f") = "S" then
'	ConFactura = true
'else
'	ConFactura = false
'end if


'Se obtiene el numero de cliente con el que se va a trabajar:
for each clef  in Request.Form
	if Left(clef,6) = "client" then
		num_client = num_client & "," & Request.Form(clef)
	end if	
next
num_client = mid(num_client,2) 'on enleve la virgule superflue
if num_client = "" then
	num_client = Session("array_client")(2,0)
end if


'Se valida si el cliente tiene configurada una tarifa por caja:
if es_tarifa_por_caja(num_client) = true then
	ConFactura = true
end if

'Se valida si el cliente tiene configurado el Tipo de Tarifa 4 (Solo Tarimas):
if es_tarifa_cuatro(num_client) = true then
	esTaCu = 1
else
	esTaCu = 0
end if


' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
'  Estas validaciones se mantienen en tiempo de pruebas     '
'  hasta que se defina por completo la regla para designar  '
'  las cuentas que documentar�n Con Factura o Sin Factura.  '
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
if es_captura_con_factura(num_client) = true then
	ConFactura = true
elseif es_captura_sin_factura(num_client) = true then
	ConFactura = false
end if


'<<20240103: La validaci�n de captura con documento fuente ya no depender� de la captura con factura:
'if ConFactura = true then
	'Se agrega validaci�n para saber si el cliente est� configurado para docmuentar NUI's con Documento Fuente:
		if es_captura_con_doc_fuente(num_client) = true then
			ConDocFuente = true
		end if
'end if
'  20240103>>

''''''''''''''''Pruebas
'''''''''''''''ConFactura = true
'''''''''''''''ConDocFuente = true


'Se obtiene la Razon Social del Cliente:
nom_client = obtener_razon_social_cte(num_client)


'Se obtiene el numero de Recoleccion:
reco = Request.Form("reco")

'Se obtiene el siguiente NUI disponible / apartado:
arrFolioSiguiente = obtener_nui_disponible_cliente(num_client)

'Se obtiene la Clave de Empresa por Cliente:
iCveEmpresa = obtener_clave_empresa(num_client)
	
'Se valida si el cliente tiene registrado un concepto por seguro:
iCCOClave = cliente_con_seguro(num_client)

'Se obtiene el remitente:
array_tmp = obtener_distribuidor(print_clinum)
if IsArray(array_tmp) then
	mi_distclave = array_tmp(0,0)
end if

'verificaciones del numero de recoleccion (oper5359_ELEC)
if Request.Form("num_recol") <> "" then
	array_tmp = obtener_distribuidor(print_clinum)
	
	if IsArray(array_tmp) then
		mi_distclave = array_tmp(0,0)
		
		array_recol = validar_numero_recoleccion(array_tmp(0,0),SQLEscape(Request.Form("num_recol")))
	end if
	
	if not IsArray(array_recol) then
		Response.Redirect "ltl_consulta.asp?msg=" & Server.URLEncode("No existe este numero de operacion de recoleccion, o no es de este cliente, o es de otro cedis! [0x000001]")
	else
		mi_traclave = array_recol(0, 0)
	end if
	
	if (array_recol(1, 0) <> "5" and array_recol(1, 0) <> "6") then
		Response.Redirect "ltl_consulta.asp?msg=" & Server.URLEncode("Esta recoleccion no fue dada de alta como siendo una recoleccion de Cross Dock/LTL, no puede servir para hacer esta entrada! [0x000002]")
	end if
		
	array_recol = validar_expedicion_recoleccion(mi_traclave)
		
	if not IsArray(array_recol) then
		Response.Redirect "ltl_consulta.asp?msg=" & Server.URLEncode("Esta recoleccion no se ha puesto en una expedicion de tipo RECOLECCION todavia! [0x000003]")
	end if
	
	mi_dxpclave = array_recol(0, 0)
		
	array_recol = cdad_entradas_recoleccion(mi_dxpclave)
	
	if CInt(array_recol(0,0)) > 0 then
		Response.Redirect "ltl_consulta.asp?msg=" & Server.URLEncode("Con esta recoleccion ya se ha hecho una entrada. No puede servir para esta operacion! [0x000004]")
	end if
	
	if CInt(array_recol(0,0)) > 0 then
		Response.Redirect "ltl_consulta.asp?msg=" & Server.URLEncode("Esta recoleccion esta asociada en otro manifiesto! [0x000005]")
	end if 
end if

script_include	=	"<script language=""JavaScript"" src=""include/js/jquery-1.2.3.js""></script>" & vbCrLf & _
					"<script language=""JavaScript"" src=""include/js/jquery.form.js""></script>" & vbCrLf & _
					"<script language=""JavaScript"" src=""include/js/jquery-select.js""></script>" & vbCrLf & _
					"<script language=""javascript"" src=""include/js/DynamicOptionList.js"" type=""text/javascript""></script>" & vbCrLf & _
					"<script language=""JavaScript"" src=""include/js/functions.js?v=1.3""></script>" & vbCrLf
script_include = script_include &	"<!-- main calendar program -->"	&	vbCrLf	& _
									"<script type=""text/javascript"" src=""include/jscalendar/calendar.js""></script>"	&	vbCrLf	& _
									"<!-- language for the calendar -->"	&	vbCrLf	& _
									"<script type=""text/javascript"" src=""include/jscalendar/lang/calendar-es.js""></script>"	&	vbCrLf	& _
									"<!-- the following script defines the Calendar.setup helper function, which makes"	&	vbCrLf	& _
									"      adding a calendar a matter of 1 or 2 lines of code. -->"	&	vbCrLf	& _
									"<script type=""text/javascript"" src=""include/jscalendar/calendar-setup.js""></script>"	&	vbCrLf
					

style_include	=	"<link href='include/css/logis_style.css' media='all' type='text/css' rel='stylesheet' />" & vbCrLf & _
					"<!-- calendar stylesheet -->" & vbCrLf & _
					"<link rel=""stylesheet"" type=""text/css"" media=""all"" href=""include/jscalendar/skins/aqua/theme.css"" title=""Aqua"" />" & vbCrLf

Response.Write print_headers_nocache("Documentacion de NUI", "ltl", script_include, style_include, "ObtenerURI();")
%>
	<script type="text/javascript"> 
		var esTaCu = <%= esTaCu %>;  // recibe la variable de vb al script y se usa cuando carga el formulario -- pclp --
		
		$(document).ready(function ()
			{
				<%
					response.write "/*" & esTaCu & "*/"
					
					if esTaCu = 1 then
						%>
							$("#welcdad_cajas").val(0);
							$("#tarifa4").addClass('hidden');
						<%
					end if
				%>
			}
		);
		
		// wait for the DOM to be loaded 
		$(document).ready(function()
		{
			// bind 'myForm' and provide a simple callback function 
			$('#ltl_form').ajaxForm({ 
				beforeSubmit:  validarForm,
				dataType:  'json', 
				success:   processJson,
				error: processError,
				timeout: 120000
			});
			
			$('#add_dieclave').click(load_dieclave);
			$("#throbber_wel").hide();
		});

		$(document).ready(function()
		{
			$(".solo-numero").keyup(function(){
				this.value = (this.value+'').replace(/[^0-9]/g,'');
			})
		});

		<%
			if num_client = "20123" or Session("array_client")(0,0) = "20123EVIDENCIAS" then
			%>
				$(document).ready(function()
				{
					$(".texto-sin-comillas").keyup(function(){
						this.value = (this.value+'').replace('"','').replace("'","");
					})
				});
				function eliminaEliminar_Comillas(txt)
				{
					txt.value = (txt.value+'').replace('"','').replace("'","");
				}
			<%
			else
				Response.Write " function eliminaEliminar_Comillas(txt) {} "
			end if
		%>
		
		$(document).ready(function()
		{
			$(".solo-numero-dec").keyup(function(){
				var new_val = (this.value+'').replace(/[^0-9\.]/g,''); 
				var dots = new_val.replace(/[^.]/g,'');
				var firstIndex, left_part, right_part, splt, dot;

				//hay mas de 1 punto
				while(dots.length > 1) {
					new_val = new_val.substring(0,new_val.lastIndexOf("."));
					dots = new_val.replace(/[^.]/g,'');
				}

				left_part = new_val.split(".")[0];

				if(new_val.split(".").length > 1) {
					right_part = new_val.split(".")[1];
					dot = ".";
				}
				else {
					right_part = "";
					dot = "";
				}

				new_val = left_part + dot + right_part.substring(0, 2);

				this.value =  new_val;
				//^[0-9]+([,][0-9]+)/$
			})
		});
		
		function validarForm(formData, jqForm, options)
		{
			// jqForm is a jQuery object which wraps the form DOM element 
			// 
			// To validate, we can access the DOM elements directly and return true 
			// only if the values of both the username and password fields evaluate 
			// to true 
			var form = jqForm[0]; 
			var resp = true;
			var msg;
			
			if (!$("#wel_dieclave").val() || $("#wel_dieclave").val().indexOf("|") < 0) {
                alert('Favor de seleccionar un destinatario. [0x000006]');
				return false; 
			}
			if($("#ocurre_oficina").attr('checked')){
				if(!$("#le_contacto").val() && !$("#le_phone").val()) {
                    alert('Favor de capturar el Contacto y/o el telefono. [0x000007]');
					return false; 
				}
			}
			<%
				'Las cuentas internas no tendr�n estas validaciones:
				if CInt(Session("array_client")(2,0)) < 9900 or CInt(Session("array_client")(2,0)) > 9999 then
					%>
						if(!$("#wel_cdad_tarimas").val() || isNaN($("#wel_cdad_tarimas").val())) {
                            alert('Favor de capturar la cantidad de tarimas. [0x000008]');
							return false;
						}
						if(!$("#wel_cajas_tarimas").val() || isNaN($("#wel_cajas_tarimas").val())) {
                            alert('Favor de capturar la cantidad de cajas totales. [0x000009]');
							return false;
						}
						/*
						if(!$("#welCdadAnexos").val() || isNaN($("#welCdadAnexos").val())) {
							alert('Favor de capturar la cantidad de anexos. [0x000010]');
							return false;
						}
						if(!$("#anexos").val()) {
							alert('Favor de capturar los anexos, uno por l�nea. [0x000011]');
							return false;
						}
						*/
						if(!$("#welobservacion").val()) {
                            alert('Favor de capturar el detalle de lo que dice contener. [0x000012]');
							return false;
						}
					<%
				end if
			%>
			if(!$("#welcdad_cajas").val() || isNaN($("#welcdad_cajas").val())) {
                //alert('Favor de capturar la cantidad de cajas o asimilables. [0x000013]');
				$("#welcdad_cajas").val(0);
				return false;
			}
			if(isNaN($("#wel_cdad_bultos").val())) {
                alert('Favor de capturar la cantidad de bultos. [0x000014]');
				return false;
			}
			if (isNaN(form.welimporte.value)) {
                alert('Favor de capturar un importe numerico o dejarlo vacio. [0x000015]');
				return false; 
			}
			if($("#welcdad_cajas").val() > 25) {
                //alert('Favor de capturar la cantidad de cajas o asimilables. [0x000013]');
				//$("#welcdad_cajas").val(0);
				return false;
			}
			/* Se agrega validaci�n para forzar a capturar el valor de mercanc�a cuando el cliente tiene configurado el Seguro de Mercanc�a:	*/
			if($("#iCCOClave").val() != "-1" && $("#iCCOClave").val() != "" && $("#iCCOClave").val() != "undefined" && $("#iCCOClave").val() != undefined)
			{
				<%
					if ConFactura = true then
						%>
							if($("#welimporte").val() == "")
							{
								var iCount = 0;
								var iCantFac = 0;
								var dImporteTotal = 0;
								
								for(iCount = 0; iCount < iCantFac; iCount++)
								{
									if($("#valor_" + iCount).val() != "")
									{
										dImporteTotal = dImporteTotal + $("#valor_" + iCount).val();
									}
								}
								$("#welimporte").val(dImporteTotal);
							}
						<%
					end if
				%>
				
				if($("#welimporte").val() == "")
				{
					$('#welimporte').addClass("not-set");
					$('#l_welimporte').addClass("not-set");
					
                    alert('Error: Cliente con tarifa de seguro, falta capturar Valor de la Mercancia. [0x000016]');
					return false;
				}
				/* Se agrega validaci�n para forzar a que la cantidad capturada sea mayor a cero:	*/
				else
				{
					if(parseFloat($("#welimporte").val()) <= 0)
					{
						$('#welimporte').addClass("not-set");
						$('#l_welimporte').addClass("not-set");
						
                        alert('Error: Cliente con tarifa de seguro, el Valor de la Mercancia debe ser mayor a cero. [0x000017]');
						return false;
					}
				}
			}
	
			msg = "";
			
			listarFacturas();
			
			/*
			if(!$('#welfactura').val())
			{
				$('#l_welfactura').addClass("not-set");
				msg = msg + "- N\u00B0 Referencia|";
			}
			else {
				$('#l_welfactura').removeClass("not-set");
			}
			*/
			/*
			if(!$('#wel_orden_compra').val()){
				$('#l_wel_orden_compra').addClass("not-set");
				msg = msg + "- N\u00B0 Documento|";
			}
			else {
				$('#l_wel_orden_compra').removeClass("not-set");
			}
			*/

			/* Se agrega validaci�n para que la sumatoria de cajas por tarima sea igual a la cantidad capturada en el campo cant. cajas totales. */
            if ($("#detalle_tarimas").attr('checked')) {
                var i, i_wel_cajas_tarimas, i_hdnTotalCajasTarima, i_hdnCantTarimas;

				i = 0;
				i_hdnCantTarimas = 0;
				i_wel_cajas_tarimas = 0;
				i_hdnTotalCajasTarima = 0;


                if ($("#hdnCantTarimas").val() != "") {
                    i_hdnCantTarimas = parseFloat($("#hdnCantTarimas").val());
				}
                if ($("#wel_cdad_tarimas").val() != "") {
					/*i_wel_cajas_tarimas = parseFloat($("#wel_cdad_tarimas").val());*/
					i_wel_cajas_tarimas = parseFloat($("#wel_cajas_tarimas").val());
				}
                if ($("#hdnTotalCajasTarima").val() != "") {
                    i_hdnTotalCajasTarima = parseFloat($("#hdnTotalCajasTarima").val());
				}


				for (i = 1; i <= i_hdnCantTarimas; i++) {
					if ($("#txtTarima_" + i).val() == "") {
						alert('Favor de capturar la cantidad de cajas por tarima para todas las tarimas. [0x000018]');
						return false;
					}
					else {
						if (parseFloat($("#txtTarima_" + i).val()) == 0) {
                            alert('Favor de capturar la cantidad de cajas por tarima para todas las tarimas. [0x000018]');
                            return false;
						}
                    }
				}

				
				if (i_wel_cajas_tarimas != i_hdnTotalCajasTarima) {
                    alert("El total de cajas en el detalle de tarimas no coincide con el total de cajas por tarima. [0x000019]");
                    return false;
				}



				/*
				var len = $("#wel_cdad_tarimas").val();
                var acc = 0;

                for (x = 1; x <= len; x++) {
                    if (!$("#cdad_cajas_" + x).val() || isNaN($("#cdad_cajas_" + x).val()) || parseInt($("#cdad_cajas_" + x).val()) == 0) {
                        alert('Favor de capturar la cantidad de cajas por tarima para todas las tarimas. [0x000018]');
                        return false;
                    }

                    acc = acc + parseInt($("#cdad_cajas_" + x).val());
                }

                if (acc > 0 && acc != parseInt($("#wel_cajas_tarimas").val())) {
                    alert('El total de cajas en el detalle de tarimas no coincide con el total de cajas por tarima: ' + (acc) + ' <> ' + $("#wel_cajas_tarimas").val() + " [0x000019]");
                    return false;
                }
				*/
            }
			
			/* se valida que la cantidad plasmada en el campo "Total del Registro" sea la misma que la capturada en el campo "Bultos Totales" */
			if($('#wel_cdad_bultosAux').val() != $('#totalRegAux').val())
			{
				alert('La cantidad de Bultos Totales no coincide con el total de Bultos capturados [0x000027]');
				return false;
			}
			
			/* Si no hay tarimas no se debe permitir cantidad de cajas por tarima: */
			if($('#wel_cdad_tarimas').val() != "" && $('#wel_cajas_tarimas').val() != "")
			{
				if(parseFloat($("#wel_cdad_tarimas").val()) <= 0 && parseFloat($("#wel_cajas_tarimas").val()) > 0)
				{
					alert('Para capturar cajas por tarima, primero debe capturar una cantidad de tarimas mayor a cero [0x000031]');
					return false;
				}
			}			
			if(($('#wel_cdad_tarimas').val() == "" || $('#wel_cdad_tarimas').val() == "0") && ($('#wel_cajas_tarimas').val() != "" && $('#wel_cajas_tarimas').val() != "0"))
			{
				alert('Para capturar cajas por tarima, primero debe capturar una cantidad de tarimas mayor a cero [0x000032]');
				return false;
			}

			if(!$('#welfactura').val() || !$('#wel_orden_compra').val() || !$('#welimporte').val()){
				if(msg != "")
				{
					var el = msg.split("|");
					
					if(el.length > 0)
					{
						if(el[0] != "")
						{
                            msg = "No ha capturado los siguientes datos:\n";
							
							for(x=0;x<el.length;x++)
							{
								msg = msg + el[x]+"\n";
							}
							
							resp = confirm(msg+"\u00BFconfirma registrar el tal\u00F3n?");
							
							if(!resp) return resp;
						}
					}
				}
			}
			
			if($('#welimporte').val() == "")
			{
				$('#welimporte').val("0");
			}
			
			$("#button_guardar_ltl").attr("disabled", "disabled");
			$("#button_guardar_ltl").attr("pointer-events", "none");
			$("#button_guardar_ltl").val("Guardando...");
			$("#throbber_wel").show();
			
			return resp;
		}
		
		function processJson(data)
		{
			//insertamos el talon creado
			if (data.error != '') {
				alert(data.error);
				limpiarFacturas();
			}
			else {
				/* Valida si se document� la LTL: */
				if (data.welclave != "-1") {
					// Presento toda la informaci�n del manifiesto:
					//$('#ltl_datos tbody tr:not(:first-child)').remove();
					$('#ltl_datos tbody tr').remove();
					$("#ltl_datos tbody").append(data.Tabla);
					
					if(data.wel_fecha_recoleccion != "")
					{
						$("#td_wel_fecha_recoleccion").text(data.wel_fecha_recoleccion);
						$("#td_wel_recoleccion_domicilio").text("Si");
					}
					
					$("#wel_manif_num").val(data.wel_manif_num);
					$("#wel_manif_corte").val(data.wel_manif_corte);
					$("#wel_manif_num_view").text(data.wel_manif_num);
					$("#wel_manif_corte_view").text(data.wel_manif_corte);
					$("#print_etiquetas_manif").show();
					$("#welClave").val(data.folioSiguiente);
				}
				else {
					$("#ltl_datos").append("<tr valign='center' align='center'>"
											+ "<td colspan='8'>" + data.error + "</td>"
											+ "</tr>"
										  );
				}
				limpiarCamposRecaptura();
			}
			
			//restablecer los controls
			resetForm();
		}
		
		function processError(msg, url, line)
		{
			var data;
			
			if (msg.response.indexOf("{") != -1 && msg.response.indexOf("}") != -1) {
				$("#ltl_datos").append(msg.response);
			}
			
			resetForm();
		}
		
		function resetForm()
		{
			$("#button_guardar_ltl").attr("disabled", "");
			$("#button_guardar_ltl").val("Guardar");
			$("#throbber_wel").hide();
			$("#button_guardar_ltl").val("Guardar");
			
			$('#welimporte').val('');
			$('#welcdad_remisiones').val('');
			$('#welpeso').val('');
			$('#welfactura').val('');
			$('#hdn_welfactura').val('');
			$('#wel_orden_compra').val('');
			$('#welobservacion').val('');
			/*$('#anexos').val('');*/
			$('#wel_cdad_bultosAux').val('');
			
			if($('#wel_cdad_tarimas').val() && $('#wel_cdad_tarimas').val() > 0){
				//limpiarembalaje();
                limpiarTarimas();
			}
			
			$('#wel_cdad_tarimas').val('');
			$('#wel_cajas_tarimas').val('');
			$('#welcdad_cajas').val('0');
			$('#wel_cdad_bultos').val('');
			$('#totalRegAux').val('');
			$('#totalReg2Aux').val('');
			$('#totalReg3Aux').val('');
			$('#welcdad_cajasAux').val('');
			/*$('#welCdadAnexos').val('');*/
			$('#txtCP').val('');
			$('#txtCantFacturas').val('');
			//<<< CHG-DESA-19032024 limpia texto del span contar caracteres 
			$("#lblTotalCaracteres").text("");
			//>>> CHG-DESA-19032024
			$('#detalle_tarimas').attr('checked', false);
			$('#hdnCantTarimas').val('0');
			
			$('#wel_collect_prepaid').selectOptions('PREPAGADO');
			f32_FillSel(document.getElementById("destinatario_restrict"),'wel_dieclave');
			$('#destinatario_restrict').focus();
			
			$('#l_welfactura').removeClass("not-set");
			$('#l_wel_orden_compra').removeClass("not-set");
			$('#l_welimporte').removeClass("not-set");
			$("#bloque_detalle_tarimas").hide();
			
			limpiarCombobox("LE_ESTESTADO","Estado");
			limpiarCombobox("LA_CIUDAD","Ciudad");
			limpiarCombobox("wel_dieclave","Destinatario");
			
			
			$("#txtCP").focus();
		}
		
		function imprimirEtiquetas(id, manif, corte_manif)
		{
			/*var etiq = window.open('ltl_etiquetas_print.asp?popup=si&tipo=zebra&id=' + id + '&manif=' + manif + '&corte_manif=' + corte_manif, '','resizable=yes, location=no, width=400, height=300, menubar=no, status=no, scrollbars=no, menubar=no');*/
			var etiq = window.open('print_label.asp?popup=si&tipo=zebra&tipo_etiq=chico&nui=' + id + '&manif=' + manif + '&corte_manif=' + corte_manif, '','resizable=yes, location=no, width=400, height=300, menubar=no, status=no, scrollbars=no, menubar=no');
		}
		
		function f32_FillSel(f32_tb,f32_id)
		{
			if(f32_tb != null)
			{
				f32_tv=f32_tb.value.toLowerCase();
				f32_id=document.getElementById(f32_id);
				
				if (!f32_id.ary) {
					f32_id.sary=new Array();
					f32_id.ary=new Array();
					
					for (f32_0=0;f32_0<f32_id.options.length;f32_0++){
						f32_id.ary[f32_0]=[f32_id.options[f32_0].text,f32_id.options[f32_0].value];
					}
				}
				
				f32_ary=new Array();
				
				for (f32_0=0;f32_0<f32_id.ary.length;f32_0++) {
					if (f32_id.ary[f32_0][0].toLowerCase().match( f32_tv)) {
						//&&f32_tv!=''&&f32_tv!=' '
						f32_ary[f32_ary.length]=f32_id.ary[f32_0];
					}
				}
				
				f32_id.options.length=0;
				
				if (f32_id.sary!=f32_ary) {
					for (f32_1=0;f32_1<f32_ary.length;f32_1++) {
						f32_id.options[f32_id.options.length]=new Option(f32_ary[f32_1][0],f32_ary[f32_1][1],true,true);
					}
				}
				
				f32_id.selectedIndex=0;
				f32_id.sary=f32_ary;
				f32_tb.focus();
			}
		}
	
		//scripts para cargar el form del nuevo destinatario
		function load_dieclave(event)
		{
			event.preventDefault();
			if ($('#wccl_form').html() == null) {
				$('#new_dieclave').load('ltl_destinatarios_captura.asp?json=ok #wccl_form', activate_wccl);
			}
			else {
				$('#wccl_form').show();
			}
		}
		
		function activate_wccl()
		{
			var dol = new DynamicOptionList();
			dol.addDependentFields("estado","dieville");
			dol.setFormName("wccl_form");
			<%
				''consulta solo ciudades con CEDIS asociados
				array_tmp = obtiene_ciudades_con_cedis(Session("array_client")(2,0))
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
		
		function validarWcclForm(formData, jqForm, options)
		{
			// jqForm is a jQuery object which wraps the form DOM element
			// 
			// To validate, we can access the DOM elements directly and return true
			// only if the values of both the username and password fields evaluate
			// to true
			
			var form = jqForm[0];
			
			if (!form.dienombre.value || !form.dieadresse1.value) {
                alert('Favor de capturar el nombre y la calle. [0x000020]');
				return false;
			}
			if (form.ccl_rfc.value != '' && (!isRFC(form.ccl_rfc.value) || form.ccl_rfc.value.length < 12)) {
                alert('Favor de capturar un RFC correcto. [0x000021]');
				return false;
			}
			
			$("#btn_validar_wccl").attr("disabled", "disabled");
			$("#btn_validar_wccl").val("Guardando...");
			$("#throbber_wccl").show();
		}
		
		function isRFC(sText)
		{
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
		
		function processWcclError(msg, url, line)
		{
            alert('Hubo un error al guardar el destinatario. [0x000022]');
			resetWcclForm();
		}
		
		function processWcclJson(data)
		{
			//insertamos el talon creado
			$("#wel_dieclave").addOption(data.dieclave, data.dienombre);
			//restablecer los controls
			resetWcclForm();
		}
		
		function resetWcclForm()
		{
			$("#btn_validar_wccl").attr("disabled", "");
			$("#btn_validar_wccl").val("Guardar");
			$("#throbber_wccl").hide();
			$('#wccl_form').resetForm();
			$('#wel_cdad_bultos').focus();
			$('#wccl_form').hide();    
		}
		
		function limpiarCamposRecaptura()
		{
			$("#welfactura").val("");
			$("#hdn_welfactura").val("");
			$("#welimporte").val("");
			$("#welobservacion").val("");
			$("#wts_observaciones_nui").val("");
			limpiarFacturas();
			
			$("#cmbCondicionesEntrega option[value=entrega_domicilio]").attr("selected",true);
			$("#le_contacto").val("");
			$("#le_phone").val("");
			$("#trOcurreLogis").addClass("hidden");
			
			$("#wel_cdad_bultosAux").val('');
			$("#wel_cdad_tarimas").val('');
			$("#wel_cajas_tarimas").val('');
			$("#lblTotalCajasTarima").empty();
			$("#lblTotalCajasTarima").text('0');
			$("#hdnTotalCajasTarima").val('0');
			$("#welcdad_cajas").val('0');
			$("#totalRegAux").val('');
			$("#totalReg2Aux").val('');
			$("#totalReg3Aux").val('');
			document.getElementById("detalle_tarimas").checked = false;
			limpiarTarimas();
			
			$("#txtCP").val('');
			
			
			<%
				if ConFactura = true then
					Response.Write "$('#txtCantFacturas').focus();"
				else
					Response.Write "$('#welfactura').focus();"
				end if
			%>
		}
		
		function listarFacturas()
		{
			var iFact = 0;
			var lstFacturas = "";
			var iCantFacturas = 0;
			
			if ($('#txtCantFacturas').val() != "")
			{
				iCantFacturas = parseFloat($('#txtCantFacturas').val());
				
				<%
					if ConDocFuente = true then
						%>
							for(iFact = 0; iFact < iCantFacturas; iFact++)
							{
								if(lstFacturas == "")
								{
									lstFacturas = $("#doc_fuente_" + iFact).val();
								}
								else
								{
									lstFacturas = lstFacturas + "," + $("#doc_fuente_" + iFact).val();
								}
							}
						<%
					else
						%>
							for(iFact = 0; iFact < iCantFacturas; iFact++)
							{
								if(lstFacturas == "")
								{
									lstFacturas = $("#factura_" + iFact).val();
								}
								else
								{
									lstFacturas = lstFacturas + "," + $("#factura_" + iFact).val();
								}
							}
						<%
					end if
				%>
				
				
				//document.getElementById('welfactura').value = lstFacturas;
				//$('#welfactura').val(lstFacturas);
				$("#welfactura").attr('value',lstFacturas)
				document.getElementById('hdn_welfactura').value = lstFacturas;
				document.getElementById('welfactura').text = lstFacturas;
				document.getElementById('hdn_welfactura').text = lstFacturas;

				//alert(lstFacturas);

			}
		}
	
		$(function()
		{
			$('#txtCantFacturas').change(function(){
				var idRow = "";
				var cFactura = 0;
				var txtCantFacturas = 0;
				var hdnCantFacturas = 0;
				
				if ($('#txtCantFacturas').val() == "")
				{
					/* Si no se registra la cantidad de facturas a capturar: se limpia la tabla. */
					limpiarFacturas();
                }
				else
				{
					txtCantFacturas = parseFloat($('#txtCantFacturas').val());

					if ($('#hdnCantFacturas').val() != "") {
						hdnCantFacturas = parseFloat($('#hdnCantFacturas').val());
					}

					if (txtCantFacturas <= 0) {
                        /* Si la cantidad de facturas a capturar es igual a cero: se limpia la tabla. */
						limpiarFacturas();
					}
					else {
						if (hdnCantFacturas == 0) {
							/* Si la tabla no tiene filas creadas, se crean como nuevas. */
							for (cFactura = 0; cFactura < txtCantFacturas; cFactura++) {
                                agregar_fila_Facturas(cFactura);
							}
						}
						else {
							if (txtCantFacturas > hdnCantFacturas) {
								/* Si la cantidad de filas a crear es mayor a la cantidad de filas de la tabla, se crean las filas faltantes. */
								for (cFactura = hdnCantFacturas; cFactura < txtCantFacturas; cFactura++) {
                                    agregar_fila_Facturas(cFactura);
								}
							}
							else {
								/* Si la cantidad de filas a crear es menor a la cantidad de filas de la tabla, se eliminan las filas sobrantes desde la mas reciente a la mas antigua. */
								for (cFactura = hdnCantFacturas; cFactura >= txtCantFacturas; cFactura--) {
                                    idRow = "row_F" + cFactura;
                                    $('#' + idRow).remove();
								}
                            }
						}
					}
				}
                $("#hdnCantFacturas").val($('#txtCantFacturas').val());
			});
		});
		
		$(function()
		{
			$('#wel_cdad_tarimas, #welcdad_cajas').change(function() {
				var tarimas = 0;
				var cajas = 0;
				
				if($('#wel_cdad_tarimas').val() != "") {
					tarimas = parseFloat($('#wel_cdad_tarimas').val());
				}
				if($('#welcdad_cajas').val() != "") {
					cajas = parseFloat($('#welcdad_cajas').val());
				}
				
				$('#wel_cdad_bultos').val((tarimas+cajas));
				$('#totalRegAux').val((tarimas+cajas));
				$('#totalReg2Aux').val((tarimas+cajas));
			});
		});
		
		$(function()
		{
			$('#wel_cajas_tarimas, #welcdad_cajas').change(function() {
				var cajastarimas = 0;
				var cajas = 0;
				
				if($('#wel_cajas_tarimas').val() != "") {
					cajastarimas = parseFloat($('#wel_cajas_tarimas').val());
				}
				
				if($('#welcdad_cajas').val() != "") {
					cajas = parseFloat($('#welcdad_cajas').val());
				}
				
				$('#welcdad_cajasAux').val(cajas);
				$('#totalReg3Aux').val((cajastarimas+cajas));
			});
			
			$("#wel_cajas_tarimas").change(function() {
				/*
				if($("#wel_cajas_tarimas").val() == "" || $("#wel_cajas_tarimas").val() == "0")
				{
					$("#td_BultosConstitutivos_label").addClass("hidden");
					$("#td_BultosConstitutivos_field").addClass("hidden");
				}
				else
				{
					$("#td_BultosConstitutivos_label").removeClass("hidden");
					$("#td_BultosConstitutivos_field").removeClass("hidden");
				}
				*/
			});
		});
		
		$(function()
		{
			$('#cmbCondicionesEntrega').change(function() {
				if(document.getElementById("cmbCondicionesEntrega").value == "ocurre_logis")
				{
					$("#trOcurreLogis").removeClass("hidden");
				}
				else
				{
					$("#trOcurreLogis").addClass("hidden");
				}
			});
			
			
			 $('#DISCLEF').change(function()
			 {
				$("#wel_disclef").val(document.getElementById("DISCLEF").value);
             });

			
		});

		function res_function(event)
		{
			//alert(element.selectedValue);
			alert('entro');
		}
		
		$(function()
		{
			$('#txtCP').change(function(){
				var txtCP = 0;
				//<<< CHG-DESA-19032024 se declaran variables para separar la dieclave
				var dieclave = "";
				var valorSeparado = "";
				var valorConcatenado = "";
				// CHG-DESA-19032024 >>>
				
				if($('#txtCP').val() != "")
				{
					txtCP = parseFloat($('#txtCP').val());
					
					$.ajaxSetup({async: false})
					$('#LE_ESTESTADO').load('ajax_CodigoPostal.asp?txtCP=' + $('#txtCP').val() + "&tipo=1");
					$.ajaxSetup({async: true})
					
					/*
					$.ajaxSetup({async: false})
					$('#LA_CIUDAD').load('ajax_ciudades.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
					$.ajaxSetup({async: true})
					con_filtro();
					*/
					
					if($('#LE_ESTESTADO').val() != "" && $('#LE_ESTESTADO').val() != null)
					{
						$.ajaxSetup({async: false})
						$('#LA_CIUDAD').load('ajax_CodigoPostal.asp?txtCP=' + $('#txtCP').val() + "&est=" + $('#LE_ESTESTADO').val() + "&tipo=2");
						$.ajaxSetup({async: true})
						
						
						if($('#LA_CIUDAD').val() != "" && $('#LA_CIUDAD').val() != null)
						{
							//logis_filtro();
							
							$.ajaxSetup({async: false})
							$('#wel_dieclave').load('ajax_CodigoPostal.asp?txtCP=' + $('#txtCP').val() + "&est=" + $('#LE_ESTESTADO').val() + "&ciu=" + $('#LA_CIUDAD').val() + "&tipo=3");
							$.ajaxSetup({async: true})
							$('#wel_dieclave').focus();
							
							if($('#wel_dieclave').val() == "" || $('#wel_dieclave').val() == null)
							{
								limpiarCombobox("wel_dieclave","Destinatario");
								alert('No existe informacion de (Destinatario) relacionada con el C.P. ingresado para el cliente: "<%=Session("array_client")(2,0)%>". Favor de verificar. [0x000028]');
								$("#txtCP").val("");
								$("#txtCP").focus();
							}

							/*<<<CHG-DESA-19032024 se valida dieclave: */
								// Separacion de valores por pipes
								valorConcatenado = $('#wel_dieclave').val();
								
								if (valorConcatenado != "")
								{
									valorSeparado = valorConcatenado.split("|");
									dieclave = valorSeparado[0];
								}
								
								//se valida la dieclave mandano a llamar al tipo 4 del ajax_Codigo_postal
								if ($('#wel_dieclave').val() != "" || $('#wel_dieclave').val() != null)
								{
									
									$.ajaxSetup({ async: false })
									$('#hdnRes').load('ajax_CodigoPostal.asp?txtCP=' + $('#txtCP').val() + '&dieclave=' + dieclave + "&tipo=4");
									$.ajaxSetup({ async: true })
									
								}
							/*   CHG-DESA-19032024>>> */
						}
						else
						{
							limpiarCombobox("LA_CIUDAD","Ciudad");
							limpiarCombobox("wel_dieclave","Destinatario");
							alert('No existe informacion de (Ciudad) relacionada con el C.P. ingresado para el cliente: "<%=Session("array_client")(2,0)%>". Favor de verificar. [0x000029]');
							$("#txtCP").val("");
							$("#txtCP").focus();
						}
					}
					else
					{
						limpiarCombobox("LE_ESTESTADO","Estado");
						limpiarCombobox("LA_CIUDAD","Ciudad");
						limpiarCombobox("wel_dieclave","Destinatario");
						alert('No existe informacion relacionada con el C.P. ingresado para el cliente: "<%=Session("array_client")(2,0)%>". Favor de verificar.  [0x000030]');
						$("#txtCP").val("");
						$("#txtCP").focus();
					}
				}
				else
				{
					limpiarCombobox("LE_ESTESTADO","Estado");
					limpiarCombobox("LA_CIUDAD","Ciudad");
					limpiarCombobox("wel_dieclave","Destinatario");
					alert('No existe informacion relacionada con el C.P. ingresado para el cliente: "<%=Session("array_client")(2,0)%>". Favor de verificar.');
					$("#txtCP").focus();
				}
			});
		});
	//<<<CHG-DESA-19032024 respuesta del ajax:	
		function ServiceFailed(result) {
                alert('Service call failed: ' + result.status + '' + result.statusText);
                Type = null;
                varUrl = null;
                Data = null;
                ContentType = null;
                DataType = null;
                ProcessData = null;
            }

            function ServiceSucceeded(result) {
                alert(result);
                if (DataType == "json") {
                    resultObject = result.GetUserResult;

                    for (i = 0; i < resultObject.length; i++) {
                        alert(resultObject[i]);
                    }

                }

            }
			//CHG-DESA-19032024 >>>:	

		$(function()
		{
			$('#LE_ESTESTADO').change(function(){
				/*
				if (document.getElementById('ocurre_oficina').checked) {
					logis_filtro();
				}
				else {
					$.ajaxSetup({async: false})
					$('#LA_CIUDAD').load('ajax_ciudades.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
					$.ajaxSetup({async: true})
					con_filtro();
				}
				*/
				
				/*
				$.ajaxSetup({async: false})
					$('#LA_CIUDAD').load('ajax_CodigoPostal.asp?txtCP=' + $('#txtCP').val() + "&est=" + $('#LE_ESTESTADO').val() + "&tipo=2");
					$.ajaxSetup({async: true})
					con_filtro();
				*/
				
				$.ajaxSetup({async: false})
				$('#LA_CIUDAD').load('ajax_CodigoPostal.asp?txtCP=' + $('#txtCP').val() + "&est=" + $('#LE_ESTESTADO').val() + "&tipo=2");
				$.ajaxSetup({async: true})
				//logis_filtro();
			});
		});
		
		$(function()
		{
			$('#LA_CIUDAD').change(function()
			{
				$.ajaxSetup({async: false})
				$('#wel_dieclave').load('ajax_CodigoPostal.asp?txtCP=' + $('#txtCP').val() + "&est=" + $('#LE_ESTESTADO').val() + "&ciu=" + $('#LA_CIUDAD').val() + "&tipo=3");
				$.ajaxSetup({async: true})
				$('#wel_dieclave').focus();
				
				//logis_filtro();
				
				/*
				con_filtro();
				*/
				//$('#wel_dieclave').load('ajax_dest.asp?LA_CIUDAD=' + $('#LA_CIUDAD').val() + '&destinatario_restrict=' + $('#destinatario_restrict').val());
				//logis_filtro();
			});
		});
		
		function con_filtro()
		{
			$('#wel_dieclave').load('ajax_dest_con_filtro.asp?LA_CIUDAD=' + $('#LA_CIUDAD').val() + '&destinatario_restrict=' + $('#destinatario_restrict').val());
			$('#wel_dieclave').focus();
		}
		
		function sin_filtro()
		{
			$('#wel_dieclave').load('ajax_dest.asp?LA_CIUDAD=' + $('#LA_CIUDAD').val() + '&destinatario_restrict=' + $('#destinatario_restrict').val());
			$('#wel_dieclave').focus();
		}
		
		function logis_filtro()
		{
			$('#wel_dieclave').load('ajax_logis.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
			$('#wel_dieclave').focus();
		}
		
		function logis_sin_filtro()
		{
			$('#wel_dieclave').load('ajax_logis_completo.asp?LE_ESTESTADO=' + $('#LE_ESTESTADO').val());
			$('#wel_dieclave').focus();
		}
		
		function calc()
		{
			if (document.getElementById('ocurre_oficina').checked)
			{
				document.getElementById("cache").style.display = "none";
				document.getElementById("btnListaCompleta").style.display = "none";
				document.getElementById("btnListaCompletaLogis").style.display = "block";
				document.getElementById("contacto").style.display = "block";
				
				$("#le_contacto").toggle();
				$("#LA_CIUDAD").toggle();
				$("#entrega_dol").toggle();
				$("#welentrega_domicilio").toggle();
				$("#phone").toggle();
				$("#le_phone").toggle();
				
				logis_filtro();
			}
			else
			{
				document.getElementById("cache").style.display = "block";
				document.getElementById("btnListaCompleta").style.display = "block";
				document.getElementById("btnListaCompletaLogis").style.display = "none";
				document.getElementById("contacto").style.display = "none";
				
				$("#le_contacto").toggle();
				$("#LA_CIUDAD").toggle();
				$("#entrega_dol").toggle();
				$("#welentrega_domicilio").toggle();
				$("#phone").toggle();
				$("#le_phone").toggle();
			}
		}
		
		function show_detalle_tarimas()
		{
			if($("#detalle_tarimas").attr('checked')) {
				$("#bloque_detalle_tarimas").toggle();
				renglones_por_tarima();
			}
			else {
				//limpiarembalaje();
                limpiarTarimas();
				$("#bloque_detalle_tarimas").toggle();
                $("#hdnCantTarimas").val("0");
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

        function txt_numerico(txt) {
			txt.value = (txt.value + '').replace(/[^0-9]/g, '');
		}
        function txt_decimal(txt) {
			var RE = /^\d*\.?\d*$/;
            if (RE.test(txt.value) == false) {
				txt.value = "";
            }
		}
		function calculaImporte(cFactura) {
			var i = 0;
			var dImp_i = 0;
			var dImporte = 0;
			var txtImp_i = 0;
			var TotalRenglones = $("#hdnCantFacturas").val();

			if (TotalRenglones != "") {
				for (i = 0; i < parseFloat(TotalRenglones); i++) {
					txtImp_i = $("#valor_" + i).val();

					if (txtImp_i != "") {
						dImp_i = parseFloat($("#valor_" + i).val());
					}
					else {
						dImp_i = 0;
					}
					dImporte += dImp_i;
				}
			}

			$("#welimporte").val(dImporte);
		}
        function calculaTotalCajas() {
            var i = 0;
            var dCant_i = 0;
            var dCantidad = 0;
			var txtCant_i = "";
            var TotalRenglones = $("#hdnCantTarimas").val();

            if (TotalRenglones != "") {
				for (i = 1; i <= parseFloat(TotalRenglones); i++) {
                    txtCant_i = $("#txtTarima_" + i).val();

                    if (txtCant_i != "") {
                        dCant_i = parseFloat($("#txtTarima_" + i).val());
                    }
                    else {
                        dCant_i = 0;
                    }
                    dCantidad += dCant_i;
                }
            }

            $("#lblTotalCajasTarima").text(dCantidad);
            $("#hdnTotalCajasTarima").val(dCantidad);
		}
// <<< CGH-DESA-13032024-01 funci�n para contar caracteres
        function calculaTotalCaracteres() {
            var i = 0;
            var dCantidad = 0;
            var txtCant_i = 0;
            var TotalRenglones = $("#hdnCantFacturas").val(); //renglones de facturas

            if (TotalRenglones != "") {
                for (i = 0; i < parseFloat(TotalRenglones); i++) {
                    txtCant_i = $("#factura_" + i).val().length; //campo factura

                    if (txtCant_i != "") {
                        // Contar el n�mero de caracteres en txtCant_i y agregarlo a dCantidad
						dCantidad += txtCant_i;

                        if (dCantidad >= 99) {
                            //	$("#lblTotalCaracteres").text("Se ha llegado al limite de 99 Caracteres, es necesario termine de registrar la totalidad de facturas , y las declare tambien en el campo dice contener.");
						}
						else if (dCantidad < 99)
						{
							$("#lblTotalCaracteres").text("");
                        }
                    }
                }
			}
        }
// CGH-DESA-13032024-01 >>>

		
		function limpiarCombobox(id,txtDefault)
		{
			const $select = document.querySelector("#" + id);
			const option = document.createElement('option');
			
			for (let i = $select.options.length; i >= 0; i--)
			{
				$select.remove(i);
			}
			
			option.value = "";
			option.text = txtDefault;
			
			$select.appendChild(option);
		}
		function limpiarembalaje()
		{
			var x;
			var len = $("#tableEmbalaje > tbody").children().length;
			
			for(x=1;x<=len;x=x+1) {
				$('#row_' + x).remove();
			}
		}
        function limpiarTarimas() {
            var x;
            var len = $("#tableEmbalaje > tbody").children().length;

            for (x = 1; x <= len; x = x + 1) {
                $('#row_T' + x).remove();
            }
        }
		function limpiarFacturas()
		{
			var x;
			var len = $("#tblFacturas > tbody").children().length;
			
			for(x=0;x<len;x=x+1)
			{
				EliminarFactura('row_F' + x );
			}
			$('#txtCantFacturas').val("");
			$('#hdnCantFacturas').val('0');
		}
		function EliminarFactura(idFila)
		{
			$('#' + idFila).remove();
		}
		
		function addEmbalajes(row)
		{
			$("#tableEmbalaje > tbody:last-child").append("<tr id=\"row_"+row+"\">"
														  +  "<td align=\"center\" width=\"10%\"><span>"+row+"</span></td>"
														  +  "<td align=\"center\" width=\"70%\" class=\"hidden\"><input type=\"text\" id=\"tarima_cliente_"+row+"\" name=\"tarima_cliente_"+row+"\" size=\"30\" maxlength=\"30\"></td>"
														  +  "<td align=\"center\" width=\"20%\"><input type=\"text\" id=\"cdad_cajas_"+row+"\" name=\"cdad_cajas_"+row+"\" size=\"10\" maxlength=\"10\" class=\"light just-added\"></td>"
														  +"</tr>");
		}
		
		function recalculaEmbalaje()
		{
			if($("#detalle_tarimas").attr('checked'))
			{
				/*
				limpiarembalaje();
				cargaembalaje();
				*/
			}
		}
		
		function display_fecha()
		{
			if (document.getElementById("recoleccion_domicilio").checked == true)
			{
				$("#fecha_div").removeClass('hidden');
            }
            else
			{
                $("#fecha_div").addClass('hidden');
				$("#fecha_recoleccion").val("");
            }
		}

		function renglones_por_tarima() {
			var txtCantTarimas = 0;
			var hdnCantTarimas = 0;

			if ($('#wel_cdad_tarimas').val() == "") {
				/* Si no se registra la cantidad de tarimas: se limpia la tabla. */
				limpiarTarimas();
			}
			else {
				txtCantTarimas = parseFloat($('#wel_cdad_tarimas').val());

				if ($('#hdnCantTarimas').val() != "") {
					hdnCantTarimas = parseFloat($('#hdnCantTarimas').val());
				}

				if (txtCantTarimas <= 0) {
					/* Si la cantidad de tarimas a capturar es igual a cero: se limpia la tabla. */
					limpiarTarimas();
				}
				else {
					if (hdnCantTarimas == 0) {
						/* Si la tabla no tiene filas creadas, se crean como nuevas. */
						for (cTarima = 0; cTarima < txtCantTarimas; cTarima++) {
							agregar_fila_Tarimas(cTarima);
						}
					}
					else {
						if (txtCantTarimas > hdnCantTarimas) {
							/* Si la cantidad de filas a crear es mayor a la cantidad de filas de la tabla, se crean las filas faltantes. */
							for (cTarima = hdnCantTarimas; cTarima < txtCantTarimas; cTarima++) {
								agregar_fila_Tarimas(cTarima);
							}
						}
						else {
							/* Si la cantidad de filas a crear es menor o igual a la cantidad de filas de la tabla, se eliminan las filas sobrantes desde la mas reciente a la mas antigua. */
							for (cTarima = hdnCantTarimas; cTarima > txtCantTarimas; cTarima--) {
								idRow = "row_T" + (cTarima);
								$('#' + idRow).remove();
							}
						}
					}
				}
			}
            $("#hdnCantTarimas").val($('#wel_cdad_tarimas').val());
		}

		function agregar_fila_Facturas(cFactura) {
			<%
				if ConDocFuente = true then
					%>
						$("#tblFacturas > tbody:last-child").append("<tr id=\"row_F" + cFactura + "\">"
							+ "	<td align=\"center\" ><span class=\"mandatory\" title=\"eliminar\" onclick=\"EliminarFactura('row_" + cFactura + "');\"><input type=\"text\" id=\"doc_fuente_" + cFactura + "\" name=\"doc_fuente_" + cFactura + "\" onkeyup=\"eliminaEliminar_Comillas(this);replicaDato(" + cFactura + ");\" class=\"width-85\" />&nbsp;</span></td>"
							+ "	<td align=\"center\" width=\"14%\"><input type=\"text\" id=\"factura_" + cFactura + "\" name=\"factura_" + cFactura + "\" onkeyup=\"eliminaEliminar_Comillas(this);\"  onchange='calculaTotalCaracteres();' class=\"width-98p\" /></span></td>"
							+ "	<td align=\"center\" >"
							+ "		<select id=\"complemento_" + cFactura + "\" name=\"complemento_" + cFactura + "\" class=\"light width-98p\">"
							//+ "		<select id=\"complemento_" + cFactura + "\" name=\"complemento\" class=\"light width-98p\">"
							+ "			<option value=\"N\" selected=\"selected\">No</option>"
							+ "			<option value=\"S\">Si</option>"
							+ "		</select>"
							+ "	</td>"
							+ "	<td align=\"center\" ><input type=\"text\" id=\"lnCaptura_" + cFactura + "\" name=\"lnCaptura_" + cFactura + "\" onkeyup='txt_numerico(this);' class=\"width-98p\" /></td>"
							+ "	<td align=\"center\" ><input type=\"text\" id=\"valor_" + cFactura + "\" name=\"valor_" + cFactura + "\" onkeyup='txt_decimal(this);calculaImporte(" + cFactura + ");' class=\"width-98p\" /></td>"
							+ "	<td align=\"center\" ><input type=\"text\" id=\"orden_compra_" + cFactura + "\" name=\"orden_compra_" + cFactura + "\" onkeyup=\"eliminaEliminar_Comillas(this);\" class=\"width-98p\" /></td>"
                            + "	<td align=\"center\" ><input type=\"text\" id=\"pedido_" + cFactura + "\" name=\"pedido_" + cFactura + "\" onkeyup=\"eliminaEliminar_Comillas(this);\" class=\"disabled width-98p\" readonly=\"readonly\" /></td>"
							+ "</tr>");
						/*
						<th class="font-size-12">
							Documento Fuente
						</th>
						*/
					<%
				else
					%>
						$("#tblFacturas > tbody:last-child").append("<tr id=\"row_F" + cFactura + "\">"
                            + "	<td align=\"center\" width=\"25%\"><span class=\"mandatory\" title=\"eliminar\" onclick=\"EliminarFactura('row_" + cFactura + "');\"><input type=\"text\" id=\"factura_" + cFactura + "\" name=\"factura_" + cFactura + "\" onkeyup=\"eliminaEliminar_Comillas(this);\" class=\"width-90p\" onchange='calculaTotalCaracteres();'  />&nbsp;</span></td>"
							+ "	<td align=\"center\" width=\"15%\">"
							+ "		<select id=\"complemento_" + cFactura + "\" name=\"complemento_" + cFactura + "\" class=\"light width-98p\">"
							+ "			<option value=\"N\" selected=\"selected\">No</option>"
							+ "			<option value=\"S\">Si</option>"
							+ "		</select>"
							+ "	</td>"
							+ "	<td align=\"center\" width=\"15%\"><input type=\"text\" id=\"lnCaptura_" + cFactura + "\" name=\"lnCaptura_" + cFactura + "\" onkeyup='txt_numerico(this);' class=\"width-98p\" /></td>"
							+ "	<td align=\"center\" width=\"15%\"><input type=\"text\" id=\"valor_" + cFactura + "\" name=\"valor_" + cFactura + "\" onkeyup='txt_decimal(this);calculaImporte(" + cFactura + ");' class=\"width-98p\" /></td>"
							+ "	<td align=\"center\" width=\"15%\"><input type=\"text\" id=\"orden_compra_" + cFactura + "\" name=\"orden_compra_" + cFactura + "\" onkeyup=\"eliminaEliminar_Comillas(this);\" class=\"width-98p\" /></td>"
							+ "	<td align=\"center\" width=\"15%\"><input type=\"text\" id=\"pedido_" + cFactura + "\" name=\"pedido_" + cFactura + "\" onkeyup=\"eliminaEliminar_Comillas(this);\" class=\"width-98p\" /></td>"
							+ "</tr>");
					<%
				end if
			%>
		}

		function agregar_fila_Tarimas(cTarima) {
			cTarima = cTarima + 1;
			$("#tableEmbalaje > tbody:last-child").append("<tr id=\"row_T" + cTarima + "\">"
				+ "	<td align=\"center\" ><label id=\"lblTarima_" + cTarima + "\" name=\"lblTarima_" + cTarima + "\">" + cTarima + "</label></td>"
                + "	<td align=\"center\" ><input type=\"text\" id=\"txtTarima_" + cTarima + "\" name=\"txtTarima_" + cTarima + "\" class=\"width-80-i\" onkeyup='txt_numerico(this);' onchange='calculaTotalCajas();' /></td>"
				+ "</tr>");
		}
		function replicaDato(idx)
		{
			var docFuente = "";
			var txtFuente, txtPedido;
			
			txtFuente = document.getElementById("doc_fuente_" + idx);
            txtPedido = document.getElementById("pedido_" + idx);
			
            if (txtFuente != null && txtPedido != null)
			{
				docFuente = txtFuente.value;
                txtPedido.value = docFuente;
			}
		}
    </script>
	
	<img src="images/pixel.gif" width="0" height="100" border="0" />
	<div id="menu" style="text-align:center; z-index:1;">
	

<%
	if Request.Form("wel_manif_num") = "" then
		'estamos creando un nuevo manifiesto, recuperamos los datos del remitente
		arrayLTL = obtener_remitente(mi_distclave)
		
		if not IsArray(arrayLTL) then
			arrayLTL = obtener_remitente_x_cliente(num_client)
			
			if not IsArray(arrayLTL) then
				Response.Write "Datos de remitente incorrectos. [0x000023-" & num_client & "]"
				Response.End
			end if
		else
			disnom = arrayLTL(0,0)
			dis_ville = arrayLTL(1,0)
			dis_estado = arrayLTL(2,0)
			wel_cliclef = arrayLTL(3,0)
			'wel_disclef = arrayLTL(4,0) 
			dis_vilclef = arrayLTL(5,0) 
		end if
		
		if Request.Form("recoleccion_domicilio") = "S" then
			wel_fecha_recoleccion = Request.Form("fecha_recoleccion") &" "& Request.Form("hora_recoleccion") &":"& Request.Form("minutos_recoleccion")
		end if
		
		'vamos a poner la fecha de llegada aqui, luego se usara para hacer la entrada del manifiesto:
		if Request.Form("fecha_entrada") <> "" and Request.Form("hora_entrada") <> "" and Request.Form("minutos_entrada") <> "" then
			wel_manif_fecha = Request.Form("fecha_entrada") & " " & Request.Form("hora_entrada") & ":" & Request.Form("minutos_entrada")
		else
			wel_manif_fecha = obtener_fecha_actual("dd/mm/yyyy hh24:mi")
		end if
		
		'hacer_corte = Request.Form("corte")
		hacer_corte = Request.QueryString("corte")
		wel_manif_corte = Request.Form("wel_manif_corte")
	else
		'estamos modificando un manifiesto recuperamos los datos de remitente y los talones
		arrayLTL = obtener_info_manifiesto(num_client,SQLEscape(Request.Form("WEL_MANIF_NUM")),SQLEscape(Request.Form("wel_manif_corte")))
		
		if not IsArray(arrayLTL) then
			Response.Write "Datos de manifiesto incorrectos. [0x000024]"
			Response.End 
		end if
		
		wel_manif_num = arrayLTL(0,0) 
		wel_fecha_recoleccion = arrayLTL(1,0) 
		disnom = arrayLTL(2,0)
		dis_ville = arrayLTL(3,0)
		dis_estado = arrayLTL(4,0)
		wel_cliclef = arrayLTL(5,0)
		'wel_disclef = arrayLTL(6,0)
		wel_manif_fecha = arrayLTL(7,0)
		dis_vilclef = arrayLTL(9,0) 
		
		if Request.Form("wel_manif_corte") <> "" then 
			hacer_corte = "S"
			
			if Request.Form("wel_manif_corte") > 0 then    
				wel_manif_corte = Request.Form("wel_manif_corte")
			end if
		end if
	end if
	
	'recuperamos si es smo para mostrar el peso
	arrayLTL = obtener_destino_por_ciudad(dis_vilclef)
	
	if not IsArray(arrayLTL) then
		verPeso = "0"
	else
		verPeso = arrayLTL(0,0)
	end if
	
	'recuperamos el CEDIS del remitente
	arrayLTL = obtener_cedis_por_remitente(wel_disclef)
	
	if IsArray(arrayLTL) then
		wel_allclave_ori = arrayLTL(0,0)
		
		'buscar si hay un cedis de remitente forzado:
		arrayLTL = obtener_cedis_por_remitente_forzado(DisClef)
		
		if IsArray(arrayLTL) then
			wel_allclave_ori = arrayLTL(0,0)	
		end if
	else
		wel_allclave_ori = 1 
	end if
	
	'Validar si el cliente tiene saldo disponible
	array_tmp = valida_cliente_regimen_8(Session("array_client")(2,0))
	if array_tmp(0, 0) <> "0" then
		array_tmp = obtiene_saldo_monedero_electronico(Session("array_client")(2,0))
		
		if IsArray(array_tmp) then
			saldo_disponible = array_tmp(0, 0)
			
			if saldo_disponible = "$0.00" then
				saldo_clase = "border:#FE8080 1px solid; background-color:#FEBFBF;"
			else
				saldo_clase = "border:#419100 1px solid; background-color:#CDFECD;"
			end if
		%>
			<div style="<%=saldo_clase%> width: 500px; margin:0 auto; padding:5px 0;">
				<b>Saldo Disponible: <%=saldo_disponible%></b>
			</div>
			<br/>
		<%
		end if
	end if

	if not IsArray(arrFolioSiguiente) then
		Response.Write "<center><font color='#900C3F'>El cliente " & Session("array_client")(2,0) & " no cuenta con folios reservados disponibles para documentar, favor de verificarlo con el &aacute;rea de facturaci&oacute;n. [0x000025]</font></center>"
		Response.End 
	else
		if arrFolioSiguiente(0, 0) = "0" then
			Response.Write "<center><font color='#900C3F'>El cliente " & Session("array_client")(2,0) & " no cuenta con folios reservados disponibles para documentar, favor de verificarlo con el &aacute;rea de facturaci&oacute;n. [0x000026]</font></center>"
			Response.End 
		else
			iFolioSiguiente = arrFolioSiguiente(0, 0)
			iFolioSiguiente = apartarNUI(num_client,SQLEscape(request.serverVariables("REMOTE_ADDR")),iFolioSiguiente)
		end if
	end if

	arrTalon = obtiene_talon_x_nui(iFolioSiguiente)
	
	if IsArray(arrTalon) then
		sTalon = arrTalon(0,0)
	end if
%>
	<table class="datos" id="ltl_manif" align="center" BORDER="1" cellpadding="2" cellspacing="0" width="940">
		<thead>
			<tr class="titulo_trading_bold" valign="center" align="center"> 
				<td>N&deg; Cliente</td>
				<td>Raz&oacute;n Social</td>
				<%if hacer_corte = "S" then%>
					<td>N&deg; Corte</td>
				<%end if%>
				<td>Recolecci&oacute;n a Domicilio</td>
				<td>Fecha de Recolecci&oacute;n</td>
			</tr>
		</thead>
		<tbody>
			<tr valign="center" align="center"> 
				<td class="center">
					<%
						if wel_cliclef = "" then
							Response.Write num_client
						else
							Response.Write wel_cliclef
						end if
					%>
				</td>
				<td class="center">
					<%=nom_client%>
				</td>
				<%if hacer_corte = "S" then%>
					<td id="wel_manif_corte_view">&nbsp;<%=wel_manif_corte%></td>
				<%end if%>
				<td id="td_wel_recoleccion_domicilio" class="center">
					<%
						if NVL(wel_fecha_recoleccion) = "" then
							Response.Write "No"
							welrecol_domicilio = "N"
						else
							welrecol_domicilio = "S"
						end if
					%>
				</td>
				<td id="td_wel_fecha_recoleccion" class="center">
					<%
						if NVL(wel_fecha_recoleccion) <> "" then
							Response.Write wel_fecha_recoleccion
						end if
					%>
				</td>
			</tr>  
		</tbody>
	</table>
	<br/>
	<br/>
	<table class="datos" id="ltl_datos" align="center" BORDER="1" cellpadding="2" cellspacing="0" width="940">
		<thead>
			<tr class="titulo_trading_bold" valign="center" align="center">
				<td title="N&uacute;mero &Uacute;nico de Identificaci&oacute;n">NUI</td>
				<%
					if ConDocFuente = true then
						%>
							<td>Doc Fuente</td>
							<td>Factura</td>
						<%
					elseif ConFactura = true then
						%>
							<td>Factura</td>
						<%
					else
						%>
							<td>Tal&oacute;n</td>
						<%
					end if
				%>
				<td>Cdad Bultos</td>
				<td>Destinatario</td>
				<td>Ciudad (estado)</td>
				<td>Cedis Dest</td>
				<!--<td>Tipo</td>-->
				<td>Acciones</td>
			</tr>
		</thead>
		<tbody>
			<%
				arrayLTL = ""
				if NVL(wel_manif_num) <> "" then
					arrayLTL = obtiene_talones_x_manifiesto(wel_cliclef,wel_manif_num,wel_manif_corte)
				end if
				
				if IsArray(arrayLTL) then
					for i = 0 to UBound(arrayLTL, 2)
						%>
							<tr valign='center' align='center'>
								<td><%=arrayLTL(0, i)%></td> 
								<%
									if es_captura_con_factura(wel_cliclef) = true then
										%>
											<td><%=arrayLTL(9, i)%></td>
										<%
									elseif es_captura_con_doc_fuente(wel_cliclef) = true then
										%>
											<td><%=arrayLTL(10, i)%></td>
											<td><%=arrayLTL(9, i)%></td>
										<%
									else
										%>
											<td><%=arrayLTL(1, i)%></td> 
										<%
									end if
								%>
								
								<td><%=arrayLTL(2, i)%></td> 
								<td><%=arrayLTL(4, i)%></td> 
								<td><%=arrayLTL(5, i)%> (<%=arrayLTL(6, i)%>)</td>
							<!-- <<< CHH-DESA-13032024-01 se comenta td 
							<!--	<td><%=arrayLTL(8, i)%></td> -->
							<!-- CHH-DESA-13032024-01 >>> --> 
								<td><%=arrayLTL(7, i)%></td>
								<td><a href='javascript:imprimirEtiquetas(<%=arrayLTL(0, i)%>)'><img src='./images/label.gif' style='border:none; cursor:pointer;' alt='Imprimir etiquetas'></a> </td>
							</tr>
						<%
					next
				end if
			%>
		</tbody>
	</table>
	<br/>
	<br/>
	<%
		array_tmp = obtiene_cambia_ciudad(Session("array_client")(2,0))
		cambia_ciudad = array_tmp(0,0)
		
		'verificar si tenemos que forzar el usuario a capturar la cantidad de remisiones
		array_tmp = forzar_remisiones_usuario(Session("array_client")(2,0))
		
		if CInt(array_tmp(0, 0)) > 0 then   
			forzar_remisiones = true
		else
			forzar_remisiones = false
		end if
		%>
			<div id="dvLtlCaptura"  style="width: 940px; margin-left:auto; margin-right: auto; border: thin solid red; text-align:left">
			<div class="titulo_trading_bold" style="/*width: 794px;*/ text-align:left; padding: 3px; margin-bottom:5px">
				Nuevo tal&oacute;n
				<%
					if ConFactura = true then
						Response.Write("(con Factura)")
					elseif ConDocFuente = true then
						Response.Write("(con Documento Fuente)")
					end if
				%>
				:
			</div>
			<%Randomize%>
			<form id="ltl_form" name="ltl_form" action="documentacion_nui_process.asp?q=<%=Rnd%>" method="post">
				<div class="wrapper">
					<table>
						<tr>
							<td colspan="6">
								<table>
									<tr>
										<td align="right" style="padding-right:15px;" valign="middle">
											<span>Recolecci&oacute;n a domicilio:</span>
										</td>
										<td colspan="3">
											<table>
												<tr>
													<td>
														<input type="checkbox" id="recoleccion_domicilio" name="recoleccion_domicilio" value="S" onclick="display_fecha();" />
													</td>
													<td>
														<div id="fecha_div" class="hidden font-size-13-i">
															Fecha recoleccion deseada<font color="red">*</font>
															<input type="text" size="12" class="light" id="fecha_recoleccion" name="fecha_recoleccion" readonly="readonly" />
															<img src="include/dynCalendar/dynCalendar.gif" id="fecha_recoleccion_trigger" title="Date selector" alt="Seleccionar fecha" valign="middle" />
															<script type="text/javascript">
																Calendar.setup({
																	inputField: "fecha_recoleccion",
																	ifFormat: "%d/%m/%Y",
																	button: "fecha_recoleccion_trigger",
																	singleClick: true
																});
															</script>&nbsp;&nbsp;&nbsp;
															Hora&nbsp;
															<select id="hora_recoleccion" name="hora_recoleccion" class="light">
																<%
																	arrNum = obtener_serie_numerica(0,23)
																	
																	if IsArray(arrNum) then
																		for i = 0 to UBound(arrNum, 2)
																			if i = Hour(now) then
																				if i < 10 then
																					Response.Write "<option value='" & arrNum(0,i) & "' selected='selected'>0" & arrNum(0,i) & "</option>" & vbCrLf & vbTab
																				else
																					Response.Write "<option value='" & arrNum(0,i) & "' selected='selected'>" & arrNum(0,i) & "</option>" & vbCrLf & vbTab
																				end if
																			else
																				if i < 10 then
																					Response.Write "<option value='" & arrNum(0,i) & "' >0" & arrNum(0,i) & "</option>" & vbCrLf & vbTab
																				else
																					Response.Write "<option value='" & arrNum(0,i) & "' >" & arrNum(0,i) & "</option>" & vbCrLf & vbTab
																				end if
																			end if
																		next
																	end if
																%>
															</select>
															<select id="minutos_recoleccion" name="minutos_recoleccion" class="light">	
																<%
																	arrNum = obtener_serie_numerica(0,55)
																	
																	if IsArray(arrNum) then
																		for i = 0 to UBound(arrNum, 2) step 5
																			if i = Minute(now) then
																				if i < 10 then
																					Response.Write "<option value='" & arrNum(0,i) & "' selected='selected'>0" & arrNum(0,i) & "</option>" & vbCrLf & vbTab
																				else
																					Response.Write "<option value='" & arrNum(0,i) & "' selected='selected'>" & arrNum(0,i) & "</option>" & vbCrLf & vbTab
																				end if
																			else		
																				Response.Write "<option value='" & arrNum(0,i) & "' >"
																				if i < 10 then
																					Response.Write "0"
																				end if
																				Response.Write arrNum(0,i)
																				Response.Write "</option>" & vbCrLf & vbTab
																			end if
																		next
																	end if
																%>
															</select>
														</div>
													</td>
												</tr>
											</table>
										</td>
									</tr>
									<tr>
										<td align="right" style="padding-right:15px;" valign="middle">
											<span>Remitente:</span>
										</td>
										<td colspan="3">
											<select id="DISCLEF" name="DISCLEF" class="light">
												<%
													'<<<CHG-DESA-08032024-02: Se reemplaza la funci�n para obtener los remitentes a mostrar en pantalla:
														'array_tmp = obtener_distribuidor(print_clinum)
														'
														'if not IsArray(array_tmp) then
														'	array_tmp = obtener_distribuidor_x_cliente(print_clinum)
														'end if
														array_tmp = obtener_remitente_x_cliente_usuario(print_clinum)
													'<<<CHG-DESA-08032024-02
													
													if IsArray(array_tmp) then
														for i = 0 to Ubound(array_tmp,2)
															Response.Write "<option value='" & array_tmp(0,i) & "'>"
																Response.Write array_tmp(1,i)
															Response.Write "</option>" & vbCrLf & vbTab
															'wel_disclef = array_tmp(0,0)
														next
													end if
												%>
											</select>
											&nbsp;&nbsp;
										</td>
									</tr>
									<tr>
										<td align="right">
											<span >
												Destinatario:
											</span>
										</td>
									</tr>
									<tr>
										<td align="right">
											<span class="mandatory">C.P.:</span>
										</td>
										<td>
											<input type="text" class="light" name="txtCP" id="txtCP" onkeyup="txt_numerico(this);" />
											<!--<<< CHG-DESA-19032024 se añade hidden para comprobar la dieclave-->
											<select class="hidden" style="visibility:collapse;display:none;" name="hdnRes" id="hdnRes" onchange="res_function(event);">
											</select>
											<!-- CHG-DESA-19032024 >>>-->
										</td>
										<td>
											<select name="LE_ESTESTADO" id="LE_ESTESTADO" class="light">
												<option>Estado</option>
											</select>
										</td>
										<td>
											<div id="CIUDADES">
												<select name="LA_CIUDAD" id="LA_CIUDAD" class="light">
													<option> Ciudad </option>
												</select>
											</div>
										</td>
									</tr>
									<tr>
										<td>
											&nbsp;
										</td>
										<td colspan="5" align="left">
											<select name="wel_dieclave" id="wel_dieclave" class="light" style="width: 70%;">
												<option> Destinatario </option>
											</select>
										</td>
									</tr>
									<tr>
										<td colspan="6">
											<br/>
											<hr/>
											<br/>
										</td>
									</tr>
									<tr>
										<td colspan="6" align="left">
											<b>
												<span style="text-align: center;">
													Para agregar un nuevo destinatario, enviar un correo a <font color="blue">admin_destinatarios@logis.com.mx</font> y a su ejecutiva de atencion a cliente.
												</span>
											</b>
										</td>
									</tr>
									<tr>
										<td colspan="6">
											<br/>
											<hr/>
											<br/>
										</td>
									</tr>
									<%
										if ConFactura = true or ConDocFuente = true then
											%>
												<tr>
													<td align="right" valign="middle">
														<span>Facturas a Capturar:</span>
													</td>
													<td colspan="3">
														<input type="text" class="light width-60" id="txtCantFacturas" name="txtCantFacturas" onkeyup="txt_numerico(this);" />
														<input type="hidden" id="hdnCantFacturas" name="hdnCantFacturas" />
													</td>
												</tr>
												<tr>
													<td colspan="6" style="padding-left:1%;">
														<table id="tblFacturas" name="tblFacturas" class="datos tblFacturas">
															<thead>
																<tr class="titulo_trading_bold">
																	<%
																		if ConDocFuente = true then
																			%>
																				<th class="font-size-12">
																					Documento Fuente
																				</th>
																			<%
																		end if
																	%>
																	<th class="font-size-12">
																		No. Factura
																	</th>
																	<th class="font-size-12 width-11p">
																		Complemento
																	</th>
																	<th class="font-size-12">
																		Lineas de Captura
																	</th>
																	<th class="font-size-12">
																		Valor Mxn
																	</th>
																	<th class="font-size-12">
																		No. de Orden de compra
																	</th>
																	<th class="font-size-12">
																		No. Pedido
																	</th>
																</tr>
															</thead>
															<tbody>
															</tbody>
														</table>
														<!-- <<< CGH-DESA-13032024-01 se crea span para mostrare mensaje de limite caracteres-->
                                                         <span style="color: red; font-size:13px;" id="lblTotalCaracteres" > </span> 
														<!-- CHG-DESA-13032024-01 >>> -->
														<input type="hidden" name="welfactura" id="welfactura" value="<%=welfactura%>" />
														<input type="hidden" name="hdn_welfactura" id="hdn_welfactura" value="<%=hdn_welfactura%>" />
														<input type="hidden" name="welimporte" id="welimporte" value="<%=welimporte%>" />
													</td>
												</tr>
											<%
										else
											%>
												<tr>
													<td align="right" class="lil_red">
														<span id="l_welfactura">
															No. Referencia:
														</span>
													</td>
													<td>
														<input type="text" name="welfactura" id="welfactura" class="light texto-sin-comillas" size="35" value="<%=welfactura%>" onkeyup="eliminaEliminar_Comillas(this);" />
														<input type="text" name="hdn_welfactura" id="hdn_welfactura" class="light hidden" value="<%=hdn_welfactura%>" />
													</td>
													<td align="right">
														<%
															if iCCOClave <> -1 then
																response.write "<span class='mandatory'>"
															end if
														%>
														<span id="l_welimporte">
															Valor Mercanc&iacute;a:
														</span>
													</td>
													<td>
														<input type="text" name="welimporte" id="welimporte" class="light solo-numero-dec" size="10" maxlength="14" />
													</td>
												</tr>		
											<%
										end if
									%>
									<tr>
										<td align="right">
											<span>
												Condiciones de Entrega:
											</span>
										</td>
										<td>
											<select id="cmbCondicionesEntrega" name="cmbCondicionesEntrega">
												<option value="entrega_domicilio">Entrega a domicilio</option>
												<option value="ocurre_logis">Ocurre Logis</option>
											</select>
										</td>
										<td align="right">
											<span class="mandatory">
												Dice contener:
											</span>
										</td>
										<td>
											<span style="float:left">
												<textarea cols="40" rows="3" class="light texto-sin-comillas" name="welobservacion" id="welobservacion" onkeyup="eliminaEliminar_Comillas(this);"></textarea>
											</span>
										</td>
									</tr>
									<tr>
										<td align="right">
											Pagado / Por Cobrar:
										</td>
										<td>
											<select id="wel_collect_prepaid" name="wel_collect_prepaid" class="light">
												<%
													'<<<CHG-DESA-14032024-02: Se implementa funcion para que solo los clientes del listado puedan ver la opcion "Por Cobrar", el resto veran solo la opcion "Prepagado".
													if ClienteXcobrar(num_client) = true then
														%>
															<option value="POR COBRAR" selected="selected">Por Cobrar</option>
														<%
													else
														%>
															<option value="PREPAGADO" selected="selected">Prepagado</option>
														<%
													end if
													'   CHG-DESA-14032024-02>>>
												%>
											</select>
										</td>
										<td align="right">
											Observaciones:
										</td>
										<td>
											<span style="float:left">
												<textarea class="light texto-sin-comillas" cols="40" id="wts_observaciones_nui" maxlength="150" name="wts_observaciones_nui" onkeyup="eliminaEliminar_Comillas(this);" rows="3"></textarea>
											</span>
										</td>
									</tr>
									<tr id="trOcurreLogis" class="hidden">
										<td align="right">
											<span id="contacto" class="mandatory">Contacto:</span>
										</td>
										<td>
											<input type="text" id="le_contacto"  name="le_contacto" class="light" />
										</td>
										<td align="right">
											<span id="phone" class="mandatory">Tel&eacute;fono:</span>
										</td>
										<td>
											<input type="text" id="le_phone" name="le_phone" class="light" />
										</td>
										<td>&nbsp;</td>
									</tr>
									<tr>
										<td colspan="6">
											<br/>
											<hr/>
											<br/>
										</td>
									</tr>
									<tr>
										<td colspan="6" align="center">
											<table>
												<tr>
													<td align="right">
														<span>Bultos Totales:</span>
													</td>
													<td>
														<input type="hidden" id="wel_cdad_bultos" name="wel_cdad_bultos" />
														<input type="text" class="light" id="wel_cdad_bultosAux" name="wel_cdad_bultosAux" size="10" maxlength="12" onkeyup="txt_numerico(this);"/>
													</td>
													<td>
														&nbsp;
													</td>
													<td align="right">
														<span class="mandatory">Tarimas:</span>
													</td>
													<td>
														<input type="text" class="light solo-numero" id="wel_cdad_tarimas" name="wel_cdad_tarimas" size="10" maxlength="12" onkeyup="txt_numerico(this);" onchange="renglones_por_tarima();" />
														<input type="hidden" id="hdnCantTarimas" name="hdnCantTarimas" />
													</td>
													<td>
														&nbsp;
													</td>
													<td align="right">
														<span style="font-style: italic;">Que contienen</span>&nbsp;<span class="mandatory">Cant. Cajas Totales:</span>
													</td>
													<td>
														<input type="text" name="wel_cajas_tarimas" id="wel_cajas_tarimas" class="light solo-numero" size="10" maxlength="14" onkeyup="txt_numerico(this);" />
													</td>
												</tr>
											</table>
										</td>
									</tr>
									<tr>
										<td>
											<br/>
										</td>
									</tr>
									<tr>
										<td colspan="3" align="right">
											<span style="font-weight: bold;">&iquest;Desea detallar la cantidad de cajas por tarima?</span>
											&nbsp;
											<input type="checkbox" name="detalle_tarimas" id="detalle_tarimas" value="S" onclick="JavaScript:show_detalle_tarimas();" />
										</td>
									</tr>
									<tr>
										<td>
											<br/>
										</td>
									</tr>
									<tr id="bloque_detalle_tarimas" style="display: none;">
										<td colspan="3">
											&nbsp;
										</td>
										<td colspan="3">
											<table id="tableEmbalaje" name="tableEmbalaje" style="border: thin solid gray;width:200px;">
												<thead>
													<tr>
														<th colspan="2" style="font-size:10px;">
															Detalle de captura de Tarimas
															<br/><hr/>
														</th>
													</tr>
													<tr>
														<th style="font-size:10px;">Tarima</th>
														<th style="font-size:10px;"><span class="mandatory">Cantidad</span></th>
														<!--<th class="hidden" style="font-size:10px;">N� Tarima (cliente)</th>-->
													</tr>
												</thead>
												<tbody>
												</tbody>
											</table>
											<table id="tableTotal" style="border: thin solid gray;width:200px;">
												<tr>
													<td class="center">
														Total
													</td>
													<td>
														<span id="lblTotalCajasTarima">0</span>
														<input type="hidden" id="hdnTotalCajasTarima" name="hdnTotalCajasTarima" value="0" />
													</td>
												</tr>
											</table>
										</td>
									</tr>
									<tr id="tarifa4">
										<td align="right" colspan="3">
											<span class="mandatory">Cant. Bultos a granel:</span>
										</td>
										<td colspan="2">
											<!--	<<Cambio20240503: 2.-No permitir documentar más de 25 bultos a Granel
											<input type="text" name="welcdad_cajas" id="welcdad_cajas" class="light solo-numero" size="10" maxlength="12" onkeyup="txt_numerico(this);" />	-->
												<input type="text" name="welcdad_cajas" id="welcdad_cajas" class="light solo-numero" size="10" maxlength="2" onkeyup="txt_numerico(this);valorMaximo(this.id,25);" />
											<!--	  Cambio20240503>>	-->
											<%
												array_tmp = obtiene_tipo_bultos(num_client)
												
												If IsArray(array_tmp) Then
													%>
														<select id="tpa_caja" name="tpa_caja" class="light required">
															<%
																For i = 0 To Ubound(array_tmp, 2)
																	Response.Write "<option value=""" & array_tmp(0,i) & """" & array_tmp(2,i)  & ">"
																	Response.Write array_tmp(1,i) & "</option>" & VbCrLf
																Next
															%>
														</select>
													<%
												Else
													Response.Write "<p>Something bad went wrong</p>"
												End If
											%>
											<label id="lblwelcdad_cajas" name="lblwelcdad_cajas" class="error margin-5" style="display:none;font-size:smaller;font-style:normal;">
												La cantidad de bultos a granel no puede exceder de 25.
											</label>
											<input type="text" disabled class="light hidden" id="welcdad_cajasAux" name="welcdad_cajasAux" size="10" maxlength="14" />
										</td>
									</tr>
									<tr>
										<td>
											<br/>
										</td>
									</tr>
									<tr>
										<td colspan="1" align="right">
											Total del Registro:
										</td>
										<td>
											<input type="text" disabled class="light" id="totalRegAux" name="totalRegAux" size="10" maxlength="14" />
											<input type="text" disabled class="light hidden" id="totalReg2Aux" name="totalReg2Aux" size="10" maxlength="14" />
										</td>
										<!--
										<td>
											&nbsp;
										</td>
										-->
										<td align="right" id="td_BultosConstitutivos_label" class="">
											Bultos Constitutivos:
										</td>
										<td id="td_BultosConstitutivos_field" class="">
											<input type="text" disabled class="light" id="totalReg3Aux" name="totalReg3Aux" size="10" maxlength="14" />
										</td>
									</tr>
								</table>
							</td>
						</tr>
					<tr>
						<td colspan="6">
							<br/>
							<hr/>
							<br/>
						</td>
					</tr>
					<tr>
						<td colspan="6">
							<span style="float:left;margin-left:5px;">
								<input type="submit" id="button_guardar_ltl" value="Guardar" class="button_trading" style="margin-bottom: 2px; float:left"/>
								<img src="images/Throbber-mac.gif" id="throbber_wel" class="escondido" style="margin-bottom: -2px;float:left" />
							</span>
						</td>
					</tr>
				</table>
			</div>
			<%
				if cliente_cobrar_prepago(num_client) = false then
					%>
						<input type="hidden" id="wel_collect_prepaid_1" name="wel_collect_prepaid_1" value="PREPAGADO" />
					<%
				end if
				
				if wel_cliclef = "" then
					wel_cliclef = num_client
				end if
				'<<<CHG-DESA-07032024-02: Se eliminan �stas l�neas que modifican el Remitente a uno incorrecto:
					'if wel_disclef = "" then
					'	array_tmp = obtener_distribuidor_x_cliente(wel_cliclef)
					'	wel_disclef = array_tmp(0,i)
					'end if
				'   CHG-DESA-07032024-02>>>
				' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
				'Se obtiene el Remitente por Numero de Cliente y por Usuario que inicio Sesion:
				array_tmp = obtener_remitente_x_cliente_usuario(num_client)
				if IsArray(array_tmp) then
					wel_disclef = array_tmp(0,0)
				end if
				
				' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
				'Se obtiene Almacen Origen por Remitente:
				arrayLTL = obtener_cedis_por_remitente(wel_disclef)
				if IsArray(arrayLTL) then
					wel_allclave_ori = arrayLTL(0,0)
				end if
			%>
			<input type="hidden" name="welClave" id="welClave" value="<%=iFolioSiguiente%>" />
			<input type="hidden" name="welTalon" id="welTalon" value="<%=sTalon%>" />
			<input type="hidden" name="wel_manif_num" id="wel_manif_num" value="<%=wel_manif_num%>" />
			<input type="hidden" name="wel_manif_fecha" id="wel_manif_fecha" value="<%=wel_manif_fecha%>" />
			<input type="hidden" name="wel_fecha_recoleccion" id="wel_fecha_recoleccion" value="<%=wel_fecha_recoleccion%>" />
			<input type="hidden" name="welrecol_domicilio" id="welrecol_domicilio" value="<%=welrecol_domicilio%>" />
			<input type="hidden" name="wel_allclave_ori" id="wel_allclave_ori" value="<%=wel_allclave_ori%>" />
			<input type="hidden" name="wel_disclef" id="wel_disclef" value="<%=wel_disclef%>" />
			<input type="hidden" name="wel_cliclef" id="wel_cliclef" value="<%=wel_cliclef%>" />
			<input type="hidden" name="hacer_corte" id="hacer_corte" value="<%=hacer_corte%>" />
			<input type="hidden" name="wel_manif_corte" id="wel_manif_corte" value="<%=wel_manif_corte%>" />
			<input type="hidden" name="wel_dxpclave_recol" id="wel_dxpclave_recol" value="<%=mi_dxpclave%>" />
			<input type="hidden" name="iCveEmpresa" id="iCveEmpresa" value="<%=iCveEmpresa%>" />
			<input type="hidden" name="iCCOClave" id="iCCOClave" value="<%=iCCOClave%>" />
			<input type="hidden" name="WBD_MODULO" id="WBD_MODULO" />
			<input type="hidden" name="reco" value="<%=reco%>" />
			<input type="hidden" name="ConFactura" id="ConFactura" value="<%=ConFactura%>" />
			<input type="hidden" name="ConDocFuente" id="ConDocFuente" value="<%=ConDocFuente%>" />
		</form>
	</body>
</html>