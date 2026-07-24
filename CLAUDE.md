# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Marathon is a SQL IDE and database administration tool for Firebird databases, ported from Delphi to Lazarus/FreePascal. The codebase is in active migration from legacy Delphi-era components (IB Objects, Toolbar2000, rmControls) to modern Lazarus/LCL standards.

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

No unit test suite exists. Manual testing only via Lazarus IDE. `test/ibx_smoke_test.lpr` is a standalone smoke test that connects to a real Firebird server via IBX (create table / insert / select round trip) — build with `lazbuild test/ibx_smoke_test.lpi` and run as `./test/ibx_smoke_test <database> <user> <password>`. CI runs the full app build plus this smoke test against a live Firebird server via `.github/workflows/build.yml` on push/PR to master.

## Architecture

The application is structured in layers:

**UI Layer** (`src/Source/`) — 101 Pascal units, 75 LFM form files. Forms inherit from `TfrmBaseDocumentForm` or `TfrmBaseDocumentDataAwareForm` and implement `IMarathonForm`. MDI-style window management via `WindowList`.

**IDE Core** — `MarathonIDE.pas` manages plugin lifecycle and form services. `MenuModule.pas` is a data module centralizing all `TActionList` actions, decoupling UI from business logic. `MarathonMain.pas` is the main frame.

**Project/Connection Cache** — `MarathonProjectCache.pas` manages open Firebird connections (`TIBDatabase`) and caches database metadata (tables, views, SPs, triggers, etc.) in `TMarathonProjectCache`. Persisted to XML via DOM/XMLRead/XMLWrite.

**SQL Processing** — `SQLParser.pas` / `SQLLex.pas` / `SQLYacc.pas` handle SQL tokenization and parsing. `ScriptExecutive.pas` implements an ISQL-compatible multi-statement script engine on top of IBX.

**Metadata/DDL** — `src/MetaExtract/`: `MetaExtractUnit.pas` and `DDLExtractor.pas` handle reverse-engineering Firebird objects to DDL, but are only compiled under `{$IFNDEF FPC}` (Delphi + COM automation, via `GSSDDLExtractorServer.pas`/`gssscript_TLB.pas`) — dead code on this Lazarus/FPC port. `GlobalMigrateWizard.pas` (schema migration assistant) is similarly COM-only and unreachable under FPC.

**Plugin System** — `GimbalToolsAPI.pas` defines the public plugin interface; `GimbalToolsAPIImpl.pas` is the implementation. Plugins are managed via `PluginsDialog.pas`.

**Editor** — `lib/SyntaxMemoWithStuff2/` wraps SynEdit with SQL syntax highlighting, code completion (`SQLInsightItem.pas`), bookmarks, and drag-and-drop.

**Custom Components** (`lib/Other/`):
- `adbpedit.pas` — `TDBPanelEdit`, a data-aware panel with edit controls
- `IBPerformanceMonitor.pas` — query performance stats widget
- `NewColorGrd.pas` — color picker
- `DiagramTree.pas` / `CloseUpCombo.pas`

Note: `adbpedit.pas`, `IBPerformanceMonitor.pas`, and `NewColorGrd.pas` also have newer, FPC-ported copies directly in `src/Source/`. Because `src/Source` is earlier in the unit search path than `lib/Other` (see `marathon.lpi`), the `src/Source` copies are the ones actually compiled into the app — the `lib/Other` originals are shadowed/dead. `lib/Other/CloseUpCombo.pas` has no such duplicate and is the live one.

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
- No raw legacy `isc_db_handle`/`isc_database_info` access — `TIBDatabase` doesn't expose a handle. `IBPerformanceMonitor.pas`'s low-level buffer-stats reader is stubbed out for this reason (see Remaining Porting Tasks).

## Component Replacement Reference

Legacy components that have been replaced (useful when reading old code or `.lfm` files):
- `TTBDock` / `TTBToolbar` / `TTBItem` → `TPanel` / `TToolBar` / `TToolButton`
- `TrmPanel` / `TrmComboBox` / `TrmTabSet` / `TrmPathTreeView` → `TPanel` / `TComboBox` / `TTabControl` / `TTreeView`
- `TVirtualStringTree` → `TTreeView`

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
- Verify low-level Firebird metadata extraction now that IBX is wired up (`src/MetaExtract/` is currently dead code under FPC — see Architecture)

The following features are intentionally stubbed/disabled on this FPC/Lazarus port (they show a "not available" message or silently no-op) because they depend on deep Win32-only APIs or on report-writer/editor units that were never ported. Each is a candidate for a real follow-up port:
- **Printing / print preview** (`GlobalPrintingRoutines.pas`, `PrintPreviewForm.pas`) — depended on the missing `PagePrnt`/`DSprint` report-writer units.
- **Query Builder** (`QBuilder.pas`) — not compiled into the app at all (removed from `marathon.lpr`); deep Win32 GDI/grid message handling (`WM_*`, `TWMMouse`, raw `Polygon`/`ClipCursor` calls).
- **SQL Insight code templates** (Options dialog "SQL Insight" tab) and **Find/Replace/bookmark glyphs** in the SQL/trigger/SP editors — `src/Source/SyntaxMemoWithStuff2.pas` is a reduced stub of the full editor wrapper at `lib/SyntaxMemoWithStuff2/SyntaxMemoWithStuff2.pas` (which is itself unported/unbuilt); it's missing `SQLInsightList`, `WSFind`/`WSFindNext`/`WSReplace`, `AddQuestGlyph`/`RemoveQuestGlyph`.
- **Keybinding editor** (`btnEditKeysClick` in `MarathonOptions.pas`) — `MarathonMain.pas`'s `kbgKeys` is a bare `TComponent` placeholder, not a real keybinding grid.
- **`IBPerformanceMonitor`**'s per-relation indexed/non-indexed read counters — relied on a raw `isc_db_handle` that IBX's `TIBDatabase` doesn't expose; `Initialise` (relation list) still works, but `DoDBInfo` is stubbed to return no data, so `SQLForm.pas`'s "Query Performance Analysis" chart is currently always empty.
