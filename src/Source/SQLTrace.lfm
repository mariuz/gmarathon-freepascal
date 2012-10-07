object frmSQLTrace: TfrmSQLTrace
  Left = 300
  Top = 254
  Width = 552
  Height = 300
  Caption = 'SQLTrace'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pgMacro: TPageControl
    Left = 0
    Top = 0
    Width = 544
    Height = 254
    ActivePage = tsEdit
    Align = alClient
    HotTrack = True
    TabOrder = 0
    object tsEdit: TTabSheet
      Caption = 'Edit View'
      object edTrace: TSyntaxMemoWithStuff2
        Left = 0
        Top = 0
        Width = 536
        Height = 226
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        PopupMenu = dmMenus.mnuSQLEditor
        TabOrder = 0
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = dmMenus.synHighlighter
        ReadOnly = True
        OnChange = edTraceChange
        FindDialogHelpContext = 0
        ReplaceDialogHelpContext = 0
        KeywordCapitalise = False
        UseNavigateHyperLinks = False
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
  end
  object stsScript: TStatusBar
    Left = 0
    Top = 254
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
        Width = 50
      end>
  end
  object dlgSave: TSaveDialog
    DefaultExt = 'log'
    Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly]
    Title = 'Save SQL Trace Log'
    Left = 42
    Top = 178
  end
  object trcSQL: TIB_Monitor
    Enabled = True
    IncludeTimeStamp = True
    ItemEnd = '----*/'
    MinTicks = 10
    NewLineText = #13#10
    StatementGroups = [sgAllocate, sgPrepare, sgDescribe, sgStatementInfo, sgExecute, sgExecuteImmediate, sgServerCursor]
    OnMonitorOutputItem = trcSQLMonitorOutputItem
    Left = 70
    Top = 178
  end
end
