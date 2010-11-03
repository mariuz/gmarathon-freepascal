object frmStoredProcedure: TfrmStoredProcedure
  Left = 328
  Top = 204
  Width = 640
  Height = 407
  BorderIcons = [biSystemMenu, biMinimize, biMaximize, biHelp]
  Caption = 'Stored Procedure - []'
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
    ActivePage = tsStoredProc
    Align = alClient
    HotTrack = True
    TabOrder = 1
    TabStop = False
    OnChange = pgObjectEditorChange
    OnChanging = pgObjectEditorChanging
    object tsStoredProc: TTabSheet
      Caption = 'Edit'
      object edEditor: TSyntaxMemoWithStuff2
        Left = 0
        Top = 0
        Width = 624
        Height = 217
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
          '4')
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
      object pnlMessages: TrmPanel
        Left = 0
        Top = 217
        Width = 624
        Height = 109
        Align = alBottom
        SplitterPanel = True
        ParentBackground = True
        ResizeBtn = True
        TabOrder = 1
        OnResize = pnlMessagesResize
        object lstResults: TrmCollectionListBox
          Left = 0
          Top = 0
          Width = 624
          Height = 103
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
    object tsExecute: TTabSheet
      Caption = 'Results'
      object nbResults: TrmNoteBookControl
        Left = 0
        Top = 27
        Width = 624
        Height = 278
        ActivePageIndex = 0
        Align = alClient
        object nbpDatasheet: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 624
          Height = 278
          Caption = 'Datasheet'
          Data = 0
          Visible = False
          ImageIndex = -1
          object grdResults: TDBGrid
            Left = 0
            Top = 0
            Width = 624
            Height = 278
            Align = alClient
            DataSource = dsResults
            PopupMenu = dmMenus.mnuDataMenu
            TabOrder = 0
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'MS Sans Serif'
            TitleFont.Style = []
          end
        end
        object nbpForm: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 624
          Height = 278
          Caption = 'Form'
          Data = 0
          Enabled = False
          Visible = False
          ImageIndex = -1
          object pnledResults: TDBPanelEdit
            Left = 0
            Top = 0
            Width = 624
            Height = 278
            DataSource = dsResults
            ControlFont.Charset = DEFAULT_CHARSET
            ControlFont.Color = clWindowText
            ControlFont.Height = -11
            ControlFont.Name = 'MS Sans Serif'
            ControlFont.Style = []
            LabelFont.Charset = DEFAULT_CHARSET
            LabelFont.Color = clWindowText
            LabelFont.Height = -11
            LabelFont.Name = 'MS Sans Serif'
            LabelFont.Style = []
            ReadOnly = False
            Refreshed = False
            Align = alClient
            BevelOuter = bvNone
            TabOrder = 0
          end
        end
      end
      object pnlDataView: TPanel
        Left = 0
        Top = 0
        Width = 624
        Height = 27
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object navDataView: TDBNavigator
          Left = 2
          Top = 1
          Width = 104
          Height = 25
          DataSource = dsResults
          VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast]
          Flat = True
          Hints.Strings = (
            'First'
            'Previous'
            'Next'
            'Last')
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
      end
      object tabResults: TrmTabSet
        Left = 0
        Top = 305
        Width = 624
        Height = 21
        Align = alBottom
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        Tabs.Strings = (
          'Datasheet'
          'Form')
        TabIndex = 0
        TabLocation = tlBottom
        TabType = ttWin2k
        OnChange = tabResultsChange
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
          OnChange = nil
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
    object tsGrants: TTabSheet
      Caption = 'Grants'
      inline framePerms: TframePerms
        Left = 0
        Top = 0
        Width = 624
        Height = 326
        Align = alClient
        TabOrder = 0
        inherited lvGrants: TListView
          Width = 624
          Height = 326
        end
      end
    end
    object tsDebuggerOutput: TTabSheet
      Caption = 'Debugger Output'
      TabVisible = False
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
    object tsDebugger: TTabSheet
      Caption = 'Debugger Output'
      ImageIndex = 7
      object edDebugInfo: TMemo
        Left = 0
        Top = 0
        Width = 624
        Height = 256
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
  end
  object dsResults: TDataSource
    DataSet = qryResults
    Left = 360
    Top = 128
  end
  object dlgOpen: TOpenDialog
    Filter = 
      'SQL Files (*.sql)|*.sql|Text Files (*.txt)|*.txt|All Files (*.*)' +
      '|*.*'
    Title = 'Open File'
    Left = 361
    Top = 164
  end
  object qryStoredProc: TIBOQuery
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
  object qryResults: TIBOQuery
    Params = <>
    CallbackInc = 10
    FetchWholeRows = False
    IB_Transaction = tranResults
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    AfterOpen = qryResultsAfterOpen
    FieldOptions = []
    Left = 360
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
  object tranResults: TIB_Transaction
    Isolation = tiConcurrency
    Left = 429
    Top = 129
  end
  object txtParameters: TrmMemoryDataSet
    FieldRoster = <
      item
        Name = 'param_name'
        Size = 60
        FieldType = fdtString
      end
      item
        Name = 'param_type'
        Size = 20
        FieldType = fdtString
      end
      item
        Name = 'param_value'
        Size = 300
        FieldType = fdtString
      end
      item
        Name = 'field_type'
        Size = 6
        FieldType = fdtString
      end
      item
        Name = 'field_length'
        Size = 6
        FieldType = fdtString
      end
      item
        Name = 'field_scale'
        Size = 6
        FieldType = fdtString
      end
      item
        Name = 'match'
        Size = 1
        FieldType = fdtString
      end
      item
        Name = 'null'
        Size = 4
        FieldType = fdtString
      end>
    Active = True
    OnNewRecord = txtParametersNewRecord
    Left = 432
    Top = 164
    object txtParametersparam_name: TStringField
      FieldName = 'param_name'
      Required = True
      Size = 60
    end
    object txtParametersparam_type: TStringField
      FieldName = 'param_type'
      Required = True
    end
    object txtParametersparam_value: TStringField
      FieldName = 'param_value'
      Required = True
      OnChange = txtParametersparam_valueChange
      Size = 300
    end
    object txtParametersfield_type: TStringField
      FieldName = 'field_type'
      Required = True
      Size = 6
    end
    object txtParametersfield_length: TStringField
      FieldName = 'field_length'
      Required = True
      Size = 6
    end
    object txtParametersfield_scale: TStringField
      FieldName = 'field_scale'
      Required = True
      Size = 6
    end
    object txtParametersmatch: TStringField
      FieldName = 'match'
      Required = True
      Size = 1
    end
    object txtParametersnull: TStringField
      FieldName = 'null'
      Required = True
      OnChange = txtParametersnullChange
      OnValidate = txtParametersnullValidate
      Size = 4
    end
  end
  object qryWarnings: TIB_DSQL
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
