object frmTables: TfrmTables
  Left = 305
  Top = 147
  Width = 640
  Height = 455
  Caption = 'Tables - []'
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  Position = poScreenCenter
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
    Top = 399
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
    Height = 399
    ActivePage = tsData
    Align = alClient
    HotTrack = True
    TabOrder = 1
    OnChange = pgObjectEditorChange
    OnChanging = pgObjectEditorChanging
    object tsTableView: TTabSheet
      Caption = 'Table'
      object lvFieldList: TListView
        Left = 0
        Top = 0
        Width = 624
        Height = 371
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
    object tsConstraints: TTabSheet
      Caption = 'Constraints'
      object lvConstraints: TListView
        Left = 0
        Top = 0
        Width = 624
        Height = 371
        Align = alClient
        Columns = <
          item
            Caption = 'Constraint Name'
            Width = 200
          end
          item
            Caption = 'Type'
            Width = 200
          end
          item
            Caption = 'On Field'
            Width = 200
          end
          item
            Caption = 'FK Table'
            Width = 200
          end
          item
            Caption = 'FK Field'
            Width = 200
          end
          item
            Caption = 'Update Rule'
            Width = 100
          end
          item
            Caption = 'Delete Rule'
            Width = 100
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        PopupMenu = dmMenus.mnuFields
        SmallImages = frmMarathonMain.ilMarathonImages
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvFieldListDblClick
        OnKeyDown = lvConstraintsKeyDown
      end
    end
    object tsIndexes: TTabSheet
      Caption = 'Indices'
      object lvIndex: TListView
        Left = 0
        Top = 0
        Width = 624
        Height = 371
        Align = alClient
        Columns = <
          item
            Caption = 'Index Name'
            Width = 200
          end
          item
            Caption = 'On Field'
            Width = 200
          end
          item
            Caption = 'Unique'
          end
          item
            Caption = 'Active'
          end
          item
            Caption = 'Direction'
            Width = 80
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        PopupMenu = dmMenus.mnuFields
        SmallImages = frmMarathonMain.ilMarathonImages
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvFieldListDblClick
        OnKeyDown = lvIndexKeyDown
      end
    end
    object tsDependenciesView: TTabSheet
      Caption = 'Dependencies'
      inline framDepend: TframeDepend
        Left = 0
        Top = 0
        Width = 624
        Height = 371
        Align = alClient
        TabOrder = 0
        inherited pgDependencies: TPageControl
          Width = 624
          Height = 371
          inherited tsDependedOn: TTabSheet
            inherited lvDependedOn: TListView
              Width = 616
              Height = 318
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
        Height = 342
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
          OnChange = cmbTriggerDisplayChange
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
        Height = 323
        ActivePageIndex = 0
        Align = alClient
        object nbpDatasheet: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 624
          Height = 323
          Caption = 'Datasheet'
          Data = 0
          Visible = False
          ImageIndex = -1
          object grdDataView: TDBGrid
            Left = 0
            Top = 0
            Width = 624
            Height = 323
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
          Height = 323
          Caption = 'Form'
          Data = 0
          Enabled = False
          Visible = False
          ImageIndex = -1
          object pnledResults: TDBPanelEdit
            Left = 0
            Top = 0
            Width = 624
            Height = 323
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
        Top = 350
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
        Height = 371
        Align = alClient
        TabOrder = 0
        inherited edDoco: TSyntaxMemoWithStuff2
          Width = 624
          Height = 371
        end
      end
    end
    object tsGrants: TTabSheet
      Caption = 'Grants'
      inline framPerms: TframePerms
        Left = 0
        Top = 0
        Width = 624
        Height = 371
        Align = alClient
        TabOrder = 0
        inherited lvGrants: TListView
          Width = 624
          Height = 371
        end
      end
    end
    object tsDDL: TTabSheet
      Caption = 'DDL'
      inline framDDL: TframDisplayDDL
        Left = 0
        Top = 0
        Width = 624
        Height = 371
        Align = alClient
        TabOrder = 0
        inherited edDDL: TSyntaxMemoWithStuff2
          Width = 624
          Height = 371
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
    Left = 50
    Top = 190
  end
  object qryConstraints: TIBOQuery
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
    PreparedInserts = True
    RecordCountAccurate = True
    AfterOpen = tblTableDataAfterOpen
    RequestLive = True
    FieldOptions = []
    Left = 50
    Top = 152
  end
  object tranTableData: TIB_Transaction
    Left = 80
    Top = 152
  end
  object PopupMenu1: TPopupMenu
    Left = 39
    Top = 28
    object sizerect1: TMenuItem
      Caption = 'sizerect'
      ShortCut = 16466
      OnClick = sizerect1Click
    end
  end
end
