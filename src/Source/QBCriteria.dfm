object frmCriteria: TfrmCriteria
  Left = 300
  Top = 196
  ActiveControl = edExpression
  BorderStyle = bsDialog
  Caption = 'Build Criteria'
  ClientHeight = 148
  ClientWidth = 425
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnPlus: TSpeedButton
    Left = 4
    Top = 84
    Width = 13
    Height = 25
    Caption = '+'
    Flat = True
  end
  object btnMinus: TSpeedButton
    Left = 17
    Top = 84
    Width = 13
    Height = 25
    Caption = '-'
    Flat = True
  end
  object btnDivide: TSpeedButton
    Left = 30
    Top = 84
    Width = 13
    Height = 25
    Caption = '/'
    Flat = True
  end
  object btnMult: TSpeedButton
    Left = 43
    Top = 84
    Width = 13
    Height = 25
    Caption = '*'
    Flat = True
  end
  object btnEquals: TSpeedButton
    Left = 61
    Top = 84
    Width = 13
    Height = 25
    Caption = '='
    Flat = True
  end
  object btnLThan: TSpeedButton
    Left = 74
    Top = 84
    Width = 13
    Height = 25
    Caption = '<'
    Flat = True
  end
  object btnGThan: TSpeedButton
    Left = 87
    Top = 84
    Width = 13
    Height = 25
    Caption = '>'
    Flat = True
  end
  object btnNotEqual: TSpeedButton
    Left = 100
    Top = 84
    Width = 20
    Height = 25
    Caption = '<>'
    Flat = True
  end
  object btnAND: TSpeedButton
    Left = 124
    Top = 84
    Width = 25
    Height = 25
    Caption = 'AND'
    Flat = True
  end
  object btnOr: TSpeedButton
    Left = 149
    Top = 84
    Width = 25
    Height = 25
    Caption = 'OR'
    Flat = True
  end
  object btnNot: TSpeedButton
    Left = 174
    Top = 84
    Width = 25
    Height = 25
    Caption = 'NOT'
    Flat = True
  end
  object btnLike: TSpeedButton
    Left = 199
    Top = 84
    Width = 25
    Height = 25
    Caption = 'LIKE'
    Flat = True
  end
  object btnLParen: TSpeedButton
    Left = 228
    Top = 84
    Width = 13
    Height = 25
    Caption = '('
    Flat = True
  end
  object btnRightParen: TSpeedButton
    Left = 241
    Top = 84
    Width = 13
    Height = 25
    Caption = ')'
    Flat = True
  end
  object btnCancel: TButton
    Left = 344
    Top = 120
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 264
    Top = 120
    Width = 75
    Height = 25
    Caption = '&Use'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object edExpression: TMemo
    Left = 4
    Top = 4
    Width = 417
    Height = 77
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
