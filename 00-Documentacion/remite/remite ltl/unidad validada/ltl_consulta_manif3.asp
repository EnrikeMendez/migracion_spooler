<%@ Language=VBScript %>
<% option explicit 
%><!--#include file="include/include.asp"--><%
'Response.Expires = 0
dim qa, rdf_test
    qa = ""
	rdf_test = ""
call check_session()

Dim  SQL,FolSelect, rst, numLTL, arrayManif, arrayTmp
Dim index_ltl

if Request.Form ("etapa") = "2" then
	SQL = " UPDATE WEB_LTL "
	SQL = SQL &  "  SET WEL_MANIF_NUM = NULL "  & vbCrLf
	SQL = SQL &  "  	, WEL_MANIF_FECHA = NULL "  & vbCrLf
	SQL = SQL &  "  	, WEL_MANIF_CORTE = NULL "  & vbCrLf
	SQL = SQL &  "  	, MODIFIED_BY = UPPER('"& Session("array_client")(0,0) &"') || '-CAN_MANIF' "  & vbCrLf
	SQL = SQL &  "  	, DATE_MODIFIED = SYSDATE "  & vbCrLf
	SQL = SQL &  "  WHERE WEL_MANIF_NUM IN ("& Request.Form("wel_manif_num")& ")" & vbCrLf
	SQL = SQL &  "  AND NVL(WEL_MANIF_CORTE, -1) = NVL('"& Request.Form("wel_manif_corte")& "', -1) " & vbCrLf
	SQL = SQL &  "  AND (WEL_TRACLAVE IS NULL OR not EXISTS (SELECT NULL FROM ETRANSFERENCIA_TRADING WHERE WEL_TRACLAVE = TRACLAVE AND TRASTATUS = '1')) " & vbCrLf
	SQL = SQL &  "  AND WEL_CLICLEF IN ("& print_clinum &") " 
	Session("SQL") = SQL
	set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open SQL, Connect(), 0, 1, 1
		
	Response.Redirect asp_self & "?msg=" & Server.URLEncode("Manifiesto cancelado.") 
end if

Response.Write print_headers_nocache("Consulta Manifiestos", "ltl", "", "", "")
%>	
<img src="images/pixel.gif" width="0" height="100" border="0">
<div id="menu" style="text-align:center; z-index:1;">

<style type="text/css">
		img {
			behavior:	url("include/js/pngbehavior.htc");
		}
</style>

<%
'initialisation des num de page
Dim PageSize, PageNum
PageSize = 20	
PageNum = Request("PageNum")
if Not IsNumeric(PageNum) or Len(PageNum) = 0 then
   PageNum = 1
else
   PageNum = CInt(PageNum)
end if

if Request("id") = "" and  Request("manif_num") = "" then
    index_ltl = "/*+INDEX(WEL IDX_WEL_CLI_DATE) USE_NL(EAL) INDEX(WEL IDX_WEL_CLICLEF)*/"
end if

'consulta del manifiesto	
SQL = " SELECT "& index_ltl &" WEL.WEL_MANIF_NUM " & VbCrlf
SQL = SQL &  "   , WEL.WEL_CLICLEF  " & VbCrlf
SQL = SQL &  "   , INITCAP(DIS.DISNOM) REMITENTE  " & VbCrlf
SQL = SQL &  "   , COUNT(WEL.WEL_MANIF_NUM) " & VbCrlf
SQL = SQL &  "   , MIN(TO_CHAR(WEL.WEL_MANIF_FECHA, 'DD/MM/YYYY HH24:MI'))  " & VbCrlf
SQL = SQL &  "   , WEL.WELRECOL_DOMICILIO  " & VbCrlf
SQL = SQL &  "   , DECODE(WEL.WELRECOL_DOMICILIO, 'N', NULL,TO_CHAR( WEL.WEL_FECHA_RECOLECCION, 'dd/mm/YYYY HH24:MI'))   " & VbCrlf
SQL = SQL &  "   , MAX(TRA.TRACLAVE) " & VbCrlf
SQL = SQL &  "   , SUM(ROUND(NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO) * (1 + (TIVTASA / 100)), 2)) " & VbCrlf
SQL = SQL &  "   , EAL.ALLCODIGO  " & VbCrlf
SQL = SQL &  "   , TRA.TRACLAVE " & VbCrlf
SQL = SQL &  "   , TRA.TRACONS_GENERAL " & VbCrlf
SQL = SQL &  "   , SUM(WEL_CDAD_BULTOS) " & VbCrlf
SQL = SQL &  "   , WEL.WEL_MANIF_CORTE " & VbCrlf
SQL = SQL &  "   , NVL(TPI2.TPI_FACTURA_CLIENTE, TPI.TPI_FACTURA_CLIENTE) " & VbCrlf
SQL = SQL &  "   , NVL(TPI2.TPI_TRACLAVE, TPI.TPI_TRACLAVE)  " & VbCrlf
SQL = SQL &  " FROM WEB_LTL WEL  " & VbCrlf
SQL = SQL &  "   , EDISTRIBUTEUR DIS " & VbCrlf
SQL = SQL &  "   , ETRANSFERENCIA_TRADING TRA " & VbCrlf
SQL = SQL &  "   , EALMACENES_LOGIS EAL " & VbCrlf
SQL = SQL &  "   , ETASAS_IVA " & VbCrlf
SQL = SQL &  "   , EDET_EXPEDICIONES DXP " & VbCrlf
SQL = SQL & "    , ETRANS_PICKING TPI " & VbCrlf
SQL = SQL & " 	 , ETRANS_ENTRADA " & VbCrlf
SQL = SQL & " 	 , EDET_EXPEDICIONES DXP2 " & VbCrlf
SQL = SQL & " 	 , ETRANS_PICKING TPI2 " & VbCrlf
SQL = SQL & " WHERE DIS.DISCLEF = WEL.WEL_DISCLEF  " & VbCrlf
SQL = SQL & "   AND WEL.WEL_TRACLAVE = TRA.TRACLAVE(+)  " & VbCrlf
SQL = SQL & "   AND WEL.WEL_CLICLEF IN ("& print_clinum &") " & VbCrlf
SQL = SQL & "   AND TRA.TRASTATUS(+) = '1' " & VbCrlf
if Request.QueryString("id") <> ""  then
	SQL = SQL & " AND WEL.WELCLAVE IN ( " & Request.QueryString("id") & " )" & VbCrlf
end if 
if Request("manif_num") <> ""  then
	SQL = SQL & " AND WEL_MANIF_NUM IN ( " & Request("manif_num") & " )" & VbCrlf
end if 
if Request("id") = "" and  Request("manif_num") = ""  then
    SQL = SQL &  " AND WEL.DATE_CREATED > SYSDATE - 30 " & vbCrLf 
end if
SQL = SQL &  "   AND WEL_MANIF_NUM IS NOT NULL " & VbCrlf
SQL = SQL &  "   AND WEL_MANIF_FECHA IS NOT NULL " & VbCrlf
SQL = SQL &  "   AND EAL.ALLCLAVE(+) = TRA.TRA_ALLCLAVE  " & VbCrlf
SQL = SQL &  "   AND TRUNC(WEL.DATE_CREATED) BETWEEN TIVFECINI AND TIVFECFIN " & VbCrlf
SQL = SQL &  "   AND TIVTASA >= 15 " & VbCrlf
'? IVA Oscar 25Nov2013
	SQL = SQL & " AND NVL(TIV_PAYSAAIM3, 'MEX') = 'MEX' " & VbCrlf
'?
SQL = SQL &  "   AND DXP.DXPCLAVE(+) = WEL_DXPCLAVE_RECOL  " & VbCrlf
SQL = SQL & "    AND TPI.TPI_TRACLAVE(+) = DXP.DXP_TRACLAVE  " & VbCrlf
SQL = SQL & " 	 AND TAE_TRACLAVE(+) = TRACLAVE " & VbCrlf
SQL = SQL & " 	 AND DXP2.DXPCLAVE(+) = TAE_DXPCLAVE " & VbCrlf
SQL = SQL & "    AND TPI2.TPI_TRACLAVE(+) = DXP2.DXP_TRACLAVE  " & VbCrlf
SQL = SQL &  " GROUP BY WEL.WEL_MANIF_NUM " & VbCrlf
SQL = SQL &  "   , WEL.WEL_CLICLEF  " & VbCrlf
SQL = SQL &  "   , DIS.DISNOM " & VbCrlf
SQL = SQL &  "   , WEL.WELRECOL_DOMICILIO " & VbCrlf
SQL = SQL &  "   , WEL.WEL_FECHA_RECOLECCION " & VbCrlf
SQL = SQL &  "   , TRA.TRACLAVE " & VbCrlf
SQL = SQL &  "   , TRA.TRACONS_GENERAL " & VbCrlf
SQL = SQL &  "   , EAL.ALLCODIGO  " & VbCrlf
SQL = SQL &  "   , WEL.WEL_MANIF_CORTE " & VbCrlf
SQL = SQL &  "   , NVL(TPI2.TPI_FACTURA_CLIENTE, TPI.TPI_FACTURA_CLIENTE) " & VbCrlf
SQL = SQL &  "   , NVL(TPI2.TPI_TRACLAVE, TPI.TPI_TRACLAVE)  " & VbCrlf
SQL = SQL &  " ORDER BY WEL_MANIF_NUM DESC, WEL.WEL_MANIF_CORTE DESC " & VbCrlf

'Response.Write Replace(SQL, vbCrLf, "<br>")
'response.end
arrayManif = GetArrayRS(SQL)
session ("tab_manif") = arrayManif

if not IsArray(arrayManif) then
	response.write "No records found !"
	Response.End 
end if


Dim iRows, iCols, iRowLoop, iColLoop, iStop, iStart
Dim iRows2, iCols2
 iRows = UBound(arrayManif , 2)
 iCols = UBound(arrayManif , 1) 


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
	FolSelect = FolSelect & ", " & CSTR(arrayManif(0,iRowLoop))
Next  

'affichage du popup pour la fonction filtre_col
call print_popup()
%>

<script language="javascript">
//<!--
	function desactivar_manif(wel_manif_num, wel_manif_corte) {
		document.desactivar_manif.wel_manif_num.value = wel_manif_num;
		document.desactivar_manif.wel_manif_corte.value = wel_manif_corte;
		if (confirm(' Esta seguro de desactivar este Manifiesto ?') == true) {
			document.desactivar_manif.submit();
		}
	}
//-->

</script>
<form name="desactivar_manif" id="desactivar_manif" action="<%=asp_self%>" method="post">
	<input type="hidden" name="etapa" value="2">
	<input type="hidden" name="wel_manif_num" value="">
	<input type="hidden" name="wel_manif_corte" value="">
</form>

<script language="javascript">
function print_etiq(id, traclave, corte_manif) {
	document.form_etiquetas.id.value = id;
	document.form_etiquetas.corte_manif.value = corte_manif;
	document.form_etiquetas.traclave.value = traclave;
	document.form_etiquetas.submit() ;
}
</script>
<!-- <<< CHG-DESA-15052024 se redirecciona al nuevo modulo de etiquetas -->
<!-- <form action="ltl_etiquetas_print<%=qa%>.asp" method="post" name="form_etiquetas"> -->
<form action="print_label<%=qa%>.asp" method="post" name="form_etiquetas">
<!-- CHG-DESA-15052024 >>> -->
	<input type="hidden" name="tipo" value="zebra">
	<input type="hidden" name="manif" value="S">
	<input type="hidden" name="traclave" value="">
	<input type="hidden" name="id" value="">
	<input type="hidden" name="corte_manif" value="">
</form>
		  
<script language="javascript">
function select_entry(num) {
	document.entry.entry_num.value = num;
	document.entry.submit() ;
}
</script>
<form name="entry" action="tr-entrada-detalle.asp" method="post">
	<input type="hidden" name="entry_num" value="">
</form>

<script language="javascript">
function select_recol(mi_traclave) {
	document.detalle_recoleccion.mi_traclave.value = mi_traclave;
	document.detalle_recoleccion.submit() ;
}
</script>
<form name="detalle_recoleccion" action="tr-recoleccion-detalle.asp" method="post">
	<input type="hidden" name="mi_traclave" value="">
</form>

<table class="datos" width="100%">
<tr><td align="right"><a href="ltl_manif-dl<%=qa%>.asp"><img src="./images/document-save.png" style="width:22px; height:22px; border:none; vertical-align:middle;" alt="Download"></a>
<a href="ltl_manif-dl<%=qa%>.asp">Download</a>
</td>
</tr>
</table>
<%if Request.QueryString("msg") <> "" then%>
<center><font color="red"><b><%=Request.QueryString("msg")%></b></font></center>
<%end if%>

<%call print_saldo_monedero%>

<script language="javascript">
   function select_wel_manif_num(manif_num) {
   	document.wel_manif_num.manif_num.value = manif_num;
   	document.wel_manif_num.submit() ;
   }
</script>
<form name="wel_manif_num" action="ltl_consulta<%=qa%>.asp" method="post">
	<input type="hidden" name="manif_num" value="">
</form>

<script language="javascript">
function redirect_smo() {
  <%SQL = "SELECT COUNT(0) FROM WEB_CAPTURA_PARAMETROS WHERE WCP_CLICLEF = " & Session("array_client")(2,0) & " AND NVL(WCP_CAPTURA_MANIF_II,'N') = 'P' OR NVL(WCP_CAPTURA_MANIF_II,'N') = 'S' "

  arrayTmp = GetArrayRS(SQL)
  if arrayTmp(0, 0) > "0" then
	'<<CHG-12032024-02: Se cambian las comillas dobles por comilla simple para que direccione al modulo correcto de documentacion de NUI's:
		Response.Write "document.modif_manif.action='documentacion_nuis.asp';"
	'  CHG-12032024-02>>
  end if%>
}
function modif_manif(wel_manif_num, cliclef, wel_manif_corte) {
	document.modif_manif.wel_manif_num.value = wel_manif_num;
	document.modif_manif.wel_manif_corte.value = wel_manif_corte;
	document.modif_manif.client.value = cliclef;
  redirect_smo();
	document.modif_manif.submit();
}
</script>
<!-- <<<20230313: FusionPantallas: Se redirige la edición del manifiesto a la pantalla 10.	-->
<!--<form name="modif_manif" action="ltl_captura_encabezado2.asp" method="post">-->
    <!-- PCLP -->
<form name="modif_manif" action="documentacion_nuis.asp" method="post">
    <!-- PCLP -->
<!--    20230313>>>	-->
	<input type="hidden" name="wel_manif_num" value="">
	<input type="hidden" name="wel_manif_corte" value="">
	<input type="hidden" name="client" value="">
</form>   


<table class="datos" align="center" BORDER="1" cellpadding="2" cellspacing="0" width="1050">
  <thead>
    <tr class="titulo_trading_bold" valign="center" align="center"> 
      <td>N° Manifiesto</td>
      <td>N° Cliente</td>
      <td>Remitente</td>
      <td>LTL / bultos</td>
      <td>Fecha<br>Creacin</td>
      <td>Recol.<br>Domicilio</td>
      <td>Fecha<br>Recoleccion</td>
      <td>Importe<br>LTL</td>
      <td>N°<br>Entrada</td>
      <td>N°<br>Recoleccion</td>
      <td>Acciones</td>
    </tr>
  </thead>
  <tbody>

    <%
	  For iRowLoop = iStart to iStop
	%>
    <tr align=center>
      <td>&nbsp;<a href="javascript:select_wel_manif_num('<%=arrayManif(0,iRowLoop)%>');" onmouseover="return overlib('Ver LTLs del Manifiesto');" onmouseout="return nd();"><%=arrayManif(0,iRowLoop)%></a>
        <%if NVL(arrayManif(13,iRowLoop)) <> "" then Response.Write " corte " & arrayManif(13,iRowLoop)%></td>     
      <td>&nbsp;<%=arrayManif(1,iRowLoop)%></td>
      <td>&nbsp;<%=filtre_col(arrayManif(2,iRowLoop), 150, "")%></td>
      <td>&nbsp;<%=arrayManif(3,iRowLoop)%> / <%=arrayManif(12,iRowLoop)%></td>
      <td>&nbsp;<%=arrayManif(4,iRowLoop)%></td>
      <td>&nbsp;<%=arrayManif(5,iRowLoop)%></td>
      <td>&nbsp;<%=arrayManif(6,iRowLoop)%></td>
      <td>&nbsp;<%if arrayManif(8,iRowLoop) <> "" then Response.Write FormatNumber(arrayManif(8,iRowLoop),2)%></td>
      <td>&nbsp;<%if arrayManif(10,iRowLoop) <> "" then Response.Write arrayManif(9,iRowLoop) & " <a href=""javascript:select_entry('" & arrayManif(10,iRowLoop) & "')"">" & arrayManif(11,iRowLoop) & "</a>"%>
      </td>
      <td>&nbsp;<%if arrayManif(15,iRowLoop) <> "" then Response.Write "<a href=""javascript:select_recol('" & arrayManif(15,iRowLoop) & "')"">" & arrayManif(14,iRowLoop) & "</a>" %>
      </td>
      <%dim tipo_Reporte
      if Session("ltl_doc_convertidor") = "1" then
        tipo_Reporte = "OPER6314_ltl" & qa & ".rdf"
        
        'verificar si hubo documentacion por encabezados:
        SQL = "SELECT COUNT(0) " & VbCrlf
        SQL = SQL & " FROM WEB_LTL " & VbCrlf
        SQL = SQL & " , WLDET_CONVERTIDOR " & VbCrlf
        SQL = SQL & " WHERE WEL_MANIF_NUM = " & arrayManif(0,iRowLoop) & VbCrlf
        SQL = SQL & " AND WEL_CLICLEF = " & arrayManif(1,iRowLoop) & VbCrlf
        SQL = SQL & " AND WLD_WELCLAVE = WELCLAVE "
        arrayTmp = GetArrayRS(SQL)
        if arrayTmp(0, 0) = "0" then
            'si no hay convertidores entonces imprimir el manifiesto tradicional.
			'<<< CHG-DESA-14062024: Se cambia el RDF que imprime el Manifiesto:
				'tipo_Reporte = "OPER6304_web_ltl_manifiesto2" & qa & ".rdf"
				tipo_Reporte = "OPER6304_web_ltl_manifiesto2" & rdf_test & ".rdf"
			'    CHG-DESA-14062024 >>>
        end if
      else
		'<<< CHG-DESA-14062024: Se cambia el RDF que imprime el Manifiesto:
			'tipo_Reporte = "OPER6304_web_ltl_manifiesto2" & qa & ".rdf"
			tipo_Reporte = "OPER6304_web_ltl_manifiesto2" & rdf_test & ".rdf"
		'    CHG-DESA-14062024 >>>
      end if%>
      
      <td>&nbsp;
        <%sql = "select count(0) " & vbCrLf
          SQL = SQL & "  from web_ltl wel " & vbCrLf
          SQL = SQL & "   , web_captura_parametros " & vbCrLf
            SQL = SQL & "  where wel_manif_num = " & arrayManif(0,iRowLoop) & vbCrLf
            SQL = SQL & "  and wel_cliclef =  " & arrayManif(1,iRowLoop) & vbCrLf
            SQL = SQL & "  and wcp_cliclef = wel_cliclef " & vbCrLf
            SQL = SQL & " AND TRUNC(WEL.DATE_CREATED) = TRUNC(SYSDATE) " & VBCRLF 
            'SQL = SQL & "  and DECODE(WEL_CDAD_BULTOS, (SELECT SUM(WPL_IDENTICAS) FROM WPALETA_LTL WHERE WPL_WELCLAVE = WEL.WELCLAVE), DECODE(WELFACTURA, '_PENDIENTE_', 'MODIF', 'PRINT'), 'MODIF')  = 'MODIF'"
        arrayTmp = GetArrayRS(SQL)
        if arrayTmp(0,0) > "0" then%>
            <a href="javascript:modif_manif(<%=arrayManif(0,iRowLoop)%>, <%=arrayManif(1,iRowLoop)%>, '<%=arrayManif(13,iRowLoop)%>')"><img src="./images/accessories-text-editor.png" style="border:none; cursor:pointer; width: 16px; height: 16px" onmouseover="return overlib('Agregar talones.');" onmouseout="return nd();"></a> 
            <%if NVL(arrayManif(13,iRowLoop)) <> "" then%>
            &nbsp;&nbsp;&nbsp;<a href="javascript:modif_manif(<%=arrayManif(0,iRowLoop)%>, <%=arrayManif(1,iRowLoop)%>, '0')"><img src="./images/edit-cut.png" style="border:none; cursor:pointer; width: 16px; height: 16px" onmouseover="return overlib('Hacer un nuevo corte.');" onmouseout="return nd();"></a> 
            <%end if%>
        <%end if%>
       &nbsp;&nbsp;&nbsp;<a href="/cgi/rwcgi60.exe/run?db_logis+wel_manif_num=<%=arrayManif(0,iRowLoop)%>+mi_cliclef=<%=arrayManif(1,iRowLoop)%>+wel_manif_corte=<%=arrayManif(13,iRowLoop)%>+report=<%=tipo_reporte%>+destype=cache+desformat=pdf"><img src="./images/document-print.png" style="border:none;rcursor:pointer; width: 16px; height: 16px;" onmouseover="return overlib('Imprimir el Manifiesto');" onmouseout="return nd();"></a> 
       <%if NVL(arrayManif(7,iRowLoop))="" then%> 
        &nbsp;&nbsp;&nbsp;<a href="javascript:desactivar_manif(<%=arrayManif(0,iRowLoop)%>, '<%=arrayManif(13,iRowLoop)%>');"><img src="./images/edit-delete.png" style="border:none; cursor:pointer; width: 16px; height: 16px;" onmouseover="return overlib('Cancelar el Manifiesto');" onmouseout="return nd();" alt="Cancelar manifiesto"></a> 
      <%end if%>
        &nbsp;&nbsp;&nbsp;<a href="ltl_consulta-dl.asp?tipo=txt&manif_num=<%=arrayManif(0,iRowLoop)%>"><img src="./images/notepad.gif" style="border:none; cursor:pointer;" onmouseover="return overlib('Imprimir reporte');" onmouseout="return nd();" alt="Imprimir reporte"></a> 
        &nbsp;&nbsp;&nbsp;<a href="javascript:print_etiq(<%=arrayManif(0,iRowLoop)%>, '<%=arrayManif(10,iRowLoop)%>', '<%=arrayManif(13,iRowLoop)%>');"><img src="./images/label.gif" style="border:none; cursor:pointer;" onmouseover="return overlib('Imprimir las etiquetas.');" onmouseout="return nd();" alt="Imprimir las etiquetas."></a> 
        &nbsp;&nbsp;&nbsp;<a href="ltl_print_talon.asp?manif_num=<%=arrayManif(0,iRowLoop)%>&cliclef=<%=arrayManif(1,iRowLoop)%>&manif_corte=<%=arrayManif(13,iRowLoop)%>&tipo=manif"><img src="./images/document-print.png" style="border:none;rcursor:pointer; width: 16px; height: 16px;" onmouseover="return overlib('Imprimir los talones');" onmouseout="return nd();"></a> 
      </td>
    </tr>
    <%
	next
	%>
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

</body>
</html>