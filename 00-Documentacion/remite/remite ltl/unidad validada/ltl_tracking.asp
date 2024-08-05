<%@ Language=VBScript %>
<% option explicit%>
<!--#include file="include/include.asp"-->
<%
dim qa
    qa = ""
'call check_session()
'Response.Expires = 0
Response.Buffer = true

dim titulo
Dim SQL, array_tmp,i, j, array_temp,firma,track_num	
Dim array_entrega, numRow, fecha_entrega, fecha_anterior
Dim hay_cd, tipo
dim incidencia, last_entrada, status
dim mi_traclave, mi_tdcdclave
dim mi_nui
dim array_fact_doc, es_doc_fte, es_fact
'<<<CHG-DESA-20240307-02: Se agregan variables para obtener el listado de facturas:
dim sqlFact, arrFatc
'   CHG-DESA-20240307-02>>>

'???oscar 20141222
Dim SQL_Log, array_Log,clave_cliente,consecutivo,SQL_Ins,rst
'???
dim welTalonRastreo
dim arrEstatus, nuevoStatus, sTipoOperacion

mi_traclave = Request("traclave")
mi_tdcdclave = Request("tdcdclave")

if not IsNumeric(mi_traclave) or (mi_tdcdclave <> "" and not IsNumeric(mi_tdcdclave)) then
    Response.End 
end if

'<JEMV(08/03/2022): Agrego nuevo estatus para hacer la comparación directamente en la pantalla:	
	welTalonRastreo = SQLEscape(Request.QueryString("track_num"))
	nuevoStatus = ""
	arrEstatus = obtieneStatusTalon(welTalonRastreo)
	if IsArray(arrEstatus) then
		nuevoStatus = arrEstatus(2)
	end if
' JEMV(08/03/2022)>

''''''''verificar si no es un tracking de Picking
'''''''SQL = "SELECT COUNT(0) " & vbCrLf
'''''''SQL = SQL & " FROM ETRANS_PICKING " & vbCrLf
'''''''SQL = SQL & " WHERE TPITRACKING_WEB = '" & SQLEscape(Request.QueryString("track_num")) & "'"
'''''''array_tmp = GetArrayRS(SQL)
'''''''if CInt(array_tmp(0, 0)) <> 0 then
'''''''    Response.Redirect "tr-pedido-detalle.asp?track_num=" & SQLEscape(Request.QueryString("track_num"))
'''''''end if





SQL = "SELECT /*+USE_CONCAT ORDERED */ TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) || DECODE(WEL_ORI.WELCLAVE, NULL, NULL, ' (talon ori: ' || TO_CHAR(WEL_ORI.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL_ORI.WEL_CLICLEF) ||')')   " & VbCrlf
SQL = SQL & "   , NVL(WEL.WEL_TALON_RASTREO, WEL.WEL_FIRMA) AS WEL_FIRMA   " & VbCrlf
SQL = SQL & "   , TO_CHAR( WEL.DATE_CREATED, 'DD/MM/YYYY HH24:MI')   " & VbCrlf
SQL = SQL & "   , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI')   " & VbCrlf
SQL = SQL & "   , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')    " & VbCrlf
SQL = SQL & "   , WEL.WELRECOL_DOMICILIO  " & VbCrlf
SQL = SQL & "   , WEL.WELFACTURA    " & VbCrlf
SQL = SQL & "   , WEL.WEL_CDAD_BULTOS    " & VbCrlf
SQL = SQL & "   , INITCAP(DIS.DISNOM) REMITENTE   " & VbCrlf
SQL = SQL & "   , InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  <br> ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DISCODEPOSTAL))  remitente_direc   " & VbCrlf
SQL = SQL & "   , INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')')    " & VbCrlf
SQL = SQL & "   , INITCAP(NVL(DIE2.DIE_A_ATENCION_DE, DIE2.DIENOMBRE) )   " & VbCrlf
SQL = SQL & "   , InitCap( DIE2.DIEADRESSE1|| ' ' || ' ' || DIE2.DIENUMEXT || '  ' || DIE2.DIENUMINT || '  <br> ' ||DIE2.DIEADRESSE2 || DECODE(DIE2.DIECODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DIE2.DIECODEPOSTAL)) remitente_direc    " & VbCrlf
SQL = SQL & "   , INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')')     " & VbCrlf
SQL = SQL & "   , WEL.WELSTATUS   " & VbCrlf
SQL = SQL & "   , WEL.WEL_TDCDCLAVE    " & VbCrlf
SQL = SQL & "   , 'LTL'    " & VbCrlf
SQL = SQL & "   , WEL.WEL_CLICLEF    " & VbCrlf
SQL = SQL & "   , WEL.WELOBSERVACION    " & VbCrlf
SQL = SQL & "   , WEL.WELPESO    " & VbCrlf
SQL = SQL & "   , WEL.WELVOLUMEN    " & VbCrlf
SQL = SQL & "  FROM WEB_LTL WEL  " & VbCrlf
SQL = SQL & "    , EDIRECCIONES_ENTREGA DIE2 " & VbCrlf
SQL = SQL & "    , EDISTRIBUTEUR DIS  " & VbCrlf
SQL = SQL & "    , ECIUDADES CIU_ORI  " & VbCrlf
SQL = SQL & "    , EESTADOS EST_ORI  " & VbCrlf
SQL = SQL & "    , ECIUDADES CIU_DEST  " & VbCrlf
SQL = SQL & "    , EESTADOS EST_DEST  " & VbCrlf
SQL = SQL & "    , ETRANS_DETALLE_CROSS_DOCK TDCD  " & VbCrlf
SQL = SQL & "    , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
SQL = SQL & "    , ETRANS_ENTRADA TAE  " & VbCrlf
SQL = SQL & "    , WEB_LTL WEL_ORI  " & VbCrlf
if mi_tdcdclave <> "" then
    SQL = SQL & "  WHERE WEL.WEL_TDCDCLAVE = " & mi_tdcdclave & vbCrLf
else
    SQL = SQL & "  WHERE (WEL.WEL_FIRMA IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") & "')  " & VbCrlf
    SQL = SQL & "         OR WEL.WEL_TALON_RASTREO IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") & "')  " & VbCrlf
    SQL = SQL & "        ) " & vbCrLf
end if
SQL = SQL & "    AND DISCLEF = WEL.WEL_DISCLEF  " & VbCrlf
SQL = SQL & "    AND DIE2.DIECLAVE = WEL.WEL_DIECLAVE  " & VbCrlf
SQL = SQL & "    AND CIU_ORI.VILCLEF = DISVILLE  " & VbCrlf
SQL = SQL & "    AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO  " & VbCrlf
SQL = SQL & "    AND CIU_DEST.VILCLEF = DIE2.DIEVILLE  " & VbCrlf
SQL = SQL & "    AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
SQL = SQL & "    AND TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE  " & VbCrlf
SQL = SQL & "    AND TDCDSTATUS (+) = '1'  " & VbCrlf
SQL = SQL & "    AND TRACLAVE(+) = WEL.WEL_TRACLAVE  " & VbCrlf
SQL = SQL & "    AND TRASTATUS (+) = '1'  " & VbCrlf
SQL = SQL & "    AND TAE_TRACLAVE(+) = WEL.WEL_TRACLAVE  " & VbCrlf
SQL = SQL & "    AND WEL_ORI.WELCLAVE(+) = WEL.WEL_WELCLAVE " & VbCrlf
SQL = SQL & " UNION ALL " & VbCrlf
SQL = SQL & " SELECT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) " & VbCrlf
SQL = SQL & "   , WCD.WCD_FIRMA   " & VbCrlf
SQL = SQL & "   , TO_CHAR( WCD.DATE_CREATED, 'DD/MM/YYYY HH24:MI')   " & VbCrlf
SQL = SQL & "   , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI')   " & VbCrlf
SQL = SQL & "   , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')    " & VbCrlf
SQL = SQL & "   , 'n/a' " & VbCrlf
SQL = SQL & "   , WCD.WCD_PEDIDO_CLIENTE    " & VbCrlf
SQL = SQL & "   , WCD.WCD_CDAD_BULTOS    " & VbCrlf
SQL = SQL & "   , INITCAP(DIS.DISNOM) REMITENTE   " & VbCrlf
SQL = SQL & "   , InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  <br> ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DISCODEPOSTAL))    " & VbCrlf
SQL = SQL & "   , INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')')    " & VbCrlf
SQL = SQL & "   , INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE))    " & VbCrlf
SQL = SQL & "   , InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || '  ' || DIENUMINT || '  <br> ' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DIECODEPOSTAL))     " & VbCrlf
SQL = SQL & "   , INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')')     " & VbCrlf
SQL = SQL & "   , WCD.WCDSTATUS   " & VbCrlf
SQL = SQL & "   , WCD.WCD_TDCDCLAVE    " & VbCrlf
SQL = SQL & "   , 'Cross Dock'    " & VbCrlf
SQL = SQL & "   , WCD_CLICLEF    " & VbCrlf
SQL = SQL & "   , WCD.WCDOBSERVACION    " & VbCrlf
SQL = SQL & "   , WCD.WCDPESO    " & VbCrlf
SQL = SQL & "   , WCD.WCDVOLUMEN    " & VbCrlf
SQL = SQL & "  FROM WCROSS_DOCK WCD  " & VbCrlf
SQL = SQL & "    , EDIRECCIONES_ENTREGA DIE " & VbCrlf
SQL = SQL & "    , ECLIENT_CLIENTE CCL " & VbCrlf
SQL = SQL & "    , EDISTRIBUTEUR DIS  " & VbCrlf
SQL = SQL & "    , ECIUDADES CIU_ORI  " & VbCrlf
SQL = SQL & "    , EESTADOS EST_ORI  " & VbCrlf
SQL = SQL & "    , ECIUDADES CIU_DEST  " & VbCrlf
SQL = SQL & "    , EESTADOS EST_DEST  " & VbCrlf
SQL = SQL & "    , ETRANS_DETALLE_CROSS_DOCK TDCD  " & VbCrlf
SQL = SQL & "    , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
SQL = SQL & "    , ETRANS_ENTRADA TAE  " & VbCrlf
if mi_tdcdclave <> "" then
    SQL = SQL & "  WHERE WCD.WCD_TDCDCLAVE = " & mi_tdcdclave & vbCrLf
else
    SQL = SQL & "  WHERE WCD.WCD_FIRMA IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") & "')  " & VbCrlf
end if
SQL = SQL & "    AND DISCLEF = WCD.WCD_DISCLEF  " & VbCrlf
SQL = SQL & "    AND DIECLAVE = NVL(NVL(TDCD_DIECLAVE_ENT, TDCD_DIECLAVE), WCD_DIECLAVE_ENTREGA)  " & VbCrlf
SQL = SQL & "    AND CCLCLAVE = NVL(TDCD_CCLCLAVE, WCD.WCD_CCLCLAVE) " & VbCrlf
SQL = SQL & "    AND CIU_ORI.VILCLEF = DISVILLE  " & VbCrlf
SQL = SQL & "    AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO  " & VbCrlf
SQL = SQL & "    AND CIU_DEST.VILCLEF = DIEVILLE  " & VbCrlf
SQL = SQL & "    AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
SQL = SQL & "    AND TDCDCLAVE(+) = WCD.WCD_TDCDCLAVE  " & VbCrlf
SQL = SQL & "    AND TDCDSTATUS (+) = '1'  " & VbCrlf
SQL = SQL & "    AND TRACLAVE(+) = WCD.WCD_TRACLAVE  " & VbCrlf
SQL = SQL & "    AND TRASTATUS (+) = '1'  " & VbCrlf
SQL = SQL & "    AND TAE_TRACLAVE(+) = WCD.WCD_TRACLAVE "
if mi_tdcdclave <> ""  then
    SQL = SQL & " UNION ALL "  & vbCrLf
    SQL = SQL & " SELECT TDCD.TDCDFACTURA  " & VbCrlf
    SQL = SQL & "  , NULL AS FIRMA " & VbCrlf
    SQL = SQL & "  , TO_CHAR(TDCD.DATE_CREATED, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
    SQL = SQL & "  , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
    SQL = SQL & "  , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
    SQL = SQL & "  , 'n/a'  " & VbCrlf
    SQL = SQL & "  , TDCD.TDCD_PEDIDO_CLIENTE  " & VbCrlf
    SQL = SQL & "  , TDCD.TCDC_CDAD_BULTOS  " & VbCrlf
    SQL = SQL & "  , INITCAP(CLI.CLINOM) REMITENTE  " & VbCrlf
    SQL = SQL & "  , InitCap(CLIADRESSE1 || ' ' || ' ' || CLINUMEXT || ' ' || CLINUMINT || '  ' ||CLIADRESSE2 || DECODE(CLICODEPOSTAL,NULL,NULL, ' C.P. ' || CLICODEPOSTAL))  " & VbCrlf
    SQL = SQL & "  , INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')')  " & VbCrlf
    SQL = SQL & "  , INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE))  " & VbCrlf
    SQL = SQL & "  , InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || ' ' || DIENUMINT || '  ' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' C.P. ' || DIECODEPOSTAL))  " & VbCrlf
    SQL = SQL & "  , INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')')  " & VbCrlf
    SQL = SQL & "  , TO_NUMBER(TDCD.TDCDSTATUS)  " & VbCrlf
    SQL = SQL & "  , TDCD.TDCDCLAVE  " & VbCrlf
    SQL = SQL & "  , 'Cross Dock'  " & VbCrlf
    SQL = SQL & "  , TRA_CLICLEF  " & VbCrlf
    SQL = SQL & "  , NULL " & vbCrLf
    SQL = SQL & "   , TDCD.TDCDPESO    " & VbCrlf
    SQL = SQL & "   , TDCD.TDCDVOLUMEN    " & VbCrlf
    SQL = SQL & "  FROM ETRANS_DETALLE_CROSS_DOCK TDCD   " & VbCrlf
    SQL = SQL & "  , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
    SQL = SQL & "  , ETRANS_ENTRADA TAE  " & VbCrlf
    SQL = SQL & "  , EDIRECCIONES_ENTREGA DIE  " & VbCrlf
    SQL = SQL & "  , ECLIENT_CLIENTE CCL  " & VbCrlf
    SQL = SQL & "  , ECIUDADES CIU_ORI  " & VbCrlf
    SQL = SQL & "  , EESTADOS EST_ORI  " & VbCrlf
    SQL = SQL & "  , ECIUDADES CIU_DEST  " & VbCrlf
    SQL = SQL & "  , EESTADOS EST_DEST  " & VbCrlf
    SQL = SQL & "  , ECLIENT CLI  " & VbCrlf
    SQL = SQL & "  WHERE TDCD.TDCDCLAVE = " & mi_tdcdclave & VbCrlf
    SQL = SQL & "  AND TDCD_DXPCLAVE_ORI IS NULL " & VbCrlf
    SQL = SQL & "  AND DIECLAVE = NVL(TDCD_DIECLAVE_ENT, TDCD_DIECLAVE)  " & VbCrlf
    SQL = SQL & "  AND CCLCLAVE = TDCD_CCLCLAVE " & VbCrlf
    SQL = SQL & "  AND CIU_ORI.VILCLEF = CLIVILLE  " & VbCrlf
    SQL = SQL & "  AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO  " & VbCrlf
    SQL = SQL & "  AND CIU_DEST.VILCLEF = DIEVILLE  " & VbCrlf
    SQL = SQL & "  AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
    SQL = SQL & "  AND TDCDSTATUS  = '1'  " & VbCrlf
    SQL = SQL & "  AND TRACLAVE = TDCD.TDCD_TRACLAVE " & VbCrlf
    SQL = SQL & "  AND TRASTATUS = '1'  " & VbCrlf
    SQL = SQL & "  AND TAE_TRACLAVE = TDCD.TDCD_TRACLAVE " & VbCrlf
    SQL = SQL & "  AND CLICLEF = TRA_CLICLEF " & VbCrlf
    SQL = SQL & "  AND NOT EXISTS ( " & VbCrlf
    SQL = SQL & "   SELECT NULL " & VbCrlf
    SQL = SQL & "   FROM WCROSS_DOCK " & VbCrlf
    SQL = SQL & "   WHERE WCD_TDCDCLAVE = TDCDCLAVE ) " & VbCrlf
    SQL = SQL & "  AND NOT EXISTS ( " & VbCrlf
    SQL = SQL & "   SELECT NULL " & VbCrlf
    SQL = SQL & "   FROM WEB_LTL " & VbCrlf
    SQL = SQL & "   WHERE WEL_TDCDCLAVE = TDCDCLAVE) "
elseif mi_traclave <> "" then
    SQL = SQL & " UNION ALL "  & vbCrLf
    SQL = SQL & " SELECT TPI.TPI_FACTURA_CLIENTE " & VbCrlf
    SQL = SQL & " ,null AS firma  " & VbCrlf
    SQL = SQL & " , TO_CHAR(TPI.DATE_CREATED, 'DD/MM/YYYY HH24:MI') " & VbCrlf
    SQL = SQL & " , NULL  " & VbCrlf
    SQL = SQL & " , TO_CHAR(TPI.DATE_CREATED, 'DD/MM/YYYY HH24:MI') " & VbCrlf
    SQL = SQL & " , 'n/a'  " & VbCrlf
    SQL = SQL & " , TPI.TPI_PEDIDO_CLIENTE  " & VbCrlf
    SQL = SQL & " ,TPI.TPI_TOT_EMPAQUES--, WCD.WCD_CDAD_BULTOS " & VbCrlf
    SQL = SQL & " , INITCAP(EAL.ALLNOMBRE) REMITENTE " & VbCrlf
    SQL = SQL & " , InitCap(EAL.ALLCODIGO) " & VbCrlf
    SQL = SQL & " , INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')') " & VbCrlf
    SQL = SQL & " , INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE)) " & VbCrlf
    SQL = SQL & " , InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || ' ' || DIENUMINT || '  " & VbCrlf
    SQL = SQL & "' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' C.P. ' || DIECODEPOSTAL)) " & VbCrlf
    SQL = SQL & " , INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')') " & VbCrlf
    SQL = SQL & " , to_number(TRA.TRASTATUS) " & VbCrlf
    SQL = SQL & " ,null WCD_TDCDCLAVE " & VbCrlf
    SQL = SQL & " , 'Picking' " & VbCrlf
    SQL = SQL & " , TPI_CLICLEF " & VbCrlf
    SQL = SQL & " , TPI.TPI_OBSERVACIONES " & VbCrlf
    SQL = SQL & " , TPI.TPI_PESO_TOTAL " & VbCrlf
    SQL = SQL & " , TPI.TPI_VOLUMEN_TOTAL " & VbCrlf
    SQL = SQL & " FROM ETRANS_PICKING TPI " & VbCrlf
    SQL = SQL & " , EDIRECCIONES_ENTREGA DIE  " & VbCrlf
    SQL = SQL & " , ECLIENT_CLIENTE CCL " & VbCrlf
    SQL = SQL & " , EALMACENES_LOGIS EAL " & VbCrlf
    SQL = SQL & " , ECIUDADES CIU_ORI  " & VbCrlf
    SQL = SQL & " , EESTADOS EST_ORI  " & VbCrlf
    SQL = SQL & " , ECIUDADES CIU_DEST  " & VbCrlf
    SQL = SQL & " , EESTADOS EST_DEST  " & VbCrlf
    SQL = SQL & " , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
    SQL = SQL & " WHERE  DIECLAVE = TPI.TPI_DIECLAVE " & VbCrlf
    SQL = SQL & " AND CCLCLAVE = TPI.TPI_CCLCLAVE " & VbCrlf
    SQL = SQL & " AND TPI.TPI_ALLCLAVE=EAL.ALLCLAVE " & VbCrlf
    SQL = SQL & " AND CIU_ORI.VILCLEF = EAL.ALL_VILCLEF  " & VbCrlf
    SQL = SQL & " AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO  " & VbCrlf
    SQL = SQL & " AND CIU_DEST.VILCLEF = DIEVILLE  " & VbCrlf
    SQL = SQL & " AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
    SQL = SQL & " AND TRACLAVE(+) = TPI.TPI_TRACLAVE " & VbCrlf
    SQL = SQL & " AND TRASTATUS (+) = '1'  " & VbCrlf
    SQL = SQL & " AND TPI_FECHA_CANCELACION IS NULL " & VbCrlf
    SQL = SQL & " AND TPI.TPI_TRACLAVE = " & mi_traclave &" "
end if




SQL = SQL & " UNION "




SQL = SQL & "SELECT /*+USE_CONCAT ORDERED */ TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) || DECODE(WEL_ORI.WELCLAVE, NULL, NULL, ' (talon ori: ' || TO_CHAR(WEL_ORI.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL_ORI.WEL_CLICLEF) ||')')   " & VbCrlf
SQL = SQL & "   , NVL(WEL.WEL_TALON_RASTREO, WEL.WEL_FIRMA) AS WEL_FIRMA   " & VbCrlf
SQL = SQL & "   , TO_CHAR( WEL.DATE_CREATED, 'DD/MM/YYYY HH24:MI')   " & VbCrlf
SQL = SQL & "   , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI')   " & VbCrlf
SQL = SQL & "   , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')    " & VbCrlf
SQL = SQL & "   , WEL.WELRECOL_DOMICILIO  " & VbCrlf
SQL = SQL & "   , WEL.WELFACTURA    " & VbCrlf
SQL = SQL & "   , WEL.WEL_CDAD_BULTOS    " & VbCrlf
SQL = SQL & "   , INITCAP(DIS.DISNOM) REMITENTE   " & VbCrlf
SQL = SQL & "   , InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  <br> ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DISCODEPOSTAL))  remitente_direc   " & VbCrlf
SQL = SQL & "   , INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')')    " & VbCrlf
SQL = SQL & "   , INITCAP(WCCL.WCCL_NOMBRE)    " & VbCrlf
SQL = SQL & "   , InitCap( WCCL_ADRESSE1|| ' ' || ' ' || WCCL_NUMEXT || '  ' || WCCL_NUMINT || '  <br> ' ||WCCL_ADRESSE2 || DECODE(WCCL_CODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || WCCL_CODEPOSTAL)) remitente_direc    " & VbCrlf
SQL = SQL & "   , INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')')     " & VbCrlf
SQL = SQL & "   , WEL.WELSTATUS   " & VbCrlf
SQL = SQL & "   , WEL.WEL_TDCDCLAVE    " & VbCrlf
SQL = SQL & "   , 'LTL'    " & VbCrlf
SQL = SQL & "   , WEL.WEL_CLICLEF    " & VbCrlf
SQL = SQL & "   , WEL.WELOBSERVACION    " & VbCrlf
SQL = SQL & "   , WEL.WELPESO    " & VbCrlf
SQL = SQL & "   , WEL.WELVOLUMEN    " & VbCrlf
SQL = SQL & "  FROM WEB_LTL WEL  " & VbCrlf
SQL = SQL & "    , WEB_CLIENT_CLIENTE WCCL  " & VbCrlf
SQL = SQL & "    , EDISTRIBUTEUR DIS  " & VbCrlf
SQL = SQL & "    , ECIUDADES CIU_ORI  " & VbCrlf
SQL = SQL & "    , EESTADOS EST_ORI  " & VbCrlf
SQL = SQL & "    , ECIUDADES CIU_DEST  " & VbCrlf
SQL = SQL & "    , EESTADOS EST_DEST  " & VbCrlf
SQL = SQL & "    , ETRANS_DETALLE_CROSS_DOCK TDCD  " & VbCrlf
SQL = SQL & "    , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
SQL = SQL & "    , ETRANS_ENTRADA TAE  " & VbCrlf
SQL = SQL & "    , WEB_LTL WEL_ORI  " & VbCrlf
if mi_tdcdclave <> "" then
    SQL = SQL & "  WHERE WEL.WEL_TDCDCLAVE = " & mi_tdcdclave & vbCrLf
else
    SQL = SQL & "  WHERE (WEL.WEL_FIRMA IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") & "')  " & VbCrlf
    SQL = SQL & "         OR WEL.WEL_TALON_RASTREO IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") & "')  " & VbCrlf
    SQL = SQL & "        ) " & vbCrLf
end if
SQL = SQL & "    AND DISCLEF = WEL.WEL_DISCLEF  " & VbCrlf
SQL = SQL & "    AND WCCLCLAVE = WEL.WEL_WCCLCLAVE  " & VbCrlf
SQL = SQL & "    AND CIU_ORI.VILCLEF = DISVILLE  " & VbCrlf
SQL = SQL & "    AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO  " & VbCrlf
SQL = SQL & "    AND CIU_DEST.VILCLEF = WCCL_VILLE  " & VbCrlf
SQL = SQL & "    AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
SQL = SQL & "    AND TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE  " & VbCrlf
SQL = SQL & "    AND TDCDSTATUS (+) = '1'  " & VbCrlf
SQL = SQL & "    AND TRACLAVE(+) = WEL.WEL_TRACLAVE  " & VbCrlf
SQL = SQL & "    AND TRASTATUS (+) = '1'  " & VbCrlf
SQL = SQL & "    AND TAE_TRACLAVE(+) = WEL.WEL_TRACLAVE  " & VbCrlf
SQL = SQL & "    AND WEL_ORI.WELCLAVE(+) = WEL.WEL_WELCLAVE " & VbCrlf
SQL = SQL & " UNION ALL " & VbCrlf
SQL = SQL & " SELECT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) " & VbCrlf
SQL = SQL & "   , WCD.WCD_FIRMA   " & VbCrlf
SQL = SQL & "   , TO_CHAR( WCD.DATE_CREATED, 'DD/MM/YYYY HH24:MI')   " & VbCrlf
SQL = SQL & "   , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI')   " & VbCrlf
SQL = SQL & "   , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')    " & VbCrlf
SQL = SQL & "   , 'n/a' " & VbCrlf
SQL = SQL & "   , WCD.WCD_PEDIDO_CLIENTE    " & VbCrlf
SQL = SQL & "   , WCD.WCD_CDAD_BULTOS    " & VbCrlf
SQL = SQL & "   , INITCAP(DIS.DISNOM) REMITENTE   " & VbCrlf
SQL = SQL & "   , InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  <br> ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DISCODEPOSTAL))    " & VbCrlf
SQL = SQL & "   , INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')')    " & VbCrlf
SQL = SQL & "   , INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE))    " & VbCrlf
SQL = SQL & "   , InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || '  ' || DIENUMINT || '  <br> ' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DIECODEPOSTAL))     " & VbCrlf
SQL = SQL & "   , INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')')     " & VbCrlf
SQL = SQL & "   , WCD.WCDSTATUS   " & VbCrlf
SQL = SQL & "   , WCD.WCD_TDCDCLAVE    " & VbCrlf
SQL = SQL & "   , 'Cross Dock'    " & VbCrlf
SQL = SQL & "   , WCD_CLICLEF    " & VbCrlf
SQL = SQL & "   , WCD.WCDOBSERVACION    " & VbCrlf
SQL = SQL & "   , WCD.WCDPESO    " & VbCrlf
SQL = SQL & "   , WCD.WCDVOLUMEN    " & VbCrlf
SQL = SQL & "  FROM WCROSS_DOCK WCD  " & VbCrlf
SQL = SQL & "    , EDIRECCIONES_ENTREGA DIE " & VbCrlf
SQL = SQL & "    , ECLIENT_CLIENTE CCL " & VbCrlf
SQL = SQL & "    , EDISTRIBUTEUR DIS  " & VbCrlf
SQL = SQL & "    , ECIUDADES CIU_ORI  " & VbCrlf
SQL = SQL & "    , EESTADOS EST_ORI  " & VbCrlf
SQL = SQL & "    , ECIUDADES CIU_DEST  " & VbCrlf
SQL = SQL & "    , EESTADOS EST_DEST  " & VbCrlf
SQL = SQL & "    , ETRANS_DETALLE_CROSS_DOCK TDCD  " & VbCrlf
SQL = SQL & "    , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
SQL = SQL & "    , ETRANS_ENTRADA TAE  " & VbCrlf
if mi_tdcdclave <> "" then
    SQL = SQL & "  WHERE WCD.WCD_TDCDCLAVE = " & mi_tdcdclave & vbCrLf
else
    SQL = SQL & "  WHERE WCD.WCD_FIRMA IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") & "')  " & VbCrlf
end if
SQL = SQL & "    AND DISCLEF = WCD.WCD_DISCLEF  " & VbCrlf
SQL = SQL & "    AND DIECLAVE = NVL(NVL(TDCD_DIECLAVE_ENT, TDCD_DIECLAVE), WCD_DIECLAVE_ENTREGA)  " & VbCrlf
SQL = SQL & "    AND CCLCLAVE = NVL(TDCD_CCLCLAVE, WCD.WCD_CCLCLAVE) " & VbCrlf
SQL = SQL & "    AND CIU_ORI.VILCLEF = DISVILLE  " & VbCrlf
SQL = SQL & "    AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO  " & VbCrlf
SQL = SQL & "    AND CIU_DEST.VILCLEF = DIEVILLE  " & VbCrlf
SQL = SQL & "    AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
SQL = SQL & "    AND TDCDCLAVE(+) = WCD.WCD_TDCDCLAVE  " & VbCrlf
SQL = SQL & "    AND TDCDSTATUS (+) = '1'  " & VbCrlf
SQL = SQL & "    AND TRACLAVE(+) = WCD.WCD_TRACLAVE  " & VbCrlf
SQL = SQL & "    AND TRASTATUS (+) = '1'  " & VbCrlf
SQL = SQL & "    AND TAE_TRACLAVE(+) = WCD.WCD_TRACLAVE "
if mi_tdcdclave <> "" then
    SQL = SQL & " UNION ALL "  & vbCrLf
    SQL = SQL & " SELECT TDCD.TDCDFACTURA  " & VbCrlf
    SQL = SQL & "  , NULL AS FIRMA " & VbCrlf
    SQL = SQL & "  , TO_CHAR(TDCD.DATE_CREATED, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
    SQL = SQL & "  , TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
    SQL = SQL & "  , TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
    SQL = SQL & "  , 'n/a'  " & VbCrlf
    SQL = SQL & "  , TDCD.TDCD_PEDIDO_CLIENTE  " & VbCrlf
    SQL = SQL & "  , TDCD.TCDC_CDAD_BULTOS  " & VbCrlf
    SQL = SQL & "  , INITCAP(CLI.CLINOM) REMITENTE  " & VbCrlf
    SQL = SQL & "  , InitCap(CLIADRESSE1 || ' ' || ' ' || CLINUMEXT || ' ' || CLINUMINT || '  ' ||CLIADRESSE2 || DECODE(CLICODEPOSTAL,NULL,NULL, ' C.P. ' || CLICODEPOSTAL))  " & VbCrlf
    SQL = SQL & "  , INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')')  " & VbCrlf
    SQL = SQL & "  , INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE))  " & VbCrlf
    SQL = SQL & "  , InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || ' ' || DIENUMINT || '  ' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' C.P. ' || DIECODEPOSTAL))  " & VbCrlf
    SQL = SQL & "  , INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')')  " & VbCrlf
    SQL = SQL & "  , TO_NUMBER(TDCD.TDCDSTATUS)  " & VbCrlf
    SQL = SQL & "  , TDCD.TDCDCLAVE  " & VbCrlf
    SQL = SQL & "  , 'Cross Dock'  " & VbCrlf
    SQL = SQL & "  , TRA_CLICLEF  " & VbCrlf
    SQL = SQL & "  , NULL " & vbCrLf
    SQL = SQL & "   , TDCD.TDCDPESO    " & VbCrlf
    SQL = SQL & "   , TDCD.TDCDVOLUMEN    " & VbCrlf
    SQL = SQL & "  FROM ETRANS_DETALLE_CROSS_DOCK TDCD   " & VbCrlf
    SQL = SQL & "  , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
    SQL = SQL & "  , ETRANS_ENTRADA TAE  " & VbCrlf
    SQL = SQL & "  , EDIRECCIONES_ENTREGA DIE  " & VbCrlf
    SQL = SQL & "  , ECLIENT_CLIENTE CCL  " & VbCrlf
    SQL = SQL & "  , ECIUDADES CIU_ORI  " & VbCrlf
    SQL = SQL & "  , EESTADOS EST_ORI  " & VbCrlf
    SQL = SQL & "  , ECIUDADES CIU_DEST  " & VbCrlf
    SQL = SQL & "  , EESTADOS EST_DEST  " & VbCrlf
    SQL = SQL & "  , ECLIENT CLI  " & VbCrlf
    SQL = SQL & "  WHERE TDCD.TDCDCLAVE = " & mi_tdcdclave & VbCrlf
    SQL = SQL & "  AND TDCD_DXPCLAVE_ORI IS NULL " & VbCrlf
    SQL = SQL & "  AND DIECLAVE = NVL(TDCD_DIECLAVE_ENT, TDCD_DIECLAVE)  " & VbCrlf
    SQL = SQL & "  AND CCLCLAVE = TDCD_CCLCLAVE " & VbCrlf
    SQL = SQL & "  AND CIU_ORI.VILCLEF = CLIVILLE  " & VbCrlf
    SQL = SQL & "  AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO  " & VbCrlf
    SQL = SQL & "  AND CIU_DEST.VILCLEF = DIEVILLE  " & VbCrlf
    SQL = SQL & "  AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
    SQL = SQL & "  AND TDCDSTATUS  = '1'  " & VbCrlf
    SQL = SQL & "  AND TRACLAVE = TDCD.TDCD_TRACLAVE " & VbCrlf
    SQL = SQL & "  AND TRASTATUS = '1'  " & VbCrlf
    SQL = SQL & "  AND TAE_TRACLAVE = TDCD.TDCD_TRACLAVE " & VbCrlf
    SQL = SQL & "  AND CLICLEF = TRA_CLICLEF " & VbCrlf
    SQL = SQL & "  AND NOT EXISTS ( " & VbCrlf
    SQL = SQL & "   SELECT NULL " & VbCrlf
    SQL = SQL & "   FROM WCROSS_DOCK " & VbCrlf
    SQL = SQL & "   WHERE WCD_TDCDCLAVE = TDCDCLAVE ) " & VbCrlf
    SQL = SQL & "  AND NOT EXISTS ( " & VbCrlf
    SQL = SQL & "   SELECT NULL " & VbCrlf
    SQL = SQL & "   FROM WEB_LTL " & VbCrlf
    SQL = SQL & "   WHERE WEL_TDCDCLAVE = TDCDCLAVE) "
elseif mi_traclave <> "" then
	SQL = SQL & " UNION ALL "  & vbCrLf
	SQL = SQL & " SELECT TPI.TPI_FACTURA_CLIENTE " & VbCrlf
	SQL = SQL & " ,null AS firma  " & VbCrlf
	SQL = SQL & " , TO_CHAR(TPI.DATE_CREATED, 'DD/MM/YYYY HH24:MI') " & VbCrlf
	SQL = SQL & " , NULL  " & VbCrlf
	SQL = SQL & " , TO_CHAR(TPI.DATE_CREATED, 'DD/MM/YYYY HH24:MI') " & VbCrlf
	SQL = SQL & " , 'n/a'  " & VbCrlf
	SQL = SQL & " , TPI.TPI_PEDIDO_CLIENTE  " & VbCrlf
	SQL = SQL & " ,TPI.TPI_TOT_EMPAQUES--, WCD.WCD_CDAD_BULTOS " & VbCrlf
	SQL = SQL & " , INITCAP(EAL.ALLNOMBRE) REMITENTE " & VbCrlf
	SQL = SQL & " , InitCap(EAL.ALLCODIGO) " & VbCrlf
	SQL = SQL & " , INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')') " & VbCrlf
	SQL = SQL & " , INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE)) " & VbCrlf
	SQL = SQL & " , InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || ' ' || DIENUMINT || '  " & VbCrlf
	SQL = SQL & "' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' C.P. ' || DIECODEPOSTAL)) " & VbCrlf
	SQL = SQL & " , INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')') " & VbCrlf
	SQL = SQL & " , to_number(TRA.TRASTATUS) " & VbCrlf
	SQL = SQL & " ,null WCD_TDCDCLAVE " & VbCrlf
	SQL = SQL & " , 'Picking' " & VbCrlf
	SQL = SQL & " , TPI_CLICLEF " & VbCrlf
	SQL = SQL & " , TPI.TPI_OBSERVACIONES " & VbCrlf
	SQL = SQL & " , TPI.TPI_PESO_TOTAL " & VbCrlf
	SQL = SQL & " , TPI.TPI_VOLUMEN_TOTAL " & VbCrlf
	SQL = SQL & " FROM ETRANS_PICKING TPI " & VbCrlf
	SQL = SQL & " , EDIRECCIONES_ENTREGA DIE  " & VbCrlf
	SQL = SQL & " , ECLIENT_CLIENTE CCL " & VbCrlf
	SQL = SQL & " , EALMACENES_LOGIS EAL " & VbCrlf
	SQL = SQL & " , ECIUDADES CIU_ORI  " & VbCrlf
	SQL = SQL & " , EESTADOS EST_ORI  " & VbCrlf
	SQL = SQL & " , ECIUDADES CIU_DEST  " & VbCrlf
	SQL = SQL & " , EESTADOS EST_DEST  " & VbCrlf
	SQL = SQL & " , ETRANSFERENCIA_TRADING TRA  " & VbCrlf
	SQL = SQL & " WHERE  DIECLAVE = TPI.TPI_DIECLAVE " & VbCrlf
	SQL = SQL & " AND CCLCLAVE = TPI.TPI_CCLCLAVE " & VbCrlf
	SQL = SQL & " AND TPI.TPI_ALLCLAVE=EAL.ALLCLAVE " & VbCrlf
	SQL = SQL & " AND CIU_ORI.VILCLEF = EAL.ALL_VILCLEF  " & VbCrlf
	SQL = SQL & " AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO  " & VbCrlf
	SQL = SQL & " AND CIU_DEST.VILCLEF = DIEVILLE  " & VbCrlf
	SQL = SQL & " AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO  " & VbCrlf
	SQL = SQL & " AND TRACLAVE(+) = TPI.TPI_TRACLAVE " & VbCrlf
	SQL = SQL & " AND TRASTATUS (+) = '1'  " & VbCrlf
	SQL = SQL & " AND TPI_FECHA_CANCELACION IS NULL " & VbCrlf
	SQL = SQL & " AND TPI.TPI_TRACLAVE = " & mi_traclave &" "
end if


array_tmp = GetArrayRS(SQL)
'Response.Write replace(SQL, vbCrLf, "<br>")
'Response.End 

if not IsArray(array_tmp) then'
	Response.Write "No hay seguimiento de LTL / Cross Dock."
	Response.End 
else
	clave_cliente=array_tmp(17, 0)
	mi_nui = obtiene_nui_x_firma_talon(array_tmp(1, 0))
end if

es_doc_fte = es_captura_con_doc_fuente(clave_cliente)
es_fact = es_captura_con_factura(clave_cliente)

dim mi_css, mi_js
mi_css = "<link rel='stylesheet' type='text/css' href='include/css/jqzoom.css' />" & vbCrLf
mi_css = mi_css & "<link rel=""stylesheet"" type=""text/css"" href=""include/css/tracking.css?v=1"" />" & vbCrLf
mi_js = "<script type='text/javascript' src='include/js/jquery-1.2.6.js'></script>" & vbCrLf
mi_js = mi_js & "<script type='text/javascript' src='include/js/jquery.jqzoom1.0.1.js'></script>" & vbCrLf


if array_tmp(16, 0) = "LTL" then
    titulo = "Tracking LTL"
    tipo = "LTL"
    if Request.QueryString("noMenu") = "1" then
        Response.Write "<html><head><title>Logis | Tracking LTL</title>" & vbCrLf
        Response.Write "<link rel=""stylesheet"" type=""text/css"" href=""./include/css/logis.css"">" & vbCrLf 
        Response.Write "<link rel=""stylesheet"" type=""text/css"" href=""./include/menu/menu.css"">" & vbCrLf 
        Response.Write mi_js
        Response.Write mi_css
        
        Response.Write "</head><body style=""margin-top: 0;"">"
    else
        Response.Write print_headers(titulo, "ltl", mi_js, mi_css, "")
        Response.Write "<img border=""0"" width=""0"" src=""images/pixel.gif"" height=""100"">"
    end if
    
else
    titulo = "Tracking Cross Dock"
    tipo = "Cross Dock"
    if IsArray(Session("array_client")) then
        Response.Write print_headers(titulo, "trading", mi_js, mi_css, "")
    else
        Response.Write print_headers(titulo, "inicio", mi_js, mi_css, "")
    end if
    Response.Write "<img src=""images/pixel.gif"" width=""0"" height=""100"" border=""0"">"
end if


if NVL(array_tmp(15, 0)) <> "" then
SQL = "SELECT /*+USE_NL(TDCD TRA TAE DXO EXP)*/ TO_CHAR(TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
SQL = SQL & " , InitCap(CIU_EAL.VILNOM) || ' (' || InitCap(EST_EAL.ESTNOMBRE)  || ')' " & VbCrlf
SQL = SQL & " , 'Entrada CEDIS Logis (' || EAL_ORI.ALLCODIGO || ' - ' || InitCap(CIU_EAL.VILNOM) || ')' " & VbCrlf
SQL = SQL & " , DXP_TIPO_ENTREGA " & VbCrlf
SQL = SQL & " , TO_CHAR(EXP_FECHA_SALIDA, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
SQL = SQL & " , DECODE(DXP_TIPO_ENTREGA, 'DIRECTO', 'Expedicion directa al cliente', 'Expedicion de traslado al CEDIS Logis (' || EAL_DEST.ALLCODIGO || ' - ' || InitCap(CIU_DEST.VILNOM) || ')') " & VbCrlf
SQL = SQL & " , TO_CHAR(DXP_FECHA_ENTREGA, 'DD/MM/YYYY HH24:MI') " & VbCrlf
SQL = SQL & " , InitCap(DXP_TIPO_EVIDENCIA)  " & VbCrlf
SQL = SQL & " , TRA_MEZTCLAVE_DEST  " & VbCrlf
SQL = SQL & " , NVL(DXP_TINCLAVE, 0)  " & VbCrlf
SQL = SQL & " , NVL(DXP_VAS, 'N')  " & VbCrlf
'<JEMV: Agrego campo que indica si la operacion es tipo VAS:
		SQL = SQL & " , LOGIS.TIPO_OPERACION_FACT (TDCD.TDCDCLAVE, TDCD.TDCD_TRACLAVE)  " & VbCrlf
' JEMV>
SQL = SQL & " FROM ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
SQL = SQL & "   , ETRANSFERENCIA_TRADING TRA " & VbCrlf
SQL = SQL & "   , EALMACENES_LOGIS EAL_ORI " & VbCrlf
SQL = SQL & "   , ECIUDADES CIU_EAL " & VbCrlf
SQL = SQL & "   , EESTADOS EST_EAL " & VbCrlf
SQL = SQL & "   , ETRANS_ENTRADA TAE " & VbCrlf
SQL = SQL & "   , EDET_EXPEDICIONES DXP " & VbCrlf
SQL = SQL & "   , EEXPEDICIONES EXP " & VbCrlf
SQL = SQL & "   , EALMACENES_LOGIS EAL_DEST " & VbCrlf
SQL = SQL & "   , ECIUDADES CIU_DEST " & VbCrlf
SQL = SQL & " WHERE TDCD.TDCDCLAVE IN ( " & VbCrlf
SQL = SQL & " 	SELECT TDCDCLAVE " & VbCrlf
SQL = SQL & " 	FROM ETRANS_DETALLE_CROSS_DOCK " & VbCrlf
SQL = SQL & " 	WHERE TDCD_DXPCLAVE_ORI IN " & VbCrlf
SQL = SQL & " 	  (SELECT DXPCLAVE " & VbCrlf
SQL = SQL & " 	 	FROM EDET_EXPEDICIONES  " & VbCrlf
SQL = SQL & " 	 	WHERE DXP_TIPO_ENTREGA IN ('TRASLADO', 'DIRECTO')  " & VbCrlf
SQL = SQL & " 	 	CONNECT BY PRIOR DXPCLAVE = DXP_DXPCLAVE  " & VbCrlf
SQL = SQL & " 	 	START WITH DXP_TDCDCLAVE = " & array_tmp(15, 0) & ") " & VbCrlf
SQL = SQL & " 	UNION  " & VbCrlf
SQL = SQL & " 	SELECT " & array_tmp(15, 0) & VbCrlf
SQL = SQL & " 	FROM DUAL " & VbCrlf
SQL = SQL & " ) " & VbCrlf
SQL = SQL & " AND TRACLAVE = TDCD.TDCD_TRACLAVE " & VbCrlf
SQL = SQL & " AND TRASTATUS = '1' " & VbCrlf
SQL = SQL & " AND TDCDSTATUS = '1' " & VbCrlf
SQL = SQL & " AND EAL_ORI.ALLCLAVE = TRA_ALLCLAVE " & VbCrlf
SQL = SQL & " AND CIU_EAL.VILCLEF = EAL_ORI.ALL_VILCLEF " & VbCrlf
SQL = SQL & " AND EST_EAL.ESTESTADO = CIU_EAL.VIL_ESTESTADO " & VbCrlf
SQL = SQL & " AND TAE_TRACLAVE = TRACLAVE " & VbCrlf
SQL = SQL & " AND DXP_TDCDCLAVE(+) = TDCD.TDCDCLAVE " & VbCrlf
SQL = SQL & " AND EXPCLAVE(+) = DXP_EXPCLAVE " & VbCrlf
SQL = SQL & " AND EAL_DEST.ALLCLAVE(+) = DXP_ALLCLAVE_DEST " & VbCrlf
SQL = SQL & " AND CIU_DEST.VILCLEF(+) = EAL_DEST.ALL_VILCLEF " & VbCrlf
SQL = SQL & " ORDER BY DXPCLAVE"
'response.write Replace(SQL,VbCrlf,"<br>")
'response.end
array_entrega = GetArrayRS(SQL)
elseif mi_traclave <> "" then



SQL = "SELECT /*+USE_NL(TDCD TRA TAE DXO EXP)*/ TO_CHAR(TPI.DATE_CREATED, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
SQL = SQL & " , InitCap(CIU_EAL.VILNOM) || ' (' || InitCap(EST_EAL.ESTNOMBRE)  || ')' " & VbCrlf
SQL = SQL & " , 'Entrada CEDIS Logis (' || EAL_ORI.ALLCODIGO || ' - ' || InitCap(CIU_EAL.VILNOM) || ')' " & VbCrlf
SQL = SQL & " , DXP_TIPO_ENTREGA " & VbCrlf
SQL = SQL & " , TO_CHAR(EXP_FECHA_SALIDA, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
SQL = SQL & " , DECODE(DXP_TIPO_ENTREGA, 'DIRECTO', 'Expedicion directa al cliente', 'Expedicion de traslado al CEDIS Logis (' || EAL_DEST.ALLCODIGO || ' - ' || InitCap(CIU_DEST.VILNOM) || ')') " & VbCrlf
SQL = SQL & " , TO_CHAR(DXP_FECHA_ENTREGA, 'DD/MM/YYYY HH24:MI') " & VbCrlf
SQL = SQL & " , InitCap(DXP_TIPO_EVIDENCIA)  " & VbCrlf
SQL = SQL & " , TRA_MEZTCLAVE_DEST  " & VbCrlf
SQL = SQL & " , NVL(DXP_TINCLAVE, 0)  " & VbCrlf
SQL = SQL & " , NVL(DXP_VAS, 'N')  " & VbCrlf
SQL = SQL & " , DXPCLAVE  " & VbCrlf
'<JEMV: Agrego campo para que el UNION no marque error al agregar el tipo de operación:
		SQL = SQL & " , ''  " & VbCrlf
' JEMV>
SQL = SQL & " FROM ETRANS_PICKING TPI " & VbCrlf
SQL = SQL & "   , ETRANSFERENCIA_TRADING TRA " & VbCrlf
SQL = SQL & "   , EALMACENES_LOGIS EAL_ORI " & VbCrlf
SQL = SQL & "   , ECIUDADES CIU_EAL " & VbCrlf
SQL = SQL & "   , EESTADOS EST_EAL " & VbCrlf
SQL = SQL & "   , EDET_EXPEDICIONES DXP " & VbCrlf
SQL = SQL & "   , EEXPEDICIONES EXP " & VbCrlf
SQL = SQL & "   , EALMACENES_LOGIS EAL_DEST " & VbCrlf
SQL = SQL & "   , ECIUDADES CIU_DEST " & VbCrlf
SQL = SQL & " WHERE TPI.TPI_TRACLAVE = " & mi_traclave & " " & VbCrlf
SQL = SQL & " AND TRACLAVE = TPI_TRACLAVE " & VbCrlf
SQL = SQL & " AND TRASTATUS = '1' " & VbCrlf
SQL = SQL & " AND TPI_FECHA_CANCELACION IS NULL " & VbCrlf
SQL = SQL & " AND EAL_ORI.ALLCLAVE = TRA_ALLCLAVE " & VbCrlf
SQL = SQL & " AND CIU_EAL.VILCLEF = EAL_ORI.ALL_VILCLEF " & VbCrlf
SQL = SQL & " AND EST_EAL.ESTESTADO = CIU_EAL.VIL_ESTESTADO " & VbCrlf
SQL = SQL & " AND DXP_TRACLAVE(+) = TPI_TRACLAVE " & VbCrlf
SQL = SQL & " AND EXPCLAVE(+) = DXP_EXPCLAVE " & VbCrlf
SQL = SQL & " AND EAL_DEST.ALLCLAVE(+) = DXP_ALLCLAVE_DEST " & VbCrlf
SQL = SQL & " AND CIU_DEST.VILCLEF(+) = EAL_DEST.ALL_VILCLEF " & VbCrlf

SQL = SQL & " UNION ALL " & VbCrlf

SQL =  SQL & " SELECT /*+USE_NL(TDCD TRA TAE DXO EXP)*/ TO_CHAR(TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
SQL = SQL & " , InitCap(CIU_EAL.VILNOM) || ' (' || InitCap(EST_EAL.ESTNOMBRE)  || ')' " & VbCrlf
SQL = SQL & " , 'Entrada CEDIS Logis (' || EAL_ORI.ALLCODIGO || ' - ' || InitCap(CIU_EAL.VILNOM) || ')' " & VbCrlf
SQL = SQL & " , DXP_TIPO_ENTREGA " & VbCrlf
SQL = SQL & " , TO_CHAR(EXP_FECHA_SALIDA, 'DD/MM/YYYY HH24:MI')  " & VbCrlf
SQL = SQL & " , DECODE(DXP_TIPO_ENTREGA, 'DIRECTO', 'Expedicion directa al cliente', 'Expedicion de traslado al CEDIS Logis (' || EAL_DEST.ALLCODIGO || ' - ' || InitCap(CIU_DEST.VILNOM) || ')') " & VbCrlf
SQL = SQL & " , TO_CHAR(DXP_FECHA_ENTREGA, 'DD/MM/YYYY HH24:MI') " & VbCrlf
SQL = SQL & " , InitCap(DXP_TIPO_EVIDENCIA)  " & VbCrlf
SQL = SQL & " , TRA_MEZTCLAVE_DEST  " & VbCrlf
SQL = SQL & " , NVL(DXP_TINCLAVE, 0)  " & VbCrlf
SQL = SQL & " , NVL(DXP_VAS, 'N')  " & VbCrlf
SQL = SQL & " , DXPCLAVE  " & VbCrlf
'<JEMV: Agrego campo que indica si la operación es tipo VAS:
		SQL = SQL & " , LOGIS.TIPO_OPERACION_FACT (TDCD.TDCDCLAVE, TDCD.TDCD_TRACLAVE)  " & VbCrlf
' JEMV>
SQL = SQL & " FROM ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
SQL = SQL & "   , ETRANSFERENCIA_TRADING TRA " & VbCrlf
SQL = SQL & "   , EALMACENES_LOGIS EAL_ORI " & VbCrlf
SQL = SQL & "   , ECIUDADES CIU_EAL " & VbCrlf
SQL = SQL & "   , EESTADOS EST_EAL " & VbCrlf
SQL = SQL & "   , ETRANS_ENTRADA TAE " & VbCrlf
SQL = SQL & "   , EDET_EXPEDICIONES DXP " & VbCrlf
SQL = SQL & "   , EEXPEDICIONES EXP " & VbCrlf
SQL = SQL & "   , EALMACENES_LOGIS EAL_DEST " & VbCrlf
SQL = SQL & "   , ECIUDADES CIU_DEST " & VbCrlf
SQL = SQL & " WHERE TDCD.TDCDCLAVE IN ( " & VbCrlf
SQL = SQL & " 	SELECT TDCDCLAVE " & VbCrlf
SQL = SQL & " 	FROM ETRANS_DETALLE_CROSS_DOCK " & VbCrlf
SQL = SQL & " 	WHERE TDCD_DXPCLAVE_ORI IN " & VbCrlf
SQL = SQL & " 	  (SELECT DXPCLAVE " & VbCrlf
SQL = SQL & " 	 	FROM EDET_EXPEDICIONES  " & VbCrlf
SQL = SQL & " 	 	WHERE DXP_TIPO_ENTREGA IN ('TRASLADO', 'DIRECTO')  " & VbCrlf
SQL = SQL & " 	 	CONNECT BY PRIOR DXPCLAVE = DXP_DXPCLAVE  " & VbCrlf
SQL = SQL & " 	 	START WITH DXP_TRACLAVE = " & mi_traclave & ") " & VbCrlf
SQL = SQL & " ) " & VbCrlf
SQL = SQL & " AND TRACLAVE = TDCD.TDCD_TRACLAVE " & VbCrlf
SQL = SQL & " AND TRASTATUS = '1' " & VbCrlf
SQL = SQL & " AND TDCDSTATUS = '1' " & VbCrlf
SQL = SQL & " AND EAL_ORI.ALLCLAVE = TRA_ALLCLAVE " & VbCrlf
SQL = SQL & " AND CIU_EAL.VILCLEF = EAL_ORI.ALL_VILCLEF " & VbCrlf
SQL = SQL & " AND EST_EAL.ESTESTADO = CIU_EAL.VIL_ESTESTADO " & VbCrlf
SQL = SQL & " AND TAE_TRACLAVE = TRACLAVE " & VbCrlf
SQL = SQL & " AND DXP_TDCDCLAVE(+) = TDCD.TDCDCLAVE " & VbCrlf
SQL = SQL & " AND EXPCLAVE(+) = DXP_EXPCLAVE " & VbCrlf
SQL = SQL & " AND EAL_DEST.ALLCLAVE(+) = DXP_ALLCLAVE_DEST " & VbCrlf
SQL = SQL & " AND CIU_DEST.VILCLEF(+) = EAL_DEST.ALL_VILCLEF " & VbCrlf
SQL = SQL & " ORDER BY 12"


array_entrega = GetArrayRS(SQL)

end if

if IsArray(array_entrega) then
    for i = 0 to UBound(array_entrega, 2)
        if NVL(array_entrega(3, i)) = "DIRECTO" _
            and (array_entrega(10, i) = "N" or (array_entrega(10, i) = "S" and array_entrega(9, i) = "4")) _ 
            and array_entrega(9, i) <> "5" then 'no recuperar las reexpediciones o los VAS
            incidencia = array_entrega(9, i)
            fecha_entrega = NVL(array_entrega(6, i))
	
	ELSEIF array_entrega(9, i)="5"   THEN
			IF i = UBound(array_entrega, 2)-1 then
				incidencia = array_entrega(9, i)
				fecha_entrega = ""
                        end if
        end if
        last_entrada = array_entrega(8, i)
    next
end if

status = "<td class='rojo'>Creado</td>"

if incidencia = "0" then    ' or incidencia = "5"
    'entrega normal, no pasa nada
    if fecha_entrega <> "" then
        status = "<td class='verde'>Entregado</td>"
    else
		if Request.QueryString("label") = "folio" then
			status = "<td class='naranja'>En cedis</td>"
		else
        status = "<td class='naranja'>En transito</td>"
    end if
    end if
elseif incidencia = "4" then
    status = "<td class='rojo'>No entregado</td>"
elseif incidencia = "3" then
    status = "<td class='rojo'>Entrega incompleta</td>"
else
    'hubo una incidencia
    if last_entrada <> "24" then
        'no hubo entrada de rechazo todavia entonces el status esta en transito
        'borramos la fecha de entrega
        fecha_entrega = ""
        if Request.QueryString("label") = "folio" then
			status = "<td class='naranja'>En cedis</td>"
		else
        status = "<td class='naranja'>En transito</td>"
		end if
    else
        status = "<td class='rojo'>Rechazado</td>"
    end if
    
end if

if array_tmp(14,0) = "0" then
    status = "<td class='rojo'>Cancelado</td>"
end if

if array_tmp(14,0) = "3" then
    status = "<td class='naranja'>Reservado</td>"
end if
if nuevoStatus = "" then
	if IsArray(array_tmp) then
		arrEstatus = obtieneStatusTalon(array_tmp(1, 0))
		if IsArray(arrEstatus) then
			nuevoStatus = arrEstatus(2)
		end if
	end if
end if
%>

<table class="datos" align="center" width="600" border="1" cellpadding="2" cellspacing="0">
  <tr class="fondo_azul_claro" align="center"> 
	<td class="fuente_guinda" colspan="4" align="center">
		Informaci&oacute;n del NUI <label class="fuente_negra"><%=mi_nui%></label> 
	</td>
  </tr>
 </table>
<%

dim num_client
dim td_doc_fte
dim td_arr_doc_fte
	num_client = array_tmp(17, 0)
	
	if es_doc_fte = true or es_fact = true then
		SQL = ""
		SQL = SQL & " SELECT	DOCUMENTO_FUENTE, " & VbCrlf
		if es_doc_fte = true then
			SQL = SQL & " 		LISTAGG(TO_CHAR(NO_FACTURA), ', ') WITHIN GROUP (ORDER BY NO_FACTURA DESC) NO_FACTURA, " & VbCrlf
		else
			SQL = SQL & " 		NO_FACTURA, " & VbCrlf
		end if
		SQL = SQL & " 	LINEAS_FACTURA, " & VbCrlf
		SQL = SQL & " 			VALOR, NO_ORDEN, PEDIDO " & VbCrlf
		SQL = SQL & " FROM		EFACTURAS_DOC" & VbCrlf
		SQL = SQL & " WHERE		NUI	=	'" & mi_nui & "' " & VbCrlf
		if es_doc_fte = true then
			SQL = SQL & " GROUP BY DOCUMENTO_FUENTE, LINEAS_FACTURA,VALOR, NO_ORDEN, PEDIDO " & VbCrlf
		end if
		
		array_fact_doc = GetArrayRS(SQL)
		
		if IsArray(array_fact_doc) then
			%>
				<table class="datos" align="center" width="600" border="1" cellpadding="2" cellspacing="0">
					<thead>
						<tr class="titulo_trading_bold" valign="center" align="center">
							<%
								if es_doc_fte = true then
									%>
										<td>Documento Fuente</td>
									<%
								end if
							%>
							<td>No. Factura</td>
							<td>Lineas de Captura</td>
							<td>Valor Mxn</td>
							<td>No. de Orden de compra</td>
							<td>No. Pedido</td>
						</tr>
					</thead>
					<tbody>
						<%
							for i = 0 to UBound(array_fact_doc,2)
								%>
									<tr valign='center' align='center'>
										<%
											if es_doc_fte = true then
												%>
													<td><%=array_fact_doc(0,i)%></td>
												<%
											end if
										%>
										<td><%=array_fact_doc(1, i)%></td>
										<td><%=array_fact_doc(2, i)%></td>
										<td><%=array_fact_doc(3, i)%></td>
										<td><%=array_fact_doc(4, i)%></td>
										<td><%=array_fact_doc(5, i)%></td>
									</tr>
								<%
							next
						%>
					</tbody>
				</table>
				<br>
			<%
		end if
   end if
%>


<table class="datos" align="center" width="600" border="1" cellpadding="2" cellspacing="0">
  <tr class="titulo_trading_bold" align="center"> 
	<td colspan="4" align="center">
		Detalle Registro
	</td>
  </tr>
  <tr> 
	<td class="titulo_trading_bold">
	<%if tipo = "LTL" then
	    Response.Write "N&deg; Tal&oacute;n"
	  elseif Request.QueryString("label") = "folio" then
	    Response.Write "N&deg; Folio"
	  else
	    Response.Write "N&deg; Factura"
	  end if%>
	</td>
	<td><%=array_tmp(0,0)%></td>
	<td class="titulo_trading_bold">N&deg; de Tracking</td>
	<td><%=array_tmp(1,0)%></td>
  </tr>
  <tr> 
	<td class="titulo_trading_bold">Fecha Creacion</td>
	<td><%=array_tmp(2,0)%></td>
	<td class="titulo_trading_bold">Fecha de Recoleccion</td>
	<%if Request.QueryString("label") = "folio" then%>
	<td><%=Request.QueryString("fecha_salida")%>&nbsp;</td>
	<%else%>
	<td><%=array_tmp(3,0)%>&nbsp;</td>
	<%end if%>
  </tr>
  <tr> 
	<td class="titulo_trading_bold">Fecha Entrada</td>
	<td><%=array_tmp(4,0)%></td>
	<td class="titulo_trading_bold">Fecha Entrega</td>
	<td><%=fecha_entrega%>&nbsp;</td>
  </tr>
  <tr> 
	<td class="titulo_trading_bold">Recol. Domicilio</td>
	<td><%=array_tmp(5,0)%></td>
	<td class="titulo_trading_bold">Status</td>
	<!--
	<%=status%>
	-->
	<%=nuevoStatus%>
  </tr>
  <tr> 
	<td class="titulo_trading_bold">
	<%if tipo = "LTL" then
	    Response.Write "N&deg; Referencia"
	  elseif Request.QueryString("label") = "folio" then
	    Response.Write "N&deg; Factura"
	  else
	    Response.Write "N&deg; Pedido"
	  end if%></td>
	<td>
		<%
			'<<<CHG-DESA-20240307-02: Para las cuentas de FANDELI, Elyan solicita que las facturas se listen sin espacios:
			if num_client = "23213" or num_client = "23548" or num_client = "23224" or num_client = "20689" then
				sqlFact = ""
				sqlFact = sqlFact & " SELECT NVL(LISTAGG(TO_CHAR(FD.NO_FACTURA), ',') WITHIN GROUP (ORDER BY FD.NO_FACTURA DESC),WEL.WELFACTURA) NO_FACTURA " & VbCrlf
				sqlFact = sqlFact & " FROM		EFACTURAS_DOC FD " & VbCrlf
				sqlFact = sqlFact & "     LEFT JOIN WEB_LTL WEL ON FD.NUI = WEL.WELCLAVE " & VbCrlf
				sqlFact = sqlFact & " WHERE		FD.NUI	=	'" & mi_nui & "' " & VbCrlf
				sqlFact = sqlFact & " GROUP BY WEL.WELFACTURA " & VbCrlf
				Session("SQL") = sqlFact
				arrFatc = GetArrayRS(sqlFact)
				
				if IsArray(arrFatc) then
					Response.Write arrFatc(0,0)
				else
					Response.Write Replace(array_tmp(6,0), " ", "")
				end if
			else
				Response.Write array_tmp(6,0)
			end if
			'   CHG-DESA-20240307-02>>>
		%>
	</td>
	<td class="titulo_trading_bold">Cdad Bultos</td>
	<td><%=array_tmp(7,0)%></td>
  </tr>
  <%if Request.QueryString("label") = "folio" then%>
  <tr valign="top"> 
	<td class="titulo_trading_bold">Peso</td>
	<td colspan="3"><%=array_tmp(19,0)%> kg</td>
  </tr>
  <%else%>
   <tr valign="top"> 
	<td class="titulo_trading_bold">Remitente</td>
	<td><%=array_tmp(8,0)%><br><%=array_tmp(9,0)%><br><%=array_tmp(10,0)%></td>
	<td class="titulo_trading_bold">Destinatario</td>
	<td><%=array_tmp(11,0)%><br><%=array_tmp(12,0)%><br><%=array_tmp(13,0)%></td>
  </tr>
   <tr valign="top"> 
	<td class="titulo_trading_bold">Peso</td>
	<td><%=array_tmp(19,0)%> kg</td>
	<td class="titulo_trading_bold">Volumen</td>
	<td><%=array_tmp(20,0)%> m3</td>
  </tr>
  <%end if%>

  <%if array_tmp(17, 0) = "5026" or array_tmp(17, 0) = "7826" then%>
  <tr valign="top"> 
    <td class="titulo_trading_bold">Observaciones</td>
    <td colspan="3"><%=array_tmp(18,0)%>
  </tr>
  <%end if%>
</table>
<br>
<table class="datos" align="center"  valign="top" width="600" border="1" cellpadding="3" cellspacing="0">
  <tr class="titulo_trading_bold" align="center"> 
	<td colspan="3">Rastreo detallado</td>
  </tr>
  <tr> 
	<td width="110" class="titulo_trading_bold">&nbsp;Fecha</td>
	<td width="175" class="titulo_trading_bold">&nbsp;Ciudad (Estado)</td>
	<td width="295" class="titulo_trading_bold">&nbsp;Observaciones</td>
  </tr>
  
  <tr valign="top" bgcolor="FFFFEE">
	<td align="right">&nbsp;<%=array_tmp(2,0)%>&nbsp;&nbsp;</td>
	<td>&nbsp;</td>
	<td>&nbsp;Creaci&oacute;n de la 
	<%if tipo = "LTL" then
	    Response.Write "LTL "
	  else
	    Response.Write "factura "
	  end if%><%=array_tmp(0,0)%></td>
  </tr>
  
  <%fecha_anterior = array_tmp(2,0)
  if IsArray(array_entrega) then
    numRow = 0
    if array_tmp(5,0) = "S" then
        numRow = numRow + 1%>
        <tr valign="top"> 
	        <td align="right">&nbsp;<%
	        	if Left(array_tmp(3,0),10) <> Left(array_tmp(2,0),10) then ' compara dias
	        		Response.Write array_tmp(3,0)
	        	else
	        		Response.Write Right(array_tmp(3,0),5)
	        	end if
	        	%>&nbsp;&nbsp;
	        </td>
	        <td>&nbsp;<%=array_tmp(10,0)%></td>
	        <td>&nbsp;Recolecci&oacute;n a domicilio (<%=array_tmp(8,0)%>)	</td>
        </tr>
    <%fecha_anterior = array_tmp(3,0)
    end if
    for i = 0 to UBound(array_entrega, 2)
        'no desplegar las entradas que no son
        '34	Recibo de VAS	
        '42	Recibo LTL	
        '25	Recibo Cross Dock	
        '57	Recibo de Stand By	
        if array_entrega(8, i) <> "34" and array_entrega(8, i) <> "42" _
            and array_entrega(8, i) <> "25" and array_entrega(8, i) <> "57" _
            and array_entrega(8, i) <> "102" and array_entrega(8, i) <> "9"  then
            exit for
        end if 
                
        numRow = numRow + 1%>
        <tr valign="top" <%if numRow mod 2 = 0 then Response.Write "bgcolor=""FFFFEE"""%>> 
	        <td align="right">&nbsp;<%
	        	if Left(fecha_anterior,10) <> Left(array_entrega(0,i),10) then ' compara dias
	        		Response.Write array_entrega(0,i)
	        	else
	        		Response.Write Right(array_entrega(0,i),5)	
	        	end if	
	        	%>&nbsp;&nbsp;
	        </td>
	        <td>&nbsp;<%=array_entrega(1,i)%></td>
	        <td>&nbsp;<%=array_entrega(2,i)%></td>
        </tr>
        <%numRow = numRow + 1
          fecha_anterior = array_entrega(0,i)
      if NVL(array_entrega(3,i)) <> "" then
        %>
        <tr valign="top" <%if numRow mod 2 = 0 then Response.Write "bgcolor=""FFFFEE"""%>> 
	        <td align="right">&nbsp;<%
	        	if Left(fecha_anterior,10) <> Left(array_entrega(4,i),10) then ' compara dias
	        		Response.Write array_entrega(4,i)
	        	else
	        		Response.Write Right(array_entrega(4,i),5)	
	        	end if
	        	%>&nbsp;&nbsp;
	        </td>
	        <td>&nbsp;<%=array_entrega(1,i)%></td>
	        <td>&nbsp;<%=array_entrega(5,i)%></td>
        </tr>
        <%
          fecha_anterior = array_entrega(4,i)
          
          if array_entrega(3,i) = "DIRECTO" and NVL(array_entrega(6,i)) <> "" and Request.QueryString("label") <> "folio"  then
            numRow = numRow + 1
        %>
        <tr  valign="top" <%if numRow mod 2 = 0 then Response.Write "bgcolor=""FFFFEE"""%>> 
	        <td align="right">&nbsp;<%
	        	if Left(fecha_anterior,10) <> Left(array_entrega(6,i),10) then ' compara dias
	        		Response.Write array_entrega(6,i)
	        	else
	        		Response.Write Right(array_entrega(6,i),5)	
	        	end if	
	        	%>&nbsp;&nbsp;
	        </td>
	        <td>&nbsp;<%=array_tmp(13,0)%></td>
<!-- Ajuste de etiqueta para tipo VAS -->
	<% if array_entrega(11,i) = "VAS" and array_entrega(9,i) <> "0" then %>
							<td>&nbsp;<span style='color:red'>Intento de entrega fallido</span>
									(<%=array_tmp(11,0)%>)<br>&nbsp;<%=array_entrega(7,i)%>
							</td>
	<% else %>
		<% if array_entrega(11,i) = "LTL" then %>
							<td>
								<% 
									if array_entrega(9,i) <> "0" then
										Response.Write " <span style='color:red'>No entregado</span> &nbsp;"
										Response.Write ("(" & array_tmp(11,0) & ")<br>&nbsp;" & array_entrega(7,i) & "")
									else
								%>
								&nbsp;Entrega al Cliente 
									<%if array_entrega(9,i) <> "0" then Response.Write " <span style='color:red'>con incidencia</span>"%>
									(<%=array_tmp(11,0)%>)<br>&nbsp;<%=array_entrega(7,i)%>
									
							</td>
								<% 
									end if
								%>
		<% else %>
							<td>
								&nbsp;Entrega al Cliente 
								<%if array_entrega(9,i) <> "0" then Response.Write " <span style='color:red'>con incidencia</span> &nbsp;"%>
								(<%=array_tmp(11,0)%>)<br>&nbsp;<%=array_entrega(7,i)%>
							</td>
		<% end if %>
	<% end if %>
        </tr>
        <%fecha_anterior = array_entrega(6,i)
        end if
      end if
    next
    
  end if%>
		<!-- << JEMV(2022/03/09): Agrego estatus de cancelación para los talones que correspondan. -->
		<%
			dim arrStatus, idStatus, dCreated, dModified, usCreated, usModified
			idStatus = ""
			if Request.QueryString("track_num") <> "" then
				SQL = " SELECT WELCLAVE, WELSTATUS, WELCONS_GENERAL, WEL_CLICLEF, WEL_FIRMA, WEL_TALON_RASTREO, TO_CHAR(DATE_CREATED, 'DD/MM/YYYY HH24:MI') DATE_CREATED, CREATED_BY,  TO_CHAR(DATE_MODIFIED, 'DD/MM/YYYY HH24:MI') DATE_MODIFIED, MODIFIED_BY " & VbCrlf
				SQL = SQL & " FROM WEB_LTL "
				SQL = SQL & " WHERE WEL_TALON_RASTREO = '" & Request.QueryString("track_num") & "' "
				Session("SQL") = SQL
				arrStatus = GetArrayRS(SQL)

				if IsArray(arrStatus) then
					for i = 0 to UBound(arrStatus, 2)
						idStatus = arrStatus(1,i)
						dCreated = arrStatus(6,i)
						usCreated = arrStatus(7,i)
						dModified = arrStatus(8,i)
						usModified = arrStatus(9,i)
					next
				end if
			end if
			
			if idStatus = "0" then
				numRow = numRow + 1
				%>
					<tr  valign="top" <%if numRow mod 2 = 0 then Response.Write "bgcolor=""FFFFEE"""%>> 
						<td align="right">
							<%
								Response.Write("&nbsp;" & dModified & "&nbsp;&nbsp;")
							%>
						</td>
						<td>&nbsp;</td>
						<td>
							&nbsp;Cancelaci&oacute;n de la <%=tipo%>&nbsp;<%=Request.QueryString("track_num")%>
						</td>
					</tr>
				<%
			end if
		%>
		<!--  JEMV(2022/03/09) >> -->
</table>

<%'para los cross dock, mostrar el detalle de bultos
Dim array_bultos
if NVL(array_tmp(15, 0)) <> "" then
SQL = "SELECT WCB_CANTIDAD " & VbCrlf
SQL = SQL & "   , LOWER(TPA.TPADESCRIPCION) " & VbCrlf
SQL = SQL & "   , WCBLARGO " & VbCrlf
SQL = SQL & "   , WCBANCHO " & VbCrlf
SQL = SQL & "   , WCBALTO " & VbCrlf
SQL = SQL & "   , WCB_CDAD_EMPAQUES_X_BULTO || ' ' || LOWER(TPA2.TPADESCRIPCION) " & VbCrlf
SQL = SQL & " FROM WCROSS_DOCK " & VbCrlf
SQL = SQL & "   , WCBULTOS " & VbCrlf
SQL = SQL & "   , ETIPOS_PALETA TPA " & VbCrlf
SQL = SQL & "   , ETIPOS_PALETA TPA2 " & VbCrlf
SQL = SQL & " WHERE WCD_TDCDCLAVE = " & NVL(array_tmp(15, 0))
SQL = SQL & "   AND WCB_WCDCLAVE = WCDCLAVE " & VbCrlf
SQL = SQL & "   AND TPA.TPACLAVE = WCB_TPACLAVE " & VbCrlf
SQL = SQL & "   AND TPA2.TPACLAVE(+) = WCB_BULTO_TPACLAVE "

array_bultos = GetArrayRS(SQL)
if IsArray(array_bultos) then
    dim view_det_bultos, colspan_det_bultos
    view_det_bultos = false
    colspan_det_bultos = 5
    for i = 0 to UBound(array_bultos, 2)
        if Trim(array_bultos(5, i)) <> "" then
            view_det_bultos = true
            colspan_det_bultos = 6
        end if
    next
    
%>
    <br><br>
    <table class="datos" align="center"  valign="top" width="600" border="1" cellpadding="3" cellspacing="0">
      <tr class="titulo_trading_bold" align="center"> 
    	<td colspan="<%=colspan_det_bultos%>">Detalle de bultos</td>
      </tr>
      <tr> 
    	<td class="titulo_trading_bold">&nbsp;Cantidad</td>
    	<td class="titulo_trading_bold">&nbsp;Tipo</td>
    	<td class="titulo_trading_bold">&nbsp;Largo (m)</td>
    	<td class="titulo_trading_bold">&nbsp;Ancho (m)</td>
    	<td class="titulo_trading_bold">&nbsp;Alto (m)</td>
    	<%if view_det_bultos then%>
    	<td class="titulo_trading_bold">&nbsp;Bultos por tarima</td>
    	<%end if%>
      </tr>
    <%
    for i = 0 to UBound(array_bultos, 2)%>
      <tr> 
    	<td>&nbsp;<%=array_bultos(0, i)%></td>
    	<td>&nbsp;<%=array_bultos(1, i)%></td>
    	<td>&nbsp;<%=array_bultos(2, i)%></td>
    	<td>&nbsp;<%=array_bultos(3, i)%></td>
    	<td>&nbsp;<%=array_bultos(4, i)%></td>
    	<%if view_det_bultos then%>
    	<td>&nbsp;<%=array_bultos(5, i)%></td>
    	<%end if%>
      </tr>
    <%next%>
</table>
<%end if

END IF%>

<%
'<<<<< CESAR
'apartir de este punto se obtienen las evidencias, se crea validación para que solo cuando exista una sesión activa muestre las evidencias
'if IsArray(Session("array_client")) then
'CESAR >>>>>    
Dim grupo_helvex
SQL = "SELECT COUNT(0) "
SQL = SQL & " FROM ECLIENT " & vbCrLf
SQL = SQL & " WHERE CLICLEF = " & array_tmp(17, 0)
SQL = SQL & "   AND CLIGROUPE IN (3185, 3231) " ', 7824
grupo_helvex = GetArrayRS(SQL)
if (IP_interna or IsArray(Session("array_client")) or CInt(grupo_helvex(0,0)) > 0) and NVL(array_tmp(15, 0)) <> "" then
    Dim array_evid
    'estamos conectados, desplegamos los conceptos y evidencias
    Dim ArrayEvidencias
    'recuperar la opcion de ver las evidencias
    SQL = "SELECT COUNT(0)  " & VbCrlf
    SQL = SQL & " FROM ECLIENT_MODALIDADES " & VbCrlf
    SQL = SQL & " WHERE CLM_CLICLEF IN ("& array_tmp(17, 0) &")" & VbCrlf
    SQL = SQL & " AND CLM_MOECLAVE = 10	 "
    ArrayEvidencias = GetArrayRS(SQL)
    if CInt(ArrayEvidencias(0,0)) > 0 or IP_interna then

        SQL = "SELECT /*+INDEX(WAS IDX_WAS_TDCDCLAVE) */  WASCLAVE " & VbCrlf
        'SQL = SQL & "   , REPLACE(NVL(WASCARPETA2, WASCARPETA), 'facturas_clientes/', 'facturas_clientes/') " & VbCrlf
        SQL = SQL & "   , DECODE(WASRESPALDO_WEB, 'S', '/evidencias/' || WASCARPETA, '/evidencias2/' || WASCARPETA2) " & VbCrlf
        'SQL = SQL & "   , WASCARPETA " & VbCrlf
        SQL = SQL & "   , WASARCHIVO_PDF " & VbCrlf
        SQL = SQL & "   , WASARCHIVO_IMG_MEDIUM " & VbCrlf
        SQL = SQL & "   , WASARCHIVO_IMG_SMALL " & VbCrlf
        SQL = SQL & "   , DECODE(WAS_EXPCLAVE, NULL, WASARCHIVO_PDF_ORIGINAL, NULL) " & VbCrlf   'si no es una expedicion entonces recuperamos el archivo original
        SQL = SQL & "   , WASARCHIVO_PDF_ORIGINAL_W " & vbCrLf
        SQL = SQL & " FROM WEB_ARCHIVOS_ESCANEADOS WAS " & VbCrlf
        SQL = SQL & " WHERE WAS_TDCDCLAVE IN (  " & VbCrlf
        SQL = SQL & " 	SELECT TDCDCLAVE  " & VbCrlf
        SQL = SQL & " 	FROM ETRANS_DETALLE_CROSS_DOCK  " & VbCrlf
        SQL = SQL & " 	WHERE TDCD_DXPCLAVE_ORI IN  " & VbCrlf
        SQL = SQL & " 	  (SELECT DXPCLAVE  " & VbCrlf
        SQL = SQL & " 	 	FROM EDET_EXPEDICIONES   " & VbCrlf
        SQL = SQL & " 	 	WHERE DXP_TIPO_ENTREGA IN ('TRASLADO', 'DIRECTO')   " & VbCrlf
        SQL = SQL & " 	 	CONNECT BY PRIOR DXPCLAVE = DXP_DXPCLAVE   " & VbCrlf
        SQL = SQL & " 	 	START WITH DXP_TDCDCLAVE = " & array_tmp(15, 0) & ")  " & VbCrlf
        SQL = SQL & " 	UNION   " & VbCrlf
        SQL = SQL & " 	SELECT " & array_tmp(15, 0) & VbCrlf
        SQL = SQL & " 	FROM DUAL  " & VbCrlf
        SQL = SQL & " ) "
        SQL = SQL & " AND WAS_UPLOAD_WEB IS NOT NULL "
        if not IP_interna then
            SQL = SQL & " AND WAS_UPLOAD_WEB > SYSDATE - 90 "
        end if
        array_evid = GetArrayRS(SQL)
        if IsArray(array_evid) then
            
            %><a name="evidencias"></a>
            <div id='facturas' style='border: solid 1px;  width: 100%; align:center'>
            <script type="text/javascript">
                $(function() {
                    var options = {
                	    zoomWidth: 600,
                	    zoomHeight: 500,
                            xOffset: 10,
                            yOffset: 0,
                            title: false,
                            preloadText: "Cargando",
                            preloadImagest: true,
                            position: "right" //and MORE OPTIONS
                    };
                	$(".jqzoom").jqzoom(options);
                });
                (function($) {
                  var cache = [];
                  // Arguments are image paths relative to the current page.
                  $.preLoadImages = function() {
                    var args_len = arguments.length;
                    for (var i = args_len; i--;) {
                      var cacheImage = document.createElement('img');
                      cacheImage.src = arguments[i];
                      cache.push(cacheImage);
                    }
                  }
                })(jQuery)
                
                //jQuery.preLoadImages('/evidencias/<%=array_evid(1, 0)%><%=array_evid(3, 0)%>');
                
	    		/*jQuery.preloadImages = function()
	    		{
	    		  for(var i = 0; i<arguments.length; i++)
	    		  {
	    		    jQuery("<img>").attr("src", arguments[i]);
	    		  }
	    		}*/</script><%
	        if NVL(array_evid(5, 0)) <> "" then
	            'mostramos el archivo completo
	            'Response.Write array_evid(1, 0)
	            %> 
	            <a href="http://189.204.115.238<%=array_evid(1, 0)%><%=array_evid(5, 0)%>" style="margin:3px;border:0px;"><img src="images/pdf.gif" style="border:0px;" />&nbsp;Descargar archivo completo (<%=Format_Size(array_evid(6, 0))%>)</a><br>
	        <%end if
            for i = 0 to UBound(array_evid, 2)
            %>
                <div style="float:left;margin:3px;padding:6px" id="archivo_<%=array_evid(0, i)%>">
                  <a href="http://189.204.115.238<%=array_evid(1, i)%><%=array_evid(3, i)%>" class="jqzoom" title="">
                    <img src="http://189.204.115.238<%=array_evid(1, i)%><%=array_evid(4, i)%>" style="border: 1px solid #666">
                  </a>
                  <div style="margin-top: 2px; width:204px" class="light">
                    <a href="http://189.204.115.238<%=array_evid(1, i)%><%=array_evid(2, i)%>" target="_blank">ver original</a>
                  </div>
                </div>
                <!--script>$.preloadImages("/evidencias/<%=array_evid(1, i)%><%=array_evid(3, i)%>");</script-->
            <% 
            next
            Response.Write "<br style='clear:left;'></div>"
    
        end if 
    end if
	
	
	'if IP_interna and array_tmp(15, 0) <> "" then
    '    'digitalizacion de entrada
    '    SQL = " SELECT '/entrada_archivos/' || REPLACE(DGECARPETA, '\', '/') " & VbCrlf
    '    SQL = SQL & " , DGEARCHIVO " & VbCrlf
    '    SQL = SQL & " FROM EDIGITALIZACION_ENTRADA " & VbCrlf
    '    SQL = SQL & " WHERE DGE_TDCDCLAVE = " & array_tmp(15, 0)
    '    array_evid = GetArrayRS(SQL)
    '    
    '    if IsArray(array_evid) then
    '        Response.Write "<br><br><b>Documentacion de entrada</b>:<br>"
    '        for i = 0 to UBound(array_evid, 2)
    '            Response.Write Replace("<a href='" & array_evid(0, i) & array_evid(1, i) & "' style='margin:3px;border:0px;'><img src='images/pdf.gif' style='border:0px;' />&nbsp;"& array_evid(1, i) & "</a><br>", "logiscomercioexterior.com.mx", "192.168.100.4")
    '        next
    '    end if
    'end if
	
	
    
    SQL = "SELECT /*+USE_CONCAT ORDERED */ CHONUMERO " & VbCrlf
    SQL = SQL & "   , InitCap(CHONOMBRE) " & VbCrlf
    
	'<<<Importe LTL:
	'SQL = SQL & "   , WLC_IMPORTE " & VbCrlf
	SQL = SQL & "   , (CASE WHEN WLC_CHOCLAVE = 3920 THEN NVL(WTS.IMP_DISTRIBUCION,WLC_IMPORTE) ELSE WLC_IMPORTE END) IMPORTE " & VbCrlf
    '   Importe LTL>>>
	
	SQL = SQL & "   , WLC_CHOCLAVE " & VbCrlf
    SQL = SQL & "   , WLC_WELCLAVE " & VbCrlf
    SQL = SQL & "   , WEL_TDCDCLAVE " & VbCrlf
    SQL = SQL & "   FROM WEB_LTL WEL   " & VbCrlf
    SQL = SQL & "    , WEB_LTL_CONCEPTOS   " & VbCrlf
    SQL = SQL & "    , ECONCEPTOSHOJA " & VbCrlf
	
	'<<<Importe LTL:
	SQL = SQL &  "   , WEB_TRACKING_STAGE WTS " & VbCrlf
	'   Importe LTL>>>
	
    SQL = SQL & "   WHERE (WEL.WEL_FIRMA IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") & "')   " & VbCrlf
    SQL = SQL & "           OR WEL.WEL_TALON_RASTREO IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") & "')   " & VbCrlf
    SQL = SQL & "         ) " & vbCrLf    
    SQL = SQL & "     AND WLC_WELCLAVE = WELCLAVE   " & VbCrlf
    SQL = SQL & " 	  AND CHOCLAVE = WLC_CHOCLAVE " & VbCrlf
	
	'<<<Importe LTL:
	SQL = SQL &  "   	AND WEL.WELCLAVE = WTS.NUI " & VbCrlf 
	'   Importe LTL>>>
	
    SQL = SQL & "     AND WLCSTATUS = 1   " & VbCrlf
    SQL = SQL & "     AND WLC_IMPORTE <> 0   " & VbCrlf
    SQL = SQL & " ORDER BY 1 "
    array_tmp = GetArrayRS(SQL)
    if IsArray(array_tmp) then%>
    <br><br>
    <table class="datos" align="center"  valign="top" width="800" border="1" cellpadding="3" cellspacing="0">
      <tr class="titulo_trading_bold" align="center"> 
    	<td colspan="4">Conceptos</td>
    	<td colspan="4">Facturacion</td>
      </tr>
      <tr> 
    	<td width="20" class="titulo_trading_bold">&nbsp;No.</td>
    	<td width="200" class="titulo_trading_bold">&nbsp;Descripcion</td>
    	<td width="60" class="titulo_trading_bold" align='right'>&nbsp;Importe</td>
    	<td width="320" class="titulo_trading_bold">&nbsp;Metodo de calculo</td>
    	<td width="60" class="titulo_trading_bold">&nbsp;Folio</td>
    	<td width="60" class="titulo_trading_bold">&nbsp;Factura</td>
    	<td width="60" class="titulo_trading_bold">&nbsp;Fecha Factura</td>
      </tr><%
        for i = 0 to UBound(array_tmp, 2)
            Response.Write "<tr>" & vbCrLf
            Response.Write vbTab & "<td>&nbsp;" & array_tmp(0, i) & "</td>" & vbCrLf
            Response.Write vbTab & "<td>&nbsp;" & array_tmp(1, i) & "</td>" & vbCrLf
            Response.Write vbTab & "<td align='right'>&nbsp;$" & Num_Format(array_tmp(2, i)) & "</td>" & vbCrLf
            'texto_metodo = view_Metodos(array_tmp(4, i), array_tmp(3, i))
            Response.Write vbTab & "<td>&nbsp;" & view_Metodos(array_tmp(4, i), array_tmp(3, i)) & "</td>" & vbCrLf
            
            'recuperacion de los datos de facturas
            if NVL(array_tmp(5,i)) <> "" then   'WEL_TDCDCLAVE
                sql = " SELECT FOLFOLIO, FCTNUMERO, TO_CHAR(FCTDATEFACTURE, 'DD/MM/YYYY') " & VbCrlf
                SQL = SQL & " FROM EDET_TRAD_FACTURA_CLIENTE_FACT DTFF " & VbCrlf
                SQL = SQL & "   , EDET_TRAD_FACTURA_CLIENTE DTFC " & VbCrlf
                SQL = SQL & "   , ETRAD_FACTURA_CLIENTE TFC " & VbCrlf
                SQL = SQL & "   , EFOLIOS FOL " & VbCrlf
                SQL = SQL & "   , EFACTURAS FCT " & VbCrlf
                SQL = SQL & " WHERE DTFF.DTFF_TDCDCLAVE = " & array_tmp(5,i) & VbCrlf
                SQL = SQL & " 	AND DTFC.DTFCCLAVE = DTFF.DTFF_DTFCCLAVE " & VbCrlf
                SQL = SQL & " 	AND DTFC.DTFC_CHOCLAVE = " & array_tmp(3,i) & VbCrlf
                SQL = SQL & " 	AND TFC.TFCCLAVE = DTFC.DTFC_TFCCLAVE " & VbCrlf
                SQL = SQL & " 	AND FOL.FOLCLAVE = TFC.TFC_FOLCLAVE " & VbCrlf
                SQL = SQL & " 	AND FCT.FCTFOLIO = FOL.FOLCLAVE " & VbCrlf
                SQL = SQL & " 	AND FCT.FCT_YFACLEF = '1'"
                SQL = SQL & " UNION ALL "
                SQL = SQL & " SELECT FOLFOLIO, FCTNUMERO, TO_CHAR(FCTDATEFACTURE, 'DD/MM/YYYY') " & VbCrlf
                SQL = SQL & " FROM ETRANS_DETALLE_CROSS_DOCK " & VbCrlf
                SQL = SQL & "   , EFOLIOS FOL " & VbCrlf
                SQL = SQL & "   , EFACTURAS FCT " & VbCrlf
                SQL = SQL & "   , EDETAILFACTURE " & VbCrlf
                SQL = SQL & " WHERE TDCDCLAVE = " & array_tmp(5,i) & VbCrlf
                SQL = SQL & " 	AND FOL.FOLCLAVE = TDCD_FOLCLAVE " & VbCrlf
                SQL = SQL & " 	AND FCT.FCTFOLIO = FOL.FOLCLAVE " & VbCrlf
                SQL = SQL & " 	AND FCT.FCT_YFACLEF = '1'  " & VbCrlf
                SQL = SQL & " 	AND DTFFACTURE = FCTCLEF " & VbCrlf
                SQL = SQL & " 	AND DTF_CHOCLAVE = " & array_tmp(3,i) & VbCrlf
                array_temp = GetArrayRS(SQL)
                if IsArray(array_temp) then
                    Response.Write vbTab & "<td>&nbsp;" & array_temp(0, 0) & "</td>" & vbCrLf
                    Response.Write vbTab & "<td>&nbsp;" & array_temp(1, 0) & "</td>" & vbCrLf
                    Response.Write vbTab & "<td>&nbsp;" & array_temp(2, 0) & "</td>" & vbCrLf
                else
                    Response.Write vbTab & "<td>&nbsp;</td>" & vbCrLf
                    Response.Write vbTab & "<td>&nbsp;</td>" & vbCrLf
                    Response.Write vbTab & "<td>&nbsp;</td>" & vbCrLf
                end if
            end if   
            Response.Write "</tr>" & vbCrLf
        next
        
        'CONCEPTOS ADICIONALES
        if NVL(array_tmp(5, 0)) <> "" then
            SQL = "SELECT CHONUMERO  " & VbCrlf
            SQL = SQL & "    , InitCap(CHONOMBRE) " & VbCrlf
            SQL = SQL & "    , FCI_IMPORTE " & VbCrlf
            SQL = SQL & "    , FCI_TDCDCLAVE " & VbCrlf
            SQL = SQL & "    , CHOCLAVE " & VbCrlf
            SQL = SQL & " FROM EFACTURA_CONC_INCREMENT " & VbCrlf
            SQL = SQL & "   , ECONCEPTOSHOJA " & VbCrlf
            SQL = SQL & " WHERE FCI_TDCDCLAVE IN ( " & VbCrlf
            SQL = SQL & " 	SELECT TDCDCLAVE " & VbCrlf
            SQL = SQL & " 	FROM ETRANS_DETALLE_CROSS_DOCK " & VbCrlf
            SQL = SQL & " 	WHERE TDCDCLAVE = " & array_tmp(5, 0) & VbCrlf
            SQL = SQL & " 	UNION ALL " & VbCrlf
            SQL = SQL & " 	SELECT TDCDCLAVE " & VbCrlf
            SQL = SQL & " 	FROM ETRANS_DETALLE_CROSS_DOCK " & VbCrlf
            SQL = SQL & " 	WHERE TDCD_DXPCLAVE_ORI IN ( " & VbCrlf
            SQL = SQL & " 		SELECT DXPCLAVE " & VbCrlf
            SQL = SQL & " 		FROM EDET_EXPEDICIONES " & VbCrlf
            SQL = SQL & " 		CONNECT BY PRIOR DXPCLAVE = DXP_DXPCLAVE " & VbCrlf
            SQL = SQL & " 		START WITH DXP_TDCDCLAVE = "& array_tmp(5, 0) &"  ) " & VbCrlf
            SQL = SQL & " ) " & VbCrlf
            SQL = SQL & "   AND CHOCLAVE = FCI_CHOCLAVE"    
            array_tmp = GetArrayRS(SQL)
            if IsArray(array_tmp) then%>
                <tr class="titulo_trading_bold" align="center"> 
    	            <td colspan="4">Conceptos Adicionales</td>
    	            <td colspan="4">Facturacion</td>
                </tr>
                <%
                  for i = 0 to UBound(array_tmp, 2)
                      Response.Write "<tr>" & vbCrLf
                      Response.Write vbTab & "<td>&nbsp;" & array_tmp(0, i) & "</td>" & vbCrLf
                      Response.Write vbTab & "<td>&nbsp;" & array_tmp(1, i) & "</td>" & vbCrLf
                      Response.Write vbTab & "<td align='right'>&nbsp;$" & Num_Format(array_tmp(2, i)) & "</td>" & vbCrLf
                      Response.Write vbTab & "<td>&nbsp;Importe capturado</td>" & vbCrLf
                      'recuperacion de los datos de facturas
                    if NVL(array_tmp(3,i)) <> "" then   'WEL_TDCDCLAVE
                        sql = " SELECT FOLFOLIO, FCTNUMERO, TO_CHAR(FCTDATEFACTURE, 'DD/MM/YYYY') " & VbCrlf
                        SQL = SQL & " FROM EDET_TRAD_FACTURA_CLIENTE_FACT DTFF " & VbCrlf
                        SQL = SQL & "   , EDET_TRAD_FACTURA_CLIENTE DTFC " & VbCrlf
                        SQL = SQL & "   , ETRAD_FACTURA_CLIENTE TFC " & VbCrlf
                        SQL = SQL & "   , EFOLIOS FOL " & VbCrlf
                        SQL = SQL & "   , EFACTURAS FCT " & VbCrlf
                        SQL = SQL & " WHERE DTFF.DTFF_TDCDCLAVE = " & array_tmp(3,i) & VbCrlf
                        SQL = SQL & " 	AND DTFC.DTFCCLAVE = DTFF.DTFF_DTFCCLAVE " & VbCrlf
                        SQL = SQL & " 	AND DTFC.DTFC_CHOCLAVE = " & array_tmp(4,i) & VbCrlf
                        SQL = SQL & " 	AND TFC.TFCCLAVE = DTFC.DTFC_TFCCLAVE " & VbCrlf
                        SQL = SQL & " 	AND FOL.FOLCLAVE = TFC.TFC_FOLCLAVE " & VbCrlf
                        SQL = SQL & " 	AND FCT.FCTFOLIO = FOL.FOLCLAVE " & VbCrlf
                        SQL = SQL & " 	AND FCT.FCT_YFACLEF = '1'"
                        SQL = SQL & " UNION ALL "
                        SQL = SQL & " SELECT FOLFOLIO, FCTNUMERO, TO_CHAR(FCTDATEFACTURE, 'dd/mm/YYYY') " & VbCrlf
                        SQL = SQL & " FROM ETRANS_DETALLE_CROSS_DOCK " & VbCrlf
                        SQL = SQL & "   , EFOLIOS FOL " & VbCrlf
                        SQL = SQL & "   , EFACTURAS FCT " & VbCrlf
                        SQL = SQL & "   , EDETAILFACTURE " & VbCrlf
                        SQL = SQL & " WHERE TDCDCLAVE = " & array_tmp(3,i) & VbCrlf
                        SQL = SQL & " 	AND FOL.FOLCLAVE = TDCD_FOLCLAVE " & VbCrlf
                        SQL = SQL & " 	AND FCT.FCTFOLIO = FOL.FOLCLAVE " & VbCrlf
                        SQL = SQL & " 	AND FCT.FCT_YFACLEF = '1'  " & VbCrlf
                        SQL = SQL & " 	AND DTFFACTURE = FCTCLEF " & VbCrlf
                        SQL = SQL & " 	AND DTF_CHOCLAVE = " & array_tmp(4,i) & VbCrlf
                        'Response.Write sql
                        array_temp = GetArrayRS(SQL)
                        if IsArray(array_temp) then
                            Response.Write vbTab & "<td>&nbsp;" & array_temp(0, 0) & "</td>" & vbCrLf
                            Response.Write vbTab & "<td>&nbsp;" & array_temp(1, 0) & "</td>" & vbCrLf
                            Response.Write vbTab & "<td>&nbsp;" & array_temp(2, 0) & "</td>" & vbCrLf
                        else
                            Response.Write vbTab & "<td>&nbsp;</td>" & vbCrLf
                            Response.Write vbTab & "<td>&nbsp;</td>" & vbCrLf
                            Response.Write vbTab & "<td>&nbsp;</td>" & vbCrLf
                        end if
                    end if   
                    Response.Write "</tr>" & vbCrLf
                  next
            
            end if
        end if
    
    %>
    
    
    
    </table>
    <%end if

    
end if%>

<%
'???oscar 20141222
SQL_Log="select nvl(max(LOGCLV),0)+1 from ELOGS_TRACKING "
array_Log = GetArrayRS(SQL_Log)
consecutivo= array_Log(0,0)

Set rst = Server.CreateObject("ADODB.Recordset")				
SQL_Ins =" INSERT INTO ELOGS_TRACKING "
if mi_traclave="" and mi_tdcdclave="" then
	SQL_Log=" SELECT  WELCLAVE CLAVE,'LTL' TIPO FROM WEB_LTL " & VbCrlf
	SQL_Log= SQL_Log &" WHERE WEL_TALON_RASTREO in ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") &"')  " & VbCrlf
	SQL_Log= SQL_Log &" OR WEL_FIRMA IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") &"') " & VbCrlf
	SQL_Log= SQL_Log &" UNION ALL " & VbCrlf
	SQL_Log= SQL_Log &" SELECT WCD_TDCDCLAVE CLAVE,'CD' TIPO FROM WCROSS_DOCK " & VbCrlf
	SQL_Log= SQL_Log &" WHERE WCD_FIRMA IN ('"& Replace(SQLEscape(Request.QueryString("track_num")),VbCrlf,"','") &"')" & VbCrlf
	array_Log = GetArrayRS(SQL_Log)
	

	if isArray(array_Log) then
		if (array_Log(1,0)="LTL" and array_Log(0,0) <> "")  then
			SQL_Ins = SQL_Ins & "  VALUES (" & consecutivo &"," & clave_cliente &",USER,SYSDATE,NULL," & array_Log(0,0) &",NULL,'" & Request.ServerVariables("REMOTE_ADDR") & "') "
		elseif (array_Log(1,0)="CD" and array_Log(0,0) <> "")  then
			SQL_Ins = SQL_Ins & "  VALUES (" & consecutivo &"," & clave_cliente &",USER,SYSDATE,NULL,NULL," & array_Log(0,0) &",'" & Request.ServerVariables("REMOTE_ADDR") & "') "
		else
			sql_ins = ""
		end if
	end if
else
	if mi_traclave<>""  then
		SQL_Ins = SQL_Ins & "  VALUES (" & consecutivo &"," & clave_cliente &",USER,SYSDATE," & mi_traclave &",NULL,NULL,'" & Request.ServerVariables("REMOTE_ADDR") & "') "	
	elseif mi_tdcdclave="" then
		SQL_Ins = SQL_Ins & "  VALUES (" & consecutivo &"," & clave_cliente &",USER,SYSDATE,NULL,NULL,NULL,'" & Request.ServerVariables("REMOTE_ADDR") & "') "	
	else
		sql_ins = ""
	end if
end if
if sql_ins <> "" then
	'response.write(SQL_ins)
'<!--CHG-DESA-19072024-01: este log es necesario?
'	rst.Open SQL_ins, Connect(), 0, 1, 1
'    CHG-DESA-19072024-01-->
	'???
end if

'<<<<< CESAR
'end if
'CESAR >>>>>
%>


<%
'	if Request.QueryString("noMenu") <> "1" and Request.QueryString("label") <> "folio" then
%>

<br><br>

<form action="ltl_tracking_summary.asp" method="post" name=track_num>
	<table class="datos"  align="center" border="1" cellpadding="2" cellspacing="0" >
	<tr> 
		<td  align="left" valign="top" class="titulo_trading_bold">
		
		   &nbsp;&nbsp;&nbsp; Buscar otra(s) Gu&iacute;a(s):<br>   &nbsp;&nbsp;&nbsp; 
		   <textarea name="track_num" rows="7" class="light" style="scrollbar-face-color:goldenrod;scrollbar-shadow-color:gray;"></textarea>
		   <input type="submit" name="submit" value="Buscar" class="button_trading">
		

		</td>
	</tr>
	</table>
</form>

<%
'end if
%>

</body>
</html>
