object frmColumns: TfrmColumns
  Left = 388
  Top = 217
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  BorderWidth = 3
  Caption = 'Column'
  ClientHeight = 451
  ClientWidth = 464
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
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pgObjectEditor: TPageControl
    Left = 0
    Top = 0
    Width = 464
    Height = 401
    ActivePage = tsMain
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    HotTrack = True
    ParentFont = False
    TabOrder = 0
    object tsMain: TTabSheet
      Caption = 'Column'
      object pgColumn: TPageControl
        Left = 0
        Top = 58
        Width = 456
        Height = 315
        ActivePage = tsRaw
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
        TabOrder = 0
        object tsRaw: TTabSheet
          Caption = 'Raw Data Type'
          object nbRawDataType: TrmNoteBookControl
            Left = 0
            Top = 0
            Width = 448
            Height = 266
            ActivePageIndex = 0
            Align = alClient
            object nbpType: TrmNotebookPage
              Left = 0
              Top = 0
              Width = 448
              Height = 266
              Caption = 'Type'
              Data = 0
              Visible = False
              ImageIndex = -1
              object Label3: TLabel
                Left = 30
                Top = 11
                Width = 24
                Height = 13
                Caption = '&Type'
                FocusControl = cmbDataType
              end
              object cmbDataType: TComboBox
                Left = 58
                Top = 8
                Width = 362
                Height = 21
                Style = csDropDownList
                ItemHeight = 13
                TabOrder = 0
                OnChange = cmbDataTypeChange
                Items.Strings = (
                  'SMALLINT'
                  'INTEGER'
                  'FLOAT'
                  'DOUBLE PRECISION'
                  'DECIMAL'
                  'NUMERIC'
                  'DATE'
                  'TIME'
                  'TIMESTAMP'
                  'CHAR'
                  'VARCHAR'
                  'BLOB')
              end
              object nbType: TrmNoteBookControl
                Left = 0
                Top = 36
                Width = 427
                Height = 81
                ActivePageIndex = 3
                object nbpBlank: TrmNotebookPage
                  Left = 0
                  Top = 0
                  Width = 427
                  Height = 81
                  Caption = 'blank'
                  Data = 0
                  Enabled = False
                  Visible = False
                  ImageIndex = -1
                end
                object nbpChar: TrmNotebookPage
                  Left = 0
                  Top = 0
                  Width = 427
                  Height = 81
                  Caption = 'char'
                  Data = 0
                  Enabled = False
                  Visible = False
                  ImageIndex = -1
                  object Label4: TLabel
                    Left = 12
                    Top = 8
                    Width = 33
                    Height = 13
                    Caption = '&Length'
                    FocusControl = edLength
                  end
                  object Label9: TLabel
                    Left = 4
                    Top = 32
                    Width = 42
                    Height = 13
                    Caption = 'C&har Set'
                    FocusControl = cmbCharCharSet
                  end
                  object Label2: TLabel
                    Left = 12
                    Top = 56
                    Width = 33
                    Height = 13
                    Caption = 'Co&llate'
                    FocusControl = cmbCollate
                  end
                  object edLength: TEdit
                    Left = 52
                    Top = 4
                    Width = 149
                    Height = 21
                    TabOrder = 0
                    Text = '1'
                  end
                  object udLen: TUpDown
                    Left = 201
                    Top = 4
                    Width = 15
                    Height = 21
                    Associate = edLength
                    Min = 1
                    Max = 32767
                    Position = 1
                    TabOrder = 1
                    Thousands = False
                  end
                  object cmbCharCharSet: TComboBox
                    Left = 52
                    Top = 28
                    Width = 165
                    Height = 21
                    Style = csDropDownList
                    ItemHeight = 13
                    TabOrder = 2
                    Items.Strings = (
                      'NONE'
                      'OCTETS'
                      'ASCII'
                      'UNICODE_FSS'
                      'SJIS_0208'
                      'EUCJ_0208'
                      'DOS437'
                      'DOS850'
                      'DOS865'
                      'ISO8859_1'
                      'DOS852'
                      'DOS857'
                      'DOS860'
                      'DOS861'
                      'DOS863'
                      'CYRL'
                      'WIN1250'
                      'WIN1251'
                      'WIN1252'
                      'WIN1253'
                      'WIN1254'
                      'NEXT'
                      'KSC_5601'
                      'BIG_5'
                      'GB_2312')
                  end
                  object cmbCollate: TComboBox
                    Left = 52
                    Top = 52
                    Width = 369
                    Height = 21
                    Style = csDropDownList
                    ItemHeight = 13
                    TabOrder = 3
                    Items.Strings = (
                      'NONE'
                      'OCTETS'
                      'ASCII'
                      'UNICODE_FSS'
                      'SJIS_0208'
                      'EUCJ_0208'
                      'DOS437'
                      'PDOX_ASCII'
                      'PDOX_INTL'
                      'PDOX_SWEDFIN'
                      'DB_DEU437'
                      'DB_ESP437'
                      'DB_FIN437'
                      'DB_FRA437'
                      'DB_ITA437'
                      'DB_NLD437'
                      'DB_SVE437'
                      'DB_UK437'
                      'DB_US437'
                      'DOS850'
                      'DB_FRC850'
                      'DB_DEU850'
                      'DB_ESP850'
                      'DB_FRA850'
                      'DB_ITA850'
                      'DB_NLD850'
                      'DB_PTB850'
                      'DB_SVE850'
                      'DB_UK850'
                      'DB_US850'
                      'DOS865'
                      'PDOX_NORDAN4'
                      'DB_DAN865'
                      'DB_NOR865'
                      'ISO8859_1'
                      'DA_DA'
                      'DU_NL'
                      'FI_FI'
                      'FR_FR'
                      'FR_CA'
                      'DE_DE'
                      'IS_IS'
                      'IT_IT'
                      'NO_NO'
                      'ES_ES'
                      'SV_SV'
                      'EN_UK'
                      'EN_US'
                      'PT_PT'
                      'DOS852'
                      'DB_CSY'
                      'DB_PLK'
                      'DB_SLO'
                      'PDOX_CSY'
                      'PDOX_PLK'
                      'PDOX_HUN'
                      'PDOX_SLO'
                      'DOS857'
                      'DB_TRK'
                      'DOS860'
                      'DB_PTG860'
                      'DOS861'
                      'PDOX_ISL'
                      'DOS863'
                      'DB_FRC863'
                      'CYRL'
                      'DB_RUS'
                      'PDOX_CYRL'
                      'WIN1250'
                      'PXW_CSY'
                      'PXW_HUNDC'
                      'PXW_PLK'
                      'PXW_SLOV'
                      'WIN1251'
                      'PXW_CYRL'
                      'WIN1252'
                      'PXW_INTL'
                      'PXW_INTL850'
                      'PXW_NORDAN4'
                      'PXW_SPAN'
                      'PXW_SWEDFIN'
                      'WIN1253'
                      'PXW_GREEK'
                      'WIN1254'
                      'PXW_TURK'
                      'NEXT'
                      'NXT_US'
                      'NXT_DEU'
                      'NXT_FRA'
                      'NXT_ITA'
                      'NXT_ESP'
                      'KSC_5601'
                      'KSC_DICTIONARY'
                      'BIG_5'
                      'GB_2312')
                  end
                end
                object nbpNumeric: TrmNotebookPage
                  Left = 0
                  Top = 0
                  Width = 427
                  Height = 81
                  Caption = 'numeric'
                  Data = 0
                  Enabled = False
                  Visible = False
                  ImageIndex = -1
                  object Label14: TLabel
                    Left = 4
                    Top = 8
                    Width = 42
                    Height = 13
                    Caption = '&Precision'
                    FocusControl = edPrecision
                  end
                  object Label15: TLabel
                    Left = 20
                    Top = 28
                    Width = 25
                    Height = 13
                    Caption = '&Scale'
                    FocusControl = edScale
                  end
                  object edPrecision: TEdit
                    Left = 52
                    Top = 4
                    Width = 150
                    Height = 21
                    TabOrder = 0
                    Text = '9'
                  end
                  object edScale: TEdit
                    Left = 52
                    Top = 28
                    Width = 149
                    Height = 21
                    TabOrder = 1
                    Text = '2'
                  end
                  object upPrec: TUpDown
                    Left = 202
                    Top = 4
                    Width = 15
                    Height = 21
                    Associate = edPrecision
                    Max = 15
                    Position = 9
                    TabOrder = 2
                    Thousands = False
                  end
                  object upScale: TUpDown
                    Left = 201
                    Top = 28
                    Width = 15
                    Height = 21
                    Associate = edScale
                    Max = 15
                    Position = 2
                    TabOrder = 3
                    Thousands = False
                  end
                end
                object nbpBlob: TrmNotebookPage
                  Left = 0
                  Top = 0
                  Width = 427
                  Height = 81
                  Caption = 'blob'
                  Data = 0
                  Visible = False
                  ImageIndex = -1
                  object Label18: TLabel
                    Left = 8
                    Top = 7
                    Width = 45
                    Height = 13
                    Caption = '&Sub Type'
                    FocusControl = edSubType
                  end
                  object Label6: TLabel
                    Left = 13
                    Top = 31
                    Width = 42
                    Height = 13
                    Caption = 'C&har Set'
                    FocusControl = cmbBlobCharSet
                  end
                  object Label11: TLabel
                    Left = 257
                    Top = 7
                    Width = 64
                    Height = 13
                    Caption = 'Segment Si&ze'
                    FocusControl = edSegSize
                  end
                  object Label5: TLabel
                    Left = 22
                    Top = 55
                    Width = 33
                    Height = 13
                    Caption = 'Col&late'
                    FocusControl = cmbBlobCollate
                  end
                  object edSubType: TEdit
                    Left = 58
                    Top = 4
                    Width = 165
                    Height = 21
                    TabOrder = 0
                    Text = '0'
                  end
                  object cmbBlobCharSet: TComboBox
                    Left = 58
                    Top = 28
                    Width = 165
                    Height = 21
                    Style = csDropDownList
                    ItemHeight = 13
                    TabOrder = 1
                    Items.Strings = (
                      'NONE'
                      'OCTETS'
                      'ASCII'
                      'UNICODE_FSS'
                      'SJIS_0208'
                      'EUCJ_0208'
                      'DOS437'
                      'DOS850'
                      'DOS865'
                      'ISO8859_1'
                      'DOS852'
                      'DOS857'
                      'DOS860'
                      'DOS861'
                      'DOS863'
                      'CYRL'
                      'WIN1250'
                      'WIN1251'
                      'WIN1252'
                      'WIN1253'
                      'WIN1254'
                      'NEXT'
                      'KSC_5601'
                      'BIG_5'
                      'GB_2312')
                  end
                  object edSegSize: TEdit
                    Left = 326
                    Top = 4
                    Width = 76
                    Height = 21
                    ReadOnly = True
                    TabOrder = 2
                    Text = '80'
                  end
                  object udSegLength: TUpDown
                    Left = 402
                    Top = 4
                    Width = 15
                    Height = 21
                    Associate = edSegSize
                    Position = 80
                    TabOrder = 3
                  end
                  object cmbBlobCollate: TComboBox
                    Left = 58
                    Top = 52
                    Width = 360
                    Height = 21
                    Style = csDropDownList
                    ItemHeight = 13
                    TabOrder = 4
                    Items.Strings = (
                      'NONE'
                      'OCTETS'
                      'ASCII'
                      'UNICODE_FSS'
                      'SJIS_0208'
                      'EUCJ_0208'
                      'DOS437'
                      'PDOX_ASCII'
                      'PDOX_INTL'
                      'PDOX_SWEDFIN'
                      'DB_DEU437'
                      'DB_ESP437'
                      'DB_FIN437'
                      'DB_FRA437'
                      'DB_ITA437'
                      'DB_NLD437'
                      'DB_SVE437'
                      'DB_UK437'
                      'DB_US437'
                      'DOS850'
                      'DB_FRC850'
                      'DB_DEU850'
                      'DB_ESP850'
                      'DB_FRA850'
                      'DB_ITA850'
                      'DB_NLD850'
                      'DB_PTB850'
                      'DB_SVE850'
                      'DB_UK850'
                      'DB_US850'
                      'DOS865'
                      'PDOX_NORDAN4'
                      'DB_DAN865'
                      'DB_NOR865'
                      'ISO8859_1'
                      'DA_DA'
                      'DU_NL'
                      'FI_FI'
                      'FR_FR'
                      'FR_CA'
                      'DE_DE'
                      'IS_IS'
                      'IT_IT'
                      'NO_NO'
                      'ES_ES'
                      'SV_SV'
                      'EN_UK'
                      'EN_US'
                      'PT_PT'
                      'DOS852'
                      'DB_CSY'
                      'DB_PLK'
                      'DB_SLO'
                      'PDOX_CSY'
                      'PDOX_PLK'
                      'PDOX_HUN'
                      'PDOX_SLO'
                      'DOS857'
                      'DB_TRK'
                      'DOS860'
                      'DB_PTG860'
                      'DOS861'
                      'PDOX_ISL'
                      'DOS863'
                      'DB_FRC863'
                      'CYRL'
                      'DB_RUS'
                      'PDOX_CYRL'
                      'WIN1250'
                      'PXW_CSY'
                      'PXW_HUNDC'
                      'PXW_PLK'
                      'PXW_SLOV'
                      'WIN1251'
                      'PXW_CYRL'
                      'WIN1252'
                      'PXW_INTL'
                      'PXW_INTL850'
                      'PXW_NORDAN4'
                      'PXW_SPAN'
                      'PXW_SWEDFIN'
                      'WIN1253'
                      'PXW_GREEK'
                      'WIN1254'
                      'PXW_TURK'
                      'NEXT'
                      'NXT_US'
                      'NXT_DEU'
                      'NXT_FRA'
                      'NXT_ITA'
                      'NXT_ESP'
                      'KSC_5601'
                      'KSC_DICTIONARY'
                      'BIG_5'
                      'GB_2312')
                  end
                end
              end
              object pnlArray: TPanel
                Left = 0
                Top = 121
                Width = 427
                Height = 100
                BevelOuter = bvNone
                TabOrder = 2
                object Label10: TLabel
                  Left = 31
                  Top = 10
                  Width = 27
                  Height = 13
                  Caption = '&Array'
                  FocusControl = lvArray
                end
                object lvArray: TListView
                  Left = 60
                  Top = 8
                  Width = 259
                  Height = 89
                  Columns = <
                    item
                      Caption = 'LBound'
                      Width = 65
                    end
                    item
                      Caption = 'UBound'
                      Width = 65
                    end>
                  HideSelection = False
                  ReadOnly = True
                  TabOrder = 0
                  ViewStyle = vsReport
                end
                object btnAddDimension: TButton
                  Left = 328
                  Top = 8
                  Width = 93
                  Height = 25
                  Caption = '&Add Dimension'
                  TabOrder = 1
                  OnClick = btnAddDimensionClick
                end
                object btnDeleteDimension: TButton
                  Left = 328
                  Top = 64
                  Width = 93
                  Height = 25
                  Caption = '&Delete Dimension'
                  TabOrder = 2
                  OnClick = btnDeleteDimensionClick
                end
                object btnEditDimension: TButton
                  Left = 328
                  Top = 36
                  Width = 93
                  Height = 25
                  Caption = '&Edit Dimension'
                  TabOrder = 3
                  OnClick = btnEditDimensionClick
                end
              end
              object chkColNotNull: TCheckBox
                Left = 60
                Top = 223
                Width = 97
                Height = 17
                Caption = 'Not &Null'
                TabOrder = 3
              end
            end
            object nbpDefault: TrmNotebookPage
              Left = 0
              Top = 0
              Width = 448
              Height = 266
              Caption = 'Default'
              Data = 0
              Enabled = False
              Visible = False
              ImageIndex = -1
              object edDefault: TSyntaxMemoWithStuff2
                Left = 0
                Top = 0
                Width = 448
                Height = 266
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
          object tabRawDataType: TrmTabSet
            Left = 0
            Top = 266
            Width = 448
            Height = 21
            Align = alBottom
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -11
            Font.Name = 'Tahoma'
            Font.Style = []
            TabHeight = 19
            Tabs.Strings = (
              'Type'
              'Default')
            TabIndex = 0
            TabLocation = tlBottom
            TabType = ttWin2k
            OnChange = tabRawDataTypeChange
          end
        end
        object tsDomain: TTabSheet
          Caption = 'Domain'
          ImageIndex = 1
          object Label8: TLabel
            Left = 12
            Top = 11
            Width = 35
            Height = 13
            Caption = '&Domain'
            FocusControl = cmbDomain
          end
          object cmbDomain: TComboBox
            Left = 52
            Top = 8
            Width = 225
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
            OnChange = cmbDomainChange
          end
          object btnEditDomain: TButton
            Left = 288
            Top = 8
            Width = 75
            Height = 25
            Caption = 'Edit Domain'
            TabOrder = 1
            OnClick = btnColumnEditDomainClick
          end
          object btnNewDomain: TButton
            Left = 288
            Top = 33
            Width = 75
            Height = 25
            Caption = 'New Domain'
            TabOrder = 2
            OnClick = btnColumnEditDomainClick
          end
        end
        object tsComputed: TTabSheet
          Caption = 'Computed'
          ImageIndex = 2
          object edComputed: TSyntaxMemoWithStuff2
            Left = 0
            Top = 0
            Width = 432
            Height = 273
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
            OnChange = edColCheckChange
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
        object tsColumnDomain: TTabSheet
          Caption = 'Domain'
          ImageIndex = 3
          object Label12: TLabel
            Left = 10
            Top = 13
            Width = 35
            Height = 13
            Caption = '&Domain'
          end
          object lblColumnCollate: TLabel
            Left = 14
            Top = 39
            Width = 33
            Height = 13
            Caption = 'Collate'
            Visible = False
          end
          object cmbColumnDomain: TComboBox
            Left = 50
            Top = 10
            Width = 191
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
            OnChange = cmbColumnDomainChange
          end
          object btnColumnEditDomain: TButton
            Left = 258
            Top = 10
            Width = 75
            Height = 25
            Caption = 'Edit Domain'
            TabOrder = 1
            OnClick = btnColumnEditDomainClick
          end
          object btnColumnNewDomain: TButton
            Left = 258
            Top = 35
            Width = 75
            Height = 25
            Caption = 'New Domain'
            TabOrder = 2
            OnClick = btnColumnEditDomainClick
          end
          object cmbColumnCollate: TComboBox
            Left = 50
            Top = 36
            Width = 191
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 3
            Visible = False
          end
          object chkColumnNotNull: TCheckBox
            Left = 11
            Top = 65
            Width = 97
            Height = 17
            Caption = 'Not &Null'
            TabOrder = 4
            OnClick = chkColumnNotNullClick
          end
          object GroupBox1: TGroupBox
            Left = 10
            Top = 90
            Width = 409
            Height = 165
            Caption = ' Domain information '
            TabOrder = 5
            object edDomainInfo: TSyntaxMemoWithStuff2
              Left = 14
              Top = 20
              Width = 375
              Height = 131
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
              OnChange = edColCheckChange
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
        object tsColumnDefault: TTabSheet
          Caption = 'Column Default'
          ImageIndex = 4
          object edColumnDefault: TSyntaxMemoWithStuff2
            Left = 0
            Top = 0
            Width = 432
            Height = 273
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
        object tsColumnDescription: TTabSheet
          Caption = 'Column Description'
          ImageIndex = 5
          inline framColumnDoco: TframeDesc
            Left = 0
            Top = 0
            Width = 448
            Height = 287
            Align = alClient
            TabOrder = 0
            inherited edDoco: TSyntaxMemoWithStuff2
              Width = 448
              Height = 287
              Highlighter = dmMenus.synHighlighter
            end
          end
        end
      end
      object rmPanel1: TrmPanel
        Left = 0
        Top = 0
        Width = 456
        Height = 58
        Align = alTop
        ParentBackground = True
        TabOrder = 1
        DesignSize = (
          456
          58)
        object Label1: TLabel
          Left = 29
          Top = 30
          Width = 35
          Height = 13
          Caption = '&Column'
          FocusControl = edColumnName
        end
        object Label7: TLabel
          Left = 6
          Top = 6
          Width = 56
          Height = 13
          Caption = '&Table Name'
          FocusControl = edTableName
        end
        object Bevel1: TBevel
          Left = 3
          Top = 47
          Width = 445
          Height = 8
          Anchors = [akLeft, akTop, akRight]
          Shape = bsBottomLine
        end
        object edTableName: TEdit
          Left = 64
          Top = 3
          Width = 372
          Height = 21
          TabOrder = 0
          OnChange = edTableNameChange
        end
        object edColumnName: TEdit
          Left = 64
          Top = 27
          Width = 372
          Height = 21
          TabOrder = 1
          OnChange = edColumnNameChange
        end
      end
    end
    object tsConstraint: TTabSheet
      Caption = 'Constraint'
      object edConstraint: TSyntaxMemoWithStuff2
        Left = 0
        Top = 0
        Width = 448
        Height = 365
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
        OnChange = edColCheckChange
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
    object tsDescription: TTabSheet
      Caption = 'Description'
      ImageIndex = 4
      inline framDoco: TframeDesc
        Left = 0
        Top = 0
        Width = 456
        Height = 373
        Align = alClient
        TabOrder = 0
        inherited edDoco: TSyntaxMemoWithStuff2
          Width = 456
          Height = 373
          Highlighter = dmMenus.synHighlighter
        end
      end
    end
  end
  object stsEditor: TStatusBar
    Left = 0
    Top = 432
    Width = 464
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
    Visible = False
  end
  object rmPanel2: TrmPanel
    Left = 0
    Top = 401
    Width = 464
    Height = 31
    Align = alBottom
    ParentBackground = True
    TabOrder = 2
    object btnOK: TButton
      Left = 308
      Top = 4
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = btnOKClick
    end
    object btnCancel: TButton
      Left = 388
      Top = 4
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
    end
  end
  object qryUtil: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 12
    Top = 400
  end
end
