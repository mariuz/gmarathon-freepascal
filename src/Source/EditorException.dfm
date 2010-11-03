object frmExceptions: TfrmExceptions
  Left = 411
  Top = 226
  Width = 536
  Height = 326
  Caption = 'Exceptions - []'
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
    Width = 528
    Height = 280
    ActivePage = tsObject
    Align = alClient
    HotTrack = True
    TabIndex = 0
    TabOrder = 0
    OnChange = pgObjectEditorChange
    OnChanging = pgObjectEditorChanging
    object tsObject: TTabSheet
      Caption = 'Exception'
      object Label1: TLabel
        Left = 8
        Top = 16
        Width = 81
        Height = 13
        Caption = '&Exception Name:'
        FocusControl = edExceptionName
      end
      object Label2: TLabel
        Left = 12
        Top = 44
        Width = 74
        Height = 13
        Caption = 'Exception &Text:'
        FocusControl = edExceptionText
      end
      object edExceptionName: TEdit
        Left = 92
        Top = 12
        Width = 221
        Height = 21
        TabOrder = 0
        OnChange = edExceptionNameChange
      end
      object edExceptionText: TEdit
        Left = 92
        Top = 40
        Width = 373
        Height = 21
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        TabOrder = 1
        OnChange = edExceptionTextChange
      end
    end
    object tsDocoView: TTabSheet
      Caption = 'Documentation'
      inline framDoco: TframeDesc
        Left = 0
        Top = 0
        Width = 520
        Height = 252
        Align = alClient
        TabOrder = 0
        inherited edDoco: TSyntaxMemoWithStuff2
          Width = 520
          Height = 252
        end
      end
    end
    object tsDDL: TTabSheet
      Caption = 'DDL'
      inline framDDL: TframDisplayDDL
        Left = 0
        Top = 0
        Width = 520
        Height = 252
        Align = alClient
        TabOrder = 0
        inherited edDDL: TSyntaxMemoWithStuff2
          Width = 520
          Height = 252
        end
      end
    end
  end
  object stsEditor: TStatusBar
    Left = 0
    Top = 280
    Width = 528
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
  object qryException: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 28
    Top = 100
  end
end
