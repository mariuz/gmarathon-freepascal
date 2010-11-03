object frmReorderColumns: TfrmReorderColumns
  Left = 407
  Top = 187
  ActiveControl = lvColumns
  AutoScroll = False
  Caption = 'Re-order Columns'
  ClientHeight = 301
  ClientWidth = 354
  Color = clBtnFace
  Constraints.MinHeight = 328
  Constraints.MinWidth = 362
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  DesignSize = (
    354
    301)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 8
    Width = 125
    Height = 13
    Caption = '&Drag to Re-order Columns:'
    FocusControl = lvColumns
  end
  object lvColumns: TListView
    Left = 3
    Top = 26
    Width = 345
    Height = 243
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <
      item
        Caption = 'Column Name'
        Width = 325
      end>
    DragMode = dmAutomatic
    HideSelection = False
    ReadOnly = True
    RowSelect = True
    SmallImages = frmMarathonMain.ilMarathonImages
    TabOrder = 0
    ViewStyle = vsReport
    OnDragDrop = lvColumnsDragDrop
    OnDragOver = lvColumnsDragOver
  end
  object btnOK: TButton
    Left = 103
    Top = 273
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 1
  end
  object btnCancel: TButton
    Left = 183
    Top = 273
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 263
    Top = 273
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object rmCornerGrip1: TrmCornerGrip
    Left = 36
    Top = 276
  end
end
