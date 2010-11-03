object frmStoredProcParameters: TfrmStoredProcParameters
  Left = 337
  Top = 213
  BorderIcons = [biSystemMenu]
  BorderStyle = bsDialog
  Caption = 'Stored Procedure Parameters'
  ClientHeight = 269
  ClientWidth = 502
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 4
    Top = 8
    Width = 56
    Height = 13
    Caption = '&Parameters:'
    FocusControl = DBGrid1
  end
  object btnOK: TButton
    Left = 424
    Top = 24
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    TabOrder = 0
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 424
    Top = 52
    Width = 75
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
  object btnHelp: TButton
    Left = 424
    Top = 104
    Width = 75
    Height = 25
    Caption = 'Help'
    TabOrder = 2
    OnClick = btnHelpClick
  end
  object DBGrid1: TDBGrid
    Left = 4
    Top = 24
    Width = 413
    Height = 237
    DataSource = dsParameters
    Options = [dgEditing, dgTitles, dgIndicator, dgColumnResize, dgColLines, dgRowLines, dgTabs, dgConfirmDelete]
    TabOrder = 3
    TitleFont.Charset = DEFAULT_CHARSET
    TitleFont.Color = clWindowText
    TitleFont.Height = -11
    TitleFont.Name = 'MS Sans Serif'
    TitleFont.Style = []
    Columns = <
      item
        Expanded = False
        FieldName = 'param_name'
        ReadOnly = True
        Title.Caption = 'Parameter'
        Width = 110
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'param_type'
        ReadOnly = True
        Title.Caption = 'Type'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'param_value'
        Title.Caption = 'Value'
        Width = 100
        Visible = True
      end
      item
        Expanded = False
        FieldName = 'null'
        PickList.Strings = (
          'NULL')
        Title.Caption = 'Null'
        Width = 62
        Visible = True
      end>
  end
  object dsParameters: TDataSource
    Left = 16
    Top = 228
  end
end
