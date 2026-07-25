# Marathon Roadmap

This roadmap adapts ideas from [FlameRobin's roadmap](https://github.com/mariuz/flamerobin/blob/master/ROADMAP.md) —
another Firebird admin/IDE tool — to what's realistic for Marathon: a Lazarus/FreePascal
codebase, now on IBX (`lib/ibx4lazarus` + `lib/fbintf`), with no unit test framework
beyond the `test/ibx_smoke_test.lpr` integration check. Items are picked for being
genuinely valuable *and* buildable without a rewrite — FlameRobin's C++/wxWidgets-specific
items (MCP servers, vector/AI embeddings, its own DAL abstraction) are left out.

Status legend: `[x]` done, `[~]` in progress, `[ ]` not started.

## Phase 1 — Metadata & DDL Scripting

The `DDLExtractor.pas` engine (reverse-engineer any object to `CREATE ...` DDL) was
fully written but only reachable through a `{$IFNDEF FPC}`-guarded COM wrapper —
dead code on this Lazarus port. It turned out to have no real COM/Windows
dependency in its own logic, so reactivating it was mostly a matter of fixing
its `uses` clauses and wiring it directly to the new IBX types.

- [x] **Single-object DDL tab** — `FrameMetadata.pas`'s "DDL" tab (used by the table/view/procedure/trigger/domain/generator/exception/UDF editors) now calls `TDDLExtractor` directly instead of showing "DDL Extraction not available in FPC yet." Covers `ctDomain`, `ctTable` (+ PK/FK/indexes/triggers/grants), `ctView` (+ grants), `ctSP` (+ grants), `ctTrigger`, `ctGenerator`, `ctException`, `ctUDF`.
- [x] **Bulk "Extract Metadata" wizard** — `MarathonIDE.pas`'s `opExtractDDL` tree action and `ToolsMetadataExtract` now open a new dialog, `MetaExtractWizard.pas`/`.lfm` (`TfrmMetaExtractWizard`), built from scratch against plain LCL controls rather than reviving `GlobalMigrateWizard.pas`'s dead `.dfm`/rmControls/`TTreeView`-with-checkboxes design (confirmed LCL's `TTreeView` has no checkbox support at all, and the prior port pass had already left the old wizard's check-state logic as dead commented-out code) - one `TCheckListBox` tab per object type (Domains/Tables/Views/Procedures/Triggers/Generators/Exceptions/UDFs, using the exact same `RDB$*`/`CHECK_*`-filtered queries as `DatabaseManager.pas`'s tree "header" node `Expand()` methods) plus an Options tab (extract mode, create-database/include-password/include-dependents/include-doc/wrap/decimal-format), matching the whole option surface the old COM-based `IGSSDDLExtractor` interface used to expose. `MetaExtractUnit.pas`'s `TIBMetaExtract` engine needed only the same `uses`-clause FPC guard fix as its siblings - it already called `DDLExtractor.pas` internally, no dead COM path in its own logic. Both `opExtractDDL` (pre-selects whichever tree object(s)/header the user right-clicked) and `ToolsMetadataExtract` (opens empty after a connection picker) now drive this same dialog, exactly mirroring the old COM interface's `DoWizardList` vs. `DoWizard` split. Verified end-to-end against a live server with a standalone harness: extracting a table (+ PK constraint), view, procedure (`CREATE` stub + `ALTER` body two-step, `SET TERM`-wrapped), trigger, and grants for all three grantable object types into one script, byte-for-byte in the shape Firebird/isql expects.
- [x] **DDL round-trip test coverage** — `test/ibx_smoke_test.lpr` now creates a view, a stored procedure, and a trigger on the smoke-test table (plus best-effort drops in dependency order at startup so repeat runs against the same database don't fail on `recreate table`'s dependency check) and extracts DDL for each. Confirmed live that `ExtractStoredProcedure` (the `ddlstNone`/`ddlstProc` subtype) always emits the `ALTER PROCEDURE ... body` form rather than `CREATE` - it's meant to follow a separate `ddlstHeader` `CREATE PROCEDURE` stub for round-tripping procedures with forward references, matching how Phase 2's "Script as CREATE" already uses this extractor - so the test asserts on that shape rather than expecting `CREATE`.

## Phase 2 — "Script As ..." Productivity (SSMS/pgAdmin/vscode-mssql-style)

- [x] **Script as CREATE from the object tree** — right-click a table/view/procedure in `DatabaseManager.pas`'s tree ("Script As" submenu) opens a new SQL editor pre-filled with its DDL, via `DDLExtractor` (Phase 1).
- [x] **Script as SELECT** — right-click a table/view → new SQL editor with `select first 100 <columns> from <table>`. Column list comes from a small `RDB$RELATION_FIELDS` query (`ScriptAsColumnNames` in `MarathonIDE.pas`).
- [x] **Script as INSERT / UPDATE / DELETE** — same column list drives `insert into t (...) values (:params)`, `update t set col = :col, ... where /* TODO */ 1 = 0`, and `delete from t where /* TODO */ 1 = 0` (no attempt at PK-based WHERE detection yet — the `1 = 0` placeholder is a deliberately inert default so a generated script can't accidentally run as an unqualified mass update/delete).
- [x] **Script as EXECUTE PROCEDURE** — one placeholder per input parameter (`RDB$PROCEDURE_PARAMETERS` where `rdb$parameter_type = 0`); if the procedure also has output parameters (`rdb$parameter_type = 1`) it generates `select * from proc(:params)` (selectable procedure) instead of `execute procedure proc(:params)`, verified against a live server for both param directions.

Implementation notes for future "Script as ..." additions: `TGSSCacheOp` (`MarathonProjectCacheTypes.pas`) has `opScriptSelect/Insert/Update/Delete/Create`; gating by object type is in `TMarathonCacheObject.CanDoOperation` (`MarathonProjectCache.pas`); the tree wiring is `TfrmDatabaseExplorer.CanScriptXxx`/`DoScriptXxx` (`DatabaseManager.pas`) → `IMarathonForm` (`MarathonInternalInterfaces.pas`, default no-op bodies in `BaseDocumentForm.pas`) → `TAction`s on `frmMarathonMain` (`MarathonMain.pas`/`.lfm`) → the "Script As" submenu in `mnuTree` (`MenuModule.lfm`/`.pas`) → `TMarathonIDE.CacheEventHandler`'s `opScriptXxx` case (`MarathonIDE.pas`), which calls the `ScriptAsXxx` generator functions and `ScriptAsOpenEditor` (all free functions just above `CacheEventHandler` in `MarathonIDE.pas`).

## Phase 3 — Live Session & Query Diagnostics

Firebird's `MON$*` monitoring tables are just ordinary read-only system tables —
this is plain SQL against `MON$ATTACHMENTS` / `MON$STATEMENTS` / `MON$TRANSACTIONS`,
no new library dependencies.

- [x] **Live Session Monitor** — `SessionMonitor.pas`/`.lfm`, opened via Tools > Session Monitor. Three tabs (Attachments/Statements/Transactions) backed by plain `MON$*` queries, manual "Refresh" button (each refresh commits and starts a new transaction, since Firebird only takes a fresh `MON$` snapshot on a transaction's first access to the monitoring tables). Verified all three queries against a live server, including catching that `MON$STATEMENTS` has no `MON$USER` column (it's `MON$TRANSACTION_ID` instead — user is on the attachment, not the statement).
- [x] **Cancel Statement / Disconnect Attachment** — a "Disconnect Attachment" button on the Attachments tab and "Cancel Statement" on the Statements tab, each behind a confirmation dialog. Both use Firebird's documented `DELETE FROM MON$ATTACHMENTS`/`MON$STATEMENTS WHERE ... = ?` mechanism (verified live: killed a real background `isql` session mid-query and watched it get "connection shutdown - Killed by database administrator"). Disconnect refuses to target the monitor's own attachment (`CURRENT_CONNECTION` from `RDB$DATABASE`), so you can't accidentally sever the connection the window itself is using.
- [x] **Query performance stats, take 2** — `IBPerformanceMonitor.pas` rewritten to drive `SQLForm.pas`'s "Query Performance Analysis" tab from `MON$RECORD_STATS`/`MON$IO_STATS`/`MON$TABLE_STATS` instead of the unavailable raw `isc_database_info()` call. Live schema exploration turned up the actual join (not `MON$STATEMENTS` as the roadmap originally guessed, since a statement's own `MON$STAT_GROUP=3` block stayed at zero in testing - the real per-table/aggregate activity is attributed to the **transaction's** stat block instead): `MON$TRANSACTIONS.MON$STAT_ID` → `MON$TABLE_STATS.MON$STAT_ID` (per-table breakdown, `MON$RECORD_STAT_ID` → that table's own `MON$RECORD_STATS` row) for the Series1 bar chart, and `MON$TRANSACTIONS.MON$STAT_ID` → `MON$RECORD_STATS`/`MON$IO_STATS` directly for the aggregate Stats-grid counters (reads/writes/marks/fetches/inserts/updates/deletes/backouts/purges/expunges), plus `MON$DATABASE.MON$PAGE_BUFFERS` and `MON$MEMORY_USAGE` (via `MON$ATTACHMENTS`) for buffers/memory. Since `MON$RECORD_STATS`/`MON$IO_STATS` are live, continuously-updated counters scoped to a transaction (not one-shot per-statement values), the class keeps the original before/after-delta model (`ResetCounters` right before executing, `Refresh` right after, `.Data` is the difference) rather than needing new semantics - `SQLForm.pas`'s `DoExecute` needed only three small edits (call `ResetCounters`/`Refresh` at those two points, wire `perfSQL.Transaction := transSQLStatement`) since the class's public property surface didn't change. Verified against a live server with a standalone harness: a full table scan, a PK-indexed lookup, and an indexed `UPDATE` each produced exactly the expected sequential/indexed read and record-operation deltas.
- [x] **Wire encryption / auth plugin status** — the "connection properties" dialog (`MarathonMasterProperties.pas`/`.lfm`, `TfrmMasterProperties.CreateModifyConnection`) turned out to actually be the connection *editor*, not a live-status view, and never read the live `TIBDatabase` at all. Added two read-only fields (Auth Method / Remote Protocol) populated from `Connection.Connection.AuthenticationMethod`/`.RemoteProtocol` when connected (verified live: `Srp256` / `TCPv4`), showing "(not connected)" otherwise - "Properties" can be opened on a never-connected entry, and those calls raise if the attachment isn't live. No dedicated encryption/wire-crypt status exists in this IBX version's `IAttachment` interface (checked `IB.pas` - only a low-level, unwrapped `fb_info_wire_crypt` info-request code), so auth method / protocol is the full extent of what's available here.

## Phase 4 — Result Grid Export

- [x] **JSON / Markdown / TSV export** — `Globals.pas`'s `ExportGrid` gained `ExType.ExType` values 2 (JSON array-of-objects, NULLs emitted as `null`, numeric fields unquoted), 3 (Markdown pipe table), and 4 (Tab Separated Values), alongside the existing 0 (separated values) and 1 (insert statement). `SaveFileFormat.pas`/`.lfm`'s format combo grew matching entries ('JSON', 'Markdown Table', 'Tab Separated Values') plus a blank `nbpNone` options page for formats with no separator/qualifier/table-name settings to configure — `SQLForm.pas`'s and `EditorStoredProcedure.pas`'s `DoExport` needed no changes since they already pass `cmbFormat.ItemIndex` straight through as `ExType.ExType`.
- [x] **Client-side result filter** — a `Filter:` `TEdit` next to the results grid's navigator/refresh panel in `SQLForm.pas` (`tsResultsView` → `pnlNavigator`), wired to `qrySQLStatement.Filtered`/`OnFilterRecord` (case-insensitive substring match across all non-BLOB fields). Confirmed via `IBQuery.pas`/`IBCustomDataSet.pas` that `TIBQuery` does not override `SetFiltered` to re-query (unlike sibling `TIBDataSet`), so this is genuinely in-memory — no round trip to Firebird. Filter box and `Filtered` both reset in `qrySQLStatementAfterOpen` so a fresh query run always starts unfiltered.

## Phase 5 — Database Maintenance

MWASoftware's IBX ships a full Services API binding (`IBXServices.pas`, already
vendored in `lib/ibx4lazarus`) that nothing in Marathon currently uses.

- [x] **Maintenance dialog** — `MaintenanceDialog.pas`/`.lfm` (`TfrmMaintenance`), opened via Tools > Database Maintenance. Sweep and Validate/Repair (full validation, ignore checksums, mend, kill shadows, read-only check) run through `TIBXValidationService`/`TIBXServicesConnection` (`ConnectUsing` + `SetDBParams` reusing the existing `TIBDatabase`'s connection and credentials, no separate login UI). `SET STATISTICS INDEX` turned out **not** to be a Services API operation at all (confirmed by grepping the whole `IBXServices.pas` for it) — it's plain DSQL, so the Index Statistics tab lists indexes from `RDB$INDICES` and runs it as ordinary `TIBQuery.ExecSQL`, one index at a time. Verified live: Sweep, `SET STATISTICS INDEX`, and Backup/Restore (below) all succeed against a running server; Validate correctly raises Firebird's own "secondary server attachments cannot validate databases" error when the app's own connection is still attached (expected — Firebird requires exclusive access for validate/repair) and is caught and reported in the dialog's log/message box rather than crashing.
- [x] **Backup/Restore via Services API** — Marathon had no backup/restore at all before this (only a dead, always-disabled "Backup" tree node stub in `MarathonProjectCache.pas`). Backup uses `TIBXClientSideBackupService.BackupToFile` (streams over the wire to a local file, optionally metadata-only). Restore uses `TIBXClientSideRestoreService.RestoreFromFile`, deliberately **restore-to-new-file only** (`Options := [CreateNewDB]`, hard-blocked if the target path already exists) rather than exposing a "replace the live database in place" option — replacing a database Marathon has open elsewhere is a much bigger, riskier change to the app's connection lifecycle than this pass was scoped for.

## Phase 6 — SQL Editor Modernization

- [x] **Firebird 3/4/5 keyword highlighting** — `MenuModule.lfm`'s shared `synHighlighter: TSynSQLSyn` was set to `SQLDialect = sqlInterbase6`, a ~180-keyword InterBase 6-era list missing `RETURNING`, `OVER`, `ROW_NUMBER`, `DECFLOAT`, `BOOLEAN`/`TRUE`/`FALSE`/`UNKNOWN`, `OFFSET`, `RECURSIVE`, `LATERAL`, `WINDOW`, `PARTITION`, `MATCHED`, etc. Lazarus's SynEdit package ships fully populated, already-correct `sqlFirebird25`/`sqlFirebird30`/`sqlFirebird40` keyword sets (`synhighlightersql.pas`) that were simply never selected — switched to `sqlFirebird40` (superset of the others, and highlighting an identifier as a keyword is harmless even against an older server).
- [x] **Execution plan tree view** — this turned out to be two separate things, one true bug and one format-compatibility gap:
  - **Bug**: the plan text fetch in `SQLForm.pas`'s `DoExecute` was `{$IFNDEF FPC}edPlan.Text := qrySQLStatement.Plan;{$ENDIF}` - on this FPC port the fetch was skipped entirely (`TIBQuery` has no `Plan` property, only a `GetPlan` method), so the plan tab showed nothing. Fixed to `edPlan.Text := qrySQLStatement.GetPlan;` (unconditional, no method to gate on FPC).
  - **Format gap**: fixing the fetch revealed the existing tree-builder (`PlanUnit.pas`'s `TPlanObject.FillTree`, fed by `SQLYacc.pas`'s `ptPlan` grammar) parses the *classic* single-line `PLAN (T INDEX (IX))` format - but this vendored IBX/fbintf's `TIBQuery.GetPlan` (via `IStatement.getPlan(status, detailed=True)`, hardcoded in `fbintf`'s `FB30Statement.GetPlan`) only ever returns Firebird 3+'s newer indentation-structured "explained" format (`Select Expression / -> Filter / -> Table ... Full Scan`), which the yacc grammar can't parse at all - so the tree stayed empty even after the fetch fix. Added `PlanUnit.FillTreeFromExplainedPlan`, a small indentation-depth tree builder for this actual format (no grammar needed - it's already whitespace-structured), wired in place of the yacc path in `SQLForm.pas`. `Table ... Full Scan` nodes get a red/pink `TDiagramNode.Color`, `Access By ID`/`Index "..."` nodes get green - `DiagramTree.pas`'s `DrawNode` previously ignored `Color` entirely (hardcoded `clWindow` fill) so this also required making it actually honor the property. Verified against a live server: single-table natural scan, indexed join, and a plain non-indexed filter all produce correctly-nested, correctly-colored trees.

---

## Explicitly out of scope

Adapted-but-rejected FlameRobin roadmap items, and why:
- **MCP server tools** (`explain_query`, `list_active_sessions`, etc.) — FlameRobin's MCP integration is a C++ process feature; there's no equivalent infrastructure here and it's a separate, large undertaking.
- **Vector/AI embedding support**, **temporal tables**, **SQL schemas (FB6)** — tied to Firebird 6 engine features not yet in general use; revisit once Firebird 6 is closer to release and there's a concrete need.
- **Schema comparison/migration generator** — valuable, but a substantially larger feature (needs a full schema-diff engine) than anything else on this list; worth its own future roadmap entry once Phases 1–2 are done.

---

## Status

| Phase | Feature | Status |
|---|---|---|
| 1 | Single-object DDL tab | **Done** |
| 1 | Bulk Extract Metadata wizard | **Done** |
| 1 | DDL extraction test coverage | **Done** |
| 2 | Script as CREATE (tree) | **Done** |
| 2 | Script as SELECT/INSERT/UPDATE/DELETE | **Done** |
| 2 | Script as EXECUTE PROCEDURE | **Done** |
| 3 | Live Session Monitor | **Done** |
| 3 | Cancel Statement / Disconnect Attachment | **Done** |
| 3 | Query performance stats via MON$ | **Done** |
| 3 | Wire encryption / auth plugin status | **Done** |
| 4 | JSON/Markdown/TSV export | **Done** |
| 4 | Client-side result filter | **Done** |
| 5 | Maintenance dialog (IBX Services) | **Done** |
| 5 | Backup/Restore via Services API | **Done** |
| 6 | Keyword highlighting refresh | **Done** |
| 6 | Execution plan tree view | **Done** |
