object frmViewEditor: TfrmViewEditor
  Left = 337
  Top = 183
  Width = 640
  Height = 452
  Caption = 'View - []'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object stsEditor: TStatusBar
    Left = 0
    Top = 396
    Width = 632
    Height = 22
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
    Height = 396
    ActivePage = tsData
    Align = alClient
    HotTrack = True
    TabOrder = 1
    OnChange = pgObjectEditorChange
    OnChanging = pgObjectEditorChanging
    object tsSQL: TTabSheet
      Caption = 'View'
      object pnlMessages: TrmPanel
        Left = 0
        Top = 261
        Width = 624
        Height = 107
        Align = alBottom
        SplitterPanel = True
        ParentBackground = True
        ResizeBtn = True
        TabOrder = 0
        object lstResults: TrmCollectionListBox
          Left = 0
          Top = 0
          Width = 624
          Height = 101
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
          OnDblClick = lstResultsDblClick
        end
      end
      object edEditor: TSyntaxMemoWithStuff2
        Left = 0
        Top = 0
        Width = 624
        Height = 261
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        PopupMenu = dmMenus.mnuSQLEditor
        TabOrder = 1
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
    object tsTableView: TTabSheet
      Caption = 'Structure'
      object lvFieldList: TListView
        Left = 0
        Top = 0
        Width = 624
        Height = 375
        Align = alClient
        Columns = <
          item
            Caption = 'Field Name'
            Width = 200
          end
          item
            Caption = 'Field Type'
            Width = 90
          end
          item
            Caption = 'Sub Type'
            Width = 60
          end
          item
            Caption = 'Domain'
            Width = 100
          end
          item
            Caption = 'Not Null'
            Width = 100
          end
          item
            Caption = 'Description'
            Width = 200
          end
          item
            Caption = 'Default Source'
            Width = 300
          end
          item
            Caption = 'Computed Source'
            Width = 300
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        PopupMenu = dmMenus.mnuFields
        SmallImages = frmMarathonMain.ilMarathonImages
        TabOrder = 0
        ViewStyle = vsReport
        OnColumnClick = lvFieldListColumnClick
        OnDblClick = lvFieldListDblClick
        OnKeyDown = lvFieldListKeyDown
      end
    end
    object tsDependenciesView: TTabSheet
      Caption = 'Dependencies'
      inline framDepend: TframeDepend
        Left = 0
        Top = 0
        Width = 624
        Height = 368
        Align = alClient
        TabOrder = 0
        inherited pgDependencies: TPageControl
          Width = 624
          Height = 368
          inherited tsDependedOn: TTabSheet
            inherited lvDependedOn: TListView
              Width = 616
              Height = 315
            end
            inherited pnlDependedOnHdr: TPanel
              Width = 616
            end
          end
        end
      end
    end
    object tsTriggerView: TTabSheet
      Caption = 'Triggers'
      object tvTriggers: TTreeView
        Left = 0
        Top = 29
        Width = 624
        Height = 339
        Align = alClient
        HideSelection = False
        Images = frmMarathonMain.ilMarathonImages
        Indent = 19
        PopupMenu = dmMenus.mnuFields
        ReadOnly = True
        TabOrder = 0
        OnDblClick = tvTriggersDblClick
        OnGetImageIndex = tvTriggersGetImageIndex
        OnGetSelectedIndex = tvTriggersGetImageIndex
        OnKeyDown = tvTriggersKeyDown
        OnMouseDown = tvTriggersMouseDown
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 624
        Height = 29
        Align = alTop
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Color = clAppWorkSpace
        TabOrder = 1
        object Label1: TLabel
          Left = 4
          Top = 4
          Width = 37
          Height = 13
          Caption = 'Display:'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clInfoBk
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          ParentFont = False
        end
        object cmbTriggerDisplay: TComboBox
          Left = 45
          Top = 1
          Width = 196
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 0
          Items.Strings = (
            'Alphabetically'
            'Execution Order')
        end
      end
    end
    object tsData: TTabSheet
      Caption = 'Data'
      object pnlDataView: TPanel
        Left = 0
        Top = 0
        Width = 624
        Height = 27
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 0
        object btnRefresh: TSpeedButton
          Left = 236
          Top = 1
          Width = 69
          Height = 25
          Caption = '&Refresh'
          Flat = True
        end
        object navDataView: TDBNavigator
          Left = 2
          Top = 1
          Width = 234
          Height = 25
          DataSource = dsTableData
          VisibleButtons = [nbFirst, nbPrior, nbNext, nbLast, nbInsert, nbDelete, nbEdit, nbPost, nbCancel]
          Flat = True
          Hints.Strings = (
            'First'
            'Previous'
            'Next'
            'Last'
            'Append'
            'Delete'
            'Edit'
            'Post'
            'Cancel')
          ParentShowHint = False
          ShowHint = True
          TabOrder = 0
        end
      end
      object nbResults: TrmNoteBookControl
        Left = 0
        Top = 27
        Width = 624
        Height = 320
        ActivePageIndex = 0
        Align = alClient
        object nbpDatasheet: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 624
          Height = 320
          Caption = 'Datasheet'
          Data = 0
          Visible = False
          ImageIndex = -1
          object grdDataView: TDBGrid
            Left = 0
            Top = 0
            Width = 624
            Height = 320
            Align = alClient
            DataSource = dsTableData
            Font.Charset = RUSSIAN_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'MS Sans Serif'
            Font.Style = []
            ParentFont = False
            TabOrder = 0
            TitleFont.Charset = DEFAULT_CHARSET
            TitleFont.Color = clWindowText
            TitleFont.Height = -11
            TitleFont.Name = 'MS Sans Serif'
            TitleFont.Style = []
            OnDblClick = grdDataViewDblClick
          end
        end
        object nbpForm: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 624
          Height = 320
          Caption = 'Form'
          Data = 0
          Enabled = False
          Visible = False
          ImageIndex = -1
          object pnledResults: TDBPanelEdit
            Left = 0
            Top = 0
            Width = 624
            Height = 320
            DataSource = dsTableData
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
      object tabResults: TrmTabSet
        Left = 0
        Top = 347
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
    object tsDoco: TTabSheet
      Caption = 'Documentation'
      inline framDoco: TframeDesc
        Left = 0
        Top = 0
        Width = 624
        Height = 368
        Align = alClient
        TabOrder = 0
        inherited edDoco: TSyntaxMemoWithStuff2
          Width = 624
          Height = 368
        end
      end
    end
    object tsGrants: TTabSheet
      Caption = 'Grants'
      inline framPerms: TframePerms
        Left = 0
        Top = 0
        Width = 624
        Height = 368
        Align = alClient
        TabOrder = 0
        inherited lvGrants: TListView
          Width = 624
          Height = 368
        end
      end
    end
  end
  object dsTableData: TDataSource
    DataSet = tblTableData
    Left = 112
    Top = 152
  end
  object qryTable: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 48
    Top = 188
  end
  object qryTriggers: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 48
    Top = 256
  end
  object tblTableData: TIBOQuery
    Params = <>
    CallbackInc = 10
    FetchWholeRows = False
    IB_Transaction = tranTableData
    RecordCountAccurate = True
    AfterOpen = tblTableDataAfterOpen
    RequestLive = True
    FieldOptions = []
    Left = 48
    Top = 152
  end
  object tranTableData: TIB_Transaction
    Isolation = tiConcurrency
    Left = 80
    Top = 152
  end
  object qryUtil: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 48
    Top = 224
  end
end
