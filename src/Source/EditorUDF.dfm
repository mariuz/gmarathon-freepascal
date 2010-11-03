object frmUDFEditor: TfrmUDFEditor
  Left = 375
  Top = 197
  Width = 599
  Height = 463
  Caption = 'UDF - []'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object pgObjectEditor: TPageControl
    Left = 0
    Top = 0
    Width = 591
    Height = 417
    ActivePage = tsObject
    Align = alClient
    HotTrack = True
    TabIndex = 0
    TabOrder = 0
    OnChange = pgObjectEditorChange
    OnChanging = pgObjectEditorChanging
    object tsObject: TTabSheet
      Caption = 'UDF'
      object Panel2: TPanel
        Left = 0
        Top = 189
        Width = 583
        Height = 200
        Align = alClient
        BevelOuter = bvNone
        Caption = 'Panel2'
        TabOrder = 0
        object lvUDFParams: TListView
          Left = 0
          Top = 0
          Width = 583
          Height = 200
          Align = alClient
          Columns = <
            item
              Caption = 'Parameter'
              Width = 150
            end
            item
              Caption = 'Calling Mechanism'
              Width = 180
            end>
          HideSelection = False
          ReadOnly = True
          PopupMenu = dmMenus.mnuUDF
          TabOrder = 0
          ViewStyle = vsReport
          OnKeyDown = lvUDFParamsKeyDown
        end
      end
      object Panel1: TPanel
        Left = 0
        Top = 0
        Width = 583
        Height = 189
        Align = alTop
        BevelOuter = bvNone
        TabOrder = 1
        object Label5: TLabel
          Left = 4
          Top = 136
          Width = 15
          Height = 13
          Caption = '&By:'
          FocusControl = cmbRtnType
        end
        object Label4: TLabel
          Left = 4
          Top = 108
          Width = 40
          Height = 13
          Caption = '&Returns:'
          FocusControl = edRtnParam
        end
        object Label3: TLabel
          Left = 4
          Top = 68
          Width = 65
          Height = 13
          Caption = '&Library Name:'
          FocusControl = edLibraryName
        end
        object Label2: TLabel
          Left = 4
          Top = 40
          Width = 54
          Height = 13
          Caption = '&Entry Point:'
          FocusControl = edEntryPoint
        end
        object Label1: TLabel
          Left = 4
          Top = 12
          Width = 31
          Height = 13
          Caption = '&Name:'
          FocusControl = edUDFName
        end
        object Label6: TLabel
          Left = 4
          Top = 172
          Width = 83
          Height = 13
          Caption = 'Input &Parameters:'
          FocusControl = lvUDFParams
        end
        object cmbRtnType: TComboBox
          Left = 76
          Top = 132
          Width = 181
          Height = 21
          Style = csDropDownList
          ItemHeight = 13
          TabOrder = 4
          Items.Strings = (
            'value'
            'reference')
        end
        object edLibraryName: TEdit
          Left = 76
          Top = 64
          Width = 181
          Height = 21
          TabOrder = 2
        end
        object edEntryPoint: TEdit
          Left = 76
          Top = 36
          Width = 181
          Height = 21
          TabOrder = 1
        end
        object edUDFName: TEdit
          Left = 76
          Top = 8
          Width = 181
          Height = 21
          TabOrder = 0
          OnChange = edUDFNameChange
        end
        object edRtnParam: TEdit
          Left = 76
          Top = 104
          Width = 181
          Height = 21
          TabOrder = 3
        end
      end
    end
    object tsDocoView: TTabSheet
      Caption = 'Documentation'
      inline framDoco: TframeDesc
        Left = 0
        Top = 0
        Width = 583
        Height = 389
        Align = alClient
        TabOrder = 0
        inherited edDoco: TSyntaxMemoWithStuff2
          Width = 583
          Height = 389
        end
      end
    end
    object tsDDL: TTabSheet
      Caption = 'DDL'
      inline framDDL: TframDisplayDDL
        Left = 0
        Top = 0
        Width = 583
        Height = 389
        Align = alClient
        TabOrder = 0
        inherited edDDL: TSyntaxMemoWithStuff2
          Width = 583
          Height = 389
        end
      end
    end
  end
  object stsEditor: TStatusBar
    Left = 0
    Top = 417
    Width = 591
    Height = 19
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
  object qryUtil: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 272
    Top = 32
  end
end
