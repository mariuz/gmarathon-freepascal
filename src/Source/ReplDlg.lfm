object EdReplDlg: TEdReplDlg
  Left = 352
  Top = 203
  ActiveControl = FindHistoryBox
  BorderStyle = bsDialog
  Caption = 'Find and replace text...'
  ClientHeight = 181
  ClientWidth = 319
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
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 150
    Width = 319
    Height = 31
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object OKButton: TButton
      Left = 82
      Top = 2
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = OKButtonClick
    end
    object CancelButton: TButton
      Left = 237
      Top = 2
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 1
      OnClick = CancelButtonClick
    end
    object ReplaceAllButton: TButton
      Left = 160
      Top = 2
      Width = 75
      Height = 25
      Caption = 'Replace &All'
      TabOrder = 2
      OnClick = ReplaceAllButtonClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 319
    Height = 150
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 6
      Top = 7
      Width = 53
      Height = 13
      Caption = '&Text to find'
    end
    object Label2: TLabel
      Left = 6
      Top = 33
      Width = 62
      Height = 13
      Caption = 'Replace with'
    end
    object FindHistoryBox: TComboBox
      Left = 72
      Top = 4
      Width = 243
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnChange = FindHistoryBoxChange
    end
    object GroupBox1: TGroupBox
      Left = 7
      Top = 56
      Width = 306
      Height = 92
      Caption = 'Options'
      TabOrder = 2
      object UseCaseBox: TCheckBox
        Left = 10
        Top = 16
        Width = 140
        Height = 17
        Caption = '&Case sensitive'
        TabOrder = 0
      end
      object WholeWordBox: TCheckBox
        Left = 10
        Top = 33
        Width = 140
        Height = 17
        Caption = '&Whole words'
        TabOrder = 1
      end
      object PromptOnReplBox: TCheckBox
        Left = 10
        Top = 51
        Width = 140
        Height = 17
        Caption = '&Prompt on Replace'
        TabOrder = 2
      end
      object GroupBox2: TGroupBox
        Left = 178
        Top = 15
        Width = 116
        Height = 45
        Caption = 'Direction'
        TabOrder = 3
        object FwdDirection: TRadioButton
          Left = 8
          Top = 20
          Width = 49
          Height = 17
          Caption = '&Down'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object BackDirection: TRadioButton
          Left = 60
          Top = 20
          Width = 49
          Height = 17
          Caption = '&Up'
          TabOrder = 1
        end
      end
    end
    object ReplHistoryBox: TComboBox
      Left = 72
      Top = 30
      Width = 243
      Height = 21
      ItemHeight = 13
      TabOrder = 1
    end
  end
end
