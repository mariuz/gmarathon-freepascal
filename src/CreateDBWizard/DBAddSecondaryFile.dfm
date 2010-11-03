object frmDBSecondaryFile: TfrmDBSecondaryFile
  Left = 347
  Top = 443
  ActiveControl = edFileName
  BorderStyle = bsDialog
  Caption = 'Add Secondary File'
  ClientHeight = 106
  ClientWidth = 388
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
    Left = 9
    Top = 12
    Width = 50
    Height = 13
    Caption = 'File Name:'
  end
  object Label2: TLabel
    Left = 152
    Top = 44
    Width = 36
    Height = 13
    Caption = 'Page(s)'
  end
  object Label3: TLabel
    Left = 16
    Top = 44
    Width = 36
    Height = 13
    Caption = 'Length:'
  end
  object btnOK: TButton
    Left = 309
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 309
    Top = 36
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 309
    Top = 68
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 2
  end
  object edFileName: TEdit
    Left = 60
    Top = 8
    Width = 233
    Height = 21
    TabOrder = 3
  end
  object edPages: TEdit
    Left = 60
    Top = 40
    Width = 85
    Height = 21
    TabOrder = 4
  end
end
