object frmScriptOptions: TfrmScriptOptions
  Left = 317
  Top = 248
  BorderStyle = bsDialog
  Caption = 'Properties for Script Executive'
  ClientHeight = 224
  ClientWidth = 348
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pgOptions: TPageControl
    Left = 4
    Top = 4
    Width = 341
    Height = 185
    ActivePage = tsGeneral
    TabIndex = 0
    TabOrder = 0
    object tsGeneral: TTabSheet
      Caption = 'General'
      object Label1: TLabel
        Left = 8
        Top = 76
        Width = 46
        Height = 13
        Caption = 'Script Dir:'
      end
      object btnChooseDir: TSpeedButton
        Left = 304
        Top = 72
        Width = 21
        Height = 21
        Caption = '...'
        OnClick = btnChooseDirClick
      end
      object chkAbortOnError: TCheckBox
        Left = 8
        Top = 12
        Width = 165
        Height = 17
        Caption = 'Abort Script On Error'
        TabOrder = 0
        OnClick = chkAbortOnErrorClick
      end
      object chkRollBack: TCheckBox
        Left = 24
        Top = 32
        Width = 133
        Height = 17
        Caption = 'Rollback on Abort'
        TabOrder = 1
      end
      object edScriptDir: TEdit
        Left = 56
        Top = 72
        Width = 249
        Height = 21
        TabOrder = 2
      end
    end
  end
  object btnOK: TButton
    Left = 188
    Top = 196
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 268
    Top = 196
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
end
