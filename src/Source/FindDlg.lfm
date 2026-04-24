object EdFindDlg: TEdFindDlg
  Left = 216
  Top = 123
  ActiveControl = FindHistoryBox
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Find text...'
  ClientHeight = 135
  ClientWidth = 317
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
  OnClose = FormClose
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 105
    Width = 317
    Height = 30
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 0
    object OKButton: TButton
      Left = 161
      Top = 2
      Width = 75
      Height = 25
      Caption = 'OK'
      Default = True
      TabOrder = 0
      OnClick = OKButtonClick
    end
    object CancelButton: TButton
      Left = 238
      Top = 2
      Width = 75
      Height = 25
      Cancel = True
      Caption = 'Close'
      ModalResult = 2
      TabOrder = 1
      OnClick = CancelButtonClick
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 317
    Height = 105
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 1
    object Label1: TLabel
      Left = 6
      Top = 6
      Width = 53
      Height = 13
      Caption = '&Text to find'
    end
    object FindHistoryBox: TComboBox
      Left = 69
      Top = 4
      Width = 243
      Height = 21
      ItemHeight = 13
      TabOrder = 0
      OnChange = FindHistoryBoxChange
    end
    object GroupBox1: TGroupBox
      Left = 6
      Top = 28
      Width = 306
      Height = 74
      Caption = 'Options'
      TabOrder = 1
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
      object GroupBox2: TGroupBox
        Left = 178
        Top = 15
        Width = 116
        Height = 45
        Caption = 'Direction'
        TabOrder = 2
        object FwdDirection: TRadioButton
          Left = 8
          Top = 20
          Width = 53
          Height = 17
          Caption = '&Down'
          Checked = True
          TabOrder = 0
          TabStop = True
        end
        object BackDirection: TRadioButton
          Left = 72
          Top = 21
          Width = 37
          Height = 17
          Caption = '&Up'
          TabOrder = 1
        end
      end
    end
  end
end
