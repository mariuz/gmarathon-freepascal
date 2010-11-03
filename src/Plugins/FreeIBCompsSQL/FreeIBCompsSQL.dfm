object frmFreeIBComponentsSQL: TfrmFreeIBComponentsSQL
  Left = 316
  Top = 179
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Create SQL for FreeIB/IBExpress'
  ClientHeight = 358
  ClientWidth = 503
  Color = clBtnFace
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
  PixelsPerInch = 96
  TextHeight = 13
  object btnClose: TButton
    Left = 420
    Top = 328
    Width = 75
    Height = 25
    Caption = '&Close'
    ModalResult = 1
    TabOrder = 0
  end
  object pgSQL: TPageControl
    Left = 4
    Top = 4
    Width = 493
    Height = 317
    ActivePage = tsSelectSQL
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    HotTrack = True
    ParentFont = False
    TabIndex = 0
    TabOrder = 1
    object tsSelectSQL: TTabSheet
      Caption = 'SelectSQL'
      object edSelectSQL: TMemo
        Left = 0
        Top = 0
        Width = 485
        Height = 289
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object tsRefreshSQL: TTabSheet
      Caption = 'RefreshSQL'
      object edRefreshSQL: TMemo
        Left = 0
        Top = 0
        Width = 485
        Height = 289
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object tsInsertSQL: TTabSheet
      Caption = 'InsertSQL'
      object edInsertSQL: TMemo
        Left = 0
        Top = 0
        Width = 485
        Height = 289
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object tsDeleteSQL: TTabSheet
      Caption = 'DeleteSQL'
      object edDeleteSQL: TMemo
        Left = 0
        Top = 0
        Width = 485
        Height = 289
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object tsUpdateSQL: TTabSheet
      Caption = 'UpdateSQL'
      object edUpdateSQL: TMemo
        Left = 0
        Top = 0
        Width = 485
        Height = 289
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'MS Sans Serif'
        Font.Style = []
        ParentFont = False
        ReadOnly = True
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
  end
  object dbPlugin: TIBDatabase
    DefaultTransaction = tranPlugin
    IdleTimer = 0
    SQLDialect = 1
    TraceFlags = []
    Left = 44
    Top = 320
  end
  object tranPlugin: TIBTransaction
    Active = False
    DefaultDatabase = dbPlugin
    AutoStopAction = saNone
    Left = 76
    Top = 320
  end
  object qryUtil: TIBDataSet
    Database = dbPlugin
    Transaction = tranPlugin
    BufferChunks = 1000
    CachedUpdates = False
    Left = 140
    Top = 320
  end
  object qryUtil2: TIBDataSet
    Database = dbPlugin
    Transaction = tranPlugin
    BufferChunks = 1000
    CachedUpdates = False
    Left = 176
    Top = 320
  end
end
