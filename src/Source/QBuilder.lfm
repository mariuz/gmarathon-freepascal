object QBForm: TQBForm
  Left = 253
  Top = 189
  Width = 591
  Height = 448
  Caption = 'Marathon Query Builder'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object ButtonsPanel: TPanel
    Left = 0
    Top = 387
    Width = 583
    Height = 34
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 583
      Height = 5
      Align = alTop
      Shape = bsTopLine
    end
    object btnInsert: TButton
      Left = 6
      Top = 6
      Width = 75
      Height = 25
      Caption = '&Insert'
      Default = True
      Enabled = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 1
      ParentFont = False
      TabOrder = 0
    end
    object Button2: TButton
      Left = 84
      Top = 6
      Width = 75
      Height = 25
      Cancel = True
      Caption = '&Cancel'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ModalResult = 2
      ParentFont = False
      TabOrder = 1
    end
    object btnHelp: TButton
      Left = 188
      Top = 6
      Width = 75
      Height = 25
      Caption = '&Help'
      TabOrder = 2
      OnClick = btnHelpClick
    end
  end
  object QBPanel: TPanel
    Left = 0
    Top = 27
    Width = 583
    Height = 360
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object VSplitter: TSplitter
      Left = 441
      Top = 0
      Height = 199
      Align = alRight
      Color = clBtnFace
      ParentColor = False
    end
    object HSplitter: TSplitter
      Left = 0
      Top = 199
      Width = 583
      Height = 3
      Cursor = crVSplit
      Align = alBottom
      Color = clBtnFace
      ParentColor = False
    end
    object Pages: TPageControl
      Left = 0
      Top = 202
      Width = 583
      Height = 158
      ActivePage = TabColumns
      Align = alBottom
      TabOrder = 0
      TabPosition = tpBottom
      object TabColumns: TTabSheet
        Caption = 'Columns'
        object pnlExtraQueryData: TPanel
          Left = 0
          Top = 0
          Width = 575
          Height = 29
          Align = alTop
          BevelOuter = bvNone
          TabOrder = 0
          object lblQueryPrompt: TLabel
            Left = 9
            Top = 7
            Width = 90
            Height = 13
            Alignment = taRightJustify
            Caption = 'Delete From Table:'
          end
          object cmbQueryTable: TComboBox
            Left = 104
            Top = 4
            Width = 145
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
          end
        end
        object pnlGridParent: TPanel
          Left = 0
          Top = 29
          Width = 575
          Height = 103
          Align = alClient
          BevelOuter = bvNone
          TabOrder = 1
        end
      end
      object TabSQL: TTabSheet
        Caption = 'SQL'
        object memoSQL: TSyntaxMemoWithStuff2
          Left = 0
          Top = 0
          Width = 575
          Height = 132
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
    object QBTables: TListBox
      Left = 444
      Top = 0
      Width = 139
      Height = 199
      TabStop = False
      Align = alRight
      DragMode = dmAutomatic
      ExtendedSelect = False
      ItemHeight = 13
      Sorted = True
      TabOrder = 1
    end
  end
  object pnlToolbar: TPanel
    Left = 0
    Top = 0
    Width = 583
    Height = 27
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 2
    object btnNew: TSpeedButton
      Left = 1
      Top = 1
      Width = 25
      Height = 25
      Hint = 'New Query'
      Flat = True
      Glyph.Data = {
        66010000424D6601000000000000760000002800000014000000140000000100
        040000000000F000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00666666666666
        666666660000666666666666666666660000667000000000000006660000667F
        FFFFFFFFFFFF06660000667FFFFFFFFFFFFF06660000667FFFFFFFFFFFFF0666
        0000667FFFFFFFFFFFFF06660000667FFFFFFFFFFFFF06660000667FFFFFFFFF
        FFFF06660000667FFFFFFFFFFFFF06660000667FFFFFFFFFFFFF06660000667F
        FFFFFFFFFFFF06660000667FFFFFFFFFFFFF06660000667FFFFFFFFFFFFF0666
        0000667FFFFFFFFF000006660000667FFFFFFFFF7FF766660000667FFFFFFFFF
        7F7666660000667FFFFFFFFF7766666600006677777777777666666600006666
        66666666666666660000}
      ParentShowHint = False
      ShowHint = True
      OnClick = btnNewClick
    end
    object btnGenSQL: TSpeedButton
      Left = 26
      Top = 1
      Width = 25
      Height = 25
      Hint = 'Generate SQL'
      Flat = True
      Glyph.Data = {
        66010000424D6601000000000000760000002800000014000000140000000100
        040000000000F000000000000000000000001000000010000000000000000000
        8000008000000080800080000000800080008080000080808000C0C0C0000000
        FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00666666666666
        6666666600006666667766667076677600006666670076700076000600006666
        6066060700760766000060666660660770760766000064066707760770760766
        0000674060770607706607660000647407006660066606660000674740666666
        6666666600006474740666666666666600006747474066666666666600006474
        7474066666666666000067474747466666666666000064747474666666666666
        0000674747466666666666660000647474666666666666660000674746666666
        6666666600006474666666666666666600006746666666666666666600006466
        66666666666666660000}
      ParentShowHint = False
      ShowHint = True
      OnClick = btnSQLClick
    end
    object Label1: TLabel
      Left = 68
      Top = 6
      Width = 58
      Height = 13
      Caption = 'Query Type:'
    end
    object cmbQueryType: TComboBox
      Left = 132
      Top = 3
      Width = 101
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cmbQueryTypeChange
      Items.Strings = (
        'Select')
    end
  end
  object mnuTbl: TPopupMenu
    AutoPopup = False
    Left = 392
    Top = 272
    object Remove1: TMenuItem
      Caption = 'Remove'
      OnClick = mnuRemoveClick
    end
  end
  object mnuFunc: TPopupMenu
    AutoPopup = False
    Left = 488
    Top = 272
    object Nofunction1: TMenuItem
      Tag = 1
      Caption = 'Group By'
      Checked = True
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuFunctionClick
    end
    object N1: TMenuItem
      Caption = '-'
      Enabled = False
      GroupIndex = 1
    end
    object Average1: TMenuItem
      Tag = 2
      Caption = 'Average'
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuFunctionClick
    end
    object Count1: TMenuItem
      Tag = 3
      Caption = 'Count'
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuFunctionClick
    end
    object Minimum1: TMenuItem
      Tag = 4
      Caption = 'Maximum'
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuFunctionClick
    end
    object Maximum1: TMenuItem
      Tag = 5
      Caption = 'Minimum'
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuFunctionClick
    end
    object Sum1: TMenuItem
      Tag = 6
      Caption = 'Sum'
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuFunctionClick
    end
  end
  object mnuSort: TPopupMenu
    AutoPopup = False
    Left = 456
    Top = 272
    object Sort1: TMenuItem
      Tag = 1
      Caption = 'No Sort'
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuSortClick
    end
    object N2: TMenuItem
      Caption = '-'
      GroupIndex = 1
    end
    object Ascending1: TMenuItem
      Tag = 2
      Caption = 'Ascending'
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuSortClick
    end
    object Descending1: TMenuItem
      Tag = 3
      Caption = 'Descending'
      GroupIndex = 1
      RadioItem = True
      OnClick = mnuSortClick
    end
  end
  object mnuShow: TPopupMenu
    AutoPopup = False
    Left = 424
    Top = 272
    object Show1: TMenuItem
      Caption = 'Show'
      Checked = True
      OnClick = mnuShowClick
    end
  end
  object mnuCriteria: TPopupMenu
    Left = 360
    Top = 272
    object Clear1: TMenuItem
      Caption = 'Clear'
      OnClick = Clear1Click
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object EditCriteria1: TMenuItem
      Caption = 'Edit Criteria...'
      OnClick = EditCriteria1Click
    end
  end
  object mnuUpdateTo: TPopupMenu
    Left = 328
    Top = 274
    object Clear2: TMenuItem
      Caption = 'Clear'
      OnClick = Clear2Click
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object Edit1: TMenuItem
      Caption = '&Edit...'
      OnClick = Edit1Click
    end
  end
  object mnuAppendTo: TPopupMenu
    Left = 296
    Top = 274
    object Clear3: TMenuItem
      Caption = 'Clear'
      OnClick = Clear3Click
    end
    object N5: TMenuItem
      Caption = '-'
    end
    object Edit2: TMenuItem
      Caption = 'Edit...'
      OnClick = Edit2Click
    end
  end
end
