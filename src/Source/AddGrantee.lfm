object frmGranteeAdd: TfrmGranteeAdd
  Left = 340
  Top = 209
  Width = 420
  Height = 266
  Caption = 'Add Grantee'
  Color = clBtnFace
  Constraints.MinHeight = 260
  Constraints.MinWidth = 420
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    412
    232)
  PixelsPerInch = 96
  TextHeight = 13
  object btnCancel: TButton
    Left = 239
    Top = 201
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 0
  end
  object btnOK: TButton
    Left = 159
    Top = 201
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object pgGrantee: TPageControl
    Left = 4
    Top = 4
    Width = 401
    Height = 190
    ActivePage = tsUser
    Anchors = [akLeft, akTop, akRight, akBottom]
    HotTrack = True
    TabOrder = 2
    object tsUser: TTabSheet
      Caption = 'User'
      DesignSize = (
        393
        162)
      object Label2: TLabel
        Left = 4
        Top = 12
        Width = 83
        Height = 13
        Caption = '&User/Role Name:'
        FocusControl = edUser
      end
      object edUser: TEdit
        Left = 88
        Top = 8
        Width = 301
        Height = 21
        Anchors = [akLeft, akTop, akRight]
        TabOrder = 0
      end
    end
    object tsObject: TTabSheet
      Caption = 'Object'
      DesignSize = (
        393
        162)
      object Label1: TLabel
        Left = 4
        Top = 12
        Width = 61
        Height = 13
        Caption = '&Object Type:'
        FocusControl = cmbObject
      end
      object cmbObject: TComboBox
        Left = 72
        Top = 8
        Width = 317
        Height = 21
        Style = csDropDownList
        Anchors = [akLeft, akTop, akRight]
        ItemHeight = 13
        TabOrder = 0
        OnChange = cmbObjectChange
        Items.Strings = (
          'Stored Procedure'
          'Trigger'
          'View')
      end
      object lvObject: TListView
        Left = 4
        Top = 36
        Width = 385
        Height = 119
        Anchors = [akLeft, akTop, akRight, akBottom]
        Columns = <
          item
            Caption = 'Object'
            Width = 360
          end>
        HideSelection = False
        MultiSelect = True
        ReadOnly = True
        TabOrder = 1
        ViewStyle = vsReport
      end
    end
  end
  object btnHelp: TButton
    Left = 319
    Top = 201
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object rmCornerGrip1: TrmCornerGrip
    Top = 204
  end
end
