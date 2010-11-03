object frmUsers: TfrmUsers
  Left = 376
  Top = 243
  Width = 557
  Height = 312
  Caption = 'Users'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Scaled = False
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object stsUsers: TStatusBar
    Left = 0
    Top = 258
    Width = 549
    Height = 20
    Panels = <
      item
        Width = 65
      end
      item
        Width = 90
      end
      item
        Width = 50
      end>
  end
  object pgUsers: TPageControl
    Left = 0
    Top = 0
    Width = 549
    Height = 258
    ActivePage = tsUserView
    Align = alClient
    HotTrack = True
    TabOrder = 1
    OnChange = pgUsersChange
    object tsUserView: TTabSheet
      Caption = 'Users'
      object Splitter1: TSplitter
        Left = 0
        Top = 0
        Height = 230
      end
      object Panel1: TPanel
        Left = 3
        Top = 0
        Width = 538
        Height = 230
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object tabGrants: TrmTabSet
          Left = 0
          Top = 209
          Width = 538
          Height = 21
          Align = alBottom
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'MS Sans Serif'
          Font.Style = []
          Tabs.Strings = (
            'Stored Procedures'
            'Tables'
            'Views')
          TabIndex = 0
          TabLocation = tlBottom
          TabType = ttWin2k
        end
        object ListView1: TListView
          Left = 0
          Top = 0
          Width = 538
          Height = 209
          Align = alClient
          Columns = <>
          TabOrder = 1
        end
      end
    end
  end
  object qryUser: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 252
    Top = 36
  end
  object ActionList1: TActionList
    Images = frmMarathonMain.imgMenuTools
    Left = 221
    Top = 37
    object actPrint: TAction
      Category = 'File'
      Caption = '&Print'
      Hint = 'Print'
      ImageIndex = 13
    end
    object actPrintPreview: TAction
      Category = 'File'
      Caption = 'Print Pre&view'
      Hint = 'Print Preview'
      ImageIndex = 14
    end
    object actUndo: TAction
      Category = 'Edit'
      Caption = '&Undo'
      Hint = 'Undo'
      ImageIndex = 22
      ShortCut = 16474
    end
    object actRedo: TAction
      Category = 'Edit'
      Caption = '&Redo'
      Hint = 'Redo'
      ImageIndex = 23
    end
    object actCaptureSnippet: TAction
      Category = 'Edit'
      Caption = 'Capture &Snippet...'
      Hint = 'Capture Code Snippet'
      ImageIndex = 24
    end
    object actCut: TAction
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut'
      ImageIndex = 19
      ShortCut = 16472
    end
    object actCopy: TAction
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy'
      ImageIndex = 20
      ShortCut = 16451
    end
    object actPaste: TAction
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste'
      ImageIndex = 21
      ShortCut = 16470
    end
    object actSelectAll: TAction
      Category = 'Edit'
      Caption = 'Select &All'
    end
    object actFind: TAction
      Category = 'Edit'
      Caption = '&Find...'
      Hint = 'Find'
      ImageIndex = 7
      ShortCut = 16454
    end
    object actCompile: TAction
      Category = 'Edit'
      Caption = '&Compile'
      Hint = 'Compile'
      ImageIndex = 16
      ShortCut = 16504
    end
    object actExecute: TAction
      Category = 'Edit'
      Caption = '&Execute'
      Hint = 'Execute'
      ImageIndex = 17
      ShortCut = 120
    end
    object actDrop: TAction
      Category = 'Edit'
      Caption = '&Drop'
      Hint = 'Drop'
      ImageIndex = 18
    end
    object actCommit: TAction
      Category = 'Edit'
      Caption = '&Commit'
      ShortCut = 49219
    end
    object actRollback: TAction
      Category = 'Edit'
      Caption = '&Rollback'
      ShortCut = 49234
    end
    object actFindNext: TAction
      Category = 'Edit'
      Caption = 'Find &Next...'
    end
    object actReplace: TAction
      Category = 'Edit'
      Caption = '&Replace...'
      ShortCut = 16466
    end
    object actClose: TAction
      Category = 'File'
      Caption = 'C&lose Window'
      OnExecute = actCloseExecute
    end
    object actSaveToFile: TAction
      Category = 'File'
      Caption = 'Save &To File...'
    end
    object actOpenFromFile: TAction
      Category = 'File'
      Caption = 'Open From F&ile...'
    end
    object actEncoding: TAction
      Category = 'Encoding'
      Caption = 'Enc&oding'
    end
    object actEncANSI: TAction
      Category = 'Encoding'
      Caption = '&ANSI'
    end
    object actEncDefault: TAction
      Category = 'Encoding'
      Caption = '&Default'
    end
    object actEncSymbol: TAction
      Category = 'Encoding'
      Caption = 'S&ymbol'
    end
    object actEncMacintosh: TAction
      Category = 'Encoding'
      Caption = '&Macintosh'
    end
    object actEncSHIFTJIS: TAction
      Category = 'Encoding'
      Caption = '&Japanese'
    end
    object actEncHANGEUL: TAction
      Category = 'Encoding'
      Caption = 'Korean (&Wansung)'
    end
    object actEncJOHAB: TAction
      Category = 'Encoding'
      Caption = 'K&orean (Johab)'
    end
    object actEncGB2312: TAction
      Category = 'Encoding'
      Caption = '&Chinese (Simplified)'
    end
    object actEncCHINESEBIG5: TAction
      Category = 'Encoding'
      Caption = 'Chinese (&Traditional)'
    end
    object actEncGreek: TAction
      Category = 'Encoding'
      Caption = '&Greek'
    end
    object actEncTurkish: TAction
      Category = 'Encoding'
      Caption = 'T&urkish'
    end
    object actEncVietnamese: TAction
      Category = 'Encoding'
      Caption = '&Vietnamese'
    end
    object actEncHebrew: TAction
      Category = 'Encoding'
      Caption = '&Hebrew'
    end
    object actEncArabic: TAction
      Category = 'Encoding'
      Caption = 'Ara&bic'
    end
    object actEncBaltic: TAction
      Category = 'Encoding'
      Caption = '&Baltic'
    end
    object actEncRussian: TAction
      Category = 'Encoding'
      Caption = 'Ru&ssian'
    end
    object actEncThai: TAction
      Category = 'Encoding'
      Caption = 'Tha&i'
    end
    object actEncEasternEuropean: TAction
      Category = 'Encoding'
      Caption = 'Easte&rn European'
    end
    object actEncOEM: TAction
      Category = 'Encoding'
      Caption = 'O&EM'
    end
    object actQueryBuilder: TAction
      Category = 'Edit'
      Caption = '&Query Builder...'
      Hint = 'Query Builder'
      ImageIndex = 26
    end
    object actPrevStatement: TAction
      Caption = 'actPrevStatement'
      Hint = 'Previous Statement'
      ImageIndex = 27
    end
    object actNextStatement: TAction
      Caption = 'actNextStatement'
      Hint = 'Next Statement'
      ImageIndex = 28
    end
    object actStatementHistory: TAction
      Caption = 'actStatementHistory'
      Hint = 'Statement History'
      ImageIndex = 29
    end
    object actWindowUserEditor: TAction
      Caption = '&1 User Editor'
      OnExecute = WindowListClick
    end
  end
  object dbSecurity: TIB_Connection
    Left = 12
    Top = 32
  end
  object tranSecurity: TIB_Transaction
    IB_Connection = dbSecurity
    Isolation = tiConcurrency
    Left = 12
    Top = 64
  end
  object qrySecurity: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    IB_Connection = dbSecurity
    IB_Transaction = tranSecurity
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 44
    Top = 32
  end
end
