object frmGlobalPrintingRoutines: TfrmGlobalPrintingRoutines
  Left = 328
  Top = 265
  Width = 658
  Height = 412
  Caption = 'PrintingRoutines - Always Hidden'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object pnlBase: TPanel
    Left = 0
    Top = 0
    Width = 650
    Height = 385
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    object ppPrinter: TPagePrinter
      Left = 0
      Top = 0
      Width = 650
      Height = 385
      HorzScrollBar.Increment = 16
      HorzScrollBar.Range = 216
      HorzScrollBar.Tracking = True
      VertScrollBar.Increment = 16
      VertScrollBar.Range = 276
      VertScrollBar.Tracking = True
      Align = alClient
      AutoScroll = False
      Color = clAppWorkSpace
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      ParentColor = False
      TabOrder = 0
      Footer = 'Page {$PAGE}'
      FooterFormat = '>1'
      GradientBackground = False
      MarginBottom = 1.000000000000000000
      MarginLeft = 1.000000000000000000
      MarginRight = 1.000000000000000000
      MarginTop = 1.000000000000000000
      PageBorders = [pbTop]
    end
    object edPrintProxy: TSyntaxMemoWithStuff2
      Left = 8
      Top = 156
      Width = 129
      Height = 89
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -13
      Font.Name = 'Courier New'
      Font.Style = []
      TabOrder = 1
      Visible = False
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
  object pdsPrinter: TDataSetPrint
    PageOrientation = poPortrait
    RestartData = True
    PrintVisibleOnly = True
    DataHeaderFont.Charset = DEFAULT_CHARSET
    DataHeaderFont.Color = clWindowText
    DataHeaderFont.Height = -11
    DataHeaderFont.Name = 'MS Sans Serif'
    DataHeaderFont.Style = [fsBold]
    DataHeaderAlignment = taLeftJustify
    DataHeaderWordWrap = True
    DataFont.Charset = DEFAULT_CHARSET
    DataFont.Color = clWindowText
    DataFont.Height = -11
    DataFont.Name = 'MS Sans Serif'
    DataFont.Style = []
    WordWrapCells = False
    rpTitleWordWrap = True
    rpTitleFont.Charset = DEFAULT_CHARSET
    rpTitleFont.Color = clWindowText
    rpTitleFont.Height = -13
    rpTitleFont.Name = 'Arial'
    rpTitleFont.Style = [fsBold]
    rpTitleAlignment = taCenter
    rpPageHeaderOps = [phfPrintDate, phfPrintTime]
    rpPageHeaderFont.Charset = DEFAULT_CHARSET
    rpPageHeaderFont.Color = clWindowText
    rpPageHeaderFont.Height = -13
    rpPageHeaderFont.Name = 'MS Sans Serif'
    rpPageHeaderFont.Style = []
    rpPageHeaderAlignment = taLeftJustify
    rpPageHeaderWordWrap = True
    rpPageFooterOps = [phfPageNo]
    rpPageFooterFont.Charset = DEFAULT_CHARSET
    rpPageFooterFont.Color = clWindowText
    rpPageFooterFont.Height = -13
    rpPageFooterFont.Name = 'MS Sans Serif'
    rpPageFooterFont.Style = []
    rpPageFooterAlignment = taRightJustify
    rpPageFooterWordWrap = True
    rpTailFont.Charset = DEFAULT_CHARSET
    rpTailFont.Color = clWindowText
    rpTailFont.Height = -13
    rpTailFont.Name = 'Arial'
    rpTailFont.Style = []
    rpTailAlignment = taLeftJustify
    rpTailWordWrap = True
    MarginLeft_MM = 0
    MarginTop_MM = 0
    MarginRight_MM = 0
    MarginBottom_MM = 0
    glnVLineWidth = 1
    glnHLineWidth = 1
    glnLockHorzVertWidths = True
    KerningCharacter = 'W'
    DataTitleWrapper = '~'
    DTWThreading = lwrplCRLF
    FitCellsByHeader = False
    OverlayPrinting = False
    OverlayWidthMM = 5
    NPagesToFit = 0
    rpDataOptions = [ddoHorzGridLines, ddoVertGridLines]
    Left = 20
    Top = 111
  end
  object qryUtil: TIBOQuery
    Params = <>
    CallbackInc = 0
    FetchWholeRows = False
    KeyLinksAutoDefine = False
    ReadOnly = True
    RecordCountAccurate = False
    FieldOptions = []
    Left = 52
    Top = 112
  end
end
