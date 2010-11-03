object frmEditorIndex: TfrmEditorIndex
  Left = 432
  Top = 255
  ActiveControl = edIdxName
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Index'
  ClientHeight = 333
  ClientWidth = 362
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
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 120
    Top = 305
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 200
    Top = 305
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 280
    Top = 305
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object PageControl1: TPageControl
    Left = 4
    Top = 4
    Width = 355
    Height = 297
    ActivePage = tsIndex
    TabOrder = 0
    object tsIndex: TTabSheet
      Caption = 'Index Details'
      object Label6: TLabel
        Left = 12
        Top = 7
        Width = 28
        Height = 13
        Caption = '&Name'
        FocusControl = edIdxName
      end
      object Bevel1: TBevel
        Left = 8
        Top = 204
        Width = 333
        Height = 33
      end
      object Label2: TLabel
        Left = 121
        Top = 215
        Width = 26
        Height = 13
        Caption = '&Order'
        FocusControl = cmbOrder
      end
      object Label1: TLabel
        Left = 5
        Top = 43
        Width = 35
        Height = 13
        Caption = '&Column'
        FocusControl = cmbIdxColumn
      end
      object edIdxName: TEdit
        Left = 44
        Top = 4
        Width = 297
        Height = 21
        TabOrder = 0
        OnChange = edIdxNameChange
      end
      object lvIdxColumns: TListView
        Left = 8
        Top = 68
        Width = 273
        Height = 129
        Columns = <
          item
            Caption = 'Column(s) for index'
            Width = 250
          end>
        HideSelection = False
        MultiSelect = True
        ReadOnly = True
        TabOrder = 4
        ViewStyle = vsReport
        OnDblClick = btnDeleteClick
        OnKeyDown = lvIdxColumnsKeyDown
      end
      object chkUnique: TCheckBox
        Left = 16
        Top = 214
        Width = 65
        Height = 17
        Caption = '&Unique'
        TabOrder = 5
      end
      object cmbOrder: TComboBox
        Left = 152
        Top = 212
        Width = 185
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 6
        Items.Strings = (
          'ASCENDING'
          'DESCENDING')
      end
      object chkActive: TCheckBox
        Left = 8
        Top = 244
        Width = 97
        Height = 17
        Caption = 'Inde&x Active'
        Checked = True
        State = cbChecked
        TabOrder = 7
      end
      object cmbIdxColumn: TComboBox
        Left = 44
        Top = 40
        Width = 297
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
      end
      object btnAdd: TButton
        Left = 286
        Top = 68
        Width = 55
        Height = 21
        Caption = '&Add'
        TabOrder = 2
        OnClick = btnAddClick
      end
      object btnDelete: TButton
        Left = 286
        Top = 92
        Width = 55
        Height = 21
        Caption = '&Delete'
        TabOrder = 3
        OnClick = btnDeleteClick
      end
    end
  end
  object qryIndex: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 4
    Top = 304
  end
end
