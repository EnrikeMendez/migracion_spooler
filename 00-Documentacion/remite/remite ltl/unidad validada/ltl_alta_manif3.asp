<%@ Language=VBScript %>
<% option explicit 
%><!--#include file="include/include.asp"--><%
dim qa
	qa = ""
'Response.Expires = 0
call check_session()

	if not cliente_habilidatado_doc(Session("array_client")(2,0)) then
		Response.Redirect "new_home" & qa & ".asp?msg=" & Server.URLEncode("Cliente desactivado")
	end if

	Dim  SQL,FolSelect, rst, script_include, style_include
	Dim arrayTemp, array_entrega
	Dim Cliente
	'<<CHG-DESA-10052023-01:Talones de Recolección
		Cliente=print_clinum
		Dim reco
		reco = Request.QueryString("reco")
	'CHG-DESA-04052023-01>>

	script_include = "<!-- main calendar program -->" & vbCrLf & _
			 "<script type=""text/javascript"" src=""include/jscalendar/calendar.js""></script>" & vbCrLf & _
			 "<!-- language for the calendar -->" & vbCrLf & _
			 "<script type=""text/javascript"" src=""include/jscalendar/lang/calendar-es.js""></script>" & vbCrLf & _
			 "<!-- the following script defines the Calendar.setup helper function, which makes" & vbCrLf & _
			 "      adding a calendar a matter of 1 or 2 lines of code. -->" & vbCrLf & _
			 "<script type=""text/javascript"" src=""include/jscalendar/calendar-setup.js""></script>" & vbCrLf

	style_include = "<!-- calendar stylesheet -->" & vbCrLf & _
					"<link rel=""stylesheet"" type=""text/css"" media=""all"" href=""include/jscalendar/skins/aqua/theme.css"" title=""Aqua"" />" & vbCrLf & _
		   			"<script language=""JavaScript"" src=""include/js/jquery-1.2.3.js""></script>" & vbCrLf & _
					"<script language=""JavaScript"" src=""include/js/jquery.form.js""></script>" & vbCrLf & _
					"<script language=""JavaScript"" src=""include/js/jquery-select.js""></script>" & vbCrLf & _
					"<script language=""javascript"" type=""text/javascript"" src=""include/js/firebug_lite/firebug.js""></script>" & vbCrLf & _
					"<script src=""include/js/DynamicOptionList.js"" type=""text/javascript"" language=""javascript""></script>"


	Response.Write print_headers_nocache("Captura Manifiesto", "ltl", script_include, style_include, "")

%>
	<img src="images/pixel.gif" width="0" height="100" border="0">
	<div id="menu" style="text-align:center; z-index:1;">


	<%'affichage du popup pour la fonction filtre_col
	call print_popup()
	%>	
	<style type="text/css">
		img {
			behavior:	url("include/js/pngbehavior.htc");
		}
	</style>
	<script language="javascript">
		//<!--
		function _Get(id) {
			return document.getElementById(id);
		}
	
		function display_fecha() {
			if (_Get("recoleccion_domicilio").checked) {
				_Get("fecha_div").className = 'visible td';
			}
			else {
				_Get("fecha_div").className = 'escondido';
			}
		}

		function redirect_smo() {
			ref_json=  'disclef=' + $("#DISCLEF").val();

			$.ajaxSetup({async: false})
			$.ajax ({
				type:"GET",
				url:"ajax_redirect_smo.asp",
				data: ref_json,
				dataType:'text',
				success: function(data){
					//alert(data);
					<%If Request.QueryString("encabezado") = "1" then%>
					if(data=='1'){
						<%If Request.QueryString("debug") = "1" Then%>
							_Get("manifesto_form").action="ltl_captura_encabezado3<%=qa%>.asp?debug=1";
						<%Else%>
							_Get("manifesto_form").action="ltl_captura_encabezado3<%=qa%>.asp";
						<%End If%>
					}
					<%End If%>

					//alert(data);
				},
				error: function(msg, url, line) {
            		alert('Hubo un error.');
				}
			});
		}
		//<<CHG-DESA-10052023-01:Talones de recoleccion
		<%
			if reco = "" then
				%>
					//CHG-DESA-10052023-01>>	
					function validarManifesto(var1) {
				
						//verificacion de la fecha
						var fecha = new Date();
						fecha.setDate(_Get("fecha_recoleccion").value.split('/')[0]);
						fecha.setMonth(_Get("fecha_recoleccion").value.split('/')[1]-1);
						fecha.setFullYear(_Get("fecha_recoleccion").value.split('/')[2]);
						var minDate = new Date();
						var maxDate = new Date();
						minDate.setFullYear(<%=year(now)%>,<%=month(now)-1%>,<%=day(now)%>);
						maxDate.setFullYear(<%=year(now)%>,<%=month(now)-1%>,<%=day(now)%>);
						minDate = minDate.setDate(minDate.getDate()-5);
						maxDate = maxDate.setDate(maxDate.getDate()+5);

						//if  ((_Get("recoleccion_domicilio").checked) && (_Get("num_recol").value == '') )
						//{		
							//	alert('Para el cliente ' + var1  + ' se debe de ingresar el numero de recoleccion.');
						//}		
						//else 
						if ((_Get("recoleccion_domicilio").checked) && ((_Get("fecha_recoleccion").value == '') || (fecha < minDate) || (fecha > maxDate))) {
							alert('Verificar la fecha de recoleccion deseada.\nNo puede ser superior o inferior a 5 dias.');
						}
						else {
							redirect_smo();
							_Get("manifesto_form").submit();
						}
					}
				//<<CHG-DESA-10052023-01:Talones de recoleccion
		<%
			else
				'recoleccion
				%>
					function validarManifesto(var1)
					{
						//verificacion de la fecha
						var fecha = new Date();
						fecha.setDate(_Get("fecha_recoleccion").value.split('/')[0]);
						fecha.setMonth(_Get("fecha_recoleccion").value.split('/')[1]-1);
						fecha.setFullYear(_Get("fecha_recoleccion").value.split('/')[2]);
						var minDate = new Date();
						var maxDate = new Date();
						minDate.setFullYear(<%=year(now)%>,<%=month(now)-1%>,<%=day(now)%>);
						maxDate.setFullYear(<%=year(now)%>,<%=month(now)-1%>,<%=day(now)%>);
						minDate = minDate.setDate(minDate.getDate()-5);
						maxDate = maxDate.setDate(maxDate.getDate()+5);

						//if  ((_Get("recoleccion_domicilio").checked) && (_Get("num_recol").value == '') )
						//{		
						//		alert('Para el cliente ' + var1  + ' se debe de ingresar el numero de recoleccion.');
						//}		
						//else 
						if ((_Get("recoleccion_domicilio").checked) && ((_Get("fecha_recoleccion").value == '') || (fecha < minDate) || (fecha > maxDate)))
						{
							alert('Verificar la fecha de recoleccion deseada.\nNo puede ser superior o inferior a 5 dias.');
						}
						else
						{
								_Get("manifesto_form").submit();
						}
					}
					$(function()
					{
						$("#DISCLEF").change(function()
						{
							recol_valid();
						});
					});
					function recol_valid()
					{
						//alert("test");
						
						ref_json=  'client=' + "<%=Cliente%>";
						ref_json= ref_json+'&disclef=' + $("#DISCLEF").val();
						
						$.ajaxSetup({async: false})
						$.ajax ({
							type:"GET",
							url:"ajax_a_tarif_recol.asp",
							data: ref_json,
							dataType:'text',
							success:function(data)
							{
								if(data=='N')
								{
									document.getElementById("recoleccion_domicilio").checked = false;
									_Get("fecha_div").className = 'escondido';
									//document.getElementById("recoleccion_domicilio").style.display = "none";
									document.getElementById("reco_domi").className = 'escondido';
									document.getElementById("no_tarif").className = 'visible td';
								}
								else
								{
									_Get("fecha_div").className = 'visible td';
									//document.getElementById("recoleccion_domicilio").style.display = "block";
									document.getElementById("reco_domi").className = 'visible td';
									document.getElementById("no_tarif").className = 'escondido';
								};
							}
						});
					}
				<%
			end if
		%>
		//CHG-DESA-10052023-01>>
		//-->
	</script>
	<%dim dest_form
	Cliente=print_clinum

	if Request.QueryString("encabezado") = "1" then
		'dest_form = "ltl_captura_encabezado2" & qa & ".asp"
		dest_form = "ltl_captura_encabezado3" & qa & ".asp"
		if Request.QueryString("debug") = "1" then
			dest_form = dest_form & "?debug=1"
		end if
	elseif Session("ltl_doc_convertidor") = "1" then
		dest_form = "ltl_convertidor" & qa & ".asp"
	else
		dest_form = "ltl_consulta" & qa & ".asp?tipo=1"
	end if%>
	<form id="manifesto_form" name="manifesto_form" action="<%=dest_form%>" method="post">
		<br><br>
		<table align="center" width="90%" border="1" class="datos">
			<tr align=left> 
				<td  class="titulo_trading">Crear Manifiesto:</td>
			</tr>
			<tr>
				<td> 
					<table align="center" width="100%" border="0" class="datos">
						<tr valign="top" class="datos">
							<td>Remitente:
								<%Dim array_tmp,i
								SQL = "SELECT DIS.DISCLEF " & VbCrlf
								SQL = SQL & " , INITCAP(DIS.DISNOM || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')') " & VbCrlf
								SQL = SQL & " , DECODE(DIS.DISCLEF, '"& print_login_remitente &"', 'selected', NULL) " & VbCrlf
								SQL = SQL & " FROM EDISTRIBUTEUR DIS " & VbCrlf
								SQL = SQL & " , ECIUDADES CIU " & VbCrlf
								SQL = SQL & " , EESTADOS EST " & VbCrlf
								SQL = SQL & " WHERE DISCLIENT IN ("& print_clinum &") " & VbCrlf
								'if not(IP_interna) then
								'	SQL = SQL & " AND DIS.DISCLEF in ("& print_login_remitente &") " & VbCrlf
								'end if
								SQL = SQL & " AND DIS.DISETAT = 'A' " & VbCrlf
								SQL = SQL & " AND CIU.VILCLEF = DIS.DISVILLE " & VbCrlf
								SQL = SQL & " AND EST.ESTESTADO = CIU.VIL_ESTESTADO " & VbCrlf
								if Session("ltl_internacional") = "1" then
									'agregar EEUU y Canada
									SQL = SQL & "  AND EST.EST_PAYCLEF IN ('N3', 'G8', 'D9', 'I6') " & VbCrlf
								else
									SQL = SQL & "  AND EST.EST_PAYCLEF = 'N3' " & VbCrlf
								end if
								SQL = SQL & " ORDER BY DISNOM"
								array_tmp = GetArrayRS(SQL)
								if IsArray(array_tmp) then
								%> 
									<select id="DISCLEF" name="DISCLEF" class="light">
										<%For i = 0 to Ubound(array_tmp,2)
											Response.Write "<option value="""& array_tmp(0,i) &""" "& array_tmp(2,i) &">" & array_tmp(1,i) & vbCrLf & vbTab 
										Next%>
									</select> 
								<%
								else
									Response.Write "<font color=""red"">No hay remitentes</font>"
								end if%>&nbsp;&nbsp;
								<!--<<CHG-DESA-10052023-01:Talones de recoleccion-->
								<%
									if reco = "1" then
										Response.Write "<br/><br/>"
									end if
								%>
								<!--CHG-DESA-10052023-01>>-->
						
								<%if Request.QueryString("encabezado") = "1" then%>
									Fecha de entrada<font color="red">*</font>
									<input type="text" size="12" class="light" id="fecha_entrada" name="fecha_entrada" readonly value="<%=day(now)%>/<%=month(now)%>/<%=year(now)%>">
									<img src="include/dynCalendar/dynCalendar.gif" id="fecha_entrada_trigger" title="Date selector" alt="Date selector"  valign="top"/>
									<script type="text/javascript">
										Calendar.setup({
											inputField     :    "fecha_entrada",     // id of the input field
											ifFormat       :    "%d/%m/%Y",      // format of the input field
											button         :    "fecha_entrada_trigger",  // trigger for the calendar (button ID)
											//align          :    "Tl",           // alignment (defaults to "Bl")
											singleClick    :    true
										});
									</script>&nbsp;&nbsp;&nbsp;
									Hora &nbsp;<select id="hora_entrada" name="hora_entrada" class="light">
										<%for i=0 to 23
											Response.Write vbTab & vbTab &"<option value=" & i 
											if i=Hour(now) then Response.Write " selected "
											Response.Write  ">" & i
										next%>
									</select>
									<select id="minutos_entrada" name="minutos_entrada" class="light">	
										<%for i=0 to 55 step 5
											Response.Write vbTab & vbTab &"<option value=" 
											if i < 10 then Response.Write "0"
											Response.Write i & ">" 
											if i < 10 then Response.Write "0"
											Response.Write i & vbCrLf
										next%>
									</select>
								<%end if%>
								&nbsp;&nbsp;&nbsp;N° Recoleccion &nbsp;<input type="text" name="num_recol" id="num_recol" size="12" class="light">
								<br>
								<%sql = "SELECT COUNT(0) " & VbCrlf
								SQL = SQL & " FROM ECONCEPTOSHOJA   " & VbCrlf
								SQL = SQL & "   , ECLIENT_APLICA_CONCEPTOS  " & VbCrlf
								SQL = SQL & " WHERE CHONUMERO IN (184)   " & VbCrlf
								SQL = SQL & " AND CHOTIPOIE = 'I'   " & VbCrlf
								SQL = SQL & " AND CCO_CLICLEF IN ("& print_clinum &") " & VbCrlf
								SQL = SQL & " AND EXISTS (  " & VbCrlf
								SQL = SQL & "   SELECT NULL  " & VbCrlf
								SQL = SQL & "   FROM EBASES_POR_CONCEPT  " & VbCrlf
								SQL = SQL & "   WHERE BPCCLAVE = CCO_BPCCLAVE  " & VbCrlf
								SQL = SQL & "   AND BPC_CHOCLAVE = CHOCLAVE  " & VbCrlf
								SQL = SQL & " )"
								array_tmp = GetArrayRS(SQL)
								Dim RecolDomChecked
								if CInt(array_tmp(0, 0)) > 0 or Session("array_client")(2,0) = "3295" then
									RecolDomChecked = "checked"
								end if
								%>
								<!--<<CHG-DESA-10052023-01:Talones de recoleccion-->
								<%
									if reco = "1" then
										Response.Write "<br/>"
									end if
								%>
								<!--CHG-DESA-10052023-01:>>-->
								<input type="checkbox" id="recoleccion_domicilio" name="recoleccion_domicilio" value="S" onclick="display_fecha();" <%=RecolDomChecked%>> Recoleccin a domicilio&nbsp;&nbsp;&nbsp;
								<!--/td-->
								<div id="fecha_div" <%if RecolDomChecked = "" then Response.Write "class='escondido'"%>>
									Fecha recoleccion deseada<font color="red">*</font>
									<input type="text" size="12" class="light" id="fecha_recoleccion" name="fecha_recoleccion" readonly>
									<img src="include/dynCalendar/dynCalendar.gif" id="fecha_recoleccion_trigger" title="Date selector" alt="Date selector" valign="middle" />
									<script type="text/javascript">
										Calendar.setup({
											inputField     :    "fecha_recoleccion",     // id of the input field
											ifFormat       :    "%d/%m/%Y",      // format of the input field
											button         :    "fecha_recoleccion_trigger",  // trigger for the calendar (button ID)
											//align          :    "Tl",           // alignment (defaults to "Bl")
											singleClick    :    true
										});
									</script>&nbsp;&nbsp;&nbsp;
									Hora&nbsp;<select id="hora_recoleccion" name="hora_recoleccion" class="light">
										<%for i=0 to 23
											Response.Write vbTab & vbTab &"<option value=" & i 
											if i=Hour(now) then Response.Write " selected "
											Response.Write  ">" & i
										next%>
									</select>
									<select id="minutos_recoleccion" name="minutos_recoleccion" class="light">	
										<%for i=0 to 55 step 5
											Response.Write vbTab & vbTab &"<option value=" 
											if i < 10 then Response.Write "0"
											Response.Write i & ">" 
											if i < 10 then Response.Write "0"
											Response.Write i & vbCrLf
										next%>
									</select>
								</div>
						
								<img src="./images/edit-undo.png" valign="middle" style="border:none;cursor:pointer; width: 16px; height: 16px;" onclick="validarManifesto('<%=Cliente%>');" onmouseover="return overlib('Enviar peticin de Manifiesto');" onmouseout="return nd();" alt="Validar">
						
								<input type="hidden" name="etapa" value="1">
								<input type="hidden" name="corte" value="<%=Request("corte")%>">
								<!-- <<CHG-DESA-10052023-01:Talones de recoleccion-->
								<input type="hidden" name="reco" value="<%=Request.QueryString("reco")%>" />
								<!-- CHG-DESA-10052023-01>>-->
							</td>
						</tr>
						<%if UBound(Split(print_clinum, ",")) > 0 then%>
							<tr>
								<td>
									<img src="images/pixel.gif" border="0" height="10" width="0" >
								</td>
							</tr>
							<tr>
								<td class="titulo_trading"><b>Numero de cliente</b> <font color="red"><i>(Obligatorio)</i></font>:</td></td>
							</tr>
							<tr>
								<td>
									<table style="border-width:1px;border-style:solid;border-color:red;" cellpadding="0" cellspacing="0" width="100%">
										<%Call print_radio_client2()%>
									</table>
								</td>
							</tr>
						<%else
							Call print_radio_client2()
						end if
						%>
					</table>
				</td>
			</tr>
		</table>
	</form>
</BODY>
</HTML>