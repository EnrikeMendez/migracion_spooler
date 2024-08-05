<% option explicit
response.expires=0
%><!--#include file="include/include.asp"-->
<!--#include file="include/include_asp/adovbs.asp"-->
<%
call check_session()
Dim qa
	qa = ""
Dim tipo_carga
	tipo_carga = "LTL"

if es_captura_con_doc_fuente(Session("array_client")(2,0)) = true then
	tipo_carga = "UNICA"
end if
if es_captura_sin_factura(Session("array_client")(2,0)) = true then
	tipo_carga = "SIN_FACTURA"
end if
if es_captura_con_factura(Session("array_client")(2,0)) = true then
	tipo_carga = "CON_FACTURA"
end if
%>
<style type="text/css">
.code {
	font-family: arial;
	font-size: 10px;
	background: #DDD;
	margin: 10 50px 10 50px;
	padding: 10 10px;
	border: 1px solid;
}
</style>
<%
Dim SQL, SQL2, array_tmp, i, script_include, style_include
Dim arrRow,arrColumn
Dim contents
	contents = request.Form("container")
'==============================
'Validar el tipo de archivo
'==============================
'if Cstr(request.Form("tipo"))="xlsl" then
	'contents=Replace(Replace (contents, "[{",""), "}]","")
	'arrRow=Split(contents,"},")
	
	'for i = 0 to UBound(arrRow)
		'arrColumn = arrColumn & (Split(arrRow(i), ",")(0)) &","
	'next
	'arrLineCollection = Split (arrColumn, ",")

'else 'txt/csv
	'arrLineCollection = Split (contents, vbCRLF)
'end if'tipo de archivo
					
	
''''''''select case Request.QueryString("tipo")
''''''''	case "cd"
''''''''	case "unico"
''''''''		 Response.Write print_headers("Carga de archivo", "cd", "", "", "")
		Response.Write print_headers("Carga de archivo", "ltl", "", "", "")
		%>
		<div id="observaciones" style="position: relative; left: 50; top: 0;">
			<img src="./images/pixel.gif" width="0" border="0" height="100"/>
			<br/><br/>
			<%
				'if Session("array_client")(2,0) = "3885" or Session("array_client")(2,0) = "3624" or Session("array_client")(2,0) = "3081" or Session("array_client")(2,0) = "13128"  or Session("array_client")(2,0) = "17873" or Session("array_client")(2,0) = "20341" or Session("array_client")(2,0) = "20305" or Session("array_client")(2,0) = "20501" or Session("array_client")(2,0) = "20502" or Session("array_client")(2,0) = "20123" or Session("array_client")(2,0) = "23488" or Session("array_client")(2,0) = "23489" then
					%>
						<form name="file_form" enctype="multipart/form-data"  action="doc_masiva_nuis_process.asp" method="post"  onsubmit='document.file_form.submit.disabled=true'>
							<%
								SQL2 = "SELECT COUNT(0) FROM WEB_LTL WHERE WELSTATUS = 3 AND WEL_CLICLEF = '" & Session("array_client")(2,0) & "'"
								array_tmp = GetArrayRS(SQL2)
								'Response.Write SQL2
								if array_tmp(0, 0) = "0" then
									Response.Write "<center><font color='#900C3F'>El cliente " & Session("array_client")(2,0) & " no cuenta con folios reservados disponibles para documentar, favor de verificarlo con el &aacute;rea de facturaci&oacute;n.</font></center> <input type='hidden' name='resbd' id='resbd' value = '0'/>"
									Response.End
								else
									%>
										<div class="container" id="btnCargaArchivo">
											<table width="450" cellspacing="0" cellpadding="3" border="0">
												<tr class="titulo_trading" valign="center" align="left">
													<td><font color="#FFFFFF" style="font-size:10pt"><b>.</font>Agregar un archivo<b> :</b></td>
												</tr>
												<tr>
													<td valign="center"><input type="file" name="archivo_carga" onchange="showFile(this)" size="70"></td>
													<input type="hidden" name="container" id="container" />
													<input type="hidden" name="resbd" id="resbd" value = "<%=array_tmp(0, 0)%>"/>
												</tr>
											</table>
										</div>
									<%
								end if
							%><!--Fin del if del Query -->
							<div class="container" name="btnsCondicionados" id="btnsCondicionados" style="visibility: visible ">
								<table width="450" cellspacing="0" cellpadding="3" border="0">
									<tr>
										<td>&nbsp;</td>
									</tr>
									<tr class="titulo_trading" valign="center" align="left">
										<td>Remitente: </td>
									</tr>
									<tr>
										<td>
											<%
												SQL = "SELECT DIS.DISCLEF " & VbCrlf
												SQL = SQL & " , INITCAP(DIS.DISNOM || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')') " & VbCrlf
												SQL = SQL & " , DECODE(DIS.DISCLEF, '"& print_login_remitente &"', 'selected', NULL) "
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
												SQL = SQL & " AND EST.EST_PAYCLEF = 'N3' " & VbCrlf
												SQL = SQL & " ORDER BY DISNOM"
												
												array_tmp = GetArrayRS(SQL)
												
												if IsArray(array_tmp) then
													%>
														<select id="disclef" name="disclef" class="light">
															<%
																For i = 0 to Ubound(array_tmp,2)
																	Response.Write "<option value="""& array_tmp(0,i) &""" "& array_tmp(2,i) &">" & array_tmp(1,i) & vbCrLf & vbTab
																Next
															%>
														</select>
													<%
												else
													Response.Write "<font color=""red"">No hay remitentes</font>"
												end if
											%>
										</td>
									</tr>
									<tr>
										<td>&nbsp;</td>
									</tr>
									<tr class="titulo_logis">
										<td colspan="2"><font color="#FFFFFF" style="font-size:10pt"><b>.</font>Correo<b> :</b></td>
									</tr>
									<tr>
										<td>
											Ingrese su correo electronico para recibir el resultado de la carga.
											<br/> <img src="images/email.png" style="margin-top: 10px;position: absolute;" width="20" />&nbsp;
											<input type="email" name="correo" id="correo" size="65" class="light" style="margin-top: 10px;margin-left: 20px;width: 410px;" />
											<input type="hidden" name="form_name" value="carga_web" />
											<input type="hidden" name="tipo_carga" value="<%=tipo_carga%>" />
										</td>
									</tr>
									<%call print_radio_client()%>
								</table>
							</div>
							<br/><input type="submit" name="submit" value="Documentar"  class="button_trading" />
						</form>
					<%
				'end if
			%><!--Fin del if que valida sesion -->
		</div>
		
		<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.8.0/jszip.js"></script>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/xlsx/0.8.0/xlsx.js"></script>
		<script type="text/javascript">
			function showFile(input)
			{
				var resultado;
				
				if (document.getElementById("lblMsg") != null)
				{
					document.getElementById("lblMsg").innerText = "";
				}
				
				let file = input.files[0];
				let reader = new FileReader();
				
				if (!file)
				{
					alert("Fallo al abrir el archivo");
				}
				else if (!file.type.match('xlsx'))
				{
					reader.onload = function (e)
									{
										var data = e.target.result;
										var workbook = XLSX.read(data, {type: 'binary'});
										workbook.SheetNames.forEach(function (sheetName)
																	{
																		var XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);
																		
																		if (XL_row_object != "")
																		{
																			var datos = document.forms[0].container.value = XL_row_object.length;
																			
																			if (datos > document.forms[0].resbd.value)
																			{
																				var divAocultar = document.getElementById('btnsCondicionados');
																				divAocultar.style.visibility = "hidden";
																				alert("El cliente <%=Session("array_client")(2,0)%> no cuenta con folios reservados suficientes para documentar este archivo, favor de verificarlo con el área de facturación.")
																			}
																			else
																			{
																				var divAocultar = document.getElementById('btnsCondicionados');
																				divAocultar.style.visibility = "visible";
																			}
																			
																			var json_object = JSON.stringify(XL_row_object);
																			var keyCount  = Object.keys(json_object).length;
																			
																			resultado = keyCount
																		}
																	})
									};
					reader.onerror = function (ex)
									{
										console.log(ex);
									};
					reader.readAsBinaryString(file);
				}
				else
				{
					document.forms[0].tipo.value = "txt";
					reader.onload = function ()
									{
										document.forms[0].container.value = reader.result;
										document.forms[0].tipo.value = (file.name).substring((file.name).length - 3);
									};
					reader.onerror = function ()
									{
										console.log(reader.error);
									};
					reader.readAsText(file);
				}
			}
		</script>
	</body>
</html>