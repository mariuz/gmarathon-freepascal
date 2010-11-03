object frmMarathonMain: TfrmMarathonMain
  Left = 225
  Top = 121
  Width = 736
  Height = 156
  Caption = 'Marathon'
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Icon.Data = {
    0000010001002020100000000000E80200001600000028000000200000004000
    0000010004000000000080020000000000000000000000000000000000000000
    000000008000008000000080800080000000800080008080000080808000C0C0
    C0000000FF0000FF000000FFFF00FF000000FF00FF00FFFF0000FFFFFF000000
    0000000000000000000000000000099999909999990000000000000000000000
    9900000990000000000000000000000099000009907070707070707070000000
    990000099000000000070707070000000990000099B3BFBF3B30007070000000
    099000BB99FBFBFBBBB3B00700000000099000B399B3BFBF3B3B300000000000
    0099003B399BFBFBBBB3B00000000000009900000993BFBF3B3B300000000000
    00990888899BFBFBBBB3B000000000000999999F9999BFBF3B3B300000000000
    000FFFFFF800FFFFB3B3B0000000008888888FFFF880FFFF3B3B307777700000
    0000000FFF8000000003B0EE8E7008888888888FFF80FBFBFBB000EE8E700000
    000000FFFFF0BFBFFFFFB088887000FFFFFFFFFFFF0BFBFFFFFFB0EE8E700000
    0000000000FFBFFFFFF00EEE8E700007EE07777700000000000EEEEE8E700007
    8880FFFFFFFFF8880888888888700007EEE0000000000000EEEEE8EEEE700007
    EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007
    88888888888888888888888888700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007
    EEEEEE8EEEEEEEE8EEEEE8EEEE700007EEEEEE8EEEEEEEE8EEEEE8EEEE700007
    77777777777777777777777777700007CCCCCCCCCCCCCCCCCCCC488488700007
    CCCCCCCCCCCCCCCCCCCC4F84F87000077777777777777777777777777770FFFF
    FFFF8103FFFFF3E7FFFFF3E55557F3E000ABF9C00057F980002FF980003FFC80
    003FFC00003FFC00003FF800003FC00000008000000000000000000000000000
    00008000000080000000E0000000E0000000E0000000E0000000E0000000E000
    0000E0000000E0000000E0000000E0000000E0000000E0000000E0000000}
  OldCreateOrder = False
  Position = poDefaultSizeOnly
  Scaled = False
  Visible = True
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object dckTop: TTBDock
    Left = 0
    Top = 0
    Width = 728
    Height = 75
    PopupMenu = mnuTools
    OnResize = dckTopResize
    object tlbrStandard: TTBToolbar
      Left = 0
      Top = 23
      Caption = 'Standard Toolbar'
      DefaultDock = dckTop
      DockPos = 0
      ParentShowHint = False
      PopupMenu = mnuTools
      ShowHint = True
      TabOrder = 0
      object tlbrStandardNewProject: TTBItem
        Action = FileNewProject
        Images = imgMenuTools
      end
      object tlbrStandardOpenProject: TTBItem
        Action = FileOpenProject
        Images = imgMenuTools
        Left = 25
      end
      object tlbrStandardCloBroject: TTBItem
        Action = FileCloseProject
        Images = imgMenuTools
        Left = 50
      end
      object ToolbarSep1: TTBSeparatorItem
        Left = 131
      end
      object btnPrint: TTBItem
        Action = FilePrint
        Images = imgMenuTools
        Left = 81
      end
      object btnPrintPreview: TTBItem
        Action = FilePrintPreview
        Images = imgMenuTools
        Left = 106
      end
      object ToolbarSep3: TTBSeparatorItem
        Left = 75
      end
      object TBControlItem: TTBControlItem
        Control = cmbConnections
      end
      object cmbConnections: TrmComboBox
        Left = 127
        Top = 0
        Width = 180
        Height = 21
        Style = csDropDownList
        ItemHeight = 13
        RegKey = rkHKEY_CLASSES_ROOT
        TabOrder = 0
        OnChange = cmbConnectionsChange
        OnCloseUp = cmbConnectionsCloseUp
        OnDropDown = cmbConnectionsDropDown
      end
    end
    object tlbrTools: TTBToolbar
      Left = 317
      Top = 23
      Caption = 'SQL Tools Toolbar'
      DefaultDock = dckTop
      DockPos = 313
      ParentShowHint = False
      PopupMenu = mnuTools
      ShowHint = True
      TabOrder = 1
      object btnToolsViewDBManager: TTBItem
        Action = ViewViewBrowser
        Images = imgMenuTools
      end
      object btnToolsSQLEditor: TTBItem
        Action = ToolsSQLEditor
        Images = imgMenuTools
        Left = 25
      end
      object ToolbarSep2: TTBSeparatorItem
        Left = 50
      end
      object btnToolsMetdataSearch: TTBItem
        Action = ToolsMetaSearch
        Images = imgMenuTools
        Left = 56
      end
      object btnToolsCodeSnippets: TTBItem
        Action = ToolsSQLCodeSnippets
        Images = imgMenuTools
        Left = 81
      end
      object btnToolsSQLTrace: TTBItem
        Action = ToolsSQLTrace
        Images = imgMenuTools
        Left = 106
      end
    end
    object tlbrScript: TTBToolbar
      Left = 448
      Top = 23
      Caption = 'Script Toolbar'
      DefaultDock = dckTop
      DockPos = 436
      ParentShowHint = False
      PopupMenu = mnuTools
      ShowHint = True
      TabOrder = 2
      object btnScriptRecordNew: TTBItem
        Action = ScriptRecordScript
        Images = imgMenuTools
      end
      object btnScriptAppendExisting: TTBItem
        Caption = '&Append To Existing Script...'
        Hint = 'Append Actions to Existing Script File'
        ImageIndex = 11
        Images = imgMenuTools
        Left = 25
      end
      object btnScriptExecute: TTBItem
        Caption = 'E&xecute Script...'
        Hint = 'Execute Firebird or InterBase SQL Script'
        ImageIndex = 12
        Images = imgMenuTools
        Left = 50
      end
    end
    object tlbrSQLEditor: TTBToolbar
      Left = 0
      Top = 49
      Caption = 'Edit Toolbar'
      DefaultDock = dckTop
      DockPos = 0
      DockRow = 1
      ParentShowHint = False
      PopupMenu = mnuTools
      ShowHint = True
      TabOrder = 3
      object btnUndo: TTBItem
        Action = EditUndo
        Images = imgMenuTools
      end
      object btnRedo: TTBItem
        Action = EditRedo
        Images = imgMenuTools
        Left = 25
      end
      object ToolbarSep6: TTBSeparatorItem
        Left = 380
      end
      object btnCaptureSnippet: TTBItem
        Action = EditCaptureSnippet
        Images = imgMenuTools
        Left = 56
      end
      object btnQueryBuilder: TTBItem
        Action = ToolsQueryBuilder
        Images = imgMenuTools
        Left = 81
      end
      object btnPrevStatement: TTBItem
        Action = ViewPrevStatement
        Images = imgMenuTools
        Left = 106
      end
      object btnNextStatement: TTBItem
        Action = ViewNextStatement
        Images = imgMenuTools
        Left = 131
      end
      object btnStatementHistory: TTBItem
        Action = ViewStatementHistory
        Images = imgMenuTools
        Left = 156
      end
      object ToolbarSep7: TTBSeparatorItem
        Left = 50
      end
      object btnCut: TTBItem
        Action = EditCut
        Images = imgMenuTools
        Left = 187
      end
      object btnCopy: TTBItem
        Action = EditCopy
        Images = imgMenuTools
        Left = 212
      end
      object btnPaste: TTBItem
        Action = EditPaste
        Images = imgMenuTools
        Left = 237
      end
      object ToolbarSep8: TTBSeparatorItem
        Left = 181
      end
      object btnFind: TTBItem
        Action = EditFind
        Images = imgMenuTools
        Left = 268
      end
      object ToolbarSep9: TTBSeparatorItem
        Left = 262
      end
      object btnCompile: TTBItem
        Action = ObjectCompile
        Images = imgMenuTools
        Left = 299
      end
      object btnExecute: TTBItem
        Action = ObjectExecute
        Images = imgMenuTools
        Left = 324
      end
      object ToolbarSep4: TTBSeparatorItem
        Left = 349
      end
      object btnDrop: TTBItem
        Action = ObjectDrop
        Images = imgMenuTools
        Left = 355
      end
      object ToolbarSep10: TTBSeparatorItem
        Left = 293
      end
      object btnCommit: TTBItem
        Action = TransactionCommit
        Left = 386
      end
      object btnRollback: TTBItem
        Action = TransactionRollback
        Left = 440
      end
    end
    object TBToolbar1: TTBToolbar
      Left = 0
      Top = 0
      BorderStyle = bsNone
      Caption = 'TBToolbar1'
      CloseButton = False
      DockMode = dmCannotFloatOrChangeDocks
      DragHandleStyle = dhNone
      FullSize = True
      HideWhenInactive = False
      Images = imgMenuTools
      MenuBar = True
      ProcessShortCuts = True
      ShrinkMode = tbsmWrap
      TabOrder = 4
      object File1: TTBSubmenuItem
        Tag = -1
        Caption = '&File'
        GroupIndex = 1
        object New1: TTBItem
          Action = FileNewProject
          GroupIndex = 1
        end
        object Open1: TTBItem
          Tag = 1
          Action = FileOpenProject
          GroupIndex = 2
        end
        object TBMRUListItem1: TTBMRUListItem
        end
        object ReOpen1: TTBItem
          Caption = '&Re-Open'
          GroupIndex = 2
        end
        object Close1: TTBItem
          Tag = -2
          Action = FileCloseProject
          GroupIndex = 3
        end
        object SaveProject1: TTBItem
          Action = FileSaveProject
          GroupIndex = 3
        end
        object SaveProjectAs1: TTBItem
          Action = FileSaveProjectAs
          GroupIndex = 3
        end
        object N20: TTBSeparatorItem
        end
        object New2: TTBItem
          Tag = -2
          Action = FileNewObject
          GroupIndex = 3
        end
        object Open2: TTBSubmenuItem
          Caption = '&Open'
          GroupIndex = 3
          object FileOpenFile1: TTBItem
            Action = FileOpenFile
          end
          object FileOpenDatabaseObject1: TTBItem
            Action = FileOpenDatabaseObject
          end
        end
        object FileSave1: TTBItem
          Action = FileSave
          GroupIndex = 3
        end
        object FileSaveAs1: TTBItem
          Action = FileSaveAs
          GroupIndex = 3
        end
        object Close2: TTBItem
          Tag = -2
          Action = FileClose
          GroupIndex = 3
        end
        object N28: TTBSeparatorItem
        end
        object F1: TTBItem
          Action = FileExport
          GroupIndex = 3
        end
        object N10: TTBSeparatorItem
          Tag = -2
        end
        object CreateDatabase1: TTBItem
          Tag = -2
          Action = FileCreateDatabase
          GroupIndex = 3
        end
        object N3: TTBSeparatorItem
          Tag = -2
        end
        object Connect1: TTBItem
          Tag = -2
          Action = FileConnect
          GroupIndex = 4
        end
        object Disconnect1: TTBItem
          Tag = -2
          Action = FileDisconnect
          GroupIndex = 5
        end
        object N1: TTBSeparatorItem
          Tag = -2
        end
        object PrintSetup1: TTBItem
          Tag = -2
          Action = FilePrintSetup
          GroupIndex = 6
        end
        object Print1: TTBItem
          Tag = -2
          Action = FilePrint
          GroupIndex = 7
        end
        object PrintPreview1: TTBItem
          Tag = -2
          Action = FilePrintPreview
          GroupIndex = 7
        end
        object N2: TTBSeparatorItem
          Tag = -2
        end
        object Exit1: TTBItem
          Tag = -2
          Action = FileExitApplication
          GroupIndex = 8
        end
      end
      object Edit1: TTBSubmenuItem
        Tag = -1
        Caption = '&Edit'
        GroupIndex = 1
        object Undo1: TTBItem
          Tag = -2
          Action = EditUndo
        end
        object actRedo1: TTBItem
          Action = EditRedo
        end
        object N4: TTBSeparatorItem
          Tag = -2
        end
        object Cut1: TTBItem
          Tag = -2
          Action = EditCut
        end
        object Copy1: TTBItem
          Tag = -2
          Action = EditCopy
        end
        object Paste1: TTBItem
          Tag = -2
          Action = EditPaste
        end
        object SelectAll1: TTBItem
          Tag = -2
          Action = EditSelectAll
        end
        object N34: TTBSeparatorItem
        end
        object CaptureSnippet1: TTBItem
          Action = EditCaptureSnippet
        end
        object N18: TTBSeparatorItem
        end
        object ToggleBookmark1: TTBSubmenuItem
          Caption = '&Toggle Bookmark'
          object EditToggleBookmark01: TTBItem
            Action = EditToggleBookmark0
          end
          object EditToggleBookmark11: TTBItem
            Action = EditToggleBookmark1
          end
          object EditGotoBookmark21: TTBItem
            Action = EditToggleBookmark2
          end
          object EditToggleBookmark31: TTBItem
            Action = EditToggleBookmark3
          end
          object EditToggleBookmark41: TTBItem
            Action = EditToggleBookmark4
          end
          object EditToggleBookmark51: TTBItem
            Action = EditToggleBookmark5
          end
          object EditToggleBookmark61: TTBItem
            Action = EditToggleBookmark6
          end
          object EditToggleBookmark71: TTBItem
            Action = EditToggleBookmark7
          end
          object EditToggleBookmark81: TTBItem
            Action = EditToggleBookmark8
          end
          object EditToggleBookmark91: TTBItem
            Action = EditToggleBookmark9
          end
        end
        object GotoBookmark1: TTBSubmenuItem
          Caption = '&Goto Bookmark'
          object EditGotoBookmark01: TTBItem
            Action = EditGotoBookmark0
          end
          object EditGotoBookmark11: TTBItem
            Action = EditGotoBookmark1
          end
          object EditGotoBookmark22: TTBItem
            Action = EditGotoBookmark2
          end
          object EditGotoBookmark31: TTBItem
            Action = EditGotoBookmark3
          end
          object EditGotoBookmark41: TTBItem
            Action = EditGotoBookmark4
          end
          object EditGotoBookmark51: TTBItem
            Action = EditGotoBookmark5
          end
          object EditGotoBookmark61: TTBItem
            Action = EditGotoBookmark6
          end
          object EditGotoBookmark71: TTBItem
            Action = EditGotoBookmark7
          end
          object EditGotoBookmark81: TTBItem
            Action = EditGotoBookmark8
          end
          object EditGotoBookmark91: TTBItem
            Action = EditGotoBookmark9
          end
        end
        object N27: TTBSeparatorItem
        end
        object Encoding1: TTBSubmenuItem
          Caption = 'Enc&oding'
          object ANSI1: TTBItem
            Action = EditEncANSI
            RadioItem = True
          end
          object Arabic1: TTBItem
            Action = EditEncDefault
            RadioItem = True
          end
          object Symbol1: TTBItem
            Action = EditEncSymbol
            RadioItem = True
          end
          object Macintosh1: TTBItem
            Action = EncMacintosh
            RadioItem = True
          end
          object Japanese1: TTBItem
            Action = EditEncSHIFTJIS
            RadioItem = True
          end
          object KoreanWansung1: TTBItem
            Action = EditEncHANGEUL
            RadioItem = True
          end
          object KoreanJohab1: TTBItem
            Action = EditEncJOHAB
            RadioItem = True
          end
          object ChineseSimplified1: TTBItem
            Action = EditEncGB2312
            RadioItem = True
          end
          object ChineseTraditional1: TTBItem
            Action = EditEncCHINESEBIG5
            RadioItem = True
          end
          object Greek1: TTBItem
            Action = EditEncGreek
            RadioItem = True
          end
          object Turkish1: TTBItem
            Action = EditEncTurkish
            RadioItem = True
          end
          object Vietnamese1: TTBItem
            Action = EditEncVietnamese
            RadioItem = True
          end
          object Hebrew1: TTBItem
            Action = EditEncHebrew
            RadioItem = True
          end
          object Arabic2: TTBItem
            Action = EditEncArabic
            RadioItem = True
          end
          object Baltic1: TTBItem
            Action = EditEncBaltic
            RadioItem = True
          end
          object Russian1: TTBItem
            Action = EditEncRussian
            RadioItem = True
          end
          object Thai1: TTBItem
            Action = EditEncThai
            RadioItem = True
          end
          object EasternEuropean1: TTBItem
            Action = EditEncEasternEuropean
            RadioItem = True
          end
          object OEM1: TTBItem
            Action = EditEncOEM
            RadioItem = True
          end
        end
        object N5: TTBSeparatorItem
          Tag = -2
        end
        object Find1: TTBItem
          Tag = -2
          Action = EditFind
        end
        object FindNext1: TTBItem
          Tag = -2
          Action = EditFindNext
        end
        object Replace1: TTBItem
          Tag = -2
          Action = EditReplace
        end
      end
      object View1: TTBSubmenuItem
        Tag = -1
        Caption = '&View'
        GroupIndex = 2
        object DatabaseManager1: TTBItem
          Tag = -2
          Action = ViewViewBrowser
        end
        object ViewDebuggerHeader1: TTBSubmenuItem
          Caption = '&Debug Windows'
          object ViewBreakPoints1: TTBItem
            Action = ViewBreakPoints
          end
          object ViewCallStack1: TTBItem
            Action = ViewCallStack
          end
          object ViewWatches1: TTBItem
            Action = ViewWatches
          end
          object ViewLocalVariables1: TTBItem
            Action = ViewLocalVariables
          end
        end
        object N19: TTBSeparatorItem
        end
        object Tools2: TTBSubmenuItem
          Caption = '&Toolbars'
          object Standard1: TTBItem
            Action = ViewToolbarStandard
          end
          object Tools3: TTBItem
            Action = ViewToolbarTools
          end
          object Scipt1: TTBItem
            Action = ViewToolbarScript
          end
          object SQLEditor2: TTBItem
            Action = ViewToolbarSQLEditor
          end
        end
        object N6: TTBSeparatorItem
          Tag = -2
        end
        object actPrevStatement1: TTBItem
          Action = ViewPrevStatement
        end
        object actNextStatement1: TTBItem
          Action = ViewNextStatement
        end
        object actStatementHistory1: TTBItem
          Action = ViewStatementHistory
        end
        object N17: TTBSeparatorItem
        end
        object Folders1: TTBItem
          Action = ViewFolders
        end
        object Search1: TTBItem
          Action = ViewSearch
        end
        object List1: TTBItem
          Action = ViewList
        end
        object N12: TTBSeparatorItem
        end
        object ViewRefresh1: TTBItem
          Action = ViewRefresh
        end
        object N23: TTBSeparatorItem
        end
        object ViewPrevPage1: TTBItem
          Action = ViewPrevPage
        end
        object ViewNextPage1: TTBItem
          Action = ViewNextPage
        end
        object N33: TTBSeparatorItem
        end
        object ObjectViewMessages1: TTBItem
          Action = ViewMessages
        end
        object N26: TTBSeparatorItem
        end
        object NextWindow1: TTBItem
          Tag = -2
          Action = ViewNextWindow
        end
      end
      object Browser1: TTBSubmenuItem
        Caption = '&Project'
        GroupIndex = 2
        object ProjectNewItem1: TTBItem
          Action = ProjectNewItem
        end
        object ProjectOpenItem1: TTBItem
          Action = ProjectOpenItem
        end
        object ProjectExtractMetadata1: TTBItem
          Action = ProjectExtractMetadata
        end
        object ProjectAddToProject1: TTBItem
          Action = ProjectAddToProject
        end
        object ProjectCreateFolder1: TTBItem
          Action = ProjectCreateFolder
        end
        object N24: TTBSeparatorItem
        end
        object ProjectItemDrop1: TTBItem
          Action = ProjectItemDrop
        end
        object ProjectItemDelete1: TTBItem
          Action = ProjectItemDelete
        end
        object N25: TTBSeparatorItem
        end
        object ProjectItemProperties1: TTBItem
          Action = ProjectItemProperties
        end
        object N22: TTBSeparatorItem
        end
        object NewConnection1: TTBItem
          Action = ProjectNewConnection
        end
        object NewServer1: TTBItem
          Action = ProjectNewServer
        end
        object N21: TTBSeparatorItem
        end
        object ProjectOptions2: TTBItem
          Action = ProjectProjectOptions
        end
      end
      object Transaction1: TTBSubmenuItem
        Caption = 'Tra&nsaction'
        GroupIndex = 10
        object Commit1: TTBItem
          Action = TransactionCommit
        end
        object Rollback1: TTBItem
          Action = TransactionRollback
        end
      end
      object Object1: TTBSubmenuItem
        Caption = '&Object'
        GroupIndex = 10
        object Compile1: TTBItem
          Action = ObjectCompile
        end
        object Execute1: TTBItem
          Action = ObjectExecute
        end
        object ObjectParameters1: TTBItem
          Action = ObjectParameters
        end
        object ScriptMode1: TTBItem
          Action = ObjectExecuteAsScript
        end
        object N31: TTBSeparatorItem
        end
        object ObjectStepOver1: TTBItem
          Action = ObjectStepOver
        end
        object ObjectStepInto1: TTBItem
          Action = ObjectStepInto
        end
        object ObjectShowExecutionPoint1: TTBItem
          Action = ObjectShowExecutionPoint
        end
        object ObjectPause1: TTBItem
          Action = ObjectPause
        end
        object ObjectReset1: TTBItem
          Action = ObjectReset
        end
        object ObjectDebuggerHeader1: TTBSubmenuItem
          Caption = '&Debugger'
          object ObjectEvalModify1: TTBItem
            Action = ObjectEvalModify
          end
          object ObjectAddWatch1: TTBItem
            Action = ObjectAddWatch
          end
          object ObjectAddBreakPoint1: TTBItem
            Action = ObjectAddBreakPoint
          end
        end
        object N29: TTBSeparatorItem
        end
        object New3: TTBSubmenuItem
          Caption = '&New'
          object ObjectNewField1: TTBItem
            Action = ObjectNewField
          end
          object ObjectNewConstraint1: TTBItem
            Action = ObjectNewConstraint
          end
          object ObjectNewIndex1: TTBItem
            Action = ObjectNewIndex
          end
          object ObjectNewTrigger1: TTBItem
            Action = ObjectNewTrigger
          end
          object ObjectNewInputParam1: TTBItem
            Action = ObjectNewInputParam
          end
        end
        object DropObject1: TTBSubmenuItem
          Caption = 'D&rop'
          object ObjectDropField1: TTBItem
            Action = ObjectDropField
          end
          object ObjectDropConstraint1: TTBItem
            Action = ObjectDropConstraint
          end
          object ObjectDropIndex1: TTBItem
            Action = ObjectDropIndex
          end
          object ObjectDropTrigger1: TTBItem
            Action = ObjectDropTrigger
          end
          object ObjectDropInputParam1: TTBItem
            Action = ObjectDropInputParam
          end
        end
        object Drop1: TTBItem
          Action = ObjectDrop
        end
        object Properties1: TTBItem
          Action = ObjectProperties
        end
        object N30: TTBSeparatorItem
        end
        object Tools5: TTBSubmenuItem
          Caption = '&Tools'
          object ObjectShowPerformanceData1: TTBItem
            Action = ObjectShowPerformanceData
          end
          object ObjectShowQueryPlan1: TTBItem
            Action = ObjectShowQueryPlan
          end
          object N36: TTBSeparatorItem
          end
          object ObjectReorderColumns1: TTBItem
            Action = ObjectReorderColumns
          end
          object ObjectResetGeneratorValue1: TTBItem
            Action = ObjectResetGeneratorValue
          end
        end
        object Permissions1: TTBSubmenuItem
          Caption = '&Permissions'
          object ObjectGrant1: TTBItem
            Action = ObjectGrant
          end
          object ObjectRevoke1: TTBItem
            Action = ObjectRevoke
          end
        end
        object N32: TTBSeparatorItem
        end
        object AddToProject1: TTBItem
          Action = ObjectAddToProject
        end
        object ObjectSaveDocumentation1: TTBItem
          Action = ObjectSaveDocumentation
        end
        object ObjectSaveAsTemplate1: TTBItem
          Action = ObjectSaveAsTemplate
        end
      end
      object Script1: TTBSubmenuItem
        Tag = -1
        Caption = '&Script'
        GroupIndex = 10
        object RecordNewScript1: TTBItem
          Tag = -2
          Action = ScriptRecordScript
        end
        object N37: TTBSeparatorItem
        end
        object AppendtoExistingScript1: TTBItem
          Tag = -2
          Action = ScriptAppendExisting
        end
        object NewScript1: TTBItem
          Action = ScriptNewScript
        end
        object N14: TTBSeparatorItem
          Tag = -2
        end
        object Record1: TTBItem
          Tag = -2
          Action = ScriptStartRecord
        end
        object Stop1: TTBItem
          Tag = -2
          Action = ScriptStopRecord
        end
      end
      object Tools1: TTBSubmenuItem
        Tag = -1
        Caption = '&Tools'
        GroupIndex = 10
        object SQLEditor1: TTBItem
          Tag = -2
          Action = ToolsSQLEditor
        end
        object UserEditor1: TTBItem
          Action = ToolsUserEditor
        end
        object N16: TTBSeparatorItem
          Tag = -2
        end
        object MetadataExtract1: TTBItem
          Tag = -2
          Action = ToolsMetaExtract
        end
        object SearchMetadata1: TTBItem
          Tag = -2
          Action = ToolsMetaSearch
        end
        object N13: TTBSeparatorItem
          Tag = -2
        end
        object SyntaxHelp1: TTBItem
          Tag = -2
          Action = ToolsSyntaxHelp
        end
        object SQLCodeSnippets1: TTBItem
          Tag = -2
          Action = ToolsSQLCodeSnippets
        end
        object N15: TTBSeparatorItem
          Tag = -2
        end
        object SQLTrace1: TTBItem
          Tag = -2
          Action = ToolsSQLTrace
        end
        object N7: TTBSeparatorItem
          Tag = -2
        end
        object Plugins1: TTBItem
          Action = ToolsPlugins
        end
        object N35: TTBSeparatorItem
        end
        object DebuggerEnabled1: TTBItem
          Action = ObjectDebuggerEnabled
        end
        object Options1: TTBItem
          Tag = -2
          Action = ToolsMarathonOptions
        end
      end
      object Window1: TTBSubmenuItem
        Tag = -1
        Caption = '&Window'
        GroupIndex = 10
        OnClick = Window1Click
        object WindowList2: TTBItem
          Tag = -2
          Action = WindowWindowList
        end
        object CloseAllWindows1: TTBItem
          Action = WindowCloseAllWindows
        end
        object N9: TTBSeparatorItem
          Tag = -2
        end
      end
      object Help1: TTBSubmenuItem
        Tag = -1
        Caption = '&Help'
        GroupIndex = 10
        object HelpTopics1: TTBItem
          Tag = -2
          Action = HelpHelpTopics
        end
        object N11: TTBSeparatorItem
        end
        object MarathonOntheWeb1: TTBItem
          Action = HelpMarathonOnTheWeb
          Caption = '&Marathon at Sourceforge...'
          Hint = 'Go to Marathon at Sourceforge'
        end
        object EmailMarathonSupport1: TTBItem
          Action = HelpEmailSupport
        end
        object N8: TTBSeparatorItem
          Tag = -2
        end
        object About1: TTBItem
          Tag = -2
          Action = HelpAbout
        end
      end
    end
  end
  object stsMain: TStatusBar
    Left = 0
    Top = 107
    Width = 728
    Height = 22
    Panels = <
      item
        Width = 500
      end>
  end
  object rmPanel1: TrmPanel
    Left = 0
    Top = 75
    Width = 728
    Height = 25
    Align = alTop
    ParentBackground = True
    TabOrder = 2
    object Bevel1: TBevel
      Left = 0
      Top = 0
      Width = 728
      Height = 3
      Align = alTop
      Shape = bsSpacer
    end
    object tabWindows: TrmTabSet
      Left = 0
      Top = 3
      Width = 728
      Height = 22
      Align = alTop
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      TabHeight = 19
      Tabs.Strings = (
        'One'
        'Two')
      TabIndex = 0
      TabLocation = tlBottom
      TabType = ttGradient
      OnChange = tabWindowsChange
    end
  end
  object prnSetup: TPrinterSetupDialog
    Left = 446
    Top = 68
  end
  object dlgOpen: TSaveDialog
    DefaultExt = '*.sql'
    Filter = 
      'SQL Files (*.sql)|*.sql|Text Files (*.txt)|*.txt|All Files (*.*)' +
      '|*.*'
    Options = [ofHideReadOnly, ofPathMustExist]
    Title = 'Record New Script'
    Left = 582
    Top = 68
  end
  object ilMarathonImages: TImageList
    Left = 389
    Top = 68
    Bitmap = {
      494C01010E001300040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000005000000001002000000000000050
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000008000000080000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000080
      000000FF000000FF000000800000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C00000FF
      000000FF000000FF000000FF0000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C00000FF
      000000FF000000FF000000FF0000008000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000080808000FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C00000FF000000FF0000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000808080000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000808080000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000080808000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000080808000808080008080800080808000808080008080800080808000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00800000008000000000000000FFFFFF000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF0000000000000000000000000000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF00000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00800000008000000000000000FFFFFF000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      000080808000000000000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C0000000000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00800000008000000000000000FFFFFF000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000008080800000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      00000000000000000000808080000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000808080000000000000FF000000FF000000FF000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C000000000000000FF000000
      0000C0C0C000C0C0C000C0C0C000C0C0C0000000000000000000800000008000
      0000000000008000000080000000800000008000000080000000800000008000
      0000800000008000000000000000000000000000000000000000000000000000
      00000000000000000000808080000000000000000000FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000808080000000000000FF000000FF000000FF000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000FFFF0000FF00
      0000FFFF0000FF000000FFFF0000FF000000FFFF0000FF000000FFFF0000FF00
      0000FFFF0000FF00000000000000000000000000000000000000000000000000
      000000000000000000000000000080808000FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000808080000000000000FF000000FF000000FF000000FF
      000000FF000000FF000000FF0000000000000000000000000000000000000000
      00000000000000000000C0C0C000000000000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF00000000000000000000000000FF000000FFFF
      0000FF000000FFFF0000FF000000FFFF0000FF000000FFFF0000FF000000FFFF
      0000FF000000FFFF000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008080800000000000000000000000000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000000000000000FF000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000008080800080808000808080000000000000FF000000FF
      000000FF00000000000080808000808080000000000000000000000000000000
      000000000000000000000000000000000000C0C0C000000000000000FF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008080800000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      000000000000000000000000000000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF0000000000FFFF0000FFFF000000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF0000000000000000000000000000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF0000000000000000000000000000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF000000000000000000000000000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      0000000000000000FF00C0C0C0000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000FF000000FF00FFFF00000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000808080008080800080808000808080000000000000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C000000000000000
      8000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C000000000000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C0000000
      80000000FF000000FF00C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000FF00FFFF
      FF000000FF000000FF000000FF000000FF000000000000000000000000008080
      800000000000FFFF0000FFFF0000C0C0C000FFFF0000FFFF0000FFFF00000000
      80000000FF000000FF00FFFF0000000000000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000C0C0C0000000
      0000000000000000000000000000000000000000000000000000000000008080
      800000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000808080000000FF000000FF000000FF000000FF000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000008080
      800000000000FFFF0000FFFF0000C0C0C000FFFF0000FFFF0000000080000000
      80000000FF000000FF00FFFF0000000000000000000000000000000000000000
      0000C0C0C00000000000FFFFFF00FFFFFF00000000000000000000000000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000008080
      800000000000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000808080000000FF000000FF000000FF00FFFF
      FF000000FF000000FF000000FF00000000000000000000000000000000008080
      800000000000FFFF0000FFFF0000C0C0C000FFFF0000FFFF0000000080000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      0000C0C0C00000000000FFFF0000FFFFFF00000000000000000000000000FFFF
      0000FFFFFF000000000000000000000000000000000000000000000000008080
      800000000000FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000000000000000000000000000808080000000FF000000FF00FFFF
      FF000000FF000000FF0000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000080000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      000000000000C0C0C00000000000000000000000000000000000C0C0C0000000
      000000000000C0C0C00000000000000000000000000000000000000000008080
      800000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000808080000000FF00FFFF
      FF000000FF000000000000000000000000000000000000000000000000008080
      800000000000FF000000FF000000FF000000FF000000FF000000000080000000
      FF000000FF000000FF000000FF00000000000000000000000000000000000000
      00000000000000000000C0C0C00000000000C0C0C00000000000000000000000
      00000000000000000000C0C0C000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000808080000000FF000000
      FF000000FF000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      80000000FF000000FF0000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C0000000000000000000000000000000
      0000000000000000000000000000C0C0C0000000000000000000000000008080
      8000808080008080800080808000808080008080800080808000808080008080
      8000808080008080800080808000808080000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000808080000000
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000808080008080800080808000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000000000FFFFFF00FFFFFF00000000000000
      0000808080008080800000000000000000000000000000000000000000000000
      000000000000000000008080800000000000C0C0C000FFFFFF00FFFFFF00C0C0
      C000808080000000000080808000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000000000000FFFF00FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000C0C0C000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00C0C0C00080808000000000000000000000000000C0C0C000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF000000000000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00C0C0
      C00080808000C0C0C0000000000000000000C0C0C0000000000000FFFF000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      00000000000000FFFF0000FFFF00000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C0C0C000C0C0C00000000000FFFFFF00FFFFFF0000FFFF000000
      000000000000000000000000000000000000000000008080800000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C000808080000000000080808000FFFFFF00FFFF
      FF00C0C0C000808080000000000000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF0000000000FFFFFF0000FFFF0000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF0000000000FFFF0000FFFF000000000000000000000000000000000000C0C0
      C000FFFFFF00FFFFFF00C0C0C0000000000000000000000000000000000000FF
      FF00000000000000000000000000000000000000000000000000C0C0C000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C0C0C0008080800000000000FFFFFF00C0C0
      C00080808000C0C0C000000000000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      000000000000FFFFFF0000FFFF000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      000000000000C0C0C000C0C0C0000000000000000000C0C0C000C0C0C0000000
      000000000000FFFFFF00C0C0C0000000000000FFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000080808000C0C0
      C000FFFFFF00FFFFFF00C0C0C00080808000C0C0C00000000000000000000000
      00000000000080808000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000FFFFFF00FFFFFF0000FFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000FFFF0000FFFF0000FFFF00000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000C0C0C000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00C0C0C0008080800000000000FF000000FF00
      0000FF000000000000000000000000000000C0C0C00000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C00000000000FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C00000000000C0C0
      C000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      0000C0C0C000C0C0C00000000000FFFFFF00C0C0C000C0C0C000000000008080
      800000000000FFFFFF000000000000000000000000000000000080808000C0C0
      C000FFFFFF00FFFFFF00C0C0C00080808000C0C0C00000000000FF000000FF00
      0000FF000000FF0000000000000000000000C0C0C00000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000FFFFFF0000FF
      FF00FFFFFF00FFFFFF0000FFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C0C0C000C0C0
      C000C0C0C000C0C0C000C0C0C000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000C0C0C0000000000000000000000000000000000000000000C0C0C0000000
      0000000000000000000000000000000000008080800000000000FF000000FF00
      0000FF000000000000000000000000000000C0C0C0000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000000000008080
      800000000000FFFF0000FFFF0000C0C0C000FFFF0000FFFF0000FFFF0000C0C0
      C000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      00000000000000000000FFFFFF008080800000000000FFFFFF00FFFFFF000000
      000000000000C0C0C0000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      000000000000000000000000000000000000C0C0C00000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FF
      FF00FFFFFF00FFFFFF0000FFFF00000000000000000000000000000000008080
      800000000000FFFF0000FFFF0000C0C0C000FFFF0000FFFF0000FFFF0000C0C0
      C000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      00000000000000000000C0C0C000C0C0C0000000000000000000C0C0C0000000
      0000808080008080800000000000000000000000000000000000FFFF0000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF0000FFFF000000000000000000000000
      000000000000000000000000000000000000C0C0C0000000000000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00000000000000000000000000000000008080
      800000000000FFFF0000FFFF0000C0C0C000FFFF0000FFFF0000FFFF0000C0C0
      C000FFFF0000FFFF0000FFFF0000000000000000000000000000000000000000
      00000000000000000000FFFFFF0000000000C0C0C00000000000000000008080
      800000000000FFFFFF000000000000000000000000000000000000000000FFFF
      0000FFFF0000FFFF0000FFFF0000FFFF00000000000000000000000000000000
      000000000000000000000000000000000000C0C0C00000000000FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF000000000080808000C0C0C000FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000C0C0C00000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      800000000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF0000008080800080808000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF0080808000C0C0C000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C0C0C000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008080
      8000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000500000000100010000000000800200000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFF300000000FFFFFFE100000000
      FFFFFFC000000000FFFFFFC000000000FE7FFFE100000000FDBFFFF300000000
      FDBFFFFF00000000FBDFFFFF00000000FBDFFFFF00000000F7EFFFFF00000000
      F00FFFFF00000000FFFFFFFF00000000FFFFFFFF00000000FFFFFFFF00000000
      FFFFFFFF00000000FFFFFFFF00000000FC01FC01FFFFFFFFF123F123FFFFFFFF
      F217F2178001FFFFF127F1278001FFFFE017E0178001FFFF000700078001F00F
      000700078001F7EF0003000F8001FBDF8003801F8001FBDFE000E00F8001FDBF
      FC00FF008001FDBFFC00FE008001FE7FFC00FC008001FFFFFC00FE008001FFFF
      FC00FF0FFFFFFFFFFF03FF8FFFFFFFFFFC01FC01FC01FC01F123F123F123F123
      F217F217F217F217F127F127F127F127E010E017E017E0170000000700070007
      00000007000700070000000F000F00008000801F801F8000E000E03FE000E000
      E000F8C7E000FC00E000F043E000FE01E000F003E000FF03E000F8C1E000FF87
      E000FC3CE000FF87E000FE3EE000FFCFFFFFFC01FC01FC01FF07F123F123F123
      FC01F217F217F217FC018121F127F127E0010010E010E0178001000000000007
      80010000000000078001000000000003800100008000800180010000E000E003
      80030000E000F80180070000E000F801803F0000E000FC03C07F0000E000FC03
      E0FF0001E000FE07FFFF83FFE000FF9F00000000000000000000000000000000
      000000000000}
  end
  object ilErrorInfo: TImageList
    Left = 417
    Top = 68
  end
  object actMain: TActionList
    Images = imgMenuTools
    Left = 276
    Top = 68
    object FileNewProject: TAction
      Category = 'File'
      Caption = '&New Project...'
      Hint = 'New Project'
      ImageIndex = 0
      OnExecute = FileNewProjectExecute
    end
    object FileOpenProject: TAction
      Category = 'File'
      Caption = '&Open Project...'
      Hint = 'Open Project'
      ImageIndex = 1
      OnExecute = FileOpenProjectExecute
    end
    object FileCloseProject: TAction
      Category = 'File'
      Caption = 'C&lose Project'
      Hint = 'Close Project'
      ImageIndex = 2
      OnExecute = FileCloseProjectExecute
      OnUpdate = FileCloseProjectUpdate
    end
    object FileConnect: TAction
      Category = 'File'
      Caption = '&Connect'
      Hint = 'Connect to Database'
      ImageIndex = 3
      OnExecute = FileConnectExecute
      OnUpdate = FileConnectUpdate
    end
    object FileDisconnect: TAction
      Category = 'File'
      Caption = '&Disconnect'
      Hint = 'Disconnect from Database'
      ImageIndex = 4
      OnExecute = FileDisconnectExecute
      OnUpdate = FileDisconnectUpdate
    end
    object FileNewObject: TAction
      Category = 'File'
      Caption = 'Ne&w...'
      Hint = 'New Object'
      OnExecute = FileNewObjectExecute
      OnUpdate = FileNewObjectUpdate
    end
    object FileCreateDatabase: TAction
      Category = 'File'
      Caption = 'Cre&ate Database...'
      Hint = 'Create an Firebird or InterBase Database'
      OnExecute = FileCreateDatabaseExecute
    end
    object FilePrintSetup: TAction
      Category = 'File'
      Caption = 'Prin&t Setup...'
      Hint = 'Modify Printer Settings'
      OnExecute = FilePrintSetupExecute
    end
    object FileExitApplication: TAction
      Category = 'File'
      Caption = 'E&xit'
      Hint = 'Exit Marathon'
      OnExecute = FileExitApplicationExecute
    end
    object ViewViewBrowser: TAction
      Category = 'View'
      Caption = '&View Browser...'
      Hint = 'View Browser'
      ImageIndex = 5
      ShortCut = 122
      OnExecute = ViewViewBrowserExecute
    end
    object ToolsSQLEditor: TAction
      Category = 'Tools'
      Caption = '&SQL Editor...'
      Hint = 'SQL Editor'
      ImageIndex = 6
      ShortCut = 49235
      OnExecute = ToolsSQLEditorExecute
    end
    object ProjectProjectOptions: TAction
      Category = 'Project'
      Caption = 'Project &Options...'
      Hint = 'Modify Project Options'
      OnExecute = ProjectProjectOptionsExecute
      OnUpdate = ProjectProjectOptionsUpdate
    end
    object ViewNextWindow: TAction
      Category = 'View'
      Caption = '&Next Window'
      Hint = 'View Next Window'
      ShortCut = 123
      OnExecute = ViewNextWindowExecute
    end
    object ScriptRecordScript: TAction
      Category = 'Script'
      Caption = '&Script Recording...'
      Hint = 'Record activity to a script'
      ImageIndex = 10
      OnExecute = ScriptRecordScriptExecute
      OnUpdate = ScriptRecordScriptUpdate
    end
    object ScriptStartRecord: TAction
      Category = 'Script'
      Caption = 'R&ecord'
      Hint = 'Start Recording Script'
      OnExecute = ScriptStartRecordExecute
      OnUpdate = ScriptStartRecordUpdate
    end
    object ScriptStopRecord: TAction
      Category = 'Script'
      Caption = 'S&top'
      Hint = 'Stop Recording Script'
      OnExecute = ScriptStopRecordExecute
      OnUpdate = ScriptStopRecordUpdate
    end
    object ToolsMetaExtract: TAction
      Category = 'Tools'
      Caption = '&Metadata Extract...'
      Hint = 'Extract Metadata from Database'
      OnExecute = ToolsMetaExtractExecute
    end
    object ToolsMetaSearch: TAction
      Category = 'Tools'
      Caption = 'Metadata S&earch...'
      Hint = 'Search in Database Metadata'
      ImageIndex = 15
      OnExecute = ToolsMetaSearchExecute
    end
    object ToolsSyntaxHelp: TAction
      Category = 'Tools'
      Caption = 'actSyntaxHelp'
      Visible = False
      OnExecute = ToolsSyntaxHelpExecute
    end
    object ToolsSQLCodeSnippets: TAction
      Category = 'Tools'
      Caption = 'SQL &Code Snippets...'
      Hint = 'Open Code Snippets Catalog'
      ImageIndex = 8
      OnExecute = ToolsSQLCodeSnippetsExecute
    end
    object ToolsSQLTrace: TAction
      Category = 'Tools'
      Caption = 'SQL &Trace...'
      Hint = 'Trace SQL Sent to Server'
      ImageIndex = 9
      OnExecute = ToolsSQLTraceExecute
    end
    object ToolsMarathonOptions: TAction
      Category = 'Tools'
      Caption = '&Options...'
      Hint = 'Marathon Environment Options'
      OnExecute = ToolsMarathonOptionsExecute
    end
    object WindowWindowList: TAction
      Category = 'Window'
      Caption = '&Window List...'
      OnExecute = WindowWindowListExecute
    end
    object HelpHelpTopics: TAction
      Category = 'Help'
      Caption = '&Help Topics...'
      Hint = 'Help Topics'
      OnExecute = HelpHelpTopicsExecute
    end
    object HelpMarathonOnTheWeb: TAction
      Category = 'Help'
      Caption = '&Marathon on the Web...'
      Hint = 'Go to Marathon Web Page'
      OnExecute = HelpMarathonOnTheWebExecute
    end
    object HelpEmailSupport: TAction
      Category = 'Help'
      Caption = '&Email Marathon Support...'
      Hint = 'Email a Support Request'
      OnExecute = HelpEmailSupportExecute
    end
    object HelpAbout: TAction
      Category = 'Help'
      Caption = '&About...'
      Hint = 'About Marathon'
      OnExecute = HelpAboutExecute
    end
    object FileSaveProject: TAction
      Category = 'File'
      Caption = '&Save Project'
      OnExecute = FileSaveProjectExecute
      OnUpdate = FileSaveProjectUpdate
    end
    object FileSaveProjectAs: TAction
      Category = 'File'
      Caption = 'Save Project &As...'
      OnExecute = FileSaveProjectAsExecute
      OnUpdate = FileSaveProjectAsUpdate
    end
    object FilePrint: TAction
      Category = 'File'
      Caption = '&Print'
      Hint = 'Print'
      ImageIndex = 13
      OnExecute = FilePrintExecute
      OnUpdate = FilePrintUpdate
    end
    object FilePrintPreview: TAction
      Category = 'File'
      Caption = 'Print Pre&view...'
      Hint = 'Print Preview'
      ImageIndex = 14
      OnExecute = FilePrintPreviewExecute
      OnUpdate = FilePrintPreviewUpdate
    end
    object EditUndo: TAction
      Category = 'Edit'
      Caption = '&Undo'
      Hint = 'Undo'
      ImageIndex = 22
      ShortCut = 16474
      OnExecute = EditUndoExecute
      OnUpdate = EditUndoUpdate
    end
    object EditRedo: TAction
      Category = 'Edit'
      Caption = '&Redo'
      Hint = 'Redo'
      ImageIndex = 23
      OnExecute = EditRedoExecute
      OnUpdate = EditRedoUpdate
    end
    object EditCaptureSnippet: TAction
      Category = 'Edit'
      Caption = 'Capture &Snippet...'
      Hint = 'Capture Snippet'
      ImageIndex = 24
      OnExecute = EditCaptureSnippetExecute
      OnUpdate = EditCaptureSnippetUpdate
    end
    object EditCut: TAction
      Category = 'Edit'
      Caption = 'Cu&t'
      Hint = 'Cut'
      ImageIndex = 19
      ShortCut = 16472
      OnExecute = EditCutExecute
      OnUpdate = EditCutUpdate
    end
    object EditCopy: TAction
      Category = 'Edit'
      Caption = '&Copy'
      Hint = 'Copy'
      ImageIndex = 20
      ShortCut = 16451
      OnExecute = EditCopyExecute
      OnUpdate = EditCopyUpdate
    end
    object EditPaste: TAction
      Category = 'Edit'
      Caption = '&Paste'
      Hint = 'Paste'
      ImageIndex = 21
      ShortCut = 16470
      OnExecute = EditPasteExecute
      OnUpdate = EditPasteUpdate
    end
    object EditFind: TAction
      Category = 'Edit'
      Caption = '&Find...'
      Hint = 'Find'
      ImageIndex = 7
      ShortCut = 16454
      OnExecute = EditFindExecute
      OnUpdate = EditFindUpdate
    end
    object ObjectCompile: TAction
      Category = 'Object'
      Caption = '&Compile'
      Hint = 'Compile'
      ImageIndex = 16
      ShortCut = 16504
      OnExecute = ObjectCompileExecute
      OnUpdate = ObjectCompileUpdate
    end
    object ObjectExecute: TAction
      Category = 'Object'
      Caption = '&Execute'
      Hint = 'Execute'
      ImageIndex = 17
      ShortCut = 120
      OnExecute = ObjectExecuteExecute
      OnUpdate = ObjectExecuteUpdate
    end
    object TransactionCommit: TAction
      Category = 'Transaction'
      Caption = '&Commit'
      Hint = 'Commit'
      ShortCut = 49219
      OnExecute = TransactionCommitExecute
      OnUpdate = TransactionCommitUpdate
    end
    object TransactionRollback: TAction
      Category = 'Transaction'
      Caption = '&Rollback'
      Hint = 'Rollback'
      ShortCut = 49234
      OnExecute = TransactionRollbackExecute
      OnUpdate = TransactionRollbackUpdate
    end
    object ToolsEditorProperties: TAction
      Category = 'Tools'
      Caption = '&Properties...'
      ImageIndex = 25
      OnExecute = ToolsEditorPropertiesExecute
      OnUpdate = ToolsEditorPropertiesUpdate
    end
    object EditSelectAll: TAction
      Category = 'Edit'
      Caption = 'Select &All'
      Hint = 'Select All'
      OnExecute = EditSelectAllExecute
      OnUpdate = EditSelectAllUpdate
    end
    object EditFindNext: TAction
      Category = 'Edit'
      Caption = 'Find &Next'
      Hint = 'Find Next'
      ShortCut = 114
      OnExecute = EditFindNextExecute
      OnUpdate = EditFindNextUpdate
    end
    object EditReplace: TAction
      Category = 'Edit'
      Caption = '&Replace...'
      Hint = 'Replace'
      ShortCut = 16466
      OnExecute = EditReplaceExecute
      OnUpdate = EditReplaceUpdate
    end
    object EditEncANSI: TAction
      Tag = 1
      Category = 'Edit'
      Caption = '&ANSI'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncDefault: TAction
      Tag = 2
      Category = 'Edit'
      Caption = '&Default'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncSymbol: TAction
      Tag = 3
      Category = 'Edit'
      Caption = 'S&ymbol'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EncMacintosh: TAction
      Tag = 4
      Category = 'Edit'
      Caption = '&Macintosh'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncSHIFTJIS: TAction
      Tag = 5
      Category = 'Edit'
      Caption = '&Japanese'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncHANGEUL: TAction
      Tag = 6
      Category = 'Edit'
      Caption = 'Korean (&Wansung)'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncJOHAB: TAction
      Tag = 7
      Category = 'Edit'
      Caption = 'K&orean (Johab)'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncGB2312: TAction
      Tag = 8
      Category = 'Edit'
      Caption = '&Chinese (Simplified)'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncCHINESEBIG5: TAction
      Tag = 9
      Category = 'Edit'
      Caption = 'Chinese (&Traditional)'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncGreek: TAction
      Tag = 10
      Category = 'Edit'
      Caption = '&Greek'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncTurkish: TAction
      Tag = 11
      Category = 'Edit'
      Caption = 'T&urkish'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncVietnamese: TAction
      Tag = 12
      Category = 'Edit'
      Caption = '&Vietnamese'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncHebrew: TAction
      Tag = 13
      Category = 'Edit'
      Caption = '&Hebrew'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncArabic: TAction
      Tag = 14
      Category = 'Edit'
      Caption = 'Ara&bic'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncBaltic: TAction
      Tag = 15
      Category = 'Edit'
      Caption = '&Baltic'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncRussian: TAction
      Tag = 16
      Category = 'Edit'
      Caption = 'Ru&ssian'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncThai: TAction
      Tag = 17
      Category = 'Edit'
      Caption = 'Tha&i'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncEasternEuropean: TAction
      Tag = 18
      Category = 'Edit'
      Caption = 'Easte&rn European'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object EditEncOEM: TAction
      Tag = 19
      Category = 'Edit'
      Caption = 'O&EM'
      OnExecute = EditEncANSIExecute
      OnUpdate = EditEncANSIUpdate
    end
    object ToolsUserEditor: TAction
      Category = 'Tools'
      Caption = '&User Editor...'
      Enabled = False
      Visible = False
      OnExecute = ToolsUserEditorExecute
    end
    object WindowCloseAllWindows: TAction
      Category = 'Window'
      Caption = '&Close All Windows'
      OnExecute = WindowCloseAllWindowsExecute
    end
    object ViewToolbarTools: TAction
      Category = 'View'
      Caption = '&Tools'
      Checked = True
      OnExecute = ViewToolbarToolsExecute
      OnUpdate = ViewToolbarToolsUpdate
    end
    object ViewToolbarScript: TAction
      Category = 'View'
      Caption = '&Script'
      Checked = True
      OnExecute = ViewToolbarScriptExecute
      OnUpdate = ViewToolbarScriptUpdate
    end
    object ViewToolbarStandard: TAction
      Category = 'View'
      Caption = 'S&tandard'
      Checked = True
      OnExecute = ViewToolbarStandardExecute
      OnUpdate = ViewToolbarStandardUpdate
    end
    object ViewToolbarSQLEditor: TAction
      Category = 'View'
      Caption = 'SQL &Editor'
      Checked = True
      OnExecute = ViewToolbarSQLEditorExecute
      OnUpdate = ViewToolbarSQLEditorUpdate
    end
    object ToolsQueryBuilder: TAction
      Category = 'Tools'
      Caption = '&Query Builder...'
      Hint = 'Query Builder'
      ImageIndex = 26
    end
    object ViewPrevStatement: TAction
      Category = 'View'
      Caption = '&Previous Statement'
      Hint = 'Previous Statement'
      ImageIndex = 27
      ShortCut = 49232
      OnExecute = ViewPrevStatementExecute
      OnUpdate = ViewPrevStatementUpdate
    end
    object ViewNextStatement: TAction
      Category = 'View'
      Caption = '&Next Statement'
      Hint = 'Next Statement'
      ImageIndex = 28
      ShortCut = 49230
      OnExecute = ViewNextStatementExecute
      OnUpdate = ViewNextStatementUpdate
    end
    object ViewStatementHistory: TAction
      Category = 'View'
      Caption = 'Statement &History...'
      Hint = 'Statement History'
      ImageIndex = 29
      ShortCut = 49224
      OnExecute = ViewStatementHistoryExecute
      OnUpdate = ViewStatementHistoryUpdate
    end
    object FileOpenFile: TAction
      Category = 'File'
      Caption = 'Open &File...'
      OnExecute = FileOpenFileExecute
    end
    object FileOpenDatabaseObject: TAction
      Category = 'File'
      Caption = 'Database &Object...'
      OnExecute = FileOpenDatabaseObjectExecute
      OnUpdate = FileOpenDatabaseObjectUpdate
    end
    object FileClose: TAction
      Category = 'File'
      Caption = 'C&lose'
      OnExecute = FileCloseExecute
      OnUpdate = FileCloseUpdate
    end
    object FileLoad: TAction
      Category = 'File'
      Caption = 'L&oad from file'
      OnExecute = FileLoadExecute
      OnUpdate = FileLoadUpdate
    end
    object ProjectNewConnection: TAction
      Category = 'Project'
      Caption = '&New Connection...'
      OnExecute = ProjectNewConnectionExecute
      OnUpdate = ProjectNewConnectionUpdate
    end
    object ProjectOpenItem: TAction
      Category = 'Project'
      Caption = '&Open'
      OnExecute = ProjectOpenItemExecute
      OnUpdate = ProjectOpenItemUpdate
    end
    object ProjectItemProperties: TAction
      Category = 'Project'
      Caption = '&Properties...'
      OnExecute = ProjectItemPropertiesExecute
      OnUpdate = ProjectItemPropertiesUpdate
    end
    object ProjectItemDelete: TAction
      Category = 'Project'
      Caption = '&Delete'
      OnExecute = ProjectItemDeleteExecute
      OnUpdate = ProjectItemDeleteUpdate
    end
    object ProjectItemDrop: TAction
      Category = 'Project'
      Caption = 'D&rop'
      OnExecute = ProjectItemDropExecute
      OnUpdate = ProjectItemDropUpdate
    end
    object ViewRefresh: TAction
      Category = 'View'
      Caption = '&Refresh'
      ShortCut = 116
      OnExecute = ViewRefreshExecute
      OnUpdate = ViewRefreshUpdate
    end
    object ProjectExtractMetadata: TAction
      Category = 'Project'
      Caption = 'E&xtract Metadata...'
      OnExecute = ProjectExtractMetadataExecute
      OnUpdate = ProjectExtractMetadataUpdate
    end
    object ProjectCreateFolder: TAction
      Category = 'Project'
      Caption = '&Create Folder...'
      OnExecute = ProjectCreateFolderExecute
      OnUpdate = ProjectCreateFolderUpdate
    end
    object ProjectAddToProject: TAction
      Category = 'Project'
      Caption = '&Add To Project...'
      OnExecute = ProjectAddToProjectExecute
      OnUpdate = ProjectAddToProjectUpdate
    end
    object ViewNextPage: TAction
      Category = 'View'
      Caption = 'Next &Page'
      OnExecute = ViewNextPageExecute
      OnUpdate = ViewNextPageUpdate
    end
    object ViewPrevPage: TAction
      Category = 'View'
      Caption = 'Pre&vious Page'
      OnExecute = ViewPrevPageExecute
      OnUpdate = ViewPrevPageUpdate
    end
    object ViewMessages: TAction
      Category = 'View'
      Caption = '&Messages'
      ShortCut = 49229
      OnExecute = ViewMessagesExecute
      OnUpdate = ViewMessagesUpdate
    end
    object EditClearEditBuffer: TAction
      Category = 'Edit'
      Caption = 'Clear Edit &Buffer'
      OnExecute = EditClearEditBufferExecute
      OnUpdate = EditClearEditBufferUpdate
    end
    object EditToggleBookmark0: TAction
      Category = 'Edit'
      Caption = 'Bookmark &0'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark1: TAction
      Tag = 1
      Category = 'Edit'
      Caption = 'Bookmark &1'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark2: TAction
      Tag = 2
      Category = 'Edit'
      Caption = 'Bookmark &2'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark3: TAction
      Tag = 3
      Category = 'Edit'
      Caption = 'Bookmark &3'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark4: TAction
      Tag = 4
      Category = 'Edit'
      Caption = 'Bookmark &4'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark5: TAction
      Tag = 5
      Category = 'Edit'
      Caption = 'Bookmark &5'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark6: TAction
      Tag = 6
      Category = 'Edit'
      Caption = 'Bookmark &6'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark7: TAction
      Tag = 7
      Category = 'Edit'
      Caption = 'Bookmark &7'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark8: TAction
      Tag = 8
      Category = 'Edit'
      Caption = 'Bookmark &8'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditToggleBookmark9: TAction
      Tag = 9
      Category = 'Edit'
      Caption = 'Bookmark &9'
      OnExecute = EditToggleBookmark1Execute
      OnUpdate = EditToggleBookmark1Update
    end
    object EditGotoBookmark0: TAction
      Category = 'Edit'
      Caption = 'Bookmark &0'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark1: TAction
      Tag = 1
      Category = 'Edit'
      Caption = 'Bookmark &1'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark2: TAction
      Tag = 2
      Category = 'Edit'
      Caption = 'Bookmark &2'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark3: TAction
      Tag = 3
      Category = 'Edit'
      Caption = 'Bookmark &3'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark4: TAction
      Tag = 4
      Category = 'Edit'
      Caption = 'Bookmark &4'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark5: TAction
      Tag = 5
      Category = 'Edit'
      Caption = 'Bookmark &5'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark6: TAction
      Tag = 6
      Category = 'Edit'
      Caption = 'Bookmark &6'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark7: TAction
      Tag = 7
      Category = 'Edit'
      Caption = 'Bookmark &7'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark8: TAction
      Tag = 8
      Category = 'Edit'
      Caption = 'Bookmark &8'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object EditGotoBookmark9: TAction
      Tag = 9
      Category = 'Edit'
      Caption = 'Bookmark &9'
      OnExecute = EditGotoBookmark0Execute
      OnUpdate = EditGotoBookmark0Update
    end
    object FileLoadFrom: TAction
      Category = 'File'
      Caption = 'L&oad from file'
      OnExecute = FileLoadFromExecute
      OnUpdate = FileLoadFromUpdate
    end
    object FileSave: TAction
      Category = 'File'
      Caption = '&Save to file'
      OnExecute = FileSaveExecute
      OnUpdate = FileSaveUpdate
    end
    object FileSaveAs: TAction
      Category = 'File'
      Caption = 'Save &As'
      OnExecute = FileSaveAsExecute
      OnUpdate = FileSaveAsUpdate
    end
    object ObjectShowQueryPlan: TAction
      Category = 'Object'
      Caption = '&Show Query Plan'
      OnExecute = ObjectShowQueryPlanExecute
      OnUpdate = ObjectShowQueryPlanUpdate
    end
    object ObjectShowPerformanceData: TAction
      Category = 'Object'
      Caption = 'Show &Performance Query Data...'
      OnExecute = ObjectShowPerformanceDataExecute
      OnUpdate = ObjectShowPerformanceDataUpdate
    end
    object FileExport: TAction
      Category = 'File'
      Caption = '&Export...'
      OnExecute = FileExportExecute
      OnUpdate = FileExportUpdate
    end
    object ObjectParameters: TAction
      Category = 'Object'
      Caption = 'P&arameters...'
      OnExecute = ObjectParametersExecute
      OnUpdate = ObjectParametersUpdate
    end
    object ObjectSaveDocumentation: TAction
      Category = 'Object'
      Caption = 'Save &Documentation'
      OnExecute = ObjectSaveDocumentationExecute
      OnUpdate = ObjectSaveDocumentationUpdate
    end
    object ObjectSaveAsTemplate: TAction
      Category = 'Object'
      Caption = 'Save As &Template...'
      OnExecute = ObjectSaveAsTemplateExecute
      OnUpdate = ObjectSaveAsTemplateUpdate
    end
    object ObjectRevoke: TAction
      Category = 'Object'
      Caption = 'Re&voke...'
      OnExecute = ObjectRevokeExecute
      OnUpdate = ObjectRevokeUpdate
    end
    object ObjectGrant: TAction
      Category = 'Object'
      Caption = '&Grant...'
      OnExecute = ObjectGrantExecute
      OnUpdate = ObjectGrantUpdate
    end
    object ProjectNewItem: TAction
      Category = 'Project'
      Caption = '&New Object'
      OnExecute = ProjectNewItemExecute
      OnUpdate = ProjectNewItemUpdate
    end
    object ObjectDrop: TAction
      Category = 'Object'
      Caption = '&Drop Object'
      Hint = 'Drop'
      ImageIndex = 18
      OnExecute = ObjectDropExecute
      OnUpdate = ObjectDropUpdate
    end
    object ObjectAddToProject: TAction
      Category = 'Object'
      Caption = '&Add To Project...'
      OnExecute = ObjectAddToProjectExecute
      OnUpdate = ObjectAddToProjectUpdate
    end
    object ToolsPlugins: TAction
      Category = 'Tools'
      Caption = '&Plugins...'
      OnExecute = ToolsPluginsExecute
    end
    object ObjectExecuteAsScript: TAction
      Category = 'Object'
      Caption = 'Script &Mode'
      OnExecute = ObjectExecuteAsScriptExecute
      OnUpdate = ObjectExecuteAsScriptUpdate
    end
    object ObjectProperties: TAction
      Category = 'Object'
      Caption = '&Properties...'
      OnExecute = ObjectPropertiesExecute
      OnUpdate = ObjectPropertiesUpdate
    end
    object ObjectDebuggerEnabled: TAction
      Category = 'Object'
      Caption = '&Debugger Enabled'
      OnExecute = ObjectDebuggerEnabledExecute
      OnUpdate = ObjectDebuggerEnabledUpdate
    end
    object ObjectNewField: TAction
      Category = 'Object'
      Caption = '&Field...'
      OnExecute = ObjectNewFieldExecute
      OnUpdate = ObjectNewFieldUpdate
    end
    object ObjectNewConstraint: TAction
      Category = 'Object'
      Caption = '&Constraint...'
      OnExecute = ObjectNewConstraintExecute
      OnUpdate = ObjectNewConstraintUpdate
    end
    object ObjectNewIndex: TAction
      Category = 'Object'
      Caption = '&Index...'
      OnExecute = ObjectNewIndexExecute
      OnUpdate = ObjectNewIndexUpdate
    end
    object ObjectNewTrigger: TAction
      Category = 'Object'
      Caption = '&Trigger...'
      OnExecute = ObjectNewTriggerExecute
      OnUpdate = ObjectNewTriggerUpdate
    end
    object ObjectNewInputParam: TAction
      Category = 'Object'
      Caption = 'New &Input Parameter...'
      OnExecute = ObjectNewInputParamExecute
      OnUpdate = ObjectNewInputParamUpdate
    end
    object ObjectDropField: TAction
      Category = 'Object'
      Caption = '&Field'
      OnExecute = ObjectDropFieldExecute
      OnUpdate = ObjectDropFieldUpdate
    end
    object ObjectDropTrigger: TAction
      Category = 'Object'
      Caption = '&Trigger'
      OnExecute = ObjectDropTriggerExecute
      OnUpdate = ObjectDropTriggerUpdate
    end
    object ObjectDropIndex: TAction
      Category = 'Object'
      Caption = '&Index'
      OnExecute = ObjectDropIndexExecute
      OnUpdate = ObjectDropIndexUpdate
    end
    object ObjectDropConstraint: TAction
      Category = 'Object'
      Caption = '&Constraint'
      OnExecute = ObjectDropConstraintExecute
      OnUpdate = ObjectDropConstraintUpdate
    end
    object ObjectDropInputParam: TAction
      Category = 'Object'
      Caption = 'Remove &Input Parameter'
      OnExecute = ObjectDropInputParamExecute
      OnUpdate = ObjectDropInputParamUpdate
    end
    object ObjectReorderColumns: TAction
      Category = 'Object'
      Caption = '&Reorder Columns..'
      OnExecute = ObjectReorderColumnsExecute
      OnUpdate = ObjectReorderColumnsUpdate
    end
    object ObjectResetGeneratorValue: TAction
      Category = 'Object'
      Caption = 'Reset Generator &Value'
      OnExecute = ObjectResetGeneratorValueExecute
      OnUpdate = ObjectResetGeneratorValueUpdate
    end
    object ObjectStepOver: TAction
      Category = 'Object'
      Caption = 'Step &Over'
      ShortCut = 119
    end
    object ObjectStepInto: TAction
      Category = 'Object'
      Caption = '&Step Into'
      ShortCut = 118
      OnExecute = ObjectStepIntoExecute
      OnUpdate = ObjectStepIntoUpdate
    end
    object ObjectShowExecutionPoint: TAction
      Category = 'Object'
      Caption = 'S&how Execution Point'
      OnExecute = ObjectShowExecutionPointExecute
      OnUpdate = ObjectShowExecutionPointUpdate
    end
    object ObjectPause: TAction
      Category = 'Object'
      Caption = '&Pause'
    end
    object ObjectReset: TAction
      Category = 'Object'
      Caption = 'R&eset'
      ShortCut = 16497
    end
    object ObjectEvalModify: TAction
      Category = 'Object'
      Caption = 'Evaluate/&Modify...'
      ShortCut = 16502
      OnExecute = ObjectEvalModifyExecute
      OnUpdate = ObjectEvalModifyUpdate
    end
    object ObjectAddWatch: TAction
      Category = 'Object'
      Caption = '&Add Watch...'
      OnExecute = ObjectAddWatchExecute
      OnUpdate = ObjectAddWatchUpdate
    end
    object ObjectAddWatchAtCursor: TAction
      Category = 'Object'
      Caption = 'Add &Watch At Cursor'
      ShortCut = 16500
      OnExecute = ObjectAddWatchAtCursorExecute
      OnUpdate = ObjectAddWatchAtCursorUpdate
    end
    object ObjectAddBreakPoint: TAction
      Category = 'Object'
      Caption = 'Add &Break Point...'
      OnExecute = ObjectAddBreakPointExecute
      OnUpdate = ObjectAddBreakPointUpdate
    end
    object ObjectToggleBreakPoint: TAction
      Category = 'Object'
      Caption = 'To&ggle Break Point'
      ShortCut = 116
      OnExecute = ObjectToggleBreakPointExecute
      OnUpdate = ObjectToggleBreakPointUpdate
    end
    object ViewBreakPoints: TAction
      Category = 'View'
      Caption = '&Break Points...'
      OnExecute = ViewBreakPointsExecute
      OnUpdate = ViewBreakPointsUpdate
    end
    object ViewCallStack: TAction
      Category = 'View'
      Caption = '&Call Stack...'
      OnExecute = ViewCallStackExecute
      OnUpdate = ViewCallStackUpdate
    end
    object ViewWatches: TAction
      Category = 'View'
      Caption = '&Watches...'
      OnExecute = ViewWatchesExecute
      OnUpdate = ViewWatchesUpdate
    end
    object ViewLocalVariables: TAction
      Category = 'View'
      Caption = '&Local Variables...'
      OnExecute = ViewLocalVariablesExecute
      OnUpdate = ViewLocalVariablesUpdate
    end
    object ProjectNewServer: TAction
      Category = 'Project'
      Caption = 'New Ser&ver...'
      OnExecute = ProjectNewServerExecute
      OnUpdate = ProjectNewServerUpdate
    end
    object ScriptNewScript: TAction
      Category = 'Script'
      Caption = '&New Script'
      OnExecute = ScriptNewScriptExecute
      OnUpdate = ScriptNewScriptUpdate
    end
    object ScriptAppendExisting: TAction
      Category = 'Script'
      Caption = '&Append to existing Script'
      OnExecute = ScriptAppendExistingExecute
      OnUpdate = ScriptAppendExistingUpdate
    end
    object ViewFolders: TAction
      Category = 'View'
      Caption = '&Folders'
      ImageIndex = 31
      OnExecute = ViewFoldersExecute
      OnUpdate = ViewFoldersUpdate
    end
    object ViewSearch: TAction
      Category = 'View'
      Caption = '&Search'
      ImageIndex = 30
      OnExecute = ViewSearchExecute
      OnUpdate = ViewSearchUpdate
    end
    object ObjectOpenSubObject: TAction
      Category = 'Object'
      Caption = 'Open'
      OnExecute = ObjectOpenSubObjectExecute
      OnUpdate = ObjectOpenSubObjectUpdate
    end
    object ViewList: TAction
      Category = 'View'
      Caption = '&List'
      ImageIndex = 32
      OnExecute = ViewListExecute
      OnUpdate = ViewListUpdate
    end
  end
  object imgMenuTools: TImageList
    Left = 220
    Top = 68
    Bitmap = {
      494C010121002200040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000009000000001002000000000000090
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00840000008400
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008400000084000000FFFF
      FF00FFFFFF00FFFFFF00C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00FF0000008400
      0000FFFFFF000000000000000000FFFFFF00FFFFFF00FF00000084000000FFFF
      FF000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00840000008400
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008400000084000000FFFF
      FF00FFFFFF00FFFFFF00C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00FF0000008400
      0000FFFFFF000000000000000000FFFFFF00FFFFFF00FF00000084000000FFFF
      FF000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00840000008400
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF008400000084000000FFFF
      FF00FFFFFF00FFFFFF00C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00FF0000008400
      0000FFFFFF000000000000000000FFFFFF00FFFFFF00FF00000084000000FFFF
      FF000000000000000000C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000084848400FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00C6C6C600000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000008400000084000000840000008400
      0000840000008400000084000000840000008400000084000000840000008400
      0000840000008400000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FFFF0000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF00
      0000FF000000FF000000FF000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000084
      000000FF000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000084
      00000084000000FF000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000FF0000FFFF000000FF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000084
      0000008400000084000000FF0000C6C6C60000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C6000000000000000000000000000000
      00000000000084840000FF00000084840000FF00000084840000000000000000
      FF00C6C6C6000000FF000000FF00000000000000000000000000000000000000
      000000848400C6C6C60000FFFF0000FFFF0000FFFF0000FFFF000084840000FF
      FF000084840000848400000000000000000000000000FFFFFF00848484008484
      8400C6C6C6000000000000000000000000000000000000000000000000000084
      00000084000000840000008400000000000000000000FFFFFF00848484008484
      8400C6C6C6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008400000084
      000000840000008400008484000000000000000000000000000000000000C6C6
      C6000000FF000000FF0000000000000000000000000000000000000000000000
      000000848400C6C6C600C6C6C60000FFFF0000FFFF0000FFFF0000FFFF000084
      840000FFFF0000848400000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000084
      00000084000000840000FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000840000848400008484
      0000008400000084000084848400848484008484000084840000848400000000
      00000000FF000000000000000000000000000000000000000000000000000000
      000000848400C6C6C60000FFFF00C6C6C60000FFFF0000FFFF0000FFFF0000FF
      FF000084840000848400000000000000000000000000FFFFFF00848484008484
      8400C6C6C60000000000FFFFFF00848484008484840084848400FFFFFF000084
      00000084000084848400FFFFFF000000000000000000FFFFFF00848484008484
      8400C6C6C60000000000FFFFFF00848484008484840084848400FFFFFF008484
      84008484840084848400FFFFFF0000000000000000000084000000FF000000FF
      0000848400008484840084848400C6C6C600FFFF0000FFFF0000848400008484
      0000000000000000000000000000000000000000000000000000000000000000
      000000848400C6C6C600FFFFFF0000FFFF00C6C6C60000FFFF0000FFFF0000FF
      FF0000FFFF0000848400000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000084
      0000FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000840000C6C6C60000FF00008484
      00000084000084848400C6C6C600FFFFFF00C6C6C600C6C6C600FFFF00008484
      0000000000008400000000000000000000000000000000000000000000000000
      000000848400C6C6C60000FFFF00FFFFFF0000FFFF00C6C6C60000FFFF0000FF
      FF0000FFFF0000848400000000000000000000000000FFFFFF00848484008484
      8400C6C6C60000000000FFFFFF00848484008484840084848400FFFFFF008484
      84008484840084848400FFFFFF000000000000000000FFFFFF00848484008484
      8400C6C6C60000000000FFFFFF00848484008484840084848400FFFFFF008484
      84008484840084848400FFFFFF000000000000840000C6C6C60000FF00000084
      0000FFFF000084848400C6C6C600FFFFFF00FFFFFF00C6C6C600FFFF00008484
      000000000000FF000000000000000000000000848400C6C6C60000FFFF0000FF
      FF0000848400C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000008400000084000000840000FFFF
      0000FFFF00008484840084848400FFFFFF00FFFFFF00FFFFFF00C6C6C6008484
      840000000000FF000000000000000000000000848400C6C6C600C6C6C60000FF
      FF0000848400C6C6C600C6C6C600C6C6C600C6C6C60000848400008484000084
      8400008484000084840000000000000000008400000084000000840000008400
      00008400000000000000FFFFFF00848484008484840084848400FFFFFF008484
      84008484840084848400FFFFFF00000000008400000084000000840000008400
      00008400000000000000FFFFFF00848484008484840084848400FFFFFF008484
      84008484840084848400FFFFFF0000000000FF000000FFFFFF00FFFF0000FFFF
      0000FFFF0000FFFF00008484840084848400C6C6C600C6C6C600848484000000
      0000FF000000FF000000000000000000000000848400C6C6C60000FFFF00C6C6
      C60000FFFF000084840000848400008484000084840000848400000000000000
      0000000000000000000000000000000000008400000084000000840000008400
      00008400000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000008400000084000000840000008400
      00008400000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000FF000000FFFFFF00FFFF00000084
      000000840000FFFF0000FFFF000084848400848484008484840084848400FFFF
      0000FF00000084000000000000000000000000848400C6C6C600FFFFFF0000FF
      FF00C6C6C60000FFFF0000FFFF0000FFFF000084840000848400000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF008400000084000000840000008400000084000000840000008400
      000084000000840000008400000084000000000000000000000000000000FFFF
      FF00FFFFFF008400000084000000840000008400000084000000840000008400
      00008400000084000000840000008400000000000000FF000000008400008484
      000000840000FF000000FFFF0000FFFF0000FFFF0000FF000000FFFF0000FF00
      0000FF00000000000000000000000000000000848400C6C6C60000FFFF00FFFF
      FF0000FFFF00C6C6C60000FFFF0000FFFF0000FFFF0000848400000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C6008400000084000000840000008400000084000000840000008400
      000084000000840000008400000084000000000000000000000000000000FFFF
      FF00C6C6C6008400000084000000840000008400000084000000840000008400
      0000840000008400000084000000840000000000000000840000C6C6C60000FF
      00008484000000840000FF000000FFFF0000FFFF0000FFFF0000FF000000FFFF
      0000FF00000000000000000000000000000000848400C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000C6C6C6000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000C6C6C6000000000000000000000000000000000000840000C6C6
      C60000FF000084840000008400000084000000840000FF00000084840000FF00
      00000000000000000000000000000000000000848400C6C6C600C6C6C600C6C6
      C600C6C6C6000084840000848400008484000084840000848400000000000000
      0000000000000000000000000000000000000000000000000000840000008400
      0000840000008400000084000000840000008400000084000000840000008400
      000084000000C6C6C60000000000000000000000000000000000840000008400
      0000840000008400000084000000840000008400000084000000840000008400
      000084000000C6C6C60000000000000000000000000000000000000000000084
      00000084000000FF000000FF0000848400000084000000840000FF000000FF00
      0000000000000000000000000000000000000000000000848400008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000840000008400
      0000840000008400000084000000840000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000840000008400
      0000840000008400000084000000840000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      00000000000000840000008400000084000000840000FF000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C6000000000000FF000000840000000000000000000000000000000000000000
      00000000000000FFFF0000848400FFFFFF00FFFFFF0000848400000000008484
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60000FF00000084000000840000000000000000000000000000000000000000
      000000FFFF000084840000FFFF00FFFFFF00FFFFFF0000FFFF00008484000000
      00008400000084000000840000008400000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000FF
      0000008400000084000000840000C6C6C6000000000000000000000000000000
      0000000000000000000000848400FFFFFF00FFFFFF000084840000FFFF000000
      0000FFFFFF00FFFFFF00FFFFFF008400000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF008484
      84000000000000000000000000000000000000000000FFFFFF00848484008484
      8400C6C6C6000000000000000000000000000000000000000000000000000084
      000000840000008400000084000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C60000000000FFFFFF00FFFFFF0000FFFF00008484000000
      0000FFFFFF00FFFFFF00FFFFFF008400000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF00C6C6
      C6000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00008400000084000000840000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00C6C6C6000000000000000000000000000000000000FFFF000000
      00008400000084000000840000008400000000000000FFFFFF00000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000000000000FF
      FF008484840000000000000000000000000000000000FFFFFF00848484008484
      8400C6C6C60000000000FFFFFF00848484008484840084848400FFFFFF008484
      84008484840000840000008400000000000000000000C6C6C600000000000000
      0000FFFFFF00C6C6C6000000000000FFFF00FFFFFF00FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF008400000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000000000FF
      FF00C6C6C60000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00008400000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000C6C6C6000000
      00008400000084000000840000008400000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF0084848400FFFF
      FF00FFFFFF00C6C6C600FFFFFF00000000000000000000000000000000000000
      000000FFFF0084848400000000000000000000000000FFFFFF00848484008484
      8400C6C6C60000000000FFFFFF00848484008484840084848400FFFFFF008484
      84008484840084848400FFFFFF0000000000000000000000000000000000C6C6
      C600C6C6C60000000000FFFFFF00C6C6C600C6C6C60000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF008400000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF0000000000C6C6C60000000000FFFFFF000000
      00000000000000000000000000008400000000000000FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      000000FFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF008400
      00008400000084000000840000008400000000000000FFFFFF0000000000C6C6
      C60000000000FFFFFF0000000000C6C6C60000000000C6C6C600000000000000
      00000000000000000000840000008400000000000000FFFFFF0084848400FFFF
      FF0000000000FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000840000008400000000008400000084000000840000008400
      00008400000000000000FFFFFF00848484008484840084848400FFFFFF008484
      84008484840084848400FFFFFF00000000000000000000000000000000008484
      840000000000848484000000000084848400000000000000FF000000FF000000
      FF000000000084848400000000000000000000000000FFFFFF00FFFFFF000000
      0000C6C6C60000000000C6C6C60000000000C6C6C60000000000C6C6C600C6C6
      C600C6C6C60000000000840000008400000000000000FFFFFF00FFFFFF00FFFF
      FF0000000000FFFFFF00FFFFFF0000000000FFFFFF0084848400FFFFFF000000
      0000000000000000000000000000000000008400000084000000840000008400
      00008400000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00008484840000000000000000000000000000000000000000000000FF000000
      FF000000000084848400848484000000FF000000000000000000000000000000
      000000000000C6C6C60000000000C6C6C60000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60084000000840000008400000084000000840000008400
      000084000000840000008400000084000000FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF008400000084000000840000008400000084000000840000008400
      0000840000008400000084000000840000000000000000000000000000008484
      84008484840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      FF000000FF0084848400000000000000FF000000000000000000000000000000
      00000000000000000000C6C6C60000000000C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60084000000840000008400000084000000840000008400
      000084000000840000008400000084000000FFFFFF0084848400FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C6008400000084000000840000008400000084000000840000008400
      0000840000008400000084000000840000000000000000000000000000000000
      000084848400000000000000000000FFFF00000000000000000000FFFF00FFFF
      00000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C6000000000084000000840000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0000000000C6C6C60000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FFFF00000000000000
      0000000000000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000000000000000000000000000000000
      0000840000008400000084000000840000008400000084000000840000008400
      0000000000000000000000000000000000000000000000000000840000008400
      0000840000008400000084000000840000008400000084000000840000008400
      000084000000C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      FF000000FF000000FF000000FF000000FF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000084000000840000008400000084000000840000008400
      0000000000000000000000000000000000000000000000000000840000008400
      0000840000008400000084000000840000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400000000008484
      8400000000008484840084000000FFFFFF008400000084000000840000008400
      00008400000084000000FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000008400000084000000840000008400
      0000840000008400000084000000000000000000000000000000848484000000
      0000848484000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000084848400000000008484
      8400000000008484840084000000FFFFFF00840000008400000084000000FFFF
      FF00840000008400000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484008400000000000000000000000000000000000000848484008400
      0000000000000000000000000000000000000000000084000000840000008400
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF000000000000000000000000000000
      000000000000FFFFFF0084000000000000000000000000000000848484000000
      0000848484000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0084000000FFFFFF0084000000000000000000000000000000000000008400
      0000840000008400000084000000840000000000000000000000000000000000
      0000000000008400000084848400000000000000000000000000840000000000
      0000000000000000000000000000000000000000000000000000840000008400
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000084848400000000008484
      8400000000008484840084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00840000008400000000000000000000000000000000000000000000008400
      0000840000008400000084000000000000000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000840000000000
      0000000000000000000000000000000000000000000000000000000000008400
      00008400000084000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF000000000000000000000000000000
      000000000000FFFFFF0084000000000000000000000000000000848484000000
      0000848484000000000084000000840000008400000084000000840000008400
      0000840000000000000000000000000000000000000000000000000000008400
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000840000000000
      0000000000000000000000000000000000000000000000000000840000000000
      00008400000084000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000000000000000000084848400000000008484
      8400000000008484840000000000848484000000000084848400000000008484
      8400000000000000000000000000000000000000000000000000000000008400
      0000840000000000000084000000000000000000000000000000000000000000
      0000000000000000000084000000000000000000000000000000848484008400
      0000000000000000000000000000000000008400000084000000000000000000
      00000000000084000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF000000000000000000FFFFFF008400
      0000840000008400000084000000000000000000000000000000848484000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484000000000000000000000000000000000000000000000000008400
      0000000000000000000000000000840000008400000000000000000000000000
      0000000000008400000084848400000000000000000000000000000000008484
      8400840000008400000084000000840000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF008400
      0000FFFFFF008400000000000000000000000000000084848400848484000000
      0000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600000000008484
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084000000840000008400
      0000840000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0084000000FFFFFF00FFFFFF00FFFFFF00FFFFFF008400
      0000840000000000000000000000000000000000000000000000848484000000
      00000000000000FFFF00000000000000000000FFFF0000000000848484000000
      0000848484000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000FFFFFF000000000084000000840000008400000084000000840000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000084000000840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000084000000000000000000000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000084000000000000008400000000000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008400
      0000000000000000000084000000000000008400000000000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000084000000840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000084000000000000008400000000000000000000008400
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000008400000084000000840000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000084000000840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000000000008400000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400000084000000840084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C6C6C600FFFFFF00C6C6C600FFFFFF00C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C6000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000840000008400000084000000840000008400000084000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084000000840000008400
      0000840000008400000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000008400000084000000840000008400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000084000000840000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000848400FFFFFF00FFFFFF00008484000000
      0000848484008484840000000000000000000000000000000000C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FFFF000084
      8400FFFFFF00FFFFFF0000848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF000084840000FFFF00FFFFFF00FFFFFF0000FFFF000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6C6C600000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000FFFF000084840000FF
      FF00FFFFFF00FFFFFF0000FFFF00008484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000848400FFFFFF00FFFFFF000084840000FF
      FF000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C60000FFFF0000FFFF0000FFFF00C6C6C600C6C6
      C6000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      000084848400000000000000000000000000000000000084840000FFFF000084
      8400FFFFFF00FFFFFF000084840000FFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C6C6C600C6C6C60000000000FFFFFF00FFFFFF0000FFFF000084
      84000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600848484008484840084848400C6C6C600C6C6
      C60000000000C6C6C600000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000084848400C6C6C600C6C6C6008484
      8400000000008484840000000000000000000000000000FFFF000084840000FF
      FF00FFFFFF00FFFFFF0000FFFF00008484000000000000000000000000000000
      0000FFFFFF00000000000000000000000000000000000000FF000000FF00C6C6
      C600FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000000000FF
      FF0000000000C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000C6C6C600C6C6C6000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000084848400C6C6C600C6C6C600FFFF00008484
      8400848484000000000000000000000000000000000000848400000000000000
      000000000000000000000000000000FFFF000000000000000000000000000000
      0000FFFFFF00000000000000000000000000000000000000FF000000FF000000
      000000000000FFFFFF00C6C6C6000000000000FFFF00FFFFFF00FFFFFF000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6C6000000
      0000C6C6C60000000000C6C6C6000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000C6C6C600C6C6C600C6C6C600C6C6C6008484
      8400C6C6C600000000000000000000000000000000000000000000FFFF000084
      840000FFFF00FFFFFF00FFFFFF00000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C60000000000C6C6C600000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000C6C6C600FFFF0000C6C6C600C6C6C6008484
      8400C6C6C6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      0000C6C6C600C6C6C60000000000FFFFFF00C6C6C600C6C6C600000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000C6C6C60000000000C6C6C6000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000084848400FFFF0000FFFF0000C6C6C6008484
      840084848400000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000C6C6C6000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF000000000084848400C6C6C600C6C6C6008484
      840000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000C6C6C6000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF0000000000000000000000000000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF0000000000000000000000000000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000FF000000FF000000FF000000
      FF000000000000000000000000000000000000000000C6C6C600000000000000
      0000C6C6C6000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000FF000000FF000000
      00000000000000000000000000000000000000000000C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484008484
      8400848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000FFFF0000848400FFFFFF00FFFFFF0000848400000000008484
      84008484840000000000000000000000000000000000FFFF0000FFFF00000000
      00000000000000000000FFFF0000FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000FFFF000084840000FFFF00FFFFFF00FFFFFF0000FFFF00008484000000
      00008400000084000000840000008400000000000000FFFFFF00FFFF00000000
      00000000000000000000FFFFFF00FFFF00000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000848400FFFFFF00FFFFFF000084840000FFFF000000
      0000FFFFFF00FFFFFF00FFFFFF0084000000000000000000000000000000C6C6
      C60000000000FFFFFF000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF008484
      8400848484008484840084848400848484008484840084848400848484008484
      8400848484000000000000000000000000000000000000000000FFFFFF008484
      840084848400848484008484840000000000000000000000000000FF000000FF
      000000FF0000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C60000000000FFFFFF00FFFFFF0000FFFF00008484000000
      0000FFFFFF00FFFFFF00FFFFFF00840000000000000000000000C6C6C600C6C6
      C60000000000FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF00FFFFFF000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000FF000000FF000000FF000000FF
      000000FF000000FF000000FF0000000000000000000000000000C6C6C600FFFF
      FF00FFFFFF00C6C6C6000000000000000000000000000000000000FFFF000000
      000084000000840000008400000084000000000000000000000000000000C6C6
      C6000000000000000000C6C6C600C6C6C600C6C6C60000000000C6C6C6000000
      0000FFFFFF0000000000FFFFFF00000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      00000000000000000000000000000000000000FF000000FF000000FF000000FF
      000000FF000000FF000000FF00000000000000000000C6C6C600000000000000
      0000FFFFFF00C6C6C6000000000000FFFF00FFFFFF00FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      00008484840000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000FFFFFF000000
      000000000000848484000000FF000000FF000000FF0084848400000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      000000000000848484000000FF000000000000FF0000FFFFFF0000FF000000FF
      000000FF000000FF000000FF00000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000C6C6C6000000
      0000840000008400000084000000840000000000000000000000000000000000
      000000000000FFFFFF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000FFFFFF000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000FF000000FF0000000000000000000000000000FF000000FF
      000000FF0000000000000000000000000000000000000000000000000000C6C6
      C600C6C6C60000000000FFFFFF00C6C6C600C6C6C60000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00840000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF0000000000FFFFFF00000000000000000000000000FFFFFF000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000FF000000FF000000FF000000FF000000000000FF000000FF
      000000FF00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084000000840000008400
      0000840000008400000084000000840000000000000000000000000000000000
      000000000000FFFFFF00C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600FFFFFF0000000000FFFFFF00000000000000000000000000FFFFFF000000
      0000000000000000FF000000FF000000FF000000FF000000FF00000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000FF000000FF000000FF000000FF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400008484008484840000848400848484000084840084848400008484008484
      8400008484008484840000848400000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      00000000000000000000FFFFFF00000000000000000000000000FFFFFF000000
      000000000000848484000000FF000000FF000000FF0084848400000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      000000000000848484000000FF000000FF000000FF0084848400000000000000
      0000848484000000000000000000000000000000000000000000000000000084
      8400848484000000000000000000000000000000000000000000000000000000
      0000000000008484840084848400000000000000000000000000000000000000
      000000000000FFFFFF00C6C6C600C6C6C600C6C6C600FFFFFF0084848400FFFF
      FF00C6C6C60000000000FFFFFF00000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000000000008484
      84008484840000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600000000008484840000848400000000000000000000000000000000000000
      000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0084848400C6C6
      C600000000008484840000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000848484000000000000000000000000000000000000000000000000000084
      840084848400008484000000000000FFFF00000000000000000000FFFF000000
      0000848484000084840084848400000000000000000000000000000000000000
      0000000000000000000084848400848484008484840084848400848484008484
      840084848400FFFFFF00C6C6C600000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00FFFFFF000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF0084848400C6C6C60000000000C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000C6C6C600C6C6C6000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000008484
      8400848484008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000FFFF0000848400FFFF
      FF00FFFFFF000084840000000000000000000000000000000000000000000000
      0000000000000000000000FFFF0000848400FFFFFF00FFFFFF00008484000000
      0000848484008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484000000
      0000000000008484840084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000FFFF000084840000FFFF00FFFF
      FF00FFFFFF0000FFFF0000848400000000000000000000000000000000000000
      00000000000000FFFF000084840000FFFF00FFFFFF00FFFFFF0000FFFF000084
      8400000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000084848400C6C6C600C6C6C600848484000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF000000000000000000000000000000000000848400FFFF
      FF00FFFFFF000084840000FFFF00000000000000000000000000000000000000
      000000000000000000000000000000848400FFFFFF00FFFFFF000084840000FF
      FF00000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000000000008484
      8400C6C6C600C6C6C60084848400C6C6C6008484840000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000FFFFFF00C6C6C600C6C6C60000000000FFFF
      FF00FFFFFF0000FFFF0000848400000000000000000000000000000000000000
      0000FFFFFF00C6C6C600C6C6C60000000000FFFFFF00FFFFFF0000FFFF000084
      8400000000000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF00C6C6
      C600C6C6C60084848400C6C6C600C6C6C6000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      00000000000000000000C6C6C600FFFFFF00FFFFFF00C6C6C600000000000000
      0000000000000000000000FFFF0000000000000000000000000000000000C6C6
      C600FFFFFF00FFFFFF00C6C6C6000000000000000000000000000000000000FF
      FF0000000000C6C6C60000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00C6C6
      C60084848400C6C6C600C6C6C6000000000000FFFF0000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00000000000000
      0000C6C6C600C6C6C6000000000000000000FFFFFF00C6C6C6000000000000FF
      FF00FFFFFF00FFFFFF00000000000000000000000000C6C6C600C6C6C6000000
      000000000000FFFFFF00C6C6C6000000000000FFFF00FFFFFF00FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000FFFFFF000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C6000000000000FFFF000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00FFFFFF000000
      0000FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00000000000000
      00000000000000000000C6C6C6000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000000000000000C6C6
      C60000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000C6C6C6000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000FFFF00000000000000000000000000000000000000
      00008484840000000000000000000000000000000000FFFFFF00000000000000
      0000000000000000000000000000C6C6C600C6C6C60000000000FFFFFF00C6C6
      C600C6C6C6000000000000000000000000000000000000000000000000000000
      0000C6C6C600C6C6C60000000000FFFFFF00C6C6C600C6C6C600000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000C6C6C6000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600C6C6C60084848400000000000000000000000000FFFFFF00FFFFFF00FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C600C6C6
      C60084848400C6C6C600848484000000000000000000FFFFFF00000000000000
      0000FFFFFF00FFFFFF00FFFFFF0000000000C6C6C60000000000FFFFFF000000
      0000000000000000000000000000840000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      0000FFFFFF000000000000000000000000000000000000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C6008484
      8400C6C6C600C6C6C600848484000000000000000000FFFFFF0000000000C6C6
      C60000000000FFFFFF0000000000C6C6C60000000000C6C6C600000000000000
      0000000000000000000084000000840000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00C6C6C60084848400C6C6
      C600C6C6C60084848400000000000000000000000000FFFFFF00FFFFFF000000
      0000C6C6C60000000000C6C6C60000000000C6C6C60000000000C6C6C600C6C6
      C600C6C6C6000000000084000000840000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600C6C6C600C6C6
      C600000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000FFFFFF00C6C6C600C6C6
      C600848484000000000000000000000000000000000000000000000000000000
      000000000000C6C6C60000000000C6C6C60000000000C6C6C600C6C6C600C6C6
      C600C6C6C600C6C6C60084000000840000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600000000000000
      0000C6C6C6000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF000000000000000000000000000000000000000000FFFF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000FFFFFF00FFFF
      FF00000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000C6C6C600C6C6C600C6C6C600C6C6C600C6C6
      C600C6C6C6000000000084000000840000000000000000000000000000000000
      00000000000000000000000000000000000000000000C6C6C600000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000848484000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084000000840000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000C6C6C6000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000848484000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000000000008484
      8400000000000000000084848400848484000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000FFFF00000000000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      00000000000084848400C6C6C600C6C6C6008484840000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFFFF0000FFFF000000
      0000008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      000084848400C6C6C600C6C6C60084848400C6C6C60084848400000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000084840000848400008484000084840000848400008484000084
      8400008484000084840000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      840000848400000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C600C6C6C60084848400C6C6C600C6C6C60000000000848484000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      840000848400000000000000000000000000000000000000000000000000FFFF
      FF00C6C6C60084848400C6C6C600C6C6C60000000000C6C6C600C6C6C6008484
      840000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      0000FFFFFF00C6C6C600C6C6C60000000000C6C6C600C6C6C60084848400C6C6
      C60084848400000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF000000000000000000000000000000000000000000FFFFFF0000FFFF00FFFF
      FF0000FFFF00FFFFFF0000FFFF00FFFFFF0000FFFF00FFFFFF00000000000000
      0000000000000000000000000000000000000000000000000000008484000084
      8400008484000084840000848400008484000084840000848400008484000084
      8400008484000000000000000000000000000000000000000000000000000000
      000000000000FFFFFF0000000000C6C6C600C6C6C60084848400C6C6C600C6C6
      C60084848400000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFF
      FF00000000000000000000000000000000000000000000FFFF00FFFFFF0000FF
      FF00000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000084848400000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      00000000000000000000FFFFFF00C6C6C60084848400C6C6C600C6C6C6008484
      840000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF0000000000000000000000000000000000000000000000
      0000000000000000000000000000840000000000000000000000000000000000
      0000000000000000000000000000FFFFFF00C6C6C600C6C6C600848484000000
      000000000000000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000FFFFFF000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000840000000000000000000000000000000000
      000000000000000000000000000000000000FFFFFF00FFFFFF00000000000000
      000084848400000000000000000000000000000000000000000000000000FFFF
      FF00FFFFFF00FFFFFF00FFFFFF00FFFFFF00FFFFFF0000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000000000000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000008484840000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000084848400000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000840000008400000084000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000084848400424D3E000000000000003E000000
      2800000040000000900000000100010000000000800400000000000000000000
      000000000000000000000000FFFFFF00FFFF0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000FFFF0000000000008007800FFFF9FFFF0003000FF830F001
      00000000E000F00100000000C001F001000000008003F001000000008003F001
      000000000001000100000000000100010000000000010003000000000001001F
      000000000001001FC000C0008003001FC000C0008003001FC003C003C007003F
      C003C003E00F87FFC007C007F83FFFFFF803FFFFEABF8009E007000FFF9F0001
      E000000FFF8F0000E000000FFF870000C000000FFF8700000000000F00C30000
      0000000F00C300000000000F00E100008000000E00010000C000000400000000
      CA8A000000010000D0000000000FC000C002F800000FC000D400FC00F00FC003
      E000FE04F00FC003FE00FFFFF00FC007FFFFFC00FFFFFFFFFFFF8000FFFFFFFF
      FFFF2800FFFFFFFFFC015400FFFFE7FFFC012800FFF3CF83FC015401E0F9DFC3
      00012803E1FDDFE300015403E3FDDFD300012AABE5FDCF3B00014003EE79E0FF
      0003000BFF83FFFF00075013FFFFFFFF000F8007FFFFFFFF00FFF87FFFFFFFFF
      01FFFFFFFFFFFFFF03FFFFFFFFFFFFFFDB6DFFFFFFFFFFFFD555FFFFFFFFF3FF
      D555FE7FFFFDED9FD555FC3FF7FFED6FDB6DFC3FE3FBED6FFFFFFE7FE3F7F16F
      E01FFFFFF1E7FD1FE01BFE7FF8CFFC7FE011FC3FFC1FFEFF0000FC3FFE3FFC7F
      0011FC3FFC1FFD7F0011FC3FF8DFF93F0011FC3FE1E7FBBF00E1FC3FC3F3FBBF
      00FFFC3FCFF9FBBF00FFFE7FFFFFFFFFFC01C007FFFFC1FFF0038003000C80FF
      F00700010008007FF007000100010060E0070001000300600003000000030060
      00030000000300000003800000038080801FC000000380008023E00100078000
      0FE3E007000FC0010FE1F007000FE0830F8CF003000FE0830F84F803001FF1C7
      9F80FFFF003FF1C7FFC1FFFF007FF1C7F8039CFFFFFFFFFFE007087FFFFFFF83
      E000000380038003E000800380038000C00080009FF39E000000C0009FF39E00
      0000E000983398000000F000983398008000F00098339803C000F00098339803
      C000F00098339833C000F0009FF39FF3C000F0009FF39FF3C000F00080038003
      E001FC0080038003FE1FFC00FFFFFFFFBFFFFF83FC01FFFF99FFFE01F003FFFF
      C0FF0000F00783E0E07F0000F00783E0C03F0000E00783E0807F000000038080
      803F000000038000C077000000038000E0E30003801F8000F5C10007E023C001
      FF80000EFFE3E083FF000004FFE1E083FE010000FF8CF1C7FF010000FF84F1C7
      FF84FC00FF80F1C7FFCEFE04FFC1FFFFFFFFFFFFFFFFBFFFFFFFFFFFFFFF9FFF
      C007001F8003CCFFC007000F8003E07FC00700078003F03FC00700038003E01F
      C00700018003C00FC00700008003C007C007001F8003E003C007001F8003F003
      C007001F8003F807C0078FF1C1FEFC07C00FFFF9E3FEFE13C01FFF75FFF5FF39
      C03FFF8FFFF3FFFCFFFFFFFFFFF1FFFE00000000000000000000000000000000
      000000000000}
  end
  object dlgOpenProject: TOpenDialog
    DefaultExt = 'xmpr'
    Filter = 'Marathon Project (*.xmpr)|*.xmpr|All Files (*.*)|*.*'
    Title = 'Open Project'
    Left = 472
    Top = 68
  end
  object dlgSaveProject: TSaveDialog
    DefaultExt = 'xmpr'
    Filter = 'Marathon Project Files (*.xmpr)|*.xmpr|All Files (*.*)|*.*'
    Title = 'Save Project As...'
    Left = 500
    Top = 68
  end
  object mnuTools: TPopupMenu
    Images = imgMenuTools
    Left = 248
    Top = 68
    object Standard2: TMenuItem
      Action = ViewToolbarStandard
    end
    object Tools4: TMenuItem
      Action = ViewToolbarTools
    end
    object Script2: TMenuItem
      Action = ViewToolbarScript
    end
    object SQLEditor3: TMenuItem
      Action = ViewToolbarSQLEditor
    end
  end
  object actMRU: TActionList
    Left = 304
    Top = 68
  end
  object kbgKeys: TrmKeyBindings
    Actions = actMain
    DisplayActionName = True
    Left = 644
    Top = 68
  end
  object TBMRUList1: TTBMRUList
    Prefix = 'MRU'
    Left = 561
    Top = 57
  end
end
