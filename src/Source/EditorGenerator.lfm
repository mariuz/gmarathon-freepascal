object frmGenerators: TfrmGenerators
  Left = 396
  Top = 243
  Width = 519
  Height = 306
  Caption = 'Generator - []'
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
    Width = 511
    Height = 260
    ActivePage = tsGeneratorView
    Align = alClient
    HotTrack = True
    TabIndex = 0
    TabOrder = 0
    OnChange = pgObjectEditorChange
    OnChanging = pgObjectEditorChanging
    object tsGeneratorView: TTabSheet
      Caption = 'Generator'
      object Label1: TLabel
        Left = 8
        Top = 16
        Width = 81
        Height = 13
        Caption = '&Generator Name:'
        FocusControl = edGeneratorName
      end
      object Label2: TLabel
        Left = 20
        Top = 44
        Width = 67
        Height = 13
        Caption = 'Current &Value:'
        FocusControl = udGenerator
      end
      object edGeneratorName: TEdit
        Left = 92
        Top = 12
        Width = 257
        Height = 21
        TabOrder = 0
        OnChange = edGeneratorNameChange
      end
      object udGenerator: TSpinEdit
        Left = 92
        Top = 40
        Width = 57
        Height = 22
        MaxValue = 0
        MinValue = 0
        TabOrder = 1
        Value = 0
        OnChange = udGeneratorChange
      end
      object Button1: TButton
        Left = 152
        Top = 40
        Width = 97
        Height = 21
        Action = actReset
        TabOrder = 2
      end
      object btnSave: TButton
        Left = 252
        Top = 40
        Width = 97
        Height = 21
        Action = actSave
        TabOrder = 3
      end
    end
    object tsDDLView: TTabSheet
      Caption = 'DDL'
      inline framDDL: TframDisplayDDL
        Left = 0
        Top = 0
        Width = 503
        Height = 232
        Align = alClient
        TabOrder = 0
        inherited edDDL: TSyntaxMemoWithStuff2
          Width = 503
          Height = 232
        end
      end
    end
  end
  object stsEditor: TStatusBar
    Left = 0
    Top = 260
    Width = 511
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
  object qryGenerator: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 28
    Top = 124
  end
  object ActionList1: TActionList
    Left = 28
    Top = 96
    object actReset: TAction
      Caption = '&Reset Value'
      OnExecute = actResetExecute
      OnUpdate = actResetUpdate
    end
    object actSave: TAction
      Caption = '&Save'
      OnExecute = actSaveExecute
      OnUpdate = actSaveUpdate
    end
  end
end
