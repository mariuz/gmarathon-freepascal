object frmCreateDatabase: TfrmCreateDatabase
  Left = 299
  Top = 192
  BorderStyle = bsDialog
  Caption = 'Create Database'
  ClientHeight = 350
  ClientWidth = 476
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = -1
    Top = 312
    Width = 477
    Height = 2
    Shape = bsBottomLine
  end
  object Bevel2: TBevel
    Left = 0
    Top = 52
    Width = 476
    Height = 5
    Shape = bsBottomLine
  end
  object nbCreateDatabase: TNotebook
    Left = 4
    Top = 60
    Width = 469
    Height = 245
    TabOrder = 0
    object TPage
      Left = 0
      Top = 0
      Caption = 'ONE'
      object Label1: TLabel
        Left = 45
        Top = 12
        Width = 31
        Height = 13
        Caption = '&Name:'
      end
      object Label2: TLabel
        Left = 20
        Top = 60
        Width = 56
        Height = 13
        Caption = '&User Name:'
      end
      object Label3: TLabel
        Left = 27
        Top = 88
        Width = 49
        Height = 13
        Caption = '&Password:'
      end
      object Label4: TLabel
        Left = 25
        Top = 136
        Width = 51
        Height = 13
        Caption = 'Page &Size:'
      end
      object Label5: TLabel
        Left = 32
        Top = 164
        Width = 44
        Height = 13
        Caption = '&Char Set:'
      end
      object Label14: TLabel
        Left = 40
        Top = 192
        Width = 36
        Height = 13
        Caption = '&Dialect:'
      end
      object edDBName: TEdit
        Left = 80
        Top = 8
        Width = 381
        Height = 21
        TabOrder = 0
      end
      object edUser: TEdit
        Left = 80
        Top = 56
        Width = 157
        Height = 21
        TabOrder = 1
      end
      object edPassword: TEdit
        Left = 80
        Top = 84
        Width = 157
        Height = 21
        PasswordChar = '*'
        TabOrder = 2
      end
      object cmbPageSize: TComboBox
        Left = 80
        Top = 132
        Width = 157
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 3
        OnChange = cmbPageSizeChange
        Items.Strings = (
          '1024'
          '2048'
          '4096'
          '8192')
      end
      object cmbCharSet: TComboBox
        Left = 80
        Top = 160
        Width = 157
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 4
        Items.Strings = (
          'NONE'
          'OCTETS'
          'ASCII'
          'BIG_5'
          'CYRL'
          'DOS437'
          'DOS737'
          'DOS775'
          'DOS850'
          'DOS852'
          'DOS857'
          'DOS858'
          'DOS860'
          'DOS861'
          'DOS862'
          'DOS863'
          'DOS864'
          'DOS865'
          'DOS866'
          'DOS869'
          'EUCJ_0208'
          'GB_2312'
          'GB_2312'
          'ISO8859_1'
          'ISO8859_13'
          'ISO8859_2'
          'ISO8859_3'
          'ISO8859_4'
          'ISO8859_5'
          'ISO8859_6'
          'ISO8859_7'
          'ISO8859_8'
          'ISO8859_9'
          'KSC_5601'
          'NEXT'
          'SJIS_0208'
          'UNICODE_FSS'
          'WIN1250'
          'WIN1251'
          'WIN1252'
          'WIN1253'
          'WIN1254'
          'WIN1255'
          'WIN1256'
          'WIN1257')
      end
      object cmbDialect: TComboBox
        Left = 80
        Top = 188
        Width = 157
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 5
        Items.Strings = (
          '1'
          '2'
          '3')
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'TWO'
      object chkMultifile: TCheckBox
        Left = 8
        Top = 8
        Width = 113
        Height = 17
        Caption = 'Use &Multiple Files'
        TabOrder = 0
        OnClick = chkMultifileClick
      end
      object pnlFiles: TPanel
        Left = 0
        Top = 32
        Width = 465
        Height = 209
        BevelOuter = bvNone
        TabOrder = 1
        Visible = False
        object Label7: TLabel
          Left = 8
          Top = 8
          Width = 128
          Height = 13
          Caption = '&Primary File Length(Pages):'
        end
        object lblSize: TLabel
          Left = 228
          Top = 8
          Width = 45
          Height = 13
          Alignment = taRightJustify
          Caption = '[Size MB]'
        end
        object Label6: TLabel
          Left = 8
          Top = 32
          Width = 78
          Height = 13
          Caption = 'Secondary Files:'
        end
        object edLengthPages: TEdit
          Left = 144
          Top = 4
          Width = 77
          Height = 21
          TabOrder = 0
          OnChange = edLengthPagesChange
        end
        object btnAdd: TButton
          Left = 400
          Top = 52
          Width = 61
          Height = 25
          Caption = '&Add'
          TabOrder = 1
          OnClick = btnAddClick
        end
        object btnRemove: TButton
          Left = 400
          Top = 107
          Width = 61
          Height = 25
          Caption = '&Remove'
          TabOrder = 2
          OnClick = btnRemoveClick
        end
        object btnEdit: TButton
          Left = 400
          Top = 79
          Width = 61
          Height = 25
          Caption = '&Edit'
          TabOrder = 3
          OnClick = btnEditClick
        end
        object lvSecondaryFiles: TListView
          Left = 8
          Top = 52
          Width = 389
          Height = 153
          Columns = <
            item
              Caption = 'File'
              Width = 120
            end
            item
              Caption = 'Length'
              Width = 74
            end
            item
              Caption = '(Size MB)'
              Width = 60
            end>
          HideSelection = False
          ReadOnly = True
          TabOrder = 4
          ViewStyle = vsReport
        end
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'THREE'
      object Label9: TLabel
        Left = 12
        Top = 36
        Width = 30
        Height = 13
        Caption = '&Script:'
      end
      object SpeedButton1: TSpeedButton
        Left = 436
        Top = 52
        Width = 21
        Height = 22
        Caption = '...'
        OnClick = SpeedButton1Click
      end
      object chkRunScript: TCheckBox
        Left = 12
        Top = 12
        Width = 249
        Height = 17
        Caption = '&Run Script Against Newly Created Database'
        TabOrder = 0
      end
      object edScriptName: TEdit
        Left = 12
        Top = 52
        Width = 425
        Height = 21
        TabOrder = 1
      end
      object pnlMarathon: TPanel
        Left = 4
        Top = 88
        Width = 461
        Height = 153
        BevelOuter = bvNone
        TabOrder = 2
        object lblFurtherAction: TLabel
          Left = 8
          Top = 68
          Width = 67
          Height = 13
          Caption = '&Project Name:'
          Enabled = False
        end
        object lblFurtherActionOne: TLabel
          Left = 8
          Top = 112
          Width = 88
          Height = 13
          Caption = '&Connection Name:'
          Enabled = False
        end
        object chkFurtherAction: TCheckBox
          Left = 8
          Top = 4
          Width = 341
          Height = 17
          Caption = 'Perform further action'
          Enabled = False
          TabOrder = 0
          OnClick = chkFurtherActionClick
        end
        object rbCreateProject: TRadioButton
          Left = 28
          Top = 24
          Width = 425
          Height = 17
          Caption = 'Create &Marathon Project and Connect when Database is Created'
          Checked = True
          Enabled = False
          TabOrder = 1
          TabStop = True
          OnClick = rbCreateConnectionClick
        end
        object rbCreateConnection: TRadioButton
          Left = 28
          Top = 44
          Width = 421
          Height = 17
          Caption = 
            'Create &Connection in currently open Marathon Project and Connec' +
            't'
          Enabled = False
          TabOrder = 2
          OnClick = rbCreateConnectionClick
        end
        object edProjectName: TEdit
          Left = 8
          Top = 84
          Width = 441
          Height = 21
          Enabled = False
          TabOrder = 3
        end
        object edConnectionName: TEdit
          Left = 8
          Top = 128
          Width = 441
          Height = 21
          Enabled = False
          TabOrder = 4
        end
      end
    end
    object TPage
      Left = 0
      Top = 0
      Caption = 'FOUR'
      object Label10: TLabel
        Left = 8
        Top = 44
        Width = 38
        Height = 13
        Caption = 'Results:'
      end
      object Label12: TLabel
        Left = 8
        Top = 8
        Width = 345
        Height = 37
        AutoSize = False
        Caption = 
          'Marathon now has all the information required to create the data' +
          'base. Click Create to create the database.'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        WordWrap = True
      end
      object edResults: TMemo
        Left = 8
        Top = 60
        Width = 453
        Height = 171
        ReadOnly = True
        ScrollBars = ssVertical
        TabOrder = 0
      end
    end
  end
  object btnBack: TButton
    Left = 232
    Top = 320
    Width = 75
    Height = 25
    Caption = '&< Back'
    Enabled = False
    TabOrder = 1
    OnClick = btnBackClick
  end
  object btnFinish: TButton
    Left = 308
    Top = 320
    Width = 75
    Height = 25
    Caption = 'Next &>'
    Default = True
    TabOrder = 2
    OnClick = btnFinishClick
  end
  object btnClose: TButton
    Left = 396
    Top = 320
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'C&lose'
    TabOrder = 3
    OnClick = btnCloseClick
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 476
    Height = 54
    Align = alTop
    BevelOuter = bvNone
    Color = clWhite
    TabOrder = 4
    object Label8: TLabel
      Left = 12
      Top = 4
      Width = 96
      Height = 13
      Caption = 'Create Database'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object Label13: TLabel
      Left = 28
      Top = 20
      Width = 197
      Height = 13
      Caption = 'Enter the details about the new database.'
    end
    object Image1: TImage
      Left = 436
      Top = 8
      Width = 32
      Height = 32
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
  end
  object dbCreateDatabase: TIB_Connection
    Left = 12
    Top = 320
  end
  object tranCreateConnection: TIB_Transaction
    IB_Connection = dbCreateDatabase
    Left = 44
    Top = 320
  end
  object qryConnection: TIB_DSQL
    IB_Connection = dbCreateDatabase
    IB_Transaction = tranCreateConnection
    ParamCheck = False
    Left = 76
    Top = 320
  end
  object dlgOpen: TOpenDialog
    Filter = 'SQL Files (*.sql)|*.sql|All Files (*.*)|*.*'
    Title = 'Open Script File'
    Left = 108
    Top = 320
  end
  object ibScript: TIB_Script
    Yield = False
    OnError = ibScriptError
    IB_Connection = dbCreateDatabase
    IB_Transaction = tranCreateConnection
    Left = 144
    Top = 320
  end
end
