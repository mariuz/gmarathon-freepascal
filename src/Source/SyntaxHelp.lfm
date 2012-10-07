object frmSyntaxHelp: TfrmSyntaxHelp
  Left = 685
  Top = 182
  Width = 238
  Height = 370
  BorderStyle = bsSizeToolWin
  Caption = 'Syntax Help'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 161
    Width = 230
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 230
    Height = 161
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    object tvSyntaxHelp: TTreeView
      Left = 0
      Top = 0
      Width = 230
      Height = 161
      Align = alClient
      DragMode = dmAutomatic
      HideSelection = False
      Images = frmMarathonMain.ilMarathonImages
      Indent = 19
      TabOrder = 0
      OnChange = tvSyntaxHelpChange
      OnGetImageIndex = tvSyntaxHelpGetImageIndex
      OnGetSelectedIndex = tvSyntaxHelpGetImageIndex
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 164
    Width = 230
    Height = 179
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 1
    object memSyntaxHelp: TMemo
      Left = 0
      Top = 0
      Width = 230
      Height = 179
      Align = alClient
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentFont = False
      ReadOnly = True
      ScrollBars = ssBoth
      TabOrder = 0
      WordWrap = False
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 196
    Top = 128
    object StayOnTop1: TMenuItem
      Caption = 'Stay On Top'
      Checked = True
      OnClick = StayOnTop1Click
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object Close1: TMenuItem
      Caption = 'Close'
      OnClick = Close1Click
    end
  end
end
