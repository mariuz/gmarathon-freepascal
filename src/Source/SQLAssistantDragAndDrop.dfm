object frmSQLAssistant: TfrmSQLAssistant
  Left = 463
  Top = 405
  ActiveControl = edRelationAlias
  BorderStyle = bsDialog
  Caption = 'SQL Assistant'
  ClientHeight = 149
  ClientWidth = 300
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
    Left = 8
    Top = 8
    Width = 73
    Height = 13
    Caption = 'Relation Name:'
  end
  object lblRelationName: TLabel
    Left = 84
    Top = 8
    Width = 77
    Height = 13
    Caption = 'lblRelationName'
  end
  object Label3: TLabel
    Left = 56
    Top = 40
    Width = 25
    Height = 13
    Caption = '&Alias:'
    FocusControl = edRelationAlias
  end
  object Bevel1: TBevel
    Left = 84
    Top = 24
    Width = 209
    Height = 6
    Shape = bsBottomLine
  end
  object edRelationAlias: TEdit
    Left = 84
    Top = 36
    Width = 209
    Height = 21
    TabOrder = 0
  end
  object chkWrapColumns: TCheckBox
    Left = 84
    Top = 64
    Width = 97
    Height = 17
    Caption = '&Wrap Columns'
    TabOrder = 1
  end
  object edColsPerLine: TEdit
    Left = 84
    Top = 88
    Width = 77
    Height = 21
    TabOrder = 2
    Text = '0'
  end
  object udColsPerLine: TUpDown
    Left = 161
    Top = 88
    Width = 12
    Height = 21
    Associate = edColsPerLine
    TabOrder = 3
  end
  object btnOK: TButton
    Left = 140
    Top = 120
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 220
    Top = 120
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
end
