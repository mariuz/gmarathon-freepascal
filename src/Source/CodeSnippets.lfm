object frmCodeSnippets: TfrmCodeSnippets
  Left = 425
  Top = 188
  Width = 240
  Height = 370
  BorderStyle = bsSizeToolWin
  Caption = 'Code Snippets'
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = ANSI_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PopupMenu = PopupMenu1
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 0
    Top = 200
    Width = 232
    Height = 2
    Cursor = crVSplit
    Align = alTop
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 232
    Height = 200
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Panel1'
    TabOrder = 0
    object tvCodeSnippets: TrmPathTreeView
      Left = 0
      Top = 0
      Width = 232
      Height = 200
      SepChar = '\'
      Align = alClient
      DragMode = dmAutomatic
      HideSelection = False
      Images = frmMarathonMain.ilMarathonImages
      Indent = 19
      ReadOnly = True
      SortType = stText
      TabOrder = 0
      OnChange = tvCodeSnippetsChange
      OnCompare = tvCodeSnippetsCompare
      OnDblClick = tvCodeSnippetsDblClick
      OnDragDrop = tvCodeSnippetsDragDrop
      OnDragOver = tvCodeSnippetsDragOver
      OnKeyDown = tvCodeSnippetsKeyDown
      OnMouseDown = tvCodeSnippetsMouseDown
      OnStartDrag = tvCodeSnippetsStartDrag
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 202
    Width = 232
    Height = 115
    Align = alClient
    BevelOuter = bvNone
    Caption = 'Panel2'
    TabOrder = 2
    object memCodeSnippets: TMemo
      Left = 0
      Top = 0
      Width = 232
      Height = 115
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
  object pnlTransSettings: TPanel
    Left = 0
    Top = 317
    Width = 232
    Height = 19
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    object sbtnToolWin: TSpeedButton
      Left = 212
      Top = 4
      Width = 14
      Height = 14
      Hint = 'Transparent window'
      AllowAllUp = True
      GroupIndex = 1
      Caption = '^'
      Flat = True
      Font.Charset = ANSI_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      Visible = False
      OnClick = sbtnToolWinClick
    end
  end
  object PopupMenu1: TPopupMenu
    Left = 58
    Top = 312
    object mnuiStayOnTop: TMenuItem
      Action = actStayOnTop
    end
    object N1: TMenuItem
      Caption = '-'
    end
    object mnuiNew: TMenuItem
      Caption = '&New'
      object mnuiNewFolder: TMenuItem
        Action = actNewFolder
      end
      object mnuiNewSnippet: TMenuItem
        Action = actNewSnippet
      end
    end
    object DeleteFolder1: TMenuItem
      Caption = '&Delete'
      object Folder2: TMenuItem
        Action = actDeleteFolder
      end
      object Snippet2: TMenuItem
        Action = actDeleteSnippet
      end
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object mnuiEditSnippet: TMenuItem
      Action = actEditSnippet
    end
    object mnuiRename: TMenuItem
      Action = actRename
    end
    object mnuiCopy: TMenuItem
      Action = actCopy
    end
    object N3: TMenuItem
      Caption = '-'
    end
    object mnuiFullExpand: TMenuItem
      Action = actFullExpand
    end
    object mnuiFullCollapse: TMenuItem
      Action = actFullCollapse
    end
    object N4: TMenuItem
      Caption = '-'
    end
    object mnuiClose: TMenuItem
      Action = actClose
    end
  end
  object ActionList1: TActionList
    Left = 30
    Top = 312
    object actStayOnTop: TAction
      Caption = '&Stay On Top'
      OnExecute = actStayOnTopExecute
      OnUpdate = actStayOnTopUpdate
    end
    object actNewFolder: TAction
      Caption = '&Folder...'
      OnExecute = actNewFolderExecute
      OnUpdate = actNewFolderUpdate
    end
    object actNewSnippet: TAction
      Caption = '&Snippet...'
      OnExecute = actNewSnippetExecute
      OnUpdate = actNewSnippetUpdate
    end
    object actDeleteFolder: TAction
      Caption = '&Folder'
      OnExecute = actDeleteFolderExecute
      OnUpdate = actDeleteFolderUpdate
    end
    object actDeleteSnippet: TAction
      Caption = '&Snippet'
      OnExecute = actDeleteSnippetExecute
      OnUpdate = actDeleteSnippetUpdate
    end
    object actRename: TAction
      Caption = '&Rename...'
      OnExecute = actRenameExecute
      OnUpdate = actRenameUpdate
    end
    object actEditSnippet: TAction
      Caption = '&Edit Snippet...'
      OnExecute = actEditSnippetExecute
      OnUpdate = actEditSnippetUpdate
    end
    object actCopy: TAction
      Caption = '&Copy'
      OnExecute = actCopyExecute
      OnUpdate = actCopyUpdate
    end
    object actFullExpand: TAction
      Caption = 'Full ex&pand'
      OnExecute = actFullExpandExecute
    end
    object actFullCollapse: TAction
      Caption = 'Full c&ollapse'
      OnExecute = actFullCollapseExecute
    end
    object actClose: TAction
      Caption = 'C&lose'
      OnExecute = actCloseExecute
    end
  end
end
