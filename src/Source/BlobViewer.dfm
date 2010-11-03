object frmBlobViewer: TfrmBlobViewer
  Left = 389
  Top = 265
  Width = 491
  Height = 260
  ActiveControl = edBlobText
  BorderIcons = [biSystemMenu]
  Caption = 'Blob Viewer'
  Color = clBtnFace
  Constraints.MinHeight = 258
  Constraints.MinWidth = 491
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  KeyPreview = True
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  DesignSize = (
    483
    226)
  PixelsPerInch = 96
  TextHeight = 13
  object btnOK: TButton
    Left = 298
    Top = 197
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 378
    Top = 197
    Width = 75
    Height = 25
    Anchors = [akRight, akBottom]
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object pgBlobViewer: TPageControl
    Left = 4
    Top = 4
    Width = 473
    Height = 189
    ActivePage = tsText
    Anchors = [akLeft, akTop, akRight, akBottom]
    HotTrack = True
    TabOrder = 2
    OnChanging = pgBlobViewerChanging
    object tsText: TTabSheet
      Caption = 'Text'
      object edBlobText: TMemo
        Left = 0
        Top = 0
        Width = 465
        Height = 161
        Align = alClient
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        ParentFont = False
        ScrollBars = ssBoth
        TabOrder = 0
        WordWrap = False
      end
    end
    object tsHex: TTabSheet
      Caption = 'Hex'
      object edBlobHex: THexEditor
        Left = 0
        Top = 0
        Width = 465
        Height = 161
        Cursor = crIBeam
        BytesPerColumn = 2
        Translation = ttAnsi
        BackupExtension = '.bak'
        Align = alClient
        OffsetDisplay = odHex
        BytesPerLine = 16
        Colors.Background = clWindow
        Colors.PositionBackground = clMaroon
        Colors.PositionText = clWhite
        Colors.ChangedBackground = 11075583
        Colors.ChangedText = clMaroon
        Colors.CursorFrame = clNavy
        Colors.Offset = clBlack
        Colors.OddColumn = clBlue
        Colors.EvenColumn = clNavy
        FocusFrame = True
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clWindowText
        Font.Height = -11
        Font.Name = 'Courier New'
        Font.Style = []
        OffsetSeparator = ':'
        TabOrder = 0
        ColWidths = (
          28
          7
          7
          7
          7
          14
          7
          7
          7
          14
          7
          7
          7
          14
          7
          7
          7
          14
          7
          7
          7
          14
          7
          7
          7
          14
          7
          7
          7
          14
          7
          7
          7
          14
          7
          7
          7
          7
          7
          7
          7
          7
          7
          7
          7
          7
          7
          7
          7
          7
          7)
      end
    end
  end
  object rmCornerGrip1: TrmCornerGrip
    Left = 160
    Top = 204
  end
end
