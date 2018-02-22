VERSION 5.00
Begin {C62A69F0-16DC-11CE-9E98-00AA00574A4F} PlainDataBaseForm 
   Caption         =   "Save and Restore Table Data"
   ClientHeight    =   2895
   ClientLeft      =   120
   ClientTop       =   450
   ClientWidth     =   4560
   OleObjectBlob   =   "PlainDataBaseForm.frx":0000
   StartUpPosition =   1  'CenterOwner
End
Attribute VB_Name = "PlainDataBaseForm"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
Option Explicit

Implements I_CopyFetchFormView

Private Type pTView
    Model As CopyFetchClass
    IsCancelled As Boolean
    FileName As String
End Type

Private pThis As pTView

Public Property Let I_CopyFetchFormView_Source(ByVal Src As String)
    pThis.FileName = Src
End Property

Public Property Let I_CopyFetchFormView_Destination(ByVal Dst As String)
    pThis.FileName = Dst
End Property

Private Function I_CopyFetchFormView_ShowDialog(ByVal viewModel As Object) As Boolean
    FileNameBox.Text = pThis.FileName
    Set pThis.Model = viewModel
    Show
    I_CopyFetchFormView_ShowDialog = Not pThis.IsCancelled
End Function

Private Property Set I_CopyFetchFormView_Model(ByVal CFC As CopyFetchClass)
    Set pThis.Model = CFC
End Property

Private Property Get I_CopyFetchFormView_Form() As UserForm
    Set I_CopyFetchFormView_Form = PlainDataBaseForm
End Property

Private Sub CopyButton_Click()
    pThis.Model.CopyClicked = True
    Me.Hide
End Sub

Private Sub FetchButton_Click()
    pThis.Model.FetchClicked = True
    Me.Hide
End Sub

Private Property Get I_CopyFetchFormView_Model() As CopyFetchClass
    Set I_CopyFetchFormView_Model = pThis.Model
End Property

Private Sub CancelButton_Click()
    OnCancel
End Sub

Private Sub UserForm_QueryClose(Cancel As Integer, CloseMode As Integer)
    If CloseMode = VbQueryClose.vbFormControlMenu Then
        Cancel = True
        OnCancel
    End If
End Sub

Private Sub OnCancel()
    pThis.IsCancelled = True
    Hide
    
    FileNameBox = vbNullString
End Sub

Private Sub UserForm_Activate()
    With Me
        .Left = Application.Left + (0.5 * Application.Width) - (0.5 * .Width)
        .Top = Application.Top + (0.5 * Application.Height) - (0.5 * .Height)
    End With
End Sub



