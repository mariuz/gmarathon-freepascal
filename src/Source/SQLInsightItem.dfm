object frmSQLInsight: TfrmSQLInsight
  Left = 332
  Top = 304
  BorderStyle = bsDialog
  Caption = 'frmSQLInsight'
  ClientHeight = 91
  ClientWidth = 335
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 20
    Top = 12
    Width = 43
    Height = 13
    Caption = '&Shortcut:'
    FocusControl = edShortCut
  end
  object Label2: TLabel
    Left = 8
    Top = 48
    Width = 56
    Height = 13
    Caption = '&Description:'
    FocusControl = edDescription
  end
  object btnOK: TButton
    Left = 256
    Top = 4
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 256
    Top = 36
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object edShortCut: TEdit
    Left = 68
    Top = 8
    Width = 177
    Height = 21
    TabOrder = 2
  end
  object edDescription: TEdit
    Left = 68
    Top = 44
    Width = 177
    Height = 21
    TabOrder = 3
  end
end
