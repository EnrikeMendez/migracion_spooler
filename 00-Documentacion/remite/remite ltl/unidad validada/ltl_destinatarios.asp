<%@ Language=VBScript %>
<% option explicit 
%><!--#include file="include/include.asp"--><%
'Response.Expires = 0
call check_session()
Dim  SQL,FolSelect, dest_name, estado, filtro, rst


'desactivacion de destinatario
if Request.Form("etapa") = "1" then

    SQL = "UPDATE WEB_CLIENT_CLIENTE " & vbCrLf
    SQL = SQL & " SET WCCL_STATUS = 0 " & vbCrLf
    SQL = SQL & " , MODIFIED_BY = UPPER('"& Session("array_client")(0,0) &"-WCCL_CAN') " & vbCrLf
    SQL = SQL & " , DATE_MODIFIED = SYSDATE " & vbCrLf
    SQL = SQL & " WHERE WCCLCLAVE = "& SQLEscape(Request.Form("wcclclave")) & vbCrLf
    
    set rst = Server.CreateObject("ADODB.Recordset")
    rst.Open SQL, Connect(), 0, 1, 1

end if


'affichage du popup pour la fonction filtre_col
call print_popup()


dest_name = Ucase(SQLEscape(Request.Form("dest_name")))
wccl_ville = SQLescape(Request.Form("wccl_ville"))
estado = SQLescape(Request.Form("estado"))

if dest_name <>"" then
  filtro = " AND CCL.WCCL_NOMBRE LIKE ('%"& dest_name &"%')  "
end if

if estado <>"" then
  filtro = filtro & " AND EST.ESTESTADO IN ("& estado &") "
end if

if wccl_ville <>"" then
  filtro = filtro &  " AND L_VIL.VILCLEF IN ("& wccl_ville &") "
end if  



'initialisation des num de page
Dim PageSize, PageNum
PageSize = 20
PageNum = Request("PageNum")
if Not IsNumeric(PageNum) or Len(PageNum) = 0 then
   PageNum = 1
else
   PageNum = CInt(PageNum)
end if

SQL = "SELECT CCL.WCCLCLAVE " & VbCrlf
SQL = SQL & "  ,INITCAP(CLI.CLINOM) " & VbCrlf
SQL = SQL & "  ,INITCAP(CCL.WCCL_NOMBRE)   " & VbCrlf
SQL = SQL & "  ,INITCAP(CCL.WCCLABREVIACION)   " & VbCrlf
SQL = SQL & "  ,INITCAP(L_VIL.VILNOM) || ' (' || INITCAP(EST.ESTNOMBRE) || ')'  " & VbCrlf
SQL = SQL & "  ,CCL.WCCLCLAVE  " & VbCrlf
'SQL = SQL & "  , COUNT(WELCLAVE) " & VbCrlf
SQL = SQL & "  , (SELECT COUNT(0) FROM WEB_LTL WHERE WEL_WCCLCLAVE = WCCLCLAVE AND ROWNUM = 1) " & VbCrlf
SQL = SQL & "  , CCL.WCCL_RFC " & VbCrlf
SQL = SQL & "  FROM WEB_CLIENT_CLIENTE CCL " & VbCrlf
SQL = SQL & "  ,ECLIENT CLI " & VbCrlf
SQL = SQL & "  ,ECIUDADES L_VIL " & VbCrlf
SQL = SQL & "  ,EESTADOS EST " & VbCrlf
SQL = SQL & "  ,EPAISES PAY " & VbCrlf
'SQL = SQL & "  ,WEB_LTL WEL " & VbCrlf
SQL = SQL & "  WHERE CCL.WCCL_CLICLEF = CLI.CLICLEF " & VbCrlf
SQL = SQL & "  AND CCL.WCCL_CLICLEF IN ("& print_clinum &") " & VbCrlf
SQL = SQL & "  AND L_VIL.VILCLEF = CCL.WCCL_VILLE " & VbCrlf
SQL = SQL & "  AND L_VIL.VIL_ESTESTADO = EST.ESTESTADO " & VbCrlf
SQL = SQL & "  AND EST.EST_PAYCLEF = PAY.PAYCLEF " & VbCrlf
SQL = SQL & "  AND PAY.PAYCLEF = 'N3' " & VbCrlf
'SQL = SQL & "  AND WEL.WEL_WCCLCLAVE(+) = CCL.WCCLCLAVE " & VbCrlf
SQL = SQL & "  AND CCL.WCCL_STATUS = 1 " & VbCrlf
SQL = SQL &  filtro
SQL = SQL & "  GROUP BY CLI.CLICLEF " & VbCrlf
SQL = SQL & "  ,INITCAP(CLI.CLINOM) " & VbCrlf
SQL = SQL & "  ,INITCAP(CCL.WCCL_NOMBRE)   " & VbCrlf
SQL = SQL & "  ,INITCAP(CCL.WCCLABREVIACION)   " & VbCrlf
SQL = SQL & "  ,INITCAP(L_VIL.VILNOM) || ' (' || INITCAP(EST.ESTNOMBRE) || ')'  " & VbCrlf
SQL = SQL & "  ,CCL.WCCLCLAVE  " & VbCrlf
SQL = SQL & "  , CCL.WCCL_RFC " & VbCrlf
SQL = SQL & "  ORDER BY 3"

'Response.Write Replace(SQL, vbCrLf, "<br>")'("& print_clinum &") "
'Response.End 
Dim arrayTemp
arrayTemp = GetArrayRS(SQL)
session ("tab_destinatarios") = arrayTemp

dim script_include
 
script_include = "<!-- script for selects -->" & vbCrLf & _
				 "<script src=""include/js/DynamicOptionList.js"" type=""text/javascript"" language=""javascript""></script>"

Response.Write print_headers("Destinatarios LTL", "ltl", script_include, "", "initDynamicOptionLists();")

%>	
<style type="text/css">
img {
	behavior:	url("include/js/pngbehavior.htc");
}
</style>
<img src="images/pixel.gif" width="0" height="100" border="0">
<div id="menu" style="text-align:center; z-index:1;">
<%
if not IsArray (arrayTemp) then
	response.write "No records found !"
%>
	<br><br><br><br>
     <table class="datos"  border="1" cellpadding="0" cellspacing="0" width="900">
	  <tr class="datos" > 
        <td colspan="6" align="left"><img src="./images/contact-new.png" style="width:22px; height:22px; vertical-align:middle;" alt="Nuevo destinatario"> 
           <a href="ltl_destinatarios_captura.asp">Agregar un destinatario</a><br><br>
        </td>
      </tr>
    </table>  
<%Response.End
end if


Dim iRows, iCols, iRowLoop, iColLoop, iStop, iStart
Dim iRows2, iCols2
 iRows = UBound(arrayTemp , 2)
 iCols = UBound(arrayTemp , 1) 


If iRows > (PageNum * PageSize ) Then
   iStop = PageNum * PageSize - 1
Else
   iStop = iRows
End If
  
iStart = (PageNum -1 )* PageSize
If iStart > iRows then iStart = iStop - PageSize  'inutile en principe... mais bon si on modifie la variable pagenum...

'Response.Write "iStart  " & iStart & " iStop  "  &iStop 
'selection des 20 num de folios 
For iRowLoop = iStart to iStop
	FolSelect = FolSelect & ", " & CSTR(arrayTemp(0,iRowLoop))
Next  

%><table class="datos" width="100%">
<tr><td align="right"><a href="ltl_destinatarios-dl.asp"><img src="./images/document-save.png" style="width:22px; height:22px; border:none; vertical-align:middle;" alt="Download"></a>
<a href="ltl_destinatarios-dl.asp">Download</a>
</td>
</tr>
</table>
<form name="modif_dest_form" action="ltl_destinatarios_captura.asp" method="post">
	<input type="hidden" name="wcclclave" value="">
</form>
<script language="javascript">
	function modif_dest(wcclclave) {
		document.modif_dest_form.wcclclave.value = wcclclave;
		document.modif_dest_form.submit();
	}
</script>

<form name="desactivar_dest" action="<%=asp_self()%>" method="post">
	<input type="hidden" name="wcclclave" value="">
	<input type="hidden" name="PageNum" value="<%=TAGEscape(Request.Form("PageNum"))%>">
	<input type="hidden" name="dest_name" value="<%=Ucase(TAGEscape(Request.Form("dest_name")))%>">
	<input type="hidden" name="estado" value="<%=Ucase(TAGEscape(Request.Form("estado")))%>">
	<input type="hidden" name="wccl_ville" value="<%=Ucase(TAGEscape(Request.Form("wccl_ville")))%>">
	<input type="hidden" name="etapa" value="1">
</form>
<script language="javascript">
	function desactivar_dest(wcclclave) {
		document.desactivar_dest.wcclclave.value = wcclclave;
		if (confirm('¿ Esta seguro de desactivar este destinatario ?') == true) {
			document.desactivar_dest.submit();
		}
	}
</script>
<%if Request.QueryString("msg") <> "" then%>
	<center><font color="red"><b><%=Request.QueryString("msg")%></b></font></center>
<%end if%>
    <table class="datos" align="center" border="0" cellpadding="2" cellspacing="0" width="900">
    <tr> 
      <td valign="top">
      <table align="left" border="1" cellpadding="0" cellspacing="0" width="900">
         <thead>
          <tr class="titulo_trading_bold" align="center">
            <td><b>N°</b></td>
            <td><b>Nombre</b></td>
            <td><b>Destinatario</b></td>
            <td><b>Abreviacion</b></td>
            <td><b>Ciudad (Estado)</b></td>
            <td>&nbsp;</td>
          </tr>
         </thead>
          <tbody>
            <%For iRowLoop = iStart to iStop%>
            <tr class="datos" align="center" <%if iRowLoop mod 2 = 0 then Response.Write  " bgcolor=""#FFFFEE"""%>> 
				<td>&nbsp;<%=filtre_col(arrayTemp(0,iRowLoop),180,"")%></td>
				<td>&nbsp;<%=filtre_col(arrayTemp(1,iRowLoop),180,"")%></td>
				<td>&nbsp;<%=filtre_col(arrayTemp(2,iRowLoop),180,"")%></td>
				<td>&nbsp;<%=filtre_col(arrayTemp(3,iRowLoop),180,"")%></td>
				<td>&nbsp;<%=arrayTemp(4,iRowLoop)%></td>
				<td>
				<%if arrayTemp(6,iRowLoop) = "0" or NVL(arrayTemp(7,iRowLoop)) = "" then%>
					<img src="./images/accessories-text-editor.png" style="width:16px; height:16px; cursor:pointer;" onclick="javascript:modif_dest(<%=arrayTemp(5,iRowLoop)%>);" onmouseover="return overlib('Modificar destinatario');" onmouseout="return nd();" alt="Modificar">
				<%else%>
					<img src="./images/contact-new-16x16.png" style="width:16px; height:16px; cursor:pointer;" onclick="javascript:modif_dest(<%=arrayTemp(5,iRowLoop)%>);" onmouseover="return overlib('Ver detalle destinatario');" onmouseout="return nd();" alt="Ver">
				<%end if%>
				<%if IP_interna then
				    Response.Write "&nbsp;&nbsp;<a href='javascript:desactivar_dest(" & arrayTemp(0,iRowLoop) & ");'><img src='./images/edit-delete.png' style='border:none; cursor:pointer; width: 16px; height: 16px;' alt='Cancelar Destinatario' title='Cancelar Destinatario'></a> "
				end if%>
				</td>
            </tr>
            <%next%>
            <tr class="datos" > 
              <td colspan="6" align="left"><img src="./images/contact-new.png" style="width:22px; height:22px; vertical-align:middle;" alt="Nuevo destinatario"> 
                <a href="ltl_destinatarios_captura.asp">Agregar un destinatario</a><br><br>
              </td>
            </tr>
            <tr> 
              <td class="titulo_trading_bold" colspan="6" align="left" class="inicio"><b>&nbsp;Criterios de Restricción</b></td>
            </tr>
            <tr> 
             <td colspan="6" align="left">
             <form action="ltl_destinatarios.asp" method="post" name="dest_form" target="_self" id="dest_form">
                  Nombre del Destinatario: 
                    <input name="dest_name" type="text" id="dest_name" class="light" size =25 value="<%=Ucase(TAGEscape(Request.Form("dest_name")))%>"/>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Estado: 
                    <%dim wccl_ville,array_tmp,i,wccl_estado
				SQL = "SELECT EST.ESTESTADO " & VbCrlf
				SQL = SQL & "  , InitCap(EST.ESTNOMBRE) " & VbCrlf
				SQL = SQL & "  , DECODE(EST.ESTESTADO, '" & Request.Form("estado") & "', 'selected') " & VbCrlf
				SQL = SQL & " FROM EESTADOS EST  " & VbCrlf
				SQL = SQL & "  WHERE EST.EST_PAYCLEF = 'N3' " & VbCrlf
				SQL = SQL & "  ORDER BY EST.ESTNOMBRE"
				array_tmp = GetArrayRS(SQL)	
			%>
               <select name="estado" id="estado" class="light">
               <option value="<%Ucase(TAGEscape(Request.Form("estado")))%>">Todos 
               <%for i = 0 to Ubound(array_tmp,2)
			 	Response.Write "<option value=""" & array_tmp(0,i) & """ " & array_tmp(2,i) & ">" & array_tmp(1,i) & vbTab  & vbCrLf
				next
			%> </select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    Ciudad: 
                <script type="text/javascript">
				var dol = new DynamicOptionList();
				dol.addDependentFields("estado","wccl_ville");
				dol.setFormName("dest_form");
				<%
				for i = 0 to Ubound(array_tmp,2)
				Response.Write "dol.forValue("""& array_tmp(0,i) & """).addOptionsTextValue(""Todas las ciudades"","""");" & vbTab  & vbCrLf
				next
				
				'consulta solo ciudades con CEDIS asociados
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
				SQL = SQL &  "   and der_allclave > 0  "  & VbCrlf
				SQL = SQL &  "   ORDER BY CIU.VILNOM"	
				array_tmp = GetArrayRS(SQL)

				for i = 0 to Ubound(array_tmp,2)
					Response.Write "dol.forValue("""& array_tmp(0,i) & """).addOptionsTextValue(""" & array_tmp(3,i) & """,""" & array_tmp(2,i) & """);" & vbTab  & vbCrLf
                                next
				if NVL(wccl_estado) <> "" then
					response.write  "dol.forValue(""" & Request.Form("estado") & """).setDefaultOptions("" & wccl_ville & "");"
				end if
				%>
				</script>
                <select name="wccl_ville" id="wccl_ville" class="light"/>
                <script type="text/javascript">
					dol.printOptions("wccl_ville");
				</script>
				</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;  
				<input type="image" src="./images/edit-undo.png" onmouseover="return overlib('Validar restriccion');" onmouseout="return nd();">
			</form>
             </td>
            </tr>
          </tbody>
        </table></td>
    </tr>
</table>
</div>
<%
'NB : iRows contient le dernier indice du tableau donc nb_lignes -1 !
%>
<script language="javascript">
	function next_page(page_num)
	{document.next_page.PageNum.value = page_num;
	document.next_page.submit();
	}
	</script>
	<form name=next_page method=post>
	<input type="hidden" name="PageNum" value="<%=TAGEscape(Request.Form("PageNum"))%>">
	<input type="hidden" name="dest_name" value="<%=Ucase(TAGEscape(Request.Form("dest_name")))%>">
	<input type="hidden" name="estado" value="<%=Ucase(TAGEscape(Request.Form("estado")))%>">
	<input type="hidden" name="wccl_ville" value="<%=Ucase(TAGEscape(Request.Form("wccl_ville")))%>">
	</form>
	<%call BuildNav2(PageNum, PageSize, iRows +1,"next_page")%>
</BODY>
</HTML>

