object frmGetSetVariable: TfrmGetSetVariable
  Left = 323
  Top = 259
  ActiveControl = cmbVariableName
  BorderStyle = bsDialog
  Caption = 'Evaluate/Modify'
  ClientHeight = 293
  ClientWidth = 359
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TButton
    Left = 278
    Top = 267
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Close'
    ModalResult = 2
    TabOrder = 0
    OnClick = btnCloseClick
  end
  object GroupBox1: TGroupBox
    Left = 4
    Top = 4
    Width = 351
    Height = 259
    TabOrder = 1
    object Label1: TLabel
      Left = 8
      Top = 12
      Width = 41
      Height = 13
      Caption = '&Variable:'
      FocusControl = cmbVariableName
    end
    object Label2: TLabel
      Left = 8
      Top = 52
      Width = 30
      Height = 13
      Caption = '&Result'
      FocusControl = memResult
    end
    object Label3: TLabel
      Left = 8
      Top = 141
      Width = 52
      Height = 13
      Caption = '&New Value'
      FocusControl = memNewValue
    end
    object cmbVariableName: TComboBox
      Left = 8
      Top = 28
      Width = 334
      Height = 21
      ItemHeight = 13
      TabOrder = 0
    end
    object memResult: TMemo
      Left = 8
      Top = 68
      Width = 334
      Height = 68
      TabStop = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 1
      WordWrap = False
    end
    object memNewValue: TMemo
      Left = 8
      Top = 157
      Width = 334
      Height = 68
      ScrollBars = ssBoth
      TabOrder = 2
      WordWrap = False
    end
    object btnGetValue: TButton
      Left = 8
      Top = 230
      Width = 75
      Height = 25
      Caption = '&Get Value'
      Default = True
      TabOrder = 3
      OnClick = btnGetValueClick
    end
    object btnModify: TButton
      Left = 88
      Top = 230
      Width = 75
      Height = 25
      Caption = '&Modify'
      TabOrder = 4
      OnClick = btnModifyClick
    end
  end
end
