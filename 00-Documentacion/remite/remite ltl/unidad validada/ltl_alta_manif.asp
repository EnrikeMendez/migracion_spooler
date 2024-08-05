<%@ Language=VBScript %>
<% option explicit 
%><!--#include file="include/include.asp"--><%
'Response.Expires = 0
dim qa
	qa = ""
call check_session()

if not cliente_habilidatado_doc(Session("array_client")(2,0)) then
    Response.Redirect "new_home" & qa & ".asp?msg=" & Server.URLEncode("Cliente desactivado")
end if

Dim  SQL,FolSelect, rst, script_include, style_include
Dim arrayTemp, array_entrega


script_include = "<!-- main calendar program -->" & vbCrLf & _
		 "<script type=""text/javascript"" src=""include/jscalendar/calendar.js""></script>" & vbCrLf & _
		 "<!-- language for the calendar -->" & vbCrLf & _
		 "<script type=""text/javascript"" src=""include/jscalendar/lang/calendar-es.js""></script>" & vbCrLf & _
		 "<!-- the following script defines the Calendar.setup helper function, which makes" & vbCrLf & _
		 "      adding a calendar a matter of 1 or 2 lines of code. -->" & vbCrLf & _
		 "<script type=""text/javascript"" src=""include/jscalendar/calendar-setup.js""></script>" & vbCrLf

style_include = "<!-- calendar stylesheet -->" & vbCrLf & _
		"<link rel=""stylesheet"" type=""text/css"" media=""all"" href=""include/jscalendar/skins/aqua/theme.css"" title=""Aqua"" />" & vbCrLf


Response.Write print_headers("Captura Manifiesto", "ltl", script_include, style_include, "")

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
	
	function validarManifesto() {
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
		if ((_Get("recoleccion_domicilio").checked) && ((_Get("fecha_recoleccion").value == '') || (fecha < minDate) || (fecha > maxDate))) {
			alert('Verificar la fecha de recoleccion deseada.\nNo puede ser superior o inferior a 5 dias.');
		}
		else {
			_Get("manifesto_form").submit();
		}
	}
	
//-->
</script>

<%dim dest_form

' << JEMV-2022-03-08: Se deshabilita la opción como parte de la unificación de pantallas.
if Request.QueryString("encabezado") = "" then
'	Response.Write "Modulo no valido."
'	Response.End
end if
'  JEMV-2022-03-08 >>

if Request.QueryString("encabezado") = "1" then
    'dest_form = "ltl_captura_encabezado" & qa & ".asp"
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
				
				'<<20230517: El filtro se hará sólo por cliente:
				'	'<<20230516: Para este segmento se mostrarán todos los Remitentes:
				'	if Left(Request.ServerVariables("REMOTE_ADDR"),11) = "192.168.29." then
				'	else
				'		if not(IP_interna) then
				'			SQL = SQL & " AND DIS.DISCLEF in ("& print_login_remitente &") " & VbCrlf
				'		end if
				'	end if
				'	'  20230516>>
				'  20230517>>
				
				SQL = SQL & " AND DIS.DISETAT = 'A' " & VbCrlf
				SQL = SQL & " AND CIU.VILCLEF = DIS.DISVILLE " & VbCrlf
				SQL = SQL & " AND EST.ESTESTADO = CIU.VIL_ESTESTADO " & VbCrlf
				SQL = SQL & " AND EST.EST_PAYCLEF = 'N3' " & VbCrlf
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
				
			<%if Request.QueryString("encabezado") = "1" then%>
				Fecha de entrada<font color="red">*</font>
			   <input type="text" size="12" class="light" id="fecha_entrada" name="fecha_entrada" readonly value="<%=day(now)%>/<%=month(now)%>/<%=year(now)%>">
			   <img src="include/dynCalendar/dynCalendar.gif" id="fecha_entrada_trigger" title="Date selector" alt="Date selector" />
			   <script type="text/javascript">
					Calendar.setup({
						inputField     :    "fecha_entrada",     // id of the input field
						ifFormat       :    "%d/%m/%Y",      // format of the input field
						button         :    "fecha_entrada_trigger",  // trigger for the calendar (button ID)
						//align          :    "Tl",           // alignment (defaults to "Bl")
						singleClick    :    true
					});
				</script>&nbsp;&nbsp;&nbsp;
				Hora<select id="hora_entrada" name="hora_entrada" class="light">
				<%for i=0 to 23
					Response.Write vbTab & vbTab &"<option value=" & i 
					if i=Hour(now) then Response.Write " selected "
					Response.Write  ">" & i
				next%></select>
				<select id="minutos_entrada" name="minutos_entrada" class="light">	
				<%for i=0 to 55 step 5
					Response.Write vbTab & vbTab &"<option value=" 
					if i < 10 then Response.Write "0"
					Response.Write i & ">" 
					if i < 10 then Response.Write "0"
					Response.Write i & vbCrLf
				next%></select>
		    <%end if%>
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
				<input type="checkbox" id="recoleccion_domicilio" name="recoleccion_domicilio" value="S" onclick="display_fecha();" <%=RecolDomChecked%>> Recolección a domicilio&nbsp;&nbsp;&nbsp;
			 <!--/td-->
			 <div id="fecha_div" <%if RecolDomChecked = "" then Response.Write "class='escondido'"%>>
			   Fecha recoleccion deseada<font color="red">*</font>
			   <input type="text" size="12" class="light" id="fecha_recoleccion" name="fecha_recoleccion" readonly>
			   <img src="include/dynCalendar/dynCalendar.gif" id="fecha_recoleccion_trigger" title="Date selector" alt="Date selector" />
			   <script type="text/javascript">
					Calendar.setup({
						inputField     :    "fecha_recoleccion",     // id of the input field
						ifFormat       :    "%d/%m/%Y",      // format of the input field
						button         :    "fecha_recoleccion_trigger",  // trigger for the calendar (button ID)
						//align          :    "Tl",           // alignment (defaults to "Bl")
						singleClick    :    true
					});
				</script>&nbsp;&nbsp;&nbsp;
				Hora<select id="hora_recoleccion" name="hora_recoleccion" class="light">
				<%for i=0 to 23
					Response.Write vbTab & vbTab &"<option value=" & i 
					if i=Hour(now) then Response.Write " selected "
					Response.Write  ">" & i
				next%></select>
				<select id="minutos_recoleccion" name="minutos_recoleccion" class="light">	
				<%for i=0 to 55 step 5
					Response.Write vbTab & vbTab &"<option value=" 
					if i < 10 then Response.Write "0"
					Response.Write i & ">" 
					if i < 10 then Response.Write "0"
					Response.Write i & vbCrLf
				next%></select>
				 </div>
				
				<img src="./images/edit-undo.png" style="border:none;cursor:pointer; width: 16px; height: 16px;" onclick="validarManifesto();" onmouseover="return overlib('Enviar petición de Manifiesto');" onmouseout="return nd();" alt="Validar">
				
				<input type="hidden" name="etapa" value="1">
				<input type="hidden" name="corte" value="<%=Request("corte")%>">
			 </td>
			</tr>
			<%if UBound(Split(print_clinum, ",")) > 0 then%>
            <tr><td><img src="images/pixel.gif" border="0" height="10" width="0"></td></tr>
            <tr>
            	<td class="titulo_trading"><b>N&uacute;mero de cliente</b> <font color="red"><i>(Obligatorio)</i></font>:</td></td>
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