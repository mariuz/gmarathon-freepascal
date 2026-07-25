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
- [ ] **Bulk "Extract Metadata" wizard** — `MarathonIDE.pas`'s `opExtractDDL` tree action and `ToolsMetadataExtract` (multi-object DDL export to files, with dependent-object inclusion, wrap/decimal-format options) still show "Not implemented for FPC". `MetaExtractUnit.pas`'s `TIBMetaExtract` (the non-visual file-writing engine) is plain Pascal like `DDLExtractor` and should port easily, but the wizard *dialog* itself, `GlobalMigrateWizard.pas`/`TfrmGlobalMigrateWizard`, has no `.lfm` at all (Delphi `.dfm` only) and uses old rmControls units (`rmBtnEdit`, `rmBaseEdit`, `rmNotebook2`) that don't exist in this tree anymore — it needs a from-scratch Lazarus form built against `rmCompatControls.pas`'s replacements, not just a `uses`-clause fix. Bigger than the single-object DDL tab; do this as its own session.
- [ ] **DDL round-trip test coverage** — extend `test/ibx_smoke_test.lpr` (or a new smoke test) to extract DDL for a view, a stored procedure, and a trigger, not just a plain table, so CI catches regressions in each `DDLExtractor` code path.

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
- [ ] **Query performance stats, take 2** — `IBPerformanceMonitor.pas`'s per-relation indexed/non-indexed read counters are stubbed out (see CLAUDE.md) because they relied on a raw `isc_db_handle` IBX doesn't expose. `MON$RECORD_STATS` / `MON$IO_STATS` (joined to `MON$STATEMENTS`) may be able to drive `SQLForm.pas`'s existing (currently-empty) "Query Performance Analysis" chart through ordinary SQL instead — worth checking before writing new UI.
- [ ] **Wire encryption / auth plugin status** — `TIBDatabase`/IBX's `Attachment` interface exposes `AuthenticationMethod` and `RemoteProtocol` (confirmed present in `IBDatabase.pas`); surface these in the connection properties dialog.

## Phase 4 — Result Grid Export

- [x] **JSON / Markdown / TSV export** — `Globals.pas`'s `ExportGrid` gained `ExType.ExType` values 2 (JSON array-of-objects, NULLs emitted as `null`, numeric fields unquoted), 3 (Markdown pipe table), and 4 (Tab Separated Values), alongside the existing 0 (separated values) and 1 (insert statement). `SaveFileFormat.pas`/`.lfm`'s format combo grew matching entries ('JSON', 'Markdown Table', 'Tab Separated Values') plus a blank `nbpNone` options page for formats with no separator/qualifier/table-name settings to configure — `SQLForm.pas`'s and `EditorStoredProcedure.pas`'s `DoExport` needed no changes since they already pass `cmbFormat.ItemIndex` straight through as `ExType.ExType`.
- [x] **Client-side result filter** — a `Filter:` `TEdit` next to the results grid's navigator/refresh panel in `SQLForm.pas` (`tsResultsView` → `pnlNavigator`), wired to `qrySQLStatement.Filtered`/`OnFilterRecord` (case-insensitive substring match across all non-BLOB fields). Confirmed via `IBQuery.pas`/`IBCustomDataSet.pas` that `TIBQuery` does not override `SetFiltered` to re-query (unlike sibling `TIBDataSet`), so this is genuinely in-memory — no round trip to Firebird. Filter box and `Filtered` both reset in `qrySQLStatementAfterOpen` so a fresh query run always starts unfiltered.

## Phase 5 — Database Maintenance

MWASoftware's IBX ships a full Services API binding (`IBXServices.pas`, already
vendored in `lib/ibx4lazarus`) that nothing in Marathon currently uses.

- [ ] **Maintenance dialog** — sweep, `SET STATISTICS INDEX` (index selectivity recalculation), and validate/repair, driven through `TIBXServices` components instead of shelling out to `gfix`/`gstat`.
- [ ] **Backup/Restore via Services API** — check whether Marathon's current backup/restore path already uses IBX services or still shells out; if the latter, migrating to `IBXServices.pas` gets progress callbacks for free.

## Phase 6 — SQL Editor Modernization

- [ ] **Firebird 3/4/5 keyword highlighting** — audit `SynHighlighterSQL`'s keyword list against modern Firebird reserved words (`RETURNING`, window functions, `DECFLOAT`, boolean literals, etc.) — this project targets Firebird generally, so no version gating is needed, just a keyword-list refresh.
- [ ] **Execution plan tree view** — `SQLForm.pas` already fetches `qrySQLStatement`'s plan text (`FShowPlan`); rendering it as an indented tree (`NATURAL` vs `INDEX` highlighted) instead of raw text is a UI-only enhancement.

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
| 1 | Bulk Extract Metadata wizard | Not started |
| 1 | DDL extraction test coverage | Not started |
| 2 | Script as CREATE (tree) | **Done** |
| 2 | Script as SELECT/INSERT/UPDATE/DELETE | **Done** |
| 2 | Script as EXECUTE PROCEDURE | **Done** |
| 3 | Live Session Monitor | **Done** |
| 3 | Cancel Statement / Disconnect Attachment | **Done** |
| 3 | Query performance stats via MON$ | Not started |
| 4 | JSON/Markdown/TSV export | **Done** |
| 4 | Client-side result filter | **Done** |
| 5 | Maintenance dialog (IBX Services) | Not started |
| 6 | Keyword highlighting refresh | Not started |
