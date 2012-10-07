object frmGlobalPrintDialog: TfrmGlobalPrintDialog
  Left = 342
  Top = 214
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Print'
  ClientHeight = 305
  ClientWidth = 519
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 274
    Width = 519
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object btnOptions: TButton
      Left = 6
      Top = 2
      Width = 93
      Height = 25
      Caption = 'Printer O&ptions'
      TabOrder = 0
      OnClick = btnOptionsClick
    end
    object Panel2: TPanel
      Left = 352
      Top = 0
      Width = 167
      Height = 31
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      object btnOK: TButton
        Left = 4
        Top = 2
        Width = 75
        Height = 25
        Caption = 'OK'
        Default = True
        TabOrder = 0
        OnClick = btnOKClick
      end
      object btnCancel: TButton
        Left = 86
        Top = 2
        Width = 75
        Height = 25
        Cancel = True
        Caption = 'Cancel'
        ModalResult = 2
        TabOrder = 1
        OnClick = btnCancelClick
      end
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 134
    Width = 519
    Height = 140
    Align = alBottom
    BevelOuter = bvNone
    BorderWidth = 6
    Caption = 'Panel3'
    TabOrder = 1
    object gbOptions: TGroupBox
      Left = 6
      Top = 6
      Width = 507
      Height = 128
      Align = alClient
      Caption = 'Output Options'
      TabOrder = 0
      object Label5: TLabel
        Left = 12
        Top = 23
        Width = 86
        Height = 13
        Caption = 'Number of &copies:'
        FocusControl = edNumCopies
      end
      object chkWrap: TCheckBox
        Left = 106
        Top = 48
        Width = 97
        Height = 17
        Caption = '&Wrap long lines'
        TabOrder = 1
      end
      object edNumCopies: TrmSpinEdit
        Left = 105
        Top = 20
        Width = 66
        Height = 21
        MaxValue = 0
        MinValue = 0
        Value = 0
        TabOrder = 0
      end
      object pnFonts: TPanel
        Left = 8
        Top = 68
        Width = 389
        Height = 55
        BevelOuter = bvLowered
        TabOrder = 2
        object Label1: TLabel
          Left = 6
          Top = 4
          Width = 29
          Height = 13
          Caption = 'Fonts:'
          FocusControl = edNumCopies
        end
        object pnPageHeaderFont: TPanel
          Left = 88
          Top = 2
          Width = 99
          Height = 25
          Caption = 'Page Header'
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 0
          OnClick = pnTitleFontClick
        end
        object pnDataHeaderFont: TPanel
          Left = 188
          Top = 2
          Width = 99
          Height = 25
          Caption = 'Data Header'
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 1
          OnClick = pnTitleFontClick
        end
        object pnTailFont: TPanel
          Left = 288
          Top = 2
          Width = 99
          Height = 25
          Caption = 'Tail'
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 2
          OnClick = pnTitleFontClick
        end
        object pnPageFooterFont: TPanel
          Left = 288
          Top = 28
          Width = 99
          Height = 25
          Caption = 'Page Footer'
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 3
          OnClick = pnTitleFontClick
        end
        object pnDataFont: TPanel
          Left = 188
          Top = 28
          Width = 99
          Height = 25
          Caption = 'Data'
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 4
          OnClick = pnTitleFontClick
        end
        object pnTitleFont: TPanel
          Left = 88
          Top = 28
          Width = 99
          Height = 25
          Caption = 'Title'
          Font.Charset = EASTEUROPE_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Courier New'
          Font.Style = []
          ParentFont = False
          TabOrder = 5
          OnClick = pnTitleFontClick
        end
      end
    end
  end
  object pnObjects: TPanel
    Left = 0
    Top = 0
    Width = 519
    Height = 134
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 2
    object pgPrintDialog: TPageControl
      Left = 0
      Top = 0
      Width = 519
      Height = 134
      ActivePage = tsDatabase
      Align = alClient
      HotTrack = True
      TabOrder = 0
      Visible = False
      object tsDatabase: TTabSheet
        Caption = 'Database'
        ImageIndex = 6
        object chkDbNewPage: TCheckBox
          Left = 332
          Top = 8
          Width = 75
          Height = 17
          Hint = 'Start print each object '#13#10'type on new page'
          Caption = 'New Page'
          Checked = True
          ParentShowHint = False
          ShowHint = True
          State = cbChecked
          TabOrder = 0
        end
        object chkDbTables: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Tables'
          Checked = True
          State = cbChecked
          TabOrder = 1
        end
        object chkDbViews: TCheckBox
          Left = 8
          Top = 56
          Width = 97
          Height = 17
          Caption = 'Views'
          Checked = True
          State = cbChecked
          TabOrder = 2
        end
        object chkDbSp: TCheckBox
          Left = 8
          Top = 80
          Width = 117
          Height = 17
          Caption = 'Stored Procedures'
          Checked = True
          State = cbChecked
          TabOrder = 3
        end
        object chkDbTriggers: TCheckBox
          Left = 188
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Triggers'
          Checked = True
          State = cbChecked
          TabOrder = 4
        end
        object chkDbDomains: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Domains'
          Checked = True
          State = cbChecked
          TabOrder = 5
        end
        object chkDbGenerators: TCheckBox
          Left = 188
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Generators'
          Checked = True
          State = cbChecked
          TabOrder = 6
        end
        object chkDbExceptions: TCheckBox
          Left = 188
          Top = 56
          Width = 97
          Height = 17
          Caption = 'Exceptions'
          Checked = True
          State = cbChecked
          TabOrder = 7
        end
        object chkDbUDFs: TCheckBox
          Left = 188
          Top = 80
          Width = 97
          Height = 17
          Caption = 'UDFs'
          Checked = True
          State = cbChecked
          TabOrder = 8
        end
      end
      object tsDomain: TTabSheet
        Caption = 'Domain'
        ImageIndex = 7
        object chkDomainDet: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Details'
          TabOrder = 0
        end
      end
      object tsTable: TTabSheet
        Caption = 'Table'
        object chkTabStruct: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Table Structure'
          TabOrder = 0
        end
        object chkTabConstraints: TCheckBox
          Left = 8
          Top = 56
          Width = 97
          Height = 17
          Caption = 'Constraints'
          TabOrder = 1
        end
        object chkTabIndexes: TCheckBox
          Left = 8
          Top = 80
          Width = 97
          Height = 17
          Caption = 'Indexes'
          TabOrder = 2
        end
        object chkTabDepend: TCheckBox
          Left = 188
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Dependencies'
          TabOrder = 3
        end
        object chkTabTriggerSummary: TCheckBox
          Left = 188
          Top = 8
          Width = 59
          Height = 17
          Caption = 'Triggers'
          TabOrder = 4
        end
        object chkTabDoco: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Documentation'
          TabOrder = 5
        end
        object chkTabTriggerDetail: TCheckBox
          Left = 252
          Top = 8
          Width = 71
          Height = 17
          Caption = 'with code'
          TabOrder = 6
        end
      end
      object tsView: TTabSheet
        Caption = 'View'
        object chkViewStruct: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'View Structure'
          TabOrder = 0
        end
        object chkViewDepend: TCheckBox
          Left = 8
          Top = 56
          Width = 97
          Height = 17
          Caption = 'Dependencies'
          TabOrder = 1
        end
        object chkViewTriggerSummary: TCheckBox
          Left = 8
          Top = 80
          Width = 63
          Height = 17
          Caption = 'Triggers'
          TabOrder = 2
        end
        object chkViewDoco: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Documentation'
          TabOrder = 3
        end
        object chkViewSource: TCheckBox
          Left = 188
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Source'
          TabOrder = 4
        end
        object chkViewTriggerDetail: TCheckBox
          Left = 78
          Top = 80
          Width = 71
          Height = 17
          Caption = 'with code'
          TabOrder = 5
        end
      end
      object tsSP: TTabSheet
        Caption = 'Stored Procedure'
        object chkSPCode: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Code'
          TabOrder = 0
        end
        object chkSPDoco: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Documentation'
          TabOrder = 1
        end
      end
      object tsTrigger: TTabSheet
        Caption = 'Trigger'
        object chkTrigCode: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Code'
          TabOrder = 0
        end
        object chkTrigDoco: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Documentation'
          TabOrder = 1
        end
      end
      object tsGenerator: TTabSheet
        Caption = 'Generator'
        ImageIndex = 8
        object chkGeneratorDet: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Details'
          TabOrder = 0
        end
      end
      object tsExcept: TTabSheet
        Caption = 'Exception'
        object chkExCode: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'Exception'
          TabOrder = 0
        end
        object chkExDoco: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Documentation'
          TabOrder = 1
        end
      end
      object tsUDF: TTabSheet
        Caption = 'UDF'
        object chkUDFCOde: TCheckBox
          Left = 8
          Top = 32
          Width = 97
          Height = 17
          Caption = 'UDF'
          TabOrder = 0
        end
        object chkUDFDoco: TCheckBox
          Left = 8
          Top = 8
          Width = 97
          Height = 17
          Caption = 'Documentation'
          TabOrder = 1
        end
      end
    end
  end
  object dlgFont: TFontDialog
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    Left = 16
    Top = 264
  end
end
