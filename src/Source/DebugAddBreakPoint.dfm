object frmDebugAddBreakPoint: TfrmDebugAddBreakPoint
  Left = 384
  Top = 147
  BorderStyle = bsDialog
  Caption = 'Add Breakpoint'
  ClientHeight = 287
  ClientWidth = 358
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
  object Label2: TLabel
    Left = 8
    Top = 12
    Width = 57
    Height = 13
    Caption = '&Connection:'
    FocusControl = cmbConnection
  end
  object Label3: TLabel
    Left = 8
    Top = 40
    Width = 83
    Height = 13
    Caption = '&Procedure Name:'
    FocusControl = edProcName
  end
  object Label4: TLabel
    Left = 8
    Top = 68
    Width = 23
    Height = 13
    Caption = '&Line:'
    FocusControl = edLine
  end
  object Label5: TLabel
    Left = 8
    Top = 96
    Width = 47
    Height = 13
    Caption = '&Condition:'
    FocusControl = edCondition
  end
  object Label6: TLabel
    Left = 8
    Top = 124
    Width = 57
    Height = 13
    Caption = 'P&ass Count:'
    FocusControl = edPassCount
  end
  object btnCancel: TButton
    Left = 276
    Top = 256
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 6
  end
  object btnOK: TButton
    Left = 192
    Top = 256
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 7
  end
  object edProcName: TEdit
    Left = 96
    Top = 36
    Width = 253
    Height = 21
    TabOrder = 1
  end
  object cmbConnection: TComboBox
    Left = 96
    Top = 8
    Width = 253
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
  end
  object edLine: TEdit
    Left = 96
    Top = 64
    Width = 253
    Height = 21
    TabOrder = 2
  end
  object edCondition: TEdit
    Left = 96
    Top = 92
    Width = 253
    Height = 21
    TabOrder = 3
  end
  object edPassCount: TEdit
    Left = 96
    Top = 120
    Width = 253
    Height = 21
    TabOrder = 4
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 148
    Width = 345
    Height = 101
    Caption = 'Actions'
    TabOrder = 5
    object Label1: TLabel
      Left = 32
      Top = 72
      Width = 46
      Height = 13
      Caption = '&Message:'
      FocusControl = edLogMessage
    end
    object chkBreak: TCheckBox
      Left = 12
      Top = 20
      Width = 117
      Height = 17
      Caption = '&Break Execution'
      Checked = True
      State = cbChecked
      TabOrder = 0
    end
    object chkLog: TCheckBox
      Left = 12
      Top = 44
      Width = 97
      Height = 17
      Caption = '&Log Message'
      TabOrder = 1
    end
    object edLogMessage: TEdit
      Left = 88
      Top = 68
      Width = 249
      Height = 21
      TabOrder = 2
    end
  end
end
