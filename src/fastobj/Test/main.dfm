object MainForm: TMainForm
  Left = 83
  Top = 181
  Caption = 'MainForm'
  ClientHeight = 62
  ClientWidth = 422
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 120
  TextHeight = 17
  object LbLoop: TLabel
    Left = 145
    Top = 17
    Width = 46
    Height = 17
    Caption = 'LbLoop'
  end
  object BtnLoop: TButton
    Left = 17
    Top = 9
    Width = 97
    Height = 26
    Caption = 'Loop'
    TabOrder = 0
    OnClick = BtnLoopClick
  end
end
