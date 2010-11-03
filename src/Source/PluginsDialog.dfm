object frmPlugins: TfrmPlugins
  Left = 467
  Top = 270
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Plugins'
  ClientHeight = 261
  ClientWidth = 321
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
  object lbPlugins: TListBox
    Left = 8
    Top = 8
    Width = 225
    Height = 245
    ItemHeight = 13
    TabOrder = 0
  end
  object btnLoad: TButton
    Left = 240
    Top = 8
    Width = 75
    Height = 25
    Caption = '&Load...'
    TabOrder = 1
    OnClick = btnLoadClick
  end
  object btnUnload: TButton
    Left = 240
    Top = 36
    Width = 75
    Height = 25
    Caption = '&Unload'
    TabOrder = 2
    OnClick = btnUnloadClick
  end
  object btnClose: TButton
    Left = 240
    Top = 228
    Width = 75
    Height = 25
    Caption = 'Close'
    TabOrder = 3
    OnClick = btnCloseClick
  end
  object btnUnloadAll: TButton
    Left = 240
    Top = 84
    Width = 75
    Height = 25
    Caption = 'Unload &All...'
    TabOrder = 4
    OnClick = btnUnloadAllClick
  end
  object dlgOpen: TOpenDialog
    Filter = 'Plugins (*.dll)|*.dll'
    Title = 'Load Plugin'
    Left = 276
    Top = 136
  end
end
