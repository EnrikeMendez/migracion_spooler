<%@ Language=VBScript %>
<% option explicit 
%><!--#include file="include/include.asp"--><%
'Response.Expires = 0
call check_session()

'affichage du popup pour la fonction filtre_col
call print_popup()
Dim  SQL,FolSelect


'initialisation des num de page
Dim PageSize, PageNum
PageSize = 20
PageNum = Request("PageNum")
if Not IsNumeric(PageNum) or Len(PageNum) = 0 then
   PageNum = 1
else
   PageNum = CInt(PageNum)
end if
 
SQL = " SELECT DIS.DISCLEF"
SQL = SQL &  " ,INITCAP(CLI.CLINOM) "
SQL = SQL &  " ,INITCAP(DIS.DISNOM) "
SQL = SQL &  " ,INITCAP(L_VIL.VILNOM) || ' (' || INITCAP(EST.ESTNOMBRE) || ')'"
SQL = SQL &  " FROM EDISTRIBUTEUR DIS"
SQL = SQL &  " ,ECLIENT CLI"
SQL = SQL &  " ,ECIUDADES L_VIL"
SQL = SQL &  " ,EESTADOS EST"
SQL = SQL &  " ,EPAISES PAY"
SQL = SQL &  " WHERE DIS.DISCLIENT = CLI.CLICLEF"
SQL = SQL &  " and DISCLIENT IN  ("& print_clinum &") "
if not(IP_interna) then
	SQL = SQL & " AND DIS.DISCLEF in ("& print_login_remitente &") " & VbCrlf
end if
SQL = SQL &  " AND DIS.DISETAT = 'A' " & VbCrlf
SQL = SQL &  " AND L_VIL.VILCLEF = DIS.DISVILLE"
SQL = SQL &  " AND L_VIL.VIL_ESTESTADO = EST.ESTESTADO"
SQL = SQL &  " AND EST.EST_PAYCLEF = PAY.PAYCLEF"
SQL = SQL &  " AND PAY.PAYCLEF = 'N3'"
SQL = SQL &  " ORDER BY DIS.DISNOM"
'Response.Write Replace(SQL, vbCrLf, "<br>")
'Response.End 
Dim arrayTemp
arrayTemp = GetArrayRS(SQL)


Response.Write print_headers("Remitentes LTL", "ltl", "", "", "")
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
	Response.End 
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

%>
<table class="datos" width="100%">
<tr><td align="right"><a href="ltl_remitentes-dl.asp"><img src="./images/document-save.png" style="width:22px; height:22px; border:none; vertical-align:middle;" alt="Download"></a>
<a href="ltl_remitentes-dl.asp">Download</a>
</td>
</tr>
</table>

<table class="datos" align="center" BORDER="1" cellpadding="2" cellspacing="0" width="900">
 <thead>
    <tr class="titulo_trading_bold" valign="center" align="center">
        <td>N° Remitente</td>
        <td>Cliente</td>
        <td>Remitente</td>
        <td>Ciudad (Estado)</td>
	</tr>
 </thead>
 <tbody>
<%


For iRowLoop = iStart to iStop
%>
<tr align=center>
<td>&nbsp;<%=arrayTemp(0,iRowLoop)%></td>
<td>&nbsp;<%=arrayTemp(1,iRowLoop)%></td>
<td>&nbsp;<%=arrayTemp(2,iRowLoop)%></td>
<td>&nbsp;<%=arrayTemp(3,iRowLoop)%></td>
</tr>
<%
next
%>

</tbody>
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
	</form>
	<%call BuildNav2(PageNum, PageSize, iRows +1,"next_page")%>
</BODY>
</HTML>

