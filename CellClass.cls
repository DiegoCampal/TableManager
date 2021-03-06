VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CellClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'@Folder("TableManager.Cells")

Option Explicit

Private Const Module_Name As String = "CellClass."

'Private pWorksheetName As String
Private pTableName As String
Private pControl As control

' Attributes common to all table cells
Private pHeaderText As String
Private pName As String
Private pColumnWidth As Single
Private pLocked As Variant
Private pNumberFormat As Variant
Private pWrap As Boolean
Private pFormControl As control
Private pControlValue As String

' Attributes for cells with validation
Private pCellValidationType As XlDVType
Private pOperator As XlFormatConditionOperator
Private pValidAlertStyle As XlDVAlertStyle
Private pValidationFormula1 As String
Private pValidationFormula2 As String
Private pIgnoreBlank As Boolean
Private pValidationList As Variant
Private pInCellDropdown As Boolean

' Attributes for cells with validation inputs messages
Private pShowInput As Boolean
Private pInputTitle As String
Private pInputMessage As String

' Attributes for cells with error messages
Private pShowError As Boolean
Private pErrorTitle As String
Private pErrorMessage As String

Private Function ModuleList() As Variant
    ModuleList = Array("TableClass.")
End Function                                     ' ModuleList

Public Sub CollectCellData( _
       ByVal Tbl As TableClass, _
       ByVal CellID As Range, _
       ByVal ModuleName As String)

    ' CellID is a cell within the Tbl's HeaderRowRange
    ' Purpose
    '   Collects all the type data for the column under CellID
    
    Debug.Assert Initializing

    Const RoutineName As String = Module_Name & "CollectCellData"
    On Error GoTo ErrorHandler
    
    Debug.Assert InScope(ModuleList, ModuleName)
    
    On Error GoTo ErrorHandler
    
    Debug.Assert CellID.Count = 1
    
    pHeaderText = CellID
    pName = Replace(pHeaderText, " ", vbNullString)
    pTableName = Tbl.Name
    
    Dim DataCell As Range
    ' DataCell is the cell in row 1 of Tbl in the CellID column
    ' The topmost data cell in the column
    Set DataCell = CellID.Offset(1, 0)
    
    pColumnWidth = CellID.ColumnWidth
    
    Dim pDBColNum As Long
    On Error Resume Next
    pDBColNum = Application.WorksheetFunction.Match(CellID, CellID.ListObject.HeaderRowRange, 0)
    If Err.Number <> 0 Then
        pDBColNum = 0
        Exit Sub
    End If
    On Error GoTo ErrorHandler
    
    pLocked = DataCell.Locked
    pNumberFormat = DataCell.NumberFormat
    pWrap = DataCell.WrapText
    
    If HasVal(DataCell) Then
        With DataCell.Validation
            pCellValidationType = .Type
            pIgnoreBlank = .IgnoreBlank
            pValidAlertStyle = .AlertStyle
            pOperator = .Operator
            
            pInCellDropdown = .InCellDropDown
            
            pShowInput = .ShowInput
            pInputTitle = .InputTitle
            pInputMessage = .InputMessage
            
            pShowError = .ShowError
            pErrorTitle = .ErrorTitle
            pErrorMessage = .ErrorMessage
            
            pValidationFormula1 = .Formula1
            pValidationFormula2 = .Formula2
        End With                                 'DataCell.Validation
        
        If pValidationFormula1 <> vbNullString Then
            pValidationList = DataCell.Parent.Evaluate(pValidationFormula1)
            If IsError(pValidationList) Then _
                                        pValidationList = Evaluate(pValidationFormula1)
            If IsError(pValidationList) Then _
                                        pValidationList = Split(pValidationFormula1, ",")
        End If
    End If
    
    '@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description

End Sub                                          ' CollectCellData

' Attributes common to all table cells
Public Property Get HeaderText() As String: HeaderText = pHeaderText: End Property

Public Property Get Name() As String: Name = pName: End Property

Public Property Get ColumnWidth() As Single: ColumnWidth = pColumnWidth: End Property

Public Property Get Locked() As Variant: Locked = pLocked: End Property

Public Property Get NumberFormat() As Variant: NumberFormat = pNumberFormat: End Property

Public Property Get Wrap() As Boolean: Wrap = pWrap: End Property

Public Property Get FormControl() As control: Set FormControl = pFormControl: End Property

Public Property Set FormControl(ByVal vbl As control): Set pFormControl = vbl: End Property

Public Property Get ControlValue() As String: ControlValue = pControlValue: End Property

Public Property Let ControlValue(ByVal vbl As String): pControlValue = vbl: End Property

Public Property Get Length() As Long: Length = Len(pHeaderText): End Property

Public Property Get control() As control: Set control = pControl: End Property

Public Property Set control(ByVal vbl As control): Set pControl = vbl: End Property

Public Property Get TableName() As String: TableName = pTableName: End Property

' Attributes for cells with validation
Public Property Get CellType() As XlDVType: CellType = pCellValidationType: End Property

Public Property Let CellType(ByVal vbl As XlDVType): pCellValidationType = vbl: End Property

Public Property Get Operator() As XlFormatConditionOperator: Operator = pOperator: End Property

Public Property Let Operator(ByVal vbl As XlFormatConditionOperator): pOperator = vbl: End Property

Public Property Get ValidAlertStyle() As XlDVAlertStyle: ValidAlertStyle = pValidAlertStyle: End Property

Public Property Let ValidAlertStyle(ByVal vbl As XlDVAlertStyle): pValidAlertStyle = vbl: End Property

Public Property Get ValidationFormula1() As String: ValidationFormula1 = pValidationFormula1: End Property

Public Property Let ValidationFormula1(ByVal vbl As String): pValidationFormula1 = vbl: End Property

Public Property Get ValidationFormula2() As String: ValidationFormula2 = pValidationFormula2: End Property

Public Property Let ValidationFormula2(ByVal vbl As String): pValidationFormula2 = vbl: End Property

Public Property Get IgnoreBlank() As Boolean: IgnoreBlank = pIgnoreBlank: End Property

Public Property Let IgnoreBlank(ByVal vbl As Boolean): pIgnoreBlank = vbl: End Property

Public Property Get ValidationList() As Variant: ValidationList = pValidationList: End Property

Public Property Let InCellDropDown(ByVal vbl As Boolean): pInCellDropdown = vbl: End Property

Public Property Get InCellDropDown() As Boolean: InCellDropDown = pInCellDropdown: End Property

Public Property Let ValidationList(ByVal vbl As Variant): pValidationList = vbl: End Property

' Attributes for cells with validation input messages
Public Property Get ShowInput() As Boolean: ShowInput = pShowInput: End Property

Public Property Let ShowInput(ByVal vbl As Boolean): pShowInput = vbl: End Property

Public Property Get InputTitle() As String: InputTitle = pInputTitle: End Property

Public Property Let InputTitle(ByVal vbl As String): pInputTitle = vbl: End Property

Public Property Get InputMessage() As String: InputMessage = pInputMessage: End Property

Public Property Let InputMessage(ByVal vbl As String): pInputMessage = vbl: End Property

' Attributes for cells with error messages
Public Property Get ShowError() As Boolean: ShowError = pShowError: End Property

Public Property Let ShowError(ByVal vbl As Boolean): pShowError = vbl: End Property

Public Property Get ErrorTitle() As String: ErrorTitle = pErrorTitle: End Property

Public Property Let ErrorTitle(ByVal vbl As String): pErrorTitle = vbl: End Property

Public Property Get ErrorMessage() As String: ErrorMessage = pErrorMessage: End Property

Public Property Let ErrorMessage(ByVal vbl As String): pErrorMessage = vbl: End Property













