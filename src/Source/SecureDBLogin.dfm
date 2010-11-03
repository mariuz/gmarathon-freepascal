object frmSecureConnect: TfrmSecureConnect
  Left = 403
  Top = 264
  ActiveControl = edUserName
  BorderStyle = bsDialog
  Caption = 'Connect to Database'
  ClientHeight = 102
  ClientWidth = 361
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
    Left = 8
    Top = 44
    Width = 56
    Height = 13
    Caption = 'User Name:'
  end
  object Label2: TLabel
    Left = 15
    Top = 72
    Width = 49
    Height = 13
    Caption = 'Password:'
  end
  object Label3: TLabel
    Left = 5
    Top = 12
    Width = 59
    Height = 13
    Caption = 'Security DB:'
  end
  object btnOK: TButton
    Left = 280
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 3
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 280
    Top = 40
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 4
  end
  object edUserName: TEdit
    Left = 68
    Top = 40
    Width = 157
    Height = 21
    CharCase = ecUpperCase
    TabOrder = 1
  end
  object edPassword: TEdit
    Left = 68
    Top = 68
    Width = 157
    Height = 21
    PasswordChar = '*'
    TabOrder = 2
  end
  object edDBName: TEdit
    Left = 68
    Top = 8
    Width = 201
    Height = 21
    TabOrder = 0
  end
end
