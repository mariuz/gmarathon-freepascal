object frmDebugCallStack: TfrmDebugCallStack
  Left = 361
  Top = 273
  Width = 395
  Height = 186
  BorderIcons = [biSystemMenu, biMaximize]
  BorderStyle = bsSizeToolWin
  Caption = 'Call Stack'
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
  object lvCallStack: TListView
    Left = 0
    Top = 0
    Width = 387
    Height = 159
    Align = alClient
    Columns = <
      item
        Caption = 'Call Stack'
        Width = 350
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    PopupMenu = PopupMenu1
    TabOrder = 0
    ViewStyle = vsReport
    OnDblClick = lvCallStackDblClick
    OnDeletion = lvCallStackDeletion
  end
  object actCallStack: TActionList
    Left = 168
    Top = 68
    object actViewSource: TAction
      Caption = 'View Source'
      OnExecute = actViewSourceExecute
      OnUpdate = actViewSourceUpdate
    end
    object actStayOnTop: TAction
      Caption = 'Stay On Top'
      OnExecute = actStayOnTopExecute
      OnUpdate = actStayOnTopUpdate
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 200
    Top = 68
    object ViewSource1: TMenuItem
      Action = actViewSource
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object StayOnTop1: TMenuItem
      Action = actStayOnTop
    end
  end
end
