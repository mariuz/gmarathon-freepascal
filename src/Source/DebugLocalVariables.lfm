object frmDebugLocals: TfrmDebugLocals
  Left = 389
  Top = 299
  Width = 392
  Height = 160
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Local Variables'
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
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lvVars: TListView
    Left = 0
    Top = 0
    Width = 384
    Height = 133
    Align = alClient
    Columns = <
      item
        Caption = 'Variable'
        Width = 200
      end
      item
        Caption = 'Value'
        Width = 150
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
  end
  object actCallStack: TActionList
    Left = 168
    Top = 68
    object actStayOnTop: TAction
      Caption = 'Stay On Top'
      OnExecute = actStayOnTopExecute
      OnUpdate = actStayOnTopUpdate
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 200
    Top = 68
    object StayOnTop1: TMenuItem
      Action = actStayOnTop
    end
  end
end
