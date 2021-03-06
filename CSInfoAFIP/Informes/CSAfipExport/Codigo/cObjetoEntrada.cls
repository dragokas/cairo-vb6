VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "cObjetoEntrada"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

'--------------------------------------------------------------------------------
' cObjetoEntrada
' 16-07-2003

'--------------------------------------------------------------------------------
' notas:

'--------------------------------------------------------------------------------
' api win32
    ' constantes
    ' estructuras
    ' funciones

'--------------------------------------------------------------------------------

' constantes
Private Const C_Module = "cObjetoEntrada"

' estructuras
' variables privadas
Private m_FolderDBF    As String
' eventos
' propiedades publicas
Public Property Let FolderDBF(ByVal rhs As String)
  m_FolderDBF = rhs
End Property
' propiedades friend
' propiedades privadas
' funciones publicas
Public Function GetRecordset(ByVal sqlstmt As String, _
                             ByRef Parametros As cIAFIPParametros, _
                             ByRef rs As ADODB.Recordset, _
                             ByRef Esquema As cIAFIPEsquema) As Boolean
 
  Esquema.Log C_Module, "Sentencia recibida: " & sqlstmt, LogSevInformation
  sqlstmt = ReplaceMacros(sqlstmt, Parametros)
  Esquema.Log C_Module, "Sentencia con macros procesadas: " & sqlstmt, LogSevInformation
  
  If LenB(sqlstmt) = 0 Then
    Esquema.Log C_Module, "No se recibio una sentencia sql para obtener los datos de la exportaci�n", LogSevError
    Exit Function
  End If
  
  Esquema.Log C_Module, "Creando objeto de base de datos", LogSevInformation
  
  Dim db As cDataBase
  Set db = New cDataBase
  Esquema.Log C_Module, "Objeto de base de datos creado con exito", LogSevInformation
  
  Esquema.Log C_Module, "Abriendo conexi�n a: " & CSOAPI2.ConnectString, LogSevInformation
  If db.InitDB(, , , , CSOAPI2.ConnectString) Then
    Esquema.Log C_Module, "Conexi�n abierta con exito", LogSevInformation
  Else
    Esquema.Log C_Module, "Error al intentar abrir la conexi�n", LogSevError
    Esquema.Log C_Module, "Error:" & vbCrLf & LastErrorInfo, LogSevError
    Exit Function
  End If

  Esquema.Log C_Module, "Abriendo recordset", LogSevInformation
  If db.OpenRsEX(True, True, True, sqlstmt, rs, , , , "GetRecordset", C_Module) Then
    Esquema.Log C_Module, "Recordset abierto con exito", LogSevInformation
  Else
    Esquema.Log C_Module, "Error al intentar abrir el recordset", LogSevError
    Esquema.Log C_Module, "Error:" & vbCrLf & LastErrorInfo, LogSevError
    Exit Function
  End If
  
  ' Desconectamos el recordset
  Set rs.ActiveConnection = Nothing
  
  ' Ahora le damos la fecha (A�o Mes) al nombre del archivo
  ' Esto es propio de esta implementacion
  Esquema.NombreArchivo = Esquema.NombreArchivo & Format(GetParamValue(C_Param_FechaDesde, Parametros), "yyyymm")

  GetRecordset = True
End Function
' funciones friend
' funciones privadas
' construccion - destruccion
Private Sub Class_Initialize()
  On Error GoTo ControlError

  GoTo ExitProc
ControlError:
  MngError Err, "Class_Initialize", C_Module, ""
  If Err.Number <> 0 Then Resume ExitProc
ExitProc:
  On Error Resume Next
End Sub

Private Sub Class_Terminate()
  On Error GoTo ControlError

  GoTo ExitProc
ControlError:
  MngError Err, "Class_Terminate", C_Module, ""
  If Err.Number <> 0 Then Resume ExitProc
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
'  If Err.Number <> 0 Then Resume ExitProc
'ExitProc:
'  On Error Resume Next


