object frmManageBrowserItems: TfrmManageBrowserItems
  Left = 314
  Top = 220
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Manage Items'
  ClientHeight = 241
  ClientWidth = 478
  Color = clBtnFace
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
  object lvRecent: TListView
    Left = 4
    Top = 5
    Width = 469
    Height = 200
    Columns = <
      item
        Caption = 'Recently Opened Items'
        Width = 400
      end>
    HideSelection = False
    ReadOnly = True
    TabOrder = 0
    ViewStyle = vsReport
  end
  object btnClose: TButton
    Left = 320
    Top = 212
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnRemove: TButton
    Left = 4
    Top = 212
    Width = 75
    Height = 25
    Action = actRemove
    TabOrder = 2
  end
  object btnMoveUp: TButton
    Left = 84
    Top = 212
    Width = 75
    Height = 25
    Action = actMoveUp
    TabOrder = 3
  end
  object btnMoveDown: TButton
    Left = 164
    Top = 212
    Width = 75
    Height = 25
    Action = actMoveDOwn
    TabOrder = 4
  end
  object btnCancel: TButton
    Left = 400
    Top = 212
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 5
  end
  object actList: TActionList
    Left = 260
    Top = 212
    object actRemove: TAction
      Caption = '&Remove'
      OnExecute = actRemoveExecute
      OnUpdate = actRemoveUpdate
    end
    object actMoveUp: TAction
      Caption = 'Move &Up'
      OnExecute = actMoveUpExecute
      OnUpdate = actMoveUpUpdate
    end
    object actMoveDOwn: TAction
      Caption = 'Move &Down'
      OnExecute = actMoveDOwnExecute
      OnUpdate = actMoveDOwnUpdate
    end
  end
end
