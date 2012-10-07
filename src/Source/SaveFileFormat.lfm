object frmSaveFileFormat: TfrmSaveFileFormat
  Left = 320
  Top = 241
  Width = 362
  Height = 256
  Caption = 'Save To File...'
  Color = clBtnFace
  Constraints.MinHeight = 256
  Constraints.MinWidth = 362
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnShow = FormShow
  DesignSize = (
    354
    229)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 101
    Top = 199
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 180
    Top = 199
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 260
    Top = 199
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object pgFileExport: TPageControl
    Left = 4
    Top = 4
    Width = 345
    Height = 189
    ActivePage = tsDetails
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 3
    object tsDetails: TTabSheet
      Caption = 'Options'
      DesignSize = (
        337
        161)
      object Label1: TLabel
        Left = 0
        Top = 40
        Width = 35
        Height = 13
        Caption = 'F&ormat:'
        FocusControl = cmbFormat
      end
      object Label4: TLabel
        Left = 0
        Top = 8
        Width = 45
        Height = 13
        Caption = '&Filename:'
        FocusControl = edFileName
      end
      object nbFormat: TrmNoteBookControl
        Left = 0
        Top = 68
        Width = 337
        Height = 89
        ActivePageIndex = 1
        object nbpSV: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 337
          Height = 89
          Caption = 'fmtCSV'
          Data = 0
          Enabled = False
          Visible = False
          ImageIndex = -1
          object Label2: TLabel
            Left = 48
            Top = 36
            Width = 49
            Height = 13
            Caption = '&Separator:'
            FocusControl = cmbSep
          end
          object Label3: TLabel
            Left = 48
            Top = 60
            Width = 71
            Height = 13
            Caption = 'String &Qualifier:'
            FocusControl = cmbQual
          end
          object cmbSep: TComboBox
            Left = 132
            Top = 32
            Width = 65
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 0
            Items.Strings = (
              ','
              'TAB'
              '^'
              '~')
          end
          object cmbQual: TComboBox
            Left = 132
            Top = 56
            Width = 65
            Height = 21
            Style = csDropDownList
            ItemHeight = 13
            TabOrder = 1
            Items.Strings = (
              '"'
              #39
              '(NONE)')
          end
          object chkFirstRow: TCheckBox
            Left = 48
            Top = 8
            Width = 193
            Height = 17
            Caption = 'First &Row Contains Field Names'
            TabOrder = 2
          end
        end
        object nbpInsert: TrmNotebookPage
          Left = 0
          Top = 0
          Width = 337
          Height = 89
          Caption = 'fmtParadox'
          Data = 0
          Visible = False
          ImageIndex = -1
          DesignSize = (
            337
            89)
          object Label5: TLabel
            Left = 5
            Top = 12
            Width = 30
            Height = 13
            Caption = '&Table:'
            FocusControl = edTable
          end
          object edTable: TEdit
            Left = 48
            Top = 8
            Width = 285
            Height = 21
            Anchors = [akLeft, akTop, akRight]
            TabOrder = 0
          end
          object chkInsColNames: TCheckBox
            Left = 48
            Top = 36
            Width = 131
            Height = 17
            Caption = '&Include column names'
            TabOrder = 1
          end
          object chkInsColNamesSep: TCheckBox
            Left = 48
            Top = 54
            Width = 185
            Height = 17
            Caption = '&Place column names between "'
            TabOrder = 2
          end
        end
      end
      object cmbFormat: TComboBox
        Left = 48
        Top = 36
        Width = 285
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight, akBottom]
        ItemHeight = 13
        TabOrder = 1
        OnChange = cmbFormatChange
        Items.Strings = (
          'Separated Values'
          'Insert Statement')
      end
      object edFileName: TrmBtnEdit
        Left = 48
        Top = 4
        Width = 285
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        Btn1Glyph.Data = {
          32010000424D3201000000000000360000002800000009000000090000000100
          180000000000FC00000000000000000000000000000000000000C8D0D4C8D0D4
          C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400C8D0D4C8D0D4C8D0D4C8
          D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400C8D0D4000000000000C8D0D40000
          00000000C8D0D400000000000000C8D0D4000000000000C8D0D4000000000000
          C8D0D400000000000000C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8
          D0D4C8D0D400C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0
          D400C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400C8D0
          D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400C8D0D4C8D0D4
          C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400}
        Btn1NumGlyphs = 1
        Btn2Glyph.Data = {
          32050000424D3209000000000000360800002800000009000000090000000100
          180000000000FC00000000000000000000000001000000000000000000000000
          80000080000000808000800000008000800080800000C0C0C000C0DCC000F0CA
          A6000020400000206000002080000020A0000020C0000020E000004000000040
          20000040400000406000004080000040A0000040C0000040E000006000000060
          20000060400000606000006080000060A0000060C0000060E000008000000080
          20000080400000806000008080000080A0000080C0000080E00000A0000000A0
          200000A0400000A0600000A0800000A0A00000A0C00000A0E00000C0000000C0
          200000C0400000C0600000C0800000C0A00000C0C00000C0E00000E0000000E0
          200000E0400000E0600000E0800000E0A00000E0C00000E0E000400000004000
          20004000400040006000400080004000A0004000C0004000E000402000004020
          20004020400040206000402080004020A0004020C0004020E000404000004040
          20004040400040406000404080004040A0004040C0004040E000406000004060
          20004060400040606000406080004060A0004060C0004060E000408000004080
          20004080400040806000408080004080A0004080C0004080E00040A0000040A0
          200040A0400040A0600040A0800040A0A00040A0C00040A0E00040C0000040C0
          200040C0400040C0600040C0800040C0A00040C0C00040C0E00040E0000040E0
          200040E0400040E0600040E0800040E0A00040E0C00040E0E000800000008000
          20008000400080006000800080008000A0008000C0008000E000802000008020
          20008020400080206000802080008020A0008020C0008020E000804000008040
          20008040400080406000804080008040A0008040C0008040E000806000008060
          20008060400080606000806080008060A0008060C0008060E000808000008080
          20008080400080806000808080008080A0008080C0008080E00080A0000080A0
          200080A0400080A0600080A0800080A0A00080A0C00080A0E00080C0000080C0
          200080C0400080C0600080C0800080C0A00080C0C00080C0E00080E0000080E0
          200080E0400080E0600080E0800080E0A00080E0C00080E0E000C0000000C000
          2000C0004000C0006000C0008000C000A000C000C000C000E000C0200000C020
          2000C0204000C0206000C0208000C020A000C020C000C020E000C0400000C040
          2000C0404000C0406000C0408000C040A000C040C000C040E000C0600000C060
          2000C0604000C0606000C0608000C060A000C060C000C060E000C0800000C080
          2000C0804000C0806000C0808000C080A000C080C000C080E000C0A00000C0A0
          2000C0A04000C0A06000C0A08000C0A0A000C0A0C000C0A0E000C0C00000C0C0
          2000C0C04000C0C06000C0C08000C0C0A000F0FBFF00A4A0A000808080000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00C8D0D4C8D0D4
          C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400C8D0D4C8D0D4C8D0D4C8
          D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400C8D0D4000000000000C8D0D40000
          00000000C8D0D400000000000000C8D0D4000000000000C8D0D4000000000000
          C8D0D400000000000000C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8
          D0D4C8D0D400C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0
          D400C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400C8D0
          D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400C8D0D4C8D0D4
          C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D4C8D0D400}
        Btn2NumGlyphs = 1
        TabOrder = 2
        OnBtn1Click = edFileNameBtn1Click
      end
    end
    object tsColumns: TTabSheet
      Caption = 'Columns'
      ImageIndex = 1
      object chkListColumns: TCheckListBox
        Left = 0
        Top = 0
        Width = 252
        Height = 161
        Align = alClient
        ItemHeight = 13
        TabOrder = 0
      end
      object Panel1: TPanel
        Left = 252
        Top = 0
        Width = 85
        Height = 161
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        DesignSize = (
          85
          161)
        object btnSelectAll: TButton
          Left = 6
          Top = 2
          Width = 75
          Height = 25
          Anchors = [akRight, akBottom]
          Cancel = True
          Caption = 'Select All'
          TabOrder = 0
          OnClick = btnSelectAllClick
        end
        object btnSelectNone: TButton
          Left = 6
          Top = 30
          Width = 75
          Height = 25
          Anchors = [akRight, akBottom]
          Cancel = True
          Caption = 'Select None'
          TabOrder = 1
          OnClick = btnSelectNoneClick
        end
      end
    end
  end
  object dlgSave: TSaveDialog
    DefaultExt = '*.sql'
    Filter = 
      'SQL Files (*.sql)|*.sql|Text Files (*.txt)|*.txt|All Files (*.*)' +
      '|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly]
    Title = 'Save File'
    Left = 12
    Top = 200
  end
  object rmCornerGrip1: TrmCornerGrip
    Left = 64
    Top = 200
  end
end
