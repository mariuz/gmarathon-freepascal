object frmDomains: TfrmDomains
  Left = 381
  Top = 154
  Width = 460
  Height = 460
  Caption = 'Domain'
  Color = clBtnFace
  Constraints.MinHeight = 460
  Constraints.MinWidth = 460
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object pgObjectEditor: TPageControl
    Left = 0
    Top = 0
    Width = 452
    Height = 344
    ActivePage = tsMain
    Align = alClient
    HotTrack = True
    TabOrder = 0
    OnChange = pgObjectEditorChange
    object tsMain: TTabSheet
      Caption = 'Domain'
      DesignSize = (
        444
        316)
      object Label1: TLabel
        Left = 16
        Top = 12
        Width = 39
        Height = 13
        Caption = '&Domain:'
        FocusControl = edColumn
      end
      object Bevel1: TBevel
        Left = 4
        Top = 32
        Width = 433
        Height = 10
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Label3: TLabel
        Left = 27
        Top = 52
        Width = 27
        Height = 13
        Caption = '&Type:'
        FocusControl = cmbDataType
      end
      object edColumn: TEdit
        Left = 60
        Top = 12
        Width = 377
        Height = 21
        TabOrder = 0
        OnChange = edColumnChange
      end
      object cmbDataType: TComboBox
        Left = 60
        Top = 48
        Width = 380
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
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
        Left = 4
        Top = 76
        Width = 437
        Height = 85
        ActivePageIndex = 1
        object nbpBlank: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 437
          Height = 85
          Caption = 'blank'
          Data = 0
          Enabled = False
          Visible = False
          ImageIndex = -1
        end
        object nbpChar: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 437
          Height = 85
          Caption = 'char'
          Data = 0
          Visible = False
          ImageIndex = -1
          object Label4: TLabel
            Left = 16
            Top = 8
            Width = 36
            Height = 13
            Caption = '&Length:'
            FocusControl = edLength
          end
          object Label9: TLabel
            Left = 8
            Top = 32
            Width = 44
            Height = 13
            Caption = 'C&har Set:'
            FocusControl = cmbCharCharSet
          end
          object Label2: TLabel
            Left = 16
            Top = 56
            Width = 35
            Height = 13
            Caption = 'Co&llate:'
            FocusControl = cmbCollate
          end
          object edLength: TEdit
            Left = 56
            Top = 4
            Width = 148
            Height = 21
            TabOrder = 0
            Text = '1'
            OnChange = edLengthChange
          end
          object udLen: TUpDown
            Left = 204
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
            Left = 56
            Top = 28
            Width = 165
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 2
            OnChange = edLengthChange
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
            Left = 56
            Top = 52
            Width = 377
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 3
            OnChange = edLengthChange
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
          Width = 437
          Height = 85
          Caption = 'numeric'
          Data = 0
          Enabled = False
          Visible = False
          ImageIndex = -1
          object Label14: TLabel
            Left = 8
            Top = 8
            Width = 46
            Height = 13
            Caption = '&Precision:'
            FocusControl = edPrecision
          end
          object Label15: TLabel
            Left = 24
            Top = 28
            Width = 30
            Height = 13
            Caption = '&Scale:'
            FocusControl = edScale
          end
          object edPrecision: TEdit
            Left = 56
            Top = 4
            Width = 149
            Height = 21
            TabOrder = 0
            Text = '9'
            OnChange = edLengthChange
          end
          object edScale: TEdit
            Left = 56
            Top = 28
            Width = 150
            Height = 21
            TabOrder = 1
            Text = '2'
            OnChange = edLengthChange
          end
          object upPrec: TUpDown
            Left = 205
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
            Left = 206
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
          Width = 437
          Height = 85
          Caption = 'blob'
          Data = 0
          Enabled = False
          Visible = False
          ImageIndex = -1
          object Label18: TLabel
            Left = 4
            Top = 8
            Width = 49
            Height = 13
            Caption = '&Sub Type:'
            FocusControl = edSubType
          end
          object Label6: TLabel
            Left = 8
            Top = 32
            Width = 44
            Height = 13
            Caption = 'C&har Set:'
            FocusControl = cmbBlobCharSet
          end
          object Label11: TLabel
            Left = 272
            Top = 8
            Width = 68
            Height = 13
            Caption = 'Segment Si&ze:'
            FocusControl = edSegSize
          end
          object Label5: TLabel
            Left = 16
            Top = 56
            Width = 35
            Height = 13
            Caption = 'Co&llate:'
            FocusControl = cmbBlobCollate
          end
          object edSubType: TEdit
            Left = 56
            Top = 4
            Width = 165
            Height = 21
            TabOrder = 0
            Text = '0'
            OnChange = edLengthChange
          end
          object cmbBlobCharSet: TComboBox
            Left = 56
            Top = 28
            Width = 165
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 1
            OnChange = edLengthChange
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
            Left = 348
            Top = 4
            Width = 69
            Height = 21
            ReadOnly = True
            TabOrder = 2
            Text = '80'
            OnChange = edLengthChange
          end
          object udSegLength: TUpDown
            Left = 417
            Top = 4
            Width = 15
            Height = 21
            Associate = edSegSize
            Position = 80
            TabOrder = 3
          end
          object cmbBlobCollate: TComboBox
            Left = 56
            Top = 52
            Width = 377
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 4
            OnChange = edLengthChange
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
      object chkColNotNull: TCheckBox
        Left = 60
        Top = 288
        Width = 97
        Height = 17
        Caption = 'Not &Null'
        TabOrder = 3
      end
      object pnlArray: TPanel
        Left = 4
        Top = 164
        Width = 437
        Height = 117
        BevelOuter = bvNone
        TabOrder = 4
        object Label10: TLabel
          Left = 20
          Top = 4
          Width = 27
          Height = 13
          Caption = '&Array:'
          FocusControl = lvArray
        end
        object lvArray: TListView
          Left = 56
          Top = 4
          Width = 273
          Height = 101
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
          Left = 340
          Top = 4
          Width = 93
          Height = 25
          Caption = '&Add Dimension'
          TabOrder = 1
          OnClick = btnAddDimensionClick
        end
        object btnDeleteDimension: TButton
          Left = 340
          Top = 60
          Width = 93
          Height = 25
          Caption = '&Delete Dimension'
          TabOrder = 2
          OnClick = btnDeleteDimensionClick
        end
        object btnEditDimension: TButton
          Left = 340
          Top = 32
          Width = 93
          Height = 25
          Caption = '&Edit Dimension'
          TabOrder = 3
          OnClick = btnEditDimensionClick
        end
      end
    end
    object tsDefault: TTabSheet
      Caption = 'Default'
      object edDefault: TSyntaxMemoWithStuff2
        Left = 0
        Top = 0
        Width = 444
        Height = 316
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
        OnChange = edColDefaultChange
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
    object tsConstraint: TTabSheet
      Caption = 'Constraint'
      object edConstraint: TSyntaxMemoWithStuff2
        Left = 0
        Top = 0
        Width = 444
        Height = 316
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
        Width = 444
        Height = 316
        Align = alClient
        TabOrder = 0
        inherited edDoco: TSyntaxMemoWithStuff2
          Width = 444
          Height = 316
        end
      end
    end
    object tsDDL: TTabSheet
      Caption = 'DDL'
      inline framDDL: TframDisplayDDL
        Left = 0
        Top = 0
        Width = 444
        Height = 316
        Align = alClient
        TabOrder = 0
        inherited edDDL: TSyntaxMemoWithStuff2
          Width = 444
          Height = 316
        end
      end
    end
  end
  object stsEditor: TStatusBar
    Left = 0
    Top = 414
    Width = 452
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
  object pnlMessages: TPanel
    Left = 0
    Top = 344
    Width = 452
    Height = 70
    Align = alBottom
    BevelOuter = bvNone
    Caption = 'pnlMessages'
    TabOrder = 2
    Visible = False
    object lstResults: TrmCollectionListBox
      Left = 0
      Top = 0
      Width = 452
      Height = 70
      AutoSelect = True
      Collection = <>
      Images = dmMenus.ilErrors
      Align = alClient
      TabOrder = 0
    end
  end
  object qryDomain: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 8
    Top = 280
  end
end
