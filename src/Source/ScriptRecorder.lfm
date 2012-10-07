object frmScriptRecorder: TfrmScriptRecorder
  Left = 384
  Top = 354
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
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBase: TPanel
    Left = 0
    Top = 0
    Width = 544
    Height = 270
    Align = alClient
    BevelOuter = bvNone
    Caption = 'pnlBase'
    TabOrder = 0
    object edScript: TSyntaxMemoWithStuff2
      Left = 0
      Top = 0
      Width = 544
      Height = 270
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      TabOrder = 0
      Gutter.Font.Charset = DEFAULT_CHARSET
      Gutter.Font.Color = clWindowText
      Gutter.Font.Height = -11
      Gutter.Font.Name = 'Terminal'
      Gutter.Font.Style = []
      Highlighter = dmMenus.synHighlighter
      Options = [eoAutoIndent, eoDragDropEditing, eoScrollPastEof, eoShowScrollHint, eoSmartTabs, eoTabsToSpaces, eoTrimTrailingSpaces]
      OnChange = edScriptChange
      FindDialogHelpContext = 0
      ReplaceDialogHelpContext = 0
      KeywordCapitalise = False
      UseNavigateHyperLinks = True
      NavigatorHyperLinkStyle.Strings = (
        '2')
      ListDelay = 800
      WordList = <>
      SQLInsightList = <>
      RemovedKeystrokes = <
        item
          Command = ecLineBreak
          ShortCut = 8205
        end
        item
          Command = ecContextHelp
          ShortCut = 112
        end>
      AddedKeystrokes = <>
    end
  end
  object dlgNewScript: TSaveDialog
    DefaultExt = 'sql'
    Filter = 'Script Files (*.sql)|*.sql|All Files (*.*)|*.*'
    Title = 'Record actions to New Script File'
    Left = 84
    Top = 32
  end
  object dlgAppend: TOpenDialog
    DefaultExt = 'sql'
    Filter = 'Script Files (*.sql)|*.sql|All Files (*.*)|*.*'
    Title = 'Append actions to Existing Script File'
    Left = 120
    Top = 32
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'sql'
    Filter = 'Script Files (*.sql)|*.sql|All Files (*.*)|*.*'
    Title = 'Save Script As'
    Left = 52
    Top = 32
  end
end
