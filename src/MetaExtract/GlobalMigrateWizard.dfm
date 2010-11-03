object frmGlobalMigrateWizard: TfrmGlobalMigrateWizard
  Left = 464
  Top = 488
  Width = 467
  Height = 283
  ActiveControl = btnNext
  BorderIcons = [biSystemMenu]
  Caption = 'Metadata Extract Wizard'
  Color = clBtnFace
  Constraints.MinHeight = 283
  Constraints.MinWidth = 467
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000099999909999990000000000000000000000
    9900000990000000000000000000000099000009907070707070707070000000
    990000099000000000070707070000000990000099B3BFBF3B30007070000000
    099000BB99FBFBFBBBB3B00700000000099000B399B3BFBF3B3B300000000000
    0099003B399BFBFBBBB3B00000000000009900000993BFBF3B3B300000000000
    00990888899BFBFBBBB3B000000000000999999F9999BFBF3B3B300000000000
    000FFFFFF800FFFFB3B3B0000000008888888FFFF880FFFF3B3B307777700000
    0000000FFF8000000003B0EE8E7008888888888FFF80FBFBFBB000EE8E700000
    000000FFFFF0BFBFFFFFB088887000FFFFFFFFFFFF0BFBFFFFFFB0EE8E700000
    0000000000FFBFFFFFF00EEE8E700007EE07777700000000000EEEEE8E700007
    8880FFFFFFFFF8880888888888700007EEE0000000000000EEEEE8EEEE700007
    EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007
    88888888888888888888888888700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007
    EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007
    77777777777777777777777777700007CCCCCCCCCCCCCCCCCCCC488488700007
    CCCCCCCCCCCCCCCCCCCC4F84F87000077777777777777777777777777770FFFF
    FFFF8103FFFFF3E7FFFFF3E55557F3E000ABF9C00057F980002FF980003FFC80
    003FFC00003FFC00003FF800003FC00000008000000000000000000000000000
    00008000000080000000E0000000E0000000E0000000E0000000E0000000E000
    0000E0000000E0000000E0000000E0000000E0000000E0000000E0000000}
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    459
    249)
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = 0
    Top = 211
    Width = 456
    Height = 2
    Anchors = [akLeft, akRight, akBottom]
    Shape = bsBottomLine
  end
  object btnClose: TButton
    Left = 363
    Top = 218
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 0
  end
  object btnNext: TButton
    Left = 271
    Top = 218
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Next &>'
    Default = True
    TabOrder = 1
    OnClick = btnNextClick
  end
  object btnPrev: TButton
    Left = 195
    Top = 218
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&< Prev'
    Enabled = False
    TabOrder = 2
    OnClick = btnPrevClick
  end
  object nbWizard: TrmNoteBookControl
    Left = 0
    Top = 0
    Width = 459
    Height = 210
    ActivePageIndex = 0
    Align = alTop
    object nbpOne: TrmNotebookPage
      Left = 0
      Top = 0
      Width = 459
      Height = 210
      Caption = 'ONE'
      Data = 0
      Visible = False
      ImageIndex = -1
      DesignSize = (
        459
        210)
      object Bevel4: TBevel
        Left = 1
        Top = 52
        Width = 458
        Height = 5
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object Panel3: TPanel
        Left = 0
        Top = 0
        Width = 459
        Height = 54
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 0
        DesignSize = (
          459
          54)
        object Image1: TImage
          Left = 415
          Top = 12
          Width = 32
          Height = 32
          Anchors = [akTop, akRight]
          AutoSize = True
          Picture.Data = {
            055449636F6E0000010001002020100000000000E80200001600000028000000
            2000000040000000010004000000000080020000000000000000000000000000
            0000000000000000000080000080000000808000800000008000800080800000
            80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
            FFFFFF0000000000000000000000000000000000099999909999990000000000
            0000000000009900000990000000000000000000000099000009907070707070
            707070000000990000099000000000070707070000000990000099B3BFBF3B30
            007070000000099000BB99FBFBFBBBB3B00700000000099000B399B3BFBF3B3B
            3000000000000099003B399BFBFBBBB3B00000000000009900000993BFBF3B3B
            30000000000000990888899BFBFBBBB3B000000000000999999F9999BFBF3B3B
            300000000000000FFFFFF800FFFFB3B3B0000000008888888FFFF880FFFF3B3B
            3077777000000000000FFF8000000003B0EE8E7008888888888FFF80FBFBFBB0
            00EE8E700000000000FFFFF0BFBFFFFFB088887000FFFFFFFFFFFF0BFBFFFFFF
            B0EE8E7000000000000000FFBFFFFFF00EEE8E700007EE07777700000000000E
            EEEE8E7000078880FFFFFFFFF8880888888888700007EEE0000000000000EEEE
            E8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE70000788888888888888888888888888700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE70000777777777777777777777777777700007CCCCCCCCCCCCCCCCCCCC
            488488700007CCCCCCCCCCCCCCCCCCCC4F84F870000777777777777777777777
            77777770FFFFFFFF8103FFFFF3E7FFFFF3E55557F3E000ABF9C00057F980002F
            F980003FFC80003FFC00003FFC00003FF800003FC00000008000000000000000
            00000000000000008000000080000000E0000000E0000000E0000000E0000000
            E0000000E0000000E0000000E0000000E0000000E0000000E0000000E0000000
            E0000000}
        end
        object lblPrompt: TLabel
          Left = 36
          Top = 24
          Width = 283
          Height = 25
          AutoSize = False
          Caption = 'Welcome to the Marathon Metadata/Data extract wizard.'
        end
        object Label9: TLabel
          Left = 12
          Top = 4
          Width = 53
          Height = 13
          Caption = 'Welcome'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object rdoMigrate: TRadioGroup
        Left = 28
        Top = 75
        Width = 401
        Height = 113
        Anchors = [akLeft, akTop, akRight]
        Caption = ' What do you want to do? '
        ItemIndex = 0
        Items.Strings = (
          'Migrate Database Metadata to a script file'
          'Migrate Database Metadata and Data to a script file'
          'Migrate Database Data to a script file')
        TabOrder = 1
      end
    end
    object nbpTwo: TrmNotebookPage
      Left = 0
      Top = 0
      Width = 459
      Height = 210
      Caption = 'TWO'
      Data = 0
      Enabled = False
      Visible = False
      ImageIndex = -1
      DesignSize = (
        459
        210)
      object Label5: TLabel
        Left = 28
        Top = 92
        Width = 50
        Height = 13
        Caption = 'File Name:'
      end
      object Bevel3: TBevel
        Left = 1
        Top = 52
        Width = 458
        Height = 5
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object edFileName: TrmBtnEdit
        Left = 28
        Top = 108
        Width = 409
        Height = 21
        Btn1Glyph.Data = {
          BE000000424DBE00000000000000760000002800000009000000090000000100
          0400000000004800000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDD000
          0000DDDDDDDDD0000000D00D00D000000000D00D00D000000000DDDDDDDDD000
          0000DDDDDDDDD0000000DDDDDDDDD0000000DDDDDDDDD0000000DDDDDDDDD000
          0000}
        Btn1NumGlyphs = 1
        Btn2Glyph.Data = {
          BE000000424DBE00000000000000760000002800000009000000090000000100
          0400000000004800000000000000000000001000000010000000000000000000
          8000008000000080800080000000800080008080000080808000C0C0C0000000
          FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF00DDDDDDDDD000
          0000DDDDDDDDD0000000D00D00D000000000D00D00D000000000DDDDDDDDD000
          0000DDDDDDDDD0000000DDDDDDDDD0000000DDDDDDDDD0000000DDDDDDDDD000
          0000}
        Btn2NumGlyphs = 1
        TabOrder = 0
        OnBtn1Click = edFileNameBtn1Click
      end
      object Panel2: TPanel
        Left = 0
        Top = 0
        Width = 459
        Height = 54
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 1
        DesignSize = (
          459
          54)
        object Label1: TLabel
          Left = 36
          Top = 24
          Width = 235
          Height = 27
          AutoSize = False
          Caption = 'Enter the name of the file you wish to extract to.'
        end
        object Image2: TImage
          Left = 415
          Top = 12
          Width = 32
          Height = 32
          Anchors = [akTop, akRight]
          AutoSize = True
          Picture.Data = {
            055449636F6E0000010001002020100000000000E80200001600000028000000
            2000000040000000010004000000000080020000000000000000000000000000
            0000000000000000000080000080000000808000800000008000800080800000
            80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
            FFFFFF0000000000000000000000000000000000099999909999990000000000
            0000000000009900000990000000000000000000000099000009907070707070
            707070000000990000099000000000070707070000000990000099B3BFBF3B30
            007070000000099000BB99FBFBFBBBB3B00700000000099000B399B3BFBF3B3B
            3000000000000099003B399BFBFBBBB3B00000000000009900000993BFBF3B3B
            30000000000000990888899BFBFBBBB3B000000000000999999F9999BFBF3B3B
            300000000000000FFFFFF800FFFFB3B3B0000000008888888FFFF880FFFF3B3B
            3077777000000000000FFF8000000003B0EE8E7008888888888FFF80FBFBFBB0
            00EE8E700000000000FFFFF0BFBFFFFFB088887000FFFFFFFFFFFF0BFBFFFFFF
            B0EE8E7000000000000000FFBFFFFFF00EEE8E700007EE07777700000000000E
            EEEE8E7000078880FFFFFFFFF8880888888888700007EEE0000000000000EEEE
            E8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE70000788888888888888888888888888700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE70000777777777777777777777777777700007CCCCCCCCCCCCCCCCCCCC
            488488700007CCCCCCCCCCCCCCCCCCCC4F84F870000777777777777777777777
            77777770FFFFFFFF8103FFFFF3E7FFFFF3E55557F3E000ABF9C00057F980002F
            F980003FFC80003FFC00003FFC00003FF800003FC00000008000000000000000
            00000000000000008000000080000000E0000000E0000000E0000000E0000000
            E0000000E0000000E0000000E0000000E0000000E0000000E0000000E0000000
            E0000000}
        end
        object Label10: TLabel
          Left = 12
          Top = 4
          Width = 61
          Height = 13
          Caption = 'Select File'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
    end
    object nbpThree: TrmNotebookPage
      Left = 0
      Top = 0
      Width = 459
      Height = 210
      Caption = 'THREE'
      Data = 0
      Enabled = False
      Visible = False
      ImageIndex = -1
      DesignSize = (
        459
        210)
      object Bevel2: TBevel
        Left = 1
        Top = 52
        Width = 458
        Height = 5
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object pgDBMigrate: TPageControl
        Left = 4
        Top = 60
        Width = 451
        Height = 147
        ActivePage = tsObjects
        Anchors = [akLeft, akTop, akRight, akBottom]
        TabOrder = 0
        object tsObjects: TTabSheet
          Caption = 'Objects'
          object tvObjects: TVirtualStringTree
            Left = 0
            Top = 0
            Width = 443
            Height = 119
            Align = alClient
            ButtonFillMode = fmWindowColor
            CheckImageKind = ckDarkTick
            DrawSelectionMode = smBlendedRectangle
            Header.AutoSizeIndex = 0
            Header.Font.Charset = DEFAULT_CHARSET
            Header.Font.Color = clWindowText
            Header.Font.Height = -11
            Header.Font.Name = 'MS Sans Serif'
            Header.Font.Style = []
            Header.MainColumn = -1
            Header.Options = [hoColumnResize, hoDblClickResize, hoDrag, hoHotTrack]
            Header.Style = hsFlatButtons
            HintAnimation = hatNone
            Indent = 19
            TabOrder = 0
            TreeOptions.AnimationOptions = [toAnimatedToggle]
            TreeOptions.MiscOptions = [toAcceptOLEDrop, toCheckSupport, toFullRepaintOnResize, toInitOnSave, toToggleOnDblClick, toWheelPanning]
            TreeOptions.SelectionOptions = [toExtendedFocus, toMultiSelect, toRightClickSelect]
            OnGetText = tvObjectsGetText
            OnInitNode = tvObjectsInitNode
            Columns = <>
          end
        end
        object tsOptions: TTabSheet
          Caption = 'Options'
          ImageIndex = 1
          object Label7: TLabel
            Left = 228
            Top = 40
            Width = 76
            Height = 13
            Caption = 'Decimal Places:'
          end
          object Label8: TLabel
            Left = 212
            Top = 68
            Width = 90
            Height = 13
            Caption = 'Decimal Seperator:'
          end
          object Label6: TLabel
            Left = 368
            Top = 13
            Width = 39
            Height = 13
            Caption = 'columns'
          end
          object chkCreateDatabase: TCheckBox
            Left = 16
            Top = 12
            Width = 149
            Height = 17
            Caption = 'Use "CREATE DATABASE"'
            TabOrder = 0
          end
          object chkInclPassword: TCheckBox
            Left = 16
            Top = 40
            Width = 121
            Height = 17
            Caption = 'Include Password'
            TabOrder = 1
          end
          object chkInclDependents: TCheckBox
            Left = 16
            Top = 68
            Width = 157
            Height = 17
            Caption = 'Include Dependent Objects'
            TabOrder = 2
          end
          object chkWrapat: TCheckBox
            Left = 244
            Top = 12
            Width = 61
            Height = 17
            Caption = 'Wrap at'
            TabOrder = 3
          end
          object edWrap: TEdit
            Left = 308
            Top = 10
            Width = 41
            Height = 21
            TabOrder = 4
            Text = '0'
          end
          object upWrap: TUpDown
            Left = 349
            Top = 10
            Width = 12
            Height = 21
            Associate = edWrap
            TabOrder = 5
          end
          object udDecPlaces: TUpDown
            Left = 425
            Top = 36
            Width = 12
            Height = 21
            Associate = edDecPlaces
            TabOrder = 6
          end
          object edDecPlaces: TEdit
            Left = 308
            Top = 36
            Width = 117
            Height = 21
            TabOrder = 7
            Text = '0'
          end
          object cmbDecSep: TComboBox
            Left = 308
            Top = 64
            Width = 129
            Height = 21
            ItemHeight = 13
            TabOrder = 8
          end
          object chkIncludeDoc: TCheckBox
            Left = 16
            Top = 96
            Width = 185
            Height = 17
            Caption = 'Include Object Documentation'
            TabOrder = 9
          end
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 459
        Height = 54
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 1
        DesignSize = (
          459
          54)
        object Label2: TLabel
          Left = 36
          Top = 24
          Width = 380
          Height = 24
          AutoSize = False
          Caption = 
            'Select the items you want to include in the extract and set to o' +
            'ptions you wish to use.'
          WordWrap = True
        end
        object Image3: TImage
          Left = 418
          Top = 12
          Width = 32
          Height = 32
          Anchors = [akTop, akRight]
          AutoSize = True
          Picture.Data = {
            055449636F6E0000010001002020100000000000E80200001600000028000000
            2000000040000000010004000000000080020000000000000000000000000000
            0000000000000000000080000080000000808000800000008000800080800000
            80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
            FFFFFF0000000000000000000000000000000000099999909999990000000000
            0000000000009900000990000000000000000000000099000009907070707070
            707070000000990000099000000000070707070000000990000099B3BFBF3B30
            007070000000099000BB99FBFBFBBBB3B00700000000099000B399B3BFBF3B3B
            3000000000000099003B399BFBFBBBB3B00000000000009900000993BFBF3B3B
            30000000000000990888899BFBFBBBB3B000000000000999999F9999BFBF3B3B
            300000000000000FFFFFF800FFFFB3B3B0000000008888888FFFF880FFFF3B3B
            3077777000000000000FFF8000000003B0EE8E7008888888888FFF80FBFBFBB0
            00EE8E700000000000FFFFF0BFBFFFFFB088887000FFFFFFFFFFFF0BFBFFFFFF
            B0EE8E7000000000000000FFBFFFFFF00EEE8E700007EE07777700000000000E
            EEEE8E7000078880FFFFFFFFF8880888888888700007EEE0000000000000EEEE
            E8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE70000788888888888888888888888888700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE70000777777777777777777777777777700007CCCCCCCCCCCCCCCCCCCC
            488488700007CCCCCCCCCCCCCCCCCCCC4F84F870000777777777777777777777
            77777770FFFFFFFF8103FFFFF3E7FFFFF3E55557F3E000ABF9C00057F980002F
            F980003FFC80003FFC00003FFC00003FF800003FC00000008000000000000000
            00000000000000008000000080000000E0000000E0000000E0000000E0000000
            E0000000E0000000E0000000E0000000E0000000E0000000E0000000E0000000
            E0000000}
        end
        object Label11: TLabel
          Left = 12
          Top = 4
          Width = 67
          Height = 13
          Caption = 'Set Options'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
    end
    object nbpFour: TrmNotebookPage
      Left = 0
      Top = 0
      Width = 459
      Height = 210
      Caption = 'FOUR'
      Data = 0
      Enabled = False
      Visible = False
      ImageIndex = -1
      DesignSize = (
        459
        210)
      object lblProgress: TLabel
        Left = 24
        Top = 92
        Width = 429
        Height = 17
        AutoSize = False
        Caption = 'Progress...'
        WordWrap = True
      end
      object Bevel5: TBevel
        Left = 1
        Top = 52
        Width = 458
        Height = 5
        Anchors = [akLeft, akTop, akRight]
        Shape = bsBottomLine
      end
      object pbScriptProgress: TProgressBar
        Left = 24
        Top = 112
        Width = 409
        Height = 13
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
      object btnStop: TButton
        Left = 361
        Top = 169
        Width = 75
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = 'Stop'
        TabOrder = 1
        OnClick = btnStopClick
      end
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 459
        Height = 54
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 2
        DesignSize = (
          459
          54)
        object Label3: TLabel
          Left = 36
          Top = 24
          Width = 288
          Height = 25
          AutoSize = False
          Caption = 'Please wait while the Wizard performs the extract operation.'
        end
        object Image4: TImage
          Left = 415
          Top = 12
          Width = 32
          Height = 32
          Anchors = [akTop, akRight]
          AutoSize = True
          Picture.Data = {
            055449636F6E0000010001002020100000000000E80200001600000028000000
            2000000040000000010004000000000080020000000000000000000000000000
            0000000000000000000080000080000000808000800000008000800080800000
            80808000C0C0C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000
            FFFFFF0000000000000000000000000000000000099999909999990000000000
            0000000000009900000990000000000000000000000099000009907070707070
            707070000000990000099000000000070707070000000990000099B3BFBF3B30
            007070000000099000BB99FBFBFBBBB3B00700000000099000B399B3BFBF3B3B
            3000000000000099003B399BFBFBBBB3B00000000000009900000993BFBF3B3B
            30000000000000990888899BFBFBBBB3B000000000000999999F9999BFBF3B3B
            300000000000000FFFFFF800FFFFB3B3B0000000008888888FFFF880FFFF3B3B
            3077777000000000000FFF8000000003B0EE8E7008888888888FFF80FBFBFBB0
            00EE8E700000000000FFFFF0BFBFFFFFB088887000FFFFFFFFFFFF0BFBFFFFFF
            B0EE8E7000000000000000FFBFFFFFF00EEE8E700007EE07777700000000000E
            EEEE8E7000078880FFFFFFFFF8880888888888700007EEE0000000000000EEEE
            E8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE70000788888888888888888888888888700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEE
            E8EEEE70000777777777777777777777777777700007CCCCCCCCCCCCCCCCCCCC
            488488700007CCCCCCCCCCCCCCCCCCCC4F84F870000777777777777777777777
            77777770FFFFFFFF8103FFFFF3E7FFFFF3E55557F3E000ABF9C00057F980002F
            F980003FFC80003FFC00003FFC00003FF800003FC00000008000000000000000
            00000000000000008000000080000000E0000000E0000000E0000000E0000000
            E0000000E0000000E0000000E0000000E0000000E0000000E0000000E0000000
            E0000000}
        end
        object Label12: TLabel
          Left = 12
          Top = 4
          Width = 58
          Height = 13
          Caption = 'Extraction'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = [fsBold]
          ParentFont = False
        end
      end
      object btnStart: TButton
        Left = 273
        Top = 169
        Width = 75
        Height = 25
        Anchors = [akRight, akBottom]
        Caption = 'Start'
        TabOrder = 3
        OnClick = btnStartClick
      end
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 72
    Top = 320
  end
  object ActionList1: TActionList
    Left = 104
    Top = 320
  end
  object dlgOpen: TOpenDialog
    DefaultExt = 'sql'
    Filter = 'Script Files (*.sql)|*.SQL|All Files (*.*)|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofPathMustExist, ofEnableSizing]
    Title = 'Script File'
    Left = 140
    Top = 320
  end
  object rmCornerGrip1: TrmCornerGrip
    Left = 16
    Top = 316
  end
end
