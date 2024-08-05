<!--#include file="html.asp"-->
<%
dim mostrarBotonCancelar
	mostrarBotonCancelar = false
	
dim tarifaEspecial
	tarifaEspecial = false
'<<CHG-DESA-04052023-01: Tiempo en minutos de gracia para actualizar los NUIs apartados y no documentados
dim min_clean
	min_clean = "60"
''CHG-DESA-04052023-01>>
Sub BuildNav (PageNum,Offset, TotalRecord, asp_dest )
Dim TotalP
TotalP = int ((TotalRecord-1) \ (Offset)) +1 
Response.Write "<br>"
	Dim counter, counterEnd
	Response.Write "<font face=verdana size=1><b>"
	
	' If the previous page id is not 0, then let's add the 'prev' link.
	if PageNum  > 1 then
		if PageNum > Offset then	
			With Response
				.Write "<a href="& asp_self() &"?PageNum="
				.Write PageNum - Offset & asp_dest & "><< prev " & Offset & "</a>"
				.Write  NBSP(5)
			End With
		end if
		With Response
			.Write "<a href="& asp_self() &"?PageNum="
			.Write PageNum - 1 &  asp_dest & ">< prev</a>"
			.Write  NBSP(5)
		End With		
	end if

	'This section displays the list of page numbers as links, separated with the pipe ( | )
	counter = PageNum
	if PageNum + Offset > TotalP then 
		counterEnd = TotalP - PageNum
	else counterEnd = counter + Offset -1
	end if
		
	Response.Write  "<br>jump to page: <br>"
	Dim I, C
	C=0
	I = (INT((PageNum-1)/Offset) * Offset)+1 
	
	do while I <> TotalP+1 AND C<>Offset
		C=C+1
		If I = PageNum Then
			Response.Write " " & I & " "
		Else
			Response.Write  "<a href="& asp_self() &"?PageNum="
			Response.Write  I & asp_dest & ">" & I & "</a>"
		End If
		
		if C <> Offset AND I <> TotalP then
			Response.Write  " | "
		end if
		I = I + 1		
	loop

	if (PageNum < TotalP ) then
		With Response
			.Write  NBSP(5)
			.Write "<br><a href="& asp_self() &"?PageNum="
			.Write PageNum + 1 & asp_dest & ">next ></a>"
		End With
		if (PageNum + Offset <= TotalP  ) then
			With Response
				.Write  NBSP(5)
				.Write "<a href="& asp_self() &"?PageNum="
				.Write PageNum + Offset & asp_dest & ">next " & Offset & " >></a>"
			End With
		end if
	end if
	Response.Write "<br><br>" & TotalP  & " page"
	if TotalP >1 then
		Response.Write "s"
	end if
	Response.Write " found ( " & TotalRecord  &" record"
	if TotalRecord >1 then
		Response.Write "s"
	end if
	Response.Write " ) </b></font>"
end Sub

'idem que BuildNav, pero con el uso de los formularios
'asi cada clic va modificar la variable PageNum del formulario
'pasar el nombre de la funcion Javascript para modificar el numero de pagina
Sub BuildNav2 (PageNum, Offset, TotalRecord, JS_func )
Dim TotalP
TotalP = int ((TotalRecord-1) \ (Offset)) +1 
Response.Write "<br>" 
	Dim counter, counterEnd
	Response.Write "<font face=verdana size=1><b>"
	
	' If the previous page id is not 0, then let's add the 'prev' link.
	if PageNum  > 1 then
		if PageNum > Offset then	
			With Response
				.Write  "<a href=""javascript:"& JS_func &"('"& PageNum - Offset &"');""><< prev " & Offset & "</a>"
				.Write  NBSP(5)
			End With
		end if
		With Response
			.Write "<a href=""javascript:"& JS_func &"('"& PageNum - 1 &"');"">< prev</a>"
			.Write  NBSP(5)
		End With		
	end if

	'This section displays the list of page numbers as links, separated with the pipe ( | )
	counter = PageNum
	if PageNum + Offset > TotalP then 
		counterEnd = TotalP - PageNum
	else counterEnd = counter + Offset -1
	end if
		
	Response.Write  "<br>jump to page: <br>"
	Dim I, C
	C=0
	I = (INT((PageNum-1)/Offset) * Offset)+1 
	
	do while I <> TotalP+1 AND C<>Offset
		C=C+1
		If I = PageNum Then
			Response.Write " " & I & " "
		Else
			Response.Write  "<a href=""javascript:"& JS_func &"('"& I &"');"">" & I & "</a>"
		End If
		
		if C <> Offset AND I <> TotalP then
			Response.Write  " | "
		end if
		I = I + 1		
	loop

	if (PageNum < TotalP ) then
		With Response
			.Write  NBSP(5)
			.Write  "<br><a href=""javascript:"& JS_func &"('"& PageNum + 1 &"');"">next ></a>"
		End With
		if (PageNum + Offset <= TotalP  ) then
			With Response
				.Write  NBSP(5)
				.Write  "<br><a href=""javascript:"& JS_func &"('"& PageNum + Offset &"');"">next " & Offset & " >></a>"
			End With
		end if
	end if
	Response.Write "<br><br>" & TotalP  & " page"
	if TotalP >1 then
		Response.Write "s"
	end if
	Response.Write " found ( " & TotalRecord  &" record"
	if TotalRecord >1 then
		Response.Write "s"
	end if
	Response.Write " ) </b></font>"
end Sub


function Connect()
	dim strCon, obj_conn 
	set obj_conn=Server.CreateObject("ADODB.connection")
	Dim CONN_STRING, CONN_USER, CONN_PASS	
	CONN_STRING = Get_Conn_string("SERVER")
	CONN_USER = Get_Conn_string("LOGIN")
	CONN_PASS = Get_Conn_string("PASS")
	obj_conn.ConnectionTimeout = 1000	'timeout for connection
	obj_conn.CommandTimeout = 1000		' timeout for SQL commands
	obj_conn.Open CONN_STRING, CONN_USER, CONN_PASS	
	Connect = obj_conn
end function

sub exec(SQL)
	Dim rst_exec
	
	Session("SQL") = SQL
	set rst_exec = Server.CreateObject("ADODB.Recordset")
	rst_exec.Open SQL, Connect(), 0, 1, 1
end sub

sub add_wel_concept (le_ins_welclave, le_ins_chonumero)
	dim cmd, Param

	Set cmd = CreateObject("ADODB.command")
	cmd.ActiveConnection = Connect()
	cmd.CommandType = adCmdStoredProc
	cmd.CommandText = "SET_LTL_CONCEPTO"					
	
	Set Param = Server.CreateObject("ADODB.Parameter")
	Param.Name = "ins_welclave"
	Param.Type = adDouble
	Param.Direction = adParamInput
	Param.Value = le_ins_welclave
						
	cmd.Parameters.Append Param

	Set Param = Server.CreateObject("ADODB.Parameter")
	Param.Name = "ins_chonumero"
	Param.Type = adDouble
	Param.Direction = adParamInput
	Param.Value = le_ins_chonumero
						
	cmd.Parameters.Append Param

	Set Param = Server.CreateObject("ADODB.Parameter")
	Param.Name = "ins_choclave"
	Param.Type = adDouble
	Param.Direction = adParamInput
	Param.Value = null
						
	cmd.Parameters.Append Param
  
	cmd.Execute
		    if le_ins_chonumero = "349" then	    	
		    	call add_wel_concept(le_ins_welclave,350)
		    end if
end sub


sub tarifa_349 (le_ins_cli)
dim cmd, Param

		    Set cmd = CreateObject("ADODB.command")
		    cmd.ActiveConnection = Connect()
		    cmd.CommandType = adCmdStoredProc
		    cmd.CommandText = "tarifa_349"		    				    
		    
		    Set Param = Server.CreateObject("ADODB.Parameter")
		    Param.Name = "ins_cli"
		    Param.Type = adDouble
		    Param.Direction = adParamInput
		    Param.Value = le_ins_cli
		    				    
		    cmd.Parameters.Append Param

		    cmd.Execute		    
end sub


sub add_wcd_concept (le_ins_wcdclave, le_ins_chonumero)
dim cmd, Param

		    Set cmd = CreateObject("ADODB.command")
		    cmd.ActiveConnection = Connect()
		    cmd.CommandType = adCmdStoredProc
		    cmd.CommandText = "SET_WCD_CONCEPTO"		    				    
		    
		    Set Param = Server.CreateObject("ADODB.Parameter")
		    Param.Name = "ins_wcdclave"
		    Param.Type = adDouble
		    Param.Direction = adParamInput
		    Param.Value = le_ins_wcdclave
		    				    
		    cmd.Parameters.Append Param

		    Set Param = Server.CreateObject("ADODB.Parameter")
		    Param.Name = "ins_chonumero"
		    Param.Type = adDouble
		    Param.Direction = adParamInput
		    Param.Value = le_ins_chonumero
		    				    
		    cmd.Parameters.Append Param

		    Set Param = Server.CreateObject("ADODB.Parameter")
		    Param.Name = "ins_choclave"
		    Param.Type = adDouble
		    Param.Direction = adParamInput
		    Param.Value = null
		    				    
		    cmd.Parameters.Append Param
          
		    cmd.Execute		    
end sub


sub set_op_status (ins_clave, ins_tipo)
	dim ins_cmd, ins_Param

	Set ins_cmd = CreateObject("ADODB.command")
	ins_cmd.ActiveConnection = Connect()
	ins_cmd.CommandType = adCmdStoredProc
	
	if ins_tipo = "LTL" THEN
		ins_cmd.CommandText = "LOGIS.SET_OP_STATUS_LTL"
	else
		ins_cmd.CommandText = "LOGIS.SET_OP_STATUS_CD"
	end if

	Set ins_Param = Server.CreateObject("ADODB.Parameter")
	ins_Param.Name = "mi_clave"
	ins_Param.Type = adDouble
	ins_Param.Direction = adParamInput
	ins_Param.Value = ins_clave

	ins_cmd.Parameters.Append ins_Param
	
	ins_cmd.Execute
end sub


function genera_talon (ins_cli, id_from, id_to, cajas, peso, volumen, id_fact)
	dim ins_cmd
	dim ins_Param_cli, ins_Param_from, ins_Param_to
	dim ins_Param_cajas, ins_Param_peso, ins_Param_volumen
	dim ins_Param_id_fact
	dim return_Param
	dim resultado

	Set ins_cmd = CreateObject("ADODB.command")
	ins_cmd.ActiveConnection = Connect()
	ins_cmd.CommandType = adCmdStoredProc
	
	ins_cmd.CommandText = "LOGIS.CREATE_TALON"

	Set return_Param = Server.CreateObject("ADODB.Parameter")
	return_Param.Type = adVarChar
	return_Param.Direction = adParamReturnValue
	return_Param.Size = 2000
	ins_cmd.Parameters.Append return_Param


	Set ins_Param_cli = Server.CreateObject("ADODB.Parameter")
	ins_Param_cli.Name = "ins_cli"
	ins_Param_cli.Type = adDouble
	ins_Param_cli.Direction = adParamInput
	ins_Param_cli.Value = ins_cli
	ins_cmd.Parameters.Append ins_Param_cli

	Set ins_Param_from = Server.CreateObject("ADODB.Parameter")
	ins_Param_from.Name = "id_from"
	ins_Param_from.Type = adVarChar
	ins_Param_from.Direction = adParamInput
	ins_Param_from.Size = 2000
	ins_Param_from.Value = id_from
	ins_cmd.Parameters.Append ins_Param_from
	
	Set ins_Param_to = Server.CreateObject("ADODB.Parameter")
	ins_Param_to.Name = "id_to"
	ins_Param_to.Type = adVarChar
	ins_Param_to.Direction = adParamInput
	ins_Param_to.Size = 2000
	ins_Param_to.Value = id_to
	ins_cmd.Parameters.Append ins_Param_to	

	Set ins_Param_cajas = Server.CreateObject("ADODB.Parameter")
	ins_Param_cajas.Name = "cajas"
	ins_Param_cajas.Type = adDouble
	ins_Param_cajas.Direction = adParamInput
	if (cajas = "") then
		ins_Param_cajas.Value = 0
	else
		ins_Param_cajas.Value = cajas
	end if
	ins_cmd.Parameters.Append ins_Param_cajas	
	
	Set ins_Param_peso = Server.CreateObject("ADODB.Parameter")
	ins_Param_peso.Name = "peso"
	ins_Param_peso.Type = adDouble
	ins_Param_peso.Direction = adParamInput
	if (peso = "") then
		ins_Param_peso.Value = 0
	else
		ins_Param_peso.Value = peso
	end if
	ins_cmd.Parameters.Append ins_Param_peso

	Set ins_Param_volumen = Server.CreateObject("ADODB.Parameter")
	ins_Param_volumen.Name = "volumen"
	ins_Param_volumen.Type = adDouble
	ins_Param_volumen.Direction = adParamInput
	if (volumen = "") then
		ins_Param_volumen.Value = 0
	else
		ins_Param_volumen.Value = volumen
	end if
	ins_cmd.Parameters.Append ins_Param_volumen

	Set ins_Param_id_fact = Server.CreateObject("ADODB.Parameter")
	ins_Param_id_fact.Name = "ins_id_fact"
	ins_Param_id_fact.Type = adVarChar
	ins_Param_id_fact.Direction = adParamInput
	ins_Param_id_fact.Size = 2000
	ins_Param_id_fact.Value = id_fact
	ins_cmd.Parameters.Append ins_Param_id_fact

	ins_cmd.Execute

	resultado = ins_cmd.Parameters(0)

	genera_talon = resultado
end function


function genera_cd (ins_cli, id_to, id_fact, tracking)
	dim ins_cmd
	dim ins_Param_cli, ins_Param_to, ins_Param_id_fact
	dim return_Param
	dim resultado

	Set ins_cmd = CreateObject("ADODB.command")
	ins_cmd.ActiveConnection = Connect()
	ins_cmd.CommandType = adCmdStoredProc
	
	ins_cmd.CommandText = "LOGIS.CREATE_CD"

	Set return_Param = Server.CreateObject("ADODB.Parameter")
	return_Param.Type = adVarChar
	return_Param.Direction = adParamReturnValue
	return_Param.Size = 2000
	ins_cmd.Parameters.Append return_Param

	Set ins_Param_cli = Server.CreateObject("ADODB.Parameter")
	ins_Param_cli.Name = "ins_cli"
	ins_Param_cli.Type = adDouble
	ins_Param_cli.Direction = adParamInput
	ins_Param_cli.Value = ins_cli
	ins_cmd.Parameters.Append ins_Param_cli
	
	Set ins_Param_to = Server.CreateObject("ADODB.Parameter")
	ins_Param_to.Name = "id_to"
	ins_Param_to.Type = adVarChar
	ins_Param_to.Direction = adParamInput
	ins_Param_to.Size = 2000
	ins_Param_to.Value = id_to
	ins_cmd.Parameters.Append ins_Param_to	

	Set ins_Param_id_fact = Server.CreateObject("ADODB.Parameter")
	ins_Param_id_fact.Name = "fact"
	ins_Param_id_fact.Type = adVarChar
	ins_Param_id_fact.Direction = adParamInput
	ins_Param_id_fact.Size = 2000
	ins_Param_id_fact.Value = id_fact
	ins_cmd.Parameters.Append ins_Param_id_fact

	Set ins_Param_id_fact = Server.CreateObject("ADODB.Parameter")
	ins_Param_id_fact.Name = "tracking"
	ins_Param_id_fact.Type = adVarChar
	ins_Param_id_fact.Direction = adParamInput
	ins_Param_id_fact.Size = 2000
	ins_Param_id_fact.Value = tracking
	ins_cmd.Parameters.Append ins_Param_id_fact

	ins_cmd.Execute

	resultado = ins_cmd.Parameters(0)

	genera_cd = resultado
end function


function GetArrayRS (strSQL)
'return an array from a query
	dim strCon, obj_conn 
	set obj_conn=Server.CreateObject("ADODB.connection")
	Dim CONN_STRING, CONN_USER, CONN_PASS	
	CONN_STRING = Get_Conn_string("SERVER")
	CONN_USER = Get_Conn_string("LOGIN")
	CONN_PASS = Get_Conn_string("PASS")
	obj_conn.ConnectionTimeout = 30000	'timeout for connection
	obj_conn.CommandTimeout = 30000		' timeout for SQL commands
	obj_conn.Open CONN_STRING, CONN_USER, CONN_PASS	
	'Response.Write strSQL 
	'debug :
	Session("SQL") = strSQL
	
	Dim rst
	set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open strSQL, obj_conn, 0, 1, 1 'cursortype: forwardonly
	'Response.Write strSQL 
	
	if not(rst.EOF) then 
		GetArrayRS = rst.GetRows 
	else GetArrayRS = ""
	end if
	'clean
	set rst = nothing
	obj_conn.Close 
	set obj_conn = nothing
	'response.end
end function

'20180817 -- >
function GetArrayRS3 (strSQL)
'return an array from a query
	dim strCon, obj_conn 
	set obj_conn=Server.CreateObject("ADODB.connection")
	Dim CONN_STRING, CONN_USER, CONN_PASS	
	CONN_STRING = Get_Conn_string("SERVER")
	CONN_USER = Get_Conn_string("LOGIN")
	CONN_PASS = Get_Conn_string("PASS")
	obj_conn.ConnectionTimeout = 900	'timeout for connection
	obj_conn.CommandTimeout = 900		' timeout for SQL commands
	obj_conn.Open CONN_STRING, CONN_USER, CONN_PASS	
	'Response.Write strSQL 
	'debug :
	Session("SQL") = strSQL
	
	Dim rst
	set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open strSQL, obj_conn, 0, 1, 1 'cursortype: forwardonly
	'Response.Write strSQL 
	
	if not(rst.EOF) then 
		GetArrayRS3 = rst.GetRows 
	else GetArrayRS3 = ""
	end if
	'clean
	set rst = nothing
	obj_conn.Close 
	set obj_conn = nothing
	'response.end
end function
'20180817 -- >

function NBSP(count)
	dim i
	for i = 1 to count
		NBSP = NBSP + "&nbsp;"
	next
end function


function asp_self()
'send the name of the current script like Php_self do !
	dim long_URL, array_tmp
	long_URL  = Request.ServerVariables("SCRIPT_NAME") 
	array_tmp = Split (CStr(long_URL), "/",-1,1 )
	asp_self = array_tmp (UBound(array_tmp)) 
	set array_tmp = nothing
end function

sub check_session()
    'si no existe esta table de session redirigimos la pagina hacia la conexion
    if not isarray(Session("array_client")) then
        response.redirect ("login.asp?logoff=1")
    end if
end sub


'Class ExcelGen
'
'    Private strTmpDir
'    Public objExcel
'    Public ActiveSheet
'
'    Sub Class_Initialize()
'      Set objExcel = CreateObject("Excel.Application")
'      objExcel.Workbooks.Add
'      objExcel.Application.Visible = True
'      Set ActiveSheet = objExcel.ActiveSheet
'      strTmpDir = "C:\Inetpub\wwwroot\Logis\test\excel\"
'    End Sub
'
'    Sub Class_Terminate()
'      objExcel.Quit            'quit Excel
'      Set objExcel = Nothing   'Clean up
'
'      'Remove out of date spreadsheets
'      'CleanUpSpreadsheets
'    End Sub
'
'    Function SaveWorksheet(strFileName)
'      'Save the worksheet to a specified filename
'      'On Error Resume Next
'      Call objExcel.ActiveWorkbook.SaveAs(strFileName)
'
'      SaveWorksheet = (Err.Number = 0)
'    End Function
'
'
'    Function DisplayWorksheetDL(Base_name)
'      'Save the worksheet in a temporary file
'      Dim strFileName, objFSO, strFileDl
'
'      Set objFSO = Server.CreateObject("Scripting.FileSystemObject")
'      strFileDl = "temp\" & Base_name & "_" & objFSO.GetBaseName(objFSO.GetTempName) & ".xls"
'      strFileName = strTmpDir & strFileDl
'      Set objFSO = Nothing
'
'      If SaveWorksheet(strFileName) Then
'        'ajout nikko :
'        'Response.ContentType = "application/vnd.ms-excel"
'        'Response.Redirect strFileName
'        DisplayWorksheetDL = strFileDl
'      End If
'    End Function
'
''verifier le path temp des feuilles excel
'    Private Sub CleanUpSpreadsheets()
'       Dim objFS, objFolder, objFile
'
'       Set objFS = Server.CreateObject("Scripting.FileSystemObject")
'       strTmpDir = strTmpDir & "\temp\"
'       Set objFolder = objFS.GetFolder(strTmpDir)
'       'Loop through each file in the strTmpDir folder
'       For Each objFile In objFolder.Files
'         'Delete Spreadsheets older than 10 minutes
'         If DateDiff("n", objFile.DateLastModified, Now) > 10 Then
'           objFS.DeleteFile strTmpDir & objFile.Name, True
'         End If
'       Next
'
'       Set objFolder = Nothing
'       Set objFS = Nothing
'    End Sub
'
'End Class


function check_clinum(numClient)
'check if a number is one of the session client number 
dim arrayClient, i
arrayClient = Session("array_client") 
if isnull(numClient) then
	check_clinum = true 
	exit function
end if	
for i=0 to ubound(arrayClient,2)
	if CInt(arrayClient(2,i))= CInt(numClient) then
		check_clinum = true  
		exit function
	end if
next
check_clinum=false
end function


function print_clinum()
'display a coma separated list of all the cliclef
	dim arrayClient, i
	arrayClient = Session("array_client") 
	for i=0 to ubound(arrayClient,2)
		print_clinum = print_clinum & arrayClient(2,i) &","
	next
	print_clinum = Mid(print_clinum,1,Len (print_clinum)-1)
end function

function print_login_remitente()
'crea una cadena (separada con coma) de los remitentes por default del login
	dim arrayClient, i
	arrayClient = Session("array_client") 
	for i=0 to ubound(arrayClient,2)
		if NVL(arrayClient(8,i)) <> "" then  
			if print_login_remitente <> "" then print_login_remitente = print_login_remitente & ","
			print_login_remitente = print_login_remitente & arrayClient(8,i)
		end if
	next
end function

function print_login_cedis()
'crea una cadena (separada con coma) de los CEDIS por default del login
	dim arrayClient, i
	arrayClient = Session("array_client") 
	for i=0 to ubound(arrayClient,2)
		print_login_cedis = print_login_cedis & arrayClient(9,i) &","
	next
	print_login_cedis = Mid(print_login_cedis,1,Len (print_login_cedis)-1)
end function

function print_login_wel_observacion()
'crea una cadena (separada con vbCrLf) de las observaciones por default de LTL
	dim arrayClient, i
	arrayClient = Session("array_client") 
	for i=0 to ubound(arrayClient,2)
		if arrayClient(10,i) <> "" then
			print_login_wel_observacion = print_login_wel_observacion & arrayClient(10,i) & vbCrLf
		end if
	next
end function

function IsInArray (clef,array_tab, col_num)
	'clef : value to find in the array array_tab at the col : col_num
	dim i 
	if array_tab(col_num,0) = "" then 
		IsInArray = false
		exit function
	end if
	for i = 0 to UBound(array_tab,2)
		if CStr(array_tab(col_num,i)) = CStr(clef) then
			IsInArray = true
			exit function
		end if
	next
	IsInArray = false
end function


Sub PrintArray(vec,lo,hi,mark)
  '==-----------------------------------------==
  '== Print out an array from the lo bound    ==
  '==  to the hi bound.  Highlight the column ==
  '==  whose number matches parm mark         ==
  '==-----------------------------------------==

  Dim i,j
  Response.Write "<table border=""1"" cellspacing=""0"">"
  For i = lo to Ubound(vec,2)
    Response.Write "<tr>"
    For j = 0 to Ubound(vec,1)
      If j = mark then 
        Response.Write "<td bgcolor=""FFFFCC"">"
      Else 
        Response.Write "<td>"
      End If
      Response.Write vec(j,i) & "</td>"
    Next
    Response.Write "</tr>"
  Next
  Response.Write "</table>"
End Sub  'PrintArray


Sub SwapRows(ary,row1,row2)
  '== This proc swaps two rows of an array 
  Dim x,tempvar
  For x = 0 to Ubound(ary,2)
    tempvar = ary(row1,x)    
    ary(row1,x) = ary(row2,x)
    ary(row2,x) = tempvar
  Next
  'For x = 0 to Ubound(ary,2)
  '  tempvar = ary(row1,x)    
  '  ary(row1,x) = ary(row2,x)
  '  ary(row2,x) = tempvar
  'Next
  
End Sub  'SwapRows

Function NVL(str)
	if IsNull(str) then
		NVL = "" 
	else 
		NVL = str
	end if
End Function

Function NVL_num(str)
    If IsNull(str) Then
        NVL_num = 0
    ElseIf Trim(str) = "" Then
        NVL_num = 0
    Else
        NVL_num = str
    End If
        
End Function

Sub QuickSort(vec,loBound,hiBound,SortField, order)
  '==--------------------------------------------------------==
  '== Sort a 2 dimensional array on SortField                ==
  '==                                                        ==
  '== This procedure is adapted from the algorithm given in: ==
  '==    ~ Data Abstractions & Structures using C++ by ~     ==
  '==    ~ Mark Headington and David Riley, pg. 586    ~     ==
  '== Quicksort is the fastest array sorting routine for     ==
  '== unordered arrays.  Its big O is  n log n               ==
  '==                                                        ==
  '== Parameters:                                            ==
  '== vec       - array to be sorted                         ==
  '== SortField - The field to sort on (2nd dimension value) ==
  '== loBound and hiBound are simply the upper and lower     ==
  '==   bounds of the array's 1st dimension.  It's probably  ==
  '==   easiest to use the LBound and UBound functions to    ==
  '==   set these.                                           ==
  '== order : 0 ascending sort                               ==					
  '==		  1 descending sort                              ==
  '==--------------------------------------------------------==

  Dim pivot(),loSwap,hiSwap,temp,counter
  Redim pivot (Ubound(vec,2))

  '== Two items to sort
  if hiBound - loBound = 1 then
	if order = 0 then
		if CStr(NVL(vec(loBound,SortField))) > CStr(NVL(vec(hiBound,SortField))) then Call SwapRows(vec,hiBound,loBound)
	else
		if CStr(NVL(vec(loBound,SortField))) < CStr(NVL(vec(hiBound,SortField))) then Call SwapRows(vec,hiBound,loBound)
	end if
  End If

  '== Three or more items to sort
  
  '== 
  For counter = 0 to Ubound(vec,2)
    pivot(counter) = vec(int((loBound + hiBound) / 2),counter)
    vec(int((loBound + hiBound) / 2),counter) = vec(loBound,counter)
    vec(loBound,counter) = pivot(counter)
  Next

  loSwap = loBound + 1
  hiSwap = hiBound
  
  do
    '== Find the right loSwap
    if order = 0 then
		while loSwap < hiSwap and CStr(NVL(vec(loSwap,SortField))) <= CStr(NVL(pivot(SortField)))
		  loSwap = loSwap + 1
		wend
		'== Find the right hiSwap
		while CStr(NVL(vec(hiSwap,SortField))) > CStr(NVL(pivot(SortField)))
		  hiSwap = hiSwap - 1
		wend
	else
		while loSwap < hiSwap and CStr(NVL(vec(loSwap,SortField))) >= CStr(NVL(pivot(SortField)))
		  loSwap = loSwap + 1
		wend
		'== Find the right hiSwap
		while CStr(NVL(vec(hiSwap,SortField))) < CStr(NVL(pivot(SortField)))
		  hiSwap = hiSwap - 1
		wend	
	end if
    '== Swap values if loSwap is less then hiSwap
    if loSwap < hiSwap then Call SwapRows(vec,loSwap,hiSwap)

  loop while loSwap < hiSwap
  
  For counter = 0 to Ubound(vec,2)
    vec(loBound,counter) = vec(hiSwap,counter)
    vec(hiSwap,counter) = pivot(counter)
  Next
    
  '== Recursively call function .. the beauty of Quicksort
    '== 2 or more items in first section
    if loBound < (hiSwap - 1) then Call QuickSort(vec,loBound,hiSwap-1,SortField, order)
    '== 2 or more items in second section
    if hiSwap + 1 < hibound then Call QuickSort(vec,hiSwap+1,hiBound,SortField, order)

End Sub  'QuickSort

Public Sub QuickSort_num(vec, loBound, hiBound, SortField, order)

  '==--------------------------------------------------------==
  '== Sort a 2 dimensional array on SortField                ==
  '==                                                        ==
  '== This procedure is adapted from the algorithm given in: ==
  '==    ~ Data Abstractions & Structures using C++ by ~     ==
  '==    ~ Mark Headington and David Riley, pg. 586    ~     ==
  '== Quicksort is the fastest array sorting routine for     ==
  '== unordered arrays.  Its big O is  n log n               ==
  '==                                                        ==
  '== Parameters:                                            ==
  '== vec       - array to be sorted                         ==
  '== SortField - The field to sort on (2nd dimension value) ==
  '== loBound and hiBound are simply the upper and lower     ==
  '==   bounds of the array's 1st dimension.  It's probably  ==
  '==   easiest to use the LBound and UBound functions to    ==
  '==   set these.                                           ==
  '== order : 0 ascending sort                               ==
  '==         1 descending sort                              ==
  '==--------------------------------------------------------==
  
  Dim pivot(), loSwap, hiSwap, temp, counter
  ReDim pivot(UBound(vec, 2))

  '== Two items to sort
  If hiBound - loBound = 1 Then
    If order = 0 Then
        If CDbl(NVL_num(vec(loBound, SortField))) > CDbl(NVL_num(vec(hiBound, SortField))) Then Call SwapRows(vec, hiBound, loBound)
    Else
        If CDbl(NVL_num(vec(loBound, SortField))) < CDbl(NVL_num(vec(hiBound, SortField))) Then Call SwapRows(vec, hiBound, loBound)
    End If
  End If
  
  If hiBound = loBound Then Exit Sub
  '== Three or more items to sort
  
  '==
  For counter = 0 To UBound(vec, 2)
    pivot(counter) = vec(Int((loBound + hiBound) / 2), counter)
    vec(Int((loBound + hiBound) / 2), counter) = vec(loBound, counter)
    vec(loBound, counter) = pivot(counter)
  Next

  loSwap = loBound + 1
  hiSwap = hiBound
  
  Do
    '== Find the right loSwap
    If order = 0 Then
        While loSwap < hiSwap And CDbl(NVL_num(vec(loSwap, SortField))) <= CDbl(NVL_num(pivot(SortField)))
          loSwap = loSwap + 1
        Wend
        '== Find the right hiSwap
        While CDbl(NVL_num(vec(hiSwap, SortField))) > CDbl(NVL_num(pivot(SortField)))
          hiSwap = hiSwap - 1
        Wend
    Else
        While loSwap < hiSwap And CDbl(NVL_num(vec(loSwap, SortField))) >= CDbl(NVL_num(pivot(SortField)))
          loSwap = loSwap + 1
        Wend
        '== Find the right hiSwap
        While CDbl(NVL_num(vec(hiSwap, SortField))) < CDbl(NVL_num(pivot(SortField)))
          hiSwap = hiSwap - 1
        Wend
    End If
    '== Swap values if loSwap is less then hiSwap
    If loSwap < hiSwap Then Call SwapRows(vec, loSwap, hiSwap)

  Loop While loSwap < hiSwap
  
  For counter = 0 To UBound(vec, 2)
    vec(loBound, counter) = vec(hiSwap, counter)
    vec(hiSwap, counter) = pivot(counter)
  Next
    
  '== Recursively call function .. the beauty of Quicksort
    '== 2 or more items in first section
    If loBound < (hiSwap - 1) Then Call QuickSort_num(vec, loBound, hiSwap - 1, SortField, order)
    '== 2 or more items in second section
    If hiSwap + 1 < hiBound Then Call QuickSort_num(vec, hiSwap + 1, hiBound, SortField, order)

End Sub  'QuickSort_num

Sub TransArray(vec)
'transform an array(x,y) in an array(y,x)

Dim i, j
Dim ArrayTemp
ReDim ArrayTemp(UBound(vec,2), UBound(vec,1))


for i = 0 to UBound(vec,1)
	for j = 0 to UBound(vec,2)
		ArrayTemp(j,i) = vec(i,j)
	next
next

'ReDim TransArray(UBound(vec,2), UBound(vec,1))
vec = ArrayTemp
End Sub	'TransArray


function order_array_display(col_name, sql_col_name, col_requested, order, url_var)
'function to display arrows to reorder column when the query is simple
'url_var to complete URL resquested 
'need to check for order_by and sort variable in SQL query
	if col_requested = sql_col_name and order = "asc" then
		Response.Write "<a href="& asp_self() & "?" & "sort=desc&order_by="& sql_col_name & url_var &"&ok=1>" & col_name & "</a>"
		Response.Write "&nbsp;<img src=""images/desc_order.gif"">"
	elseif col_requested = sql_col_name then
		Response.Write "<a href="& asp_self() & "?" & "sort=asc&order_by="& sql_col_name & url_var &"&ok=1>" & col_name & "</a>"
		Response.Write "&nbsp;<img src=""images/asc_order.gif"">"
	else 
		Response.Write "<a href="& asp_self() & "?" & "sort=asc&order_by="& sql_col_name & url_var &"&ok=1>" & col_name & "</a>"
	end if
end function

Sub order_array(array_to_order, order_by ,sort)	
	if UBound(array_to_order,1) > 1 then
		Call TransArray(array_to_order)
		'Response.Write "size " & UBound(array2,2)
	
		Call QuickSort(array_to_order,0,UBound(array_to_order,1), order_by ,sort)

		Call TransArray(array_to_order)
	end if
	'Response.Write "Sort : " & sort & " Order by : " &  order_by 
end Sub

Function IsInArray_Multi(clef, array_tab, Col_num) 
    'clef : value to find in the array array_tab at the col : col_num
    'give number of line where is the data
    Dim i
    For i = 0 To UBound(array_tab, 2)
        If CStr(array_tab(Col_num, i)) = CStr(clef) Then
            IsInArray_Multi = i
            Exit Function
        End If
    Next
    IsInArray_Multi = -1
End Function

function Num_Format(value)
  value = NVL(value)
  if not IsNumeric(CStr(value))then 
	if value = "" then 
	    Num_Format = 0
	else
	    Num_Format = value
	end if
	exit function
  end if
	Num_Format = CDbl(NVL_num(value))
	if Num_Format - Round(Num_Format) <> 0 then
		Num_Format = FormatNumber(Num_Format,2)
	else
		Num_Format = Left(FormatNumber(Num_Format,2), Len(FormatNumber(Num_Format,2)) - 3)
	end if 
end function


function Num_Format_digits(value,cdad_digits)
  value = NVL(value)
  if not IsNumeric(CStr(value))then 
	if value = "" then 
	    Num_Format_digits = 0
	else
	    Num_Format_digits = value
	end if
	exit function
  end if
	Num_Format_digits = CDbl(NVL_num(value))
	if Num_Format_digits - Round(Num_Format_digits) <> 0 then
		Num_Format_digits = FormatNumber(Num_Format_digits,cdad_digits)
	else
		Num_Format_digits = Left(FormatNumber(Num_Format_digits,cdad_digits), Len(FormatNumber(Num_Format_digits,cdad_digits)) - 3)
	end if 
end function


Function find_pedimento_trading(ped_num)	
	'Recupera el numero de folio asociado a ped_num
	'ped_num esta formateado de esta manera :
	'05 20 3681-5002515
	'a�o aduana numero-pedimento
	Dim aduana, pednumero, SQL, array_ped, find_ped, pedanio
	pedanio = "20" & Mid(Trim(ped_num), 1,2)
	find_ped = Mid(Trim(ped_num), 4)
	
	aduana = Mid(find_ped, 1, 2)
	pednumero = Mid(find_ped, 4, 12)
	
	SQL = "select folfolio  " & VbCrlf
    SQL = SQL & " , pednumero ||' '|| dounom ||' '|| to_char(sgefecha_entrada, 'dd/mm/yyyy') " & VbCrlf
    SQL = SQL & "  from efolios fol  " & VbCrlf
    SQL = SQL & "  , epedimento ped  " & VbCrlf
    SQL = SQL & "  , EDOUANE " & VbCrlf
    SQL = SQL & "  , ESAAI_M3_GENERAL sge " & VbCrlf
    SQL = SQL & "  where folclave = pedfolio  " & VbCrlf
    SQL = SQL & "  and ped.PEDDOUANE = '"& aduana &"'  " & VbCrlf
    SQL = SQL & "  and ped.PEDNUMERO = '"& pednumero &"' " & VbCrlf
    SQL = SQL & "  and ped.PEDANIO = '"& pedanio &"' " & VbCrlf
    SQL = SQL & "  and ped.PEDDOUANE = sge.SGEDOUCLEF " & VbCrlf
    SQL = SQL & "  and ped.PEDNUMERO = sge.SGEPEDNUMERO " & VbCrlf
    SQL = SQL & "  and ped.PEDANIO = sge.SGEANIO " & VbCrlf
    SQL = SQL & "  and sge.SGEDOUCLEF = DOUCLEF" & VbCrlf
	SQL = SQL & " AND FOL_CLICLEF IN ("& print_clinum &")"
	'Response.Write SQL
	array_ped = GetArrayRS(SQL)
	
	if IsArray(array_ped) then
		find_pedimento_trading = "<a href=""foliod-entry.asp?xfolio=" & array_ped(0,0) & """ title=""Ver pedimento"">" & array_ped(1,0) & "</a>"
	else
		find_pedimento_trading = ped_num
	end if
end function

function IP_interna 
	if Left(Request.ServerVariables("REMOTE_ADDR"),7) = "192.168" And _
	    Request.ServerVariables("REMOTE_ADDR") <> "192.168.100.1" then
	'if not(Left(Request.ServerVariables("REMOTE_ADDR"),7) <> "192.168" Or _
	'	(Left(Request.ServerVariables("REMOTE_ADDR"),7) = "192.168" And _
	'	Split(Request.ServerVariables("REMOTE_ADDR"), ".")(2) >= 100 ) Or _
	'	Left(Request.ServerVariables("REMOTE_ADDR"),11) <> "192.168.102") then
		IP_interna = true
	else
		IP_interna = false
	end if
end function

Function isValidEmail(myEmail)
  dim isValidE
  dim regEx
  
  isValidE = True
  set regEx = New RegExp
  
  regEx.IgnoreCase = False
  
  regEx.Pattern = "^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$"
  isValidE = regEx.Test(myEmail)
  
  isValidEmail = isValidE
End Function

Sub SaveMetodos(mi_welclave)
	Dim SQL_METODOS, array_metodos

	SQL_METODOS = "select GET_CADENA_IMPORTE_CONCEPTO3('WELCLAVE='|| WELCLAVE ||';CLIENTE='|| WEL_CLICLEF||';DIV='|| WEL_DIVCLEF ||';CHOCLAVE='|| WLC_CHOCLAVE ||';EMP='|| WEL_EMPCLAVE ||'')  " & VbCrlf
    SQL_METODOS = SQL_METODOS & " ,  WLC_CHOCLAVE, NVL(WLCMANUAL, 'N'), WLC_IMPORTE " & vbCrLf
    SQL_METODOS = SQL_METODOS & " FROM WEB_LTL, WEB_LTL_CONCEPTOS WLC " & VbCrlf
    SQL_METODOS = SQL_METODOS & " WHERE WELCLAVE = " & mi_welclave
    SQL_METODOS = SQL_METODOS & "   AND WLC_WELCLAVE = WELCLAVE "
    SQL_METODOS = SQL_METODOS & "   AND WLCSTATUS = 1 "
    'no calcular los metodos para los talones que no son en pesos
    SQL_METODOS = SQL_METODOS & "   AND NVL(WEL_DIVCLEF, 'MXN') = 'MXN' " & vbcrlf

	SQL_METODOS = SQL_METODOS & " AND NOT EXISTS ( SELECT NULL FROM WEB_LTL_METODOS WLM WHERE WLM_WELCLAVE = WELCLAVE AND WLM_CHOCLAVE = WLC_CHOCLAVE AND WLMSTATUS = 1 AND WLM.DATE_CREATED >= WLC.DATE_CREATED AND WLMDESCRIPCION IS NOT NULL) "

	array_metodos = GetArrayRS(SQL_METODOS)

	If IsArray(array_metodos) Then
		dim ins_cmd
		dim ins_param_wel

		Set ins_cmd = CreateObject("ADODB.command")
		ins_cmd.ActiveConnection = Connect()
		ins_cmd.CommandType = adCmdStoredProc
		
		ins_cmd.CommandText = "LOGIS.SAVE_LTL_METODOS"

		Set ins_param_wel = Server.CreateObject("ADODB.Parameter")
		ins_param_wel.Name = "mi_welclave"
		ins_param_wel.Type = adDouble
		ins_param_wel.Direction = adParamInput
		ins_param_wel.Value = mi_welclave
		ins_cmd.Parameters.Append ins_param_wel

		ins_cmd.Execute
	End If
End Sub

Sub SaveMetodos1(mi_welclave)
  Dim SQL_METODOS, array_metodos, rstrst
  dim  cdad_digits
    SQL_METODOS = "select GET_CADENA_IMPORTE_CONCEPTO3('WELCLAVE='|| WELCLAVE ||';CLIENTE='|| WEL_CLICLEF||';DIV='|| WEL_DIVCLEF ||';CHOCLAVE='|| WLC_CHOCLAVE ||';EMP='|| WEL_EMPCLAVE ||'')  " & VbCrlf
    SQL_METODOS = SQL_METODOS & " ,  WLC_CHOCLAVE, NVL(WLCMANUAL, 'N'), WLC_IMPORTE " & vbCrLf
    SQL_METODOS = SQL_METODOS & " FROM WEB_LTL, WEB_LTL_CONCEPTOS WLC " & VbCrlf
    SQL_METODOS = SQL_METODOS & " WHERE WELCLAVE = " & mi_welclave
    SQL_METODOS = SQL_METODOS & "   AND WLC_WELCLAVE = WELCLAVE "
    SQL_METODOS = SQL_METODOS & "   AND WLCSTATUS = 1 "
    'no calcular los metodos para los talones que no son en pesos
    SQL_METODOS = SQL_METODOS & "   AND NVL(WEL_DIVCLEF, 'MXN') = 'MXN' "

	SQL_METODOS = SQL_METODOS & " AND NOT EXISTS ( SELECT NULL FROM WEB_LTL_METODOS WLM WHERE WLM_WELCLAVE = WELCLAVE AND WLM_CHOCLAVE = WLC_CHOCLAVE AND WLMSTATUS = 1 AND WLM.DATE_CREATED >= WLC.DATE_CREATED ) "
    		    
    array_metodos = GetArrayRS(SQL_METODOS)
    
    Dim PAR, BASECALCULO, METODO, CUOTAFIJA, CUOTAMIN, CUOTAMAX, CUOTAUNIDAD, Cadena, Descripcion, DescripcionMinMax, BASEDECOBRO, APARTIRDE, WLMERROR, PORCENTAJE, PRORATEO
    Dim labelKg, labelPorKg
    if IsArray(array_metodos) then
      Dim kk, ll, jj
      for kk = 0 to UBound(array_metodos, 2)
        if NVL(array_metodos(0,kk)) <> "" then
            for ll = 0 to UBound(Split(array_metodos(0,kk), "$$__$$"))
                PAR = ""
                BASECALCULO = ""
                METODO = ""
                CUOTAFIJA = ""
                CUOTAMIN = ""
                CUOTAMAX = ""
                CUOTAUNIDAD = ""
                BASEDECOBRO = ""
                APARTIRDE = ""
                WLMERROR = ""
                PORCENTAJE = ""
                PRORATEO = ""
                labelKg = ""
                labelPorKg = ""
                Cadena = Split(array_metodos(0,kk), "$$__$$")(ll)
                
                Descripcion = ""
                DescripcionMinMax = ""
                for jj = 0 to UBound(Split(Cadena, "##"))
                    if InStr(Split(Cadena, "##")(jj), "ERROR") > 0 and array_metodos(2,kk) <> "S" then   'WLCMANUAL
                        WLMERROR = Cadena
                    end if
                    if InStr(Split(Cadena, "##")(jj), "PAR=") > 0 then
                        PAR = Mid(Split(Cadena, "##")(jj), len("PAR=")+1)
                    end if
                    if InStr(Split(Cadena, "##")(jj), "BASECALCULO=") > 0 then
                        BASECALCULO = Mid(Split(Cadena, "##")(jj), len("BASECALCULO=")+1)
                    end if
                    if InStr(Split(Cadena, "##")(jj), "METODO=") > 0 then
                        METODO = Mid(Split(Cadena, "##")(jj), len("METODO=")+1)
                    end if
                    if InStr(Split(Cadena, "##")(jj), "CUOTAFIJA=") > 0 then
                        CUOTAFIJA = Mid(Split(Cadena, "##")(jj), len("CUOTAFIJA=")+1)
                    end if
                    if InStr(Split(Cadena, "##")(jj), "CUOTAMIN=") > 0 then
                        CUOTAMIN = Mid(Split(Cadena, "##")(jj), len("CUOTAMIN=")+1)
                    end if
                    if InStr(Split(Cadena, "##")(jj), "CUOTAMAX=") > 0 then
                        CUOTAMAX = Mid(Split(Cadena, "##")(jj), len("CUOTAMAX=")+1)
                    end if
                    if InStr(Split(Cadena, "##")(jj), "CUOTAUNIDAD=") > 0 then
                        CUOTAUNIDAD = Mid(Split(Cadena, "##")(jj), len("CUOTAUNIDAD=")+1)
                        if not IsNumeric(CUOTAUNIDAD) then
                            CUOTAUNIDAD = Split(CUOTAUNIDAD, " ")(0)
                        end if
                    end if
                    if InStr(Split(Cadena, "##")(jj), "PORCENTAJE=") > 0 then
                        PORCENTAJE = Mid(Split(Cadena, "##")(jj), len("PORCENTAJE=")+1)
                    end if
                    if InStr(Split(Cadena, "##")(jj), "PRORATEO=") > 0 then
                        PRORATEO = Mid(Split(Cadena, "##")(jj), len("PRORATEO=")+1)
                    end if
                    
                    if InStr(Split(Cadena, "##")(jj), "BASEDECOBRO=") > 0 then
                        BASEDECOBRO = Mid(Split(Cadena, "##")(jj), len("BASEDECOBRO=")+1)
                    end if
                    if InStr(Split(Cadena, "##")(jj), "APARTIRDE=") > 0 then
                        APARTIRDE = Mid(Split(Cadena, "##")(jj), len("APARTIRDE=")+1)
                    end if
                next
    		                    
                if IsNumeric(BASECALCULO) and IsNumeric(CUOTAUNIDAD) then
                    if Descripcion <> "" then Descripcion = Descripcion & vbCrLf
    		                        
                    if InStr(LCase(METODO), "peso") > 0 then
                        labelKg = " Kg"
                        labelPorKg = "/Kg "
                    end if
					

					if InStr(ucase(METODO), "VOLUMEN")>0 and InStr(ucase(METODO), "PESO")=0 then
						cdad_digits = 4
					else
						cdad_digits = 2
					end if

                    if BASEDECOBRO <> "" then
                        if APARTIRDE <> "" then
                            Descripcion = METODO & ", " & Num_Format(BASEDECOBRO) & " + (" & Num_Format(BASECALCULO) & _
                              " - " & Num_Format(APARTIRDE) & ")" & labelKg & " * $" & CDbl(CUOTAUNIDAD) & labelPorKg & " = $" & _
                              Num_Format(CDbl(BASEDECOBRO) + (CDbl(BASECALCULO) - CDbl(APARTIRDE)) * CDbl(CUOTAUNIDAD)) 
                        else
     '                       Descripcion = METODO & ", " & Num_Format(BASEDECOBRO) & " + " & Num_Format(BASECALCULO,cdad_digits) & _
	                        Descripcion = METODO & ", " & Num_Format(BASEDECOBRO) & " + " & Num_Format_digits(BASECALCULO,cdad_digits) & _
                              labelKg & " * $" & CDbl(CUOTAUNIDAD) & labelPorKg & " = $" & _
                              Num_Format(CDbl(BASEDECOBRO) + CDbl(BASECALCULO) * CDbl(CUOTAUNIDAD)) 
                        end if
                    else
                        if APARTIRDE <> "" then
                            Descripcion = METODO & ", " & Num_Format(BASECALCULO) & _
                              " - " & Num_Format(APARTIRDE) & ")" & labelKg & " * $" & CDbl(CUOTAUNIDAD) & labelPorKg & " = $" & _
                              Num_Format((CDbl(BASECALCULO) - CDbl(APARTIRDE)) * CDbl(CUOTAUNIDAD)) 
                        else
                            'Descripcion = METODO & ", " & Num_Format(BASECALCULO,cdad_digits) & _
							Descripcion = METODO & ", " & Num_Format_digits(BASECALCULO,cdad_digits) & _
                              labelKg & " * $" & CDbl(CUOTAUNIDAD) & labelPorKg & " = $" & _
                              Num_Format(CDbl(BASECALCULO) * CDbl(CUOTAUNIDAD)) 
                        end if
                    end if
                end if
                
                if IsNumeric(BASECALCULO) and IsNumeric(PORCENTAJE) then
                    Descripcion = METODO & ", " & Num_Format(BASECALCULO) & _
                        " * " & CDbl(PORCENTAJE) & "% = $" & _
                        Num_Format(CDbl(BASECALCULO) * CDbl(PORCENTAJE) / 100) 
                end if
    		                    
                If CUOTAFIJA <> "" then 
                    Descripcion = "Cuota fija: $" & Num_Format(CUOTAFIJA)
                end if
    		                    
                If CUOTAMIN <> "" then
                    DescripcionMinMax = "Importe minino: $" & Num_Format(CUOTAMIN)
                    if PRORATEO <> "" and PRORATEO <> "1" then
                        Descripcion = DescripcionMinMax & " (Prorrateo: " & Num_Format(CDbl(PRORATEO)*100) & "%) = " & _
                            "$" & Num_Format(CDbl(CUOTAMIN) * CDbl(PRORATEO))
                        DescripcionMinMax = ""
                    end if
                end if
                If CUOTAMAX <> "" then
                    if DescripcionMinMax <> "" then DescripcionMinMax = DescripcionMinMax & ", "
                    DescripcionMinMax = DescripcionMinMax & "Importe maximo: $" & Num_Format(CUOTAMAX)
                end if
                
                if array_metodos(2,kk) = "S" and NVL(array_metodos(3,kk)) <> "" then  'WLCMANUAL    WLC_IMPORTE
                    Descripcion = "Importe manual: $" & Num_Format(CDbl(array_metodos(3,kk)))
                end if
   		                    
                SQL = "INSERT INTO WEB_LTL_METODOS (WLMCLAVE, WLM_WELCLAVE, WLM_PARCLAVE " & vbCrLf
                SQL = SQL & " , WLMBASECALCULO, WLMMETODO, WLMCUOTAFIJA " & vbCrLf
                SQL = SQL & " , WLMCUOTAMIN, WLMCUOTAMAX, WLMCUOTAUNIDAD " & vbCrLf
                SQL = SQL & " , CREATED_BY, DATE_CREATED, WLM_CHOCLAVE " & vbCrLf
                SQL = SQL & " , WLMDESCRIPCION, WLMDESCRIPCION_MIN_MAX " & vbCrLf
                SQL = SQL & " , WLMBASEDECOBRO, WLMAPARTIRDE, WLMERROR " & vbCrLf
                SQL = SQL & " , WLMPORCENTAJE, WLMPRORATA, WLMCADENA_FACTURACION) " & vbCrLf
                SQL = SQL & " VALUES (SEQ_WLMCLAVE.nextval, " & mi_welclave & ", '" & SQLEscape(PAR) & "' " & vbCrLf
                SQL = SQL & " , '" & SQLEscape(BASECALCULO) & "', '" & SQLEscape(METODO) & "', '" & SQLEscape(CUOTAFIJA) & "'" & vbCrLf
                SQL = SQL & " , '" & SQLEscape(CUOTAMIN) & "', '" & SQLEscape(CUOTAMAX) & "', '" & SQLEscape(CUOTAUNIDAD) & "'" & vbCrLf
                SQL = SQL & " , UPPER('"& Session("array_client")(0,0) &"'), SYSDATE, "& array_metodos(1,kk) &" "
                SQL = SQL & " , '" & SQLEscape(Descripcion) & "', '" & SQLEscape(DescripcionMinMax) & "' "
                SQL = SQL & " , '" & SQLEscape(BASEDECOBRO) & "', '" & SQLEscape(APARTIRDE) & "', '" & SQLEscape(WLMERROR) & "' "
                SQL = SQL & " , '" & SQLEscape(PORCENTAJE) & "', '" & SQLEscape(PRORATEO) & "', '" & SQLEscape(Cadena) & "') "
                'Response.Write SQL
                'Response.End 
                Session("SQL") = SQL
    	        set rstrst = Server.CreateObject("ADODB.Recordset")
    	        rstrst.Open SQL, Connect(), 0, 1, 1 
    		        	        
            next
        end if
      next
    end if  'resultado del query de metodos de calculo
End sub

Function view_Metodos(mi_welclave, mi_choclave)
    Dim vm,array_metodos
    SQL = "SELECT WLMDESCRIPCION, NVL(WLMCUOTAMIN, 0), NVL(WLMCUOTAMAX, 0), WLC_IMPORTE " & vbCrLf
	SQL = SQL & " FROM WEB_LTL_METODOS " & vbCrLf
	SQL = SQL & "   , WEB_LTL_CONCEPTOS " & vbCrLf
	SQL = SQL & " WHERE WLMDESCRIPCION IS NOT NULL " & vbCrLf
	SQL = SQL & "   AND WLMSTATUS = 1 " & vbCrLf
	SQL = SQL & "   AND WLCSTATUS = 1 " & vbCrLf
	SQL = SQL & "   AND WLM_CHOCLAVE = " & mi_choclave & vbCrLf
	SQL = SQL & "   AND WLM_WELCLAVE = " & mi_welclave & vbCrLf
	SQL = SQL & "   AND WLC_WELCLAVE = WLM_WELCLAVE " & vbCrLf
	SQL = SQL & "   AND WLC_CHOCLAVE = WLM_CHOCLAVE " & vbCrLf
	SQL = SQL & " ORDER BY 1"
    array_metodos = GetArrayRS(SQL)
    if IsArray(array_metodos) then
        For vm = 0 to Ubound(array_metodos, 2)
            if CDbl(array_metodos(1, vm)) = CDbl(array_metodos(3, vm)) then 'WLMCUOTAMIN
                view_Metodos = "Importe minimo: $" & Num_Format(array_metodos(1, vm))
                exit function
            end if
            if CDbl(array_metodos(2, vm)) = CDbl(array_metodos(3, vm)) then 'WLMCUOTAMAX
                view_Metodos = "Importe maximo: $" & Num_Format(array_metodos(2, vm))
                exit function
            end if
            if view_Metodos <> "" then
                view_Metodos = view_Metodos & vbCrLf
            end if
            view_Metodos = view_Metodos & array_metodos(0, vm)
        next
    end if
End Function


Function BinaryGetURL(URL)
  'Create an Http object, use any of the four objects
  Dim Http
'  Set Http = CreateObject("Microsoft.XMLHTTP")
'  Set Http = CreateObject("MSXML2.ServerXMLHTTP")
  Set Http = CreateObject("WinHttp.WinHttpRequest.5.1")
'  Set Http = CreateObject("WinHttp.WinHttpRequest")
  
  'Send request To URL
  Http.Open "GET", URL, False
  Http.Send
  'Get response data As a string
  BinaryGetURL = Http.ResponseBody
End Function

Function SaveBinaryData(FileName, ByteArray)
  Const adTypeBinary = 1
  Const adSaveCreateOverWrite = 2
  
  'Create Stream object
  Dim BinaryStream
  Set BinaryStream = CreateObject("ADODB.Stream")
  
  'Specify stream type - we want To save binary data.
  BinaryStream.Type = adTypeBinary
  
  'Open the stream And write binary data To the object
  BinaryStream.Open
  BinaryStream.Write ByteArray
  
  'Save binary data To disk
  BinaryStream.SaveToFile FileName, adSaveCreateOverWrite
End Function


Function Format_Size(Octet_Size)
'format el tamano de un archivo
    Dim n
    Dim Suffix
    Octet_Size = CLng(Octet_Size) 
    n = 0
    While CLng(Octet_Size) > 1024
        Octet_Size = Round(Octet_Size / 1024, 2)
        n = n + 1
    Wend
    
    Select Case n
        Case 0
            Suffix = "B"
        Case 1
            Suffix = "KB"
        Case 2
            Suffix = "MB"
        Case 3
            Suffix = "GB"
        Case 4
            Suffix = "TB"
        Case Else
            Suffix = "Trop long !!!"
    End Select
    
    Format_Size = CStr(Octet_Size) & " " & Suffix

End Function

Function cliente_habilidatado_doc(mi_cliclef)
    Dim array_habil
	SQL = " SELECT COUNT(0) " & VbCrlf
    SQL = SQL & "  FROM ECLIENT " & VbCrlf
    SQL = SQL & "    , ECLIENT_MODALIDADES  " & VbCrlf
    SQL = SQL & "  WHERE CLICLEF = " & mi_cliclef & vbCrLf
    SQL = SQL & "  AND CLM_CLICLEF(+) = CLICLEF " & VbCrlf
    SQL = SQL & "  AND (CLISTATUS = 1 " & VbCrlf
    SQL = SQL & "  	   OR  " & VbCrlf
    SQL = SQL & " 	  NVL(CLM_MOECLAVE, 0) = 21  " & VbCrlf
    SQL = SQL & " 	 ) "
    array_habil = GetArrayRS(SQL)
    'Response.Write array_habil(0,0) & "tttt"
    if CInt(array_habil(0,0)) > 0 then
        cliente_habilidatado_doc = false
    else
        cliente_habilidatado_doc = true
    end if
End Function

Function get_lada_cedis()
	Dim SQL, array_lada, consecutivo
	if CDbl(Session("array_client")(2,0)) < 999000 then
		exit function
	end if
	consecutivo = CDbl(Session("array_client")(2,0)) - 999000

	SQL = "SELECT GET_LADA(DIETELEPHONE) " & vbCrLf
	SQL = SQL & " FROM EDIRECCIONES_ENTREGA " & vbCrLf
	SQL = SQL & " WHERE DIE_CCLCLAVE = 0 " & vbCrLf
	SQL = SQL & " AND DIECONSECUTIVO = " & consecutivo
	array_lada = GetArrayRS(SQL)
	if IsArray(array_lada) then
		get_lada_cedis = array_lada(0, 0)
	end if
End Function

Function track_SQL(id, id_sql, sql_track, dump)
    Dim SQL_T, array_track, rst_t
    if dump <> "1" then
        Exit Function
    end if
    Set rst_t = Server.CreateObject("ADODB.Recordset")
	
    
    SQL_T = "INSERT INTO WEB_SQL_TRACK ( " & VbCrlf
    SQL_T = SQL_T & "    WSTCLAVE, WSTID, WSTID_SQL,  " & VbCrlf
    SQL_T = SQL_T & "    WSTSQL, WSTFECHA, WSTIP)  " & VbCrlf
    SQL_T = SQL_T & " VALUES ( SEQ_WSTCLAVE.nextval, "& id &", '"& SQLEscape(id_sql) &"', " & VbCrlf
    SQL_T = SQL_T & "    '"& Mid(SQLEscape(sql_track), 1, 4000) &"' , SYSDATE, '"& SQLEscape(request.serverVariables("REMOTE_ADDR")) &"') "
    rst_t.Open SQL_T, Connect(), 0, 1, 1	
    Set rst_t = nothing
End Function

function xsltransform(xmlfile,xslfile,strOptionalParam1,strOptionalParam2)
	dim objXML
	dim objXSL
	dim templates
	dim transformer
	
	'create two document instances
	Set objXML = Server.CreateObject("MSXML2.FreeThreadedDOMDocument.6.0")
	objXML.async = false

	Set objXSL = Server.CreateObject("MSXML2.FreeThreadedDOMDocument.6.0")
	objXSL.async = false

	'set the parser properties
	objXML.ValidateOnParse = True
	objXSL.ValidateOnParse = True

	'load the source XML document and check for errors
	'objXML.load Server.MapPath(".") & "/" & xmlfile
    
	'load the XSL stylesheet and check for errors
	if IP_interna=false then
		objXSL.load(Server.MapPath(xslfile))
	else
		objXSL.load Server.MapPath(".") & "/" & xslfile
	end if
	if objXSL.parseError.errorCode <> 0 Then
  		'error found so  stop
		response.write objXSL.parseError.reason & "<br>"
		response.write "Error with transform: XSL file"
 		response.end
	end if

    objXML.setProperty "ServerHTTPRequest", true
	if IP_interna=false then
		objXML.load "http://192.168.100.4"  & xmlfile
	else
		objXML.load "http://" & Request.ServerVariables("HTTP_HOST") & xmlfile
	end if
	if objXML.parseError.errorCode <> 0 Then
 		'error found so  stop
		response.write objXML.parseError.reason & "<br>"
  		response.write "Error with transform: XML file"
 		response.end
	end if

	'all must be OK, so perform transformation

	Set templates = Server.CreateObject("Msxml2.XSLTemplate.6.0")
	templates.stylesheet = ObjXSL
	Set transformer = templates.createProcessor()
	if len(strOptionalparam1) then
		transformer.addParameter "param1", strOptionalParam1 
	end if
	if len(strOptionalparam2) then
		transformer.addParameter "param2", strOptionalParam2 
	end if
	transformer.input = objXML
	transformer.transform()
	xsltransform = transformer.output
end function

public function SaveFileFromUrl(Url, FileName)
    dim objXMLHTTP, objADOStream, objFSO

    Set objXMLHTTP = CreateObject("MSXML2.ServerXMLHTTP")

    objXMLHTTP.open "GET", Url, false
    objXMLHTTP.send()

    If objXMLHTTP.Status = 200 Then 
        Set objADOStream = CreateObject("ADODB.Stream")
        objADOStream.Open
        objADOStream.Type = 1 'adTypeBinary

        objADOStream.Write objXMLHTTP.ResponseBody
        objADOStream.Position = 0 'Set the stream position to the start

        Set objFSO = Createobject("Scripting.FileSystemObject")
        If objFSO.Fileexists(FileName) Then objFSO.DeleteFile FileName
        Set objFSO = Nothing

        objADOStream.SaveToFile FileName
        objADOStream.Close
        Set objADOStream = Nothing

        SaveFileFromUrl = objXMLHTTP.getResponseHeader("Content-Type")
    else
        SaveFileFromUrl = ""
    End if

    Set objXMLHTTP = Nothing
end function


function Get_Ced_IP 
	Dim SQL, array_ced

	if Left(Request.ServerVariables("REMOTE_ADDR"),7) = "192.168" And _
	    Request.ServerVariables("REMOTE_ADDR") <> "192.168.100.1" then
		SQL = " SELECT ETIP_ALLCLAVE FROM ETERMINAL_IP WHERE '" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "' LIKE ETIPCLAVE ||'.' || '%' "
		array_ced = GetArrayRS(SQL)
		if IsArray(array_ced) then
			if array_ced(0, 0) = "40" then
				Get_Ced_IP = "(1, 40)"
			elseif array_ced(0, 0) = "24" then
				Get_Ced_IP = "(2, 24)"
			elseif array_ced(0, 0) = "51" or array_ced(0, 0) = "10" then
				Get_Ced_IP = "(10, 51)"
			else
				Get_Ced_IP = "(" & array_ced(0, 0) & ")"
			end if
		else
			Get_Ced_IP = ""
		end if
	else
		Get_Ced_IP = ""
	end if
end function

function xsltransform_tmp(xmlfile,xslfile,strOptionalParam1,strOptionalParam2)
	
		dim objXML
	dim objXSL
	dim templates
	dim transformer

	'create two document instances
	Set objXML = Server.CreateObject("MSXML2.FreeThreadedDOMDocument.6.0")
	objXML.async = false

	Set objXSL = Server.CreateObject("MSXML2.FreeThreadedDOMDocument.6.0")
	objXSL.async = false	

	'set the parser properties
	objXML.ValidateOnParse = True
	objXSL.ValidateOnParse = True
	
	objXSL.load(Server.MapPath(xslfile))

    ' response.write(objXSL.parseError.errorCode)

	if objXSL.parseError.errorCode <> 0 Then
 ' 		'error found so  stop
		response.write objXSL.parseError.reason & "<br>"
		response.write "Error with transform: XSL file"
 		response.end
	end if
    objXML.setProperty "ServerHTTPRequest", true
	objXML.load "http://192.168.100.4"  & xmlfile

	if objXML.parseError.errorCode <> 0 Then
 		'error found so  stop
		response.write objXML.parseError.reason & "<br>"
  		response.write "Error with transform: XML file"
 		response.end
	end if

	'all must be OK, so perform transformation

	Set templates = Server.CreateObject("Msxml2.XSLTemplate.6.0")
	templates.stylesheet = ObjXSL
	Set transformer = templates.createProcessor()
	if len(strOptionalparam1) then
		transformer.addParameter "param1", strOptionalParam1 
	end if
	if len(strOptionalparam2) then
		transformer.addParameter "param2", strOptionalParam2 
	end if
	transformer.input = objXML
	transformer.transform()
	xsltransform_tmp = transformer.output
end function


public function Modalidad(Cliente,NumMod)
Modalidad = False
'verificar si el cliente documenta tarimas Logis
'esas tarimas pueden no tener la misma cantidad de detalle de bultos que el encabezado.
SQL = "SELECT COUNT(0) " & vbCrLf
SQL = SQL & " FROM ECLIENT_MODALIDADES " & vbCrLf
SQL = SQL & " WHERE CLM_CLICLEF = " & Cliente
SQL = SQL & " AND CLM_MOECLAVE = " & NumMod
array_tmp = GetArrayRS(SQL)
if IsArray(array_tmp)  then
	if array_tmp(0,0) > "0" then
		Modalidad = True
	end if
end if
end function

public function ModalidadVal_Acep(Cliente,NumMod)
Dim array_tmp
ModalidadVal_Acep = "0"
'verifica el peso maximo de un bulto de un cliente 
SQL = " SELECT DMOVALOR_ACEPTABLE " & vbCrLf
SQL = SQL & " FROM ECLIENT_MODALIDADES CLM " & vbCrLf
SQL = SQL & " ,EDETCLIENT_MODALIDADES DMO " & vbCrLf 
SQL = SQL & " WHERE CLM.CLMCLAVE=DMO.DMO_CLMCLAVE " & vbCrLf
SQL = SQL & " AND   CLM.CLM_CLICLEF = " & Cliente
SQL = SQL & " AND CLM.CLM_MOECLAVE = " & NumMod
array_tmp = GetArrayRS(SQL)
if IsArray(array_tmp)  then
	if array_tmp(0,0) > "0" then
		ModalidadVal_Acep = array_tmp(0,0)
	end if
end if
end function

public function Print_Perfil_usr(Pas,Perfil)
'PERFIL DE USUARIO
'Oscar 22Ene2014
Dim array_tmp
Print_Perfil_usr = "N"
SQL = " SELECT COUNT(0)  " & VbCrlf 
SQL = SQL & " FROM USUARIOS  " & VbCrlf
SQL = SQL & " WHERE UPPER(DSUSUARIO) = UPPER('"& Pas &"') " & VbCrlf 
SQL = SQL & " AND logis.usuario_con_perfil('"& Perfil &"', CDUSUARIO) = 'S' "
array_tmp = GetArrayRS(SQL)
if array_tmp(0,0) > "0" then
	Print_Perfil_usr = "S"
end if
end function

Function cliente_cancelado(mi_cliclef)
    Dim array_can
	SQL = " SELECT COUNT(0) " & VbCrlf
    SQL = SQL & "  FROM ECLIENT " & VbCrlf
    SQL = SQL & "  WHERE CLICLEF = " & mi_cliclef & vbCrLf
    SQL = SQL & "  AND clistatus = 1 " & VbCrlf
    array_can = GetArrayRS(SQL)
    if CInt(array_can(0,0)) > 0 then
        cliente_cancelado = true
    else
        cliente_cancelado = false
    end if
End Function

Function cliente_bloqueado(mi_cliclef)
    Dim array_habil
	SQL = " SELECT COUNT(0) " & VbCrlf
    SQL = SQL & "  FROM ECLIENT " & VbCrlf
    SQL = SQL & "    , ECLIENT_MODALIDADES  " & VbCrlf
    SQL = SQL & "  WHERE CLICLEF = " & mi_cliclef & vbCrLf
    SQL = SQL & "  AND CLM_CLICLEF(+) = CLICLEF " & VbCrlf
    SQL = SQL & "  AND (CLISTATUS <>1 " & VbCrlf
    SQL = SQL & "  	   AND  " & VbCrlf
    SQL = SQL & " 	  NVL(CLM_MOECLAVE, 0) = 21  " & VbCrlf
    SQL = SQL & " 	 ) "
    array_habil = GetArrayRS(SQL)
    if CInt(array_habil(0,0)) > 0 then
        cliente_bloqueado = true
    else
        cliente_bloqueado = false
    end if
End Function	

function IP_interna_Pruebas 
	if Request.ServerVariables("REMOTE_ADDR") = "192.168.0.104" then
		IP_interna_Pruebas  = true
	else
		IP_interna_Pruebas  = false
	end if
end function	

'<CHG-DESA-28032022-01: Nuevas funciones para el estatus de la carga:
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
''' Funci�n para obligar a mantener el consecutivo de acuerdo al n�mero de tal�n en un LTL  '''
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
function valida_ltl_consecutivo(numLTL, wel_cliclef)
	Dim consecutivoSiguiente, consecutivoNuevo
	Dim mi_welclave, mi_cliclef, mi_welCons
	Dim SQL, array_tmp, actualizar, rst

    consecutivoSiguiente = 1
    consecutivoNuevo = 1000
	actualizar = false
	mi_welclave = ""
	mi_welCons = ""
		
	'********************************************************************************************
	'*	Para las cuentas de Helvex, se estableci� que los consecutivos deber�n					*
	'*	respetarse de acuerdo a los que se registraron en el tal�n al momento de reservarlos.	*
	'********************************************************************************************
	if wel_cliclef = 19808 or wel_cliclef = 22512 then
		'Obtengo el NUI, Cliente y Consecutivo de acuerdo al tal�n:
		SQL = "SELECT WELCLAVE, WEL_CLICLEF,SUBSTR(WEL_TALON_RASTREO,0,7) "	&	VbCrlf
		SQL = SQL & "FROM WEB_LTL "	&	VbCrlf
		SQL = SQL & "WHERE WELCLAVE = '" & numLTL & "' "	&	VbCrlf
        SQL = SQL & "   AND WELSTATUS = 3 "	&	VbCrlf
		Session("SQL") = SQL
			
		array_tmp = GetArrayRS(SQL)
		if IsArray(array_tmp) then
			mi_welclave = array_tmp(0,0)
            mi_cliclef = array_tmp(1,0)
			mi_welCons = array_tmp(2,0)
		end if

		if mi_welCons <> "" and mi_welclave <> "" and mi_cliclef <> "" then
			'Validar que el consecutivo est� disponible:
			SQL = "SELECT WELCLAVE, WEL_CLICLEF, WELCONS_GENERAL, SUBSTR(WEL_TALON_RASTREO,0,7), WELFACTURA, WELSTATUS "	&	VbCrlf
			SQL = SQL & "FROM WEB_LTL "	&	VbCrlf
			SQL = SQL & "WHERE WEL_CLICLEF = " & mi_cliclef & " "	&	VbCrlf
			SQL = SQL & " AND WELCONS_GENERAL = " & mi_welCons & " "	&	VbCrlf
			Session("SQL") = SQL
			
			array_tmp = GetArrayRS(SQL)
			if IsArray(array_tmp) then
				'Si est� siendo utilizado, se valida que no corresponda al NUI con el que se est� trabajando:
'				Session("SQL") = array_tmp(0,0) & " " & mi_welclave
				if CStr(array_tmp(0,0)) <> "-1" then
					if Cstr(array_tmp(0,0)) <> Cstr(mi_welclave) then
						'Si el consecutivo no est� disponible, se debe consultar si est� siendo utilizado por un reservado:
						if array_tmp(4,0) = "RESERVADO" and array_tmp(5,0) = "3" then
							'Si el consecutivo est� siendo utilizado por un reservado, se libera para ajustar el registro actual:
							SQL = "UPDATE WEB_LTL SET " & vbCrLf
							SQL = SQL & "   WELCONS_GENERAL = (SELECT MAX(NVL(WELCONS_GENERAL,0))+1 FROM WEB_LTL WHERE WEL_CLICLEF = " & array_tmp(1,0) & ") " & vbCrLf
							SQL = SQL & " WHERE WELCLAVE = " & array_tmp(0,0)
							Session("SQL") = SQL
				
							set rst = Server.CreateObject("ADODB.Recordset")
							rst.Open SQL, Connect(), 0, 1, 1
							
							'Una vez liberado el consecutivo, se puede actualizar al que trae la gu�a:
							actualizar = true
						else
							'Si el consecutivo est� en un NUI documentado, se mentendr� el que tiene la gu�a actual
							'para evistar que el desfase se siga acumulando:
							actualizar = false
						end if
					else
						'Si NUI que se est� validando coincide con el que trae la consulta no es necesario actualizar:
						actualizar = false
					end if
				end if
			else
				'Si est� disponible, se actualiza el consecutivo que corresponde:
				actualizar = true
			end if
        end If

		if actualizar = true then
			SQL = "UPDATE WEB_LTL SET " & vbCrLf
			SQL = SQL & "   WELCONS_GENERAL = " & mi_welCons & " " & vbCrLf
			SQL = SQL & " WHERE WELCLAVE = " & mi_welclave
			Session("SQL") = SQL
			
			set rst = Server.CreateObject("ADODB.Recordset")
			rst.Open SQL, Connect(), 0, 1, 1
		end if
	else
		'************************************************************************************
		'*	Para el resto de las cuentas, por el momento se mantendr� el proceso actual		*
		'*	para que no afecte la operaci�n.												*
		'************************************************************************************
        consecutivoSiguiente = 1
        consecutivoNuevo = 1000
		
        'Consecutivo al que se va a actualizar:
        SQL = " SELECT NVL(MAX(WELCONS_GENERAL),0)+1 FROM WEB_LTL WHERE WELFACTURA <> 'RESERVADO' AND WELFACTURA <> 'RESERVADO - CANCELADO ' AND WELOBSERVACION <> 'RESERVADO' AND WELSTATUS <> 3 AND WEL_CLICLEF = " & wel_cliclef & ""	&	VbCrlf
        Session("SQL") = SQL

        array_tmp = GetArrayRS(SQL)
        if IsArray(array_tmp) then
            consecutivoSiguiente = array_tmp(0,0)
        end if

        if consecutivoSiguiente <> "0" then
            valida_ltl_consecutivo = consecutivoSiguiente
			
			'Buscar si existe para el cliente:
            SQL = " SELECT WELCONS_GENERAL FROM WEB_LTL WHERE WEL_CLICLEF = " & wel_cliclef & " AND WELCONS_GENERAL = " & consecutivoSiguiente &	VbCrlf
            Session("SQL") = SQL
			
            array_tmp = GetArrayRS(SQL)
            if IsArray(array_tmp) then
                'Si existe la combinaci�n Cliente-Consecutivo, se actualiza el consecutivo actual para evitar errores de restricci�n TSC.UK_WEL_CLI_CONS:
                SQL = "UPDATE WEB_LTL SET WELCONS_GENERAL = (SELECT MAX(WELCONS_GENERAL)+1 FROM WEB_LTL WHERE WEL_CLICLEF = " & wel_cliclef & ") WHERE WEL_CLICLEF = " & wel_cliclef & " AND WELCONS_GENERAL = " & consecutivoSiguiente	&	VbCrlf
                Session("SQL") = SQL

                set rst = Server.CreateObject("ADODB.Recordset")
                rst.Open SQL, Connect(), 0, 1, 1
            end if
        end if
	end if

	set rst = nothing
	
	valida_ltl_consecutivo = consecutivoSiguiente
end function


' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
''' Funci�n para obligar a mantener el consecutivo de acuerdo al n�mero de tal�n en un LTL  '''
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
function valida_ltl_consecutivo(numLTL, wel_cliclef)
	Dim consecutivoSiguiente, consecutivoNuevo
	Dim mi_welclave, mi_cliclef, mi_welCons
	Dim SQL, array_tmp, actualizar, rst

    consecutivoSiguiente = 1
    consecutivoNuevo = 1000
	actualizar = false
	mi_welclave = ""
	mi_welCons = ""

		
	'********************************************************************************************
	'*	Para las cuentas de Helvex, se estableci� que los consecutivos deber�n					*
	'*	respetarse de acuerdo a los que se registraron en el tal�n al momento de reservarlos.	*
	'********************************************************************************************
	if wel_cliclef = 19808 or wel_cliclef = 22512 then
		'Obtengo el NUI, Cliente y Consecutivo de acuerdo al tal�n:
		SQL = "SELECT WELCLAVE, WEL_CLICLEF,SUBSTR(WEL_TALON_RASTREO,0,7) "	&	VbCrlf
		SQL = SQL & "FROM WEB_LTL "	&	VbCrlf
		SQL = SQL & "WHERE WELCLAVE = '" & numLTL & "' "	&	VbCrlf
        SQL = SQL & "   AND WELSTATUS = 3 "	&	VbCrlf
		Session("SQL") = SQL
			
		array_tmp = GetArrayRS(SQL)
		if IsArray(array_tmp) then
			mi_welclave = array_tmp(0,0)
            mi_cliclef = array_tmp(1,0)
			mi_welCons = array_tmp(2,0)
		end if

		if mi_welCons <> "" and mi_welclave <> "" and mi_cliclef <> "" then
			'Validar que el consecutivo est� disponible:
			SQL = "SELECT WELCLAVE, WEL_CLICLEF, WELCONS_GENERAL, SUBSTR(WEL_TALON_RASTREO,0,7), WELFACTURA, WELSTATUS "	&	VbCrlf
			SQL = SQL & "FROM WEB_LTL "	&	VbCrlf
			SQL = SQL & "WHERE WEL_CLICLEF = " & mi_cliclef & " "	&	VbCrlf
			SQL = SQL & " AND WELCONS_GENERAL = " & mi_welCons & " "	&	VbCrlf
			Session("SQL") = SQL
			
			array_tmp = GetArrayRS(SQL)
			if IsArray(array_tmp) then
				'Si est� siendo utilizado, se valida que no corresponda al NUI con el que se est� trabajando:
'				Session("SQL") = array_tmp(0,0) & " " & mi_welclave
				if CStr(array_tmp(0,0)) <> "-1" then
					if Cstr(array_tmp(0,0)) <> Cstr(mi_welclave) then
						'Si el consecutivo no est� disponible, se debe consultar si est� siendo utilizado por un reservado:
						if array_tmp(4,0) = "RESERVADO" and array_tmp(5,0) = "3" then
							'Si el consecutivo est� siendo utilizado por un reservado, se libera para ajustar el registro actual:
							SQL = "UPDATE WEB_LTL SET " & vbCrLf
							SQL = SQL & "   WELCONS_GENERAL = (SELECT MAX(NVL(WELCONS_GENERAL,0))+1 FROM WEB_LTL WHERE WEL_CLICLEF = " & array_tmp(1,0) & ") " & vbCrLf
							SQL = SQL & " WHERE WELCLAVE = " & array_tmp(0,0)
							Session("SQL") = SQL
				
							set rst = Server.CreateObject("ADODB.Recordset")
							rst.Open SQL, Connect(), 0, 1, 1
							
							'Una vez liberado el consecutivo, se puede actualizar al que trae la gu�a:
							actualizar = true
						else
							'Si el consecutivo est� en un NUI documentado, se mentendr� el que tiene la gu�a actual
							'para evistar que el desfase se siga acumulando:
							actualizar = false
						end if
					else
						'Si NUI que se est� validando coincide con el que trae la consulta no es necesario actualizar:
						actualizar = false
					end if
				end if
			else
				'Si est� disponible, se actualiza el consecutivo que corresponde:
				actualizar = true
			end if
        end If

		if actualizar = true then
			SQL = "UPDATE WEB_LTL SET " & vbCrLf
			SQL = SQL & "   WELCONS_GENERAL = " & mi_welCons & " " & vbCrLf
			SQL = SQL & " WHERE WELCLAVE = " & mi_welclave
			Session("SQL") = SQL
			
			set rst = Server.CreateObject("ADODB.Recordset")
			rst.Open SQL, Connect(), 0, 1, 1
		end if
	else
		'************************************************************************************
		'*	Para el resto de las cuentas, por el momento se mantendr� el proceso actual		*
		'*	para que no afecte la operaci�n.												*
		'************************************************************************************
        consecutivoSiguiente = 1
        consecutivoNuevo = 1000
		
        'Consecutivo al que se va a actualizar:
        SQL = " SELECT NVL(MAX(WELCONS_GENERAL),0)+1 FROM WEB_LTL WHERE WELFACTURA <> 'RESERVADO' AND WELFACTURA <> 'RESERVADO - CANCELADO ' AND WELOBSERVACION <> 'RESERVADO' AND WELSTATUS <> 3 AND WEL_CLICLEF = " & wel_cliclef & ""	&	VbCrlf
        Session("SQL") = SQL

        array_tmp = GetArrayRS(SQL)
        if IsArray(array_tmp) then
            consecutivoSiguiente = array_tmp(0,0)
        end if

        if consecutivoSiguiente <> "0" then
            valida_ltl_consecutivo = consecutivoSiguiente
			
			'Buscar si existe para el cliente:
            SQL = " SELECT WELCONS_GENERAL FROM WEB_LTL WHERE WEL_CLICLEF = " & wel_cliclef & " AND WELCONS_GENERAL = " & consecutivoSiguiente &	VbCrlf
            Session("SQL") = SQL
			
            array_tmp = GetArrayRS(SQL)
            if IsArray(array_tmp) then
                'Si existe la combinaci�n Cliente-Consecutivo, se actualiza el consecutivo actual para evitar errores de restricci�n TSC.UK_WEL_CLI_CONS:
                SQL = "UPDATE WEB_LTL SET WELCONS_GENERAL = (SELECT MAX(WELCONS_GENERAL)+1 FROM WEB_LTL WHERE WEL_CLICLEF = " & wel_cliclef & ") WHERE WEL_CLICLEF = " & wel_cliclef & " AND WELCONS_GENERAL = " & consecutivoSiguiente	&	VbCrlf
                Session("SQL") = SQL

                set rst = Server.CreateObject("ADODB.Recordset")
                rst.Open SQL, Connect(), 0, 1, 1
            end if
        end if
	end if

	set rst = nothing
	
	valida_ltl_consecutivo = consecutivoSiguiente
end function

' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
''' Funci�n para obtener el estatus a partir del seguimiento que se le da a un tal�n LTL	'''
' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
function obtieneStatusTalon(wTalonRastreo)
	Dim ObtieneInfoBDs
	Dim arrResult, i, j, k
	Dim EstatusTalon,TdcdClave, sNUI, idStatus
	Dim SQL, arrInfoTalon, arrTracking, catEstatus, cveStatus
	Dim stClase, stTexto, stStatus, stObservaciones, sTxtCatalogo

	'Variables utilizadas para interpretar el estatus:
	Dim incidencia, fecha_entrega, last_entrada
	Dim tieneVAS, statusCancelado, statusStandby

	i = 0
	j = 0
	k = 0
	
	idStatus = -1
	incidencia = -1
	cveStatus = "-"
	fecha_entrega = ""
	stClase = "amarillo"
	stTexto = "Documentado"
	ObtieneInfoBDs = false
	sTxtCatalogo = "Documentado"
	tieneVAS = false
	statusStandby = false
	statusCancelado = false
	
	statusCancelado = EsGuiaCancelada(wTalonRastreo)
	statusStandby = GuiaEnStndBy(wTalonRastreo)
	
	if statusCancelado = true then
		stClase = "rojo"
		stTexto = "Cancelado"
		stObservaciones = "Guia cancelada"
		cveStatus = "0"
		stStatus = "0"
		EstatusTalon = "<td cveStatus='" & cveStatus & "' sStatus='" & stStatus & "' class='" & stClase & "' style='text-align:center;'>" & stTexto & "</td>"
	elseif statusStandby = true then
		stClase = "naranja"
		stTexto = "StdBy"
		stObservaciones = "Guia en Stand By"
		cveStatus = "2"
		stStatus = "2"
		EstatusTalon = "<td cveStatus='" & cveStatus & "' sStatus='" & stStatus & "' class='" & stClase & "' style='text-align:center;'>" & stTexto & "</td>"
	else
		stClase = "amarillo " & wTalonRastreo
		catEstatus = ObtenerCatalogoEstatus()
		arrInfoTalon = ObtenerInfoTalon(wTalonRastreo)

		if IsArray(arrInfoTalon) then
			stStatus = arrInfoTalon(14,0)
			TdcdClave = arrInfoTalon(15,0)
			sNUI = arrInfoTalon(15,0)
			cveStatus = arrInfoTalon(14,0)
			stTexto = "Creacion de la " & arrInfoTalon(16, 0)
		
	'		for i = 0 to UBound(arrInfoTalon, 2)
	'			response.Write "<br>"
	'			for j = 0 to 21
	'				response.Write " | " & j & " -> " & arrInfoTalon(j,i)
	'			next
	'		next
	'	response.End

			if TdcdClave <> "" then
				arrTracking = ObtenerTrackingTalon(TdcdClave)
			end if
			
			if IsArray(arrTracking) then
				incidencia = arrTracking(9, 0)
				fecha_entrega = NVL(arrTracking(6, 0))
				last_entrada = arrTracking(8, 0)
				ObtieneInfoBDs = true

				'================================================================='
				'Obtiene los par�metros: incidencia, fecha_entrega y last_entrada.'
				'================================================================='
				for i = 0 to UBound(arrTracking, 2)
					if NVL(arrTracking(3, i)) = "DIRECTO" _
						and (arrTracking(10, i) = "N" or (arrTracking(10, i) = "S" and arrTracking(9, i) = "4")) _ 
						and  arrTracking(9, i) <> "5" then 'no recuperar las reexpediciones o los VAS
							incidencia = arrTracking(9, i)
							fecha_entrega = NVL(arrTracking(6, i))
					else
						if arrTracking(9, i) = "5" then
							if i = UBound(arrTracking, 2) - 1 then
								incidencia = arrTracking(9, i)
								fecha_entrega = ""
							end if
						end if
					end if
					last_entrada = arrTracking(8, i)
					
					if arrTracking(11,i) = "VAS" and arrTracking(9,i) <> "0" then
						tieneVAS = true
					else
						tieneVAS = false
					end if
				next

				'Datos iniciales:
				stClase = "rojo"
				stTexto = "Creado"
			end if

			'==========================='
			'Interpretaci�n del estatus.'
			'==========================='
			select case incidencia
				case "0"
					if fecha_entrega <> "" then
						'entrega normal, no pasa nada
						stClase = "verde"
						stTexto = "Entregado"
					else
						stClase = "naranja"
						stTexto = "En transito"
					end if
				case "4"
	'				if fecha_entrega <> "" then
	'					stClase = "rojo-claro"
	'					stTexto = "Intento de entrega fallido"
	'					stClase = "verde"
	'					stTexto = "Entregado"
	'				else
						stClase = "rojo"
						stTexto = "No entregado"
	'				end if
				case "3"
					stClase = "rojo"
					stTexto = "Entrega incompleta"
				case else
					if last_entrada <> "24" then
						'no hubo entrada de rechazo todavia entonces el status esta en transito borramos la fecha de entrega:
						fecha_entrega = ""
	'					stClase = "naranja"
	'					stTexto = "En transito"
					else
						stClase = "rojo"
						stTexto = "Rechazado"
					end if
			end select
			if tieneVAS = true then
				stClase = "rojo-claro"
				stTexto = "No   entregado (Intento de entrega fallido)"
			end if
		else
			dim arrNvoStatus
			arrNvoStatus = ObtenerEstatusSinDocumentar(wTalonRastreo)
			
			if not isarray(arrNvoStatus) then
				arrNvoStatus = ObtenerEstatusSinDocumentarCD(wTalonRastreo)
			end if
			
			if IsArray(arrNvoStatus) then
				cveStatus = arrNvoStatus(0,0)
				if arrNvoStatus(0,0) = "0" then
					if arrNvoStatus(1,0) = "RESERVADO - CANCELADO " then
						stClase = "rojo-claro"
						stTexto = "Reservado - Cancelado"
					else
						stClase = "rojo"
						stTexto = "Cancelado"
					end if
				else 
					if arrNvoStatus(0,0) = "3" then
						stClase = "gris"
						stTexto = "Reservado"
					end if
				end if
			end if
		end if

		'Si la gu�a tiene incidencia, se mantiene el estatus de la incidencia, si tiene fecha de entrega tambi�n se mantiene, de lo contrario se procesa el nuevo estatus:
		if incidencia <> "3" and incidencia <> "4" and CStr(fecha_entrega) = "" then
			''' =========================================== '''
			'''  Nuevo proceso para interpretar el estatus  '''
			''' =========================================== '''
			' 1.- Obtener informaci�n del tal�n;
			' 2.- Replicar el proceso de la pantalla Tracking;
			' 3.- Ajustar los estatus de acuerdo a las reglas que est�n en el excel (8 eventos);
			' 4.- Aplicar las reglas de los colores que se van a mostrar en la pantalla;
			' NOTA: todo se debe basar en el texto que est� en los registros de seguimiento que se encuentra en la BD's.

			stObservaciones = ""

			if isArray(arrTracking) then
				stObservaciones = arrTracking(2,0)
			end if

			if isArray(arrTracking) then
				for i = 0 to UBound(arrTracking,2)
					for j = 0 to UBound(arrTracking)
						if j = 2 or j = 5 then
							for k = 0 to UBound(catEstatus, 2)
								if InStr(UCase(arrTracking(j,i)),UCase(catEstatus(2,k))) > 0 then
									'idStatus = catEstatus(0,k)
									idStatus = k
								end if
							next
						end if
					next
				next

				if idStatus <> -1 then
					stTexto = catEstatus(1,idStatus)
					stClase = catEstatus(3,idStatus)
					sTxtCatalogo = catEstatus(2,idStatus)
				end if
			end if
		end if

		if stStatus = "0" then
			stClase = "rojo"
			stTexto = "Cancelado"
		else
			if stStatus = "3" then
				stClase = "gris"
				stTexto = "Reservado"
			end if
		end if

		'	'	'	'	'	'	'	'	'	'	'	'	'	'	'	'	'	'	'
		'	Obtener informaci�n del cat�logo de acuerdo al estatus obtenido.	'
		'	'	'	'	'	'	'	'	'	'	'	'	'	'	'	'	'	'	'
		for k = 0 to UBound(catEstatus, 2)
			if InStr(UCase(stTexto),UCase(catEstatus(2,k))) > 0 then
				stTexto = catEstatus(1,k)
				stClase = catEstatus(3,k)
				sTxtCatalogo = catEstatus(2,k)
			end if
		next
	end if


	
	''	''	''	''	''	''	''	''	''
	'' PRESENTACI�N DE RESULTADOS	''
	''	''	''	''	''	''	''	''	''
	redim arrResult(5)
	EstatusTalon = "<td cveStatus='" & cveStatus & "' sStatus='" & stStatus & "' class='" & stClase & "' style='text-align:center;'>" & stTexto & "</td>"

	arrResult(0) = stClase
	arrResult(1) = stTexto
	arrResult(2) = EstatusTalon
	arrResult(3) = true
	arrResult(4) = stObservaciones
	arrResult(5) = cveStatus

	if wTalonRastreo = "" then
		arrResult = null
	end if

	obtieneStatusTalon = arrResult
end function


function ObtenerCatalogoEstatus()
	Dim SQL, arrInfo

	SQL = " SELECT 1 AS No_Evento,	'Creado' AS Estatus,	'Creacion de la' AS Observaciones,	'amarillo' AS Clase FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 2,'En Recoleccion','Recolecci�n','naranja' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 3,'En Transito','Entrada CEDIS Logis','naranja' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 4,'En Transito','Expedici�n','naranja' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 5,'En Transito a destino final','Expedici�n directa al cliente','naranja' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 6,'Entregado','Entrega al Cliente','verde' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
'	SQL = SQL & " SELECT 7,'Entregado con incidencia','Entrega incompleta','rojo' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " SELECT 7,'Intento de entrega fallido','Entrega incompleta','rojo' FROM DUAL	"	&	VbCrlf
	'SQL = SQL & " SELECT 7,'Intento de entrega fallido - No entregado','Intento de entrega fallido','rojo' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
'	SQL = SQL & " SELECT 8,'Entregado con incidencia','Entrega al cliente con incidencia','rojo' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " SELECT 8,'Intento de entrega fallido   (no   entregado)','Entrega al cliente con incidencia','rojo' FROM DUAL	"	&	VbCrlf
'	SQL = SQL & " SELECT 8,'Entregado','Entrega al cliente con incidencia','verde' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 9,'No entregado','No entregado','rojo' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 10,'Rechazado','Rechazado','rojo' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 11,'Cancelado','Cancelado','rojo' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 12,'Reservado','Reservado','gris' FROM DUAL	"	&	VbCrlf
	SQL = SQL & " UNION	"	&	VbCrlf
	SQL = SQL & " SELECT 13,'StandBy','StandBy','naranja' FROM DUAL	"	&	VbCrlf
	
	'response.Write replace(SQL,VbCrlf,"<br>")
	Session("SQL") = SQL
	arrInfo = GetArrayRS(SQL)

	ObtenerCatalogoEstatus = arrInfo
end function


function ObtenerInfoTalon(wTalonRastreo)
	Dim SQL, arrInfo

	SQL = " SELECT TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) || DECODE(WEL_ORI.WELCLAVE, NULL, NULL, ' (talon ori: ' || TO_CHAR(WEL_ORI.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL_ORI.WEL_CLICLEF) ||')') "	&	VbCrlf
	SQL = SQL & ", NVL(WEL.WEL_TALON_RASTREO, WEL.WEL_FIRMA) AS WEL_FIRMA "	&	VbCrlf
	SQL = SQL & ", TO_CHAR( WEL.DATE_CREATED, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", WEL.WELRECOL_DOMICILIO "	&	VbCrlf
	SQL = SQL & ", WEL.WELFACTURA "	&	VbCrlf
	SQL = SQL & ", WEL.WEL_CDAD_BULTOS "	&	VbCrlf
	SQL = SQL & ", INITCAP(DIS.DISNOM) REMITENTE "	&	VbCrlf
	SQL = SQL & ", InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  <br> ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DISCODEPOSTAL))  remitente_direc "	&	VbCrlf
	SQL = SQL & ", INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')') "	&	VbCrlf
	SQL = SQL & ", INITCAP(NVL(DIE2.DIE_A_ATENCION_DE, DIE2.DIENOMBRE)) "	&	VbCrlf
	SQL = SQL & ", InitCap( DIE2.DIEADRESSE1|| ' ' || ' ' || DIE2.DIENUMEXT || '  ' || DIE2.DIENUMINT || '  <br> ' ||DIE2.DIEADRESSE2 || DECODE(DIE2.DIECODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DIE2.DIECODEPOSTAL)) remitente_direc "	&	VbCrlf
	SQL = SQL & ", INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')') "	&	VbCrlf
	SQL = SQL & ", WEL.WELSTATUS "	&	VbCrlf
	SQL = SQL & ", WEL.WEL_TDCDCLAVE "	&	VbCrlf
	SQL = SQL & ", 'LTL' "	&	VbCrlf
	SQL = SQL & ", WEL.WEL_CLICLEF "	&	VbCrlf
	SQL = SQL & ", WEL.WELOBSERVACION "	&	VbCrlf
	SQL = SQL & ", WEL.WELPESO "	&	VbCrlf
	SQL = SQL & ", WEL.WELVOLUMEN "	&	VbCrlf
	SQL = SQL & ", WEL.WELCLAVE AS NUI "	&	VbCrlf
	SQL = SQL & "FROM WEB_LTL WEL "	&	VbCrlf
	SQL = SQL & " , EDIRECCIONES_ENTREGA DIE2 "	&	VbCrlf
	SQL = SQL & " , EDISTRIBUTEUR DIS "	&	VbCrlf
	SQL = SQL & " , ECIUDADES CIU_ORI "	&	VbCrlf
	SQL = SQL & " , EESTADOS EST_ORI "	&	VbCrlf
	SQL = SQL & " , ECIUDADES CIU_DEST "	&	VbCrlf
	SQL = SQL & " , EESTADOS EST_DEST "	&	VbCrlf
	SQL = SQL & " , ETRANS_DETALLE_CROSS_DOCK TDCD "	&	VbCrlf
	SQL = SQL & " , ETRANSFERENCIA_TRADING TRA "	&	VbCrlf
	SQL = SQL & " , ETRANS_ENTRADA TAE "	&	VbCrlf
	SQL = SQL & " , WEB_LTL WEL_ORI "	&	VbCrlf
	SQL = SQL & "WHERE (WEL.WEL_FIRMA IN ('" & wTalonRastreo & "') "	&	VbCrlf
	SQL = SQL & "	      OR WEL.WEL_TALON_RASTREO IN ('" & wTalonRastreo & "') "	&	VbCrlf
	SQL = SQL & "	     ) "	&	VbCrlf
	SQL = SQL & " AND DISCLEF = WEL.WEL_DISCLEF "	&	VbCrlf
	SQL = SQL & " AND DIE2.DIECLAVE = WEL.WEL_DIECLAVE "	&	VbCrlf
	SQL = SQL & " AND CIU_ORI.VILCLEF = DISVILLE "	&	VbCrlf
	SQL = SQL & " AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO "	&	VbCrlf
	SQL = SQL & " AND CIU_DEST.VILCLEF = DIE2.DIEVILLE "	&	VbCrlf
	SQL = SQL & " AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO "	&	VbCrlf
	SQL = SQL & " AND TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE "	&	VbCrlf
	SQL = SQL & " AND TDCDSTATUS (+) = '1' "	&	VbCrlf
	SQL = SQL & " AND TRACLAVE(+) = WEL.WEL_TRACLAVE "	&	VbCrlf
	SQL = SQL & " AND TRASTATUS (+) = '1' "	&	VbCrlf
	SQL = SQL & " AND TAE_TRACLAVE(+) = WEL.WEL_TRACLAVE "	&	VbCrlf
	SQL = SQL & " AND WEL_ORI.WELCLAVE(+) = WEL.WEL_WELCLAVE "	&	VbCrlf
	SQL = SQL & " AND TAE_TRACLAVE = TRACLAVE "	&	VbCrlf
	SQL = SQL & "UNION ALL "	&	VbCrlf
	SQL = SQL & "SELECT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) "	&	VbCrlf
	SQL = SQL & ", WCD.WCD_FIRMA "	&	VbCrlf
	SQL = SQL & ", TO_CHAR( WCD.DATE_CREATED, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", 'n/a' "	&	VbCrlf
	SQL = SQL & ", WCD.WCD_PEDIDO_CLIENTE "	&	VbCrlf
	SQL = SQL & ", WCD.WCD_CDAD_BULTOS "	&	VbCrlf
	SQL = SQL & ", INITCAP(DIS.DISNOM) REMITENTE "	&	VbCrlf
	SQL = SQL & ", InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  <br> ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DISCODEPOSTAL)) "	&	VbCrlf
	SQL = SQL & ", INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')') "	&	VbCrlf
	SQL = SQL & ", INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE)) "	&	VbCrlf
	SQL = SQL & ", InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || '  ' || DIENUMINT || '  <br> ' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DIECODEPOSTAL)) "	&	VbCrlf
	SQL = SQL & ", INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')') "	&	VbCrlf
	SQL = SQL & ", WCD.WCDSTATUS "	&	VbCrlf
	SQL = SQL & ", WCD.WCD_TDCDCLAVE "	&	VbCrlf
	SQL = SQL & ", 'Cross Dock' "	&	VbCrlf
	SQL = SQL & ", WCD_CLICLEF "	&	VbCrlf
	SQL = SQL & ", WCD.WCDOBSERVACION "	&	VbCrlf
	SQL = SQL & ", WCD.WCDPESO "	&	VbCrlf
	SQL = SQL & ", WCD.WCDVOLUMEN "	&	VbCrlf
	SQL = SQL & ", WCD.WCDCLAVE AS NUI "	&	VbCrlf
	SQL = SQL & "FROM WCROSS_DOCK WCD "	&	VbCrlf
	SQL = SQL & " , EDIRECCIONES_ENTREGA DIE "	&	VbCrlf
	SQL = SQL & " , ECLIENT_CLIENTE CCL "	&	VbCrlf
	SQL = SQL & " , EDISTRIBUTEUR DIS "	&	VbCrlf
	SQL = SQL & " , ECIUDADES CIU_ORI "	&	VbCrlf
	SQL = SQL & " , EESTADOS EST_ORI "	&	VbCrlf
	SQL = SQL & " , ECIUDADES CIU_DEST "	&	VbCrlf
	SQL = SQL & " , EESTADOS EST_DEST "	&	VbCrlf
	SQL = SQL & " , ETRANS_DETALLE_CROSS_DOCK TDCD "	&	VbCrlf
	SQL = SQL & " , ETRANSFERENCIA_TRADING TRA "	&	VbCrlf
	SQL = SQL & " , ETRANS_ENTRADA TAE "	&	VbCrlf
	SQL = SQL & "	WHERE WCD.WCD_FIRMA IN ('" & wTalonRastreo & "') "	&	VbCrlf
	SQL = SQL & " AND DISCLEF = WCD.WCD_DISCLEF "	&	VbCrlf
	SQL = SQL & " AND DIECLAVE = NVL(NVL(TDCD_DIECLAVE_ENT, TDCD_DIECLAVE), WCD_DIECLAVE_ENTREGA) "	&	VbCrlf
	SQL = SQL & " AND CCLCLAVE = NVL(TDCD_CCLCLAVE, WCD.WCD_CCLCLAVE) "	&	VbCrlf
	SQL = SQL & " AND CIU_ORI.VILCLEF = DISVILLE "	&	VbCrlf
	SQL = SQL & " AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO "	&	VbCrlf
	SQL = SQL & " AND CIU_DEST.VILCLEF = DIEVILLE "	&	VbCrlf
	SQL = SQL & " AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO "	&	VbCrlf
	SQL = SQL & " AND TDCDCLAVE(+) = WCD.WCD_TDCDCLAVE "	&	VbCrlf
	SQL = SQL & " AND TDCDSTATUS (+) = '1' "	&	VbCrlf
	SQL = SQL & " AND TRACLAVE(+) = WCD.WCD_TRACLAVE "	&	VbCrlf
	SQL = SQL & " AND TRASTATUS (+) = '1' "	&	VbCrlf
	SQL = SQL & " AND TAE_TRACLAVE(+) = WCD.WCD_TRACLAVE "	&	VbCrlf
	SQL = SQL & " AND TAE_TRACLAVE = TRACLAVE "	&	VbCrlf
	SQL = SQL & "UNION "	&	VbCrlf
	SQL = SQL & "SELECT TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) || DECODE(WEL_ORI.WELCLAVE, NULL, NULL, ' (talon ori: ' || TO_CHAR(WEL_ORI.WELCONS_GENERAL, 'FM0000000') || '-' ||GET_CLI_ENMASCARADO(WEL_ORI.WEL_CLICLEF) ||')') "	&	VbCrlf
	SQL = SQL & ", NVL(WEL.WEL_TALON_RASTREO, WEL.WEL_FIRMA) AS WEL_FIRMA "	&	VbCrlf
	SQL = SQL & ", TO_CHAR( WEL.DATE_CREATED, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", WEL.WELRECOL_DOMICILIO "	&	VbCrlf
	SQL = SQL & ", WEL.WELFACTURA "	&	VbCrlf
	SQL = SQL & ", WEL.WEL_CDAD_BULTOS "	&	VbCrlf
	SQL = SQL & ", INITCAP(DIS.DISNOM) REMITENTE "	&	VbCrlf
	SQL = SQL & ", InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  <br> ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DISCODEPOSTAL))  remitente_direc "	&	VbCrlf
	SQL = SQL & ", INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')') "	&	VbCrlf
	SQL = SQL & ", INITCAP(WCCL.WCCL_NOMBRE) "	&	VbCrlf
	SQL = SQL & ", InitCap( WCCL_ADRESSE1|| ' ' || ' ' || WCCL_NUMEXT || '  ' || WCCL_NUMINT || '  <br> ' ||WCCL_ADRESSE2 || DECODE(WCCL_CODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || WCCL_CODEPOSTAL)) remitente_direc "	&	VbCrlf
	SQL = SQL & ", INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')') "	&	VbCrlf
	SQL = SQL & ", WEL.WELSTATUS "	&	VbCrlf
	SQL = SQL & ", WEL.WEL_TDCDCLAVE "	&	VbCrlf
	SQL = SQL & ", 'LTL' "	&	VbCrlf
	SQL = SQL & ", WEL.WEL_CLICLEF "	&	VbCrlf
	SQL = SQL & ", WEL.WELOBSERVACION "	&	VbCrlf
	SQL = SQL & ", WEL.WELPESO "	&	VbCrlf
	SQL = SQL & ", WEL.WELVOLUMEN "	&	VbCrlf
	SQL = SQL & ", WEL.WELCLAVE AS NUI "	&	VbCrlf
	SQL = SQL & "FROM WEB_LTL WEL "	&	VbCrlf
	SQL = SQL & " , WEB_CLIENT_CLIENTE WCCL "	&	VbCrlf
	SQL = SQL & " , EDISTRIBUTEUR DIS "	&	VbCrlf
	SQL = SQL & " , ECIUDADES CIU_ORI "	&	VbCrlf
	SQL = SQL & " , EESTADOS EST_ORI "	&	VbCrlf
	SQL = SQL & " , ECIUDADES CIU_DEST "	&	VbCrlf
	SQL = SQL & " , EESTADOS EST_DEST "	&	VbCrlf
	SQL = SQL & " , ETRANS_DETALLE_CROSS_DOCK TDCD "	&	VbCrlf
	SQL = SQL & " , ETRANSFERENCIA_TRADING TRA "	&	VbCrlf
	SQL = SQL & " , ETRANS_ENTRADA TAE "	&	VbCrlf
	SQL = SQL & " , WEB_LTL WEL_ORI "	&	VbCrlf
	SQL = SQL & "	WHERE (WEL.WEL_FIRMA IN ('" & wTalonRastreo & "') "	&	VbCrlf
	SQL = SQL & "	      OR WEL.WEL_TALON_RASTREO IN ('" & wTalonRastreo & "') "	&	VbCrlf
	SQL = SQL & "	     ) "	&	VbCrlf
	SQL = SQL & " AND DISCLEF = WEL.WEL_DISCLEF "	&	VbCrlf
	SQL = SQL & " AND WCCLCLAVE = WEL.WEL_WCCLCLAVE "	&	VbCrlf
	SQL = SQL & " AND CIU_ORI.VILCLEF = DISVILLE "	&	VbCrlf
	SQL = SQL & " AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO "	&	VbCrlf
	SQL = SQL & " AND CIU_DEST.VILCLEF = WCCL_VILLE "	&	VbCrlf
	SQL = SQL & " AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO "	&	VbCrlf
	SQL = SQL & " AND TDCDCLAVE(+) = WEL.WEL_TDCDCLAVE "	&	VbCrlf
	SQL = SQL & " AND TDCDSTATUS (+) = '1' "	&	VbCrlf
	SQL = SQL & " AND TRACLAVE(+) = WEL.WEL_TRACLAVE "	&	VbCrlf
	SQL = SQL & " AND TRASTATUS (+) = '1' "	&	VbCrlf
	SQL = SQL & " AND TAE_TRACLAVE(+) = WEL.WEL_TRACLAVE "	&	VbCrlf
	SQL = SQL & " AND WEL_ORI.WELCLAVE(+) = WEL.WEL_WELCLAVE "	&	VbCrlf
	SQL = SQL & " AND TAE_TRACLAVE = TRACLAVE "	&	VbCrlf
	SQL = SQL & "UNION ALL "	&	VbCrlf
	SQL = SQL & "SELECT NVL(TDCD.TDCDFACTURA, WCD.WCDFACTURA) "	&	VbCrlf
	SQL = SQL & ", WCD.WCD_FIRMA "	&	VbCrlf
	SQL = SQL & ", TO_CHAR( WCD.DATE_CREATED, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", TO_CHAR(TAE.TAE_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", TO_CHAR(TAE.TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI') "	&	VbCrlf
	SQL = SQL & ", 'n/a' "	&	VbCrlf
	SQL = SQL & ", WCD.WCD_PEDIDO_CLIENTE "	&	VbCrlf
	SQL = SQL & ", WCD.WCD_CDAD_BULTOS "	&	VbCrlf
	SQL = SQL & ", INITCAP(DIS.DISNOM) REMITENTE "	&	VbCrlf
	SQL = SQL & ", InitCap(DISADRESSE1 || ' ' || ' ' || DISNUMEXT || '  ' || DISNUMINT || '  <br> ' ||DISADRESSE2 || DECODE(DISCODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DISCODEPOSTAL)) "	&	VbCrlf
	SQL = SQL & ", INITCAP(CIU_ORI.VILNOM || ' ('|| EST_ORI.ESTNOMBRE || ')') "	&	VbCrlf
	SQL = SQL & ", INITCAP(CCL.CCL_NOMBRE || ' ' || NVL(DIE.DIE_A_ATENCION_DE, DIE.DIENOMBRE)) "	&	VbCrlf
	SQL = SQL & ", InitCap( DIEADRESSE1|| ' ' || ' ' || DIENUMEXT || '  ' || DIENUMINT || '  <br> ' ||DIEADRESSE2 || DECODE(DIECODEPOSTAL,NULL,NULL, ' <BR>C.P. ' || DIECODEPOSTAL)) "	&	VbCrlf
	SQL = SQL & ", INITCAP(CIU_DEST.VILNOM || ' ('|| EST_DEST.ESTNOMBRE || ')') "	&	VbCrlf
	SQL = SQL & ", WCD.WCDSTATUS "	&	VbCrlf
	SQL = SQL & ", WCD.WCD_TDCDCLAVE "	&	VbCrlf
	SQL = SQL & ", 'Cross Dock' "	&	VbCrlf
	SQL = SQL & ", WCD_CLICLEF "	&	VbCrlf
	SQL = SQL & ", WCD.WCDOBSERVACION "	&	VbCrlf
	SQL = SQL & ", WCD.WCDPESO "	&	VbCrlf
	SQL = SQL & ", WCD.WCDVOLUMEN "	&	VbCrlf
	SQL = SQL & ", WCD.WCDCLAVE AS NUI "	&	VbCrlf
	SQL = SQL & "FROM WCROSS_DOCK WCD "	&	VbCrlf
	SQL = SQL & " , EDIRECCIONES_ENTREGA DIE "	&	VbCrlf
	SQL = SQL & " , ECLIENT_CLIENTE CCL "	&	VbCrlf
	SQL = SQL & " , EDISTRIBUTEUR DIS "	&	VbCrlf
	SQL = SQL & " , ECIUDADES CIU_ORI "	&	VbCrlf
	SQL = SQL & " , EESTADOS EST_ORI "	&	VbCrlf
	SQL = SQL & " , ECIUDADES CIU_DEST "	&	VbCrlf
	SQL = SQL & " , EESTADOS EST_DEST "	&	VbCrlf
	SQL = SQL & " , ETRANS_DETALLE_CROSS_DOCK TDCD "	&	VbCrlf
	SQL = SQL & " , ETRANSFERENCIA_TRADING TRA "	&	VbCrlf
	SQL = SQL & " , ETRANS_ENTRADA TAE "	&	VbCrlf
	SQL = SQL & "	WHERE WCD.WCD_FIRMA IN ('" & wTalonRastreo & "') "	&	VbCrlf
	SQL = SQL & " AND DISCLEF = WCD.WCD_DISCLEF "	&	VbCrlf
	SQL = SQL & " AND DIECLAVE = NVL(NVL(TDCD_DIECLAVE_ENT, TDCD_DIECLAVE), WCD_DIECLAVE_ENTREGA) "	&	VbCrlf
	SQL = SQL & " AND CCLCLAVE = NVL(TDCD_CCLCLAVE, WCD.WCD_CCLCLAVE) "	&	VbCrlf
	SQL = SQL & " AND CIU_ORI.VILCLEF = DISVILLE "	&	VbCrlf
	SQL = SQL & " AND EST_ORI.ESTESTADO = CIU_ORI.VIL_ESTESTADO "	&	VbCrlf
	SQL = SQL & " AND CIU_DEST.VILCLEF = DIEVILLE "	&	VbCrlf
	SQL = SQL & " AND EST_DEST.ESTESTADO = CIU_DEST.VIL_ESTESTADO "	&	VbCrlf
	SQL = SQL & " AND TDCDCLAVE(+) = WCD.WCD_TDCDCLAVE "	&	VbCrlf
	SQL = SQL & " AND TDCDSTATUS (+) = '1' "	&	VbCrlf
	SQL = SQL & " AND TRACLAVE(+) = WCD.WCD_TRACLAVE "	&	VbCrlf
	SQL = SQL & " AND TRASTATUS (+) = '1' "	&	VbCrlf
	SQL = SQL & " AND TAE_TRACLAVE = TRACLAVE "	&	VbCrlf
	
	'response.Write replace(SQL, VbCrlf, "<br>")
	Session("SQL") = SQL
	arrInfo = GetArrayRS(SQL)

	ObtenerInfoTalon = arrInfo
end function


function ObtenerTrackingTalon(tdcdClave)
	Dim SQL, arrInfo
	
	SQL	=	" SELECT TO_CHAR(TAEFECHALLEGADA, 'DD/MM/YYYY HH24:MI')	"	&	VbCrlf
	SQL	=	SQL & " 	, InitCap(CIU_EAL.VILNOM) || ' (' || InitCap(EST_EAL.ESTNOMBRE)  || ')'	"	&	VbCrlf
	SQL	=	SQL & " 	, 'Entrada CEDIS Logis (' || EAL_ORI.ALLCODIGO || ' - ' || InitCap(CIU_EAL.VILNOM) || ')'	"	&	VbCrlf
	SQL	=	SQL & " 	, DXP_TIPO_ENTREGA	"	&	VbCrlf
	SQL	=	SQL & " 	, TO_CHAR(EXP_FECHA_SALIDA, 'DD/MM/YYYY HH24:MI')	"	&	VbCrlf
	SQL	=	SQL & " 	, DECODE(DXP_TIPO_ENTREGA, 'DIRECTO', 'Expedici&oacute;n directa al cliente', 'Expedici&oacute;n de traslado al CEDIS Logis (' || EAL_DEST.ALLCODIGO || ' - ' || InitCap(CIU_DEST.VILNOM) || ')')	"	&	VbCrlf
	SQL	=	SQL & " 	, TO_CHAR(DXP_FECHA_ENTREGA, 'DD/MM/YYYY HH24:MI')	"	&	VbCrlf
	SQL	=	SQL & " 	, InitCap(DXP_TIPO_EVIDENCIA)	"	&	VbCrlf
	SQL	=	SQL & " 	, TRA_MEZTCLAVE_DEST	"	&	VbCrlf
	SQL	=	SQL & " 	, NVL(DXP_TINCLAVE, 0)	"	&	VbCrlf
	SQL	=	SQL & " 	, NVL(DXP_VAS, 'N')	"	&	VbCrlf
	
	SQL = SQL & " , LOGIS.TIPO_OPERACION_FACT (TDCD.TDCDCLAVE, TDCD.TDCD_TRACLAVE)  " & VbCrlf
	
	SQL	=	SQL & " FROM	ETRANS_DETALLE_CROSS_DOCK TDCD	"	&	VbCrlf
	SQL	=	SQL & " 	, ETRANSFERENCIA_TRADING TRA	"	&	VbCrlf
	SQL	=	SQL & " 	, EALMACENES_LOGIS EAL_ORI	"	&	VbCrlf
	SQL	=	SQL & " 	, ECIUDADES CIU_EAL	"	&	VbCrlf
	SQL	=	SQL & " 	, EESTADOS EST_EAL	"	&	VbCrlf
	SQL	=	SQL & " 	, ETRANS_ENTRADA TAE	"	&	VbCrlf
	SQL	=	SQL & " 	, EDET_EXPEDICIONES DXP	"	&	VbCrlf
	SQL	=	SQL & " 	, EEXPEDICIONES EXP	"	&	VbCrlf
	SQL	=	SQL & " 	, EALMACENES_LOGIS EAL_DEST	"	&	VbCrlf
	SQL	=	SQL & " 	, ECIUDADES CIU_DEST	"	&	VbCrlf
	SQL	=	SQL & " WHERE	TDCD.TDCDCLAVE IN (	"	&	VbCrlf
	SQL	=	SQL & " 		SELECT TDCDCLAVE	"	&	VbCrlf
	SQL	=	SQL & " 		FROM ETRANS_DETALLE_CROSS_DOCK	"	&	VbCrlf
	SQL	=	SQL & " 		WHERE TDCD_DXPCLAVE_ORI IN	"	&	VbCrlf
	SQL	=	SQL & " 			(SELECT DXPCLAVE	"	&	VbCrlf
	SQL	=	SQL & " 			 FROM EDET_EXPEDICIONES	"	&	VbCrlf
	SQL	=	SQL & " 			 WHERE DXP_TIPO_ENTREGA IN ('TRASLADO', 'DIRECTO')	"	&	VbCrlf
	SQL	=	SQL & " 			 CONNECT BY PRIOR DXPCLAVE = DXP_DXPCLAVE	"	&	VbCrlf
	SQL	=	SQL & " 			 START WITH DXP_TDCDCLAVE = " & tdcdClave & ")	"	&	VbCrlf
	SQL	=	SQL & " 			UNION	"	&	VbCrlf
	SQL	=	SQL & " 			 SELECT	" & tdcdClave & "	"	&	VbCrlf
	SQL	=	SQL & " 			 FROM	DUAL	"	&	VbCrlf
	SQL	=	SQL & " 		)	"	&	VbCrlf
	SQL	=	SQL & " 	AND	TRACLAVE = TDCD.TDCD_TRACLAVE	"	&	VbCrlf
	SQL	=	SQL & " 	AND	TRASTATUS = '1'	"	&	VbCrlf
	SQL	=	SQL & " 	AND	TDCDSTATUS = '1'	"	&	VbCrlf
	SQL	=	SQL & " 	AND	EAL_ORI.ALLCLAVE = TRA_ALLCLAVE	"	&	VbCrlf
	SQL	=	SQL & " 	AND	CIU_EAL.VILCLEF = EAL_ORI.ALL_VILCLEF	"	&	VbCrlf
	SQL	=	SQL & " 	AND	EST_EAL.ESTESTADO = CIU_EAL.VIL_ESTESTADO	"	&	VbCrlf
	SQL	=	SQL & " 	AND	TAE_TRACLAVE = TRACLAVE	"	&	VbCrlf
	SQL	=	SQL & " 	AND	DXP_TDCDCLAVE(+) = TDCD.TDCDCLAVE	"	&	VbCrlf
	SQL	=	SQL & " 	AND	EXPCLAVE(+) = DXP_EXPCLAVE	"	&	VbCrlf
	SQL	=	SQL & " 	AND	EAL_DEST.ALLCLAVE(+) = DXP_ALLCLAVE_DEST	"	&	VbCrlf
	SQL	=	SQL & " 	AND	CIU_DEST.VILCLEF(+) = EAL_DEST.ALL_VILCLEF	"	&	VbCrlf
	SQL	=	SQL & " ORDER	BY DXPCLAVE	"	&	VbCrlf

	'response.Write replace(SQL,VbCrlf,"<br>")
	Session("SQL") = SQL
	arrInfo = GetArrayRS(SQL)

	ObtenerTrackingTalon = arrInfo
end function

function ObtenerTipoOperacion(wTalonRastreo)
	Dim SQL, arrInfo, TDCDFACTURA

	SQL = "SELECT LPAD(WELCONS_GENERAL, 7, '0') || '-' || WEL_CLICLEF FROM WEB_LTL WHERE WEL_TALON_RASTREO = '" & wTalonRastreo & "'"
	
	'response.Write replace(SQL,VbCrlf,"<br>")
	Session("SQL") = SQL
	arrInfo = GetArrayRS(SQL)

	if isArray(arrInfo) then
		TDCDFACTURA = arrInfo(0,0)
	else
		TDCDFACTURA = ""
	end if

	SQL	=	" SELECT	 CROSS.TDCDFACTURA	AS	FACTURA_TALON	"	&	VbCrlf
	SQL	=	SQL	&	" 		,LOGIS.TIPO_OPERACION_FACT (CROSS.TDCDCLAVE, CROSS.TDCD_TRACLAVE)	AS	TIPO_OPERACION	"	&	VbCrlf
'	SQL	=	SQL	&	" 		,TIPO_OPERACION_FACT (CROSS.TDCDCLAVE, CROSS.TDCD_TRACLAVE)	AS	TIPO_OPERACION	"	&	VbCrlf
	SQL	=	SQL	&	" 		,CEDIS.ALLCODIGO ||'-'|| CEDIS.ALLNOMBRE	AS	CEDIS	"	&	VbCrlf
	SQL	=	SQL	&	" FROM	 ETRANS_DETALLE_CROSS_DOCK CROSS	"	&	VbCrlf
	SQL	=	SQL	&	"		,EALMACENES_LOGIS CEDIS	"	&	VbCrlf
'	SQL	=	SQL	&	" WHERE	 CROSS.TDCDFACTURA		=	'0089529-3999'	"	&	VbCrlf
	SQL	=	SQL	&	" WHERE	 CROSS.TDCDFACTURA		=	'" & TDCDFACTURA & "'	"	&	VbCrlf
	SQL	=	SQL	&	"	AND	 CROSS.TDCD_ALLCLAVE	=	CEDIS.ALLCLAVE	"	&	VbCrlf
	SQL	=	SQL	&	" ORDER	BY	CROSS.TDCDFECHA_BASE	"	&	VbCrlf

	'response.Write replace(SQL,VbCrlf,"<br>")
	Session("SQL") = SQL
	arrInfo = GetArrayRS(SQL)

	ObtenerTipoOperacion = arrInfo
end function

function ObtenerEstatusSinDocumentar(wTalonRastreo)
	Dim SQL, arrInfo
	
	'SQL	=	" select welstatus,welfactura,welclave,welcons_general,wel_talon_rastreo,wel_firma from web_ltl where wel_talon_rastreo = '" & wTalonRastreo & "'	"	&	VbCrlf
	SQL	=	" select welstatus,welfactura,welclave,welcons_general,wel_talon_rastreo,wel_firma from web_ltl where wel_talon_rastreo = '" & wTalonRastreo & "' or wel_firma = '" & wTalonRastreo & "'	"	&	VbCrlf

	'response.Write replace(SQL,VbCrlf,"<br>")
	Session("SQL") = SQL
	arrInfo = GetArrayRS(SQL)
	
	ObtenerEstatusSinDocumentar = arrInfo
end function

function ObtenerEstatusSinDocumentarCD(wTalonRastreo)
	Dim SQL, arrInfo
	
	SQL	=	" select wcdstatus,wcdfactura,wcdclave,wcd_firma from wcross_dock where wcd_firma = '" & wTalonRastreo & "'	"	&	VbCrlf

	'response.Write replace(SQL,VbCrlf,"<br>")
	Session("SQL") = SQL
	arrInfo = GetArrayRS(SQL)
	
	ObtenerEstatusSinDocumentarCD = arrInfo
end function

function OrdenarTracking(arrInfo)
	Dim arrTmp, x, y, z
	
	if IsArray(arrInfo) then
		ReDim arrTmp((UBound(arrInfo,2)+2)*10)
		y = 0
		for x = 0 to UBound(arrInfo,2)
			for y = 0 to UBound(arrInfo)
				arrTmp(z) = arrInfo(y,x)
				z = z + 1
			next
		next
	else
		arrTmp = arrInfo
	end if

	OrdenarTracking = arrTmp
end function
' CHG-DESA-28032022-01>

function EsGuiaCancelada(sGuia_Firma)
	Dim Result, arrInfo
	Result = false
	
	arrInfo = ObtenerEstatusSinDocumentar(sGuia_Firma)
	
	if IsArray(arrInfo) then
		if CStr(arrInfo(0,0)) = "0" then
			Result = true
		end if
	else
		arrInfo = ObtenerEstatusSinDocumentarCD(sGuia_Firma)
		
		if IsArray(arrInfo) then
			if CStr(arrInfo(0,0)) = "0" then
				Result = true
			end if
		end if
	end if
	
	EsGuiaCancelada = Result
end function

function GuiaEnStndBy(sGuia_Firma)
	Dim Result, arrInfo
	Result = false
	
	arrInfo = ObtenerEstatusSinDocumentar(sGuia_Firma)
	
	if IsArray(arrInfo) then
		if CStr(arrInfo(0,0)) = "2" then
			Result = true
		end if
	else
		arrInfo = ObtenerEstatusSinDocumentarCD(sGuia_Firma)
		
		if IsArray(arrInfo) then
			if CStr(arrInfo(0,0)) = "2" then
				Result = true
			end if
		end if
	end if
	
	GuiaEnStndBy = Result
end function

'<<CHG-DESA-27122022-01: no mostrar el menu para los clientes de la lista
Function obtener_clients()
	dim matriz,result 
	dim client,i
	result = false
	client ="1297,4613,6530,18140,21223,21225,21852,21853,21925,22011,22139,22140,22292,22329,22594,22754,22758,22807,22824,22825,22844,22848,"
	client = client & "22864,22869,22885,22886,22887,22888,22889,22890,22891,22892,22894,22907,22926,22944"
	client = client & ",14795,22963,22972,3272"
	matriz= Split(client,",")
	
	for i = 0 to UBound(matriz)
		if Cstr(matriz(i)) = Cstr(Session("array_client")(2,0)) then
			result = true
		end if
	next
	obtener_clients= result

End Function
'  CHG-DESA-27122022-01>>
'<<<MRG-20230111
Function obtenerCteFctCan()
	Dim SQL,result
	Dim arrLotes
	response.write "/*ini*/"
	result = false
	SQL = ""
	
	SQL = SQL & "	SELECT DISTINCT wl.lote numero_lote,wl.web_cliente " & vbCrLf
	SQL = SQL & "	FROM tb_facturas_ccfdi f " & vbCrLf
	SQL = SQL & "	JOIN tb_facturas_nuis_ccfdi fn " & vbCrLf
	SQL = SQL & "	ON f.id_factura_cumple = fn.id_factura_cumple " & vbCrLf
	SQL = SQL & "	inner join web_tracking_stage wts on wts.nui= fn.nui " & vbCrLf
	SQL = SQL & "	inner join web_lots wl on wts.numero_lote = wl.lote" & vbCrLf
	SQL = SQL & "	INNER JOIN EFACTURAS FCT ON F.FCTCLEF = FCT.FCTCLEF " & vbCrLf
	SQL = SQL & "	WHERE 1=1 " & vbCrLf
	SQL = SQL & "	AND f.fctclef IS NOT NULL " & vbCrLf
	SQL = SQL & "	AND f.cliente NOT IN (9954,9955,9956,9929,9910) " & vbCrLf
	SQL = SQL & "	AND f.TIPO_CFDI = 'Ingreso' " & vbCrLf
	SQL = SQL & "	AND f.STATUS_CFDI = 'T' " & vbCrLf
	SQL = SQL & "	AND f.FECHA_TIMBRADO IS NOT NULL " & vbCrLf
	SQL = SQL & "	AND f.FECHA_CANCELACION IS NULL " & vbCrLf
	SQL = SQL & "	AND fct.FCTNUMERO NOT IN (--obtener relacion de la NC - Fact Ini montos iguales " & vbCrLf
	SQL = SQL & "	        select  " & vbCrLf
	SQL = SQL & "	         fac.FCTNUMERO as Num_Factura_ini " & vbCrLf
	SQL = SQL & "	        FROM EFACTURAS fac " & vbCrLf
	SQL = SQL & "	        JOIN EFOLIOS fol " & vbCrLf
	SQL = SQL & "	        ON fol.folclave = fac.fctfolio " & vbCrLf
	SQL = SQL & "	        INNER JOIN (--obtener NC " & vbCrLf
	SQL = SQL & "	                select fct.FCTTOTAL as Total " & vbCrLf
	SQL = SQL & "	                , fol.folfolio as Folio " & vbCrLf
	SQL = SQL & "	                FROM EFACTURAS fct " & vbCrLf
	SQL = SQL & "	                INNER JOIN EFOLIOS fol " & vbCrLf
	SQL = SQL & "	                ON fol.folclave = fct.fctfolio " & vbCrLf
	SQL = SQL & "	                WHERE 1=1 " & vbCrLf
	SQL = SQL & "	                AND fct.FCT_YFACLEF IN ('3') " & vbCrLf
	SQL = SQL & "	        ) NC " & vbCrLf
	SQL = SQL & "	        ON fol.folfolio = NC.Folio " & vbCrLf
	SQL = SQL & "	        WHERE 1=1 " & vbCrLf
	SQL = SQL & "	        AND fac.FCTTOTAL = ABS(NC.Total) " & vbCrLf
	SQL = SQL & "	        AND fac.FCT_YFACLEF IN ('1') " & vbCrLf
	SQL = SQL & "	        AND fac.FCT_EMPCLAVE IN(55,56) " & vbCrLf
	SQL = SQL & "	        and fac.fctclient = '" & Session("array_client")(2,0) & "' " & vbCrLf
	SQL = SQL & "	        ) " & vbCrLf
	SQL = SQL & "	AND f.cliente = '" & Session("array_client")(2,0) & "' " & vbCrLf

	Session("SQL") = SQL 
	arrLotes = GetArrayRS(SQL)
	
	if isArray(arrLotes) then
		if Ubound(arrLotes,2) > 0 then
			result = true
		end if
	end if
	response.write "/*fin*/"
	obtenerCteFctCan = result
End Function 
'   MRG-20230111>>>
'<<CHG-DESA-20230117: Registra movimientos en Bitácora.
	function registrar_bitacora(client,modulo,nui,tipo)
		Dim ip_site,rst_bita,arr_bita,puede_registrar_bita,SQL
			ip_site="192.168.100.21"
			SQL=""
		
		if client <> "" and modulo <> "" then
			'''''Valida si ya se registró el acceso en la última hora:
			puede_registrar_bita = true
			SQL = " SELECT	* " & vbCrLf
			SQL = SQL & " FROM	WEB_BITA_DOCUMENTA " & vbCrLf
			SQL = SQL & " WHERE	WBD_CLICLEF = '" & client & "' " & vbCrLf
			SQL = SQL & " 	AND	(	WBD_USUARIO = '" & Session("array_client")(0,0) & "' " & vbCrLf
			SQL = SQL & " 		OR	WBD_USUARIO = '" & Session("internal_user") & "') " & vbCrLf
			SQL = SQL & " 	AND	WBD_IP_CLIENTE = '" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "' " & vbCrLf
			SQL = SQL & " 	AND	WBD_MODULO = '" & modulo & "' " & vbCrLf
			SQL = SQL & " 	AND	TO_CHAR(WBD_FECHA,'DD/MM/YYYY HH24MI') = TO_CHAR(SYSDATE,'DD/MM/YYYY HH24MI') " & vbCrLf
			Session("SQL") = SQL
			'arr_bita = GetArrayRS(SQL)
			
			if IsArray(arr_bita) then
				if UBound(arr_bita) > 0 then
	'				puede_registrar_bita = false
				end if
			end if
			
			'if puede_registrar_bita = true then
				SQL = " INSERT INTO	WEB_BITA_DOCUMENTA( "	& vbCrLf
				SQL = SQL & " 		 WBD_ID_EVENTO "	& vbCrLf
				SQL = SQL & " 		,WBD_FECHA ,WBD_CLICLEF "	& vbCrLf
				SQL = SQL & " 		,WBD_MODULO ,WBD_USUARIO "	& vbCrLf
				SQL = SQL & " 		,NUI, TIPO "	& vbCrLf
				SQL = SQL & " 		,WBD_IP_SERVIDOR,WBD_IP_CLIENTE) "	& vbCrLf
				SQL = SQL & " 	VALUES( "	& vbCrLf
				SQL = SQL & " 		 (SELECT MAX(NVL(WBD_ID_EVENTO,0)) + 1 FROM WEB_BITA_DOCUMENTA) "	& vbCrLf
				SQL = SQL & " 		,SYSDATE ,'" & client & "' "	& vbCrLf
				SQL = SQL & " 		,'" & modulo & "' ,'" 
				
				if (Session("internal_login") <> 2 and Session("internal_login") <> 3) then
					SQL = SQL & Session("array_client")(0,0) & "' "	& vbCrLf
				else
					if Session("internal_user") <> "" then
						SQL = SQL & Session("internal_user") & "' "	& vbCrLf
					else
						SQL = SQL & Session("array_client")(0,0) & "' "	& vbCrLf
					end if
				end if
				
				SQL = SQL & " 		,'" & nui & "','" & tipo & "' "	& vbCrLf
				SQL = SQL & " 		,'" & ip_site & "','" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "') "	& vbCrLf
				
				Session("SQL") = SQL
				set rst_bita = Server.CreateObject("ADODB.Recordset")
				rst_bita.Open SQL, Connect(), 0, 1, 1
			'end if
		else
			puede_registrar_bita = false
		end if
	end function 
'  CHG-DESA-20230117>>

function registrar_movimiento_bitacora(client,modulo,nui,tipo,usuario)
	Dim ip_site,rst_bita,arr_bita,puede_registrar_bita,SQL
		
	ip_site = "192.168.100.21"
	SQL = ""
	
	if client <> "" and modulo <> "" then
		SQL = " INSERT INTO	WEB_BITA_DOCUMENTA( "	& vbCrLf
		SQL = SQL & " 		 WBD_ID_EVENTO "	& vbCrLf
		SQL = SQL & " 		,WBD_FECHA ,WBD_CLICLEF "	& vbCrLf
		SQL = SQL & " 		,WBD_MODULO ,WBD_USUARIO "	& vbCrLf
		SQL = SQL & " 		,NUI, TIPO "	& vbCrLf
		SQL = SQL & " 		,WBD_IP_SERVIDOR,WBD_IP_CLIENTE) "	& vbCrLf
		SQL = SQL & " 	VALUES( "	& vbCrLf
		SQL = SQL & " 		 (SELECT MAX(NVL(WBD_ID_EVENTO,0)) + 1 FROM WEB_BITA_DOCUMENTA) "	& vbCrLf
		SQL = SQL & " 		,SYSDATE ,'" & client & "' "	& vbCrLf
		SQL = SQL & " 		,'" & modulo & "' ," 
		
		if usuario <> "" and usuario <> " USER " then
			SQL = SQL & usuario & " "	& vbCrLf
		else
			if (Session("internal_login") <> 2 and Session("internal_login") <> 3) then
				SQL = SQL & "'" & Session("array_client")(0,0) & "' "	& vbCrLf
			else
				if Session("internal_user") <> "" then
					SQL = SQL & "'" & Session("internal_user") & "' "	& vbCrLf
				else
					SQL = SQL & "'" & Session("array_client")(0,0) & "' "	& vbCrLf
				end if
			end if
		end if
		
		SQL = SQL & " 		,'" & nui & "','" & tipo & "' "	& vbCrLf
		SQL = SQL & " 		,'" & ip_site & "','" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "' "	& vbCrLf
		SQL = SQL & " 	) "	& vbCrLf
			
		'<<<<2024-08-01: Se agrega registro en log de queries:
			registraLog_subproceso "3", SQL
		'    2024-08-01>>>>
		Session("SQL") = SQL
		set rst_bita = Server.CreateObject("ADODB.Recordset")
		rst_bita.Open SQL, Connect(), 0, 1, 1
		'<<<<2024-08-01: Se agrega registro en log de queries:
			registraLog_subproceso "3", "ejecutado"
		'    2024-08-01>>>>
		registrar_movimiento_bitacora = true
	else
		registrar_movimiento_bitacora = false
	end if
end function

'<<< CHG-DESA-24042024 se integra a la funcion el parametro de cantidad de facturas
function registrar_tracking(nui,user,cant_facturas)
	Dim res, SQL
	
	if cant_facturas = "" then
		cant_facturas = "0"
	elseif Cdbl(cant_facturas) < 0 then
		cant_facturas = "0"
	end if
	
	SQL	=	" UPDATE	 WEB_TRACKING_STAGE	" & vbCrLf
	SQL	=	SQL	&	"	SET	 FECHA_DOCUMENTACION	=	SYSDATE	" & vbCrLf
	SQL	=	SQL	&	" 		,USR_DOC				=	" & user & "	" & vbCrLf
	SQL	=	SQL	&	" 		,TOTAL_FACTURAS			=	'" & cant_facturas & "'	" & vbCrLf
	SQL	=	SQL	&	" WHERE	 NUI	=	'" & nui & "' " & vbCrLf
	
	'<<<<2024-08-01: Se agrega registro en log de queries:
		registraLog_subproceso "4", SQL
	'    2024-08-01>>>>
	Session("SQL") = SQL
	set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open SQL, Connect(), 0, 1, 1
	'<<<<2024-08-01: Se agrega registro en log de queries:
		registraLog_subproceso "4", "ejecutado"
	'    2024-08-01>>>>
end function
' CHG-DESA-24042024 >>>

	Function ObtenerNUIdisponible(Tipo, NumCliente)
		Dim NuevoNUI, SQL, arrNuevoNUI
		
		NuevoNUI = "-1"
		
		if Tipo = "LTL" then
			SQL = "SELECT	MIN(WELCLAVE)	FROM	WEB_LTL		WHERE	WEL_CLICLEF	=	'" & NumCliente & "'	AND	(WELSTATUS	=	3	OR	(WELSTATUS	=	1	AND	WELFACTURA	=	'RESERVADO'))"
		else
			SQL = "SELECT	MIN(WCDCLAVE)	FROM	WCROSS_DOCK	WHERE	WCD_CLICLEF	=	'" & NumCliente & "'	AND	(WCDSTATUS	=	3	OR	(WCDSTATUS	=	1	AND	WCDFACTURA	=	'RESERVADO'))"
		end if
		
		Session("SQL") = SQL
		arrNuevoNUI = GetArrayRS(SQL)
		
		if IsArray(arrNuevoNUI) then
			NuevoNUI = CStr(arrNuevoNUI(0,0))
		end if
		
		ObtenerNUIdisponible = NuevoNUI
	End Function

	'Valida si la cuenta del cliente tiene tarifa de cobro por cajas (Tarifa Especial):
	function ClienteTarifaEspecial(NumCliente)
		Dim bRes
			bRes = false
			
			'23012 Prueba Cajas
			'20123 Pruebas Smo
			'0 Cliente, S.A. De C.V.
			'3272 Acegrapas Fifa S.A. De C.V.
			'3642 Hellamex SA de CV
			'4958 Mettler Toledo SA de CV
			'5668 Ntn De Mexico SA
			'7787 Knova SA de CV
			'10662 Teka Mexicana SA de CV
			'15178 Johnson & Johnson SA de CV
			'16935 Beautyge Mexico
			'18806 Binney & Smith (Mexico) SA de CV
			'20150 Frabel S.A De C.V.
			'20235 Frabel S.A De C.V.
			'20343 Teka Mexicana SA de CV
			'20432 Sbcbsg Company De Mexico S. De R.L. De C.V.
			'20501 Glaxosmithkline Consumer Healthcare Mexico SA de CV
			'20502 Glaxosmithkline Consumer Healthcare Mexico SA de CV
			'20906 Imagen Cosmetica Sapi De Cv
			'20975 Originales Nina Carol'S
			'21063 Extrusa De Mexico SA de CV
			'21194 Wolf Company SA de CV
			'21240 Ah Actual SA de CV
			'21378 Belleza Euromex S, De Rl De Cv
			'21487 Cerveceria De Yucatan SA de CV
			'21698 Polietileno Publicitario S.A.
			'21794 Mead Johnson Nutricionales De Mexico
			'21795 Rb Health Mexico Sa De
			'21836 Ogg Homes Mexico S.A. De C.V.
			'21858 Kyb Mexico SA de CV
			'22067 Reckitt Benckiser Mexico S.A. De C.V
			'22258 Arod S.A. De C.V.
			'22311 Rafisacos S.A De C.V.
			'22443 Rb Health Mexico Sa De
			'22444 Mead Johnson Nutricionales De Mexico S De Rl De Cv
			'22526 Dispensadores Electricos SA de CV
			'22596 Comercializadora Cosmetica De Mexico Sapi De Cv
			'22644 Republic Nail SA de CV
			'22853 Mead Johnson Nutricionales De Mexico S De Rl De Cv
			'22944 Talleres Estrella S.A. De C.V
			'22963 Santul Herramientas SA de CV
			
		'<<20230403: Sandy envió por correo el listado de cuentas que tienen tarifa de cobro por caja:
		'if	NumCliente = 23012	or NumCliente = 20123	or _
		'	NumCliente = 0		or NumCliente = 3272	or NumCliente = 3642	or NumCliente = 4958	or NumCliente = 5668	or _
		'	NumCliente = 7787	or NumCliente = 10662	or NumCliente = 15178	or NumCliente = 16935	or NumCliente = 18806	or _
		'	NumCliente = 20150	or NumCliente = 20235	or NumCliente = 20343	or NumCliente = 20432	or _
		'	NumCliente = 20501	or NumCliente = 20502	or NumCliente = 20906	or NumCliente = 20975	or NumCliente = 21063	or _
		'	NumCliente = 21194	or NumCliente = 21240	or NumCliente = 21378	or NumCliente = 21487	or NumCliente = 21698	or _
		'	NumCliente = 21794	or NumCliente = 21795	or NumCliente = 21836	or NumCliente = 21858	or NumCliente = 22067	or _
		'	NumCliente = 22258	or NumCliente = 22311	or NumCliente = 22443	or NumCliente = 22444	or NumCliente = 22526	or _
		'	NumCliente = 22596	or NumCliente = 22644	or NumCliente = 22853	or NumCliente = 22944	or NumCliente = 22963	then
		'		bRes = true
		'end if
		
		if	NumCliente = 23012	or NumCliente = 20123	or _
			NumCliente = 15178	or NumCliente = 20432	or NumCliente = 21794	or NumCliente = 21795	or NumCliente = 22067	or _
			NumCliente = 22443	or NumCliente = 22444	or NumCliente = 22853	then
				bRes = true
		end if
		'  20230403>>
		
		ClienteTarifaEspecial = bRes
	end function

	'Valida si la cuenta del cliente tiene permisos para utilizar el nuevo módulo de documentación de guías CrossDock:
	function NuevoModulo_CD_Habilitado(NumCliente)
		Dim bRes
			bRes = false
		
		if NumCliente <> "" then
			if	CDbl(NumCliente) = 20123 or CDbl(NumCliente) = 19808 or CDbl(NumCliente) = 19810	or _
				CDbl(NumCliente) = 22512 or CDbl(NumCliente) = 22573 or CDbl(NumCliente) = 19066	or _
				CDbl(NumCliente) = 22853 or CDbl(NumCliente) = 22067 or CDbl(NumCliente) = 22963	or _
				CDbl(NumCliente) = 23012	then
				bRes = true
			end if
		end if
		
		'2023-03-03:
		'Una vez habilitado el nuevo LogIn, ésta validación ya no aplica, por lo que la función retorna un TRUE.
		bRes = true
		
		NuevoModulo_CD_Habilitado = bRes
	end function

	'Sirve para validar si se presenta (o no) la pantalla intermedia al momento de Iniciar Sesión (login.asp):
	Function usuLogCte(usu)
		Dim log
		Dim sqlLogin, arrLogin, countLogin
		
		log = false
		usu = UCase(usu)
		
		sqlLogin = "" & vbCrLf
		sqlLogin = sqlLogin & " SELECT	 ID, NVL(NOMBRE_USUARIO,'') NOMBRE_USUARIO, NVL(REGIONAL,'') REGIONAL " & vbCrLf
		sqlLogin = sqlLogin & " 		,NVL(MENU_CANCELAR,0) MENU_CANCELAR, NVL(OPCION_CANCELAR,0) OPCION_CANCELAR " & vbCrLf
		sqlLogin = sqlLogin & " 		,NVL(DOCUMENTA_CTAS,0) LOGIN_INTERMEDIO " & vbCrLf
		sqlLogin = sqlLogin & " 		,NVL(ACCESO_PERMITIDO,0) ACCESO_PERMITIDO, NVL(COMENTARIOS,'') COMENTARIOS " & vbCrLf
		sqlLogin = sqlLogin & " FROM	 USUARIO_PERMISO_DISTRIBUCION " & vbCrLf
		sqlLogin = sqlLogin & " WHERE	 UPPER(NOMBRE_USUARIO)	=	UPPER('" & usu & "') " & vbCrLf
		
		arrLogin = GetArrayRS(sqlLogin)
		
		if IsArray(arrLogin) then
			if CStr(arrLogin(5,0)) = "1" then
				log = true
			end if
		end if
		
		Session("doc_multi_ctas") = log
		usuLogCte = log
	End Function

	'Busca al Usuario y Password de Orfeo en la tabla [Usuarios] para ingresar a la pantalla intemedia y capturar la cuenta con que se va a trabajar:
	Function getUsuHab(usu,pwd)
		Dim SQL_Can,array_usr,result
		result = false
		SQL_usu= ""
		SQL_usu = " SELECT	CDUSUARIO,DSUSUARIO " & VbCrlf
		SQL_usu = SQL_usu & " FROM	USUARIOS " & VbCrlf
		SQL_usu = SQL_usu & " WHERE	UPPER(CDUSUARIO) = UPPER('"& usu &"') " & VbCrlf
		SQL_usu = SQL_usu & " 	AND	UPPER(DSUSUARIO) = UPPER('"& pwd &"') " & VbCrlf
		array_usr = GetArrayRS(SQL_usu)
		
		if IsArray(array_usr) then
			Session("array_client")= array_usr 
			result = true
		end if
		
		getUsuHab = result
	End Function
	'<20230322:

	function ClienteXcobrar(CliClef)
		Dim res, sqlCob, ArrCob, countCob
		res = false
		
		sqlCob = " SELECT	cobrar_prepago " & vbCrLf
		sqlCob = sqlCob & " FROM	USUARIO_PERMISO_DISTRIBUCION " & vbCrLf
		sqlCob = sqlCob & " WHERE	NOMBRE_USUARIO = '" & CliClef & "' " & vbCrLf
		Session("SQL") = sqlCob
		ArrCob = GetArrayRS(sqlCob)
		
		if IsArray(ArrCob) then
			countCob = CStr(ArrCob(0,0))
			
			if countCob = "2" then
				res = true
			end if
		end if
		
		ClienteXcobrar = res
	end function
	' 20230322>

'<<CHG-DESA-04052023-01: Se agrega función para reservar el siguiente NUI disponible
	'Update para apartar NUI y poderlo documentar
	function apartarNUI(numClient, ipAparta,NUI)
		Dim SQLaparta, rst_aparta
		
		'funcion de limpieza de nuis apartados:
		cleanApartaNUI(numClient)
		
		if ValidarNUIApartado(numClient,NUI,ipAparta) = false Or ValidarNUIApartado(numClient,NUI,ipAparta) = "false" then
			'Obtener el siguiente nui disponible
			NUI = dispNUI(numClient)
			if NUI <> "0" then 
				SQLaparta = " UPDATE WEB_LTL " & VbCrlf
				SQLaparta = SQLaparta & "   SET  WELFACTURA = 'APAR_" & ipAparta & "_TADO' " & VbCrlf
				SQLaparta = SQLaparta & "   	,DATE_CREATED = SYSDATE " & VbCrlf
				SQLaparta = SQLaparta & "   	,WEL_TRACLAVE = NULL " & VbCrlf
				SQLaparta = SQLaparta & "   	,WEL_TDCDCLAVE = NULL " & VbCrlf
				SQLaparta = SQLaparta & " WHERE WELCLAVE = '" & NUI & "' " & VbCrlf
				SQLaparta = SQLaparta & "   AND WEL_CLICLEF = '" & numClient& "' " & VbCrlf
				SQLaparta = SQLaparta & "   AND UPPER(WELFACTURA) = UPPER('RESERVADO') " & VbCrlf
				SQLaparta = SQLaparta & "   AND WELSTATUS = '3' " & VbCrlf
				Session("SQL") = SQLaparta
				set rst_aparta = Server.CreateObject("ADODB.Recordset")
				rst_aparta.Open SQLaparta, Connect(), 0, 1, 1
			end if
		end if 
		
		apartarNUI = NUI
	end function
	
	'Obtener el siguiente NUI disponible
	function dispNUI(numClient)
		Dim SQL_NUI,arrNUI,nui
		
		nui="0"

	if numClient = "20123" then
		SQL_NUI = "SELECT NVL(MAX(WELCLAVE),0) " & VbCrlf
	else
		SQL_NUI = "SELECT NVL(MIN(WELCLAVE),0) " & VbCrlf
	end if 
		SQL_NUI = SQL_NUI & "  FROM WEB_LTL " & VbCrlf
		SQL_NUI = SQL_NUI & " WHERE WEL_CLICLEF = '" & numClient & "' " & VbCrlf
		'SQL_NUI = SQL_NUI & "   AND UPPER(WELFACTURA) = UPPER('RESERVADO') " & VbCrlf
		SQL_NUI = SQL_NUI & "   AND WELFACTURA IN ('RESERVADO','APAR_" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "_TADO') " & VbCrlf
		SQL_NUI = SQL_NUI & "   AND WELSTATUS = '3' " & VbCrlf

		Session("SQL") = SQL_NUI
		arrNUI = GetArrayRS(SQL_NUI)
		
			if IsArray(arrNUI) then
				nui = arrNUI(0,0)
			end if
		dispNUI = nui
	end function

	function ValidarNUIApartado(numClient,NUI,ipAparta)
		Dim SQL_NUI,arrNUI,validado
		validado = false
		'Si el NUI está apartado para el cliente y la IP ingresada, se retorna TRUE para que no sea necesario apartar otro NUI:
		SQL_NUI	=	" SELECT	WELCLAVE, WELFACTURA " & VbCrlf
		SQL_NUI	=	SQL_NUI	&	" FROM	WEB_LTL " & VbCrlf
		SQL_NUI	=	SQL_NUI	&	" WHERE	1=1 " & VbCrlf
		SQL_NUI	=	SQL_NUI	&	" 	AND	WEL_CLICLEF = '" & numClient & "' " & VbCrlf
		SQL_NUI	=	SQL_NUI	&	" 	AND WELFACTURA = 'APAR_" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "_TADO' " & VbCrlf
		SQL_NUI	=	SQL_NUI	&	" 	AND WELCLAVE = '" & NUI & "' " & VbCrlf
		
		Session("SQL") = SQL_NUI
		arrNUI = GetArrayRS(SQL_NUI)
		
		if IsArray(arrNUI) = true then
			if UBound(arrNUI) > 0 and UBound(arrNUI,2) > 0 then
				if arrNUI(0,0) = NUI then
					validado = true
				end if
			end if
		end if
		
		
		'Si no hay NUI apartado para el cliente y la IP ingresada, se aparta el siguiente NUI disponible:
		if validado = false then
			if numClient = "20123" then
				SQL_NUI = "SELECT MAX(WELCLAVE), WELFACTURA" & VbCrlf
			else
				SQL_NUI = "SELECT MIN(WELCLAVE), WELFACTURA" & VbCrlf
			end if 
		SQL_NUI = SQL_NUI & "  FROM WEB_LTL " & VbCrlf
		SQL_NUI = SQL_NUI & " WHERE 1=1 " & VbCrlf
		SQL_NUI = SQL_NUI & " AND WELCLAVE = '" & NUI & "' " & VbCrlf
		SQL_NUI = SQL_NUI & "   AND WEL_CLICLEF = '" & numClient & "' " & VbCrlf

		if numClient = "20123" then
			SQL_NUI = SQL_NUI & "   AND WELFACTURA = 'APAR_" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "_TADO' " & VbCrlf
		else
			SQL_NUI = SQL_NUI & "   AND WELFACTURA IN ('RESERVADO','APAR_" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "_TADO') " & VbCrlf
		end if
		SQL_NUI = SQL_NUI & "   AND WELSTATUS = '3' " & VbCrlf
		SQL_NUI = SQL_NUI & "   group by WELFACTURA " & VbCrlf
		SQL_NUI = SQL_NUI & " ORDER BY 1 " & VbCrlf
		
		if numClient = "20123" then
			SQL_NUI = SQL_NUI & " DESC " & VbCrlf
		end if

		Session("SQL") = SQL_NUI
		arrNUI = GetArrayRS(SQL_NUI)
		
			if IsArray(arrNUI) then
				if arrNUI(1,0) <> "RESERVADO" then
					validado = true
				end if
			else
				validado = false
			end if
		end if 
		ValidarNUIApartado = validado
	end function
	
	function cleanApartaNUI(numClient)
	Dim SQL_Clean, rst_clean, arr_clean
	Dim i_clean, i_limit_inf, i_limit_sup
	
	'Tiempo en minutos:
	dim min_clean
		min_clean = "30"
		i_clean = 1000
		i_limit_inf = 2
		i_limit_sup = 58
	
	
	SQL_Clean = ""
	SQL_Clean = " SELECT TO_CHAR(SYSDATE,'MI') FROM DUAL " & VbCrlf
	Session("SQL") = SQL_Clean
	arr_clean = GetArrayRS(SQL_Clean)
		
	if IsArray(arr_clean) then
		if arr_clean(0,0) <> "" then
			i_clean = CDbl(arr_clean(0,0))
		end if
	end if
	
	SQL_Clean = ""
		SQL_Clean = "UPDATE WEB_LTL " & VbCrlf
		SQL_Clean = SQL_Clean & "   SET WELFACTURA = 'RESERVADO' " & VbCrlf
		SQL_Clean = SQL_Clean & " WHERE 1=1 " & VbCrlf
		SQL_Clean = SQL_Clean & "   AND WEL_CLICLEF = '" & numClient & "' " & VbCrlf
		SQL_Clean = SQL_Clean & "   AND UPPER(WELFACTURA) LIKE UPPER('APAR_%_TADO%') " & VbCrlf
		SQL_Clean = SQL_Clean & "   AND WELSTATUS = '3' " & VbCrlf
		SQL_Clean = SQL_Clean & "   AND UPPER(WELFACTURA) LIKE UPPER('APAR_%_TADO')" & VbCrlf
	SQL_Clean = SQL_Clean & "   AND WELCLAVE NOT IN (SELECT WELCLAVE" & VbCrlf
	SQL_Clean = SQL_Clean & "   	FROM WEB_LTL " & VbCrlf
	SQL_Clean = SQL_Clean & "   	WHERE 1=1 " & VbCrlf
	SQL_Clean = SQL_Clean & "   AND WELSTATUS = '3' " & VbCrlf
	SQL_Clean = SQL_Clean & "   AND DATE_CREATED >= (SYSDATE -" & min_clean & "/1440))" & VbCrlf
		
		Session("SQL") = SQL_Clean
		set rst_clean = Server.CreateObject("ADODB.Recordset")
		rst_clean.Open SQL_Clean, Connect(), 0, 1, 1
	end function
'CHG-DESA-04052023-01>>


function cliente_prepago(CliClef)
	Dim res, sqlPre, ArrPre, countPre, cveEmp
	res = false
	
	cveEmp = obtener_clave_empresa(CliClef)
	
	sqlPre = ""
	sqlPre = sqlPre & " SELECT	COUNT(*) CANTIDAD " & VbCrlf
	sqlPre = sqlPre & " FROM	ECREDIT CRE " & VbCrlf
	sqlPre = sqlPre & " WHERE	CRE.CRECLIENT		=	'" & CliClef & "' " & VbCrlf
	sqlPre = sqlPre & " 	AND	CRE.CRE_EMPCLAVE	=	'" & cveEmp & "' " & VbCrlf
	sqlPre = sqlPre & " 	AND	CRE.CREREGIME		=	8 " & VbCrlf
	
	Session("SQL") = sqlPre
	ArrPre = GetArrayRS(sqlPre)
	
	if IsArray(ArrPre) then
		countPre = CStr(ArrPre(0,0))
		
		if CDbl(countPre) > 0 then
			res = true
		end if
	end if
	
	cliente_prepago = res
end function


function cliente_cobrar_prepago(CliClef)
	Dim res, sqlCobPre, ArrCobPre, countCobPre
	res = false
	
	sqlCobPre = ""
	sqlCobPre = sqlCobPre & " SELECT	COUNT(*) CANTIDAD " & VbCrlf
	sqlCobPre = sqlCobPre & " FROM	ECLIENT CTE " & VbCrlf
	sqlCobPre = sqlCobPre & " 	INNER JOIN	ECLIENT_EMPRESA_TRADING LIGA	ON	CTE.CLICLEF		=	LIGA.CET_CLICLEF " & VbCrlf
	sqlCobPre = sqlCobPre & " 	INNER JOIN	EEMPRESAS EMP					ON	EMP.EMPCLAVE	=	LIGA.CET_EMPCLAVE " & VbCrlf
	sqlCobPre = sqlCobPre & " WHERE	1=1 " & VbCrlf
	
	'Todas las cuentas asignadas a la empresa 54 tendrán las opciones "por cobrar" y "prepagado":
	sqlCobPre = sqlCobPre & " 	AND	EMP.EMPCLAVE	IN	(54) " & VbCrlf
	
	sqlCobPre = sqlCobPre & " 	AND	CTE.CLICLEF		=	'" & CliClef & "' " & VbCrlf
	sqlCobPre = sqlCobPre & " ORDER	BY	1 " & VbCrlf
	
	Session("SQL") = sqlCobPre
	ArrCobPre = GetArrayRS(sqlCobPre)
	
	if IsArray(ArrCobPre) then
		countCobPre = CStr(ArrCobPre(0,0))
		
		if CDbl(countCobPre) > 0 then
			res = true
		end if
	end if
	
	cliente_cobrar_prepago = res
end function


function obtener_clave_empresa(CliClef)
	Dim sqlEmpresa, arrEmpresa, iCveEmpresa
	
	iCveEmpresa = -1
	
	sqlEmpresa = sqlEmpresa & " SELECT  CET_EMPCLAVE CVE_EMPRESA " & VbCrlf
	sqlEmpresa = sqlEmpresa & " FROM    ECLIENT_EMPRESA_TRADING LIGA " & VbCrlf
	sqlEmpresa = sqlEmpresa & " WHERE   1=1 " & VbCrlf
	sqlEmpresa = sqlEmpresa & " AND LIGA.CET_CLICLEF = '" & CliClef & "' " & VbCrlf
	
	Session("SQL") = sqlEmpresa
	arrEmpresa = GetArrayRS(sqlEmpresa)
	
	if IsArray(arrEmpresa) then
		iCveEmpresa = CDbl(arrEmpresa(0,0))
	end if
	
	obtener_clave_empresa = iCveEmpresa
end function


function cliente_con_seguro(CliClef)
	Dim res, sqlSeguro, arrSeguro, iCveEmpresa, iCCOClave
	
	res = false
	sqlSeguro = ""
	iCCOClave = -1
	
	iCveEmpresa = obtener_clave_empresa(CliClef)
		
	sqlSeguro = sqlSeguro & " SELECT	CCOCLAVE, CCO_CLICLEF, CCO_BPCCLAVE, CCO_YFOCLEF, CCO_DOUCLEF, CCO_CHOCLAVE, CCO_PARCLAVE " & VbCrlf
	sqlSeguro = sqlSeguro & " FROM	ECLIENT_APLICA_CONCEPTOS " & VbCrlf
	sqlSeguro = sqlSeguro & " WHERE	CCO_CLICLEF	=	'" & CliClef & "' /* CAMBIAR CLIENTE */ " & VbCrlf
	sqlSeguro = sqlSeguro & " 	AND	CCO_CLICLEF	NOT IN (9954,9955,9956,9910,9929) " & VbCrlf
	sqlSeguro = sqlSeguro & " 	AND	EXISTS	( " & VbCrlf
	sqlSeguro = sqlSeguro & " 					SELECT	NULL " & VbCrlf
	sqlSeguro = sqlSeguro & " 					FROM	EBASES_POR_CONCEPT " & VbCrlf
	sqlSeguro = sqlSeguro & " 					WHERE	BPCCLAVE	=	CCO_BPCCLAVE " & VbCrlf
	sqlSeguro = sqlSeguro & " 						AND	BPC_CHOCLAVE	IN	(	SELECT	CHOCLAVE " & VbCrlf
	sqlSeguro = sqlSeguro & " 													FROM	ECONCEPTOSHOJA " & VbCrlf
	sqlSeguro = sqlSeguro & " 													WHERE	CHOTIPOIE		=	'I' " & VbCrlf
	sqlSeguro = sqlSeguro & " 														AND	CHONUMERO		=	183 /* CONCEPTO SEGURO DE MERCANCÍA  / NO SE CAMBIA */ " & VbCrlf
	sqlSeguro = sqlSeguro & " 														AND	CHO_EMPCLAVE	=	'" & iCveEmpresa & "' /* CAMBIAR EMPRESA */ " & VbCrlf
	sqlSeguro = sqlSeguro & " 												) " & VbCrlf
	sqlSeguro = sqlSeguro & " 				) " & VbCrlf
	
	Session("SQL") = sqlSeguro
	arrSeguro = GetArrayRS(sqlSeguro)
	
	if IsArray(arrSeguro) then
		iCCOClave = CDbl(arrSeguro(0,0))
		
		if iCCOClave > 0 then
			res = true
		end if
	end if
	
	'cliente_con_seguro = res
	cliente_con_seguro = iCCOClave
end function


function obtener_distribuidor(CliClef)
	Dim res, sqlDis, arrDis
	
	sqlDis = ""
	sqlDis = sqlDis & " SELECT	DISTINCT DIS.DISCLEF " & VbCrlf
	sqlDis = sqlDis & " 		,INITCAP(DIS.DISNOM || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')') NOMBRE " & VbCrlf
	sqlDis = sqlDis & " 		,DIS.DISNUMERO " & VbCrlf
	sqlDis = sqlDis & " FROM	 EDISTRIBUTEUR DIS " & VbCrlf
	sqlDis = sqlDis & " 	INNER JOIN	ECIUDADES CIU				ON	CIU.VILCLEF		=	DIS.DISVILLE " & VbCrlf
	sqlDis = sqlDis & " 	INNER JOIN	EESTADOS EST				ON	EST.ESTESTADO	=	CIU.VIL_ESTESTADO " & VbCrlf
	sqlDis = sqlDis & " 	INNER JOIN	ELOGINCLIENTEDETALLE LCD	ON	DIS.DISCLEF		=	LCD.LCD_DISCLEF " & VbCrlf
	sqlDis = sqlDis & " WHERE	DIS.DISETAT		=	'A' " & VbCrlf
	sqlDis = sqlDis & " 	AND	LCD.LCD_CLICLEF	=	'" & CliClef & "' " & VbCrlf
	sqlDis = sqlDis & " ORDER BY 2 " & VbCrlf
	
	Session("SQL") = sqlDis
	arrDis = GetArrayRS(sqlDis)
	
	obtener_distribuidor = arrDis
end function


function obtener_distribuidor_x_cliente(CliClef)
	Dim res, sqlDis, arrDis
	
	sqlDis = ""
	sqlDis = sqlDis & " SELECT	 DIS.DISCLEF " & VbCrlf
	sqlDis = sqlDis & " 		,INITCAP(DIS.DISNOM || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')') NOMBRE " & VbCrlf
	sqlDis = sqlDis & " 		,DIS.DISNUMERO " & VbCrlf
	sqlDis = sqlDis & "  " & VbCrlf
	sqlDis = sqlDis & " FROM	 EDISTRIBUTEUR DIS " & VbCrlf
	sqlDis = sqlDis & " 	INNER JOIN	ECIUDADES CIU	ON	DIS.DISVILLE		=	CIU.VILCLEF " & VbCrlf
	sqlDis = sqlDis & " 	INNER JOIN	EESTADOS EST	ON	CIU.VIL_ESTESTADO	=	EST.ESTESTADO " & VbCrlf
	sqlDis = sqlDis & " WHERE	 DISCLIENT		IN	(" & CliClef & ") " & VbCrlf
	sqlDis = sqlDis & " 	AND	 DIS.DISETAT	=	'A' " & VbCrlf
	sqlDis = sqlDis & " 	AND	EST.EST_PAYCLEF	=	'N3' " & VbCrlf
	sqlDis = sqlDis & " ORDER	BY	DISNOM " & VbCrlf
	
	Session("SQL") = sqlDis
	arrDis = GetArrayRS(sqlDis)
	
	obtener_distribuidor_x_cliente = arrDis
end function


function obtener_remitentes(CliClef,DisClef)
	Dim res, sqlRemi, arrRemi
	
	sqlRemi = ""
	sqlRemi = sqlRemi & " SELECT	 DIS.DISCLEF " & VbCrlf
	sqlRemi = sqlRemi & " 		,INITCAP(DIS.DISNOM || ' - ' || CIU.VILNOM || ' (' || EST.ESTNOMBRE || ')') " & VbCrlf
	sqlRemi = sqlRemi & " 		,DECODE(DIS.DISCLEF, '" & DisClef & "', 'selected', NULL) " & VbCrlf
	sqlRemi = sqlRemi & " FROM	 EDISTRIBUTEUR DIS " & VbCrlf
	sqlRemi = sqlRemi & " 	INNER JOIN	ECIUDADES CIU	ON	DIS.DISVILLE		=	CIU.VILCLEF " & VbCrlf
	sqlRemi = sqlRemi & " 	INNER JOIN	EESTADOS EST	ON	CIU.VIL_ESTESTADO	=	EST.ESTESTADO " & VbCrlf
	sqlRemi = sqlRemi & " WHERE	 DISCLIENT		IN	(" & CliClef & ") " & VbCrlf
	sqlRemi = sqlRemi & " 	AND	 DIS.DISETAT	=	'A' " & VbCrlf

	if Session("ltl_internacional") = "1" then
		'agregar EEUU y Canada
		sqlRemi = sqlRemi & "	AND	EST.EST_PAYCLEF	IN	('N3', 'G8', 'D9', 'I6') " & VbCrlf
	else
		sqlRemi = sqlRemi & "	AND	EST.EST_PAYCLEF	=	'N3' " & VbCrlf
	end if

	sqlRemi = sqlRemi & " ORDER	BY	DISNOM " & VbCrlf
	
	Session("SQL") = sqlRemi
	arrRemi = GetArrayRS(sqlRemi)
	
	obtener_remitentes = arrRemi
end function


function obtener_remitente(mi_distclave)
	Dim res, sqlRemi, arrRemi
	
	sqlRemi = ""
	sqlRemi = sqlRemi & " SELECT	 InitCap(DIS.DISNOM) " & VbCrlf
	sqlRemi = sqlRemi & " 		,InitCap(VILNOM) " & VbCrlf
	sqlRemi = sqlRemi & " 		,InitCap(ESTNOMBRE) " & VbCrlf
	sqlRemi = sqlRemi & " 		,DIS.DISCLIENT " & VbCrlf
	sqlRemi = sqlRemi & " 		,DIS.DISCLEF " & VbCrlf
	sqlRemi = sqlRemi & " 		,VILCLEF " & VbCrlf
	sqlRemi = sqlRemi & " FROM	 EDISTRIBUTEUR DIS " & VbCrlf
	sqlRemi = sqlRemi & " 	INNER	JOIN	ECIUDADES VIL	ON	DIS.DISVILLE		=	VIL.VILCLEF " & VbCrlf
	sqlRemi = sqlRemi & " 	INNER	JOIN	EESTADOS EST	ON	VIL.VIL_ESTESTADO	=	EST.ESTESTADO " & VbCrlf
	sqlRemi = sqlRemi & " WHERE	1=1 " & VbCrlf

	if SQLEscape(mi_distclave) = "" then
		sqlRemi = sqlRemi & " 	AND	DIS.DISCLEF	=	'" & SQLEscape(Session("wel_disclef")) & "' " & VbCrlf
	else
		sqlRemi = sqlRemi & " 	AND	DIS.DISCLEF	=	'" & SQLEscape(mi_distclave) & "' " & VbCrlf
	end if
	
	Session("SQL") = sqlRemi
	arrRemi = GetArrayRS(sqlRemi)
	
	obtener_remitente = arrRemi
end function

function obtener_remitente_x_cliente(mi_cliclef)
		Dim res, sqlRemi, arrRemi
	
	sqlRemi = ""
	sqlRemi = sqlRemi & " SELECT	 InitCap(DIS.DISNOM) " & VbCrlf
	sqlRemi = sqlRemi & " 		,InitCap(VILNOM) " & VbCrlf
	sqlRemi = sqlRemi & " 		,InitCap(ESTNOMBRE) " & VbCrlf
	sqlRemi = sqlRemi & " 		,DIS.DISCLIENT " & VbCrlf
	sqlRemi = sqlRemi & " 		,DIS.DISCLEF " & VbCrlf
	sqlRemi = sqlRemi & " 		,VILCLEF " & VbCrlf
	sqlRemi = sqlRemi & " FROM	 EDISTRIBUTEUR DIS " & VbCrlf
	sqlRemi = sqlRemi & " 	INNER JOIN	ECIUDADES CIU	ON	DIS.DISVILLE		=	CIU.VILCLEF " & VbCrlf
	sqlRemi = sqlRemi & " 	INNER JOIN	EESTADOS EST	ON	CIU.VIL_ESTESTADO	=	EST.ESTESTADO " & VbCrlf
	sqlRemi = sqlRemi & " WHERE	 DISCLIENT		IN	(" & mi_cliclef & ") " & VbCrlf
	sqlRemi = sqlRemi & " 	AND	 DIS.DISETAT	=	'A' " & VbCrlf
	sqlRemi = sqlRemi & " 	AND	EST.EST_PAYCLEF	=	'N3' " & VbCrlf
	sqlRemi = sqlRemi & " ORDER	BY	DISNOM " & VbCrlf
	
	Session("SQL") = sqlRemi
	arrRemi = GetArrayRS(sqlRemi)
	
	obtener_remitente_x_cliente = arrRemi
end function

function obtener_cat_estados()
	Dim res, sqlEst, arrEst
	
	sqlEst = ""
	sqlEst = sqlEst & " SELECT	DISTINCT	ESTESTADO	,EST.ESTNOMBRE " & VbCrlf
	sqlEst = sqlEst & " FROM	ECLIENT_CLIENTE  CCL " & VbCrlf
	sqlEst = sqlEst & " 	INNER	JOIN	EDIRECCIONES_ENTREGA DIE	ON	CCL.CCLCLAVE		=	DIE.DIE_CCLCLAVE " & VbCrlf
	sqlEst = sqlEst & " 	INNER	JOIN	ECIUDADES CIU				ON	CCL.CCL_VILLE		=	CIU.VILCLEF " & VbCrlf
	sqlEst = sqlEst & " 	INNER	JOIN	EESTADOS EST				ON	CIU.VIL_ESTESTADO	=	EST.ESTESTADO " & VbCrlf
	sqlEst = sqlEst & " WHERE	CCL.CCL_STATUS	=	1 " & VbCrlf
	sqlEst = sqlEst & " 	AND	DIE.DIE_STATUS	=	1 " & VbCrlf
	sqlEst = sqlEst & " 	AND	EST.EST_PAYCLEF	=	'N3' " & VbCrlf
	sqlEst = sqlEst & " ORDER	BY	2 " & VbCrlf
	
	Session("SQL") = sqlEst
	arrEst = GetArrayRS(sqlEst)
	
	obtener_cat_estados = arrEst
end function


function validar_numero_recoleccion(DisClef,NumRecol)
	Dim res, sqlReco, arrReco
	
	sqlReco = ""
	sqlReco = sqlReco & " SELECT	TRACLAVE, TPI_MDECLAVE , TRA.* " & VbCrlf
	sqlReco = sqlReco & " FROM	ETRANSFERENCIA_TRADING TRA " & VbCrlf
	sqlReco = sqlReco & " 	INNER	JOIN	ETRANS_PICKING TPI		ON	TRA.TRACLAVE		=	TPI.TPI_TRACLAVE " & VbCrlf
	sqlReco = sqlReco & " 	INNER	JOIN	EDESTINOS_POR_RUTA DER 	ON	TRA.TRA_ALLCLAVE	=	DER.DER_ALLCLAVE " & VbCrlf
	sqlReco = sqlReco & " 	INNER	JOIN	EDISTRIBUTEUR DIS		ON	TRA.TRA_CLICLEF		=	DIS.DISCLIENT	AND	DER.DER_VILCLEF	=	DIS.DISVILLE " & VbCrlf
	sqlReco = sqlReco & " WHERE	TRACONS_GENERAL			=	'" & NumRecol & "' " & VbCrlf
	sqlReco = sqlReco & " 	AND	DIS.DISCLEF				=	'" & DisClef & "' " & VbCrlf
	sqlReco = sqlReco & " 	AND	TRA.TRASTATUS			=	'1' " & VbCrlf
	sqlReco = sqlReco & " 	AND	TRA.TRA_MEZTCLAVE_ORI	=	0 " & VbCrlf
	sqlReco = sqlReco & " 	AND	TRA.TRA_MEZTCLAVE_DEST	=	2 " & VbCrlf
	
	Session("SQL") = sqlReco
	arrReco = GetArrayRS(sqlReco)
	
	validar_numero_recoleccion = arrReco
end function


function validar_expedicion_recoleccion(TraClave)
	Dim res, sqlReco, arrReco
	
	sqlReco = ""
	sqlReco = sqlReco & " SELECT	DXP.DXPCLAVE " & VbCrlf
	sqlReco = sqlReco & " FROM	EDET_EXPEDICIONES DXP " & VbCrlf
	sqlReco = sqlReco & " WHERE	DPX.DXP_TRACLAVE		=	'" & TraClave & "' " & VbCrlf
	sqlReco = sqlReco & " 	AND	DXP.DXP_TIPO_ENTREGA	IN	('RECOLECCION', 'RECOL. DEVOLUCION') " & VbCrlf
	
	Session("SQL") = sqlReco
	arrReco = GetArrayRS(sqlReco)
	
	validar_numero_recoleccion = arrReco
end function


function cdad_entradas_recoleccion(DxpClave)
	Dim res, sqlEnt, arrEnt
	
	sqlEnt = ""
	sqlEnt = sqlEnt & " SELECT	SUM(CDAD) " & VbCrlf
	sqlEnt = sqlEnt & " FROM " & VbCrlf
	sqlEnt = sqlEnt & " 	( " & VbCrlf
	sqlEnt = sqlEnt & " 		SELECT	COUNT(0) CDAD " & VbCrlf
	sqlEnt = sqlEnt & " 		FROM	ETRANS_ENTRADA TAE " & VbCrlf
	sqlEnt = sqlEnt & " 			INNER	JOIN	ETRANSFERENCIA_TRADING TRA	ON	TAE.TAE_TRACLAVE	=	TRA.TRACLAVE " & VbCrlf
	sqlEnt = sqlEnt & " 		WHERE	TAE.TAE_DXPCLAVE	=	'" & DxpClave & "' " & VbCrlf
	sqlEnt = sqlEnt & " 			AND	TRA.TRASTATUS		=	'1' " & VbCrlf
	sqlEnt = sqlEnt & " 		UNION ALL " & VbCrlf
	sqlEnt = sqlEnt & " 		SELECT	COUNT(0) " & VbCrlf
	sqlEnt = sqlEnt & " 		FROM	ETRANS_DETALLE_CROSS_DOCK TDCD " & VbCrlf
	sqlEnt = sqlEnt & " 			INNER	JOIN	ETRANSFERENCIA_TRADING TRA	ON	TDCD.TDCD_TRACLAVE	=	TRA.TRACLAVE " & VbCrlf
	sqlEnt = sqlEnt & " 		WHERE	TDCD.TDCD_DXPCLAVE_ORI	=	'" & DxpClave & "' " & VbCrlf
	sqlEnt = sqlEnt & " 			AND	TDCD.TDCDSTATUS			=	'1' " & VbCrlf
	sqlEnt = sqlEnt & " 			AND	TRA.TRASTATUS			=	'1' " & VbCrlf
	sqlEnt = sqlEnt & " 	) " & VbCrlf
	
	Session("SQL") = sqlEnt
	arrEnt = GetArrayRS(sqlEnt)
	
	cdad_entradas_recoleccion = arrEnt
end function


function validar_recoleccion_distribuidor(DxpClave,DisClef)
	Dim res, sqlReco, arrReco
	
	sqlReco = ""
	sqlReco = sqlReco & " SELECT	COUNT(0) " & VbCrlf
	sqlReco = sqlReco & " FROM	WEB_LTL WEL " & VbCrlf
	sqlReco = sqlReco & " 	INNER	JOIN	EDISTRIBUTEUR DIS	ON	WEL.WEL_CLICLEF	=	DIS.DISCLIENT " & VbCrlf
	sqlReco = sqlReco & " WHERE	WEL.WEL_DXPCLAVE_RECOL	=	'" & DxpClave & "' " & VbCrlf
	sqlReco = sqlReco & " 	AND	WEL.WEL_DISCLEF	=	'" & DisClef & "' " & VbCrlf
	sqlReco = sqlReco & " 	AND	WEL.WELSTATUS	=	1 " & VbCrlf
	
	Session("SQL") = sqlReco
	arrReco = GetArrayRS(sqlReco)
	
	validar_recoleccion_distribuidor = arrReco
end function


function obtener_nui_disponible_cliente(CliClef)
	Dim res, sqlNui, arrNui
	
	sqlNui = ""
	
	if CliClef = "20123" then
		sqlNui = sqlNui & " SELECT	NVL(MAX(WEL.WELCLAVE),0) " & VbCrlf
	else
		sqlNui = sqlNui & " SELECT	NVL(MIN(WEL.WELCLAVE),0) " & VbCrlf
	end if
	sqlNui = sqlNui & " FROM	WEB_LTL WEL " & VbCrlf
	sqlNui = sqlNui & " WHERE	UPPER(WEL.WELFACTURA)	IN	('RESERVADO','APAR_" & SQLEscape(request.serverVariables("REMOTE_ADDR")) & "_TADO') " & VbCrlf
	sqlNui = sqlNui & " 	AND	WEL.WEL_CLICLEF	=	'" & CliClef & "' " & VbCrlf
	sqlNui = sqlNui & " 	AND	WEL.WELSTATUS	=	3 " & VbCrlf
	
	Session("SQL") = sqlNui
	arrNui = GetArrayRS(sqlNui)
	
	obtener_nui_disponible_cliente = arrNui
end function


function obtener_info_manifiesto(CliClef,ManifNum,ManifCorte)
	Dim res, sqlManif, arrManif
	
	sqlManif = ""
	sqlManif = sqlManif & " SELECT	DISTINCT	 WEL_MANIF_NUM " & VbCrlf
	sqlManif = sqlManif & " 					,TO_CHAR(WEL_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI') " & VbCrlf
	sqlManif = sqlManif & " 					,InitCap(DISNOM) " & VbCrlf
	sqlManif = sqlManif & " 					,InitCap(VILNOM) " & VbCrlf
	sqlManif = sqlManif & " 					,InitCap(ESTNOMBRE) " & VbCrlf
	sqlManif = sqlManif & " 					,WEL_CLICLEF " & VbCrlf
	sqlManif = sqlManif & " 					,WEL_DISCLEF " & VbCrlf
	sqlManif = sqlManif & " 					,TO_CHAR(WEL_MANIF_FECHA, 'DD/MM/YYYY HH24:MI') " & VbCrlf
	sqlManif = sqlManif & " 					,WEL_MANIF_CORTE " & VbCrlf
	sqlManif = sqlManif & " 					,VILCLEF " & VbCrlf
	sqlManif = sqlManif & " FROM	WEB_LTL WEL " & VbCrlf
	sqlManif = sqlManif & " 	INNER	JOIN	EDISTRIBUTEUR DIS	ON	WEL.WEL_DISCLEF		=	DIS.DISCLEF " & VbCrlf
	sqlManif = sqlManif & " 	INNER	JOIN	ECIUDADES VIL		ON	DIS.DISVILLE		=	VIL.VILCLEF " & VbCrlf
	sqlManif = sqlManif & " 	INNER	JOIN	EESTADOS EST		ON	VIL.VIL_ESTESTADO	=	EST.ESTESTADO " & VbCrlf
	sqlManif = sqlManif & " WHERE	WEL.WEL_MANIF_NUM	=	'" & SQLEscape(ManifNum) & "' " & VbCrlf
	sqlManif = sqlManif & " 	AND	WEL.WEL_CLICLEF		IN	(" & SQLEscape(CliClef) & ") " & VbCrlf

	if ManifCorte <> "" and ManifCorte <> "0" then
		sqlManif = sqlManif & " 	AND	WEL.WEL_MANIF_CORTE	=	'" & SQLEscape(ManifCorte) & "' " & VbCrlf
	end if
	
	Session("SQL") = sqlManif
	arrManif = GetArrayRS(sqlManif)
	
	obtener_info_manifiesto = arrManif
end function


function obtener_destino_por_ciudad(VilClef)
	Dim res, sqlDest, arrDest
	
	sqlDest = ""
	sqlDest = sqlDest & " SELECT	DER.DER_ALLCLAVE " & VbCrlf
	sqlDest = sqlDest & " FROM		EDESTINOS_POR_RUTA DER " & VbCrlf
	sqlDest = sqlDest & " WHERE		DER.DER_VILCLEF	=	'" & VilClef & "' " & VbCrlf
	
	Session("SQL") = sqlDest
	arrDest = GetArrayRS(sqlDest)
	
	obtener_destino_por_ciudad = arrDest
end function


function obtener_cedis_por_remitente(DisClef)
	Dim res, sqlCedis, arrCedis
	
	sqlCedis = ""
	sqlCedis = sqlCedis & " SELECT	DER_ALLCLAVE " & vbCrLf
	sqlCedis = sqlCedis & " FROM	EDESTINOS_POR_RUTA DER " & vbCrLf
	sqlCedis = sqlCedis & " 	INNER	JOIN	EDISTRIBUTEUR DIS	ON	DER.DER_VILCLEF	=	DIS.DISVILLE " & vbCrLf
	sqlCedis = sqlCedis & " WHERE	DIS.DISCLEF			=	'" & SQLEscape(DisClef) & "' " & vbCrLf
	sqlCedis = sqlCedis & " 	AND	DER.DER_ALLCLAVE	>	0 " & vbCrLf
	
	Session("SQL") = sqlCedis
	arrCedis = GetArrayRS(sqlCedis)
	
	obtener_cedis_por_remitente = arrCedis
end function


function obtener_cedis_por_remitente_forzado(DisClef)
	Dim res, sqlCedis, arrCedis
	
	sqlCedis = ""
	sqlCedis = sqlCedis & " SELECT	DIS.DIS_ALLCLAVE " & vbCrLf
	sqlCedis = sqlCedis & " FROM	EDISTRIBUTEUR DIS " & vbCrLf
	sqlCedis = sqlCedis & " WHERE	DIS.DISCLEF			=	'" & DisClef & "' " & vbCrLf
	sqlCedis = sqlCedis & " 	AND	DIS.DIS_ALLCLAVE	IS	NOT	NULL " & vbCrLf
	
	Session("SQL") = sqlCedis
	arrCedis = GetArrayRS(sqlCedis)
	
	obtener_cedis_por_remitente_forzado = arrCedis
end function


function valida_cliente_regimen_8(CliClef)
	Dim res, sqlReg, arrReg
	
	sqlReg = ""
	sqlReg = sqlReg & " SELECT	COUNT(0) " & vbCrLf
	sqlReg = sqlReg & " FROM	ECREDIT CRE " & vbCrLf
	sqlReg = sqlReg & " WHERE	CRE.CRECLIENT		=	'" & SQLEscape(CliClef) & "' " & vbCrLf
	sqlReg = sqlReg & " 	AND	CRE.CRE_EMPCLAVE	IN	(10, 28, 54) " & vbCrLf
	sqlReg = sqlReg & " 	AND	CRE.CREREGIME		=	8 " & vbCrLf
	
	Session("SQL") = sqlReg
	arrReg = GetArrayRS(sqlReg)
	
	valida_cliente_regimen_8 = arrReg
end function


function obtiene_saldo_monedero_electronico(CliClef)
	Dim res, sqlMec, arrMec
	
	sqlMec = ""
	sqlMec = sqlMec & " SELECT	'$' || TO_CHAR(NVL(SUM(MEC.MECSALDO_REMANENTE), 0), 'FM999,999,990.00') " & vbCrLf
	sqlMec = sqlMec & " FROM	EMONEDERO_ELECTRONICO MEC " & vbCrLf
	sqlMec = sqlMec & " WHERE	MEC.MEC_CLICLEF	IN	(" & SQLEscape(CliClef) & ") " & vbCrLf
	sqlMec = sqlMec & " 	AND	MEC.MECSTATUS	=	1 " & vbCrLf
	
	Session("SQL") = sqlMec
	arrMec = GetArrayRS(sqlMec)
	
	obtiene_saldo_monedero_electronico = arrMec
end function
function consulta_cte_monedero_electronico(welclave)
	Dim res, sqlMec, arrMec
	
	sqlMec = ""
	sqlMec = sqlMec & " SELECT	COUNT(0) " & vbCrLf
	sqlMec = sqlMec & " FROM	WEB_LTL " & vbCrLf
	sqlMec = sqlMec & " WHERE	WELCLAVE	=	'" & SQLEscape(welclave) & "'" & vbCrLf
	sqlMec = sqlMec & " 	AND	WEL_COLLECT_PREPAID	=	'PREPAGADO' " & vbCrLf
	sqlMec = sqlMec & " 	AND	EXISTS	( " & vbCrLf
	sqlMec = sqlMec & " 					SELECT	NULL " & vbCrLf
	sqlMec = sqlMec & " 					FROM	ECREDIT " & vbCrLf
	sqlMec = sqlMec & " 					WHERE	CRECLIENT		=	WEL_CLICLEF " & vbCrLf
	sqlMec = sqlMec & "							AND	CRE_EMPCLAVE	=	GET_EMPRESA_TRADING(CRECLIENT) " & vbCrLf
	sqlMec = sqlMec & " 						AND	CREREGIME		=	8 " & vbCrLf
	sqlMec = sqlMec & " 				) " & vbCrLf
	
	Session("sqlME") = Session("sqlME") & sqlMec
	Session("SQL") = sqlMec
	arrMec = GetArrayRS(sqlMec)
	
	consulta_cte_monedero_electronico = arrMec
end function
function asignaEstatusMonederoElect_SinSaldo(nui)
	Dim res, cteME, saldME, sqlME, arrME, rst_ME
	
	sqlME = ""
	arrME = consulta_cte_monedero_electronico(nui)
	
	If IsArray(arrME) Then
		If arrME(0,0) <> "" And arrME(0,0) <> "0" Then
			'Si es cliente monedero podemos continuar:
			If CDbl(arrME(0,0)) > 0 Then
				'Obtenemos la clave de cliente:
				cteME = obtiene_cliente_x_nui(nui)
				
				'Consultamos el saldo disponible del cliente:
				saldME = obtieneSaldoMonederoElectronicoNUM(cteME)
				
				If CDbl(saldME) <= 0 Then
					'No tiene saldo, colocamos el NUI en StandBy:
					sqlME = sqlME & " UPDATE	WEB_LTL " & vbCrLf
					sqlME = sqlME & " 	SET		WELSTATUS	=	2 " & vbCrLf
					sqlME = sqlME & " WHERE		WELCLAVE	=	'" & nui & "' " & vbCrLf
				
					'<<<<2024-08-01: Se agrega registro en log de queries:
						registraLog_subproceso "5", sqlME
					'    2024-08-01>>>>
					Session("SQL") = sqlME
					Session("sqlME") = Session("sqlME") & sqlME
					set rst_ME = Server.CreateObject("ADODB.Recordset")
					rst_ME.Open sqlME, Connect(), 0, 1, 1
					'<<<<2024-08-01: Se agrega registro en log de queries:
						registraLog_subproceso "5", "ejecutado"
					'    2024-08-01>>>>
				End If
			End If
		End If
	End If
end function
function obtieneSaldoMonederoElectronicoNUM(cliclef)
	Dim res, sqlSaldMec, arrSaldMec, saldMec
	
	saldMec = 0
	sqlSaldMec = ""
	
	sqlSaldMec = sqlSaldMec & "SELECT	NVL(SUM(MEC.MECSALDO_REMANENTE), 0) SALDO " & vbCrLf
	sqlSaldMec = sqlSaldMec & "FROM		EMONEDERO_ELECTRONICO MEC " & vbCrLf
	sqlSaldMec = sqlSaldMec & "WHERE	MEC.MEC_CLICLEF	=	'" & cliclef & "' " & vbCrLf
	sqlSaldMec = sqlSaldMec & "	AND		MEC.MECSTATUS	=	1 " & vbCrLf
	
	Session("SQL") = sqlSaldMec
	Session("sqlME") = Session("sqlME") & sqlSaldMec
	arrSaldMec = GetArrayRS(sqlSaldMec)
	
	If IsArray(arrSaldMec) Then
		If arrSaldMec(0,0) <> "" Then
			saldMec = CDbl(arrSaldMec(0,0))
		End If
	End If
	
	obtieneSaldoMonederoElectronicoNUM = saldMec
end function
function obtiene_cliente_x_nui(NUI)
	Dim sqlNui, arrNui, cliNui
	
	sqlNui = ""
	cliNui = "-1"
	sqlNui = sqlNui & " SELECT	WEL.WEL_CLICLEF " & vbCrLf
	sqlNui = sqlNui & " FROM	WEB_LTL WEL " & vbCrLf
	sqlNui = sqlNui & " WHERE	WEL.WELCLAVE	=	'" & NUI & "' " & vbCrLf
	
	Session("SQL") = sqlNui
	Session("sqlME") = Session("sqlME") & sqlNui
	arrNui = GetArrayRS(sqlNui)
	
	If IsArray(arrNui) Then
		cliNui = arrNui(0,0)
	End If
	
	obtiene_cliente_x_nui = cliNui
end function

function obtiene_talon_x_nui(WelClave)
	Dim res, sqlNui, arrNui
	
	sqlNui = ""
	sqlNui = sqlNui & " SELECT	WEL.WEL_TALON_RASTREO " & vbCrLf
	sqlNui = sqlNui & " FROM	WEB_LTL WEL " & vbCrLf
	sqlNui = sqlNui & " WHERE	WEL.WELCLAVE	=	'" & WelClave & "' " & vbCrLf
	
	Session("SQL") = sqlNui
	arrNui = GetArrayRS(sqlNui)
	
	obtiene_talon_x_nui = arrNui
end function


function obtiene_talones_x_manifiesto(CliClef,WelManifNum,WelManifCorte)
	Dim res, sqlTal, arrTal
	
	sqlTal = ""
	sqlTal = sqlTal & " SELECT	 WEL.WELCLAVE " & vbCrLf
	sqlTal = sqlTal & " 		,TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) " & vbCrLf
	sqlTal = sqlTal & " 		/*,WEL.WELFACTURA REFERENCIA*/ " & vbCrLf
	sqlTal = sqlTal & " 		,WEL.WEL_CDAD_BULTOS " & vbCrLf
	sqlTal = sqlTal & " 		,WEL.WEL_MANIF_NUM " & vbCrLf
	sqlTal = sqlTal & " 		,InitCap(WCCL.WCCL_NOMBRE) " & vbCrLf
	sqlTal = sqlTal & " 		,InitCap(VIL.VILNOM) " & vbCrLf
	sqlTal = sqlTal & " 		,InitCap(EST.ESTNOMBRE) " & vbCrLf
	sqlTal = sqlTal & " 		,DECODE(WEL.WEL_COLLECT_PREPAID, 'PREPAGADO', 'Prep', 'COD') " & vbCrLf
	sqlTal = sqlTal & " 		,AL.ALLCODIGO  " & vbCrLf
	
	if es_captura_con_doc_fuente(CliClef) = true then
		sqlTal = sqlTal & "		,REPLACE(LISTAGG(FD.NO_FACTURA, ',') WITHIN GROUP (ORDER BY FD.NO_FACTURA),' ,','') NO_FACTURA " & vbCrLf
		sqlTal = sqlTal & "		,LISTAGG(FD.DOCUMENTO_FUENTE, ',') WITHIN GROUP (ORDER BY FD.DOCUMENTO_FUENTE) DOCUMENTO_FUENTE " & vbCrLf
	elseif es_captura_con_factura(CliClef) = true then
		sqlTal = sqlTal & "		,LISTAGG(FD.NO_FACTURA, ',') WITHIN GROUP (ORDER BY FD.NO_FACTURA) NO_FACTURA " & vbCrLf
		sqlTal = sqlTal & "		,'' DOCUMENTO_FUENTE " & vbCrLf
	else
		sqlTal = sqlTal & "		,'' NO_FACTURA " & vbCrLf
		sqlTal = sqlTal & "		,'' DOCUMENTO_FUENTE " & vbCrLf
	end if
	
	sqlTal = sqlTal & " FROM	WEB_LTL WEL " & vbCrLf
	sqlTal = sqlTal & " 	INNER	JOIN	WEB_CLIENT_CLIENTE WCCL	ON	WEL.WEL_WCCLCLAVE		=	WCCL.WCCLCLAVE " & vbCrLf
	sqlTal = sqlTal & " 	INNER	JOIN	ECIUDADES VIL			ON	WCCL.WCCL_VILLE			=	VIL.VILCLEF " & vbCrLf
	sqlTal = sqlTal & " 	INNER	JOIN	EESTADOS EST			ON	VIL.VIL_ESTESTADO		=	EST.ESTESTADO " & vbCrLf
	sqlTal = sqlTal & " 	INNER	JOIN	EALMACENES_LOGIS AL		ON	WEL.WEL_ALLCLAVE_DEST	=	AL.ALLCLAVE " & vbCrLf
	
	if es_captura_con_doc_fuente(CliClef) = true or es_captura_con_factura(CliClef) = true then
		sqlTal = sqlTal & " 	LEFT JOIN	EFACTURAS_DOC FD			ON	WEL.WELCLAVE			=	FD.NUI " & vbCrLf
	end if
	
	sqlTal = sqlTal & " WHERE	WEL.WEL_MANIF_NUM	= 	'" & WelManifNum  & "' " & vbCrLf
	sqlTal = sqlTal & " 	AND	WEL.WEL_CLICLEF		=	'" & CliClef & "' " & vbCrLf

	if WelManifCorte <> "" then
		sqlTal = sqlTal & " 	AND	NVL(WEL.WEL_MANIF_CORTE, -1)	=	NVL('" & WelManifCorte & "', -1) " & vbCrLf
	end if
	
	sqlTal = sqlTal & " group by WEL.WELCLAVE " & vbCrLf
	sqlTal = sqlTal & " ,TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) " & vbCrLf
	sqlTal = sqlTal & " /*,WEL.WELFACTURA*/ " & vbCrLf
	sqlTal = sqlTal & " ,WEL.WEL_CDAD_BULTOS " & vbCrLf
	sqlTal = sqlTal & " ,WEL.WEL_MANIF_NUM " & vbCrLf
	sqlTal = sqlTal & " ,InitCap(WCCL.WCCL_NOMBRE) " & vbCrLf
	sqlTal = sqlTal & " ,InitCap(VIL.VILNOM) " & vbCrLf
	sqlTal = sqlTal & " ,InitCap(EST.ESTNOMBRE) " & vbCrLf
	sqlTal = sqlTal & " ,DECODE(WEL.WEL_COLLECT_PREPAID, 'PREPAGADO', 'Prep', 'COD') " & vbCrLf
	sqlTal = sqlTal & " ,AL.ALLCODIGO " & vbCrLf

	sqlTal = sqlTal & " UNION " & vbCrLf
	sqlTal = sqlTal & " SELECT	 WEL.WELCLAVE " & vbCrLf
	sqlTal = sqlTal & " 		,TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) " & vbCrLf
	sqlTal = sqlTal & " 		/*,WEL.WELFACTURA REFERENCIA*/ " & vbCrLf
	sqlTal = sqlTal & " 		,WEL.WEL_CDAD_BULTOS " & vbCrLf
	sqlTal = sqlTal & " 		,WEL.WEL_MANIF_NUM " & vbCrLf
	sqlTal = sqlTal & " 		,InitCap(DIE.DIENOMBRE) " & vbCrLf
	sqlTal = sqlTal & " 		,InitCap(VIL.VILNOM) " & vbCrLf
	sqlTal = sqlTal & " 		,InitCap(EST.ESTNOMBRE) " & vbCrLf
	sqlTal = sqlTal & " 		,DECODE(WEL.WEL_COLLECT_PREPAID, 'PREPAGADO', 'Prep', 'COD') " & vbCrLf
	sqlTal = sqlTal & " 		,AL.ALLCODIGO " & vbCrLf
	
	if es_captura_con_doc_fuente(CliClef) = true then
		sqlTal = sqlTal & "		,REPLACE(LISTAGG(FD.NO_FACTURA, ',') WITHIN GROUP (ORDER BY FD.NO_FACTURA),' ,','') NO_FACTURA " & vbCrLf
		sqlTal = sqlTal & "		,LISTAGG(FD.DOCUMENTO_FUENTE, ',') WITHIN GROUP (ORDER BY FD.DOCUMENTO_FUENTE) DOCUMENTO_FUENTE " & vbCrLf
	elseif es_captura_con_factura(CliClef) = true then
		sqlTal = sqlTal & "		,LISTAGG(FD.NO_FACTURA, ',') WITHIN GROUP (ORDER BY FD.NO_FACTURA) NO_FACTURA " & vbCrLf
		sqlTal = sqlTal & "		,'' DOCUMENTO_FUENTE " & vbCrLf
	else
		sqlTal = sqlTal & "		,'' NO_FACTURA " & vbCrLf
		sqlTal = sqlTal & "		,'' DOCUMENTO_FUENTE " & vbCrLf
	end if
	
	sqlTal = sqlTal & " FROM	WEB_LTL WEL " & vbCrLf
	sqlTal = sqlTal & " 	INNER	JOIN	EDIRECCIONES_ENTREGA DIE	ON	WEL.WEL_DIECLAVE		=	DIE.DIECLAVE " & vbCrLf
	sqlTal = sqlTal & " 	INNER	JOIN	ECIUDADES VIL				ON	DIE.DIEVILLE			=	VIL.VILCLEF " & vbCrLf
	sqlTal = sqlTal & " 	INNER	JOIN	EESTADOS EST				ON	VIL.VIL_ESTESTADO		=	EST.ESTESTADO " & vbCrLf
	sqlTal = sqlTal & " 	INNER	JOIN	EALMACENES_LOGIS AL			ON	WEL.WEL_ALLCLAVE_DEST	=	AL.ALLCLAVE " & vbCrLf
	
	if es_captura_con_doc_fuente(CliClef) = true or es_captura_con_factura(CliClef) = true then
		sqlTal = sqlTal & " 	LEFT JOIN	EFACTURAS_DOC FD			ON	WEL.WELCLAVE			=	FD.NUI " & vbCrLf
	end if
	
	sqlTal = sqlTal & " WHERE	WEL.WEL_MANIF_NUM	=	'" & WelManifNum  & "' " & vbCrLf
	sqlTal = sqlTal & " 	AND	WEL.WEL_CLICLEF		=	'" & CliClef & "' " & vbCrLf
	sqlTal = sqlTal & " 	AND	DIE.DIE_STATUS		=	1 " & vbCrLf

	if WelManifCorte <> "" then
		sqlTal = sqlTal & " 	AND	NVL(WEL_MANIF_CORTE, -1)	=	NVL('" & WelManifCorte & "', -1) " & vbCrLf
	end if
	
	sqlTal = sqlTal & " GROUP BY WEL.WELCLAVE " & vbCrLf
	sqlTal = sqlTal & " ,TO_CHAR(WEL.WELCONS_GENERAL, 'FM0000000') || '-' || GET_CLI_ENMASCARADO(WEL.WEL_CLICLEF) " & vbCrLf
	sqlTal = sqlTal & " /*		,WEL.WELFACTURA*/ " & vbCrLf
	sqlTal = sqlTal & " ,WEL.WEL_CDAD_BULTOS " & vbCrLf
	sqlTal = sqlTal & " ,WEL.WEL_MANIF_NUM " & vbCrLf
	sqlTal = sqlTal & " ,InitCap(DIE.DIENOMBRE) " & vbCrLf
	sqlTal = sqlTal & " ,InitCap(VIL.VILNOM) " & vbCrLf
	sqlTal = sqlTal & " ,InitCap(EST.ESTNOMBRE) " & vbCrLf
	sqlTal = sqlTal & " ,DECODE(WEL.WEL_COLLECT_PREPAID, 'PREPAGADO', 'Prep', 'COD') " & vbCrLf
	sqlTal = sqlTal & " ,AL.ALLCODIGO " & vbCrLf
	
	'response.write Replace(sqlTal,vbCrLf,"<br>")
	Session("SQL") = sqlTal
	arrTal = GetArrayRS(sqlTal)
	
	obtiene_talones_x_manifiesto = arrTal
end function


function obtiene_cambia_ciudad(CliClef)
	Dim res, sqlCambia, arrCambia
	
	sqlCambia = ""
	sqlCambia = sqlCambia & " SELECT	SIGN(TO_DATE(LOGIS.FEC_INI_DIE_LTL(),'DD/MM/YY')-SYSDATE) " & vbCrLf
	sqlCambia = sqlCambia & " FROM		DUAL " & vbCrLf
	
	Session("SQL") = sqlCambia
	arrCambia = GetArrayRS(sqlCambia)
	
	obtiene_cambia_ciudad = arrCambia
end function


function forzar_remisiones_usuario(CliClef)
	Dim res, sqlForza, arrForza
	
	sqlForza = ""
	sqlForza = sqlForza & " SELECT	COUNT(0) " & VbCrlf
	sqlForza = sqlForza & " FROM ECLIENT_MODALIDADES CLM " & VbCrlf
	sqlForza = sqlForza & " WHERE	CLM.CLM_CLICLEF	=	'" & CliClef & "' " & VbCrlf
	sqlForza = sqlForza & " /*	24  FORZAR LA CAPTURA DE CANTIDAD DE REMISIONES (LTL)  NICOLAST  03/08/11  (null)  (null)  1	*/ " & VbCrlf
	sqlForza = sqlForza & " 	AND	CLM.CLM_MOECLAVE	=	24 " & VbCrlf
	
	Session("SQL") = sqlForza
	arrForza = GetArrayRS(sqlForza)
	
	forzar_remisiones_usuario = arrForza
end function


function obtiene_ciudades_con_cedis(CliClef)
	Dim res, sqlCiudades, arrCiudades
	
	sqlCiudades = ""
	sqlCiudades = sqlCiudades & " SELECT	 /*+ordered index(EST I_EST_PAYCLEF) index(CIU I_VIL_ESTESTADO) index(DER IDX_DER_VILCLEF) use_nl(EST CIU DER)*/ " & VbCrlf
	sqlCiudades = sqlCiudades & " 		 EST.ESTESTADO " & VbCrlf
	sqlCiudades = sqlCiudades & " 		,InitCap(EST.ESTNOMBRE) " & VbCrlf
	sqlCiudades = sqlCiudades & " 		,CIU.VILCLEF " & VbCrlf
	sqlCiudades = sqlCiudades & " 		,InitCap(CIU.VILNOM) " & VbCrlf
	sqlCiudades = sqlCiudades & " FROM	 EESTADOS EST " & VbCrlf
	sqlCiudades = sqlCiudades & " 	INNER	JOIN	ECIUDADES CIU			ON	EST.ESTESTADO	=	CIU.VIL_ESTESTADO " & VbCrlf
	sqlCiudades = sqlCiudades & " 	INNER	JOIN	EDESTINOS_POR_RUTA DER	ON	DER.DER_VILCLEF	=	CIU.VILCLEF " & VbCrlf
	sqlCiudades = sqlCiudades & " WHERE	EST.EST_PAYCLEF		=	'N3' " & VbCrlf
	sqlCiudades = sqlCiudades & " 	AND	DER.DER_ALLCLAVE	>	0 " & VbCrlf
	sqlCiudades = sqlCiudades & " 	AND	NVL(DER.DER_TIPO_ENTREGA, 'FORANEO 6')	<>	'FORANEO 6' " & VbCrlf
	sqlCiudades = sqlCiudades & " ORDER	BY	CIU.VILNOM " & VbCrlf
	
	Session("SQL") = sqlCiudades
	arrCiudades = GetArrayRS(sqlCiudades)
	
	obtiene_ciudades_con_cedis = arrCiudades
end function


function obtiene_tipo_bultos(CliClef)
	Dim res, sqlTipoBulto, arrTipoBulto
	
	sqlTipoBulto = ""
	sqlTipoBulto = sqlTipoBulto & " SELECT	TPA.TPACLAVE, " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " 		(DECODE(TPA.TPACLAVE,9,'Cajas o asmimilables',InitCap(NVL(TPA.TPADESCRIPCION_WEB,TPA.TPADESCRIPCION)))), " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " 		DECODE(TPA.TPACLAVE, 9, 'selected', NULL) " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " FROM	ETIPOS_PALETA TPA " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " WHERE	TPA.TPA_STCCLAVE	IS	NULL " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " 	AND	TPA.TPACLAVE		=	9 " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " UNION " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " SELECT	TPA.TPACLAVE, " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " 		(DECODE(TPA.TPACLAVE,9,'Cajas o asmimilables',InitCap(NVL(TPA.TPADESCRIPCION_WEB,TPA.TPADESCRIPCION)))), " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " 		DECODE(TPACLAVE, 9, 'selected', NULL) " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " FROM	ETIPOS_PALETA TPA " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " WHERE	TPA.TPA_STCCLAVE	IS	NULL " & VbCrlf
	sqlTipoBulto = sqlTipoBulto & " 	AND	NVL(TPA.TPAWEB,'N')	=	'S' " & VbCrlf
	
	if (CDbl(CliClef) >= 9900 and CDbl(CliClef) <= 9999) Or CDbl(CliClef) = 20123 then
		sqlTipoBulto = sqlTipoBulto & " 	AND	TPA.TPACLAVE		IN	(9,12) " & VbCrlf
	else
		sqlTipoBulto = sqlTipoBulto & " 	AND	TPA.TPACLAVE		=	9 " & VbCrlf
	end if
	
	sqlTipoBulto = sqlTipoBulto & " ORDER	BY	2 " & VbCrlf
	
	Session("SQL") = sqlTipoBulto
	arrTipoBulto = GetArrayRS(sqlTipoBulto)
	
	obtiene_tipo_bultos = arrTipoBulto
end function


function obtener_fecha_actual(formato)
	Dim res, sqlFecha, arrFecha
	
	if formato = "" then
		formato = "DD/MM/YYYY HH24:MI:SS"
	end if
	
	sqlFecha = ""
	sqlFecha = sqlFecha & " SELECT  " & VbCrlf
	sqlFecha = sqlFecha & " 		TO_CHAR(SYSDATE,'" & formato & "') FECHA " & VbCrlf
	sqlFecha = sqlFecha & " FROM	DUAL " & VbCrlf
	
	Session("SQL") = sqlFecha
	arrFecha = GetArrayRS(sqlFecha)
	
	if IsArray(arrFecha) then
		res = arrFecha(0,0)
	end if
	
	obtener_fecha_actual = res
end function


function obtener_razon_social_cte(num_client)
	Dim res, sqlCte, arrCte
	
	sqlCte = ""
	sqlCte = sqlCte & " SELECT  " & VbCrlf
	sqlCte = sqlCte & " 		 CLINOM RAZON_SOCIAL " & VbCrlf
	sqlCte = sqlCte & " 		,CLICLEF NUM_CLIENTE " & VbCrlf
	sqlCte = sqlCte & " FROM	 ECLIENT " & VbCrlf
	sqlCte = sqlCte & " WHERE	 CLICLEF	=	'" & num_client & "' " & VbCrlf
	
	Session("SQL") = sqlCte
	arrCte = GetArrayRS(sqlCte)
	
	if IsArray(arrCte) then
		res = arrCte(0,0)
	end if
	
	obtener_razon_social_cte = res
end function


function obtener_serie_numerica(inicio,fin)
	Dim res, sqlNum, arrNum
	
	sqlNum = ""
	sqlNum = sqlNum & " SELECT " & VbCrlf
	sqlNum = sqlNum & " 	(x-1) NUMERO " & VbCrlf
	sqlNum = sqlNum & " FROM	(SELECT	ROWNUM x " & VbCrlf
	sqlNum = sqlNum & " 		 FROM   DUAL " & VbCrlf
	sqlNum = sqlNum & " 		 CONNECT BY	LEVEL	BETWEEN (" & inicio & "+1) AND (" & fin & "+1)) x " & VbCrlf
	
	Session("SQL") = sqlNum
	arrNum = GetArrayRS(sqlNum)
	
	obtener_serie_numerica = arrNum
end function


function obtiene_foraneo_6(dieclave)
	Dim res, sqlF6, arrF6
	
	sqlF6 = ""
	sqlF6 = sqlF6 & " SELECT	COUNT(0) " & VbCrlf
	sqlF6 = sqlF6 & " FROM	EDIRECCIONES_ENTREGA, EDESTINOS_POR_RUTA " & VbCrlf
	sqlF6 = sqlF6 & " WHERE DIECLAVE	=	" & dieclave & " " & VbCrlf
	sqlF6 = sqlF6 & " 	AND	der_vilclef(+)	=	dieville " & vbCrLf
	sqlF6 = sqlF6 & " 	AND	die_status		=	1 " & vbCrLf
	sqlF6 = sqlF6 & " 	AND	NVL(der_tipo_entrega, 'FORANEO 6')	=	'FORANEO 6'	AND	1 = 0 " & vbCrLf
	
	Session("SQL") = sqlF6
	arrF6 = GetArrayRS(sqlF6)
	
	obtener_serie_numerica = arrF6
end function


function obtener_usuario_documenta(CurrentUser)
	Dim res, sqlUsuario, arrUsuario
	
	sqlUsuario = ""
	sqlUsuario = sqlUsuario & " SELECT	UPPER(SUBSTR(UPPER('" & CurrentUser & "')|| '-WEB_DOC_EXT32', 1, 30)) USUARIO " & vbCrLf
	sqlUsuario = sqlUsuario & " FROM	DUAL " & vbCrLf
	
	Session("SQL") = sqlUsuario
	arrUsuario = GetArrayRS(sqlUsuario)
	
	if IsArray(arrUsuario) then
		res = "'" & arrUsuario(0,0) & "'"
	else
		res = " USER "
	end if
	
	obtener_usuario_documenta = res
end function


function obtiene_liga_dir_entrega_df_edomex(dieclave)
	Dim res, sqlDFedomex, arrDFedomex
	
	sqlDFedomex = ""
	sqlDFedomex = sqlDFedomex & " SELECT	COUNT(0) " & VbCrlf
	sqlDFedomex = sqlDFedomex & " FROM	 EDIRECCIONES_ENTREGA DIR " & vbCrLf 
	sqlDFedomex = sqlDFedomex & " 		,ECLIENT_CLIENTE CLICLI " & vbCrLf 
	sqlDFedomex = sqlDFedomex & " WHERE	 DIR.DIECLAVE		=	'" & dieclave & "' " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 	AND	 DIR.DIE_CCLCLAVE	=	CLICLI.CCLCLAVE " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 	AND	 EXISTS	( " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 					SELECT	NULL " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 					FROM	ECIUDADES, EESTADOS " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 					WHERE	VILCLEF		=	dieVILLE " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 						AND	ESTESTADO	=	VIL_ESTESTADO " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 						AND	 ESTESTADO	IN	(1129, 1444) " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 				) " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 	AND	 NOT EXISTS ( " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 						SELECT	NULL " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 						FROM	ECLIENT, ECREDIT " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 						WHERE	CLIRFC			=	CLICLI.CCL_RFC " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 							AND	CRECLIENT		=	CLICLEF " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 							AND	CREREGIME		IN	(2,6) " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 							AND	CRE_EMPCLAVE	=	28 " & vbCrLf
	sqlDFedomex = sqlDFedomex & " 					) " & vbCrLf
	
	Session("SQL") = sqlDFedomex
	arrDFedomex = GetArrayRS(sqlDFedomex)
	
	obtiene_liga_dir_entrega_df_edomex = arrDFedomex
end function


function obtiene_web_ltl_consecutivo(cliclef)
	Dim res, sqlCons, arrCons
	
	sqlCons = ""
	sqlCons = sqlCons & " SELECT	WLCO.WLCO_CONSECUTIVO " & vbCrLf
	sqlCons = sqlCons & " FROM	WEB_LTL_CONSECUTIVOS WLCO " & vbCrLf
	sqlCons = sqlCons & " WHERE	WLCO.WLCO_CLICLEF	=	'" & cliclef & "' " & vbCrLf
	
	Session("SQL") = sqlCons
	arrCons = GetArrayRS(sqlCons)
	
	obtiene_web_ltl_consecutivo = arrCons
end function


function obtiene_concepto_recol_domicilio(nui)
	Dim res, sqlReco, arrReco
	
	sqlReco = ""
	sqlReco = sqlReco & " SELECT	GET_CHOCLAVE_TRADING(184, WEL_CLICLEF) CONCEPTO " & vbCrLf
	sqlReco = sqlReco & " FROM	WEB_LTL " & vbCrLf
	sqlReco = sqlReco & " WHERE	WELCLAVE	=	'" & nui & "' " & vbCrLf
	
	Session("SQL") = sqlReco
	arrReco = GetArrayRS(sqlReco)
	
	obtiene_concepto_recol_domicilio = arrReco
end function


function es_valida_factura_cliente(cliclef, wel_factura)
	Dim res, sqlValFact, arrValFact
	
	res = true
	sqlValFact = ""
	
	sqlValFact = sqlValFact & " SELECT	WELFACTURA " & vbCrLf
	sqlValFact = sqlValFact & " FROM	WEB_LTL " & vbCrLf
	sqlValFact = sqlValFact & " WHERE	WEL_CLICLEF	=	'" & cliclef & "' " & vbCrLf
	sqlValFact = sqlValFact & " 	AND	WELFACTURA	=	'" & wel_factura & "' " & vbCrLf
	sqlValFact = sqlValFact & " 	AND	WELFACTURA	<>	'_PENDIENTE_' " & vbCrLf
	sqlValFact = sqlValFact & " 	AND	WELSTATUS	NOT	IN	(0,3) " & vbCrLf
	
	Session("SQL") = sqlValFact
	arrValFact = GetArrayRS(sqlValFact)
	
	if isArray(arrValFact) then
		res = false
	end if
	
	es_valida_factura_cliente = res
end function


function obtiene_tarifas_distribucion_x_cliente(cliclef)
	Dim res, sqlTarifa, arrTarifa
	
	res = false
	sqlTarifa = ""
	
	sqlTarifa = sqlTarifa & " SELECT	 DISTINCT " & vbCrLf
	sqlTarifa = sqlTarifa & " 		 NVL(PAR.PAR_TIBCLAVE_IMPORTE, PAR.PAR_TIBCLAVE) CLAVE_CALCULO " & vbCrLf
	sqlTarifa = sqlTarifa & " 		,TIB.TIBNOMBRE NOMBRE " & vbCrLf
	sqlTarifa = sqlTarifa & " FROM	 ECLIENT_APLICA_CONCEPTOS CCO " & vbCrLf
	sqlTarifa = sqlTarifa & " 	INNER	JOIN	EBASES_POR_CONCEPT BPC	ON	CCO.CCO_BPCCLAVE	=	BPC.BPCCLAVE " & vbCrLf
	sqlTarifa = sqlTarifa & " 	INNER	JOIN	EPARAMETRO_RESTRICT PAR	ON	BPC.BPC_PARCLAVE	=	PAR.PARCLAVE " & vbCrLf
	sqlTarifa = sqlTarifa & " 	INNER	JOIN	ETIPO_BASE_TARIFA TIB	ON	NVL(PAR.PAR_TIBCLAVE_IMPORTE, PAR.PAR_TIBCLAVE)	=	TIB.TIBCLAVE " & vbCrLf
	sqlTarifa = sqlTarifa & " WHERE	1 = 1 " & vbCrLf
	sqlTarifa = sqlTarifa & " 	AND	CCO.CCO_CLICLEF		=	'" & cliclef & "' " & vbCrLf
	sqlTarifa = sqlTarifa & " 	AND	BPC.BPC_CHOCLAVE	IN	( " & vbCrLf
	sqlTarifa = sqlTarifa & " 									SELECT	CHO.CHOCLAVE " & vbCrLf
	sqlTarifa = sqlTarifa & " 									FROM	ECONCEPTOSHOJA CHO " & vbCrLf
	sqlTarifa = sqlTarifa & " 									WHERE	1 = 1 " & vbCrLf
	sqlTarifa = sqlTarifa & " 										/*	40	DISTRIBUCION CROSS DOCK	*/ " & vbCrLf
	sqlTarifa = sqlTarifa & " 										/*	172	DISTRIBUCION LTL		*/ " & vbCrLf
	sqlTarifa = sqlTarifa & " 										AND	CHO.CHONUMERO		IN	(40,172) " & vbCrLf
	sqlTarifa = sqlTarifa & " 										AND	CHO.CHO_EMPCLAVE	IN	( " & vbCrLf
	sqlTarifa = sqlTarifa & " 																		SELECT	LIGA.CET_EMPCLAVE CVE_EMPRESA " & vbCrLf
	sqlTarifa = sqlTarifa & " 																		FROM	ECLIENT_EMPRESA_TRADING LIGA " & vbCrLf
	sqlTarifa = sqlTarifa & " 																		WHERE	1 = 1 " & vbCrLf
	sqlTarifa = sqlTarifa & " 																			AND	LIGA.CET_CLICLEF	=	CCO.CCO_CLICLEF " & vbCrLf
	sqlTarifa = sqlTarifa & " 																	) " & vbCrLf
	sqlTarifa = sqlTarifa & " 								) " & vbCrLf
	sqlTarifa = sqlTarifa & " ORDER	BY 1 " & vbCrLf
	
	
	Session("SQL") = sqlTarifa
	arrTarifa = GetArrayRS(sqlTarifa)
	
	obtiene_tarifas_distribucion_x_cliente = arrTarifa
end function


function es_tarifa_por_caja(cliclef)
	Dim res, arrTarifa
	
	res = false
	arrTarifa = obtiene_tarifas_distribucion_x_cliente(cliclef)
	
	if isArray(arrTarifa) then
		for i = 0 to Ubound(arrTarifa,2)
			if arrTarifa(0,i) = "173" then
				res = true
			end if
		next
	end if
	
	es_tarifa_por_caja = res
end function

function es_captura_con_factura(num_client)
	Dim res
	Dim iConFactura, sqlConFactura, arrConFactura
	
	res = false
	iConFactura = 0
	sqlConFactura = ""
	
	''if num_client = "23221" or num_client = "23222" or num_client = "23217" then
	'if num_client = "23221" or num_client = "23222" or num_client = "23217" or num_client = "23149" then
	'	res = true
	'end if
	
	'<<20240103: Se modifica el campo de donde se tomará el tipo de documentación:
	'sqlConFactura = sqlConFactura & " SELECT	CON_FACTURA " & vbCrLf
	sqlConFactura = sqlConFactura & " SELECT	TIPO_DOCUMENTACION " & vbCrLf
	'  20240103>>
	sqlConFactura = sqlConFactura & " FROM		TB_CONFIG_CLIENTE_DIST " & vbCrLf
	sqlConFactura = sqlConFactura & " WHERE		ID_CLIENTE	=	'" & num_client & "' " & vbCrLf
	Session("SQL") = sqlConFactura
	arrConFactura = GetArrayRS(sqlConFactura)
	
	if IsArray(arrConFactura) then
		iConFactura = arrConFactura(0,0)
		
		if iConFactura = "1" then
			res = true
		end if
	end if
	
	es_captura_con_factura = res
end function
function es_captura_sin_factura(num_client)
	Dim res
	Dim iSinFactura, sqlSinFactura, arrSinFactura
	
	res = false
	iSinFactura = 0
	sqlSinFactura = ""
	
	''if num_client = "23058" or num_client = "23149" or num_client = "23150" or num_client = "23220" then
	'if num_client = "23058" or num_client = "23150" or num_client = "23220" then
	'	res = true
	'end if
	
	'<<20240103: Se modifica el campo de donde se tomará el tipo de documentación:
	'if es_captura_con_factura(num_client) = true then
	'	res = false
	'end if
	sqlSinFactura = sqlSinFactura & " SELECT	NVL(TIPO_DOCUMENTACION,0) TIPO_DOCUMENTACION " & vbCrLf
	sqlSinFactura = sqlSinFactura & " FROM		TB_CONFIG_CLIENTE_DIST " & vbCrLf
	sqlSinFactura = sqlSinFactura & " WHERE		ID_CLIENTE	=	'" & num_client & "' " & vbCrLf
	Session("SQL") = sqlSinFactura
	arrSinFactura = GetArrayRS(sqlSinFactura)
	
	if IsArray(arrSinFactura) then
		iSinFactura = arrSinFactura(0,0)
		
		if iSinFactura = "0" then
			res = true
		end if
	end if
	'  20240103>>
	
	es_captura_sin_factura = res
end function

function eliminar_comillas(txt)
	Dim res
	
	res = Replace(txt,"""","")
	
	eliminar_comillas = res
end function
function es_cuenta_pruebas(num_client)
	Dim res
	res = false
	
	'if CStr(num_client) = "20123" or CStr(num_client) = "20120" or CStr(num_client) = "20459" then
	if CStr(num_client) = "20123" then
		res = true
	end if
	if Session("array_client")(0,0) = "20123EVIDENCIAS" or Session("array_client")(0,0) = "MESA_AYUDA" then
		res = true
	end if
	
	es_cuenta_pruebas = res
end function
function es_captura_con_doc_fuente(num_client)
	Dim res
	Dim iConDocFuente, sqlConDocFuente, arrConDocFuente
	
	res = false
	iConDocFuente = 0
	sqlConDocFuente = ""
	
	'<<20240103: Se modifica el campo de donde se tomará el tipo de documentación:
	'sqlConDocFuente = sqlConDocFuente & " SELECT	CON_DOCUMENTO_FUENTE " & vbCrLf
	sqlConDocFuente = sqlConDocFuente & " SELECT	TIPO_DOCUMENTACION CON_DOCUMENTO_FUENTE " & vbCrLf
	'  20240103>>
	sqlConDocFuente = sqlConDocFuente & " FROM		TB_CONFIG_CLIENTE_DIST " & vbCrLf
	sqlConDocFuente = sqlConDocFuente & " WHERE		ID_CLIENTE	=	'" & num_client & "' " & vbCrLf
	Session("SQL") = sqlConDocFuente
	arrConDocFuente = GetArrayRS(sqlConDocFuente)
	
	if IsArray(arrConDocFuente) then
		iConDocFuente = arrConDocFuente(0,0)
		
		'<<20240103: Se modifica el valor que se va a evaluar de acuerdo a la dfinición del nuevo campo:
		'if iConDocFuente = "1" then
		if iConDocFuente = "2" then
		'  20240103>>
			res = true
		end if
	end if
	
	es_captura_con_doc_fuente = res
end function
function tiene_confronta(num_client)
	Dim res
	res = false
	
	if num_client = "20235" or num_client = "22595" or num_client = "23406" or num_client = "23374" or num_client = "23264" or num_client = "20150" _
		or num_client = "20123" then
		res = true
	end if
	
	tiene_confronta = res
end function
function obtieneCantidadFacturas(nui)
	Dim sqlDetFactura, arrDetFactura, iCantidad
	
	iCantidad = 0
	sqlDetFactura = ""
	sqlDetFactura = sqlDetFactura & "SELECT	COUNT(*) CANTIDAD " & vbCrLf
	sqlDetFactura = sqlDetFactura & "FROM	EFACTURAS_DOC " & vbCrLf
	sqlDetFactura = sqlDetFactura & "WHERE	NUI	=	'" & nui & "' " & vbCrLf
	Session("SQL") = sqlDetFactura
	arrDetFactura = GetArrayRS(sqlDetFactura)
	
	if IsArray(arrDetFactura) then
		iCantidad = arrDetFactura(0,0)
	end if
	
	obtieneCantidadFacturas = iCantidad
end function
function obtieneDetalleFactura(nui)
	Dim sqlDetFactura, arrDetFactura
	
	sqlDetFactura = ""
	sqlDetFactura = sqlDetFactura & "SELECT	ID_FACTURA_DOC, NUI, DOCUMENTO_FUENTE, NO_FACTURA, LINEAS_FACTURA, VALOR, NO_ORDEN, PEDIDO, (ROWNUM-1) CONSECUTIVO " & vbCrLf
	sqlDetFactura = sqlDetFactura & "FROM	EFACTURAS_DOC " & vbCrLf
	sqlDetFactura = sqlDetFactura & "WHERE	NUI	=	'" & nui & "' " & vbCrLf
	sqlDetFactura = sqlDetFactura & "ORDER	BY " & vbCrLf
	'ORP:
	'sqlDetFactura = sqlDetFactura & "		1,2,3 " & vbCrLf
	sqlDetFactura = sqlDetFactura & "		8,3,2,1 " & vbCrLf
	
	Session("SQL") = sqlDetFactura
	arrDetFactura = GetArrayRS(sqlDetFactura)
	
	obtieneDetalleFactura = arrDetFactura
end function
function actualizaNumeroFactura(IdFacturaDoc,NumeroFactura)
	Dim sqlNumFactura, rst_fact
	
	sqlNumFactura = ""
	sqlNumFactura = sqlNumFactura & " UPDATE	EFACTURAS_DOC " & vbCrLf
	sqlNumFactura = sqlNumFactura & " 	SET	NO_FACTURA		=	'" & NumeroFactura & "' " & vbCrLf
	sqlNumFactura = sqlNumFactura & " WHERE	ID_FACTURA_DOC	=	'" & IdFacturaDoc & "' " & vbCrLf
	
	Session("SQL") = sqlNumFactura
	set rst_fact = Server.CreateObject("ADODB.Recordset")
	rst_fact.Open sqlNumFactura, Connect(), 0, 1, 1
end function
function obtieneFacturasXnui(Nui)
	Dim sqlNumFactura, arrNumFactura, lstFacturas
	
	lstFacturas = ""
	sqlNumFactura = ""
	
	sqlNumFactura = sqlNumFactura & " SELECT	 DISTINCT " & vbCrLf
	sqlNumFactura = sqlNumFactura & " 			 LISTAGG(NO_FACTURA, ',') WITHIN GROUP (ORDER BY DATE_CREATED) OVER (PARTITION BY NUI) LISTA_FACTURAS " & vbCrLf
	sqlNumFactura = sqlNumFactura & " 			,NUI " & vbCrLf
	sqlNumFactura = sqlNumFactura & " FROM		EFACTURAS_DOC " & vbCrLf
	sqlNumFactura = sqlNumFactura & " WHERE		NUI	=	'" & Nui & "' " & vbCrLf
	
	Session("SQL") = sqlDetFactura
	arrNumFactura = GetArrayRS(sqlDetFactura)
	
	if IsArray(arrNumFactura) then
		lstFacturas = arrNumFactura(0,0)
	end if
	
	obtieneFacturasXnui = lstFacturas
end function
function actualizaNumeroFacturaNUI(Nui,NumeroFactura)
	Dim sqlNumFactura, rst_fact
	
	sqlNumFactura = ""
	sqlNumFactura = sqlNumFactura & " UPDATE	WEB_LTL " & vbCrLf
	sqlNumFactura = sqlNumFactura & " 	SET	WELFACTURA	=	'" & NumeroFactura & "' " & vbCrLf
	sqlNumFactura = sqlNumFactura & " WHERE	WELCLAVE	=	'" & Nui & "' " & vbCrLf
	
	Session("SQL") = sqlNumFactura
	set rst_fact = Server.CreateObject("ADODB.Recordset")
	rst_fact.Open sqlNumFactura, Connect(), 0, 1, 1
end function

function GetArrayRS_QA (strSQL)
	'return an array from a query
	dim strCon, obj_conn 
	set obj_conn=Server.CreateObject("ADODB.connection")
	Dim CONN_STRING, CONN_USER, CONN_PASS
	
	CONN_STRING = "192.168.0.199"
	'CONN_STRING = Get_Conn_string("SERVER")
	CONN_USER = Get_Conn_string("LOGIN")
	CONN_PASS = Get_Conn_string("PASS")
	obj_conn.ConnectionTimeout = 30000	'timeout for connection
	obj_conn.CommandTimeout = 30000		' timeout for SQL commands
	obj_conn.Open CONN_STRING, CONN_USER, CONN_PASS	

	'debug :
	Session("SQL") = strSQL
	
	Dim rst
	set rst = Server.CreateObject("ADODB.Recordset")
	rst.Open strSQL, obj_conn, 0, 1, 1 'cursortype: forwardonly
	
	if not(rst.EOF) then 
		GetArrayRS_QA = rst.GetRows 
	else GetArrayRS_QA = ""
	end if
	'clean
	set rst = nothing
	obj_conn.Close 
	set obj_conn = nothing
end function
function es_entrada_VAS(nui)
	Dim res, TDCDCLAVE
	Dim iEntradaVAS, sqlEntradaVAS, arrEntradaVAS
	
	res = false
	TDCDCLAVE = ""
	iEntradaVAS = 0
	sqlEntradaVAS = ""
	
	sqlEntradaVAS = " SELECT	WEL_TDCDCLAVE "
	sqlEntradaVAS = " FROM		WEB_LTL "
	sqlEntradaVAS = " WHERE		WELCLAVE = '" & nui & "' "
	Session("SQL") = sqlEntradaVAS
	arrEntradaVAS = GetArrayRS(sqlEntradaVAS)
	
	if IsArray(arrEntradaVAS) then
		TDCDCLAVE = arrEntradaVAS(0,0)
		
		if TDCDCLAVE <> "" then
			sqlEntradaVAS = ""
			sqlEntradaVAS = sqlEntradaVAS & " SELECT	COUNT(*) " & vbCrLf
			sqlEntradaVAS = sqlEntradaVAS & " FROM	ETRANSFERENCIA_TRADING TRA " & vbCrLf
			sqlEntradaVAS = sqlEntradaVAS & " 	JOIN	ETRANSFERENCIA_PALETA TDP " & vbCrLf
			sqlEntradaVAS = sqlEntradaVAS & " 		ON	TRA.TRACLAVE		=	TDP.TDP_TRACLAVE " & vbCrLf
			sqlEntradaVAS = sqlEntradaVAS & " WHERE	TDP.TDP_TDCDCLAVE		=	'" & TDCDCLAVE & "' " & vbCrLf
			sqlEntradaVAS = sqlEntradaVAS & " 	AND	TRA.TRASTATUS			=	'1' " & vbCrLf
			sqlEntradaVAS = sqlEntradaVAS & " 	AND	TRA.TRA_MEZTCLAVE_ORI	=	0 " & vbCrLf
			sqlEntradaVAS = sqlEntradaVAS & " 	AND	TRA.TRA_MEZTCLAVE_DEST	=	34	--VAS " & vbCrLf
			Session("SQL") = sqlEntradaVAS
			arrEntradaVAS = GetArrayRS(sqlEntradaVAS)
			
			if IsArray(arrEntradaVAS) then
				iEntradaVAS = arrEntradaVAS(0,0)
				
				if iEntradaVAS <> "" then
					res = true
				end if
			end if
		end if
	end if
	
	es_entrada_VAS = res
end function
'	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	*	'
function registrar_segundos_envios(NUI)
	Dim SQl, array_tmp, choclave_segundos_envios, result
	'''Se agregan instrucciones para registrar el concepto de SEGUNDOS ENVIOS para los casos que apliquen:
	SQl = ""
	result = false
	choclave_segundos_envios = "-1"
	
	'Buscar la clave del Concepto Correspondiente por Empresa:
	SQL = SQL & " SELECT	CHOCLAVE " & vbCrLf
	SQL = SQL & " FROM		ECONCEPTOSHOJA " & vbCrLf
	SQL = SQL & " WHERE		1 = 1 " & vbCrLf
	SQL = SQL & "	AND		CHOTIPOIE		=	'I' " & vbCrLf
	SQL = SQL & "	AND		CHONUMERO		=	517 " & vbCrLf
	SQL = SQL & "	AND		CHO_EMPCLAVE	=	'" & obtener_clave_empresa(Session("array_client")(2,0)) & "' " & vbCrLf

	Session("SQL") = SQL
	array_tmp = GetArrayRS(SQL)
	
	if IsArray(array_tmp) then
		SQL = ""
		choclave_segundos_envios = array_tmp(0,0)
		
		'Buscar que al cliente le corresponda este concepto:
		SQL = SQL & " 	select lig.lig_cliclef " & vbCrLf
		SQL = SQL & "      , cli.clinom  " & vbCrLf
		SQL = SQL & "      , cho.chonumero " & vbCrLf
		SQL = SQL & "      , cho.chonombre " & vbCrLf
		SQL = SQL & "      , cho2.chonumero " & vbCrLf
		SQL = SQL & "      , cho2.chonombre " & vbCrLf
		SQL = SQL & "   from ELIGA_TARIFAS lig " & vbCrLf
		SQL = SQL & "   join econceptoshoja cho " & vbCrLf
		SQL = SQL & "     on cho.choclave = lig.lig_choclave_aplica " & vbCrLf
		SQL = SQL & "   join econceptoshoja cho2 " & vbCrLf
		SQL = SQL & "     on cho2.choclave = lig.lig_choclave " & vbCrLf
		SQL = SQL & "   join eclient cli " & vbCrLf
		SQL = SQL & "     on cli.cliclef = lig.lig_cliclef  " & vbCrLf
		SQL = SQL & "     where lig_cliclef = '" & Session("array_client")(2,0) & "' " & vbCrLf
		SQL = SQL & "     AND cho2.CHONUMERO IN (517) " & vbCrLf

		Session("SQL") = SQL
		array_tmp = GetArrayRS(SQL)
	
		If IsArray(array_tmp) then
			SQL = ""
			'Validar que se tenga el NUI al que se va a agregar el concepto:
			if NUI <> "" then
				if IsNumeric(NUI) then
					SQL = ""
					'Validar que el NUI no tenga asignado ya el concepto de SEGUNDOS ENVIOS:
					SQL = SQL & "SELECT	WLCCLAVE, WLC_WELCLAVE, WLC_CHOCLAVE " & vbCrLf
					SQL = SQL & "FROM	WEB_LTL_CONCEPTOS WLC " & vbCrLf
					SQL = SQL & "WHERE	WLC_WELCLAVE	=	'" & NUI & "' " & vbCrLf
					SQL = SQL & "	AND	WLC_CHOCLAVE	=	'" & choclave_segundos_envios & "' " & vbCrLf
					SQL = SQL & "	AND	WLCSTATUS		=	1 " & vbCrLf
					Session("SQL") = SQL
					array_tmp = GetArrayRS(SQL)

					If Not IsArray(array_tmp) then
						SQL = ""
						'Si no está asignado el concepto de segundos envios, se registra en cero:
						SQL = SQL & " INSERT INTO	WEB_LTL_CONCEPTOS " & vbCrLf
						SQL = SQL & " ( " & vbCrLf
						SQL = SQL & " 	 WLCCLAVE " & vbCrLf
						SQL = SQL & " 	,WLC_WELCLAVE ,WLC_CHOCLAVE ,WLC_IMPORTE " & vbCrLf
						SQL = SQL & " 	,CREATED_BY ,DATE_CREATED " & vbCrLf
						SQL = SQL & " ) " & vbCrLf
						SQL = SQL & " 	 SELECT	 SEQ_WEB_LTL_CONCEPTOS.nextval " & vbCrLf
						SQL = SQL & " 			,'" & NUI & "' ,'" & choclave_segundos_envios & "','" & obtener_monto_x_concepto(NUI,choclave_segundos_envios) & "' " & vbCrLf
						SQL = SQL & " 			,UPPER(" & obtener_usuario_documenta(Session("array_client")(0,0)) & "), SYSDATE " & vbCrLf
						SQL = SQL & " 	FROM	 DUAL " & vbCrLf

						'<<<<2024-08-01: Se agrega registro en log de queries:
							registraLog_subproceso "16", SQL
						'    2024-08-01>>>>
						Session("SQL") = SQL
						set rst = Server.CreateObject("ADODB.Recordset")
						rst.Open SQL, Connect(), 0, 1, 1
						'<<<<2024-08-01: Se agrega registro en log de queries:
							registraLog_subproceso "16", "ejecutado"
						'    2024-08-01>>>>
						
						result = true
					end if
				end if
			end if
		end if
	end if
	
	registrar_segundos_envios = result
end function
function registrar_rechazos(NUI)
	Dim SQl, array_tmp, choclave_rechazos, result
	'''Se agregan instrucciones para registrar el concepto de RECHAZOS para los casos que apliquen:
	SQl = ""
	result = false
	choclave_rechazos = "-1"
	
	'Buscar la clave del Concepto Correspondiente por Empresa:
	SQL = SQL & " SELECT	CHOCLAVE " & vbCrLf
	SQL = SQL & " FROM		ECONCEPTOSHOJA " & vbCrLf
	SQL = SQL & " WHERE		1 = 1 " & vbCrLf
	SQL = SQL & "	AND		CHOTIPOIE		=	'I' " & vbCrLf
	SQL = SQL & "	AND		CHONUMERO		=	174 " & vbCrLf
	SQL = SQL & "	AND		CHO_EMPCLAVE	=	'" & obtener_clave_empresa(Session("array_client")(2,0)) & "' " & vbCrLf

	Session("SQL") = SQL
	array_tmp = GetArrayRS(SQL)
	
	if IsArray(array_tmp) then
		SQL = ""
		choclave_rechazos = array_tmp(0,0)
		
		'Buscar que al cliente le corresponda este concepto:
		SQL = SQL & " 	select lig.lig_cliclef " & vbCrLf
		SQL = SQL & "      , cli.clinom  " & vbCrLf
		SQL = SQL & "      , cho.chonumero " & vbCrLf
		SQL = SQL & "      , cho.chonombre " & vbCrLf
		SQL = SQL & "      , cho2.chonumero " & vbCrLf
		SQL = SQL & "      , cho2.chonombre " & vbCrLf
		SQL = SQL & "   from ELIGA_TARIFAS lig " & vbCrLf
		SQL = SQL & "   join econceptoshoja cho " & vbCrLf
		SQL = SQL & "     on cho.choclave = lig.lig_choclave_aplica " & vbCrLf
		SQL = SQL & "   join econceptoshoja cho2 " & vbCrLf
		SQL = SQL & "     on cho2.choclave = lig.lig_choclave " & vbCrLf
		SQL = SQL & "   join eclient cli " & vbCrLf
		SQL = SQL & "     on cli.cliclef = lig.lig_cliclef  " & vbCrLf
		SQL = SQL & "     where lig_cliclef = '" & Session("array_client")(2,0) & "' " & vbCrLf
		SQL = SQL & "     AND cho2.CHONUMERO IN (174) " & vbCrLf

		Session("SQL") = SQL
		array_tmp = GetArrayRS(SQL)
	
		If IsArray(array_tmp) then
			SQL = ""
			'Validar que se tenga el NUI al que se va a agregar el concepto:
			if NUI <> "" then
				'if IsNumeric(NUI) then
					SQL = ""
					'Validar que el NUI no tenga asignado ya el concepto de RECHAZOS:
					SQL = SQL & "SELECT	WLCCLAVE, WLC_WELCLAVE, WLC_CHOCLAVE " & vbCrLf
					SQL = SQL & "FROM	WEB_LTL_CONCEPTOS WLC " & vbCrLf
					SQL = SQL & "WHERE	WLC_WELCLAVE	=	'" & NUI & "' " & vbCrLf
					SQL = SQL & "	AND	WLC_CHOCLAVE	=	'" & choclave_rechazos & "' " & vbCrLf
					SQL = SQL & "	AND	WLCSTATUS		=	1 " & vbCrLf
					Session("SQL") = SQL
					array_tmp = GetArrayRS(SQL)

					If Not IsArray(array_tmp) then
						SQL = ""
						'Si no está asignado el concepto de RECHAZOS, se registra en cero:
						SQL = SQL & " INSERT INTO	WEB_LTL_CONCEPTOS " & vbCrLf
						SQL = SQL & " ( " & vbCrLf
						SQL = SQL & " 	 WLCCLAVE " & vbCrLf
						SQL = SQL & " 	,WLC_WELCLAVE ,WLC_CHOCLAVE ,WLC_IMPORTE " & vbCrLf
						SQL = SQL & " 	,CREATED_BY ,DATE_CREATED " & vbCrLf
						SQL = SQL & " ) " & vbCrLf
						SQL = SQL & " 	 SELECT	 SEQ_WEB_LTL_CONCEPTOS.nextval " & vbCrLf
						SQL = SQL & " 			,'" & NUI & "' ,'" & choclave_rechazos & "','" & obtener_monto_x_concepto_rechazo(NUI,choclave_rechazos) & "' " & vbCrLf
						SQL = SQL & " 			,UPPER(" & obtener_usuario_documenta(Session("array_client")(0,0)) & "), SYSDATE " & vbCrLf
						SQL = SQL & " 	FROM	 DUAL " & vbCrLf

						'<<<<2024-08-01: Se agrega registro en log de queries:
							registraLog_subproceso "17", SQL
						'    2024-08-01>>>>
						Session("SQL") = SQL
						set rst = Server.CreateObject("ADODB.Recordset")
						rst.Open SQL, Connect(), 0, 1, 1
						'<<<<2024-08-01: Se agrega registro en log de queries:
							registraLog_subproceso "17", SQL
						'    2024-08-01>>>>

						result = true
					end if
				'end if
			end if
		end if
	end if
	
	registrar_rechazos = result
end function
function registrar_evidencias(NUI)
	Dim SQl, array_tmp, choclave_evidencias, cant_facturas, monto_evidencias, result
	'''Se agregan instrucciones para registrar el concepto de evidencias para los casos que apliquen:
	SQl = ""
	result = false
	cant_facturas = 0
	monto_evidencias = 0
	choclave_evidencias = "-1"
	
	'Buscar la clave del Concepto Correspondiente por Empresa:
	SQL = SQL & " SELECT	CHOCLAVE " & vbCrLf
	SQL = SQL & " FROM		ECONCEPTOSHOJA " & vbCrLf
	SQL = SQL & " WHERE		1 = 1 " & vbCrLf
	SQL = SQL & "	AND		CHOTIPOIE		=	'I' " & vbCrLf
	SQL = SQL & "	AND		CHONUMERO		=	406 " & vbCrLf
	SQL = SQL & "	AND		CHO_EMPCLAVE	=	'" & obtener_clave_empresa(Session("array_client")(2,0)) & "' " & vbCrLf

	Session("SQL") = SQL
	array_tmp = GetArrayRS(SQL)
	
	if IsArray(array_tmp) then
		SQL = ""
		choclave_evidencias = array_tmp(0,0)
		
		'Buscar que al cliente le corresponda este concepto:
		if es_captura_con_factura(Session("array_client")(2,0)) then
			SQL = SQL & "SELECT	COUNT(NO_FACTURA) CANTIDAD " & vbCrLf
			SQL = SQL & "FROM	EFACTURAS_DOC " & vbCrLf
			SQL = SQL & "WHERE	NUI	=	'" & NUI & "' " & vbCrLf
			
			Session("SQL") = SQL
			array_tmp = GetArrayRS(SQL)
			
			if IsArray(array_tmp) then
				cant_facturas = CDbl(array_tmp(0,0))
				'El Monto por Evidencias se obtiene calculando la cantidad de Facturas por 50 pesos:
				monto_evidencias = cant_facturas * 50
				
				if cant_facturas > 0 and monto_evidencias > 0 then
					SQL = ""
					'Validar que el NUI no tenga asignado ya el concepto de COBRO POR EVIDENCIAS:
					SQL = SQL & "SELECT	WLCCLAVE, WLC_WELCLAVE, WLC_CHOCLAVE " & vbCrLf
					SQL = SQL & "FROM	WEB_LTL_CONCEPTOS WLC " & vbCrLf
					SQL = SQL & "WHERE	WLC_WELCLAVE	=	'" & NUI & "' " & vbCrLf
					SQL = SQL & "	AND	WLC_CHOCLAVE	=	'" & choclave_evidencias & "' " & vbCrLf
					SQL = SQL & "	AND	WLCSTATUS		=	1 " & vbCrLf
					Session("SQL") = SQL
					array_tmp = GetArrayRS(SQL)
					
					If Not IsArray(array_tmp) then
						SQL = ""
						'Si no está asignado el concepto de COBRO POR EVIDENCIAS, se registra el Monto calculado:
						SQL = SQL & " INSERT INTO	WEB_LTL_CONCEPTOS " & vbCrLf
						SQL = SQL & " ( " & vbCrLf
						SQL = SQL & " 	 WLCCLAVE " & vbCrLf
						SQL = SQL & " 	,WLC_WELCLAVE ,WLC_CHOCLAVE ,WLC_IMPORTE " & vbCrLf
						SQL = SQL & " 	,CREATED_BY ,DATE_CREATED " & vbCrLf
						SQL = SQL & " ) " & vbCrLf
						SQL = SQL & " 	 SELECT	 SEQ_WEB_LTL_CONCEPTOS.nextval " & vbCrLf
						SQL = SQL & " 			,'" & NUI & "' ,'" & choclave_evidencias & "','" & monto_evidencias & "' " & vbCrLf
						SQL = SQL & " 			,UPPER(" & obtener_usuario_documenta(Session("array_client")(0,0)) & "), SYSDATE " & vbCrLf
						SQL = SQL & " 	FROM	 DUAL " & vbCrLf
	
						'<<<<2024-08-01: Se agrega registro en log de queries:
							registraLog_subproceso "18", SQL
						'    2024-08-01>>>>
						Session("SQL") = SQL
						set rst = Server.CreateObject("ADODB.Recordset")
						rst.Open SQL, Connect(), 0, 1, 1
						'<<<<2024-08-01: Se agrega registro en log de queries:
							registraLog_subproceso "18", "ejecutado"
						'    2024-08-01>>>>
					end if
				end if
			end if
		end if
	end if
	
	registrar_evidencias = result
end function
function obtener_monto_x_concepto(NUI, choclave)
	dim res, porcentaje, montoNUI, chonumero
	dim SQL, array_tmp
	
	res = 0
	montoNUI = 0
	porcentaje = 0
	chonumero = ""
	
	'Obtener el monto de Distribucion (CHONUMERO => 172)
	'Obtener el CHONUMERO correspondiente a la CHOCLAVE del concepto
	'Obtener el Porcentaje por concepto
	'Calcular el Monto del Concepto multiplicando el Monto de Distribucion por el Porcentaje
	
	SQL = ""
	'Obtener el monto de Distribucion (CHONUMERO => 172)
	SQL = SQL & " SELECT	WLC.WLC_IMPORTE IMPORTE, WLC.WLCCLAVE CLAVE_CONCEPTO, WLC.WLC_WELCLAVE WELCLAVE, WLC.WLC_CHOCLAVE CHOCLAVE, " & VbCrlf
	SQL = SQL & " 		WLC.WLCSTATUS STATUS, CHO.CHONUMERO CHONUMERO, WLC.DATE_CREATED FECHA_CREACION " & VbCrlf
	SQL = SQL & " FROM	WEB_LTL_CONCEPTOS WLC " & VbCrlf
	SQL = SQL & " 	INNER JOIN	ECONCEPTOSHOJA CHO " & VbCrlf
	SQL = SQL & " 		ON	WLC.WLC_CHOCLAVE	=	CHO.CHOCLAVE " & VbCrlf
	SQL = SQL & " WHERE	CHO.CHOTIPOIE		=	'I' " & VbCrlf
	SQL = SQL & " 	AND	CHO.CHONUMERO		=	172 /* DISTRIBUCION */ " & VbCrlf
	SQL = SQL & " 	AND	WLC.WLC_WELCLAVE	=	'" & NUI & "' " & VbCrlf
	SQL = SQL & " ORDER	BY	WLC.DATE_CREATED	DESC " & VbCrlf

	Session("SQL") = SQL
	array_tmp = GetArrayRS(SQL)
	
	If IsArray(array_tmp) then
		montoNUI = CDbl(array_tmp(0,0))
	End If
	
	If montoNUI <= 0 then
		SQL = ""
		SQL = SQL & " SELECT " & VbCrlf
		SQL = SQL & "	(" & VbCrlf
		SQL = SQL & "		CASE	WHEN	LOGIS.FN_OBTEN_MONTO_DISTRIBUCION(WTS.NUI)	>	0 " & VbCrlf
		SQL = SQL & "					THEN	LOGIS.FN_OBTEN_MONTO_DISTRIBUCION(WTS.NUI) " & VbCrlf
		SQL = SQL & "				WHEN NVL(NVL(WTS.IMP_DISTRIBUCION,NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO)),0) > 0 " & VbCrlf
		SQL = SQL & "					THEN	NVL(NVL(WTS.IMP_DISTRIBUCION,NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO)),0) " & VbCrlf
		SQL = SQL & "				ELSE " & VbCrlf
		SQL = SQL & "			 		WEL.WELIMPORTE " & VbCrlf
		SQL = SQL & "		END " & VbCrlf
		SQL = SQL & " 	) IMPORTE " & VbCrlf
		SQL = SQL & " FROM	WEB_LTL WEL " & VbCrlf
		SQL = SQL & " 	INNER JOIN	WEB_TRACKING_STAGE WTS " & VbCrlf
		SQL = SQL & " 		ON	WEL.WELCLAVE = WTS.NUI " & VbCrlf
		SQL = SQL & " WHERE	WEL.WELCLAVE = '" & NUI & "' " & VbCrlf

		Session("SQL") = SQL
		array_tmp = GetArrayRS(SQL)
		
		If IsArray(array_tmp) then
			'<<<2024078
			if array_tmp(0,0) <> "" Then
				montoNUI = CDbl(array_tmp(0,0))
			else
				montoNUI = 0
			end if
			'   2024078>>>
			'montoNUI = array_tmp(0,0)
		End If
	End If
	
	SQL = ""
	'Obtener el CHONUMERO correspondiente a la CHOCLAVE del concepto
	SQL = SQL & " SELECT	CHO.CHONUMERO, CHO.CHO_EMPCLAVE, CHO.CHOTIPOIE, CHO.CHONOMBRE, " & VbCrlf
	SQL = SQL & " 	WLC.WLCCLAVE, WLC.WLC_WELCLAVE, WLC.WLC_CHOCLAVE, WLC.WLC_IMPORTE, WLC.DATE_CREATED, WLC.WLCSTATUS " & VbCrlf
	SQL = SQL & " FROM	WEB_LTL_CONCEPTOS WLC " & VbCrlf
	SQL = SQL & " 	INNER JOIN	ECONCEPTOSHOJA CHO " & VbCrlf
	SQL = SQL & " 		ON	WLC.WLC_CHOCLAVE	=	CHO.CHOCLAVE " & VbCrlf
	SQL = SQL & " WHERE	CHO.CHOTIPOIE		=	'I' " & VbCrlf
	SQL = SQL & " 	AND	WLC.WLC_WELCLAVE	=	'" & NUI & "' " & VbCrlf
	SQL = SQL & " 	AND	WLC.WLC_CHOCLAVE	=	'" & choclave & "' " & VbCrlf

	Session("SQL") = SQL
	array_tmp = GetArrayRS(SQL)
	
	If IsArray(array_tmp) then
		chonumero = array_tmp(0,0)
	End If
	
	If chonumero <> "" then
		SQL = ""
		'Obtener el Porcentaje por concepto
		SQL = SQL & " SELECT " & vbCrLf
		SQL = SQL & " 	  LIG.LIGPORCENTAJE_APLICA " & vbCrLf
		SQL = SQL & " 	, LIG.LIG_CLICLEF " & vbCrLf
		SQL = SQL & " 	, CLI.CLINOM " & vbCrLf
		SQL = SQL & " 	, CHO.CHONUMERO " & vbCrLf
		SQL = SQL & " 	, CHO.CHONOMBRE " & vbCrLf
		SQL = SQL & " 	, CHO2.CHONUMERO " & vbCrLf
		SQL = SQL & " 	, CHO2.CHONOMBRE " & vbCrLf
		SQL = SQL & " FROM	ELIGA_TARIFAS LIG " & vbCrLf
		SQL = SQL & " 	JOIN	ECONCEPTOSHOJA CHO " & vbCrLf
		SQL = SQL & " 		ON	CHO.CHOCLAVE	=	LIG.LIG_CHOCLAVE_APLICA " & vbCrLf
		SQL = SQL & " 	JOIN	ECONCEPTOSHOJA CHO2 " & vbCrLf
		SQL = SQL & " 		ON	CHO2.CHOCLAVE	=	LIG.LIG_CHOCLAVE " & vbCrLf
		SQL = SQL & " 	JOIN	ECLIENT CLI " & vbCrLf
		SQL = SQL & " 		ON	CLI.CLICLEF		=	LIG.LIG_CLICLEF " & vbCrLf
		SQL = SQL & " WHERE	CHO2.CHONUMERO		=	'" & chonumero & "' " & vbCrLf
		SQL = SQL & " 	AND	LIG.LIG_CLICLEF		=	'" & Session("array_client")(2,0) & "' " & vbCrLf
		
		Session("SQL") = SQL
		array_tmp = GetArrayRS(SQL)
		
		If IsArray(array_tmp) then
			porcentaje = CDbl(array_tmp(0,0))
		end if
	End If
	
	'Calcular el Monto del Concepto multiplicando el Monto de Distribucion por el Porcentaje
	res = montoNUI * (porcentaje/100)
	
	obtener_monto_x_concepto = res
end function
function obtener_monto_x_concepto_rechazo(NUI, choclave)
	dim res, porcentaje, montoNUI, chonumero
	dim SQL, array_tmp
	
	res = 0
	montoNUI = 0
	porcentaje = 0
	chonumero = ""
	
	'Obtener el monto de Distribucion (CHONUMERO => 172)
	'Obtener el CHONUMERO correspondiente a la CHOCLAVE del concepto
	'Obtener el Porcentaje por concepto
	'Calcular el Monto del Concepto multiplicando el Monto de Distribucion por el Porcentaje
	
	SQL = ""
	'Obtener el monto de Distribucion (CHONUMERO => 172)
	SQL = SQL & " SELECT	WLC.WLC_IMPORTE IMPORTE, WLC.WLCCLAVE CLAVE_CONCEPTO, WLC.WLC_WELCLAVE WELCLAVE, WLC.WLC_CHOCLAVE CHOCLAVE, " & VbCrlf
	SQL = SQL & " 		WLC.WLCSTATUS STATUS, CHO.CHONUMERO CHONUMERO, WLC.DATE_CREATED FECHA_CREACION " & VbCrlf
	SQL = SQL & " FROM	WEB_LTL_CONCEPTOS WLC " & VbCrlf
	SQL = SQL & " 	INNER JOIN	ECONCEPTOSHOJA CHO " & VbCrlf
	SQL = SQL & " 		ON	WLC.WLC_CHOCLAVE	=	CHO.CHOCLAVE " & VbCrlf
	SQL = SQL & " WHERE	CHO.CHOTIPOIE		=	'I' " & VbCrlf
	SQL = SQL & " 	AND	CHO.CHONUMERO		=	172 /* DISTRIBUCION */ " & VbCrlf
	SQL = SQL & " 	AND	WLC.WLC_WELCLAVE	=	'" & NUI & "' " & VbCrlf
	SQL = SQL & " ORDER	BY	WLC.DATE_CREATED	DESC " & VbCrlf

	Session("SQL") = SQL
	array_tmp = GetArrayRS(SQL)
	
	If IsArray(array_tmp) then
		montoNUI = CDbl(array_tmp(0,0))
	End If
	
	If montoNUI <= 0 then
		SQL = ""
		SQL = SQL & " SELECT " & VbCrlf
		SQL = SQL & "	(" & VbCrlf
		SQL = SQL & "		CASE	WHEN	LOGIS.FN_OBTEN_MONTO_DISTRIBUCION(WTS.NUI)	>	0 " & VbCrlf
		SQL = SQL & "					THEN	LOGIS.FN_OBTEN_MONTO_DISTRIBUCION(WTS.NUI) " & VbCrlf
		SQL = SQL & "				WHEN NVL(NVL(WTS.IMP_DISTRIBUCION,NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO)),0) > 0 " & VbCrlf
		SQL = SQL & "					THEN	NVL(NVL(WTS.IMP_DISTRIBUCION,NVL(WEL.WEL_PRECIO_TOTAL, WEL.WEL_PRECIO_ESTIMADO)),0) " & VbCrlf
		SQL = SQL & "				ELSE " & VbCrlf
		SQL = SQL & "			 		WEL.WELIMPORTE " & VbCrlf
		SQL = SQL & "		END " & VbCrlf
		SQL = SQL & " 	) IMPORTE " & VbCrlf
		SQL = SQL & " FROM	WEB_LTL WEL " & VbCrlf
		SQL = SQL & " 	INNER JOIN	WEB_TRACKING_STAGE WTS " & VbCrlf
		SQL = SQL & " 		ON	WEL.WELCLAVE = WTS.NUI " & VbCrlf
		SQL = SQL & " WHERE	WEL.WELCLAVE = '" & NUI & "' " & VbCrlf

		Session("SQL") = SQL
		array_tmp = GetArrayRS(SQL)
		
		If IsArray(array_tmp) then
'<<<2024078
			montoNUI = CDbl(array_tmp(0,0))
'			if array_tmp(0,0) <> "" Then
'				montoNUI = CDbl(array_tmp(0,0))
'			end if
'   2024078>>>
			'montoNUI = array_tmp(0,0)
		End If
	End If
	
	SQL = ""
	'Obtener el CHONUMERO correspondiente a la CHOCLAVE del concepto
	SQL = SQL & " SELECT	CHO.CHONUMERO, CHO.CHO_EMPCLAVE, CHO.CHOTIPOIE, CHO.CHONOMBRE, " & VbCrlf
	SQL = SQL & " 	WLC.WLCCLAVE, WLC.WLC_WELCLAVE, WLC.WLC_CHOCLAVE, WLC.WLC_IMPORTE, WLC.DATE_CREATED, WLC.WLCSTATUS " & VbCrlf
	SQL = SQL & " FROM	WEB_LTL_CONCEPTOS WLC " & VbCrlf
	SQL = SQL & " 	INNER JOIN	ECONCEPTOSHOJA CHO " & VbCrlf
	SQL = SQL & " 		ON	WLC.WLC_CHOCLAVE	=	CHO.CHOCLAVE " & VbCrlf
	SQL = SQL & " WHERE	CHO.CHOTIPOIE		=	'I' " & VbCrlf
	SQL = SQL & " 	AND	WLC.WLC_WELCLAVE	=	'" & NUI & "' " & VbCrlf
	SQL = SQL & " 	AND	WLC.WLC_CHOCLAVE	=	'" & choclave & "' " & VbCrlf

	Session("SQL") = SQL
	array_tmp = GetArrayRS(SQL)
	
	If IsArray(array_tmp) then
		chonumero = array_tmp(0,0)
	End If
		
	If chonumero = "" then
		chonumero = "174"
	End If
	
	If chonumero <> "" then
		SQL = ""
		'Obtener el Porcentaje por concepto
		SQL = SQL & " SELECT " & vbCrLf
		SQL = SQL & " 	  LIG.LIGPORCENTAJE_APLICA " & vbCrLf
		SQL = SQL & " 	, LIG.LIG_CLICLEF " & vbCrLf
		SQL = SQL & " 	, CLI.CLINOM " & vbCrLf
		SQL = SQL & " 	, CHO.CHONUMERO " & vbCrLf
		SQL = SQL & " 	, CHO.CHONOMBRE " & vbCrLf
		SQL = SQL & " 	, CHO2.CHONUMERO " & vbCrLf
		SQL = SQL & " 	, CHO2.CHONOMBRE " & vbCrLf
		SQL = SQL & " FROM	ELIGA_TARIFAS LIG " & vbCrLf
		SQL = SQL & " 	JOIN	ECONCEPTOSHOJA CHO " & vbCrLf
		SQL = SQL & " 		ON	CHO.CHOCLAVE	=	LIG.LIG_CHOCLAVE_APLICA " & vbCrLf
		SQL = SQL & " 	JOIN	ECONCEPTOSHOJA CHO2 " & vbCrLf
		SQL = SQL & " 		ON	CHO2.CHOCLAVE	=	LIG.LIG_CHOCLAVE " & vbCrLf
		SQL = SQL & " 	JOIN	ECLIENT CLI " & vbCrLf
		SQL = SQL & " 		ON	CLI.CLICLEF		=	LIG.LIG_CLICLEF " & vbCrLf
		SQL = SQL & " WHERE	CHO2.CHONUMERO		=	'" & chonumero & "' " & vbCrLf
		SQL = SQL & " 	AND	LIG.LIG_CLICLEF		=	'" & Session("array_client")(2,0) & "' " & vbCrLf

		Session("SQL") = SQL
		array_tmp = GetArrayRS(SQL)
		
		If IsArray(array_tmp) then
			porcentaje = CDbl(array_tmp(0,0))
		end if
	End If
	
	'Calcular el Monto del Concepto multiplicando el Monto de Distribucion por el Porcentaje
	res = montoNUI * (porcentaje/100)
	
	obtener_monto_x_concepto_rechazo = res
end function
function obtener_monto_x_concepto_evidencias(NUI)
	dim res
	dim SQL, array_tmp
	dim cve_emp, cant_facts, monto_evid
	
	res = 0
	cve_emp = 0
	cant_facts = 0
	monto_evid = 0
	
	' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
	' Obtener Clave de Empresa para el Cliente que esta en Session:
	cve_emp = obtener_clave_empresa(Session("array_client")(2,0))
	
	' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
	' Obtener el importe configurado por cliente:
	SQL = ""
	SQL = SQL & " SELECT	 NVL(PAD_CUOTA_POR_UNIDAD,0) PAD_CUOTA_POR_UNIDAD " & VbCrlf
	SQL = SQL & " 		,CHO.CHONUMERO CHONUMERO " & VbCrlf
	SQL = SQL & " 		,PAR.PAR_TIBCLAVE PAR_TIBCLAVE " & VbCrlf
	SQL = SQL & " 		,CLI.CLICLEF CLICLEF " & VbCrlf
	SQL = SQL & " 		,CHO.CHO_EMPCLAVE CHO_EMPCLAVE " & VbCrlf
	SQL = SQL & " FROM	ECLIENT CLI " & VbCrlf
	SQL = SQL & " 	JOIN	ECLIENT_APLICA_CONCEPTOS CCO " & VbCrlf
	SQL = SQL & " 		ON	CCO.CCO_CLICLEF		=	CLI.CLICLEF " & VbCrlf
	SQL = SQL & " 	JOIN	ECONCEPTOSHOJA CHO " & VbCrlf
	SQL = SQL & " 		ON	CHO.CHOCLAVE		=	CCO.CCO_CHOCLAVE " & VbCrlf
	SQL = SQL & " 	JOIN	EBASES_POR_CONCEPT BPC " & VbCrlf
	SQL = SQL & " 		ON	BPC.BPCCLAVE		=	CCO.CCO_BPCCLAVE " & VbCrlf
	SQL = SQL & " 	JOIN	EPARAMETRO_RESTRICT PAR " & VbCrlf
	SQL = SQL & " 		ON	PAR.PARCLAVE		=	CCO_PARCLAVE " & VbCrlf
	SQL = SQL & " 	JOIN	EPARAMETRO_DETALLE PAD " & VbCrlf
	SQL = SQL & " 		ON	PAD.PAD_PARCLAVE	=	PAR.PARCLAVE " & VbCrlf
	SQL = SQL & " WHERE	CHO.CHONUMERO		=	406		/* NÚMERO DE CONCEPTO */ " & VbCrlf
	SQL = SQL & " 	AND	PAR.PAR_TIBCLAVE	=	118		/* CLAVE DEL PARÁMETRO DE CALCULO */ " & VbCrlf
	SQL = SQL & " 	AND	CLI.CLICLEF			=	'" & Session("array_client")(2,0) & "'	/* NÚMERO DE CLIENTE */ " & VbCrlf
	SQL = SQL & " 	AND	CHO.CHO_EMPCLAVE	=	'" & cve_emp & "'	/* NÚMERO DE EMPRESA */ " & VbCrlf
	
	Session("SQL") = SQL
	array_tmp = GetArrayRS(SQL)
	
	If IsArray(array_tmp) then
		monto_evid = CDbl(array_tmp(0,0))
	End If
	
	If monto_evid > 0 then
		' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
		' Obtener la cantidad de facturas que tiene registrado el NUI:
		SQL = ""
		SQL = SQL & "SELECT	COUNT(NO_FACTURA) CANTIDAD " & vbCrLf
		SQL = SQL & "FROM	EFACTURAS_DOC " & vbCrLf
		SQL = SQL & "WHERE	NUI	=	'" & NUI & "' " & vbCrLf
		
		Session("SQL") = SQL
		array_tmp = GetArrayRS(SQL)
		
		If IsArray(array_tmp) then
			cant_facts = CDbl(array_tmp(0,0))
		End If
	End If
	
	' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
	' Calcular el monto por evidencias del NUI:
	res = monto_evid * cant_facts
	
	obtener_monto_x_concepto_evidencias = res
end function
'<<CHG-DESA-07112023-01
	function valida_cuenta(Cliente,NomCliente)
		Dim cuentas_helvex, rs3, validado
		validado = false
		
		'verificar la cuenta de un cliente.
		cuentas_helvex = "  SELECT '1' FROM ECLIENT " & vbCrLf
		cuentas_helvex = cuentas_helvex & "     WHERE 1=1" & vbCrLf
		cuentas_helvex = cuentas_helvex & "     AND CLICLEF = "& Cliente &"" & vbCrLf
		cuentas_helvex = cuentas_helvex & "     AND UPPER(CLINOM) LIKE UPPER('%"& NomCliente &"%') " & vbCrLf
		cuentas_helvex = cuentas_helvex & "     AND CLISTATUS = 0" & vbCrLf
		
		Session("SQL") = cuentas_helvex
		rs3 = GetArrayRS(cuentas_helvex)
		
		if IsArray(rs3) then
			if rs3(0,0) = "1" then
				validado = true
			end if
		end if
		
		valida_cuenta = validado
	end function
'  CHG-DESA-07112023-01>>
'<<20240117
	function es_valido_delivery_dieclave(delivery,cliente,dieclave)
		Dim res, SQL, arrConteo, arrConteo2
			res = true
		
		SQL = "select count(*) CANTIDAD " & vbCrLf
		SQL = SQL & "from efacturas_doc fd" & vbCrLf
		SQL = SQL & "    inner join web_ltl wel on fd.nui = wel.welclave" & vbCrLf
		SQL = SQL & "where upper(fd.DOCUMENTO_FUENTE) = upper('" & delivery & "')" & vbCrLf
		SQL = SQL & "    and wel.wel_cliclef = '" & cliente & "' " & vbCrLf
		
		Session("SQL") = SQL
		arrConteo = GetArrayRS(SQL)
		
		if IsArray(arrConteo) then
			if CDbl(arrConteo(0,0)) > 0 then
				SQL = "select count(*) CANTIDAD " & vbCrLf
				SQL = SQL & "from efacturas_doc fd " & vbCrLf
				SQL = SQL & "inner join web_ltl wel on fd.nui = wel.welclave " & vbCrLf
				SQL = SQL & "where upper(fd.DOCUMENTO_FUENTE) = upper('" & delivery & "') " & vbCrLf
				SQL = SQL & "and wel.WEL_DIECLAVE = '" & dieclave & "' " & vbCrLf
				
				Session("SQL") = SQL
				arrConteo2 = GetArrayRS(SQL)
				
				if IsArray(arrConteo2) then
					if CDbl(arrConteo2(0,0)) > 0 then
						res = true
					else
						res = false
					end if
				end if
			end if
		end if
		
		es_valido_delivery_dieclave = res
	end function
'  20240117>>
function es_tarifa_cuatro(num_client)
	Dim res
	Dim iEsTarifaCuatro, sqlEsTarifaCuatro, arrEsTarifaCuatro
	
	res = false
	iEsTarifaCuatro = 0
	sqlEsTarifaCuatro = ""
	
	sqlEsTarifaCuatro = sqlEsTarifaCuatro & " SELECT	ID_TIPO_TARIFA  " & vbCrLf
	sqlEsTarifaCuatro = sqlEsTarifaCuatro & " FROM		TB_CONFIG_CLIENTE_DIST " & vbCrLf
	sqlEsTarifaCuatro = sqlEsTarifaCuatro & " WHERE		ID_CLIENTE	=	'" & num_client & "' " & vbCrLf
	
	Session("SQL") = sqlEsTarifaCuatro
	arrEsTarifaCuatro = GetArrayRS(sqlEsTarifaCuatro)
	
	if IsArray(arrEsTarifaCuatro) then
		iEsTarifaCuatro = arrEsTarifaCuatro(0,0)
		
		if CStr(iEsTarifaCuatro) = "4" then
			res = true
		end if
	end if
	response.write "<div class='hidden'>" & sqlEsTarifaCuatro & "</div>"
	es_tarifa_cuatro = res
end function
function obtiene_nui_x_firma_talon(firma_talon)
	Dim res, sqlNui, arrNui, iNUI
	
	iNUI = "-1"
	sqlNui = ""
	sqlNui = sqlNui & " SELECT	WEL.WELCLAVE " & vbCrLf
	sqlNui = sqlNui & " FROM	WEB_LTL WEL " & vbCrLf
	sqlNui = sqlNui & " WHERE	UPPER(WEL.WEL_TALON_RASTREO)	=	UPPER('" & firma_talon & "') " & vbCrLf
	sqlNui = sqlNui & " 	OR	UPPER(WEL.WEL_FIRMA)	=	UPPER('" & firma_talon & "') " & vbCrLf
	sqlNui = sqlNui & " UNION " & vbCrLf
	sqlNui = sqlNui & " SELECT	WCD.WCDCLAVE " & vbCrLf
	sqlNui = sqlNui & " FROM	WCROSS_DOCK WCD " & vbCrLf
	sqlNui = sqlNui & " WHERE	UPPER(WCD.WCDFACTURA)	=	UPPER('" & firma_talon & "') " & vbCrLf
	sqlNui = sqlNui & " 	OR	UPPER(WCD.WCD_FIRMA)	=	UPPER('" & firma_talon & "') " & vbCrLf
	
	Session("SQL") = sqlNui
	arrNui = GetArrayRS(sqlNui)
	
	if IsArray(arrNui) then
		iNUI = arrNui(0,0)
	end if
	
	obtiene_nui_x_firma_talon = iNUI
end function
function existe_factura_cliente(factura,cliclef)
        Dim res, sqlValFact, arrValFact
        
        res = False
        sqlValFact = ""
        
        sqlValFact = sqlValFact & " SELECT	WELFACTURA " & vbCrLf
        sqlValFact = sqlValFact & " FROM	WEB_LTL " & vbCrLf
        sqlValFact = sqlValFact & " WHERE	WEL_CLICLEF	=	'" & cliclef & "' " & vbCrLf
        sqlValFact = sqlValFact & " 	AND	WELFACTURA	=	'" & factura & "' " & vbCrLf
        sqlValFact = sqlValFact & " 	AND	WELFACTURA	<>	'_PENDIENTE_' " & vbCrLf
        sqlValFact = sqlValFact & " 	AND	WELSTATUS	NOT	IN	(0,3) " & vbCrLf
		
		Session("SQL") = sqlValFact
		arrValFact =  GetArrayRS(sqlValFact)
		
        If IsArray(arrValFact) Then
            If CStr(arrValFact(0,0)) = CStr(factura) then
				res = True
			End If
        End If
        
        If res = False Then
			sqlValFact = ""
			sqlValFact = sqlValFact & "	SELECT	FD.NO_FACTURA " & vbCrLf
			sqlValFact = sqlValFact & "	FROM	EFACTURAS_DOC FD " & vbCrLf
			sqlValFact = sqlValFact & "		INNER JOIN	WEB_LTL WEL " & vbCrLf
			sqlValFact = sqlValFact & "			ON	FD.NUI		=	WEL.WELCLAVE " & vbCrLf
			sqlValFact = sqlValFact & "	WHERE	FD.NO_FACTURA	=	'" & factura & "' " & vbCrLf
			sqlValFact = sqlValFact & "		AND	WEL.WEL_CLICLEF	=	'" & cliclef & "' " & vbCrLf
			
			Session("SQL") = sqlValFact
			arrValFact =  GetArrayRS(sqlValFact)
			
			If IsArray(arrValFact) Then
				If CStr(arrValFact(0,0)) = CStr(factura) then
					res = True
				End If
			End If
        End If
        
        existe_factura_cliente = res
End Function
Function string_to_table(value,separator)
	Dim array_tmp
	Dim table
	
	table = value
	
	if value <> "" and separator <> "" then
		'array_tmp = Split (CStr(value), separator,-1,1)
		array_tmp = Split (CStr(value), separator)
		
		if IsArray(array_tmp) then
			table = "<table cellspacing=0 cellpadding=0>"
			for i = 0 to UBound(array_tmp)
				table = "<tr><td>" & array_tmp(i) & "</td></tr>"
			next
			table = "</table>"
		else
			table = "<table cellspacing=0 cellpadding=0><tr><td>" & value & "</td></tr></table>"
		end if
	end if
	response.write table
	string_to_table = table
End Function
function es_cross_dock(numClient)
	dim res
	dim sqlValida_CD, arrayValida_CD
	res = false
	
	'if numClient = 20235 or numClient = 22595 or numClient = 23406 or numClient = 23374 or numClient = 23264 or numClient = 23491 or numClient = 23279 or numClient = 23632 or numClient = 23579 or numClient = 23556 or numClient = 23582 or numClient = 23711 or numClient = 20501 or numClient = 20502 or numClient = 22501 then
	'	res = true
	'end if
	
	sqlValida_CD = "select FN_ES_CROSS_DOCK(" & numClient & ") from dual"
	Session("SQL") = sqlValida_CD
	arrayValida_CD =  GetArrayRS(sqlValida_CD)
	
	if IsArray(arrayValida_CD) then
		if arrayValida_CD(0,0) = "1" then
			res = true
		end if
	end if
	
	es_cross_dock = res
end function

'<<<CHG-DESA-07032024-02: Se agrega función para obtener el remitente que está ligado al usuario con que se inició sesión:
function obtener_remitente_x_cliente_usuario(CliClef)
	Dim res, sqlDis, arrDis
	
	sqlDis = ""
	sqlDis = sqlDis & " SELECT	 LCD.LCD_DISCLEF DISCLEF " & VbCrlf
	sqlDis = sqlDis & " 		,DIS.DISNOM NOMBRE " & VbCrlf
	sqlDis = sqlDis & " 		,CLI.CLICLEF CLIENTE " & VbCrlf
	sqlDis = sqlDis & " FROM	 ELOGINCLIENTE LOC " & VbCrlf
	sqlDis = sqlDis & " 	INNER JOIN	ECLIENT CLI " & VbCrlf
	sqlDis = sqlDis & " 		ON	LOC.LOCCLIENTE	=	CLI.CLICLEF " & VbCrlf
	sqlDis = sqlDis & " 	INNER JOIN	ELOGINCLIENTEDETALLE LCD " & VbCrlf
	sqlDis = sqlDis & " 		ON	LOC.LOCLOGIN	=	LCD.LCD_LOCLOGIN " & VbCrlf
	sqlDis = sqlDis & " 	INNER JOIN	EDISTRIBUTEUR DIS " & VbCrlf
	sqlDis = sqlDis & " 		ON	LCD.LCD_DISCLEF	=	DIS.DISCLEF " & VbCrlf
	sqlDis = sqlDis & " WHERE	 1	=	1 " & VbCrlf
	sqlDis = sqlDis & " 	AND	 CLI.CLICLEF	=	'" & CliClef & "' " & VbCrlf
	sqlDis = sqlDis & " 	AND	 LOC.LOCLOGIN	=	'" & Session("array_client")(0,0) & "' " & VbCrlf
	
	Session("SQL") = sqlDis
	arrDis = GetArrayRS(sqlDis)
	
	obtener_remitente_x_cliente_usuario = arrDis
end function
'   CHG-DESA-07032024-02>>>
'	<<< CHG-DESA-12032024
	Function mostrar_menu_nui(num_client)
	Dim resul
		resul = false
	'por cuenta
	if CStr(num_client) = "23345" or CStr(num_client) = "23319" then
		resul = true
	end if
	mostrar_menu_nui = resul
	End Function
'   CHG-DESA-12032024>>>
'<<< CHG-DESA-14062024: Se agregan funciones que se utilizarán para los cálculos de conceptos de facturación:
	function next_sequence(secuencia, tabla, campo)
		Dim sql_sequence, arr_sequence
		Dim max_val, curr_val, next_val, i

		'1.- Obtener el valor actual de la secuencia;
		'2.- Obtener el valor maximo del campo
		'3.- Si el valor de la secuencia es menor al valor maximo, se deberá recorrer la secuencia hasta que se empalmen los valores
		'4.- Retornar el valor siguiente de la secuencia

		sql_sequence = " SELECT	" & secuencia & ".NEXTVAL	FROM	DUAL "
		Session("SQL") = sql_sequence
		arr_sequence = GetArrayRS(sql_sequence)

		If IsArray(arr_sequence) Then
			curr_val = arr_sequence(0,0)
			next_val = arr_sequence(0,0)

			sql_sequence = " SELECT	MAX(" & campo & ")	FROM	" & tabla & " "
			Session("SQL") = sql_sequence
			arr_sequence = GetArrayRS(sql_sequence)

			If IsArray(arr_sequence) Then
				max_val = arr_sequence(0,0)

				If CDbl(curr_val) < CDBl(max_val) Then
					for i = curr_val to max_val
						sql_sequence = " SELECT	" & secuencia & ".NEXTVAL	FROM	DUAL "
						Session("SQL") = sql_sequence
						arr_sequence = GetArrayRS(sql_sequence)
					next
				End If

				sql_sequence = " SELECT	" & secuencia & ".NEXTVAL	FROM	DUAL "
				Session("SQL") = sql_sequence
				arr_sequence = GetArrayRS(sql_sequence)

				If IsArray(arr_sequence) Then
					next_val = arr_sequence(0,0)
				End If
			End If
		End If

		next_sequence = next_val
	end function
	' FUNCION OBTENER CADENA FACTURACION
	function get_cadena_facturacion(NUI,cliente)
		dim welclave
		dim cliclef
		dim SQL_DIV
		dim SQL_CHO
		dim SQL_CADENA
		dim choclv
		dim emp
		dim arrdiv ,arrchoclv,arrcadena
		dim cadena
		dim div
		dim res

		welclave = NUI
		cliclef = cliente
		cadena = ""
		res = ""
		SQL_CHO = ""
		SQL_DIV = ""
		SQL_CADENA = ""

		'obtiene choclave 
		SQL_CHO = SQL_CHO & "select GET_CHOCLAVE_TRADING(172,"& cliclef &") " & VbCrlf 
		SQL_CHO = SQL_CHO & " from dual " & VbCrlf 

		Session("SQL") = SQL_CHO
		arrchoclv = GetArrayRS(SQL_CHO)

		If IsArray(arrchoclv) Then
			choclv = arrchoclv(0,0)

			'obtiene empresa 
			emp = obtener_clave_empresa(cliclef)

			'obtener divisa por nui	
			SQL_DIV = SQL_DIV & "SELECT NVL(WEL_DIVCLEF, 'MXN') " & VbCrlf 
			SQL_DIV = SQL_DIV & "FROM WEB_LTL " & VbCrlf
			SQL_DIV = SQL_DIV & "WHERE WELCLAVE = " & welclave & " "  & VbCrlf

			Session("SQL") = SQL_DIV
			arrdiv = GetArrayRS(SQL_DIV)

			If IsArray(arrdiv) Then
				div = arrdiv(0,0)

				'obtiene cadena facturacion
				SQL_CADENA = SQL_CADENA & " SELECT GET_CADENA_IMPORTE_CONCEPTO3('WELCLAVE='|| " & welclave & " ||';CLIENTE='|| " & cliclef & "||';DIV='|| '" & arrdiv(0,0) & "' ||';CHOCLAVE='|| "& choclv &" ||';EMP='|| " & emp & " ||'') " & VbCrlf 
				SQL_CADENA = SQL_CADENA & "FROM DUAL" & VbCrlf

				Session("SQL") = SQL_CADENA
				arrcadena = GetArrayRS(SQL_CADENA)

				If IsArray(arrcadena) Then
					res = arrcadena(0,0)
				End If
			End If
		End If

		get_cadena_facturacion = res
	end function
	function registrar_observaciones_nui(nui,observaciones)
		Dim res, SQL

		SQL	=	" UPDATE	 WEB_TRACKING_STAGE	" & vbCrLf
		SQL	=	SQL	&	"	SET	 OBSERVACIONES_NUI	=	'" & observaciones & "'	" & vbCrLf
		SQL	=	SQL	&	" WHERE	 NUI	=	'" & nui & "' " & vbCrLf

		'<<<<2024-08-01: Se agrega registro en log de queries:
			registraLog_subproceso "2", SQL
		'    2024-08-01>>>>
		Session("SQL") = SQL
		set rst = Server.CreateObject("ADODB.Recordset")
		rst.Open SQL, Connect(), 0, 1, 1
		'<<<<2024-08-01: Se agrega registro en log de queries:
			registraLog_subproceso "2", "ejecutado"
		'    2024-08-01>>>>
	end function
	function obtener_info_manif_modif(CliClef,ManifNum,ManifCorte)
		Dim res, sqlManif, arrManif

		sqlManif = ""
		sqlManif = sqlManif & " SELECT	DISTINCT	 WEL_MANIF_NUM " & VbCrlf
		sqlManif = sqlManif & " 					,TO_CHAR(WEL_FECHA_RECOLECCION, 'DD/MM/YYYY HH24:MI') " & VbCrlf
		sqlManif = sqlManif & " 					,InitCap(DISNOM) " & VbCrlf
		sqlManif = sqlManif & " 					,InitCap(VILNOM) " & VbCrlf
		sqlManif = sqlManif & " 					,InitCap(ESTNOMBRE) " & VbCrlf
		sqlManif = sqlManif & " 					,WEL_CLICLEF " & VbCrlf
		sqlManif = sqlManif & " 					,WEL_DISCLEF " & VbCrlf
		sqlManif = sqlManif & " 					,TO_CHAR(WEL_MANIF_FECHA, 'DD/MM/YYYY HH24:MI') " & VbCrlf
		sqlManif = sqlManif & " 					,WEL_MANIF_CORTE " & VbCrlf
		sqlManif = sqlManif & " 					,VILCLEF " & VbCrlf
		sqlManif = sqlManif & " FROM	WEB_LTL WEL " & VbCrlf
		sqlManif = sqlManif & " 	INNER	JOIN	EDISTRIBUTEUR DIS	ON	WEL.WEL_DISCLEF		=	DIS.DISCLEF " & VbCrlf
		sqlManif = sqlManif & " 	INNER	JOIN	ECIUDADES VIL		ON	DIS.DISVILLE		=	VIL.VILCLEF " & VbCrlf
		sqlManif = sqlManif & " 	INNER	JOIN	EESTADOS EST		ON	VIL.VIL_ESTESTADO	=	EST.ESTESTADO " & VbCrlf
		sqlManif = sqlManif & " WHERE	WEL.WEL_MANIF_NUM	=	'" & SQLEscape(ManifNum) & "' " & VbCrlf
		sqlManif = sqlManif & " 	AND	WEL.WEL_CLICLEF		IN	(" & SQLEscape(CliClef) & ") " & VbCrlf

		if ManifCorte <> "" and ManifCorte <> "0" then
			sqlManif = sqlManif & " 	AND	WEL.WEL_MANIF_CORTE	=	'" & SQLEscape(ManifCorte) & "' " & VbCrlf
		end if

		Session("SQL") = sqlManif
		arrManif = GetArrayRS(sqlManif)

		obtener_info_manif_modif = arrManif
	end function
'	 CHG-DESA-14062024>>>
%>


<%
'<-- CHG-DESA-20240624-01
function ObtenRuta(ByRef Ip,ByRef Url, ByRef codigo)
	dim CnnString, Msj
	Dim CONN_STRING, CONN_USER, CONN_PASS	
	CONN_STRING = Get_Conn_string("SERVER")
	CONN_USER = Get_Conn_string("LOGIN")
	CONN_PASS = Get_Conn_string("PASS")
	
	''''''''''''''''''''''''''''''''''''''''''''''''''SP OBTEN RUTAS'''''''''''''''''''''''''''''''''''''''''''''''''
	Dim con ,cmm
	set con  = Server.CreateObject("ADODB.connection")
	con.Open CONN_STRING, CONN_USER, CONN_PASS
	

	const adCmdText = 1
	const adInteger = 3
	const adParamInput = 1
	const adVarChar = 200
	const adParamOutput = 2
	const adCmdStoredProc = 4

	'''if con.State = 1 then
	'''    response.Write "la conexion esta abierta"
	'''else
	'''    response.Write "la conexion esta cerrada"
	'''end if


	Set cmm = Server.CreateObject("ADODB.Command") 

	With cmm
		.Activeconnection = con
		.CommandType = adCmdStoredProc
		.CommandText = "LOGIS.PR_OBTEN_CONFIG_SITIO_DIST"

		.Parameters.Append cmm.CreateParameter("P_URL", adVarChar, adParamOutput, 500)
		.Parameters.Append cmm.CreateParameter("P_IP", adVarChar, adParamOutput, 500)
		.Parameters.Append cmm.CreateParameter("P_MENSAJE", adVarChar, adParamOutput, 500)
		.Parameters.Append cmm.CreateParameter("P_CODIGO_ERROR", adInteger, adParamOutput)

		.CommandTimeout = 100
		.Prepared = True
    
		.Execute

		Url = .Parameters("P_URL").Value
		Ip = .Parameters("P_IP").Value
		Msj = .Parameters("P_MENSAJE").Value
		codigo = .Parameters("P_CODIGO_ERROR").Value
	End With

	con.Close
	Set con = Nothing
	Set cmm = Nothing
	 ''''''''''''''''''''''''''''''''''''''''''''''''''TERMINA'''''''''''''''''''''''''''''''''''''''''''''''''

end function
'CHG-DESA-20240624-01 -->
'<-- CHG-DESA-19072024-01: Se agrega funcion para obtener la secuencia de una tabla.
Function siguienteSequencia(tabla, nombre_campo, nombre_sequencia)
	Dim res, actual, maximo, arrSequencia, sqlSequencia
	
	res = true
	actual = -1
	maximo = -1
	
	sqlSequencia = " SELECT " & nombre_sequencia & ".NEXTVAL FROM DUAL "
	Session("SQL") = sqlSequencia
	arrSequencia = GetArrayRS(sqlSequencia)
	
	If IsArray(arrSequencia) Then
		actual = CDbl(arrSequencia(0,0))
	End If
	
	sqlSequencia = " SELECT MAX(" & nombre_campo & ") FROM " & tabla & " "
	Session("SQL") = sqlSequencia
	arrSequencia = GetArrayRS(sqlSequencia)
	
	If IsArray(arrSequencia) Then
		maximo = CDbl(arrSequencia(0,0))
	End If
	
	If actual < maximo Then
		while actual <= maximo
			sqlSequencia = " SELECT " & nombre_sequencia & ".NEXTVAL FROM DUAL "
			Session("SQL") = sqlSequencia
			arrSequencia = GetArrayRS(sqlSequencia)
			
			If IsArray(arrSequencia) Then
				actual = CDbl(arrSequencia(0,0))
			Else
				actual = maximo
			End If
		wend
	End If
	
	siguienteSequencia = actual
End Function
'    CHG-DESA-19072024-01 -->
Function esNUIrecoleccion(NUI)
	Dim res, sqlReco, arrReco
		res = false
		sqlReco = ""
	
	sqlReco = sqlReco & " SELECT	COUNT(DISTINCT WBD.WBD_MODULO) CANTIDAD	" & vbCrLf
	sqlReco = sqlReco & " FROM	WEB_BITA_DOCUMENTA WBD	" & vbCrLf
	sqlReco = sqlReco & " WHERE	1=1	" & vbCrLf
	sqlReco = sqlReco & " 	AND	(	" & vbCrLf
	sqlReco = sqlReco & " 			UPPER(WBD.WBD_MODULO)	LIKE	'LTL_CAPTURA_ENCABEZADO3%'	" & vbCrLf
	sqlReco = sqlReco & " 			OR	" & vbCrLf
	sqlReco = sqlReco & " 			UPPER(WBD.WBD_MODULO)	LIKE	'LTL_CAPTURA_ENCABEZADO_RECO%'	" & vbCrLf
	sqlReco = sqlReco & " 		)	" & vbCrLf
	sqlReco = sqlReco & " 	AND	WBD.NUI	=	'" & NUI & "'	" & vbCrLf
	
	Session("SQL") = sqlReco
	arrReco = GetArrayRS(sqlReco)
	
	If IsArray(arrReco) Then
		If arrReco(0,0) <> "" Then
			If Cdbl(arrReco(0,0)) > 0 Then
				res = True
			End If
		End If
	End If
	
	esNUIrecoleccion = res
End Function
'<<<2024-08-01:
Function registraLog_subproceso(codigo_mensaje, mensaje_log)
	Dim sqlLogSubProceso, arrLogSubProceso, resLogSubProceso
	Dim id_proceso, id_subproceso, mensaje
		id_proceso = 4
		id_subproceso = 21
		sqlLogSubProceso = ""
		resLogSubProceso = "-1"
	
	If Session("array_client")(2,0) = "23213" Or Session("array_client")(2,0) = "23222" Or Session("array_client")(2,0) = "20123" Then
		sqlLogSubProceso = "	select FN_LOG_SUBPROCESOS_INT	(4,21,'" & SQLEscape(codigo_mensaje) & "',SUBSTR('" & SQLEscape(Session("NUI_LOG") & " - " & mensaje_log) & "',1,4000)) from dual	" & vbCrLf
		
		Session("SQL") = sqlLogSubProceso
		arrLogSubProceso = GetArrayRS(sqlLogSubProceso)
		
		If IsArray(arrLogSubProceso) Then
			resLogSubProceso = arrLogSubProceso(0,0)
		End If
	Else
		resLogSubProceso = "1"
	End If
	
	registraLog_subproceso = resLogSubProceso
End Function
'   2024-08-01>>>
%>