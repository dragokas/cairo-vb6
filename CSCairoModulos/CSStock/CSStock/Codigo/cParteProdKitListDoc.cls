VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cParteProdKitListDoc"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Implements CSInterfacesABM.cIEditGenericListDoc
Implements CSInterfacesABM.cIABMListDocClient

'--------------------------------------------------------------------------------
' cParteProdKitListDoc
' 04-08-04

'--------------------------------------------------------------------------------
' notas:

'--------------------------------------------------------------------------------
' api win32
    ' constantes
    ' estructuras
    ' funciones

'--------------------------------------------------------------------------------

' constantes
Private Const C_Module = "cParteProdKitListDoc"

Private Const c_FechaIni = "FechaIni"
Private Const c_FechaFin = "FechaFin"

Private Const c_img_task = 1

' ACA VAN LAS K GENERADAS POR EL ASISTENTE.
Private Const K_FECHAINI                       As Integer = 1
Private Const K_FECHAFIN                       As Integer = 2
Private Const K_LGJ_ID                         As Integer = 7
Private Const K_SUC_ID                         As Integer = 8
Private Const K_DOC_ID                         As Integer = 9
' empid
Private Const K_EMP_ID                         As Integer = 100
' estructuras
' variables privadas
Private m_FechaIni                       As Date
Private m_FechaFin                       As Date
Private m_doc_id                         As String
Private m_Documento                      As String
Private m_suc_id                         As String
Private m_Sucursal                       As String
Private m_lgj_id                         As String
Private m_Legajo                         As String
' empid
Private m_emp_id                         As String
Private m_Empresa                        As String
Private m_FechaIniV                      As String
Private m_FechaFinV                      As String

' ACA VAN LAS m_ GENERADAS POR EL ASISTENTE.

'OJO HASTA ACA

Private m_ObjAbm            As cIABMGenericListDoc
Private m_ObjList           As Object
Private m_Us_id             As Long
Private m_Properties        As cABMDocProperties

Private m_Title             As String

Private m_MenuLoaded        As Boolean

Private m_MenuShowMensajes  As Long
Private m_MenuAddMensaje    As Long
Private m_MenuShowDocAux    As Long

' Properties publicas
' Properties privadas
' funciones publicas
Public Function ProcessMenu(ByVal Index As Long)
  On Error GoTo ControlError

  Select Case Index
    
    Case m_MenuShowMensajes
      pShowMensajes
      
    Case m_MenuAddMensaje
      pAddMensaje
      
    Case m_MenuShowDocAux
      pShowDocAux
    
  End Select

  GoTo ExitProc
ControlError:
  MngError Err, "ProcessMenu", C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Function

' Implementacion de cIABMClient

' funciones privadas

Private Function LoadCollection() As Boolean
  Dim c As cIABMProperty
  Dim o As cIABMListItem
  Dim Value As String
  Dim bExists As Boolean

  m_ObjAbm.Properties.Clear

  Set c = m_ObjAbm.Properties.Add(Nothing, c_FechaIni)
  c.PropertyType = cspDate
  c.Name = LNGGetText(1203, vbNullString)   'Fecha desde
  c.Key = K_FECHAINI
  If LenB(m_FechaIniV) Then
    c.Value = m_FechaIniV
  Else
    c.Value = m_FechaIni
  End If
  

  Set c = m_ObjAbm.Properties.Add(Nothing, c_FechaFin)
  c.PropertyType = cspDate
  c.Name = LNGGetText(1204, vbNullString)   'Fecha hasta
  c.Key = K_FECHAFIN
  If LenB(m_FechaFinV) Then
    c.Value = m_FechaFinV
  Else
    c.Value = m_FechaFin
  End If
  

  Set c = m_ObjAbm.Properties.Add(Nothing, cscDocId)
  c.PropertyType = cspHelp
  c.Table = csETablasDocumento.CSDocumento
  c.Name = LNGGetText(1611, vbNullString)   'Documentos
  c.Key = K_DOC_ID
  Value = m_Documento
  If UCase(Left$(m_doc_id, 1)) = KEY_NODO Then
    Value = GetNombreRama(csETablasDocumento.CSDocumento, Val(Mid(m_doc_id, 2)), bExists)
    If Not bExists Then m_doc_id = "0"
  End If
  c.Value = Value
  c.HelpId = Val(m_doc_id)
  c.HelpValueProcess = m_doc_id
  c.HelpFilter = "'{emp_id=0}doct_id = " & csEDT_ParteProdKit & "'"
  

  Set c = m_ObjAbm.Properties.Add(Nothing, cscSucId)
  c.PropertyType = cspHelp
  c.Table = csSucursal
  c.Name = LNGGetText(1281, vbNullString)   'Sucursal
  c.Key = K_SUC_ID
  Value = m_Sucursal
  If UCase(Left$(m_suc_id, 1)) = KEY_NODO Then
    Value = GetNombreRama(csSucursal, Val(Mid(m_suc_id, 2)), bExists)
    If Not bExists Then m_suc_id = "0"
  End If
  c.Value = Value
  c.HelpId = Val(m_suc_id)
  c.HelpValueProcess = m_suc_id
  

  Set c = m_ObjAbm.Properties.Add(Nothing, cscLgjId)
  c.PropertyType = cspHelp
  c.Table = csLegajo
  c.Name = LNGGetText(1575, vbNullString)   'Legajo
  c.Key = K_LGJ_ID
  Value = m_Legajo
  If UCase(Left$(m_lgj_id, 1)) = KEY_NODO Then
    Value = GetNombreRama(csLegajo, Val(Mid(m_lgj_id, 2)), bExists)
    If Not bExists Then m_lgj_id = "0"
  End If
  c.Value = Value
  c.HelpId = Val(m_lgj_id)
  c.HelpValueProcess = m_lgj_id
  

  ' empid
  Set c = m_ObjAbm.Properties.Add(Nothing, cscEmpId)
  c.PropertyType = cspHelp
  c.Table = csEmpresa
  c.Name = LNGGetText(1114, vbNullString)   'Empresa
  c.Key = K_EMP_ID
  Value = m_Empresa
  If UCase(Left$(m_emp_id, 1)) = KEY_NODO Then
    Value = GetNombreRama(csEmpresa, Val(Mid(m_emp_id, 2)), bExists)
    If Not bExists Then m_emp_id = "0"
  End If
  c.Value = Value
  c.HelpId = Val(m_emp_id)
  c.HelpValueProcess = m_emp_id
  
  pCreateMenu
  If Not m_ObjAbm.Show(Me, m_ObjList) Then Exit Function

  LoadCollection = True
End Function

Private Function Load(ByVal us_id As Long) As Boolean
  Dim sqlstmt As String
  Dim rs      As Recordset
  
  sqlstmt = "select * from ListaDocumentoParametro " & _
            " where us_id = " & us_id & _
              " and pre_id = " & csPreStListParteProdKit & _
              " and (emp_id is null or emp_id = " & EmpId & ")" & _
            " order by " & cscLdpOrden

  If Not gDB.OpenRs(sqlstmt, rs, csRsStatic, csLockReadOnly, csCmdText, C_LoadFunction, C_Module) Then Exit Function

  ' empid
  m_emp_id = EmpId
  m_Empresa = EmpNombre
  
  If rs.EOF Then
    
    m_FechaIni = Date
    m_FechaFin = Date
    m_doc_id = csNO_ID
    m_Documento = vbNullString
    m_Sucursal = vbNullString
    m_Legajo = vbNullString
    
  Else

    rs.MoveLast
    rs.MoveFirst

    Dim i As Integer
    While Not rs.EOF

      Select Case gDB.ValField(rs.Fields, cscLdpId)
        
        Case K_FECHAINI
          m_FechaIniV = gDB.ValField(rs.Fields, cscLdpValor)
          m_FechaIni = IIf(IsDate(gDB.ValField(rs.Fields, cscLdpValor)), gDB.ValField(rs.Fields, cscLdpValor), Date)
        
        Case K_FECHAFIN
          m_FechaFinV = gDB.ValField(rs.Fields, cscLdpValor)
          m_FechaFin = IIf(IsDate(gDB.ValField(rs.Fields, cscLdpValor)), gDB.ValField(rs.Fields, cscLdpValor), Date)
        
        Case K_DOC_ID
          m_doc_id = gDB.ValField(rs.Fields, cscLdpValor)
        
        Case K_SUC_ID
          m_suc_id = gDB.ValField(rs.Fields, cscLdpValor)
        
        Case K_LGJ_ID
          m_lgj_id = gDB.ValField(rs.Fields, cscLdpValor)
        
        ' empid
        Case K_EMP_ID
          m_emp_id = gDB.ValField(rs.Fields, cscLdpValor)
      
      End Select

      rs.MoveNext
    Wend

    Dim Data As String
    Dim strLoad As String
    
    strLoad = LNGGetText(2258, vbNullString)  'Error al cargar los parámetros de navegación de Partes de Producción de Kit
    
    m_FechaIni = IIf(m_FechaIni <> csNoDate, m_FechaIni, Date)
    m_FechaFin = IIf(m_FechaFin <> csNoDate, m_FechaFin, Date)


' OJO: EL ASISTENTE ESTO LO HACE MAL, YA QUE EL CODIGO QUE GENERA NO SOPORTA ARBOLES
'      USEN ESTE CODIGO COMO EJ. OJO!!! CAMBIEN LOS NOMBRES DE LAS TABLAS Y LOS CAMPOS NOMBRES DE DICHAS TABLAS.
    If UCase(Left$(m_doc_id, 1)) <> KEY_NODO Then
      If Not gDB.GetData(csTDocumento, cscDocId, Val(m_doc_id), cscDocNombre, Data, C_LoadFunction, C_Module, strLoad) Then Exit Function
      m_Documento = Data
    End If
    If UCase(Left$(m_suc_id, 1)) <> KEY_NODO Then
      If Not gDB.GetData(csTSucursal, cscSucId, Val(m_suc_id), cscSucNombre, Data, C_LoadFunction, C_Module, strLoad) Then Exit Function
      m_Sucursal = Data
    End If
    If UCase(Left$(m_lgj_id, 1)) <> KEY_NODO Then
      If Not gDB.GetData(csTLegajo, cscLgjId, Val(m_lgj_id), cscLgjCodigo, Data, C_LoadFunction, C_Module, strLoad) Then Exit Function
      m_Legajo = Data
    End If
    ' empid
    If UCase(Left$(m_emp_id, 1)) <> KEY_NODO Then
      If Not gDB.GetData(csTEmpresa, cscEmpId, Val(m_emp_id), cscEmpNombre, Data, C_LoadFunction, C_Module, strLoad) Then Exit Function
      m_Empresa = Data
    End If
  
  End If

  Load = True
End Function
' construccion - destruccion

Private Property Get cIABMListDocClient_Aplication() As String
  cIABMListDocClient_Aplication = gAppName
End Property

Private Sub cIABMListDocClient_DiscardChanges()
  LoadCollection
End Sub

Private Function cIABMListDocClient_ListAdHock(List As CSInterfacesABM.cIABMList) As Boolean

End Function

Private Sub cIABMListDocClient_Load()

End Sub

Private Property Get cIABMListDocClient_Properties() As Object
  Set cIABMListDocClient_Properties = m_Properties
End Property


' OJO: NUEVAMENTE LA EXISTENCIA DE FECHAS VIRTUALES HACE QUE EL CODIGO GENERADO POR EL ASISTENTE ESTE MAL
'      CORRIJALO UTILIZANDO ESTE CODIGO COMO EJEMPLO.
Private Function cIABMListDocClient_PropertyChange(ByVal Key As Integer) As Boolean
  Dim iProp     As cIABMProperty
  
  Select Case Key

    Case K_FECHAINI
      
      Set iProp = m_ObjAbm.Properties(c_FechaIni)
  
      If iProp.HelpValueProcess <> vbNullString Then
        m_FechaIniV = iProp.HelpValueProcess
        m_FechaIni = VDGetDateByName(m_FechaIniV)
      ElseIf IsDate(iProp.Value) Then
        m_FechaIniV = vbNullString
        m_FechaIni = iProp.Value
      Else
        m_FechaIniV = vbNullString
        iProp.Value = m_FechaIni
      End If
  
    Case K_FECHAFIN
      
      Set iProp = m_ObjAbm.Properties(c_FechaFin)
      
      If iProp.HelpValueProcess <> vbNullString Then
        m_FechaFinV = iProp.HelpValueProcess
        m_FechaFin = VDGetDateByName(m_FechaFinV)
      ElseIf IsDate(iProp.Value) Then
        m_FechaFinV = vbNullString
        m_FechaFin = iProp.Value
      Else
        m_FechaFinV = vbNullString
        iProp.Value = m_FechaFin
      End If
    
    Case K_DOC_ID
      With m_ObjAbm.Properties(cscDocId)
        m_Documento = .Value
        m_doc_id = .HelpValueProcess
      End With
  
    Case K_SUC_ID
      With m_ObjAbm.Properties(cscSucId)
        m_Sucursal = .Value
        m_suc_id = .HelpValueProcess
      End With
  
    Case K_LGJ_ID
      With m_ObjAbm.Properties(cscLgjId)
        m_Legajo = .Value
        m_lgj_id = .HelpValueProcess
      End With
    
    ' empid
    Case K_EMP_ID
      With m_ObjAbm.Properties(cscEmpId)
        m_Empresa = .Value
        m_emp_id = .HelpValueProcess
      End With
  End Select

  cIABMListDocClient_PropertyChange = True
End Function

Private Function cIABMListDocClient_Refresh() As String
  Dim sqlstmt As String

  sqlstmt = "sp_lsdoc_ParteProdKits "

  sqlstmt = sqlstmt & gDB.UserId & ","


  If Not DateNames(m_FechaIniV) Is Nothing Then
    sqlstmt = sqlstmt & gDB.sqlDate(VDGetDateByName(m_FechaIniV)) & ","
  Else
    sqlstmt = sqlstmt & gDB.sqlDate(m_FechaIni) & ","
  End If
  
  If Not DateNames(m_FechaFinV) Is Nothing Then
    sqlstmt = sqlstmt & gDB.sqlDate(VDGetDateByName(m_FechaFinV)) & ","
  Else
    sqlstmt = sqlstmt & gDB.sqlDate(m_FechaFin) & ","
  End If
  
  sqlstmt = sqlstmt & gDB.sqlString(m_doc_id) & ","
  sqlstmt = sqlstmt & gDB.sqlString(m_suc_id) & ","
  sqlstmt = sqlstmt & gDB.sqlString(m_lgj_id) & ","
  sqlstmt = sqlstmt & gDB.sqlString(m_emp_id)

  cIABMListDocClient_Refresh = sqlstmt
End Function

Private Function cIABMListDocClient_Save() As Boolean

  Dim strError As String
  
  strError = LNGGetText(2257, vbNullString) 'Error al grabar los parámetros de navegación de Partes de Producción de Kit

  Dim register As cRegister
  Set register = New cRegister

  Dim sqlstmt As String
  
  sqlstmt = "delete ListaDocumentoParametro " & _
            " where pre_id = " & csPreStListParteProdKit & _
              " and us_id = " & m_Us_id & _
              " and (emp_id is null or emp_id = " & EmpId & ")"

  If Not gDB.Execute(sqlstmt, "cIABMClient_Save", C_Module, strError) Then Exit Function

  register.Table = csTListaDocumentoParametro
  register.UtilizaIdentity = True

  Dim IProperty As cIABMProperty
  For Each IProperty In m_ObjAbm.Properties

    register.Fields.Clear

    With IProperty
      Select Case .Key

         Case K_FECHAINI
          If .HelpValueProcess <> vbNullString Then
            register.Fields.Add2 cscLdpValor, .HelpValueProcess, csText
          Else
            register.Fields.Add2 cscLdpValor, .Value, csText
          End If
          
          register.Fields.Add2 cscLdpOrden, 10, csInteger
          register.Fields.Add2 cscLdpId, K_FECHAINI, csInteger
        Case K_FECHAFIN

          If .HelpValueProcess <> vbNullString Then
            register.Fields.Add2 cscLdpValor, .HelpValueProcess, csText
          Else
            register.Fields.Add2 cscLdpValor, .Value, csText
          End If

          register.Fields.Add2 cscLdpOrden, 20, csInteger
          register.Fields.Add2 cscLdpId, K_FECHAFIN, csInteger

        Case K_DOC_ID
            register.Fields.Add2 cscLdpValor, .HelpValueProcess, csText
            register.Fields.Add2 cscLdpOrden, 30, csInteger
            register.Fields.Add2 cscLdpId, K_DOC_ID, csInteger
      
        Case K_SUC_ID
            register.Fields.Add2 cscLdpValor, .HelpValueProcess, csText
            register.Fields.Add2 cscLdpOrden, 40, csInteger
            register.Fields.Add2 cscLdpId, K_SUC_ID, csInteger
      
        Case K_LGJ_ID
            register.Fields.Add2 cscLdpValor, .HelpValueProcess, csText
            register.Fields.Add2 cscLdpOrden, 50, csInteger
            register.Fields.Add2 cscLdpId, K_LGJ_ID, csInteger
        
        ' empid
        Case K_EMP_ID
            register.Fields.Add2 cscLdpValor, .HelpValueProcess, csText
            register.Fields.Add2 cscLdpOrden, 100, csInteger
            register.Fields.Add2 cscLdpId, K_EMP_ID, csInteger
      
      End Select
      
      ' empid
      register.Fields.Add2 cscEmpId, EmpId, csId
      
      register.Fields.Add2 cscUsId, m_Us_id, csId
      register.Fields.Add2 cscPreID, csPreStListParteProdKit, csId

      register.Fields.HaveLastUpdate = False
      register.Fields.HaveWhoModify = False
      If Not gDB.Save(register, , "cIABMClient_Save", C_Module, strError) Then Exit Function
    End With
  Next
  
  If Not Load(m_Us_id) Then Exit Function

  cIABMListDocClient_Save = True
End Function

Private Function cIABMListDocClient_Terminate() As Boolean
  cIABMListDocClient_Terminate = True
End Function

Private Property Get cIABMListDocClient_Title() As String
  cIABMListDocClient_Title = m_Title
End Property

Private Function cIABMListDocClient_Validate() As Boolean
  cIABMListDocClient_Validate = True
End Function

Private Function cIEditGenericListDoc_GridAdd(ByVal KeyProperty As Integer) As Boolean

End Function

Private Function cIEditGenericListDoc_GridEdit(ByVal KeyProperty As Integer) As Boolean

End Function

Private Function cIEditGenericListDoc_GridRemove(ByVal KeyProperty As Integer) As Boolean

End Function

Private Property Set cIEditGenericListDoc_ObjABM(rhs As CSInterfacesABM.cIABMGenericListDoc)
  Set m_ObjAbm = rhs
End Property

Private Property Set cIEditGenericListDoc_ObjList(rhs As Object)
  Set m_ObjList = rhs
End Property

Private Function cIEditGenericListDoc_PropertyChange(ByVal Key As Integer) As Boolean
End Function

Private Function cIEditGenericListDoc_ShowParams(ByVal us_id As Long) As Boolean
  On Error GoTo ControlError
  
  If us_id = csNO_ID Then Exit Function

  m_Us_id = us_id
  
  If Not Load(us_id) Then Exit Function
  
  If Not LoadCollection() Then Exit Function
  
  cIEditGenericListDoc_ShowParams = True
  Exit Function
ControlError:
  MngError Err, "cIEditGenericListDoc_ShowParams", C_Module, vbNullString
End Function

Private Function cIEditGenericListDoc_TabClick(ByVal Index As Integer) As Boolean

End Function

Private Sub Class_Initialize()
  On Error GoTo ControlError
 
  m_Title = LNGGetText(1993, vbNullString) ' Partes de Producción de Kit
 
  Set m_Properties = New cABMDocProperties
  With m_Properties
    'Set .ImageList = fIcons.iList
    .HaveDetail = True
    .StartRowText = 4
    
    With .Columns.Add(Nothing, "TypeTask")
      .Name = "TypeTask"
      .Caption = " "
      With .Icons.Add(Nothing)
      .FormulaType = csCondTNone
      .IconIndex = c_img_task
      End With
      .Width = 500
      .SortType = csSrtTIcon
    End With
    
    With .Columns.Add(Nothing, "Observaciones")
      .Name = "Observaciones"
      .FontName = "Tahoma"
      .FontSize = 8
      .ForeColor = vbBlue
    End With
  End With
  
  GoTo ExitProc
ControlError:
  MngError Err, "Class_Terminate", C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Sub

Private Sub Class_Terminate()
  On Error GoTo ControlError
  
  Set m_ObjAbm = Nothing
  Set m_ObjList = Nothing
  Set m_Properties = Nothing

  GoTo ExitProc
ControlError:
  MngError Err, "Class_Terminate", C_Module, vbNullString
  If Err.Number Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Sub

'//////////////////////////////
'  Codigo estandar de errores
'  On Error GoTo ControlError
'
'  GoTo ExitProc
'ControlError:
'  MngError err,"", C_Module, ""
'  If Err.Number Then Resume ExitProc
'ExitProc:
'  On Error Resume Next

Private Sub pCreateMenu()
  On Error Resume Next
  
  If m_MenuLoaded Then Exit Sub
  
  m_MenuLoaded = True
  
  With m_ObjList
    Set .ObjClientMenu = Me
    .ClearMenu
    m_MenuAddMensaje = .AddMenu(LNGGetText(1645, vbNullString))   'Agregar Nota
    m_MenuShowMensajes = .AddMenu(LNGGetText(1616, vbNullString)) 'Ver Notas
    m_MenuShowDocAux = .AddMenu(LNGGetText(1691, vbNullString))   'Ver Documento Asociado
  End With
End Sub

Private Sub pShowMensajes()
  Dim sqlstmt As String
  Dim PpkId    As Long
  Dim rs      As ADODB.Recordset
  
  PpkId = m_ObjList.Id
  
  sqlstmt = "sp_ParteDiarioGetTitleForDoc " & csEDT_ParteProdKit & "," & PpkId
  
  If Not gDB.OpenRs(sqlstmt, rs) Then Exit Sub
  
  If rs.EOF Then Exit Sub
  
  Dim infodoc As String
  Dim DoctId  As Long
  
  DoctId = gDB.ValField(rs.Fields, cscDoctId)
  infodoc = gDB.ValField(rs.Fields, "info_doc")
  sqlstmt = "sp_PartesDiarioGetForDoc " & gDB.UserId & "," & EmpId & "," & DoctId & "," & PpkId
  ShowNotes LNGGetText(2004, vbNullString, infodoc), sqlstmt
            'Notas sobre Parte Prod. Kit (1)
End Sub

Private Sub pAddMensaje()
  Dim Parte As Object
  Set Parte = CSKernelClient2.CreateObject("CSEnvio2.cParteDiario")
  
  Parte.AddParteToDoc csEDT_ParteProdKit, m_ObjList.Id, False
End Sub

Private Sub pShowDocAux()
  
  Dim PpkId As Long
  PpkId = m_ObjList.Id
  
  If PpkId Then
  
    Dim StId1 As Long
    Dim StId2 As Long
    
    If Not gDB.GetData(csTParteProdKit, cscPpkId, PpkId, cscStId1, StId1) Then Exit Sub
    If Not gDB.GetData(csTParteProdKit, cscPpkId, PpkId, cscStId2, StId2) Then Exit Sub
    
    If StId1 = csNO_ID And StId2 = csNO_ID Then
    
      MsgInfo LNGGetText(1693, vbNullString)
              'Este comprobante no tiene un documento de stock asociado.
    Else
    
      If StId1 <> csNO_ID Then
        If Ask(LNGGetText(2005, vbNullString), vbYes) Then
              'Desea ver el consumo?
          ShowDocAux StId1, _
                     "CSStock2.cStock", _
                     "CSABMInterface2.cABMGeneric"
        End If
      End If
      
      If StId2 <> csNO_ID Then
        If Ask(LNGGetText(2006, vbNullString), vbYes) Then
              'Desea ver lo producido ?
          ShowDocAux StId2, _
                     "CSStock2.cStock", _
                     "CSABMInterface2.cABMGeneric"
        End If
      End If
    End If
  End If

End Sub
