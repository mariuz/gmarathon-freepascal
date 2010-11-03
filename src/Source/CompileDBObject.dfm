object frmCompileDBObject: TfrmCompileDBObject
  Left = 386
  Top = 85
  BorderIcons = []
  BorderStyle = bsDialog
  Caption = 'Compiling...'
  ClientHeight = 203
  ClientWidth = 335
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 124
    Top = 172
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
    Visible = False
  end
  object aniCompile: TAnimate
    Left = 36
    Top = 8
    Width = 269
    Height = 45
  end
  object memStatus: TMemo
    Left = 4
    Top = 80
    Width = 325
    Height = 85
    ReadOnly = True
    ScrollBars = ssVertical
    TabOrder = 2
  end
end
