object frmTriggerEditor: TfrmTriggerEditor
  Left = 292
  Top = 258
  Width = 640
  Height = 407
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  Caption = 'Trigger - []'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poDefault
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnHelp = FormHelp
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object stsEditor: TStatusBar
    Left = 0
    Top = 354
    Width = 632
    Height = 19
    Panels = <
      item
        Width = 65
      end
      item
        Width = 90
      end
      item
        Width = 200
      end
      item
        Width = 50
      end>
  end
  object pgObjectEditor: TPageControl
    Left = 0
    Top = 0
    Width = 632
    Height = 354
    ActivePage = tsObject
    Align = alClient
    HotTrack = True
    TabOrder = 1
    TabStop = False
    OnChange = pgObjectEditorChange
    OnChanging = pgObjectEditorChanging
    object tsObject: TTabSheet
      Caption = 'Edit'
      object Splitter1: TSplitter
        Left = 0
        Top = 69
        Width = 624
        Height = 4
        Cursor = crVSplit
        Align = alTop
      end
      object edEditor: TSyntaxMemoWithStuff2
        Left = 0
        Top = 73
        Width = 624
        Height = 151
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        PopupMenu = dmMenus.mnuSQLEditor
        TabOrder = 0
        OnDragDrop = edEditorDragDrop
        OnDragOver = edEditorDragOver
        OnKeyDown = edEditorKeyDown
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = dmMenus.synHighlighter
        OnChange = edEditorChange
        OnStatusChange = edEditorStatusChange
        FindDialogHelpContext = 0
        ReplaceDialogHelpContext = 0
        KeywordCapitalise = False
        OnGetHintText = edEditorGetHintText
        UseNavigateHyperLinks = True
        NavigatorHyperLinkStyle.Strings = (
          '2')
        OnNavigateHyperLinkClick = edEditorNavigateHyperLinkClick
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
      object edTriggerHeader: TSyntaxMemoWithStuff2
        Left = 0
        Top = 0
        Width = 624
        Height = 69
        Align = alTop
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 1
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = dmMenus.synHighlighter
        ReadOnly = True
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
      object pnlMessages: TrmPanel
        Left = 0
        Top = 224
        Width = 624
        Height = 102
        Align = alBottom
        SplitterPanel = True
        ResizeBtn = True
        TabOrder = 2
        OnResize = pnlMessagesResize
        object lstResults: TrmCollectionListBox
          Left = 0
          Top = 0
          Width = 624
          Height = 96
          AutoSelect = True
          Collection = <>
          Images = dmMenus.ilErrors
          Align = alClient
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
          PopupMenu = dmMenus.mnuListResults
          TabOrder = 0
          OnDblClick = lstResultsClick
        end
      end
    end
    object tsDocoView: TTabSheet
      Caption = 'Documentation'
      inline framDoco: TframeDesc
        Left = 0
        Top = 0
        Width = 624
        Height = 326
        Align = alClient
        TabOrder = 0
        inherited edDoco: TSyntaxMemoWithStuff2
          Width = 624
          Height = 326
        end
      end
    end
    object tsDependencies: TTabSheet
      Caption = 'Dependencies'
      inline framDepend: TframeDepend
        Left = 0
        Top = 0
        Width = 624
        Height = 326
        Align = alClient
        TabOrder = 0
        inherited pgDependencies: TPageControl
          Width = 624
          Height = 326
          inherited tsDependedOn: TTabSheet
            inherited lvDependedOn: TListView
              Width = 616
              Height = 273
            end
            inherited pnlDependedOnHdr: TPanel
              Width = 616
            end
          end
        end
      end
    end
    object tsDRUI: TTabSheet
      Caption = 'DRUI Matrix'
      inline frameDRUI: TframeDRUI
        Left = 0
        Top = 0
        Width = 624
        Height = 326
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        inherited Panel1: TPanel
          Width = 624
        end
        inherited tvCrud: TrmPathTreeView
          Width = 624
          Height = 293
        end
        inherited dtaCrud: TrmMemoryDataSet
          FieldRoster = <
            item
              Size = 0
              FieldType = fdtString
            end>
        end
      end
    end
    object tsDebuggerOutput: TTabSheet
      Caption = 'Debugger Output'
      object edErrors: TSyntaxMemoWithStuff2
        Left = 0
        Top = 0
        Width = 624
        Height = 256
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
        ReadOnly = True
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
  object dlgOpen: TOpenDialog
    Filter = 
      'SQL Files (*.sql)|*.sql|Text Files (*.txt)|*.txt|All Files (*.*)' +
      '|*.*'
    Title = 'Open File'
    Left = 361
    Top = 164
  end
  object qryTrigger: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 396
    Top = 96
  end
  object qryUtil: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 396
    Top = 164
  end
  object qryWarnings: TIB_DSQL
    ParamChar = '?'
    Left = 316
    Top = 116
  end
  object dlgSave: TSaveDialog
    DefaultExt = '*.sql'
    Filter = 
      'SQL Files (*.sql)|*.sql|Text Files (*.txt)|*.txt|All Files (*.*)' +
      '|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly]
    Title = 'Save to file'
    Left = 324
    Top = 166
  end
end
