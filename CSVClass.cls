VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "CSVClass"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
'@Folder("TableManager.DataBase")

Option Explicit
Private Const Module_Name As String = "CSVClass."

Implements I_DataBase

Public Function I_DataBase_ArrayFromDataBase(ByVal Parameters As String) As Variant
    I_DataBase_ArrayFromDataBase = ArrayFromCSVfile(Parameters)
End Function

Public Sub I_DataBase_ArrayToDataBase(ByRef MyArray() As Variant, ByVal Parameters As String)
    SaveAsCSV MyArray, Parameters
End Sub

Public Sub I_DataBase_OpenDataBase()
End Sub

Public Sub I_DataBase_CloseDataBase()
End Sub

Private Function ArrayFromCSVfile( _
        ByVal FullFileName As String, _
        Optional ByVal RowDelimiter As String = vbCrLf, _
        Optional ByVal FieldDelimiter As String = ",", _
        Optional ByVal RemoveQuotes As Boolean = True _
        ) As Variant
    ' https://stackoverflow.com/questions/12259595/load-csv-file-into-a-vba-array-rather-than-excel-sheet
    ' Assumes file name ends with ".csv"
    ' Load a file created by FileToArray into a 2-dimensional array
    ' The file name is specified by strName, and it is exected to exist
    ' in the user's temporary folder. This is a deliberate restriction:
    ' it's always faster to copy remote files to a local drive than to
    ' edit them across the network

    ' RemoveQuotes=TRUE strips out the double-quote marks (Char 34) that
    ' encapsulate strings in most csv files.

    Const RoutineName As String = Module_Name & "ArrayFromCSVfile"
    On Error GoTo ErrorHandler
    
    Dim FSO As Scripting.FileSystemObject
    Dim DataArray As Variant

    Set FSO = New Scripting.FileSystemObject
    
    If Not FSO.FileExists(FullFileName) Then     ' raise an error?
        Exit Function
    End If

    Application.StatusBar = "Reading the file... (" & FullFileName & ")"

    If Not RemoveQuotes Then
        DataArray = Join2d(FSO.OpenTextFile(FullFileName, ForReading).ReadAll, RowDelimiter, FieldDelimiter)
        Application.StatusBar = "Reading the file... Done"
    Else
        ' we have to do some allocation here...
        Dim OneLine As String

        OneLine = FSO.OpenTextFile(FullFileName, ForReading).ReadAll
        Application.StatusBar = "Reading the file... Done"

        Application.StatusBar = "Parsing the file..."

        OneLine = Replace$(OneLine, Chr$(34) & RowDelimiter, RowDelimiter)
        OneLine = Replace$(OneLine, RowDelimiter & Chr$(34), RowDelimiter)
        OneLine = Replace$(OneLine, Chr$(34) & FieldDelimiter, FieldDelimiter)
        OneLine = Replace$(OneLine, FieldDelimiter & Chr$(34), FieldDelimiter)

        If Right$(OneLine, Len(OneLine)) = Chr$(34) Then
            OneLine = Left$(OneLine, Len(OneLine) - 1)
        End If

        If Left$(OneLine, 1) = Chr$(34) Then
            OneLine = Right$(OneLine, Len(OneLine) - 1)
        End If

        Application.StatusBar = "Parsing the file... Done"
        DataArray = Split2d(OneLine, RowDelimiter, FieldDelimiter)
        OneLine = vbNullString
    End If
    
    DecodeCommas DataArray

    Application.StatusBar = False

    Set FSO = Nothing
    ArrayFromCSVfile = DataArray
    Erase DataArray

    '@Ignore LineLabelNotUsed
Done:
    Exit Function
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description
End Function

Private Sub DecodeCommas(ByRef Ary As Variant)
    Dim I As Long
    Dim J As Long
    
    For I = LBound(Ary, 1) To UBound(Ary, 1)
        For J = LBound(Ary, 2) To UBound(Ary, 2)
            Ary(I, J) = Replace$(Ary(I, J), "<comma>", ",")
        Next J
    Next I
End Sub

Private Function Split2d(ByVal InputString As String, _
                         Optional ByVal RowDelimiter As String = vbCrLf, _
                         Optional ByVal FieldDelimiter As String = vbTab, _
                         Optional ByVal CoerceLowerBound As Long = 1 _
                         ) As Variant
    ' https://stackoverflow.com/questions/12259595/load-csv-file-into-a-vba-array-rather-than-excel-sheet
    ' Split up a string into a 2-dimensional array.

    ' Works like VBA.Strings.Split, for a 2-dimensional array.
    ' Check your lower bounds on return: never assume that any array in
    ' VBA is zero-based, even if you've set Option Base 0
    ' If in doubt, coerce the lower bounds to 0 or 1 by setting
    ' CoerceLowerBound
    ' Note that the default delimiters are those inserted into the
    '  string returned by ADODB.Recordset.GetString

    Const RoutineName As String = Module_Name & "Split2d"
    On Error GoTo ErrorHandler
    
    ' Coding note: we're not doing any string-handling in VBA.Strings -
    ' allocating, deallocating and (especially!) concatenating are SLOW.
    ' We're using the VBA Join & Split functions ONLY. The VBA Join,
    ' Split, & Replace functions are linked directly to fast (by VBA
    ' standards) functions in the native Windows code. Feel free to
    ' optimise further by declaring and using the Kernel string functions
    ' if you want to.

    ' ** THIS CODE IS IN THE PUBLIC DOMAIN **
    '    Nigel Heffernan   Excellerando.Blogspot.com

    Dim I   As Long
    Dim J   As Long

    Dim I_Lower As Long
    Dim J_Lower As Long

    Dim FirstRow As Long
    Dim LastRow As Long
    Dim FirstColumn As Long
    Dim LastColumn As Long

    Dim ArrayOfRows As Variant
    Dim OneRow As Variant

    ArrayOfRows = Split(InputString, RowDelimiter)

    FirstRow = LBound(ArrayOfRows)
    LastRow = UBound(ArrayOfRows)

    If Len(VBA.LenB(ArrayOfRows(LastRow))) <= 1 Then
        ' clip out empty last row: a common artifact in data
        'loaded from files with a terminating row delimiter
        LastRow = LastRow - 1
    End If

    I = FirstRow
    OneRow = Split(ArrayOfRows(I), FieldDelimiter)

    FirstColumn = LBound(OneRow)
    LastColumn = UBound(OneRow)

    If VBA.LenB(OneRow(LastColumn)) <= 0 Then
        ' ! potential error: first row with an empty last field...
        LastColumn = LastColumn - 1
    End If

    I_Lower = CoerceLowerBound - FirstRow
    J_Lower = CoerceLowerBound - FirstColumn

    Dim DataArray() As Variant
    ReDim DataArray(FirstRow + I_Lower To LastRow + I_Lower, FirstColumn + J_Lower To LastColumn + J_Lower)

    ' As we've got the first row already... populate it
    ' here, and start the main loop from lbound+1

    For J = FirstColumn To LastColumn
        DataArray(FirstRow + I_Lower, J + J_Lower) = OneRow(J)
    Next J

    For I = FirstRow + I_Lower To LastRow + I_Lower - 1

        OneRow = Split(ArrayOfRows(I), FieldDelimiter)

        For J = LBound(OneRow, 1) To UBound(OneRow, 1)
            DataArray(I + I_Lower, J + J_Lower) = OneRow(J)
        Next J

        Erase OneRow

    Next I

    Erase ArrayOfRows

    Application.StatusBar = False

    Split2d = DataArray

    '@Ignore LineLabelNotUsed
Done:
    Exit Function
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description
End Function

Private Function Join2d( _
        ByVal InputArray As Variant, _
        Optional ByVal RowDelimiter As String = vbCr, _
        Optional ByVal FieldDelimiter As String = vbTab, _
        Optional ByVal SkipBlankRows As Boolean = False _
        ) As String
    ' https://stackoverflow.com/questions/12259595/load-csv-file-into-a-vba-array-rather-than-excel-sheet
    ' Join up a 2-dimensional array into a string. Works like the standard
    '  VBA.Strings.Join, for a 2-dimensional array.
    ' Note that the default delimiters are those inserted into the string
    '  returned by ADODB.Recordset.GetString

    Const RoutineName As String = Module_Name & "Join2d"
    On Error GoTo ErrorHandler
    
    ' Coding note: we're not doing any string-handling in VBA.Strings -
    ' allocating, deallocating and (especially!) concatenating are SLOW.
    ' We're using the VBA Join & Split functions ONLY. The VBA Join,
    ' Split, & Replace functions are linked directly to fast (by VBA
    ' standards) functions in the native Windows code. Feel free to
    ' optimise further by declaring and using the Kernel string functions
    ' if you want to.

    ' ** THIS CODE IS IN THE PUBLIC DOMAIN **
    '   Nigel Heffernan   Excellerando.Blogspot.com

    Dim I As Long
    Dim J As Long

    Dim I_LBound As Long
    Dim I_UBound As Long
    Dim J_LBound As Long
    Dim J_UBound As Long

    Dim ArrayOfRows() As String
    Dim ArrayOfColumns() As String

    Dim BlankRow As String

    I_LBound = LBound(InputArray, 1)
    I_UBound = UBound(InputArray, 1)

    J_LBound = LBound(InputArray, 2)
    J_UBound = UBound(InputArray, 2)

    ReDim ArrayOfRows(I_LBound To I_UBound)
    ReDim ArrayOfColumns(J_LBound To J_UBound)

    For I = I_LBound To I_UBound

        For J = J_LBound To J_UBound
            ArrayOfColumns(J) = InputArray(I, J)
        Next J

        ArrayOfRows(I) = Join(ArrayOfColumns, FieldDelimiter)

    Next I

    If SkipBlankRows Then

        If Len(FieldDelimiter) = 1 Then
            BlankRow = String(J_UBound - J_LBound, FieldDelimiter)
        Else
            For J = J_LBound To J_UBound
                BlankRow = BlankRow & FieldDelimiter
            Next J
        End If

        Join2d = Replace(Join(ArrayOfRows, RowDelimiter), BlankRow, RowDelimiter, vbNullString)
        I = Len(BlankRow & RowDelimiter)

        If Left$(Join2d, I) = BlankRow & RowDelimiter Then
            Mid$(Join2d, 1, I) = vbNullString
        End If

    Else

        Join2d = Join(ArrayOfRows, RowDelimiter)

    End If

    Erase ArrayOfRows

    '@Ignore LineLabelNotUsed
Done:
    Exit Function
ErrorHandler:
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description
End Function

Private Sub SaveAsCSV( _
        ByRef MyArray() As Variant, _
        ByVal Filename As String, _
        Optional ByVal LowerBound As Long = 1, _
        Optional ByVal Delimiter As String = ",")
    ' https://stackoverflow.com/questions/4191560/create-csv-from-array-in-vba
    ' SaveAsCSV saves an array as csv file. Choosing a delimiter different as a comma, is optional.
    '
    ' Syntax:
    ' SaveAsCSV dMyArray, sMyFileName, [sMyDelimiter]
    '
    ' Examples:
    ' SaveAsCSV dChrom, app.path & "\Demo.csv"       --> comma as delimiter
    ' SaveAsCSV dChrom, app.path & "\Demo.csv", ";"  --> semicolon as delimiter
    '
    ' Rev. 1.00 [8 jan 2003]
    ' written by P. Wester
    ' wester@kpd.nl

    Dim I As Long                                'counter
    Dim J As Long                                'counter
    Dim OneRow As String                         'csv string to print

    Const RoutineName As String = Module_Name & "SaveACSV"
    On Error GoTo ErrorHandler
    
    Dim UpperBound1 As Long
    Dim UpperBound2 As Long
    Dim PrintString As String

    If NumberOfArrayDimensions(MyArray()) = 1 Then '1 dimensional
        Open Filename For Output As #7
        ' TODO Check the default value of lower bound of one-dimensional array
        If LowerBound = 1 Then
            UpperBound1 = UBound(MyArray(), 1)
        Else
            UpperBound1 = UBound(MyArray(), 1) - 1
        End If
        For I = LowerBound To UpperBound1
            '            Print #7, Format$(MyArray(I, 0), "0.000000E+00")
            PrintString = Replace$(MyArray(I, 0), ",", "<comma>")
            Print #7, PrintString
        Next I
        Close #7

    ElseIf NumberOfArrayDimensions(MyArray()) = 2 Then '2 dimensional
        Open Filename For Output As #7
        
        If LowerBound = 1 Then
            UpperBound1 = UBound(MyArray(), 1)
            UpperBound2 = UBound(MyArray(), 2)
        Else
            UpperBound1 = UBound(MyArray(), 1) - 1
            UpperBound2 = UBound(MyArray(), 2) - 1
        End If
        
        For I = LowerBound To UpperBound1
            OneRow = vbNullString
            For J = LowerBound To UpperBound2
                PrintString = Replace$(MyArray(I, J), ",", "<comma>")
                OneRow = OneRow & PrintString & Delimiter
            Next J
            OneRow = Left$(OneRow, Len(OneRow) - 1) 'remove last Delimiter
            Print #7, OneRow
        Next I
        Close #7
    Else
        '        Error.Raise ArrayMustBe1or2Dimensions, RoutineName, "Array must be 1 or 2 dimensions"
        '        RaiseError Err.Number, Err.Source, RoutineName, Err.Description
        RaiseError ArrayMustBe1or2Dimensions, Err.Source, RoutineName, "Array must be 1 or 2 dimensions"

    End If

    '@Ignore LineLabelNotUsed
Done:
    Exit Sub
ErrorHandler:
    Close #7
    RaiseError Err.Number, Err.Source, RoutineName, Err.Description
End Sub


