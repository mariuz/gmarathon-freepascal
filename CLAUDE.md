# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Marathon is a SQL IDE and database administration tool for Firebird databases, ported from Delphi to Lazarus/FreePascal. The codebase is in active migration from legacy Delphi-era components (IB Objects, Toolbar2000, rmControls) to modern Lazarus/LCL standards.

## Build Commands

```bash
# Debug build
lazbuild --build-mode=Debug src/Source/marathon.lpi

# Release build
lazbuild --build-mode=Release src/Source/marathon.lpi
```

Required Lazarus packages: `SynEdit`, `LCL`, `Printer4Lazarus`, `TAChartLazarusPkg`

## Tests

No automated test suite exists. Manual testing only via Lazarus IDE. CI runs via `.github/workflows/build.yml` on push/PR to master.

## Architecture

The application is structured in layers:

**UI Layer** (`src/Source/`) — 101 Pascal units, 75 LFM form files. Forms inherit from `TfrmBaseDocumentForm` or `TfrmBaseDocumentDataAwareForm` and implement `IMarathonForm`. MDI-style window management via `WindowList`.

**IDE Core** — `MarathonIDE.pas` manages plugin lifecycle and form services. `MenuModule.pas` is a data module centralizing all `TActionList` actions, decoupling UI from business logic. `MarathonMain.pas` is the main frame.

**Project/Connection Cache** — `MarathonProjectCache.pas` manages open Firebird connections (`TIBConnection`) and caches database metadata (tables, views, SPs, triggers, etc.) in `TMarathonProjectCache`. Persisted to XML via DOM/XMLRead/XMLWrite.

**SQL Processing** — `SQLParser.pas` / `SQLLex.pas` / `SQLYacc.pas` handle SQL tokenization and parsing. `ScriptExecutive.pas` implements an ISQL-compatible multi-statement script engine.

**Metadata/DDL** — `src/MetaExtract/`: `MetaExtractUnit.pas` and `DDLExtractor.pas` handle reverse-engineering Firebird objects to DDL. `GlobalMigrateWizard.pas` assists schema migration.

**Plugin System** — `GimbalToolsAPI.pas` defines the public plugin interface; `GimbalToolsAPIImpl.pas` is the implementation. Plugins are managed via `PluginsDialog.pas`.

**Editor** — `lib/SyntaxMemoWithStuff2/` wraps SynEdit with SQL syntax highlighting, code completion (`SQLInsightItem.pas`), bookmarks, and drag-and-drop.

**Custom Components** (`lib/Other/`):
- `adbpedit.pas` — `TDBPanelEdit`, a data-aware panel with edit controls
- `IBPerformanceMonitor.pas` — query performance stats widget
- `NewColorGrd.pas` — color picker
- `DiagramTree.pas` / `CloseUpCombo.pas`

## Database Access Pattern (SQLDB)

The project was fully migrated from IB Objects (IBO) to Lazarus SQLDB. All database access uses:
- `TIBConnection` for Firebird connections
- `TSQLTransaction` for transaction management
- `TSQLQuery` for parameterized queries
- `TSQLScript` for multi-statement scripts
- `TBufDataset` for in-memory result caching

Data binding follows the standard pattern: `TDataSource` → `TDataSet` → UI components (`TDBGrid`, `TDBNavigator`, `TDBPanelEdit`).

IBO→SQLDB property renames that still appear in older code:
- `.Path` / `.Server` → `.DatabaseName` / `.HostName`
- `.InTransaction` / `.Started` → `.Active` (on transaction)
- `TIBOQuery` / `TIB_Query` / `TIBSQL` → `TSQLQuery`

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
- Verify low-level Firebird metadata extraction under SQLDB
