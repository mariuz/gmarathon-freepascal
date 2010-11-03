object frmEditorSnippet: TfrmEditorSnippet
  Left = 405
  Top = 234
  Width = 370
  Height = 350
  Caption = 'New/Modify Code Snippet'
  Color = clBtnFace
  Constraints.MinHeight = 350
  Constraints.MinWidth = 370
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  DesignSize = (
    362
    323)
  PixelsPerInch = 96
  TextHeight = 13
  object lblSnippetName: TLabel
    Left = 5
    Top = 10
    Width = 70
    Height = 13
    Caption = '&Snippet Name:'
    FocusControl = edSnippetName
  end
  object btnCancel: TButton
    Left = 190
    Top = 295
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = '&Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnOK: TButton
    Left = 110
    Top = 295
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&OK'
    TabOrder = 2
    OnClick = btnOKClick
  end
  object edSnippetName: TEdit
    Left = 85
    Top = 5
    Width = 260
    Height = 21
    Anchors = [akLeft, akTop, akRight]
    TabOrder = 0
  end
  object btnHelp: TButton
    Left = 270
    Top = 295
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = '&Help'
    TabOrder = 4
    OnClick = btnHelpClick
  end
  object pgEditorSnippet: TPageControl
    Left = 6
    Top = 36
    Width = 350
    Height = 250
    ActivePage = tsSnippet
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 1
    object tsSnippet: TTabSheet
      Caption = 'Snippet'
      ImageIndex = 1
      DesignSize = (
        342
        222)
      object Label3: TLabel
        Left = 5
        Top = 5
        Width = 63
        Height = 13
        Caption = '&Snippet Text:'
        FocusControl = edSnippet
      end
      object edSnippet: TSyntaxMemoWithStuff2
        Left = 5
        Top = 25
        Width = 330
        Height = 190
        Anchors = [akLeft, akTop, akRight, akBottom]
        Font.Charset = ANSI_CHARSET
        Font.Color = clWindowText
        Font.Height = -13
        Font.Name = 'Courier New'
        Font.Style = []
        TabOrder = 0
        Gutter.Font.Charset = DEFAULT_CHARSET
        Gutter.Font.Color = clWindowText
        Gutter.Font.Height = -11
        Gutter.Font.Name = 'Terminal'
        Gutter.Font.Style = []
        Highlighter = dmMenus.synHighlighter
        FindDialogHelpContext = 0
        ReplaceDialogHelpContext = 0
        KeywordCapitalise = False
        UseNavigateHyperLinks = False
        NavigatorHyperLinkStyle.Strings = (
          '2')
        ListDelay = 800
        WordList = <>
        SQLInsightList = <>
        RemovedKeystrokes = <
          item
            Command = ecLineBreak
            ShortCut = 8205
          end
          item
            Command = ecContextHelp
            ShortCut = 112
          end>
        AddedKeystrokes = <>
      end
    end
    object tsFolder: TTabSheet
      Caption = 'Folder'
      DesignSize = (
        342
        222)
      object Label2: TLabel
        Left = 5
        Top = 5
        Width = 44
        Height = 13
        Caption = '&In Folder:'
        FocusControl = tvSnippetsFolders
      end
      object tvSnippetsFolders: TrmPathTreeView
        Left = 5
        Top = 25
        Width = 330
        Height = 190
        SepChar = '\'
        Anchors = [akLeft, akTop, akRight, akBottom]
        HideSelection = False
        Images = frmMarathonMain.ilMarathonImages
        Indent = 19
        ReadOnly = True
        RightClickSelect = True
        TabOrder = 0
      end
    end
  end
  object rmCornerGrip1: TrmCornerGrip
    Left = 332
    Top = 294
  end
end
