object frmDebugBreakPoints: TfrmDebugBreakPoints
  Left = 446
  Top = 260
  Width = 487
  Height = 203
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Breakpoints'
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnClose = FormClose
  PixelsPerInch = 96
  TextHeight = 13
  object lvBreakPoints: TListView
    Left = 0
    Top = 0
    Width = 479
    Height = 176
    Align = alClient
    Columns = <
      item
        Caption = 'Module'
        Width = 150
      end
      item
        Caption = 'Line'
      end
      item
        Caption = 'Condition'
        Width = 100
      end
      item
        Caption = 'Action'
        Width = 100
      end
      item
        Caption = 'Pass Count'
        Width = 75
      end>
    ColumnClick = False
    ReadOnly = True
    RowSelect = True
    TabOrder = 0
    ViewStyle = vsReport
  end
end
