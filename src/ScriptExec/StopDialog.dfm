object frmStopExecution: TfrmStopExecution
  Left = 254
  Top = 304
  BorderStyle = bsDialog
  Caption = 'Stop Execution'
  ClientHeight = 95
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 260
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnContinue: TButton
    Left = 260
    Top = 36
    Width = 75
    Height = 25
    Caption = 'Continue'
    ModalResult = 2
    TabOrder = 1
  end
  object rbRollback: TRadioButton
    Left = 8
    Top = 32
    Width = 237
    Height = 17
    Caption = 'Halt Execution - Rollback Uncommitted Work'
    TabOrder = 2
  end
  object rbCommit: TRadioButton
    Left = 8
    Top = 8
    Width = 241
    Height = 17
    Caption = 'Halt Execution - Commit Uncommitted Work'
    Checked = True
    TabOrder = 3
    TabStop = True
  end
end
