object frameDRUI: TframeDRUI
  Left = 0
  Top = 0
  Width = 466
  Height = 189
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  ParentFont = False
  TabOrder = 0
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 466
    Height = 33
    Align = alTop
    BevelOuter = bvNone
    BorderStyle = bsSingle
    Color = clAppWorkSpace
    TabOrder = 0
    object Label1: TLabel
      Left = 4
      Top = 8
      Width = 56
      Height = 13
      Caption = '&Group by:'
      FocusControl = cmbGroup
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindow
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object cmbGroup: TComboBox
      Left = 60
      Top = 4
      Width = 161
      Height = 21
      Style = csDropDownList
      ItemHeight = 13
      TabOrder = 0
      OnChange = cmbGroupChange
      Items.Strings = (
        'Relation'
        'Operation')
    end
  end
  object tvCrud: TrmPathTreeView
    Left = 0
    Top = 33
    Width = 466
    Height = 156
    SepChar = #2
    Align = alClient
    HideSelection = False
    Indent = 19
    ReadOnly = True
    TabOrder = 1
  end
  object dtaCrud: TrmMemoryDataSet
    FieldRoster = <
      item
        Name = 'line'
        Size = 0
        FieldType = fdtInteger
      end
      item
        Name = 'op'
        Size = 40
        FieldType = fdtString
      end
      item
        Name = 'table'
        Size = 120
        FieldType = fdtString
      end>
    Left = 56
    Top = 80
    object dtaCrudline: TIntegerField
      FieldName = 'line'
      Required = True
    end
    object dtaCrudop: TStringField
      FieldName = 'op'
      Required = True
      Size = 40
    end
    object dtaCrudtable: TStringField
      FieldName = 'table'
      Required = True
      Size = 120
    end
  end
  object dsCrud: TDataSource
    DataSet = dtaCrud
    Left = 92
    Top = 80
  end
end
