object frmSelectConnection: TfrmSelectConnection
  Left = 425
  Top = 281
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Select Connection'
  ClientHeight = 98
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 15
    Width = 57
    Height = 13
    Caption = '&Connection:'
    FocusControl = cmbConnections
  end
  object cmbConnections: TComboBox
    Left = 64
    Top = 12
    Width = 257
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 244
    Top = 68
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnOK: TButton
    Left = 164
    Top = 68
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
end
