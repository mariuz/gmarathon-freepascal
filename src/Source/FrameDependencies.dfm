object frameDepend: TframeDepend
  Left = 0
  Top = 0
  Width = 533
  Height = 244
  TabOrder = 0
  object pgDependencies: TPageControl
    Left = 0
    Top = 0
    Width = 533
    Height = 244
    ActivePage = tsDependedOn
    Align = alClient
    TabOrder = 0
    OnChange = pgDependenciesChange
    object tsDependedOn: TTabSheet
      Caption = 'Depended On'
      object lvDependedOn: TListView
        Left = 0
        Top = 25
        Width = 525
        Height = 191
        Align = alClient
        Columns = <
          item
            Caption = 'Dependent'
            Width = 300
          end
          item
            Caption = 'Field'
            Width = 300
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        SmallImages = frmMarathonMain.ilMarathonImages
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvDependedOnDblClick
        OnDeletion = lvDependsOnDeletion
      end
      object pnlDependedOnHdr: TPanel
        Left = 0
        Top = 0
        Width = 525
        Height = 25
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Caption = ' Objects that Depend On This Object'
        Color = clAppWorkSpace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clInfoBk
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
      end
    end
    object tsDependsOn: TTabSheet
      Caption = 'Depends On'
      ImageIndex = 1
      object lvDependsOn: TListView
        Left = 0
        Top = 25
        Width = 525
        Height = 191
        Align = alClient
        Columns = <
          item
            Caption = 'Dependent'
            Width = 300
          end
          item
            Caption = 'Field'
            Width = 300
          end>
        GridLines = True
        HideSelection = False
        ReadOnly = True
        RowSelect = True
        SmallImages = frmMarathonMain.ilMarathonImages
        TabOrder = 0
        ViewStyle = vsReport
        OnDblClick = lvDependedOnDblClick
        OnDeletion = lvDependsOnDeletion
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 525
        Height = 25
        Align = alTop
        Alignment = taLeftJustify
        BevelOuter = bvNone
        BorderStyle = bsSingle
        Caption = ' Objects that This Object Depends On'
        Color = clAppWorkSpace
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clInfoBk
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = [fsBold]
        ParentFont = False
        TabOrder = 1
      end
    end
  end
  object qryUtil: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 44
    Top = 88
  end
end
