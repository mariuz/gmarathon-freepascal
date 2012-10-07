object frmEditorConstraint: TfrmEditorConstraint
  Left = 392
  Top = 246
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Constraint'
  ClientHeight = 403
  ClientWidth = 389
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 148
    Top = 375
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 228
    Top = 375
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 2
  end
  object btnHelp: TButton
    Left = 308
    Top = 375
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 3
    OnClick = btnHelpClick
  end
  object pgConstraint: TPageControl
    Left = 4
    Top = 4
    Width = 381
    Height = 365
    ActivePage = tsPK
    HotTrack = True
    TabOrder = 0
    object tsPK: TTabSheet
      Caption = 'Primary key'
      object Label1: TLabel
        Left = 4
        Top = 44
        Width = 38
        Height = 13
        Caption = '&Column:'
        FocusControl = cmbPKColumn
      end
      object Label7: TLabel
        Left = 4
        Top = 12
        Width = 31
        Height = 13
        Caption = '&Name:'
        FocusControl = edPKName
      end
      object edPKName: TEdit
        Left = 45
        Top = 8
        Width = 325
        Height = 21
        TabOrder = 0
        OnChange = edPKNameChange
      end
      object lvPKColumns: TListView
        Left = 45
        Top = 68
        Width = 261
        Height = 261
        Columns = <
          item
            Caption = 'Column(s) for primary key'
            Width = 240
          end>
        ReadOnly = True
        TabOrder = 4
        ViewStyle = vsReport
        OnKeyDown = lvPKColumnsKeyDown
      end
      object cmbPKColumn: TComboBox
        Left = 45
        Top = 40
        Width = 325
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 1
      end
      object btnPKAdd: TButton
        Left = 312
        Top = 68
        Width = 55
        Height = 21
        Action = actPKAdd
        TabOrder = 2
      end
      object btnPKDelete: TButton
        Left = 312
        Top = 92
        Width = 55
        Height = 21
        Action = actPKDelete
        TabOrder = 3
      end
    end
    object tsFK: TTabSheet
      Caption = 'Foreign key'
      object Label4: TLabel
        Left = 4
        Top = 156
        Width = 30
        Height = 13
        Caption = '&Table:'
        FocusControl = cmbTables
      end
      object Label9: TLabel
        Left = 4
        Top = 12
        Width = 31
        Height = 13
        Caption = '&Name:'
        FocusControl = edFKName
      end
      object Label10: TLabel
        Left = 4
        Top = 180
        Width = 38
        Height = 13
        Caption = 'C&olumn:'
        FocusControl = cmbFKRefColumns
      end
      object Label11: TLabel
        Left = 4
        Top = 44
        Width = 38
        Height = 13
        Caption = '&Column:'
        FocusControl = cmbFKColumns
      end
      object lvFKColumns: TListView
        Left = 45
        Top = 68
        Width = 261
        Height = 73
        Columns = <
          item
            Caption = 'Column(s) for foreign key'
            Width = 240
          end>
        HideSelection = False
        ReadOnly = True
        TabOrder = 0
        ViewStyle = vsReport
        OnKeyDown = lvFKColumnsKeyDown
      end
      object lvFKRefColumns: TListView
        Left = 45
        Top = 204
        Width = 257
        Height = 69
        Columns = <
          item
            Caption = 'Ref Column(s) for foreign key'
            Width = 240
          end>
        HideSelection = False
        ReadOnly = True
        TabOrder = 1
        ViewStyle = vsReport
        OnKeyDown = lvFKRefColumnsKeyDown
      end
      object cmbTables: TComboBox
        Left = 45
        Top = 152
        Width = 321
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
        OnChange = cmbTablesChange
      end
      object edFKName: TEdit
        Left = 45
        Top = 8
        Width = 325
        Height = 21
        TabOrder = 3
      end
      object cmbFKRefColumns: TComboBox
        Left = 45
        Top = 176
        Width = 321
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 4
      end
      object btnFKRefAdd: TButton
        Left = 312
        Top = 204
        Width = 55
        Height = 21
        Action = actFKAdd1
        TabOrder = 5
      end
      object btnFKRefDelete: TButton
        Left = 312
        Top = 228
        Width = 55
        Height = 21
        Action = actFKDelete1
        TabOrder = 6
      end
      object cmbFKColumns: TComboBox
        Left = 45
        Top = 40
        Width = 325
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 7
      end
      object btnFKAdd: TButton
        Left = 312
        Top = 68
        Width = 55
        Height = 21
        Action = actFKAdd
        TabOrder = 8
      end
      object btnFKDelete: TButton
        Left = 312
        Top = 92
        Width = 55
        Height = 21
        Action = actFKDelete
        TabOrder = 9
      end
      object chkOnDelete: TCheckBox
        Left = 45
        Top = 284
        Width = 97
        Height = 17
        Caption = 'On &delete'
        TabOrder = 10
      end
      object chkOnUpdate: TCheckBox
        Left = 45
        Top = 310
        Width = 97
        Height = 17
        Caption = 'On &update'
        TabOrder = 11
      end
      object cmbOnDelete: TComboBox
        Left = 160
        Top = 282
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 12
        Items.Strings = (
          'NO ACTION'
          'CASCADE'
          'SET DEFAULT'
          'SET NULL')
      end
      object cmbOnUpdate: TComboBox
        Left = 160
        Top = 308
        Width = 145
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        TabOrder = 13
        Items.Strings = (
          'NO ACTION'
          'CASCADE'
          'SET DEFAULT'
          'SET NULL')
      end
    end
    object tsCheck: TTabSheet
      Caption = 'Check'
      object Label5: TLabel
        Left = 4
        Top = 40
        Width = 103
        Height = 13
        Caption = '&Check constraint text:'
        FocusControl = edCheck
      end
      object Label6: TLabel
        Left = 4
        Top = 12
        Width = 31
        Height = 13
        Caption = '&Name:'
        FocusControl = edCheckName
      end
      object edCheck: TMemo
        Left = 45
        Top = 56
        Width = 325
        Height = 277
        ScrollBars = ssBoth
        TabOrder = 1
        WordWrap = False
      end
      object edCheckName: TEdit
        Left = 45
        Top = 8
        Width = 321
        Height = 21
        TabOrder = 0
      end
    end
    object tsUnique: TTabSheet
      Caption = 'Unique'
      ImageIndex = 3
      object Label2: TLabel
        Left = 4
        Top = 44
        Width = 38
        Height = 13
        Caption = '&Column:'
        FocusControl = cmbUniqueColumn
      end
      object Label3: TLabel
        Left = 4
        Top = 12
        Width = 31
        Height = 13
        Caption = '&Name:'
        FocusControl = edUniqueName
      end
      object edUniqueName: TEdit
        Left = 45
        Top = 8
        Width = 325
        Height = 21
        TabOrder = 0
        OnChange = edPKNameChange
      end
      object lvUniqueColumns: TListView
        Left = 45
        Top = 68
        Width = 261
        Height = 261
        Columns = <
          item
            Caption = 'Column(s) for unique constraint'
            Width = 240
          end>
        ReadOnly = True
        TabOrder = 1
        ViewStyle = vsReport
        OnKeyDown = lvUniqueColumnsKeyDown
      end
      object cmbUniqueColumn: TComboBox
        Left = 45
        Top = 40
        Width = 325
        Height = 21
        Style = csDropDownList
        ItemHeight = 0
        TabOrder = 2
      end
      object btnUniqueAdd: TButton
        Left = 312
        Top = 68
        Width = 55
        Height = 21
        Action = actUCAdd
        TabOrder = 3
      end
      object btnUniqueDelete: TButton
        Left = 312
        Top = 92
        Width = 55
        Height = 21
        Action = actUCDelete
        TabOrder = 4
      end
    end
  end
  object qryConstraint: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 4
    Top = 372
  end
  object ActionList1: TActionList
    Left = 141
    Top = 131
    object actFKAdd: TAction
      Caption = '&Add'
      OnExecute = actFKAddExecute
      OnUpdate = actFKAddUpdate
    end
    object actFKDelete: TAction
      Caption = '&Delete'
      OnExecute = actFKDeleteExecute
      OnUpdate = actFKDeleteUpdate
    end
    object actFKAdd1: TAction
      Caption = 'A&dd'
      OnExecute = actFKAdd1Execute
      OnUpdate = actFKAdd1Update
    end
    object actFKDelete1: TAction
      Caption = 'D&elete'
      OnExecute = actFKDelete1Execute
      OnUpdate = actFKDelete1Update
    end
    object actPKAdd: TAction
      Caption = '&Add'
      OnExecute = actPKAddExecute
      OnUpdate = actPKAddUpdate
    end
    object actPKDelete: TAction
      Caption = '&Delete'
      OnExecute = actPKDeleteExecute
      OnUpdate = actPKDeleteUpdate
    end
    object actUCAdd: TAction
      Caption = '&Add'
      OnExecute = actUCAddExecute
      OnUpdate = actUCAddUpdate
    end
    object actUCDelete: TAction
      Caption = '&Delete'
      OnExecute = actUCDeleteExecute
      OnUpdate = actUCDeleteUpdate
    end
  end
end
