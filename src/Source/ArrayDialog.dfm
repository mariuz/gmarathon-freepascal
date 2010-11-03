object frmArrayDialog: TfrmArrayDialog
  Left = 398
  Top = 354
  BorderStyle = bsDialog
  Caption = 'Array Settings'
  ClientHeight = 129
  ClientWidth = 273
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
    Left = 16
    Top = 20
    Width = 40
    Height = 13
    Caption = '&LBound:'
    FocusControl = edLBound
  end
  object Label2: TLabel
    Left = 16
    Top = 60
    Width = 42
    Height = 13
    Caption = '&UBound:'
    FocusControl = edUBound
  end
  object btnOK: TButton
    Left = 112
    Top = 100
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 192
    Top = 100
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object edLBound: TEdit
    Left = 60
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '1'
  end
  object edUBound: TEdit
    Left = 60
    Top = 56
    Width = 121
    Height = 21
    TabOrder = 3
    Text = '0'
  end
  object udLBound: TUpDown
    Left = 181
    Top = 16
    Width = 15
    Height = 21
    Associate = edLBound
    Min = 0
    Position = 1
    TabOrder = 4
    Wrap = False
  end
  object udUBound: TUpDown
    Left = 181
    Top = 56
    Width = 15
    Height = 21
    Associate = edUBound
    Min = 0
    Position = 0
    TabOrder = 5
    Wrap = False
  end
end
