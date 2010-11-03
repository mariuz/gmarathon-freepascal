object frmScriptEditorHost: TfrmScriptEditorHost
  Left = 388
  Top = 222
  Width = 552
  Height = 297
  Caption = 'Script Recorder'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pgMacro: TPageControl
    Left = 0
    Top = 0
    Width = 544
    Height = 251
    Align = alClient
    HotTrack = True
    TabOrder = 0
    OnChange = pgMacroChange
  end
  object stsScript: TStatusBar
    Left = 0
    Top = 251
    Width = 544
    Height = 19
    Panels = <
      item
        Width = 65
      end
      item
        Width = 90
      end
      item
        Width = 90
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object tmrRecord: TTimer
    Interval = 550
    Left = 5
    Top = 136
  end
end
