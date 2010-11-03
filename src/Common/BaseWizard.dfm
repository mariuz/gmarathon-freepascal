object frmBaseWizard: TfrmBaseWizard
  Left = 455
  Top = 285
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'WizardForm'
  ClientHeight = 350
  ClientWidth = 476
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
  object Bevel2: TBevel
    Left = 0
    Top = 52
    Width = 476
    Height = 5
    Shape = bsBottomLine
  end
  object Bevel1: TBevel
    Left = -1
    Top = 312
    Width = 477
    Height = 2
    Shape = bsBottomLine
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 476
    Height = 54
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 0
  end
  object btnPrev: TButton
    Left = 232
    Top = 320
    Width = 75
    Height = 25
    Caption = '&< Prev'
    Enabled = False
    TabOrder = 1
  end
  object btnNext: TButton
    Left = 308
    Top = 320
    Width = 75
    Height = 25
    Caption = 'Next &>'
    Default = True
    TabOrder = 2
  end
  object btnClose: TButton
    Left = 396
    Top = 320
    Width = 75
    Height = 25
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 3
  end
end
