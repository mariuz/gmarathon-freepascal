object frmEditorGrant: TfrmEditorGrant
  Left = 352
  Top = 215
  Width = 640
  Height = 455
  Caption = 'Grants & Revokes'
  Color = clBtnFace
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
  OnKeyDown = FormKeyDown
  PixelsPerInch = 96
  TextHeight = 13
  object Label6: TLabel
    Left = 265
    Top = 5
    Width = 63
    Height = 13
    Caption = 'Privileges for:'
  end
  object lblObject: TLabel
    Left = 10
    Top = 5
    Width = 39
    Height = 13
    Caption = 'Objects:'
  end
  object lblObjectName: TLabel
    Left = 115
    Top = 5
    Width = 34
    Height = 13
    Caption = 'Object:'
  end
  object Label1: TLabel
    Left = 370
    Top = 5
    Width = 69
    Height = 13
    Caption = 'Privilegename:'
  end
  object cmbPrivileges: TComboBox
    Left = 265
    Top = 20
    Width = 100
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 2
    OnChange = cmbPrivilegesChange
    Items.Strings = (
      'Users'
      'Roles'
      'Views'
      'Triggers'
      'Procedures')
  end
  object cmbObjects: TComboBox
    Left = 10
    Top = 20
    Width = 100
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 0
    OnChange = cmbObjectsChange
    Items.Strings = (
      'Tables'
      'Views'
      'Procedures')
  end
  object stsEditorGrant: TStatusBar
    Left = 0
    Top = 406
    Width = 632
    Height = 22
    Panels = <
      item
        Width = 65
      end
      item
        Width = 90
      end
      item
        Width = 200
      end
      item
        Width = 50
      end>
    SimplePanel = False
  end
  object pgEditorGrant: TPageControl
    Left = 0
    Top = 56
    Width = 632
    Height = 350
    ActivePage = tsObjects
    Align = alBottom
    TabIndex = 0
    TabOrder = 4
    object tsObjects: TTabSheet
      Caption = 'Object'
      object lvObjects: TListView
        Left = 0
        Top = 0
        Width = 624
        Height = 322
        Align = alClient
        Columns = <>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        PopupMenu = pmnuGrantRevoke
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvObjectsDblClick
        OnMouseDown = lvObjectsMouseDown
      end
    end
    object tsColumns: TTabSheet
      Caption = 'Columns'
      ImageIndex = 1
      object lvColumns: TListView
        Left = 0
        Top = 0
        Width = 624
        Height = 322
        Align = alClient
        Columns = <
          item
            Caption = 'Name'
            Width = 150
          end
          item
            Caption = 'update'
            Width = 65
          end
          item
            Caption = 'reference'
            Width = 65
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvColumnsDblClick
        OnMouseDown = lvObjectsMouseDown
      end
    end
  end
  object cmbObjectsNames: TComboBox
    Left = 115
    Top = 20
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
    OnChange = cmbObjectsNamesChange
  end
  object cmbPrivilegeName: TComboBox
    Left = 370
    Top = 20
    Width = 145
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 3
    OnChange = cmbPrivilegeNameChange
  end
  object dsqlGrants: TIB_DSQL
    Left = 540
    Top = 8
  end
  object pmnuGrantRevoke: TPopupMenu
    OnPopup = pmnuGrantRevokePopup
    Left = 568
    Top = 8
    object mnuiGrant: TMenuItem
      Caption = '&Grant'
      OnClick = mnuiGrantClick
    end
    object mnuiRevoke: TMenuItem
      Caption = '&Revoke'
      OnClick = mnuiGrantClick
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mnuiGrantAll: TMenuItem
      Caption = 'Grant &all'
      OnClick = mnuiGrantAllClick
    end
    object mnuiGrantAllGrantOption: TMenuItem
      Caption = 'Grant all with grant &option'
      OnClick = mnuiGrantAllGrantOptionClick
    end
    object mnuiRevokeAll: TMenuItem
      Caption = 'Revo&ke all'
      OnClick = mnuiGrantAllClick
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mnuiGrantToAll: TMenuItem
      Caption = 'Grant to all'
      OnClick = mnuiGrantToAllClick
    end
    object mnuiGrantToAllGrantOption: TMenuItem
      Caption = 'Grant to all with grant option'
      OnClick = mnuiGrantToAllClick
    end
    object mnuiRevokeFromAll: TMenuItem
      Caption = 'Revoke from all'
      OnClick = mnuiGrantToAllClick
    end
  end
  object qryGrants: TIBOQuery
    Params = <>
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 596
    Top = 8
  end
  object qryGrants2: TIBOQuery
    Params = <>
    AutoFetchAll = True
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 596
    Top = 36
  end
end
