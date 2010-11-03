object frmNewTrigger: TfrmNewTrigger
  Left = 356
  Top = 235
  ActiveControl = edTriggerName
  BorderStyle = bsDialog
  Caption = 'New Trigger'
  ClientHeight = 176
  ClientWidth = 392
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 12
    Width = 31
    Height = 13
    Caption = '&Name:'
    FocusControl = edTriggerName
  end
  object Label2: TLabel
    Left = 36
    Top = 40
    Width = 18
    Height = 13
    Caption = '&For:'
    FocusControl = cmbTables
  end
  object Label4: TLabel
    Left = 12
    Top = 132
    Width = 40
    Height = 13
    Caption = '&Position:'
    FocusControl = edPosition
  end
  object Bevel1: TBevel
    Left = 12
    Top = 60
    Width = 281
    Height = 6
    Shape = bsBottomLine
  end
  object btnOK: TButton
    Left = 312
    Top = 8
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 6
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 312
    Top = 36
    Width = 75
    Height = 25
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 7
  end
  object btnHelp: TButton
    Left = 312
    Top = 80
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 8
    OnClick = btnHelpClick
  end
  object edTriggerName: TEdit
    Left = 56
    Top = 8
    Width = 237
    Height = 21
    TabOrder = 0
    OnChange = edTriggerNameChange
  end
  object cmbTables: TComboBox
    Left = 56
    Top = 36
    Width = 237
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
  object cmbTrigPos: TComboBox
    Left = 56
    Top = 100
    Width = 237
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    Items.Strings = (
      'before insert'
      'after insert'
      'before update'
      'after update'
      'before delete'
      'after delete')
  end
  object edPosition: TEdit
    Left = 56
    Top = 128
    Width = 77
    Height = 21
    TabOrder = 4
    Text = '0'
  end
  object UpDown1: TUpDown
    Left = 133
    Top = 128
    Width = 15
    Height = 21
    Associate = edPosition
    TabOrder = 5
  end
  object cmbActive: TComboBox
    Left = 56
    Top = 72
    Width = 105
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    Items.Strings = (
      'active'
      'inactive')
  end
end
