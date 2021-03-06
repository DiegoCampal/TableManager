VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "EventClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Private Const Module_Name As String = "EventClass."

Private WithEvents pSheetEvent As Worksheet
Attribute pSheetEvent.VB_VarHelpID = -1

Private pTableObj As TableManager.TableClass

Private WithEvents pFormEvent As MSForms.UserForm
Attribute pFormEvent.VB_VarHelpID = -1
Private pFormObj As Object

Private WithEvents pButtonEvent As MSForms.CommandButton
Attribute pButtonEvent.VB_VarHelpID = -1
Private pButtonObj As MSForms.CommandButton

Private WithEvents pTextEvent As MSForms.TextBox
Attribute pTextEvent.VB_VarHelpID = -1
Private pTextObj As MSForms.TextBox

Private WithEvents pComboEvent As MSForms.ComboBox
Attribute pComboEvent.VB_VarHelpID = -1
Private pComboObj As MSForms.ComboBox

Private pName As String

Public Property Set SheetEvent(ByVal WS As Worksheet): Set pSheetEvent = WS: End Property

Public Property Set FormEvent(ByVal UF As MSForms.UserForm): Set pFormEvent = UF: End Property

Public Property Set ButtonEvent(ByVal CB As MSForms.CommandButton): Set pButtonEvent = CB: End Property

Public Property Set TextEvent(ByVal TB As MSForms.TextBox): Set pTextEvent = TB: End Property

Public Property Set ComboEvent(ByVal CB As MSForms.ComboBox): Set pComboEvent = CB: End Property

Public Property Set TableObj(ByVal Tbl As TableManager.TableClass)
    Debug.Assert Initializing

    Set pTableObj = Tbl
End Property

Public Property Set FormObj(ByVal FO As Object)
    Debug.Assert Initializing

    Set pFormObj = FO
    Set pFormEvent = FO.Designer
End Property

Public Property Set ButtonObj(ByVal Btn As MSForms.CommandButton)
    Debug.Assert Initializing

    Set pButtonObj = Btn
    Set pButtonEvent = Btn
End Property ' ButtonObj

Public Property Set TextObj(ByVal Txt As MSForms.TextBox)
    Debug.Assert Initializing

    Set pTextObj = Txt
    Set pTextEvent = Txt
End Property ' TextObj

Public Property Set ComboObj(ByVal Cmb As MSForms.ComboBox)
    Debug.Assert Initializing

    Set pComboEvent = Cmb
    Set pComboObj = Cmb
End Property ' ComboObj

Private Sub pFormEvent_MouseMove( _
    ByVal Button As Integer, _
    ByVal Shift As Integer, _
    ByVal x As Single, _
    ByVal y As Single)

    On Error GoTo ErrorHandler
    Const RoutineName As String = Module_Name & "FormEvent_MouseMove"
        
    Dim Ctl As Variant

    For Each Ctl In pFormObj.Controls
        If Ctl.Enabled Then
            If Left$(Ctl.Name, 5) <> "Image" Then
                If Left$(Ctl.Name, 3) = "Com" Then
                    LowLightControl Ctl
                End If
            End If
        End If
    Next Ctl

    PaintButtons
   
'@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description

End Sub ' FormEvent_MouseMove

Private Sub pButtonEvent_MouseMove( _
    ByVal Button As Integer, _
    ByVal Shift As Integer, _
    ByVal x As Single, _
    ByVal y As Single)
    
    On Error GoTo ErrorHandler
    Const RoutineName As String = Module_Name & "ButtonEvent_MouseMove"
    
    PaintButtons
    
    HighLightButton pButtonObj
        
'@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description

End Sub ' ButtonEvent_MouseMove

Private Sub pTextEvent_MouseMove( _
    ByVal Button As Integer, _
    ByVal Shift As Integer, _
    ByVal x As Single, _
    ByVal y As Single)

    On Error GoTo ErrorHandler
    Const RoutineName As String = Module_Name & "TextEvent_MouseMove"
    
    Dim Ctl As Object

    For Each Ctl In pFormObj.Controls
        If Left$(Ctl.Name, 5) <> "Image" Then
            If Left$(Ctl.Name, 3) = "Com" And Ctl.ForeColor = vbWhite Then
                LowLightButton Ctl
            End If
        End If
    Next Ctl

    PaintButtons
    
'@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description

End Sub ' TextEvent_MouseMove

Private Sub pComboEvent_MouseMove( _
    ByVal Combo As Integer, _
    ByVal Shift As Integer, _
    ByVal x As Single, _
    ByVal y As Single)

    On Error GoTo ErrorHandler
    Const RoutineName As String = Module_Name & "ComboEvent_MouseMove"
    
    Dim Ctl As Object

    For Each Ctl In pFormObj.Controls
        If Left$(Ctl.Name, 5) <> "Image" Then
            If Left$(Ctl.Name, 3) = "Com" And Ctl.ForeColor = vbWhite Then
                LowLightButton Ctl
            End If
        End If
    Next Ctl

    PaintButtons

'@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description

End Sub ' ComboEvent_MouseMove

Private Sub pSheetEvent_BeforeDoubleClick( _
    ByVal Target As Range, _
    Cancel As Boolean)
    
    Dim Isect As Range
    
    On Error GoTo ErrorHandler
    Const RoutineName As String = Module_Name & "SheetEvent_BeforeDoubleClick"
    
    Dim TableName As String
    Dim Tbl As TableManager.TableClass
    
    Cancel = True

    TableName = ActiveCellTableName
    If TableName = vbNullString Then
        MsgBox "Please select a cell in the body of the table", _
            vbOKOnly Or vbExclamation, "Select a Table Cell"
        Exit Sub
    End If
    
    Set Tbl = New TableManager.TableClass
    Set Tbl = TableItem(TableName, Module_Name)
    Set Tbl.ActiveTarget = Target
    
    Set Isect = Application.Intersect(Target, Tbl.Table.HeaderRowRange)
    If Not Isect Is Nothing Then
        MsgBox "Please select a cell in the body of the table", _
            vbOKOnly Or vbExclamation, "Selected a Header Cell"
        Exit Sub
    End If
    
    TableManager.FormNameToShow Tbl.Form.Name
    
    TableManager.PopulateForm Tbl, Module_Name
    Application.Run "ReqTracker.MainModule.ShowForm"
    Stop
    
'@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    DisplayError RoutineName

End Sub ' SheetEvent_BeforeDoubleClick

Private Sub pButtonEvent_Click()
    Dim Target As Range
    Dim TableName As String
    Dim Tbl As TableManager.TableClass
    
    Const RoutineName As String = Module_Name & "ButtonEvent_Click"
    On Error GoTo ErrorHandler
    
    TableName = ActiveCellTableName
    Set Tbl = New TableManager.TableClass
    Set Tbl = TableManager.Table(TableName, Module_Name)
    
    Select Case pButtonEvent.Caption
    Case "Validate Form"
        If TableManager.ValidateForm(Tbl, Module_Name) Then
            MsgBox "There are no validation errors in this form", _
                vbOKOnly, "Successful Copy"
        Else
            MsgBox "There is/are a validation error(s)", _
                vbOKOnly Or vbExclamation, _
                "Data Validation Error"
        End If
    
    Case "Copy To Table"
        If TableManager.ValidateForm(Tbl, Module_Name) Then
            TableManager.PopulateTable Tbl, Module_Name
            MsgBox "Form data successfully copied to Table", _
                vbOKOnly, "Successful Copy"
        Else
            MsgBox "There is/are a validation error(s). " & _
                "Correct the error then copy the Form to the Table.", _
                vbOKOnly Or vbExclamation, _
                "Data Validation Error"
        End If
    
    Case "Next Row"
        TableManager.TurnOnCellDescriptions Tbl, Module_Name
        pTableObj.NextRow
        Set pTableObj.ActiveTarget = pTableObj.ActiveTarget.Offset(0, 0)
        TableManager.PopulateForm Tbl, Module_Name
    
    Case "Previous Row"
        TableManager.TurnOnCellDescriptions Tbl, Module_Name
        pTableObj.PreviousRow
        Set pTableObj.ActiveTarget = pTableObj.ActiveTarget.Offset(0, 0)
        TableManager.PopulateForm Tbl, Module_Name
    
    Case "Insert Above"
        pTableObj.ActiveTarget.ListObject.ListRows.Add pTableObj.ActiveRow
        Set pTableObj.ActiveTarget = pTableObj.ActiveTarget.Offset(-1, 0)
        ClearForm Tbl, Module_Name
    
    Case "Insert Below"
        pTableObj.ActiveTarget.ListObject.ListRows.Add pTableObj.ActiveRow + 1
        Set pTableObj.ActiveTarget = pTableObj.ActiveTarget.Offset(1, 0)
        ClearForm Tbl, Module_Name
    
    Case "Insert at Top"
        pTableObj.ActiveTarget.ListObject.ListRows.Add 1
        Set pTableObj.ActiveTarget = pTableObj.FirstCell
        ClearForm Tbl, Module_Name
    
    Case "Insert at Bottom"
        pTableObj.ActiveTarget.ListObject.ListRows.Add
        Set pTableObj.ActiveTarget = pTableObj.LastCell
        ClearForm Tbl, Module_Name
    
    Case "Delete This Row"
        If pTableObj.LastRow = pTableObj.ActiveRow Then
            Set Target = pTableObj.ActiveTarget.Offset(-1, 0)
        Else
            Set Target = pTableObj.ActiveTarget.Offset(1, 0)
        End If
        pTableObj.ActiveTarget.ListObject.ListRows(pTableObj.ActiveRow).Delete
        Set pTableObj.ActiveTarget = Target
        PopulateForm Tbl, Module_Name
    
    Case "Go To Top"
        TableManager.TurnOnCellDescriptions pTableObj, Module_Name
        Set pTableObj.ActiveTarget = pTableObj.FirstCell
        TableManager.TurnOffCellDescriptions pTableObj, Module_Name
    
    Case "Go To Bottom"
        TableManager.TurnOnCellDescriptions pTableObj, Module_Name
        Set pTableObj.ActiveTarget = pTableObj.LastCell
        TableManager.TurnOffCellDescriptions pTableObj, Module_Name
    
    Case Is = "Cancel"
        TableManager.TurnOnCellDescriptions pTableObj, Module_Name
        pFormObj.Hide
        Exit Sub
    
    Case Else
        MsgBox _
            "This button does not exist: " & pButtonEvent.Caption & " Select another.", _
            vbOKOnly Or vbExclamation, "Button Does Not Exist"

    End Select
    
    PaintButtons
    
'@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    DisplayError RoutineName

End Sub ' ButtonEvent_Click

Private Sub PaintButtons()
'   Sets all the button colors to reflect the current state of the form

    On Error GoTo ErrorHandler
    Const RoutineName As String = Module_Name & "PaintButtons"
    
    Dim Ctl As Variant
    
    For Each Ctl In pFormObj.Controls
        With Ctl
            If Left$(.Name, 7) = "Command" Then
                EnableButton Ctl
                LowLightControl Ctl
                If .Caption = "Previous Row" And pTableObj.ActiveRow = 1 Then
                    DisableButton Ctl
                End If
                If .Caption = "Next Row" And pTableObj.ActiveRow = pTableObj.LastRow _
                Then
                    DisableButton Ctl
                End If
            End If
        End With ' Ctl
    Next Ctl
    
'@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description

End Sub ' PaintButtons

Public Property Get Name() As String: Name = pName: End Property
Public Property Let Name(ByVal NM As String): pName = NM: End Property


