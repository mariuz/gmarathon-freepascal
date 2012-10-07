object frmWatches: TfrmWatches
  Left = 384
  Top = 305
  Width = 505
  Height = 137
  BorderStyle = bsSizeToolWin
  Caption = 'Watches'
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  FormStyle = fsStayOnTop
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object lvWatches: TListView
    Left = 0
    Top = 0
    Width = 497
    Height = 110
    Align = alClient
    Columns = <
      item
        Caption = 'Expression'
        Width = 100
      end
      item
        Caption = 'Value'
        Width = 350
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
    object actEditWatch: TAction
      Caption = 'Edit Watch...'
      OnExecute = actEditWatchExecute
      OnUpdate = actEditWatchUpdate
    end
    object actAddWatch: TAction
      Caption = 'Add Watch...'
      OnExecute = actAddWatchExecute
      OnUpdate = actAddWatchUpdate
    end
    object actEnableWatch: TAction
      Caption = 'Enable Watch'
      OnExecute = actEnableWatchExecute
      OnUpdate = actEnableWatchUpdate
    end
    object actDisableWatch: TAction
      Caption = 'Disable Watch'
      OnExecute = actDisableWatchExecute
      OnUpdate = actDisableWatchUpdate
    end
    object actDeleteWatch: TAction
      Caption = 'Delete Watch'
      OnExecute = actDeleteWatchExecute
      OnUpdate = actDeleteWatchUpdate
    end
    object actEnableAllWatches: TAction
      Caption = 'Enable All Watches'
      OnExecute = actEnableAllWatchesExecute
      OnUpdate = actEnableAllWatchesUpdate
    end
    object actDisableAllWatches: TAction
      Caption = 'Disable All Watches'
      OnExecute = actDisableAllWatchesExecute
      OnUpdate = actDisableAllWatchesUpdate
    end
    object actDeleteAllWatches: TAction
      Caption = 'Delete All Watches'
      OnExecute = actDeleteAllWatchesExecute
      OnUpdate = actDeleteAllWatchesUpdate
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 200
    Top = 68
    object ViewSource1: TMenuItem
      Action = actAddWatch
    end
    object actEditWatch1: TMenuItem
      Action = actEditWatch
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object actEnableWatch1: TMenuItem
      Action = actEnableWatch
    end
    object actDisableWatch1: TMenuItem
      Action = actDisableWatch
    end
    object actDeleteWatch1: TMenuItem
      Action = actDeleteWatch
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object actEnableAllWatches1: TMenuItem
      Action = actEnableAllWatches
    end
    object actDisableAllWatches1: TMenuItem
      Action = actDisableAllWatches
    end
    object actDeleteAllWatches1: TMenuItem
      Action = actDeleteAllWatches
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object StayOnTop1: TMenuItem
      Action = actStayOnTop
    end
  end
end
