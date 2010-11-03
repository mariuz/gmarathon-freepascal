object frmAutoInc: TfrmAutoInc
  Left = 455
  Top = 285
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'AutoIncrement Field Wizard'
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
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object Bevel1: TBevel
    Left = -1
    Top = 312
    Width = 477
    Height = 2
    Shape = bsBottomLine
  end
  object btnPrev: TButton
    Left = 232
    Top = 320
    Width = 75
    Height = 25
    Caption = '&< Prev'
    Enabled = False
    TabOrder = 0
  end
  object btnNext: TButton
    Left = 308
    Top = 320
    Width = 75
    Height = 25
    Caption = '&Finish'
    Default = True
    TabOrder = 1
    OnClick = btnNextClick
  end
  object btnClose: TButton
    Left = 396
    Top = 320
    Width = 75
    Height = 25
    Caption = '&Close'
    ModalResult = 2
    TabOrder = 2
  end
  object Notebook1: TNotebook
    Left = 0
    Top = 0
    Width = 476
    Height = 309
    Align = alTop
    TabOrder = 3
    object TPage
      Left = 0
      Top = 0
      Caption = 'Default'
      object Label1: TLabel
        Left = 88
        Top = 72
        Width = 61
        Height = 13
        Caption = 'Table Name:'
      end
      object Label4: TLabel
        Left = 108
        Top = 100
        Width = 38
        Height = 13
        Caption = 'Column:'
      end
      object Label2: TLabel
        Left = 64
        Top = 128
        Width = 81
        Height = 13
        Caption = 'Generator Name:'
      end
      object Label5: TLabel
        Left = 80
        Top = 156
        Width = 67
        Height = 13
        Caption = 'Trigger Name:'
      end
      object Label6: TLabel
        Left = 152
        Top = 184
        Width = 104
        Height = 13
        Caption = 'Trigger Firing Position:'
      end
      object Label7: TLabel
        Left = 28
        Top = 244
        Width = 117
        Height = 13
        Caption = 'Stored Procedure Name:'
      end
      object Bevel2: TBevel
        Left = 0
        Top = 52
        Width = 476
        Height = 5
        Shape = bsBottomLine
      end
      object Label3: TLabel
        Left = 152
        Top = 268
        Width = 305
        Height = 33
        AutoSize = False
        Caption = 
          'Note that using a stored procedure wrapper may cause problems wi' +
          'th some versions of Interbase.'
        WordWrap = True
      end
      object edTableName: TEdit
        Left = 152
        Top = 68
        Width = 313
        Height = 21
        ReadOnly = True
        TabOrder = 0
      end
      object cmbColumn: TComboBox
        Left = 152
        Top = 96
        Width = 309
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
      end
      object edGeneratorName: TEdit
        Left = 152
        Top = 124
        Width = 309
        Height = 21
        TabOrder = 2
      end
      object edTriggerName: TEdit
        Left = 152
        Top = 152
        Width = 305
        Height = 21
        TabOrder = 3
      end
      object edFiringPos: TEdit
        Left = 260
        Top = 180
        Width = 181
        Height = 21
        ReadOnly = True
        TabOrder = 4
        Text = '0'
      end
      object udFiringPos: TUpDown
        Left = 441
        Top = 180
        Width = 15
        Height = 21
        Associate = edFiringPos
        Min = 0
        Max = 50
        Position = 0
        TabOrder = 5
        Wrap = False
      end
      object chkUseSPWrapper: TCheckBox
        Left = 152
        Top = 216
        Width = 193
        Height = 17
        Caption = 'Use Stored Procedure Wrapper'
        TabOrder = 6
        OnClick = chkUseSPWrapperClick
      end
      object edSPName: TEdit
        Left = 152
        Top = 240
        Width = 305
        Height = 21
        TabOrder = 7
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 476
        Height = 54
        Align = alTop
        BevelOuter = bvNone
        Color = clWhite
        TabOrder = 8
        object Label8: TLabel
          Left = 12
          Top = 4
          Width = 157
          Height = 13
          Caption = 'AutoIncrement Field Wizard'
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
          Width = 134
          Height = 13
          Caption = 'Enter the details as required.'
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
    end
  end
  object dbAutoInc: TIBDatabase
    DefaultTransaction = tranAutoInc
    IdleTimer = 0
    SQLDialect = 1
    TraceFlags = []
    Left = 44
    Top = 320
  end
  object tranAutoInc: TIBTransaction
    Active = False
    DefaultDatabase = dbAutoInc
    AutoStopAction = saNone
    Left = 76
    Top = 320
  end
  object qryAutoInc: TIBSQL
    Database = dbAutoInc
    ParamCheck = True
    Transaction = tranAutoInc
    Left = 108
    Top = 320
  end
  object qryUtil: TIBDataSet
    Database = dbAutoInc
    Transaction = tranAutoInc
    BufferChunks = 1000
    CachedUpdates = False
    Left = 140
    Top = 320
  end
end
