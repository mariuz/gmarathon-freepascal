object frmAddWatch: TfrmAddWatch
  Left = 376
  Top = 274
  BorderStyle = bsDialog
  Caption = 'Add Watch'
  ClientHeight = 92
  ClientWidth = 379
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
    Top = 16
    Width = 54
    Height = 13
    Caption = '&Expression:'
    FocusControl = cmbVariable
  end
  object cmbVariable: TComboBox
    Left = 64
    Top = 12
    Width = 229
    Height = 21
    ItemHeight = 13
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 300
    Top = 12
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 300
    Top = 40
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object chkEnabled: TCheckBox
    Left = 64
    Top = 48
    Width = 97
    Height = 17
    Caption = 'Enabled'
    Checked = True
    State = cbChecked
    TabOrder = 3
  end
end
