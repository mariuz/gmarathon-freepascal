# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Marathon is a SQL IDE and database administration tool for Firebird databases, ported from Delphi to Lazarus/FreePascal. The migration from legacy Delphi-era components (IB Objects, Toolbar2000, rmControls) to modern Lazarus/LCL standards is largely complete — see "Remaining Porting Tasks" below for the handful of Win32-only features still stubbed out, and `ROADMAP.md` for the (fully implemented) feature roadmap on top of the port itself.

## Build Commands

```bash
# One-time: fetch the vendored IBX packages (git submodules)
git submodule update --init --recursive

# Register the IBX packages with lazbuild (one-time per machine)
lazbuild --add-package-link lib/fbintf/fbintf.lpk
lazbuild --add-package-link lib/ibx4lazarus/ibexpress.lpk

# Debug build
lazbuild --build-mode=Debug src/Source/marathon.lpi

# Release build
lazbuild --build-mode=Release src/Source/marathon.lpi
```

Required Lazarus packages: `SynEdit`, `LCL`, `Printer4Lazarus`, `TAChartLazarusPkg`, `ibexpress`, `fbintf` (the latter two are vendored as git submodules under `lib/ibx4lazarus` and `lib/fbintf` — see [MWASoftware/ibx4lazarus](https://github.com/MWASoftware/ibx4lazarus)).

## Tests

No unit test suite exists. Manual testing only via Lazarus IDE. `test/form_load_test.lpr` additionally opens the table editor against a live database when `MARATHON_TEST_DB`/`MARATHON_TEST_USER`/`MARATHON_TEST_PASSWORD` are set (it skips loudly otherwise) — the object editors need a database and a widgetset at once, so nothing else covers them. Note the variables are read from the environment, not argv: the application treats its first argument as a project file to open. `test/ibx_smoke_test.lpr` is a standalone smoke test that connects to a real Firebird server via IBX (create table / insert / select round trip, then extracts and sanity-checks its DDL via `DDLExtractor`) — build with `lazbuild test/ibx_smoke_test.lpi` and run as `./test/ibx_smoke_test <database> <user> <password>`. CI runs the full app build plus this smoke test against a live Firebird server via `.github/workflows/build.yml` on push/PR to master.

## Roadmap

See `ROADMAP.md` for planned features (adapted from FlameRobin's roadmap where realistic for this codebase) and their status.

## Architecture

The application is structured in layers:

**UI Layer** (`src/Source/`) — 101 Pascal units, 75 LFM form files. Forms inherit from `TfrmBaseDocumentForm` or `TfrmBaseDocumentDataAwareForm` and implement `IMarathonForm`. MDI-style window management via `WindowList`.

**IDE Core** — `MarathonIDE.pas` manages plugin lifecycle and form services. Object editors are opened through `OpenObject(name, connection, kind, schema)` and created through `NewObject(connection, kind)`; the nine `OpenTable`/`OpenView`/… and eight `NewTable`/… functions are one-line wrappers on those, and the object tree's `opOpen` dispatch is one call rather than a branch per kind. It finds an editor already open by **object type** rather than by class — every editor sets `FObjectType` — so only the two small factory functions beside it name a form class at all. `MenuModule.pas` is a data module centralizing all `TActionList` actions, decoupling UI from business logic. `MarathonMain.pas` is the main frame.

**Project/Connection Cache** — the ten per-kind tree headers share one `TMarathonCacheHeader.ExpandObjectList`; each `Expand` is now the query and the kind, and `NewCacheObject` is the only place a node class is named (they differ in nothing but their cache type, and the icon comes from that). Note `TMarathonCacheBaseNode.SubItems` is a *selection* list the explorer fills, not a node's children — children are tree nodes under `ContainerNode`. `MarathonProjectCache.pas` manages open Firebird connections (`TIBDatabase`) and caches database metadata (tables, views, SPs, triggers, etc.) in `TMarathonProjectCache`. Persisted to XML via DOM/XMLRead/XMLWrite.

**SQL Processing** — `SQLParser.pas` / `SQLLex.pas` / `SQLYacc.pas` handle SQL tokenization and parsing. `ScriptExecutive.pas` implements an ISQL-compatible multi-statement script engine on top of IBX.

`SQLLex.pas` and `SQLYacc.pas` are **generated** from `sqllex.l` and `sqlyacc.y` beside them — edit the `.l`/`.y` and run `tools/build_parser.sh`, the way `tools/build_icons.sh` is run after changing an icon. Output is checked in, so an ordinary build needs neither the script nor a yacc. Three things to know: the stock `pyacc` cannot build this grammar (TP Yacc's table sizes overflow — `tools/build_pyacc.sh` rebuilds it with larger ones); the generated units need patches the generators cannot express (methods rather than free functions, and a `TStatement` built on every shift — without that last one the parser segfaults inside a Variant conversion on the first identifier, nowhere near the cause), which `build_parser.sh` applies; and inside a yacc action a Pascal `{ }` comment closes the action while an apostrophe opens a string that swallows the rest of the rule, so use `(* *)` inside actions, `/* */` between them, and no apostrophes in either. `test/debugger_test` is the headless check on what the grammar accepts.

**Metadata/DDL** — `src/MetaExtract/DDLExtractor.pas`'s `TDDLExtractor` reverse-engineers Firebird objects (tables, views, procedures, triggers, domains, generators, exceptions, UDFs, plus PK/FK/index/grant sub-scripts) to DDL text, driven directly against `TIBDatabase`/`TIBTransaction`; it's used by `FrameMetadata.pas`'s "DDL" tab in the object editors and by `MetaExtractUnit.pas`'s `TIBMetaExtract` (the bulk multi-object export engine, one file covering however many selected tables/views/procedures/etc.), which in turn is driven by `MetaExtractWizard.pas`'s `TfrmMetaExtractWizard` — a from-scratch Lazarus dialog (Tools > Metadata Extract, or right-click "Extract Metadata..." on any tree object/header) since the original `GlobalMigrateWizard.pas`/`TfrmGlobalMigrateWizard` had no `.lfm` and relied on LCL's `TTreeView` having Delphi-style tri-state node checkboxes, which it doesn't. The Delphi build reached all of this through a COM server — `gssscript.dll`, whose `IGSSDDLExtractor` typelib import was `gssscript_TLB.pas`; that whole path is gone (see below), so `MarathonIDE.pas`'s `opExtractDDL` and `ToolsMetadataExtract` now open `TfrmMetaExtractWizard` unconditionally rather than choosing between a COM branch and an FPC one.

**Printing** — `src/Common/PrintDocument.pas` builds a document from blocks (title, headings, text, tables) and paginates it onto a character grid; it needs no printer and no LCL, so pagination is tested headlessly. `src/Source/PrintRenderer.pas` draws a page onto any canvas — the printer's or the preview's — in a fixed-pitch font sized to make the grid span the page. `PrintPreviewForm.pas` renders pages onto a paint box; `GlobalPrintingRoutines.pas` builds the documents, taking object reports from `DDLExtractor`. This replaced the `PagePrnt`/`DSprint` report writers, which were never ported.

**Query Builder** — `src/Common/QueryModel.pas` holds the tables, joins and columns and generates the `SELECT`; it needs no widgetset, so join ordering is tested headlessly and the generated statements are run against a live server by the smoke test. `src/Source/QueryBuilderForm.pas` draws the canvas. This replaced `QBuilder.pas` (deleted), 2819 lines of Win32 GDI that was never compiled into this port.

**SQL Trace** — `src/Common/SQLTraceFormat.pas` maps Marathon's monitor/statement groups onto IBX's trace flags and formats a traced line; no IBX, no LCL, so it is tested headlessly. `MarathonSQLMonitor.pas` is a thin adapter over IBX's `TIBSQLMonitor`, replacing a stub that had every property and no behaviour. Note tracing has **three** switches: the monitor that listens, each `TIBDatabase.TraceFlags` that publishes, and the global `MonitorHook.Enabled` that carries events between them — with any one off, nothing arrives.

**Keybindings** — `src/Common/KeyBindings.pas` holds the map of command to shortcut, the storage text form, and conflict detection; no LCL, so it is tested headlessly. The text form is deliberately not the LCL's `ShortCutToText`, which is translated — a file written on a German build would not load on an English one. `src/Source/KeyBindingEditor.pas` is the grid, reached from Options; `keybind.dat` beside the executable holds only what differs from the built-in shortcuts.

**Code templates** — `src/Common/CodeTemplates.pas` holds the templates, the `[name | description]` file form the Delphi build used, and expansion (caret marker, indentation to where the name was typed). No LCL. `TSyntaxMemoWithStuff2.ExpandTemplateAtCaret` is bound to Ctrl+J, so every editor built on the wrapper gets it; the Options "SQL Insight" tab edits them and `templates.dat` sits beside the executable. The same wrapper's `AddQuestGlyph`/`RemoveQuestGlyph` are the debugger's "blue dots", kept in SynEdit's own mark list so they move with the text.

**Icons** — `icons/*.svg` is the source of truth; `tools/build_icons.sh` renders it to `TreeImagesStrip{,_24,_32}.bmp` at 16/24/32 and recompiles `Toolmenus.RES`. Output is checked in, so a normal build needs neither the script nor ImageMagick — run it after changing an icon. `Globals.LoadScaledStrip` picks the strip for the display; the thresholds live in `src/Common/IconScaling.pas` and are tested headlessly. Note ImageMagick's built-in SVG renderer has no arc command — use Béziers.

**Data grid edits** — the table editor's Data tab runs with IBX `CachedUpdates`, so edits are held. `TfrmTables.PendingDataChanges` renders them through `src/Common/RowEdits.pas`; `ApplyDataChanges` writes them, `CancelDataChanges` drops them. Leaving the Data tab asks about the *pending row changes*, not about the transaction — `CheckCommit`. The grid writes through a `TIBUpdateSQL` built from the table's columns and key when the tab opens; a plain `TIBQuery` over `select *` is read-only, so before that every edit failed with "Dataset is read-only". Tables without a primary key stay read-only deliberately. A deleted row is recorded as the user deletes it (`DataBeforeDelete` into `FPendingDeletes`) rather than read back: a cached deletion is excluded from every view of the dataset, and neither `UpdateRecordTypes` including `cusDeleted` nor IBX's `CachedUpdateStatus` reaches it. `UpdatesPending` does know one exists, but not which row it was. Also note `form_load_test` installs an `Application.OnException` sink - without it an unhandled exception opens a dialog that hangs under Xvfb instead of failing. RowEdits refuses to write an UPDATE or DELETE for a table with no primary key rather than emit one that would match every row that looks alike.

**SQL keywords** — the highlighter takes its list from the connected server's `RDB$KEYWORDS` (Firebird 5+), applied by `Globals.ApplyConnectionKeywords` when a connection opens. `FirebirdKeywords.ExtraFirebirdKeywords` is now only the fallback for older servers. Words the highlighter already knows are not injected — doing so would replace its own handling with the TableName attribute.

**Query plans** — Firebird returns two formats. Firebird 3+ gives an explained plan (indented lines), read by `PlanUnit.FillTreeFromExplainedPlan`; older servers give a parenthesised one-liner, parsed by `src/Common/PlanParser.pas`. `FillTreeFromPlan` picks between them — call that, not either reader directly.

**Schema Designer** — `src/Common/SchemaDiagram.pas` is the model and the layout (breadth-first from the most-referenced table; no canvas, so it is tested headlessly), `SchemaDiagramIO.pas` reads tables and foreign keys from `RDB$RELATION_CONSTRAINTS` + `RDB$REF_CONSTRAINTS` + `RDB$INDEX_SEGMENTS`, and `src/Source/SchemaDiagramForm.pas` draws it on one paint box.

**Plugin System** — `GimbalToolsAPI.pas` defines the public plugin interface; `GimbalToolsAPIImpl.pas` is the implementation. Plugins are managed via `PluginsDialog.pas`.

**Editor** — `lib/SyntaxMemoWithStuff2/` wraps SynEdit with SQL syntax highlighting, code completion (`SQLInsightItem.pas`), bookmarks, and drag-and-drop.

**Custom Components** (`lib/Other/`):
- `adbpedit.pas` — `TDBPanelEdit`, a data-aware panel with edit controls
- `IBPerformanceMonitor.pas` — query performance stats widget
- `NewColorGrd.pas` — color picker
- `DiagramTree.pas` / `CloseUpCombo.pas`

Note: the shadowed `lib/Other` copies of `adbpedit.pas`, `IBPerformanceMonitor.pas` and `NewColorGrd.pas` have been deleted — `src/Source` is earlier in the unit search path (see `marathon.lpi`), so those were never compiled and editing one had no effect. `lib/Other/CloseUpCombo.pas` has no duplicate, but note it is not reachable from `marathon.lpr` either — it, and `src/Common/ChooseFolder.pas`, are live only for `src/ScriptExec/screxec.dpr`, one of the Delphi-only side projects (`ScriptExec`, `Plugins/AutoIncFieldWizard`, `Plugins/FreeIBCompsSQL`, `ShellExtension`) that were never given an `.lpi` and so are not part of this port. Check those before calling anything outside `src/Source` dead. `DBValCb.pas` did have a `src/Source` twin, and nothing referenced either copy; both are gone, along with `SQLParser.pas`, `BaseWizard.pas`, `GlobalMigrateWizard.pas` and `GSSDDLExtractorServer.pas` — the last two were dead together, the extractor server being the only thing that still named the wizard.

The COM half of the old metadata-extract feature is gone with them: `src/MetaExtract/gssscript_TLB.pas` (the Delphi-generated `IGSSDDLExtractor` typelib import, which under FPC had already been reduced to an empty `interface implementation end.` stub because it needs Delphi's `StdVCL`), the `gssscript.dll` project that published it (`gssscript.dpr`/`.tlb`/`.res`, `GssscriptVersion.*`, the orphaned `GlobalMigrateWizard.dfm`, and the `want.xml`/`MarathonProduction.bpg` rules that built it — the `.dpr` had been unbuildable since `GSSDDLExtractorServer.pas` and `GlobalMigrateWizard.pas` were deleted out from under it), and the four `{$IFNDEF FPC}` `CreateComObject`/`Extractor.*` sites in `MarathonIDE.pas` that were the only callers. Each of those sites already had a `{$ELSE}` branch driving `TfrmMetaExtractWizard`, so removing the guard is what the FPC build was compiling all along. `ComObj` left `MarathonIDE.pas`'s `uses` with them. Note the name is misleading — despite "script", the typelib's one coclass was a DDL extractor, not a scripting engine; nothing was lost that a script host would replace.

`src/CreateDBWizard/` went the same way, and for the same reason — it was the *other* COM DLL, `CDatabse.dll`. Gone: `cdatabse.dpr`/`.tlb`/`.res`, `CDatabseVersion.*`, `GimbalCreateDatabase_TLB.pas` with its two servers `GSSCreateDatabaseImpl.pas`/`GSSDatabaseInfoImpl.pas` (a closed reference cycle — nothing outside the four named any of them), and the old Delphi forms `CreateDatabase.pas`/`.dfm` + `DBAddSecondaryFile.pas`/`.dfm`. `CreateDatabase.pas` is the one to understand: it declared `unit CreateDatabase`, the *same unit name* as the live `src/Common/CreateDatabase.pas`, and `OtherUnitFiles` lists `../Common` before `../CreateDBWizard` — so it was shadowed and never compiled, exactly the `lib/Other` trap above, which is why editing it during the port had no effect. The live pair is `src/Common/CreateDatabase.pas` (LCL-free, IBX creates the database from the DPB) plus `src/Source/CreateDatabaseDialog.pas`/`.lfm`. **Only `GSSCreateDatabaseConsts.pas` survives in that directory** — it is a pure `const` unit with no `uses`, and `marathon.lpr` names it, which is why `../CreateDBWizard` stays on the unit search path.

Two smaller sweeps went with it. Orphaned Delphi form resources whose units were ported or deleted: `src/Common/BaseWizard.dfm`, and `lib/SyntaxMemoWithStuff2/FindDlg.dfm`/`.dsk`/`ReplDlg.dfm` (ported to `src/Source/FindDlg.*`/`ReplDlg.*` with real `.lfm`s). And `marathon.lpi` carried `<Unit>` entries for eight files that no longer exist anywhere — `PagePrnt.pas`, `DSprint.pas` (the report writers that were never ported), `Chart.pas`, `Series.pas`, `TeeProcs.pas`, `TeEngine.pas` (TeeChart, replaced by TAChart), `rmSpin.pas`, `rmCollectionListBox.pas` (rmControls) — plus a stale path: `AboutBox.pas` moved from `src/Common` to `src/Source` during the port and both `marathon.lpr` and `.lpi` still pointed at `../Common/`. When removing a `<Unit>` block from an `.lpi`/`.lps`, renumber the `<UnitNN>` tags above the hole and decrement `<Units Count>`; note the `.lpi`'s numbering already has a pre-existing gap, so it is not contiguous and `Count` does not equal the number of blocks. Also note `marathon.lps` is a per-developer session file (cursor positions, editor state) that is tracked in git anyway and has accumulated absolute paths like `/usr/share/lazarus/1.0.2/lcl/grids.pas`; it is noise, not configuration.

## Database Access Pattern (IBX)

The project was migrated Delphi → SQLDB → **IBX** (MWASoftware's `ibx4lazarus`, vendored as git submodules under `lib/ibx4lazarus` and `lib/fbintf`). All database access uses:
- `TIBDatabase` for Firebird connections (unit `IBDatabase`)
- `TIBTransaction` for transaction management (unit `IBDatabase`)
- `TIBQuery` for parameterized queries (unit `IBQuery`)
- `TIBXScript` for multi-statement scripts (unit `ibxscript`)
- `TBufDataset` for in-memory result caching (unchanged, FCL)

Data binding follows the standard pattern: `TDataSource` → `TDataSet` → UI components (`TDBGrid`, `TDBNavigator`, `TDBPanelEdit`).

Key API differences from SQLDB/TIBConnection that show up throughout the codebase:
- Auth is via `Params` (`TStrings`), not discrete properties: `DB.Params.Values['user_name']`, `['password']`, `['sql_role_name']` — there is no `.UserName`/`.Password`/`.Role`/`.HostName`.
- `.DatabaseName` embeds the host: `'hostname:/path/to/db.fdb'` for a remote connection, just `'/path/to/db.fdb'` for local.
- Dialect is `.SQLDialect`, not `.Dialect`.
- A transaction links to its connection via `.DefaultDatabase`, not `.Database` (that property is on datasets/queries, e.g. `TIBQuery.Database`).
- `TIBQuery.StatementType` returns `TIBSQLStatementTypes` (`SQLSelect`, `SQLInsert`, `SQLUpdate`, `SQLDelete`, `SQLDDL`, `SQLExecProcedure`, `SQLCommit`, `SQLRollback`, `SQLSelectForUpdate`, …), unit `IB` — not the old SQLDB `TStatementType` (`stSelect` etc.).
- Errors: `EIBError` (base, has `.SQLCode`) and `EIBInterBaseError` (has `.IBErrorCode`, `.Status`), unit `IB`.
- No raw legacy `isc_db_handle`/`isc_database_info` access — `TIBDatabase` doesn't expose a handle. `IBPerformanceMonitor.pas` originally relied on this and was stubbed out for this reason, but has since been rewritten to source the same stats from Firebird's `MON$*` monitoring tables instead (see `ROADMAP.md` Phase 3).

## Component Replacement Reference

Legacy components that have been replaced (useful when reading old code or `.lfm` files):
- `TTBDock` / `TTBToolbar` / `TTBItem` → `TPanel` / `TToolBar` / `TToolButton`
- `TrmPanel` / `TrmComboBox` / `TrmTabSet` / `TrmPathTreeView` → `TPanel` / `TComboBox` / `TTabControl` / `TTreeView`
- `TVirtualStringTree` → `TTreeView`

### Delphi/LCL behavioural differences

Components that exist in both but *behave* differently. Each of these shipped as
a working-looking build and failed only at runtime, so treat a compiling port of
Delphi UI code as unverified until it has been run:

- **`TImageList.AddMasked`** — Delphi splits a bitmap wider than the list's image
  size into one image per cell; LCL adds the whole strip as a single image, *and
  swallows the exception*, returning −1. Use `AddStripMasked` (`Globals.pas`). An
  image list holding one image makes every icon index ≥ 1 raise `List index out
  of bounds` from inside the gtk2 widgetset, nowhere near the real cause.
- **`TImageList` in a `.lfm`** — a Delphi `Bitmap = {494C0101…}` blob loads as a
  single image whatever its header says. Convert with
  `tools/imagelist_convert.lpr`.
- **`TTabSheet.TabVisible`** — making a tab visible does not make it the active
  page. Set `PageControl.ActivePage` explicitly, and before `ActiveControl`.
- **`TIBDatabase.LoginPrompt`** — defaults to `True`, which makes IBX try to raise
  its own login dialog from the GUI half of the package. Always set it `False`;
  Marathon collects credentials itself.
- **Transactions are not opened on demand** — a query on a committed transaction
  raises `Transaction is not active` rather than starting one. The shared
  per-connection transaction is committed constantly, so guard at the entry
  point (`ScriptAs.EnsureActive`, `DDLExtractor.Extract`) or grant
  `AllowAutoActivateTransaction` via `Globals.AllowAutoTransactions`, which
  recurses because a form does not own the components on its frames.
- **Event handlers fire with nil arguments** — `TTreeView.OnChange` fires with no
  node when the selection is cleared, which any tree rebuild does. Check before
  dereferencing.

- **Threads need `cthreads` on Unix** — a program with no thread driver dies
  with `no thread support compiled in` (runtime error 232) the moment one is
  created, which for the SQL Trace is when the window is opened rather than at
  startup. `cthreads` must come *first* in the `uses` clause of `marathon.lpr`
  and of any console harness.

Set `MARATHON_TRACE_EXCEPTIONS=1` to print a Pascal backtrace for every
exception. gdb cannot produce one for faults raised inside the RTL — it is built
without frame pointers, so the caller's frame is lost.

## Key Files Quick Reference

| File | Role |
|------|------|
| `src/Source/marathon.lpr` | Entry point, splash screen |
| `src/Source/MarathonIDE.pas` | IDE services, plugin management |
| `src/Source/MarathonProjectCache.pas` | DB connection & metadata cache |
| `src/Source/SQLForm.pas` | Main SQL editor form |
| `src/Source/DatabaseManager.pas` | Database object explorer |
| `src/Source/MenuModule.pas` | Centralized action/menu data module |
| `src/Common/Tools.pas` | Utility functions (string, DB, system) |
| `src/Common/ScriptExecutive.pas` | ISQL-compatible script execution |
| `src/Common/GSSRegistry.pas` | Settings persistence |
| `src/MetaExtract/DDLExtractor.pas` | DDL/SQL generation from metadata |

## Remaining Porting Tasks

- Fix specific API mismatches from `TrmTabSet` → `TTabControl` differences
- Tri-state checkbox handling (previously via VirtualTreeView)

The following features are intentionally stubbed/disabled on this FPC/Lazarus port (they show a "not available" message or silently no-op) because they depend on deep Win32-only APIs or on report-writer/editor units that were never ported. Each is a candidate for a real follow-up port:
