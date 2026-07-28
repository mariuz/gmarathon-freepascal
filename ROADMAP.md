# Marathon Roadmap

**Status:** Phases 1–6 (the original IDE/productivity roadmap) are complete.
Phase 7 — **Firebird 3/4/5/6 engine feature support** — is newly opened after
auditing this codebase against [FlameRobin's roadmap](https://github.com/mariuz/flamerobin/blob/master/ROADMAP.md),
the Firebird release notes, and a live Firebird 6 server. That audit found the
port had **no support at all** for any column type added since Firebird 2.5,
which was producing unrunnable DDL — now fixed — plus a long tail of
genuinely-missing FB4/5/6 features tracked below.

This roadmap adapts ideas from FlameRobin — another Firebird admin/IDE tool —
to what's realistic for Marathon: a Lazarus/FreePascal codebase on IBX
(`lib/ibx4lazarus` + `lib/fbintf`), with no unit test framework beyond the
`test/ibx_smoke_test.lpr` integration check. Items are picked for being
genuinely valuable *and* buildable without a rewrite — FlameRobin's
C++/wxWidgets-specific items (MCP servers, its own DAL abstraction) are left out.

Two structural differences from FlameRobin shape what is and isn't cheap here,
and are worth stating up front because they explain several deferrals below:

- **Syntax highlighting is not ours.** FlameRobin maintains its own
  `firebird_keyword_sets.hpp` with per-version keyword lists. Marathon uses
  Lazarus's shipped `SynHighlighterSQL`, whose `TSQLDialect` enum stops at
  `sqlFirebird40` — there is no FB5/FB6 keyword set to select. Anything past
  FB4 keywords means adding keywords locally or upstreaming to Lazarus.
- **The Services API layer is vendored, not ours.** FB5 features like parallel
  backup/restore workers need SPB parameters that this IBX version's
  `IBXServices.pas` does not expose, so they need a submodule patch (or an
  upstream contribution) rather than app-level code.

Status legend: `[x]` done, `[~]` in progress, `[ ]` not started.
Firebird ODS mapping used below: FB 2.5 → ODS 11.1, FB 3.0 → ODS 12.0,
FB 4.0 → ODS 13.0, FB 5.0 → ODS 13.1, FB 6.0 → ODS 14.x.

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

Implementation notes for future "Script as ..." additions: `TGSSCacheOp` (`MarathonProjectCacheTypes.pas`) has `opScriptSelect/Insert/Update/Delete/Create/Execute/Alter/Drop/Merge`; gating by object type is in `TMarathonCacheObject.CanDoOperation` (`MarathonProjectCache.pas`); the tree wiring is `TfrmDatabaseExplorer.CanScriptXxx`/`DoScriptXxx` (`DatabaseManager.pas`) → `IMarathonForm` (`MarathonInternalInterfaces.pas`, default no-op bodies in `BaseDocumentForm.pas`) → `TAction`s on `frmMarathonMain` (`MarathonMain.pas`/`.lfm`) → the "Script As" submenu in `mnuTree` (`MenuModule.lfm`/`.pas`) → `TMarathonIDE.CacheEventHandler`'s `opScriptXxx` case (`MarathonIDE.pas`), which calls the `ScriptAsXxx` generator functions (now in `src/Common/ScriptAs.pas`, deliberately LCL-free so `test/ibx_smoke_test.lpr` can cover them) and `ScriptAsOpenEditor` (still in `MarathonIDE.pas`, since it opens a form).

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

## Known issue: `WITH TIME ZONE` columns and disconnect (vendored IBX)

Reading a Firebird 4 `TIMESTAMP`/`TIME WITH TIME ZONE` column through
`TIBQuery` leaves the attachment in a state where disconnecting raises
`EObjectCheck: Object reference is Nil`, from inside IBX's own
`FBTransaction.Commit` ← `EndAllTransactions` ← `Disconnect`.

Narrowed by elimination: an integer column and a plain `TIMESTAMP` disconnect
cleanly, both time-zone types do not. It is not schema qualification, not the
prepared statement, not global temporary tables, and not the query or
transaction lifetime — freeing both beforehand does not help, which places the
residue on the attachment. `test/timezone_disconnect_repro.lpr` reproduces it
in twenty lines and is kept so it can be re-run against a future
`ibx4lazarus`.

**What this affected:** the Session Monitor selects `MON$TIMESTAMP`, which is
`TIMESTAMP WITH TIME ZONE` from Firebird 4 on — so opening it and then
disconnecting faulted. Its queries now cast that column to text on the server,
which sidesteps the defect and shows the IANA zone name into the bargain.

**What is still exposed:** arbitrary SQL in the editor. A user query selecting
a `WITH TIME ZONE` column is not rewritten, so the connection it ran on still
faults when closed. Fixing that properly needs the IBX layer, not this
codebase — but the consequence is now contained rather than fatal, and a fix
has been proposed upstream: **https://github.com/MWASoftware/fbintf/pull/7**,
carried here as `patches/fbintf-0001-transaction-use-after-free.patch`, with
`lib/fbintf` pinned to a fork carrying it so a fresh checkout builds with the
fix rather than needing a manual patch step. The
cause is a use-after-free: reading a time zone value creates
`TFB30TimeZoneServices`, which starts an internal transaction and registers
itself on it; at disconnect `DoDefaultTransactionEnd` calls its
`TransactionEnding`, which clears the last reference to that transaction — the
interface list holds raw object pointers, not counted references — so the
object is destroyed while the method is still running and the `Commit` at its
end operates on freed memory. With the patch applied all four column types
disconnect cleanly.
`src/Common/SafeDisconnect.pas` closes a connection without letting a fault in
the database layer propagate: the message is handed back, the caller's cleanup
still runs (before this, the fault abandoned the tree cleanup and left a closed
connection displayed as open), and disconnecting from the tree reports it once
rather than taking the application down. `test/ibx_smoke_test.lpr` drives a
throwaway connection into the fault deliberately and checks it is contained —
and if IBX is ever fixed, that test says so instead of quietly passing.

## Phase 7 — Firebird 3/4/5/6 Engine Feature Support

Everything above this point was about IDE features. This phase is about the
*engine*: Marathon's metadata layer was written against InterBase 6 / Firebird
1.x and had never been taught about anything newer. An audit against a live
Firebird 6 server found that the entire post-FB2.5 type system was unmapped —
not merely unsupported in the UI, but actively generating **DDL that will not
execute**. Those correctness bugs are fixed; the remaining items are real
feature work.

### Correctness fixes (done)

- [x] **Modern column types in DDL generation (FB3 `BOOLEAN`, FB4 `DECFLOAT`, `INT128`, `WITH TIME ZONE`)** — `ConvertFieldType` (which exists in two copies: `src/Source/Globals.pas` for the editors, `src/MetaExtract/MetaExtractGlobals.pas` for `DDLExtractor`/the bulk wizard) knew only the 12 InterBase-era `blr_*` codes. Every newer type fell through leaving `Result` empty, so callers emitted the *internal domain name* in its place — a table with a `BOOLEAN` column extracted as `create table T(C_BOOL RDB$29, ...)`, which is unrunnable. Verified against a live server before/after; all types now round-trip byte-identically (`RDB$FIELD_TYPE` + `RDB$FIELD_SUB_TYPE` match after re-executing the generated DDL). Type codes were confirmed empirically rather than copied from a header, which caught a genuine trap: **`INT128` is field type 26** (historically `blr_dec_fixed`), sharing its code with `NUMERIC(38,x)`/`DECIMAL(38,x)` via `RDB$FIELD_SUB_TYPE` 0/1/2 exactly like `blr_short`/`blr_long`/`blr_int64` — *not* the `blr_int128` value of 32 used in the wire/BLR layer, which is what a header-driven implementation would have picked.
- [x] **`BIGINT` round-trip fidelity** — `blr_int64` sub_type 0 emitted `decimal(18, 0)`. Both store as int64 scale 0, but re-running that DDL changed `RDB$FIELD_SUB_TYPE` from 0 to 2, so a backup/restore-by-script silently altered metadata. Now emits `bigint`.
- [x] **Expression indexes emitted invalid SQL** — an expression index (`COMPUTED BY`, FB1.5+) has no `RDB$INDEX_SEGMENTS` rows, so the column-list loop produced nothing and the extractor wrote `create index IX on TBL();` — a syntax error. Now reads `RDB$EXPRESSION_SOURCE` and emits `computed by (...)`.
- [x] **FB5 partial (conditional) indexes lost their `WHERE`** — `RDB$CONDITION_SOURCE` was never read, so `create index IX on T(C) where C is not null` extracted as an unconditional index over the whole table: a *different* index, not a cosmetic difference. Now appended, read via `FindField` since the column does not exist before FB5.
- [x] **Identity columns (FB3) lost on extraction** — a column declared `GENERATED ALWAYS|BY DEFAULT AS IDENTITY` extracted as a plain `integer`, so a table restored from the generated script silently stopped auto-generating values. `RDB$RELATION_FIELDS.RDB$IDENTITY_TYPE` (0 = ALWAYS, 1 = BY DEFAULT) is now read, along with `START WITH`/`INCREMENT BY` from the backing generator named by `RDB$GENERATOR_NAME`, emitted only when they differ from Firebird's 1/1 defaults. Verified round-trip: identity type, initial value and increment all match after re-executing.
- [x] **`SQL SECURITY` (FB4) lost on extraction** — `RDB$RELATIONS.RDB$SQL_SECURITY` is now emitted as `sql security definer|invoker`. It is nullable, meaning "inherit the database default", so a NULL emits nothing rather than guessing.
- [x] **ODS gating inside `DDLExtractor`** — the above need columns that do not exist on older servers, and naming a missing column is a hard query error rather than a NULL, so the extractor reads the attachment's ODS itself (`ODSAtLeast`) and only selects them when present. This keeps it self-contained: callers do not have to pass version information in.
- [x] **PSQL functions (FB3) extracted as gibberish** — Firebird 3 replaced external UDFs with PSQL functions, and both live in `RDB$FUNCTIONS`, so the "User Defined Functions" node listed PSQL functions and ran them through the `DECLARE EXTERNAL FUNCTION` path. Their arguments are typed through `RDB$FIELD_SOURCE` rather than `RDB$FIELD_TYPE`, so the type lookup saw NULL and — because `ConvertFieldType` never initialised its result (see below) — the output contained *a previously-built SQL statement*. Now branches on `RDB$LEGACY_FLAG` and emits proper `CREATE OR ALTER FUNCTION ... RETURNS ... AS <body>` from `RDB$FUNCTION_SOURCE`; verified by round-trip (the recreated function returns the same value). Since FB4 deprecated external UDFs and FB5 disables them by default, in practice nearly everything in this node is a PSQL function, so this path was broken for most modern databases.
- [x] **`ConvertFieldType` returned uninitialised memory** — the root cause of the above, and a latent hazard everywhere else: with no `Result := ''`, any unrecognised `ftype` (notably NULL, which arrives as 0) fell through every `case` branch and returned whatever string memory happened to be there. Both copies now initialise. FPC's own `(5033) Function result does not seem to be set` warning had been flagging this.
- [x] **Packaged functions listed as standalone objects** — a function belonging to a package cannot be created or dropped on its own, so it does not belong in the top-level list. Both the object tree and the bulk wizard now filter on `RDB$PACKAGE_NAME is null`, gated on ODS 12 since that column does not exist earlier.
- [x] **Trigger event clauses beyond the six single-action forms** — `RDB$TRIGGER_TYPE` was decoded with a `case` covering only 1..6, so anything else emitted *no event clause at all*. Two common cases were therefore invalid SQL: a multi-action trigger (`before insert or update` — entirely ordinary) and a database-level trigger (`on connect`, FB2.1+), which additionally emitted `for ` with an empty relation name. The encoding is now decoded properly: odd = BEFORE, even = AFTER, and `(type + 1 - after) div 2` reads in base 4 as up to three action slots (1=INSERT, 2=UPDATE, 3=DELETE). Derived and verified empirically against a live server across 1..6, 17, 18, 25, 27, 113 and the database-level 8192..8196, and round-tripped — every recreated trigger reports an identical `RDB$TRIGGER_TYPE`.
- [x] **`SQL SECURITY` on procedures, functions and triggers** — completes the table work above; one shared helper now serves all four object types, still treating NULL as "inherit the database default" and emitting nothing.
- [x] **CI regression coverage for all of the above** — `test/ibx_smoke_test.lpr` now creates and extracts modern-type columns and both index kinds, gated on `RDB$GET_CONTEXT('SYSTEM','ENGINE_VERSION')` so it exercises what the connected server actually supports (CI runs FB3.0 → `BOOLEAN` path; a local FB6 exercises everything). It also fails outright if any extracted DDL contains an `RDB$` domain name, which is the generic signature of an unmapped type.

### Firebird 4 (ODS 13.0)

- [x] **Long identifiers (63 chars)** — audited: no hard-coded 31-char truncation anywhere in the port; identifiers flow through dynamic strings, so this already works.
- [x] **FB4 keyword highlighting** — `SQLDialect = sqlFirebird40` (Phase 6).
- [x] **Named time zone display** — turned out to matter for more than readability. IBX surfaces a FB4 `WITH TIME ZONE` column as a plain `ftDateTime` and reduces the zone to a numeric offset, so `Europe/Berlin` reaches the grid as `+02:00`. Casting the column to `VARCHAR` on the server keeps the IANA name — and, as it happens, is also the way round the IBX defect recorded below, since the cast means no `WITH TIME ZONE` value is ever handed to the client. Marathon's own `MON$` queries in the Session Monitor now do this, so its three grids show real zone names. `varchar(64)`, not 40: a timestamp with fractional seconds plus the longest IANA name overflows a narrower cast and Firebird raises a truncation error rather than shortening it — the smoke test checks the width against the longest name `RDB$TIME_ZONES` actually holds. Arbitrary user SQL in the editor is not rewritten, so a `select ts_col from t` there still shows an offset.
- [x] **FB3/FB4 values in the result grid and JSON export** — verified what these types look like once IBX has them: `DECFLOAT`, `INT128` and `NUMERIC(38,x)` all arrive as BCD fields and `BOOLEAN` as `ftBoolean`, with correct values including the full 128-bit range. That exposed a bug in the Phase 4 JSON exporter, which handled only the plain integer and float types and so emitted every one of these as a *quoted string* (`"1.5"`, `"True"`) instead of a JSON number or boolean. Now emitted unquoted, via `AsString` rather than `AsFloat` — routing a `DECFLOAT` or `INT128` through a float would silently destroy exactly the precision those types exist to provide. Confirmed by exporting 2^127-1 and parsing it back as an exact integer.
- [x] **Replication monitoring** — a *Replication* branch now appears under each connection, listing `RDB$PUBLICATIONS` and gated on ODS 13 (empty on FB3 and earlier, where the table does not exist). It is deliberately the one header here that does **not** filter on `RDB$SYSTEM_FLAG = 0`: the built-in `RDB$DEFAULT` publication is flagged as a system object, and since Firebird 4/5/6 have no `CREATE PUBLICATION` statement it is the only row the table ever holds — the usual filter would have left the branch permanently empty, which is how this looked at first. `TDDLExtractor` gained `ddlPublication`, and because the publication is unnamed at the DDL level its whole surface is `ALTER DATABASE`: enable/disable from `RDB$ACTIVE_FLAG`, then either `include all to publication` (when `RDB$AUTO_ENABLE` is set) or an explicit `include table a, b to publication` built from `RDB$PUBLICATION_TABLES`. `INCLUDE ALL` opts in every table created from then on, so it has to be reproduced as such rather than as the current member list — but a table can still be excluded afterwards without clearing the flag (verified live), so any user table missing from the member list is named in a following `exclude table`. Right-click → *Script As > CREATE* on a publication opens a SQL editor with that script; a row under any other publication name emits a comment saying this server has no DDL for named publications. Verified against a live FB6 server, round-tripping both shapes (auto-enable + an exclusion; explicit list, disabled) into a fresh database and re-extracting byte-identical output, plus the pristine state (`disable publication` alone) and a non-existent name (empty). `test/ibx_smoke_test.lpr` covers it, gated on engine major ≥ 4 — including a table does not switch replication on, and the test excludes it again to leave the database as found.
- [x] **Database encryption status** — shown in the connection properties dialog beside the auth method, protocol and server version from Phase 3. The note recorded here previously — that `IAttachment` exposes no encryption accessor and this needs the raw info item — was half right and led away from the answer. The raw route does exist (`GetDBInformation(fb_info_crypt_state)`) and the server does answer it: the item comes back as type 134, size 4. But this fbintf's DB-information parser (`FBOutputBlock.pas`) classifies only the item codes it knows, and that one is not among them, so it lands untyped and *every* accessor rejects it — `getAsBytes` included, so the bytes cannot even be decoded by hand. **`MON$DATABASE.MON$CRYPT_STATE` carries the same state** and needs nothing outside this codebase. Its meanings are published in `RDB$TYPES` (NOT ENCRYPTED / ENCRYPTED / DECRYPT IN PROGRESS / ENCRYPT IN PROGRESS), so the value is decoded by joining that table the same way the Session Monitor decodes `MON$STATE` — a state added by a later Firebird shows its own name rather than being mislabelled or falling back to a bare number. Verified live, and covered in `test/ibx_smoke_test.lpr`, which also asserts all four states are documented. Only an unencrypted database was available to test against, so the ENCRYPTED path is exercised through the catalogue rather than against a genuinely encrypted database.
- [x] **`SCROLL` attribute on cursors** — audited: nothing to do, it already works. `SCROLL` is part of a `DECLARE <name> SCROLL CURSOR FOR (...)` statement *inside* a PSQL body, and Firebird stores that body as source text in `RDB$PROCEDURE_SOURCE`/`RDB$TRIGGER_SOURCE`, which `TDDLExtractor` emits verbatim. There is no separate metadata column that could be dropped. Confirmed end-to-end on Firebird 6: a procedure declaring a scroll cursor extracts with the `scroll` keyword intact. (The syntax is name-then-keyword, `declare C scroll cursor for (...)` — `declare scroll cursor C` is rejected.)
- [x] **Read-committed read-consistency isolation** — the Session Monitor's Transactions tab showed `MON$ISOLATION_MODE` as a bare code number, so FB4's new mode 4 read as "4". Rather than hard-code a decode table (which would go stale the next time Firebird adds a mode), the three `MON$` grids now `left join RDB$TYPES`, which is where the server itself publishes the meaning of every code — `MON$ISOLATION_MODE`, `MON$STATE` and `RDB$OBJECT_TYPE` all have rows there. A code the running server does not know about falls back to its number via `coalesce` instead of being mislabelled, and this needs no ODS gate since it names no version-specific column. That also settled the mapping without guessing: mode 4 is `READ_COMMITTED_READ_CONSISTENCY`, and modes 2/3 (`READ_COMMITTED_VERSION` / `_NO_VERSION`) came from the same catalogue — worth noting because they were *not* reproducible on the test server, since FB4+ ships `ReadConsistency = 1` and silently upgrades both legacy read-committed sub-modes to 4, verified live by asking for each in turn and getting 4 back every time. The tab also gained readable Read Only and Lock Timeout columns. Aliases are unquoted upper case because IBX normalises a field name to that anyway, so a prettier quoted alias would not survive to the grid.

### Firebird 5 (ODS 13.1)

- [x] **Partial index DDL** — see correctness fixes above.
- [x] **`SKIP LOCKED` keyword highlighting** — unblocked, and the ceiling described at the top of this file turns out to be lower than it looked. `SKIP` is already in Lazarus's `sqlFirebird40` list (486 words, which covers most of the modern surface); only `LOCKED` was missing, so the construct was half-highlighted. `TSynSQLSyn.DoAddKeyword` is `private`, i.e. unit-scoped, so no descendant can add a real `tkKey` from outside SynEdit — but the published `TableNames` property feeds the same keyword hash and does work from outside, adding words as `tkTableName`. `src/Source/FirebirdKeywords.pas` uses it and copies the reserved-word styling onto `TableNameAttri` so the result is visually identical; Marathon does not otherwise use `TableNames` (the `gTableNames` setting drives code completion, not the highlighter), so nothing competes for that attribute. Applied after `LoadFromRegistry` in both the main window and the Options preview, since that call restores the colours being copied. An upstream FB5/FB6 keyword set in Lazarus remains the clean fix and would let this unit shrink.
- [x] **Parallel workers in Backup / Restore / Sweep** — unblocked by patching the submodules rather than waiting. Two things were missing: `consts_pub.inc` predates Firebird 5 and defines no `isc_spb_bkp_parallel_workers` (value 21 in Firebird's own shipped header, where `isc_spb_res_parallel_workers` is the same code), and `IBXServices.pas` built its service parameter block without one. The fbintf side now defines the constants ([MWASoftware/fbintf#8](https://github.com/MWASoftware/fbintf/pull/8)) and `TIBXBackupRestoreService` gained a published `ParallelWorkers` property ([MWASoftware/ibx4lazarus#23](https://github.com/MWASoftware/ibx4lazarus/pull/23)), sent only when greater than one and the server is Firebird 5 or later — so nothing changes for existing callers or older servers, which reject the parameter. The Maintenance dialog offers a worker count on the Backup tab, defaulting to 1. Verified against a live Firebird 6.0.0 server through `TIBXClientSideBackupService`: with one worker the parameter is not sent, with four it is — checked with a temporary trace at the point it is added, since the server clamps an absurd value rather than rejecting it, so a successful backup alone proves nothing — and the resulting file restores to a working database. Sweep is not covered: it takes the parameter through a different service, and that was not exercised here.
- [x] **SQL / PSQL profiler** — Tools > SQL Profiler. `src/Common/ProfilerQueries.pas` starts, pauses, resumes and finishes a session through the `RDB$PROFILER` package, resolves where the `PLG$PROF_*` tables live, and builds the queries for sessions, statement stats and record-source stats. Three findings are baked in. **Where the tables live is not fixed**: Firebird 6 puts them in a `PLG$PROFILER` schema and they must be qualified, before schemas they sat in the default schema and must not be — so the prefix is resolved by asking the catalogue, which needs no version test. **`RDB$PROFILER.DISCARD` does not clear the tables** despite the name; it drops only what this attachment has gathered and not yet flushed. Deleting from the sessions table is what clears recorded data, and the dependents cascade with it — a "clear" button wired to `DISCARD` would look broken. **The sessions view's timestamps are `WITH TIME ZONE`** and are cast to text on the server, which both keeps the IANA zone name and avoids the IBX defect recorded above; that defect is what made this item look blocked when it was first written. `test/ibx_smoke_test.lpr` drives a real session end to end: the package is detected, a session records and returns an id, the prefix resolves, the sessions and both stats views read back, the zone name survives, `DISCARD` is shown *not* to remove flushed data, and deleting the session is shown to cascade. `ProfilerWindow.pas`/`.lfm` puts Start / Pause / Resume / Finish / Refresh / Clear over three grids, modelled on the Session Monitor and picking its connection the same way — profiling is per attachment, so the window has to be told which one it is recording. The buttons are a small state machine (pause only while recording, resume only while paused), which `test/form_load_test.lpr` checks along with the grid bindings, because getting it wrong leaves buttons that do nothing or double-start a session. Finishing is also what flushes, so the grids refresh from it; before any session has been finished the plugin has not created its tables yet and the window says so rather than showing an error. Clear deletes the sessions rather than calling `DISCARD`, for the reason above. On a server without the profiler the window opens inert and says which version would be needed.
- [x] **`MON$COMPILED_STATEMENTS` visibility** — a fourth Session Monitor tab, gated on ODS 13.1 (FB5) and simply hidden on older servers, since querying a table that does not exist is a hard error. Unlike the other three tabs this is a server-wide *cache* rather than a view of live activity — confirmed live that rows outlive the attachment that compiled them — so it answers "what does Firebird still have compiled, and what plan did it pick". A splitter-resizable pane under the grid shows the selected row's `MON$SQL_TEXT` and `MON$EXPLAINED_PLAN`, which is the part a grid cell cannot render (both arrive as `ftMemo`). `MON$OBJECT_NAME`/`MON$OBJECT_TYPE`/`MON$PACKAGE_NAME` are selected and decoded, but came back NULL for every probe on the FB6 test server — including a stored procedure querying the table from inside its own body — so in practice this surfaces top-level DSQL, not PSQL routines.
- [x] **Multi-row `RETURNING`** — the concern turned out to be aimed at the wrong case, and the investigation found a worse one next to it. A *multi-row* `RETURNING` needs no work at all: Firebird gives it a real cursor and reports it as `SQLSelect`, so `SQLForm.pas` already takes the ordinary `Open` path and shows every row (verified live for `insert ... select ... returning`, `update ... returning` and `delete ... returning`). The smoke test now asserts that statement type, so an IBX bump that changes it is caught rather than silently losing rows. The real gap was the **singleton** form. Firebird executes `insert ... values ... returning` — and equally `execute procedure` against a procedure with output parameters — "with output" rather than through a cursor, reporting `SQLExecProcedure`. `TIBCustomDataSet.InternalOpen` only builds a cursor when the type is `SQLSelect`, so `TIBQuery.Open` yields *no rows at all* for these, and `TIBQuery` does not re-publish the `QSelect` property that would expose its inner `TIBSQL`. The editor's `else` branch therefore ran them through `ExecSQL` and dropped whatever came back: the classic `insert ... returning ID` to fetch a generated key reported "Statement Execution Successful" and showed nothing. Fixed in `src/Common/SingletonQuery.pas` (kept LCL-free so the smoke test can reach it): the statement is prepared, and if it has no output columns the function returns nil *without executing*, so the caller can run it normally and it never happens twice; otherwise it runs once through its own `TIBSQL` and copies the row into a `TBufDataset` the results grid is pointed at. Values go through `AsString` for the same reason the JSON exporter does — a `DECFLOAT` or `INT128` routed through a float would lose exactly the precision it exists for — and NULL stays NULL. Export and the can-export test now follow whichever dataset the grid is showing. Writing the test paid for itself immediately: it caught that `TFieldDefs.Find` *raises* when a name is absent instead of returning nil, which is the opposite of what the duplicate-name guard needed (`IndexOf` is the right call). It also showed that guard is only a safety net — Firebird already hands back distinct names (`ID`, `ID1`) for `returning ID, ID`.
- [x] **Inline ODS upgrade** — offered as its own button on the Maintenance dialog, using Firebird 5's in-place upgrade rather than a backup and restore. The note here previously said no `isc_spb_rpr_*` constant existed for it. **That was wrong**: the search had been against the vendored `consts_pub.inc`, which predates Firebird 5, not against Firebird's own shipped header, where `isc_spb_rpr_upgrade_db` is `0x1000`. Both submodules are patched — the constant in fbintf ([#8](https://github.com/MWASoftware/fbintf/pull/8)), and `UpgradeODS` appended to `TValidateOption` in ibx4lazarus ([#23](https://github.com/MWASoftware/ibx4lazarus/pull/23)), sent only to a Firebird 5 or later server. It is a separate button rather than another checkbox beside Mend, because it rewrites the database irreversibly and should not be tick-able by accident; the confirmation says so and tells the user to back up and close other windows first. Verified against a live Firebird 6.0.0 server: the assembled repair parameter is `0x1000` — checked with a temporary trace, since the operation is a silent no-op on a database already at the server's format, so a successful run proves nothing on its own — and the database is left usable. **Not** exercised against a genuinely old-ODS database: the test server cannot create one, so what is proven is the plumbing, not the upgrade itself.

### Firebird 6 (ODS 14.x)

The test server for this audit is Firebird 6.0.0, so all of the following were
confirmed to exist rather than taken from release notes.

- [x] **SQL schemas** — done, both halves. (The paragraph below describes the state part-way through; the work it says is missing was finished afterwards — the editors, their frames, the drop dialog, Script As and the extract wizard all carry a schema now, and the tree opens objects in one.) The correctness half first: Marathon generates unqualified DDL and unqualified scripts, so an object list that offers something from another schema hands the user a script that will not run. The object tree and the bulk extract wizard therefore now show only what an unqualified name reaches, via `TMarathonCacheConnection.SchemaFilterClause` and the wizard's equivalent — `and (rdb$schema_name = current_schema or current_schema is null)`, gated on ODS 14 since `RDB$SCHEMA_NAME` does not exist earlier and naming it is a hard error. The null guard matters: `CURRENT_SCHEMA` is null when the search path is empty, and without it the tree would come back *empty* rather than unfiltered. Applied to all fourteen object-list queries across tables, views, domains, procedures, functions, triggers, generators, exceptions and packages. This also closes the leak noted under the system-table audit: the profiler plugin creates its tables in a `PLG$PROFILER` schema and Firebird does not flag them as system, so no system filter excluded them — on the test database the table list went from 13 relations to the user's 6, with none of the plugin's. Verified both ways in `test/ibx_smoke_test.lpr`: another schema's tables are excluded, and the user's own are not hidden. Two further pieces are now done. **Schemas are visible and scriptable**: a Schemas branch under each connection lists them (from `RDB$SCHEMAS`, gated on ODS 14, deliberately *not* filtered by the current schema — a schema is not itself in a schema, and filtering would reduce the list to the one entry the branch exists to see past), with Extract DDL, Script as Create and Drop. `ddlSchema` renders `CREATE SCHEMA … DEFAULT CHARACTER SET … SQL SECURITY …`; the character set is null for `PUBLIC` and omitted rather than guessed, since a clause naming nothing will not compile. Verified by round trip rather than by inspection: extract, drop, run what was extracted, and require the schema back *with its declared character set*. `DROP SCHEMA` is offered and Firebird refuses it while the schema still holds objects — which is the engine's job to say, not a reason to empty the schema as a side effect of confirming a dialog.

  **Schema-qualified extraction** is now possible: `TDDLExtractor.Schema` names the schema to work in, and setting it does two things at once — the catalogue queries look in *that* schema rather than through `CURRENT_SCHEMA`, and every identifier the DDL emits comes out qualified, so what is produced will actually run. Left empty, which is the default, nothing changes for any existing caller. Verified against the harder case rather than the easy one: the test extracts `SMOKE_DUP` from `SMOKE_OTHER` while a *different* table of the same name exists in the current schema, and requires the other schema's column and not the current one's — qualification on the wrong object would otherwise look like success. Removing the `Schema` assignment makes the test fail on the missing qualifier.

  **The tree now opens a schema.** Each entry under Schemas expands into the same nine object kinds a connection offers — domains, tables, views, procedures, functions, triggers, generators, exceptions, packages — listing what *that* schema holds rather than what an unqualified name reaches. `src/Common/SchemaObjects.pas` builds and runs those lists and is LCL-free, so what a schema contains is checked against a real database rather than by opening a window: the test asks for the tables of `SMOKE_OTHER` while the current schema holds a table of the same name, requires the shared name to appear and the current schema's *other* tables not to, and separately requires that a pre-Firebird-6 server is never sent `RDB$SCHEMA_NAME` at all.

  **Scripting them works.** `TScriptAsContext` carries a schema, and *Script as Create* and *Script as Drop* on an object in another schema produce statements that name it in full — the only form that runs outside the search path. Left empty, which is what every existing caller does, the generated SQL is byte-for-byte what it was; the test asserts that too, since a change there would be invisible until someone's script broke. What the tree offers on such a node is decided by the node itself, so a schema member advertises only the operations that are actually safe for it.

  **Extract Metadata on a schema** takes that schema's contents: `TIBMetaExtract.Schema` is handed to the extractor it already drives, and the wizard's own object lists filter by the same schema, so both halves — which objects are listed and how the DDL names them — follow. Empty by default, so every existing caller extracts exactly what it did.

  One honesty note on how far that is tested. `MetaExtractUnit` pulls in `Globals`, which needs the LCL, so the bulk engine cannot be driven from the console smoke test — but `form_load_test` has the LCL and now drives it: the engine is given the database's real table and view lists, and the file it writes is required to hold `CREATE TABLE` and a table named by the check. The file is then run back into a database made for the purpose and the objects counted on the far side, which is the claim worth proving: the schema this tool exports rebuilds the schema it read. The `CONNECT` the extract writes is dropped first — it names the source database, which is right for isql and wrong for a replay, and `TIBXScript` honours it. That rebuild immediately found a real defect; see below. What is verified is the extractor underneath, against a schema holding a table whose name also exists in the current schema; the engine's own part is a one-line forward of the property to it.

  **Drop works too.** The drop dialog qualifies every statement it builds when the node came from a named schema — sixteen sites, all going through one helper rather than sixteen copies. That is the one dialog where naming the wrong object destroys something, which is why it was left until the identifier could be built correctly.

  Two defects surfaced while doing it. Schema members were all created as `ctTable` whatever they were, so scripting a view or a procedure in another schema would have extracted it as a table — the cache type is what decides how an object is scripted. And dropping a generator ran `delete from rdb$generators where rdb$generator_name = …`, a raw catalogue delete matching on name alone: with schemas it could remove a generator of that name in a different one, and it was never the supported way to drop a generator regardless. Both now do the right thing, and `DROP GENERATOR` was confirmed against the server rather than assumed.

  **Done.** What was recorded here as a missing feature was a wrong answer.
  Firebird 6 made an object name unique per schema rather than per database;
  every metadata query in every editor filtered on the name alone, so on a
  database holding `EDIT_DUP` in the current schema and `EDIT_SCH.EDIT_DUP`,
  opening either showed one table carrying both schemas' columns. That was a
  defect on any Firebird 6 database with two schemas, whether or not anyone
  wanted to open a foreign-schema object.

  The foundation:
  - `src/Common/SchemaNames.pas` — the predicate that narrows a catalogue query
    to one schema, and the qualified identifier that makes generated DDL name
    the object the query found. No database, no LCL. `DDLExtractor` had worked
    both out first and now calls in here rather than keeping a second copy.
  - `src/Common/SQLIdentifiers.pas` — identifier quoting, lifted out of
    `MetaExtractGlobals` (which still declares it and delegates). Nothing about
    deciding whether a name needs double quotes involves Firebird's API, but it
    lived beside `IBHeader`, so anything wanting to spell a name had to link the
    whole IBX package — which is what had kept it out of the light harness.
  - `TfrmBaseDocumentDataAwareForm`, the base all eight editors share, gained
    `Schema`, `SchemaClause` and `QualifiedObjectName`, so converting an editor
    became appending a clause per query rather than inventing a mechanism.

  All eight editors are converted — table, view, procedure, trigger, domain,
  generator, exception and package — along with `EditorColumn`, the table
  editor's column dialog, which is a plain `TForm` and so carries a schema of
  its own: it builds its own `ALTER TABLE`, and without one it would have
  altered whatever the unqualified name reached while the editor it belongs to
  showed a different table. The tree hands a schema member's schema over before
  the load (the editors read their metadata while loading), an editor already
  open counts as the same one only if its schema matches, and dropping an
  object closes only the editors on that schema's object.

  Which schema column to filter on was read off a live server rather than
  guessed, because several are not what one would expect — `RDB$USER_PRIVILEGES`
  uses `RDB$RELATION_SCHEMA_NAME` for the object granted on, and
  `RDB$REF_CONSTRAINTS` uses `RDB$CONST_SCHEMA_NAME_UQ`. Filtering on the wrong
  one returns nothing, which looks exactly like an object with no privileges.

  Verified in `form_load_test` against pairs of same-named objects the smoke
  test leaves behind in two schemas: each editor shows its own object and none
  of the other's, and is not merely empty. Stripping the predicates makes eight
  checks fail with both schemas' contents merged, which is the original defect
  reproduced. The fixture's markers are deliberately not substrings of one
  another — a first pair, `HERE_V` and `THERE_V`, made correct editors look
  wrong.

  Found on the way: the domain editor's array-dimension query concatenated to
  `rdb$dimension = 0and rdb$field_name`, so an array-typed domain never loaded
  its dimensions. Fixed.

  **Extraction is now schema-scoped, which fixed a silent corruption.** Object names are unique per schema, not per database, so every `DDLExtractor` query filtering on the name alone matched *every* schema using that name. With a `T_AMBIG` in both `PUBLIC` and `APPX`, the column query matched four rows and `ExtractTable` emitted one table carrying both schemas' columns and a duplicated `ID` — verified against the live server before the fix, and the regression test reproduces exactly that failure when the clause is removed. A `SchemaClause` helper now restricts the ~30 name-keyed queries to what an unqualified name reaches, matching how the tree lists them. Two traps it exists to record: `RDB$USER_PRIVILEGES` spells the column `RDB$RELATION_SCHEMA_NAME`, not `RDB$SCHEMA_NAME`, so the grants queries need their own column name; and the `CURRENT_SCHEMA IS NULL` guard is load-bearing, because with an empty search path every query would otherwise return nothing rather than everything.

  Schema-*qualified* name generation, listed here as outstanding while this entry was being written, is done — `QualifiedIdent`/`QualifiedObjectName` qualify the DDL and the editors, the drop dialog, Script As and the extract wizard all carry a schema, so the tree opens and scripts a second schema's objects. So are the catalogue joins the paragraph warned about: the field-source join is `SchemaNames.FieldSourceJoin` with one caller in the extractor, one in the editors' shared base and one in the debugger, and procedure parameters carry a schema predicate of their own.

  **`ALTER SCHEMA` is generated too**, which closes this item. What it can change was probed against the 6.0.0 server rather than taken from the notes, and the answer is short: `SET DEFAULT CHARACTER SET` and `DROP DEFAULT CHARACTER SET` work, and nothing else does — `SQL SECURITY` and `OWNER TO` are rejected outright (`Token unknown - sql`, `- owner`) in every position tried. So a schema's ALTER is its character set or nothing, and `ddlstAlter` on `ddlSchema` emits exactly that; the tree's *Script as ALTER* offers it on a schema node.

  A schema with no character set — `PUBLIC` is the case in point — restates as the DROP form rather than as an ALTER with nothing on the end, which is both the state it is in and a statement that runs. Proved by running it: the schema is moved to another character set behind the extractor's back, the statement it produced is run, and the catalogue has to hold what the statement said. Both branches fail the test when removed.

  The same probe found something latent: **`CREATE SCHEMA` rejects a `SQL SECURITY` clause as well**, which `ExtractSchema` would emit if `RDB$SQL_SECURITY` were ever set. It cannot be — no syntax in 6.0.0 writes that column, so it is null on every schema including `PUBLIC` — so the branch is unreachable rather than wrong, and it is left with a comment saying so.
- [x] **JSON functions** — settled without waiting for them. The highlighter now takes its keyword list from `RDB$KEYWORDS`, the table Firebird 5 added holding every word the server reserves (527 on the 6.0.0 test server), so a server that supports the JSON functions reports them and they are highlighted with no change here. The original note, kept because the probe result is still the fact: *blocked on Firebird, not on SynEdit, which is the opposite of what was assumed here.* Probed against the 6.0.0 test server: `JSON_VALUE`, `JSON_QUERY`, `JSON_OBJECT`, `JSON_ARRAY`, `JSON_EXISTS`, `JSON_ARRAYAGG` and `JSON_OBJECTAGG` are all rejected as unknown. There is nothing to highlight yet. The mechanism to add them the moment a server supports them now exists (`FirebirdKeywords.pas`), so this becomes a one-line change then.
- [x] **`EXPLAIN` statement** — the roadmap assumed this was "mostly wiring a new statement type through `SQLForm.pas`", which turned out to be the wrong model: **`EXPLAIN` is not server DSQL at all**. It is a client-side command that isql implements itself, and preparing `explain select ...` through IBX fails outright with "Token unknown - explain" (verified against Firebird 6). What isql actually does is prepare the inner statement and ask for its plan. So the editor now recognises a leading `EXPLAIN` (whole word, case-insensitive, `SQLStatementText.pas` — LCL-free so the smoke test covers the parsing), strips it, prepares what is left, and fills the Plan tab from `GetPlan` without executing anything. Two facts this rests on are asserted in CI: a prepared statement already carries its explained plan, and preparing genuinely does not execute — checked by preparing a `DELETE` and confirming the rows are still there, which is precisely what makes explaining a destructive statement worth having. The Plan tab is forced visible for an explicit `EXPLAIN` even when the plan display is otherwise switched off, and the post-execution plan code is skipped so it cannot overwrite the result.
- [x] **Partial indices in extracted DDL** — recorded here as a defect and it
  was not one. `DDLExtractor` already reads `RDB$CONDITION_SOURCE` through
  `FindField` (so an older server without the column is fine) and emits the
  `WHERE`, with a comment saying that dropping it would turn a partial index
  into a full one; the smoke test already creates a partial index and requires
  the clause in the extracted DDL. The item came from probing the server,
  finding the column, and inferring the gap without checking the extractor —
  left here as a correction rather than deleted.

- [x] **Cross-schema domains in extracted DDL** — a column's domain need not
  live in the object's own schema. `RDB$RELATION_FIELDS` records both the
  domain's name and, separately, `RDB$FIELD_SOURCE_SCHEMA_NAME`; the extractor
  joined on the name alone, which finds it in *every* schema and emits the
  column once per schema holding one. `TDDLExtractor.FieldSourceJoin` ties the
  two together, on the table branch and the view branch, gated on Firebird 6.

  Tested by a domain of the same name in two schemas with different widths.
  Removing the join makes the column appear twice and the test says so. The
  test does **not** catch the other way of getting it wrong — restricting the
  lookup to the object's own schema, which would pick the wrong same-named
  domain — because the extracted DDL names the domain rather than its type, so
  both candidates render identically. Catching that needs a check against the
  rebuilt database rather than the script.

  Since extended twice. The check against the rebuilt database now exists —
  `DOM_USER.TAG` is declared with a domain that is `varchar(7)` here and
  `varchar(19)` next door, and the rebuilt column's width says which one was
  matched. And the join was only ever fixed where the bug had been *seen*: the
  same `RDB$FIELD_SOURCE` → `RDB$FIELDS` join appears in the object editors and
  in the procedure-parameter paths, where it was still matching by name alone.
  The rule now lives in `SchemaNames.FieldSourceJoin` with one caller apiece —
  `TDDLExtractor`, `TfrmBaseDocumentDataAwareForm` (so all eight editors have
  it), and `TIBDebuggerVM` — rather than three copies to keep in step.

  Procedure parameters had the second half of the same bug: they were fetched
  by procedure name with no schema predicate, so a procedure that shares its
  name with one in another schema extracted with both parameter lists run
  together. `create procedure DOM_PROC (P varchar(7), Q integer, Q2 integer,
  Q3 integer)` is what that produces, and with the domain join missing as well,
  `(P varchar(7), P varchar(19))` — which Firebird refuses outright. Both are
  now checked against the rebuilt database, and both fail when the fix is
  removed.

  Three places that look like the same bug are not: the copies in
  `Globals.pas`, `DescribeForm.pas` and `MarathonIDE.GetTableColumnsEvent` are
  inside comment blocks or wired to no event, and `GlobalQueriesText.pas` has
  no callers at all. Left alone rather than fixed blind — the plugin sources
  under `src/Plugins` are separate projects and are not built with the
  application.

- [x] **Backup history** — the Maintenance dialog has a Backup History tab
  reading `RDB$BACKUP_HISTORY`, beside the backup and restore it already
  performs. That table is written by the server, so it shows nbackup runs made
  by anything, including a scheduled job this program knows nothing about. A
  server without the table says so in the list rather than raising.

- [x] **An editor pointed at a connection that is gone** — found by writing a test against a made-up connection name and watching the harness die. Every editor's `SetDatabaseName` read `MarathonIDEInstance.CurrentProject.Cache.ConnectionByName[Value]` and dereferenced the answer where it stood — eleven times in one setter, sixty-four across the ten of them — so a name the project no longer holds, which is what removing or renaming a connection with its editor open leaves behind, took the window down with an access violation instead of leaving it disconnected. The lookup is now `CacheConnectionNamed` in `MarathonIDE.pas`, answering nil for a name that is not there and for a form built before there is a project at all; each setter holds the result once and treats nil the way it already treated the empty name. The domain editor is the one that mattered most: alone among them it had no disconnected branch at all, so even *clearing* the connection crashed it. The three sub-dialogs of the table editor (column, constraint, index) are plain forms rather than editors and could not reach a method on the base, which is why the lookup is a plain function. All ten editors are checked, and reverting one to the old shape fails its own check with the access violation it used to raise.

  Then the same question was put to the tool windows, and all three answered the same way: the Session Monitor, the SQL Profiler and the Maintenance dialog each held the connection in a local and then dereferenced it unchecked, so each crashed on a name that is not there. Each now goes inert instead — the profiler into the same state a server without a profiler gets, the monitor with its tabs hidden and its queries unbound, the maintenance dialog holding no database and listing nothing.

  The path this is reachable by is a rename rather than a removal: `TfrmMasterProperties` writes `Connection.Caption := edConnectionName.Text`, and a window opened before that still holds the old name, which from then on resolves to nothing. Not swept: the places that take a connection name from a *tree item* — the drop dialog, the compile path, metadata search — where the name exists by construction because the tree is what listed it. Guarding those would be churn without a demonstrated failure.

- [ ] **Tablespaces** — *not implementable yet, and not for lack of trying:* no Firebird release up to and including the 6.0.0 test server has them. There is no `RDB$TABLESPACES` table, and no system-table column anywhere whose name contains `TABLESPACE` (checked by querying `RDB$RELATIONS`/`RDB$RELATION_FIELDS` directly rather than trusting the release notes). Re-check when a Firebird version actually ships the feature; until then there is nothing to show in table or index properties.
- [x] **Newer SQL:2023 surface** — split by what the engine actually supports, checked against the 6.0.0 test server rather than the release notes. `GREATEST`, `LEAST` and `ANY_VALUE` exist and are now highlighted via `FirebirdKeywords.pas` (along with `BLOB_APPEND` and `UNICODE_CHAR`, found missing from Lazarus's list in the same sweep). `UNLIST` and underscore-separated numeric literals (`1_000_000`) are **rejected by Firebird 6.0.0**, so there is nothing to support yet. **Named procedure arguments** are supported by the 6.0.0 server, including reordered ones, and *Script as EXECUTE* now emits them: `P(A => :A, B => :B)` says which value goes where and survives a later reordering of the routine's parameters, which a positional call does not. Gated on engine major 6, because that is what this was verified against and an older engine rejects the syntax outright — a script that will not parse is worse than a positional one that does. `TScriptAsContext` carries the engine version for this; both forms are prepared against the server in `test/ibx_smoke_test.lpr` rather than only inspected as text. **`ROW` types are blocked on Firebird, not on Marathon** — probed against the 6.0.0 test server rather than taken from the standard: the row constructor `(1, 2)`, the explicit `ROW(1, 2)`, `CREATE TYPE … AS (…)`, `%ROWTYPE` and `TYPE OF TABLE` are all rejected as unknown tokens. What Firebird *does* have is `TYPE OF COLUMN <table>.<column>` and `TYPE OF <domain>`, both of which work and neither of which is a row type. There is nothing to support until a release ships one. Completion support, which was listed here as the other open half, is done — see the parameter helper entry.

### Cross-cutting

- [x] **Server version detection** — `TMarathonCacheConnection` now reads and caches the real engine version and ODS on connect, exposed as `ServerVersion`/`ServerMajorVersion`/`ODSMajor`/`ODSMinor` plus two predicates: `IsFirebirdAtLeast(major)` for SQL-level features and `IsODSAtLeast(major, minor)` for anything depending on the on-disk schema. Both are needed because they can disagree — a database created by an older engine keeps its older ODS when opened by a newer server, and it is the ODS that decides which `RDB$` columns exist. Named constants (`FB_VERSION_4..6`, `ODS_FB3_MAJOR`, `ODS_FB4_MAJOR`, `ODS_FB5_MINOR`, `ODS_FB6_MAJOR`) replace scattered magic numbers; note FB4 and FB5 share ODS major 13 and differ only in the minor. Engine version comes from `RDB$GET_CONTEXT('SYSTEM','ENGINE_VERSION')` with an ODS-based fallback (that context variable only exists from FB2 on), and ODS from IBX's `IAttachment.GetODSMajorVersion`/`GetODSMinorVersion` — no query needed. Verified against the live FB6 server: engine 6.0.0, ODS 14.0, all predicates correct. Surfaced in the connection properties dialog next to the Phase 3 auth/protocol fields.
  `IsIB5`/`IsIB6` are deliberately left returning `True`: despite the names they are not version detection but "does this server use InterBase 6 semantics", which callers pass to `MakeQuotedIdent`/`ConvertFieldType` for quoted identifiers and dialect-3 types. Every Firebird release Marathon can connect to answers yes, so `True` is correct rather than a placeholder — they are now commented to say so, since they read like stubs.
- [x] **System-table column audit** — done by running the shipped queries against a live server rather than reading them, which turned up two real gaps rather than the "widen where useful" the entry anticipated. **The table and view lists had no system-object filter.** Every other object query in `MarathonProjectCache.pas` filters `RDB$SYSTEM_FLAG`; `GetTableList` and `GetViewList` instead checked for an `RDB$` name prefix in Pascal, which does not catch `MON$` or `SEC$` relations — they are ordinary relations that merely happen to be flagged system. Those two lists feed the New Trigger dialog's table dropdown, so creating a trigger offered all fourteen `MON$` monitoring tables and the security tables alongside the user's own. Now filtered like every other query. (`PLG$PROF_*` profiler tables are *not* flagged system, so they still appear on a database where the profiler has run; on Firebird 6 they live in their own schema, which is the schema item below.) **Packaged procedures were listed at top level.** The packages work excluded packaged *functions* from the function list — a packaged routine cannot be created or dropped on its own — but the procedure list was missed, in both the object tree and the bulk extract wizard. Both now exclude them, ODS-12 gated in the same way, since `RDB$PACKAGE_NAME` does not exist before Firebird 3. Covered in `test/ibx_smoke_test.lpr`: no `MON$` relation survives the table filter, an ordinary user table does, a standalone procedure is listed and the filter is not self-contradictory.
- [x] **Packages (FB3) — DDL extraction and bulk export** — `TDDLExtractor` gained `ddlPackage`, reusing the same header/body subtype split as stored procedures (`ddlstHeader` → `CREATE OR ALTER PACKAGE ... AS <header>`, `ddlstProc` → `RECREATE PACKAGE BODY ... AS <body>`), ODS-12 gated. `TIBMetaExtract.WritePackages` writes all headers before any body, since a body may reference routines declared in another package's header — the same two-pass ordering stored procedures already use — and the bulk wizard has a Packages tab. A package may legitimately have a header and no body, so an empty body emits nothing rather than being treated as an error. Verified by round-trip: a package recreated from the generated script returns the same value from its packaged function.
- [x] **Packages (FB3) — object tree node** — a *Packages* branch now appears under each connection, listing `RDB$PACKAGES` and gated on ODS 12 (the branch is simply empty on older servers, since querying a missing table is a hard error). Selecting a package shows its DDL — header followed by body, which together are what recreating it actually takes — and the tree's "Extract Metadata" pre-selects it on the wizard's Packages tab. The persistence worry recorded here previously turned out to be unfounded: `TGSSCacheType` is serialised to the project XML by *name* via `GetEnumName`/`GetEnumValue`, not by ordinal, so appending values cannot invalidate saved projects. Two gaps left by that pass are closed alongside the replication work below: *Script As > CREATE* now works on a package (emitting header + body, the same pairing the DDL tab uses) rather than being restricted to tables/views/procedures, and "Extract Metadata" on the *Packages* header node now pre-selects every package under it, as the other header nodes already did.
- [x] **Package editor** — double-clicking a package in the tree now opens `EditorPackage.pas`/`.lfm`, with Header, Body and DDL tabs. Header and body are shown separately because a package may legitimately be declared and left unimplemented; the viewer says so rather than treating a missing body as an error (checked live — a header-only package reports a NULL `RDB$PACKAGE_BODY_SOURCE`, not an empty one). Deliberately read-only: a package is edited as a whole, header and body have to be recreated together, and getting that wrong invalidates every routine that depends on it — so changing one is left to the SQL editor, which *Script as CREATE* on the tree node fills in. That also made the DDL tab reachable for the first time: `FrameMetadata`'s `ctPackage` branch existed but nothing could host it without an editor form. Two supporting gaps closed on the way: `DoesObjectExist` had no `ctPackage` branch (added, and tolerant of an older server where `RDB$PACKAGES` does not exist), and the package tree node inherited the base class's claim to support New and Drop, neither of which has a handler for a package — they sat enabled in the menu and did nothing. The node now advertises only Open, Script As, Extract and Add to Project. Covered in `test/form_load_test.lpr` (tabs, read-only views, and the node's operations) and `test/ibx_smoke_test.lpr` (the load query, including the header-only case). Followed up by auditing what the tree offers against what the dispatch actually implements: the drop dialog gained a `ctPackage` branch (so packages can now be dropped like any other object), and the node stops advertising New, Print and Print Preview, none of which has a `ctPackage` branch anywhere — unlike Print on other object types, which at least reports that printing is unavailable on this build, these did nothing at all. `DROP PACKAGE` takes the body with it (verified), which also simplified `ScriptAsDrop` from two statements to one and made it correct for a header-only package. The audit was then completed across every leaf node type rather than left at packages: `opDrop` reaches all of them through the drop dialog's else-branch, `opOpen` covers everything except publications, and `opNew`/`opPrint`/`opPrintPreview` cover the eight classic object types only — so the classic eight are fully wired and the only gaps ever were the two types added this phase. `test/form_load_test.lpr` now pins that matrix, so adding a cache type without wiring the dispatch fails a test rather than shipping a menu item that does nothing.

## Phase 8 — Remaining FlameRobin IDE Parity

Items FlameRobin lists that Marathon has not done. Ordered roughly by
value-for-effort; none are blocked on engine or library limits.

- [x] **`Script as ALTER` / `DROP` / `MERGE`** — completes the Phase 2 set. **DROP** is one statement per object type, with two details that are not interchangeable: a legacy external UDF drops as `drop external function` while a Firebird 3 PSQL function drops as `drop function` (branching on `RDB$LEGACY_FLAG` the way `ExtractUDF` already does), and a package's body is a separate object, so both statements are emitted in order. `drop generator` is used rather than the modern `drop sequence` synonym — both work on current Firebird (verified), but only the older form works on the InterBase-era servers this codebase still supports, and it matches what `ExtractGenerator` emits. **MERGE** is the one generator that genuinely needs the primary key: the `1 = 0` placeholder that makes the generated UPDATE/DELETE inert would do the opposite here, since a row that never matches falls through to `WHEN NOT MATCHED` and gets inserted. The key columns therefore drive the `ON` clause and are excluded from the `UPDATE SET` list (they are what the rows were matched on); a table with no primary key gets an explicit comment saying so rather than a statement that quietly does the wrong thing. The source is a `SOURCE` placeholder rather than parameters, because a parameterised `using (select ? as C ...)` fails outright with "Data type unknown" — verified live. **ALTER** splits three ways. A view and a trigger get a real `ALTER` form from `TDDLExtractor` via a new `ddlstAlter` subtype, which turned up the trap in this item: **`ALTER TRIGGER` rejects the `for <table>` clause that `CREATE TRIGGER` requires** (verified live — "Token unknown - for"), so an implementation that just swapped the verb would emit invalid SQL for every trigger. A procedure, PSQL function and package already extract in a re-runnable form (`alter procedure ... <body>`, `create or alter function`, `create or alter package`) and are reused as-is. A table has no whole-table `ALTER` in Firebird at all, so that path emits a commented template listing the table's current columns plus the forms the user will reach for; an external UDF has no `ALTER` either and says so.
- [x] **`Script As` generators moved out of the GUI layer** — done as part of the above, because it is what made any of it verifiable. The generators lived in `MarathonIDE.pas` and took a `TMarathonCacheConnection`, which drags in `MarathonProjectCache` and through it `Controls`/`ComCtrls`/`Dialogs`; nothing that touches the LCL can be reached from a console test, since the widgetset aborts at unit initialisation without a display. They now live in `src/Common/ScriptAs.pas` and take a small `TScriptAsContext` record (database, transaction, IB6 flag, dialect), with a one-line adapter in `MarathonIDE.pas`. That also fixed a latent asymmetry the move exposed: each generator committed the transaction it used but assumed one was already open on entry, so two calls in a row failed with "Transaction is not active". Each entry point that runs a query now opens one if needed. `test/ibx_smoke_test.lpr` exercises all twelve generators against a live server — SELECT is executed, INSERT/UPDATE/DELETE/EXECUTE and every DROP are *prepared* (which still makes Firebird compile them and resolve every name, without destroying the objects the rest of the run needs), and the three ALTER forms are executed outright, since restating an object exactly as it already is is harmless and is the only way to prove the forms are right.
- [x] **Environment color coding / connection profiles** — a connection can now be tagged Development / Test / Staging / Production in its properties dialog, and a SQL editor opened on a tagged connection grows a coloured band across the top naming the environment and the connection. The band is hidden entirely when no environment is set, so nothing changes for anyone who does not use the feature. The colours are fixed rather than user-configurable on purpose: the protection comes from "red means production" reading the same in every window and on every machine. The tag is advisory only — Marathon never changes behaviour based on it, it just makes the window about to run DDL against production look unlike one pointed at a scratch database. Stored in the project XML by enum *name* (`environment="envProduction"`), so a project written by an earlier build simply has no such attribute and loads as unset rather than as whatever sits at ordinal zero. Both directions are covered in `test/form_load_test.lpr`: a project naming an environment reads it back, saving writes it out again, and a project without the attribute round-trips to unset. The colours are asserted to be distinct from each other and from the default. Scope, as first committed: the band was on the SQL editor alone, which is where a script gets run.

  **Now on every document window and in the object tree**, which is where the rest of the damage is done — the object editors drop columns, and the table designer runs `ALTER TABLE`. The strip is built by `TfrmBaseDocumentForm` rather than dropped on each form: these forms do not inherit each other's streamed controls, so a panel in the base unit's `.lfm` would have reached none of its eighteen descendants. It reads `GetActiveConnectionName`, so a window gets the strip by calling `UpdateEnvironmentBand` once it knows which connection it is on — the editors from the property setter they already had, the designer when it is loaded. A form that answers `''` shows nothing, and nothing at all is built for an untagged connection, so the cost to anyone not using the feature is zero controls. The SQL editor's own strip carries the connection switcher, so it *overrides* the base one rather than growing a second.

  In the tree, everything under a tagged connection is drawn in that environment's colour — the whole branch, not the connection node alone, because by the time a table is being right-clicked the connection node has scrolled off the top. The selected row is left to the widgetset, since the selection colour is what says which row is selected. What the test asserts is the *decision* — `EnvironmentForNode` walking up to the connection — rather than the canvas, which would be asserting about gtk2. Both halves are ablated: removing the call in the editors' setter and making the tree lookup answer `envUnset` each fail the checks written for them.
- [x] **Quick connection switcher in the SQL editor** — a dropdown at the top of the editor repoints an open script at another connection without reopening the tab; the script text is untouched, only what it will run against changes. It shares a strip with the environment colouring from the previous item, which is the natural pairing: the same line answers "which connection" and "how dangerous is it". `SetDatabaseName` already did the whole rebind (transaction, the three queries, the performance monitor, dialect and IB6 flags), so the work was the safety around it: uncommitted work on the connection being left is settled first with the same Commit / Rollback / Cancel question closing the editor asks, and Cancel puts the dropdown back rather than half-switching. The results grid, cached plan and any singleton result are cleared, since they belong to the old connection. The list refreshes on drop-down rather than at create time, so connections added or renamed while the editor is open do appear. Building this surfaced a flaw in the environment band as first committed: it was refreshed by `SetConnectionName` only, so any other path that repointed an editor left the strip showing the previous environment. It is now driven from the property setter itself. Covered in `test/form_load_test.lpr` against a two-connection project — the switcher lists both, shows the current one, and switching from a Development connection to a Production one repoints the editor and turns the strip the production colour.
- [x] **XLSX result export** — `ExportGrid` gains `ExType` 5, alongside the existing separated-values / INSERT / JSON / Markdown / TSV, with a matching entry in `SaveFileFormat`'s format combo and save filter. Written by hand in `src/Common/XlsxWriter.pas` rather than by pulling in `fpspreadsheet`: an `.xlsx` is a zip of five XML parts, FPC already ships the zip writer in paszlib, and a result-set dump needs none of what a spreadsheet library exists for — so the build's dependencies are unchanged. Numbers are written into numeric cells so they sort and total in the spreadsheet, with the same type decisions the JSON exporter makes and for the same reason: `DECFLOAT`, `INT128` and `NUMERIC` all arrive as BCD fields, and routing those through `AsFloat` would destroy exactly the precision they exist to provide, so their text form goes verbatim into the cell. A NULL becomes an genuinely empty cell (`<c r="B3"/>`), which is distinct from the empty string a text cell would hold. Dates are deliberately left as text: a date in a numeric cell needs a serial number *and* a number format to read back correctly, and getting that subtly wrong is worse than a cell that says what the database said. Strings are inline rather than shared, which keeps the writer single-pass with no dictionary to hold for a large export. Verified by writing a workbook from a live result set containing the three things most likely to break it — a number, a NULL, and text needing XML escaping — and then taking the file apart again in `test/validate_xlsx.py`, now a CI step: zip integrity, the parts OOXML requires, every part well-formed, and the cells typed as intended. Cell references are checked past the base-26 boundaries that are easy to get wrong (Z→AA, ZZ→AAA). **Structural only** — no spreadsheet reader was available in this environment, so "Excel opens it" is not something these tests prove.
- [x] **Interactive parameterized routine executor** — done in two passes. The first found that this was a quiet bug rather than a convenience: Phase 2's generators deliberately emit parameter placeholders (`insert ... values (:ID)`, `execute procedure P(:A)`), and the SQL editor had no parameter handling at all, so it executed them with every parameter **unbound, which Firebird takes as NULL without complaint** (verified). The common path from the object tree — script as INSERT or EXECUTE, press run — appeared to succeed and quietly did nothing useful. `SQLParamsDialog.pas`/`.lfm` now prompts for a value per parameter with a NULL tick per row; a statement with no parameters never prompts, Cancel abandons the run, and values start empty and *not* NULL so pressing OK cannot reintroduce the silent-NULL behaviour. The second pass added the per-type checking. Parameter types are not reachable through `TIBQuery` — its parameters are FCL `TParams` whose `DataType` comes back `ftUnknown` — so the editor prepares a `TIBSQL` alongside, which does expose the statement's own typed metadata. `SQLParamTypes.pas` maps the codes; the trap it exists to document is that **NUMERIC(10,2) arrives as `SQL_INT64` with scale -2**, so scale, not the type code, is what separates a whole number from a decimal. Checking is deliberately permissive — a ticked NULL is not validated, an empty cell is left for the database to judge, and anything the dialog cannot judge passes — because a dialog that blocks a legal value is worse than one that misses an illegal one. Split so both halves are covered: `test/form_load_test.lpr` exercises the dialog and the type map without a database (rejects a word for an integer, a decimal for an integer, `maybe` for a boolean; accepts free text unconditionally; `SQL_INT64` at scale 0 vs -2), and `test/ibx_smoke_test.lpr` pins the empirical end — that the `TIBSQL` route really does yield `SQL_LONG` scale 0 and `SQL_VARYING`, and that values bound as text reach the database intact. Not done, and deliberately: richer editors (a date picker rather than a typed date) and a launch point on the tree's procedure node. Both are polish on a path that now works — *Script as EXECUTE* followed by run already prompts.
- [x] **Find and Replace in the editors** — Ctrl+F, Find Next and Replace did nothing anywhere on this port: all fourteen call sites across the SQL editor, SQL trace, and the view, trigger and stored-procedure editors had been reduced to a comment, because `TSyntaxMemoWithStuff2` was missing `WSFind`/`WSFindNext`/`WSReplace`. The dialogs themselves (`FindDlg`, `ReplDlg`) were fully ported and working, and `TEdPersistent` — the per-editor search text, options and history the dialogs read and write — was already there; only the three methods that raise them were absent. They are now implemented over SynEdit's own `SearchReplace`, so nothing here depends on the code-completion machinery this unit still lacks. Find Next with nothing searched for yet opens the Find dialog rather than reporting that an empty string was not found. Covered in `test/form_load_test.lpr` through the form's own `CanFind`/`CanReplace` — the path the menu actually takes — plus a real search over editor text, hit and miss.
- [x] **PSQL routine parameter helper** — signatures in the tree, completion in all four editors, and hover tooltips. Selecting a procedure or function in the object tree now shows its signature in the explorer's status bar — `IBX_SMOKE_TEST_PROC(A_ID integer) RETURNS (A_NOTE varchar(50))` — so a routine's parameters can be read without opening it or scripting an `EXECUTE` first. `RoutineSignature` lives in the LCL-free `ScriptAs.pas` and is covered against a live server. Two details it exists to get right: both catalogues type their arguments through `RDB$FIELD_SOURCE` (the domain) rather than carrying the type directly, so the domain has to be joined in; and a PSQL function's *return* type is argument position 0 of `RDB$FUNCTION_ARGUMENTS`, not a column of its own — so procedures and functions need separate queries and are tested separately. Selecting anything else clears the panel rather than leaving a stale signature under an unrelated node, and a failure to read one is swallowed, since a convenience must not stop a node being selected. **Completion now exists**, and the `SQLInsightList` surface it was said to need turned out not to be needed at all: SynEdit ships `TSynCompletion`, so what was missing was not a popup but the decision of what to put in one. Ctrl+Space in the SQL editor offers the connection's tables and views followed by SQL keywords; after a dot it offers that object's columns *and nothing else*, since a keyword after a dot is never right. `src/Common/SQLCompletion.pas` holds the reading of the text — no popup, no metadata, no LCL — so what to offer where is tested without a database or a widgetset in `test/keyword_test.lpr`: a partly typed word filters the list, a dot with nothing before it qualifies nothing, `RDB$` names keep their `$`, and only the text behind the caret is read. Aliases are resolved from the statement's own FROM and JOIN clauses (`select * from CUSTOMERS c` then `c.` gives CUSTOMERS), including `AS`, joins, comma-separated lists and a table named in full; an unknown alias resolves to itself rather than to nothing. Completion is wired into the **view, trigger and stored-procedure editors** as well, which is where PSQL bodies are actually written — `SQLCompletionHost` is a component the forms create, so the four editors share one implementation rather than four copies, and it follows the connection when an editor is repointed at another one without being reopened. **Signature tooltips** are done: hovering a routine name in any of the four editors shows its call signature, which is the same information the object tree puts in its status bar, offered where it is actually needed — while writing the call. It works by asking `RoutineSignature` about whatever word is under the pointer rather than first establishing what kind of object that is, and writing the test for *that* assumption found it to be false: `RoutineSignature` built its answer from the name alone, so a table produced `CUSTOMERS()`. A routine with no parameters and one that does not exist both yield no parameter rows, and nothing told them apart. It now checks the catalogue first, which restores the contract its own comment had always claimed. The object tree never noticed because it only ever asks about routine nodes.
- [x] **Schema comparison & migration generator** — compares two databases, or a DDL script against a database. Tools > Compare Schemas picks two open connections and opens a migration script in a SQL editor pointed at the *target* — the database the script would change, since an editor on the source would run it against the wrong one. `src/Common/SchemaCompare.pas` holds the whole engine and is LCL-free, so the smoke test drives it against two real databases. Eight object kinds are compared (domains, generators, exceptions, tables, views, procedures, functions, triggers), emitted in dependency order. Three deliberate limits: **drops are always commented out**, because dropping is the only direction that destroys data and a generated script must not be able to do it by being run unread; a **table that differs is reported, not altered**, since the difference could be a column added, dropped, retyped or renamed and guessing wrong loses data silently; and comparison is by *extracted DDL text*, so anything `DDLExtractor` does not render compares equal. Objects that differ and *can* be restated wholesale — views, triggers, procedures, functions, packages — are compared on their CREATE form but emitted as the ALTER one, which is what Firebird accepts against an object that already exists. Verified by more than "a script was produced": the smoke test builds two databases with known differences, runs the generated script against the target with `TIBXScript`, and compares again — the second pass must report *nothing* left except the one commented-out drop, which simultaneously proves the migration converges and that the drops really were inert. Building it surfaced three shipped bugs, all now fixed and covered (see below). **Index differences are now compared too**, and unlike a column change they are *migrated* rather than reported: an index can be added or dropped safely, so a table whose columns match but whose indexes do not now yields runnable `CREATE INDEX` statements. Each table's index block is split into individual statements and set-differenced — both databases are rendered by the same extractor, so a statement in one list and not the other is exactly one index's worth of difference, and emitting only those avoids failing on the indexes already present. Verified by giving one side an index on a table that is otherwise identical: the count rises by one, the script still converges (so the emitted statement really ran), and removing the feature makes the test fail on the missing index. **Key constraints are compared too**, by *definition* rather than by name — necessarily, because Firebird names an unnamed constraint for you (`INTEG_249` for a primary key) and those numbers differ between databases holding identical schemas, so a name-based comparison reports differences that do not exist. Primary keys, unique keys and foreign keys are rendered into a normalised statement (columns in key order, referenced table and columns resolved through `RDB$REF_CONSTRAINTS`, `ON UPDATE`/`ON DELETE` omitted when `RESTRICT`, since that is what Firebird stores when nothing was written) and set-differenced. What the script would actually *run* therefore names no constraint at all; a generated name appears only on a commented-out `DROP`, which needs the real one — asserted line by line in the test. A **primary key that differs** is reported rather than emitted, since a table can only have one and adding the new one requires dropping the old first; the commented drop for it is the other half of that report.

  Keys and indexes are emitted in a pass of their own, after every table exists. That ordering is not cosmetic: a table missing from the target is created from its column DDL alone and so arrives without them, and a foreign key may point at a table created later in the script. Two rounds of the convergence test were needed to find that — the first attempt left newly created tables without their keys, and the second tripped over the unique-constraint index described below.

  One trap worth recording: `ExtractTableIDX` excludes the indexes behind PRIMARY KEY and FOREIGN KEY constraints but *not* those behind UNIQUE ones. Since a unique constraint's index is named after the constraint, the same constraint showed up as `UQ_NOTE` in one database and `INTEG_512` in the other and was reported as an index difference that was not real. The comparison now filters out every index that belongs to a constraint, and compares those as constraints instead.

  **Objects being created are ordered by dependency**, not alphabetically. This was a real failure, not a tidiness point: a view `V_AAA` selecting from `V_ZZZ` sorts first, so the generated script did `create view V_AAA` before the view it reads and Firebird refused it with *Table unknown "V_ZZZ"* — reproduced before fixing. `RDB$DEPENDENCIES` is consulted only for names within the set being created; anything depended on that is not in that set belongs to an earlier kind and already exists by the time the section runs. A dependency cycle leaves the entries it involves in the order they arrived rather than looping — Firebird permits mutually recursive procedures, so that path is reachable rather than theoretical. Only creations are ordered; an object already in the target needs none. The test asserts the *order* in the script rather than settling for the script running, and removing the ordering makes it fail on exactly that.

  **CHECK constraints** turn out to be compared already, and the note that previously said otherwise here was wrong: `ExtractTable` renders them inline from the engine-written trigger, so a CHECK difference makes the table's DDL differ and is reported. What that exposed instead was a **false positive**: the extractor includes the constraint *name*, and an unnamed CHECK is `INTEG_3` in one database and `INTEG_5` in another holding the identical schema, because the engine numbers them per database as it goes — so every such table was reported as differing. The comparison now strips generated constraint names from the DDL it compares, leaving `add check (...)`, which is both what the two schemas genuinely have in common and a statement Firebird accepts, naming it itself. Pinning that needed care in the test as well: built the obvious way, both throwaway databases produce the *same* `INTEG_` numbers and the test proves nothing, so the target deliberately creates an extra table first to make the counters diverge.

  **Comparison against a DDL script** is now supported, and deliberately without a DDL parser: the script is run into a scratch database, which is then compared as any other source would be and dropped afterwards. A script therefore gets exactly the same treatment as a database — dependency ordering, constraint handling, index comparison — with no second implementation to keep in step, and the only thing it costs is insisting the script is one Firebird accepts in full, which is reasonable for something being used as a reference. A script that will not run is reported as that rather than as a schema with no differences, which is the distinction that matters: an empty comparison and an unrunnable script look identical otherwise. The scratch database is created beside the database being compared, since that is a path the *server* is known to be able to write — it is the server that creates it, not the client, so a local temp directory would be wrong for a remote connection — and it is dropped whichever way the comparison goes. Tools > Compare Schemas offers it as a radio choice against the database source.

  Not done: nothing substantial. CHECK differences are reported rather than migrated, along with the rest of a table's columns.
- [x] **Character length vs byte length in extracted DDL** — found while making the comparison above converge, and the more serious of the two. `RDB$FIELD_LENGTH` is a **byte** count, so in any multi-byte character set it is not the length the column was declared with: a UTF8 `varchar(10)` is stored as `RDB$FIELD_LENGTH = 40`, `RDB$CHARACTER_LENGTH = 10` (verified against the catalogue). Every DDL path read the byte length, so extracting a UTF8 database's metadata **quadrupled the width of every string column**, and a round trip through extract-and-recreate silently changed the schema. The editors and the debugger showed the same inflated types to the user. Fixed with a `DeclaredFieldLength` helper that prefers `RDB$CHARACTER_LENGTH` and falls back to `RDB$FIELD_LENGTH` — the fallback is the normal path, not a defensive one, since the column is null for every non-text type and absent from a catalogue old enough to predate it — applied at all 51 `ConvertFieldType` call sites, with the column added to the queries that select explicit column lists. Pinned directly in the smoke test rather than only through the comparison: a UTF8 domain declared `varchar(10)` must extract as `varchar(10)`, and no column may come back as `varchar(40)`.
- [x] **Implicit domains listed as user domains** — `RDB$FIELDS` holds one row per *column* of every table, named `RDB$1`, `RDB$2` and so on, and Firebird flags those `RDB$SYSTEM_FLAG = 0` exactly as it flags a domain the user wrote. The system-flag test that keeps the catalogue out of every other list therefore did nothing here, so the object tree's Domains node, the metadata extract wizard and metadata search all listed them — 148 of them on the smoke-test database, against no real domains at all. Told apart only by the `RDB$` name prefix, which is what all five listing queries now filter on.
- [x] **"Script as → Create" on a stored procedure emitted `alter procedure`** — the extractor hardcodes that verb because the bulk export it was written for creates every stub first and then fills the bodies in, which is how a procedure that calls another extracts without a forward reference. On its own it fails against a database where the procedure does not exist — precisely what CREATE is for. `ScriptAsCreate` now emits the header stub ahead of the body so the pair stands alone, the same two-statement shape a package already used. The same function's object-kind mapping was also incomplete: domains, generators, exceptions, triggers and functions fell through to `ddlTable` and would have returned a table's DDL. Unreachable from the menu, which only offers Create on the four kinds that were mapped — but the comparison engine asks for all of them.
- [x] **Create Database** — File > Create Database did **nothing at all** on this platform, silently: the original wizard was a Windows COM component with a Delphi `.dfm` and no `.lfm`, and the whole body of `FileCreateDatabase` sat inside a WINDOWS-only conditional, so on Linux the menu item was a no-op that did not even report itself. `CreateDatabaseDialog.pas`/`.lfm` replaces it, with the creation itself in the LCL-free `src/Common/CreateDatabase.pas` so it can be tested against a real server. One page rather than the original's four: with the COM component gone, what is left to ask for is the five things IBX can express when it builds the `CREATE DATABASE` statement — server, file, user/password, page size, character set and dialect — and those fit on one form. The old "run a script afterwards" and "create a project" steps are not reproduced; a script is what the SQL editor is for, and the connection is offered instead by pre-filling the existing New Connection dialog, which is still *shown* rather than applied silently because it carries settings this one does not ask for (role, environment, remember-password). Two things the server forced rather than the design choosing: an existing file is refused up front for a local path, because `CREATE DATABASE` over a live database is the one mistake here that could cost somebody their data; and the page size list is **8192 / 16384 / 32768 only**, because Firebird does not reject a size outside its range, it silently clamps it — 1024, 2048 and 4096 all produce an 8192-byte page and 65536 produces 32768 (verified by creating a database at each size and reading `MON$PAGE_SIZE` back), so offering 4096 would show a choice that is quietly ignored. Verified end to end against Firebird 6: the database is created, the page size and character set are checked to be *what was asked for* rather than merely present, and creating over an existing file is confirmed to be refused.
- [x] **`page_size` unusable through IBX** — found immediately: two of the three page sizes the dialog offers did not work at all. `isc_dpb_page_size` is an integer DPB parameter, but `TIBDataBase.GenerateDPB` grouped it with the string ones and wrote it with `SetAsString`, storing the digits as text — and the clumplet writer refuses an integer parameter carrying more than four bytes, so `page_size` = 16384 failed with `Invalid clumplet buffer structure: length of integer exceeds 4 bytes (5)`. Only the four-digit sizes got through, and those worked by accident rather than by design: the create path reads the item back with `AsString` and pastes it into the `PAGE_SIZE` clause, so the text happened to round-trip. Fixed in the vendored submodule and sent upstream as [MWASoftware/ibx4lazarus#24](https://github.com/MWASoftware/ibx4lazarus/pull/24); see `patches/README.md`. This is the first submodule patch Marathon genuinely *depends* on rather than merely benefits from — on a stock ibx4lazarus, two of the three offered page sizes raise the error above.
- [x] **HiDPI / scalable icons** — done, both halves.

  The *scaling* was done earlier: every one of the 62 `.lfm` files carried
  Delphi's `Scaled = False`, which switches LCL's DPI scaling off form by form,
  and `Application.Scaled` was never set — so the whole interface rendered at
  96 DPI whatever the display. Both are on, and the image lists are marked
  `Scaled`. On a 96 DPI display the factor is 1.0 and nothing moves, which is
  why this was invisible until looked for.

  The remaining half was artwork, and it needed source images this tree did not
  have. It has them now: `icons/*.svg` holds fifteen hand-authored vector icons
  — folder, connection, table, procedure, trigger, view, domain, exception,
  generator, function, publication, document, key, and the two overlays the
  tree draws for connected and inactive connections.
  `tools/build_icons.sh` renders them to a strip per size (16, 24, 32),
  recompiles the resource, and the output is checked in so building Marathon
  needs neither the script nor ImageMagick. `Globals.LoadScaledStrip` picks the
  strip that suits the display; which one that is, is `IconScaling`'s decision
  and is tested without a display.

  Three things surfaced doing it. The `.rc` named `ToolBarStrip.bmp` while the
  file is `ToolbarStrip.bmp`, so the resource had only ever been compiled on
  Windows and could not be rebuilt here at all. The compiled `.RES` in the tree
  was years older than the `.rc` beside it. And the old strip held thirteen
  icons while the tree indexes 13 and 14 for its overlays, so those overlays
  had silently never appeared.

  The icons are a new set rather than a trace of the old ones: redrawing a
  16×16 bitmap as vector art is a design job, not a conversion, so the
  application looks different — deliberately.

  Verifying this exposed a trap worth recording: an `.lfm`-only change does not make `lazbuild` recompile the unit, and the test project keeps its *own* copies of the `src/Source` units under `test/lib`, so a stale one there reported the old value long after the application had been rebuilt. Both had to be rebuilt with `-B` before the check told the truth.

---

- [x] **Object editors covered by a test, and three faults that exposed** — the eight object editors had never been opened by anything: they need a live connection *and* a widgetset at once, so the console smoke test cannot reach them and the GUI harness had no database. `test/form_load_test.lpr` now opens the table, view, procedure, trigger, domain, generator and exception editors on real objects, driven by `MARATHON_TEST_DB`/`MARATHON_TEST_USER`/`MARATHON_TEST_PASSWORD` and skipping loudly when they are unset. It prints a Pascal backtrace when an editor fails, because these run dozens of metadata queries and the message alone rarely says which one broke.

  It found three faults on its first run, none of which any amount of reading had turned up:

  - **The stored procedure editor could not be opened at all.** Its in-memory parameter list is a `TBufDataset` with persistent fields but no `FieldDefs`, and FPC refuses to open one of those — only `CreateDataset` builds the definitions from the fields. Delphi opened straight from the persistent fields, so this compiled and failed at runtime. The `.lfm` also marked it `Active`, so the failure happened during construction, which is why an earlier test had recorded the editor as "could not be built here" and moved on.
  - **`GetDBCharSetName`, `GetCharSetNames` and `GetCollationNames` could never have worked.** Each creates its own `TIBTransaction`, assigns it to a query and opens the query without starting it — and a new transaction is not active. Every caller (the stored procedure, domain and column editors, and the debugger) got `Transaction is not active` in place of a character set or collation name.

  The credentials come from the environment rather than argv because the application treats its first argument as a project file to open, and the harness registers a server before the connection because `Connect` otherwise falls back to its own login dialog — under Xvfb a hang rather than a failure. Both were found the hard way. The smoke test now leaves a domain, a generator and an exception behind so those three editors are exercised rather than skipped.

## Phase 9 — a single-window shell, modelled on the VS Code MSSQL extension

Marathon is a floating-window application: the object browser is one window, and
every table, view, procedure and SQL editor opens as another. The VS Code MSSQL
extension — the reference for this phase — is one window: object explorer docked
on the left, documents as tabs in the centre, results below, and a command
palette over the top. Most of what that extension *does*, Marathon already does;
what differs is the shell around it.

Worth being explicit about what is **not** missing, so the work is not
re-invented: connection colouring (environments), schema-grouped object trees,
result export to CSV/JSON/Excel/INSERT, an execution plan view, a query profiler
and schema comparison all exist here already. The gap is arrangement.

- [x] **1. Docked shell and tabbed documents** — the main window gains an
  explorer panel, a splitter and a document tab area; document windows are
  hosted as tabs rather than floating. Every document form descends from
  `TfrmBaseDocumentForm`, so this hooks in one place rather than fourteen.

  Two faults only running the application found, both caused by the change and
  neither reachable from the harness. A document in a tab is no longer a
  top-level form, so the editors' `ActiveControl := …` reached the shell's
  notion of focus and raised *Cannot focus a disabled or invisible window*
  while a tab was still being built; documents now ask through a guard that
  treats focus as the convenience it is. And freeing the tab from inside the
  document's own close handler left the form to be released afterwards by the
  application's async queue with a parent that had gone — an access violation
  in the form's destructor, *after* the close appeared to succeed. The tab is
  now released the same way the form is.

  A third thing worth recording because it was silent: the guard was first
  called `FocusControl`, which is already a method of `TCustomForm`. It
  shadowed the built-in one and quietly changed several dialogs, whose own
  focus calls had been rewritten to it in the same sweep. LCL's version assigns
  `ActiveControl` and raises in exactly the same way, so the "fix" would have
  spread the fault rather than contained it. It is `FocusIfPossible` now, and
  the dialogs were put back.
- [x] **2. Object explorer in the shell** — the browser docks into the left
  panel instead of floating, and the panel and its splitter appear only when
  something is in them. `DockInto` is the same reparenting the document host
  does, without the tab; the explorer falls back to a window when there is no
  shell. Its list/detail pane is unchanged for now — moving that into a
  document tab is a separate question.

  This is where the address-identity flaw in the document host surfaced, and it
  was luck that it did. A tab remembers which form it holds by address; a form
  destroyed *without being closed* left that behind, and the allocator handed
  the same address to the object explorer, so the host reported a brand new
  window as already open. The host now takes `FreeNotification` from each
  document and drops the tab when the form goes, however it goes.

  Two lessons went into the test rather than only the code. The first version
  of the check passed with the mechanism removed, because its documents shared
  an owner with the host — and `TComponent.Notification` already reaches
  components that share an owner. The application creates documents with
  `Create(nil)`, so the test now does too, and removing the notification fails
  it three times over. The second: an assertion that the dock "starts hidden"
  was true only at startup and ran after a project had been opened; it is now
  the invariant that the dock shows exactly when it holds something, which is
  checkable at any point.
- [x] **3. Explorer filtering and type-aware search** — a filter box above the
  tree, in one line rather than a dialog: `cust` finds anything containing it,
  `table:cust` restricts that to tables, `table:` shows every table, and
  `"CUST"` matches the whole name rather than part of it. Types are matched
  loosely in both directions, so `procedure`, `proc` and `sp` all reach the
  *Stored Procedures* group without anyone having to know Marathon's wording.
  Matching folds case, since Firebird stores unquoted names upper-cased and
  nobody types them that way.

  `src/Common/TreeFilter.pas` holds what a filter *means* and has no tree and
  no LCL in it, so the sixteen cases that decide it run without a widgetset. The
  tree side is checked separately against a hand-built tree: what it must never
  do is strand an object, so a surviving object keeps its group and connection
  visible above it, and clearing the box brings everything back.

  It deliberately does not expand anything. Walking a collapsed tree would
  report an object as absent when it has merely not been read yet, and
  expanding every branch to find out would query the whole database on each
  keystroke. Metadata Search still exists for the case this does not cover -
  searching inside procedure and trigger *source*.
- [x] **4. Results beneath the statement** — the gap here turned out to be
  sharper than "results should be in one place": Marathon put results on a *tab
  of their own*, so seeing them meant leaving the SQL text behind. They now sit
  under the editor with a splitter between, both on screen at once, which is
  what the VS Code extension does and the actual point of the item. A
  shell-level pane shared between documents was considered and rejected — each
  document keeping its own results is better here, and reparenting a live data
  grid on every tab switch is risk with nothing to show for it.

  Merging the panes changed what seven menu guards meant. They asked *which tab
  is active* to decide whether Copy, Print and the exporters act on rows or on
  text; with both panes visible that question no longer has an answer, so they
  ask where the focus is instead. That is a silent kind of change — a wrong
  guard disables a menu item rather than crashing — so `ResultsHaveFocus` is
  one named function rather than seven inline conditions, and the test pins the
  case that would otherwise pass by accident: nothing focused must not count as
  the results being focused.
- [x] **5. Command palette** — `Ctrl+Shift+P` finds any of the application's
  **176** commands by typing part of a name. It needed no list of commands:
  every one is already a `TAction` with a caption and a category, so the
  palette reads `actMain` and nothing has to be kept in step with it.

  Words match independently and in any order, because nobody recalls the exact
  wording of a menu item — *new conn* and *conn new* both find New Connection,
  and the category is searched too, so *tools extract* finds Metadata Extract
  without knowing which menu it lives under. Accelerator ampersands and
  trailing ellipses are stripped, since they are noise to type against.
  Ordering puts a name that *starts* with what was typed above one that merely
  contains it, above one matched only through its category.

  A command that cannot run now is **listed but greyed, not hidden**: an action
  is disabled because its document or connection is not there, and hiding it
  would send someone hunting for a command that exists. Pressing Enter on one
  does nothing, which the test pins by finding a disabled command in the real
  action list and requiring that it is offered and not executed.

  What a query means is decided in the LCL-free `src/Common/CommandPalette.pas`
  and tested there without a widgetset; the dialog is checked against the
  application's own action list, which is what makes "it finds the commands
  that actually exist" a real claim rather than one about a fixture.
- [x] **6. Connection groups** — connections are gathered under a heading per
  environment, and only when more than one environment is in use: a project
  where everything is Production, or nothing is tagged, gains nothing from a
  single heading over the lot. Grouping is presentation, so it can be run again
  whenever an environment changes, and running it twice neither multiplies the
  headings nor loses a connection.

  The work was not the headings. `ConnectionCount`, `Connections[]` and
  `ConnectionByName` were each *defined* as the direct children of the
  Connections node — so "how many connections are there" was the same question
  as "how deep is the tree", and adding a level under it would have emptied the
  connection list everywhere, including the project file on the next save.
  Collecting connections is now one routine that does not care about the shape
  of the tree, and the accessors go through it. Reverting just that and leaving
  the grouping in place does not fail the suite so much as hang it, which is
  what `Connections[]` handing back a group node cast to a connection looks
  like.

  Not done: the **dedicated connection dialog**. The master-properties
  connection tab already has every field one would have, so a new dialog would
  be a second way to do the same thing rather than a better one.
- [x] **7. Table designer** — the whole table in one grid, the script it would
  run underneath it, and one Apply.

  The shape of the job was not what the item implied. Marathon *already*
  designs tables: New Table opens a column dialog, and the table editor has
  Structure, Constraints, Indices and DDL tabs. What the VS Code designer adds
  is that the whole table is edited in one view and **the script is shown
  before it is applied**. Marathon applied each change as it was made — every
  column dialog ran its own `ALTER TABLE` on OK — so there was nothing pending
  to preview, and no way to abandon a half-made change: the first three columns
  were already in the database while you were still deciding on the fourth.

  So the designer is a second way of editing a table rather than a replacement.
  The immediate-apply editor is still what you want to alter one column; this is
  what you want to lay out a table. Nothing was converted, which is why the
  change carries no risk to the editor that had the thinnest coverage in the
  tree.

  Three units, split so the decisions can be tested without a server:
  - `src/Common/TableDesign.pas` — a design, and the statements that turn one
    into another. No database, no LCL. Renames come first (so later statements
    can use the new name) and the primary key last (it names columns the earlier
    ones create); drops and retypes are flagged as able to lose data.
  - `src/Common/TableDesignIO.pas` — reading a table out of the catalogue as a
    design, and running a script. Reuses the metadata extractor's
    `ConvertFieldType`, so a column reads back spelled the way the DDL tab
    spells it — if the two disagreed, opening a table and pressing Apply without
    touching anything would rewrite columns.
  - `src/Source/TableDesignerForm.pas` — the form. Reachable from the object
    tree's context menu and the command palette (`ObjectDesignTable`).

  A column carries the name it has *in the database* alongside the name it is
  being given. That is what makes a rename an instruction rather than a guess:
  without it, `ID` becoming `CUSTOMER_ID` is indistinguishable from `ID` being
  dropped and `CUSTOMER_ID` added, and those two differ by the data in the
  column.

  Tested at three levels: 28 checks in `keyword_test` on what each edit should
  generate (no database); a round trip in `ibx_smoke_test` that creates a table
  from a design, reads it back, applies every kind of change at once and checks
  each one landed — including that *reading a table twice generates no
  statements*, which is what ties the reader and the generator together; and
  the form itself in `form_load_test` against a real table. Reverting the
  rename ordering makes the live test fail with the error it exists to prevent
  (`column "FULL_NAME" does not exist`).
- [x] **8. Cleanup that this makes possible** — `WindowList` and the Window menu
  exist to manage floating windows and become redundant once documents are tabs;
  `GlobalMigrateWizard.pas` is already dead (superseded by `MetaExtractWizard`);
  `lib/Other` holds three units shadowed by copies in `src/Source`. Release
  notes are auto-generated stubs (`**Full Changelog**: …`) and could describe
  what actually changed.

  Done: the three shadowed `lib/Other` units are gone, along with an orphaned
  Delphi palette icon. They were not spare copies but a trap — `src/Source` is
  earlier in the search path, so editing one had no effect whatsoever. All
  three differed from the live versions, which is how a trap like that gets
  noticed too late.

  Release notes now list the commit subjects since the previous tag, name the
  three downloads and link the comparison. The reason every release so far said
  only *Full Changelog* is that all three platform jobs asked GitHub to
  generate notes, and whichever finished last overwrote the others; one job
  writes them now. Checked by running the generator against the real repository
  rather than by reading the YAML — without `fetch-depth: 0` the default shallow
  clone has no previous tag and the list would have come out empty.

  `WindowList` and the Window menu are *not* removed. Documents are tabs now, so
  the menu is largely redundant, but it still lists tool windows and the
  explorer, and every document form registers itself with `WindowList` in its
  constructor. That is a change to unpick carefully rather than in a cleanup
  commit. `GlobalMigrateWizard` and `GSSDDLExtractorServer` are unreachable from
  the application but are the old COM server rather than duplicates, so they are
  left for a decision about that build.

## Phase 10 — a second pass over the VS Code MSSQL extension

Phase 9 was built from that extension's feature set; this is the same list
reviewed again against what it ships now (its changelog, July 2026) and against
what Firebird can support. Not everything there makes sense here: it is a
client for one server product with a cloud service behind it, and several of
its headline features have no Firebird counterpart at all.

| Their feature | Here |
|---|---|
| Shortcuts configuration | **Done** — the keybinding editor |
| Connection groups | **Done** |
| Table Designer | **Done** |
| Schema Compare | **Done** |
| Query Profiler | **Done** — over `MON$` rather than their DMVs |
| Global object search | **Done** — the Metadata Search window and the object tree filter |
| Query results grid | **Done** — results sit under the statement, as theirs do |
| Backup/restore dialogs | **Done** — the Maintenance dialog, over IBX's services API |
| Query Plan Visualizer | **Done** — the plan draws as a tree. Firebird has two plan formats: the explained one (3+, several indented lines) always drew, and the older parenthesised one is one line however deeply nested, so it drew as a single box holding the whole plan. `src/Common/PlanParser.pas` parses that form; `PlanUnit.FillTreeFromPlan` picks the reader that suits what arrived |
| Edit data grid with script preview | **Done** — the grid holds its edits (IBX cached updates) and `TfrmTables.PendingDataChanges` renders them as the INSERT/UPDATE/DELETE they would run, with `ApplyDataChanges` and `CancelDataChanges` either side. `src/Common/RowEdits.pas` builds the statements and refuses to write an update or delete for a table with no primary key |
| **Schema Designer** | **Not done** — see below |
| SQL Notebooks | Not planned: a VS Code notebook-host feature, with no shell here to host one |
| Data API Builder | Not planned — generates REST/GraphQL endpoints for Azure SQL |
| GitHub Copilot integration | Not planned |
| Local SQL Server containers | Not planned. The nearest useful thing, creating a database, is already File > Create Database |

- [x] **Schema Designer** — a diagram of the tables and the foreign keys
  between them. `src/Common/SchemaDiagram.pas` holds the model and the layout
  (no canvas, so where every box goes is checked without one),
  `src/Common/SchemaDiagramIO.pas` reads the catalogue, and
  `src/Source/SchemaDiagramForm.pas` draws it. Reached through
  `MarathonIDE.ShowSchemaDiagram`, one per connection.

  Layout is breadth-first from the most-referenced table, so a table sits near
  what it references; tables in no relationship go last, together. That is a
  rough rule on purpose — it beats alphabetical order by a long way, it is
  predictable, and it terminates on the cyclic graphs real schemas have.
  Anything cleverer is a force-directed simulation, which moves every time it
  runs and cannot be tested.

  Everything it needs was in the catalogue:
  `RDB$RELATION_CONSTRAINTS` gives the keys, `RDB$REF_CONSTRAINTS` pairs each
  foreign key with the unique key it references, and `RDB$INDEX_SEGMENTS` gives
  the columns on both sides. The drawing is the approach the query builder
  already uses — one paint box, boxes and lines drawn rather than made of
  controls.

  The part worth care is layout: sixty tables in a grid is unreadable, so
  tables want placing near what they reference.


### What else the Firebird probe found

Checked against the 6.0.0 test server and then against this codebase, which is
the order that matters — twice now an item has been recorded as missing when it
was already there.

- `MON$COMPILED_STATEMENTS` — **already done.** The session monitor has a tab
  for it, gated on ODS 13.1 and hidden on older servers.
- `MON$ATTACHMENTS.MON$SESSION_TIMEZONE` — **done here.** A column in the
  attachments list, selected only when the server has it: naming a column that
  is not there is a hard error rather than a null.
- `SKIP LOCKED`, `RDB$PUBLICATIONS`, `RDB$SCHEMAS` — already supported.

## Phase 11 — a coverage audit, and a review of FlameRobin and the VS Code extensions

Three things at once: every roadmap item checked against what actually tests it,
FlameRobin's feature set re-read, and the two VS Code database extensions
re-read for anything worth taking. The audit is the part that found bugs.

### What the audit found

The suites cover the roadmap well, with one large hole and two shipped bugs
inside it.

- [x] **Result grid export had no test at all** — five of the six formats had
  never been driven. Only XLSX did, and that goes through `XlsxWriter` rather
  than through `ExportGrid`, so the procedure the Save dialog actually calls
  had never run in a test. Now exercised against a live result set holding the
  things the formats disagree about: a number, text containing a comma, a
  double quote and a tab, a NULL, and a boolean.

  **`Export as INSERT` produced scripts that would not run.** The 100-line type
  switch had no null test at all, so a null column emitted *nothing* and left
  `values (42, 'x', , true)`, and text was wrapped in quotes without doubling
  the ones inside it, so a single apostrophe ended the literal. Both are the
  kind of defect that looks fine in the file and fails at the server, which is
  why the test now runs the exported script back into a table shaped like the
  row it came from and reads the row back — apostrophe, null and boolean
  intact. The rules live in `RowEdits.SQLFieldLiteral` now, shared with the
  data grid's own edits and checked headlessly over a `TBufDataset`; dates are
  written year-first rather than through `DateTimeToStr`, whose format is the
  machine's and not Firebird's.

- [x] **The result grid filter did not filter** — the box cleared itself as it
  was typed in. Switching the filter on re-opens the dataset, and the editor's
  `AfterOpen` cleared the filter box and switched filtering off, so the two
  undid each other and nothing was ever filtered. Guarded with a flag now, so
  a new *result* still starts unfiltered while applying a filter does not.
  Split across two suites for a reason: that IBX honours
  `Filtered`/`OnFilterRecord` at all is a fact about the dataset and is settled
  in the console harness, and that the box is wired to it is checked in the GUI
  harness. Removing the guard fails the GUI checks.

- [x] **The Session Monitor's admin actions** — Firebird has no CANCEL or KILL
  verb: both are done by deleting a row from a monitoring table, which is the
  one place the engine reads a DELETE as a command. That is now
  `src/Common/SessionAdmin.pas` — the two statements and the guard that stops
  the window disconnecting itself — checked headlessly, with the window itself
  driven against a live server: a second connection is opened, the monitor is
  required to list it, the disconnect statement is run the way the button runs
  it, and the attachment has to be *gone from the server* afterwards. The
  buttons cannot be pressed in the harness because both confirm first, and a
  modal dialog under Xvfb is a hang rather than a failure.

- [x] **Metadata search connected to the wrong database** — found while reading
  for coverage rather than by a test. It built its own connection from
  `DBFileName` alone, which to IBX means a *local* file of that path whatever
  server the connection belongs to, so searching a remote database opened a
  local file or failed. Both places now build the string through
  `TMarathonCacheConnection.DatabaseConnectString`.

- [x] **Backup and restore had never been run by a test** — the largest of the
  remaining gaps, and the operation with the most to lose: a restore writes a
  whole database file. The smoke test now takes a real backup through the
  Services API, restores it to a database of its own, connects to the result
  and requires a table the suite made to be in it. The guards moved to
  `src/Common/MaintenanceOps.pas` so they can be checked without a window - the
  dialog asked its three questions between `MessageDlg` calls, and a modal
  dialog under Xvfb is a hang rather than a failure. The one that earns its
  place is the refusal to restore onto a file that already exists: Firebird
  would refuse too, but only after reading the backup and only in the engine's
  words.

  Writing it turned up something worth keeping: **the restored database is the
  server's file, not the client's**, so deleting it from the test silently did
  nothing when the server runs as another user, and the next run failed with
  "database already exists". It is dropped through a connection to it now,
  which asks the side that made it to remove it. The backup file really is the
  client's - this service streams it back - so that one is deleted.

- [x] **Per-statement performance counters** — the `MON$`-sourced component
  behind the SQL editor's stats panel was rewritten from a stub earlier in this
  port and never driven since, which matters because a component reporting
  zeroes looks exactly like a quiet database. The smoke test now reads the
  counters, does work that must move them, and requires that they moved.

  The test as first written failed, and the component was right: the counters
  are the monitored **transaction's**, not the attachment's, so work done on
  another transaction shows nothing. That is what the SQL editor wants, since
  its statements run in its own transaction.

- [x] **Metadata search** — driven end to end for the first time, which also
  pins the connection-string fix above: for a remote server the string it
  builds must be the one the connection itself opened.

- [x] **The drop dialog kept its own copy of how to drop an object** — a case
  statement per kind, in two blocks, alongside the one in `ScriptAs` that is
  checked against a live server. The copies had already drifted: this one said
  `drop external function` for *every* function, so a Firebird 3 PSQL function
  could not be dropped from the tree at all. Verified against 6.0.0 before
  fixing: the engine refuses that verb for a PSQL function, and `drop function`
  is what it takes. `ScriptAsDrop` branches on the legacy flag, qualifies by
  schema and drops a package in one statement, so the dialog asks it now.

  The named path — what an editor takes when it drops the object it is editing
  — did not carry a schema at all, so an editor opened on a second schema's
  object generated an unqualified `DROP`. It takes one now, and all eight
  editors pass theirs.

- [x] **"Does this object exist" was nine copies of the same twenty lines** —
  `Globals.DoesObjectExist` carried a block per object kind differing only in
  the catalogue table and column, each with its own fallback, its own
  transaction guard and its own error dialog, so a fix to any of it reached one
  kind. The mapping is a mapping now: `src/Common/ObjectCatalogue.pas` says
  which catalogue holds which kind and builds the query, and the function is
  63 lines instead of 279.

  Split in two while it was open, because it could not be tested at all: the
  old function raised a dialog when the answer was no, and a modal dialog under
  Xvfb is a hang rather than a failure - so the "not there" path, which is the
  interesting one, was unreachable from the harness. `ObjectExists` answers and
  says nothing; `DoesObjectExist` is that plus the message. Both answers are
  now checked against a live database, for every kind, and the mapping is
  checked without one.

  One deliberate change of behaviour: the package branch swallowed a failing
  query, because `RDB$PACKAGES` does not exist before Firebird 3 and asking is
  a hard error rather than an empty answer. Every kind does now - "the
  catalogue cannot answer" and "there is no such object" mean the same thing to
  every caller of this.

- [x] **The compile path's fourth copy** — `CompileDBObject.pas` asked whether
  a procedure or function was already there with its own inline queries, to
  decide whether to rewrite `CREATE` as `ALTER`, and named no schema while
  doing it: on Firebird 6 it answered about whatever an unqualified name
  reached, so compiling a procedure in a second schema could create a duplicate
  in the search path's instead of altering the one being edited. It asks
  `ObjectExists` now, which qualifies and is tested. The stored-procedure path
  also had the same four lines in both branches of its own if.

  The rewrite itself is `src/Common/CompileScript.pas` — three lines that
  indexed into a string at a position the parser handed them, with nothing
  checking the position was on the line. A parse that surprised them wrote into
  the wrong place or raised out of a compile that had nothing wrong with it.
  Refusing an impossible position and changing nothing is now checked six ways.

  What is still not covered is the compile *flow* - the parser walk, the
  prompts, the execution - which needs the form, a database and a way past
  three modal confirmations. The pieces it is built from are covered instead.

- [x] **The blob viewer destroyed the blobs it was opened on** — three defects
  in one small window, all found by writing the first test it has ever had.
  Its second tab is labelled Hex and held no hex: it loaded the same bytes into
  a second memo as text, so a text blob was shown twice and a binary one was
  mojibake twice. Switching tabs wrote whichever memo was in front back into
  the blob, so *looking* at the other tab rewrote it - through a memo, which
  normalises line endings and loses what it cannot render. And OK wrote back
  whichever memo was in front, so pressing it with the hex tab up put the dump
  into the blob.

  The hex tab is a hex dump now - offset, bytes, printable gutter, capped so a
  megabyte blob does not turn a window into a wait - and it is a view rather
  than an editor, since writing hex back would need it parsed and nothing here
  does that. Switching tabs changes nothing. OK writes only from the text side.
  And a blob that is not text is shown read-only whatever the caller asked for,
  because a memo cannot hold one without changing it.

  `src/Common/BlobText.pas` decides both halves - is this text, and what does
  it look like in hex - so they are checked without a window: a NUL settles it,
  a run of control bytes settles it, one stray byte in a hundred does not, and
  the dump lines up in rows of sixteen and says how much it left out. The
  window's own behaviour is checked too, and the check that matters is that a
  binary blob comes back byte for byte after OK. With the guard removed it
  comes back a byte short.

One harness lesson worth recording: a check that borrows the caller's open
query and then commits leaves the next export sitting on a dataset whose
transaction has gone, and that hangs rather than failing. The runnable-INSERT
check owns its query now, and runs last.

### FlameRobin, re-read

Checked against [mariuz/flamerobin](https://github.com/mariuz/flamerobin) as of
2026-07-28. Its roadmap and this one have converged — this document was adapted
from theirs and both are now almost entirely ticked — so what follows is only
what they have and Marathon does not, with each judged against the 6.0.0 test
server rather than against the release notes.

- [x] **Memory diagnostics** — done. A fifth Session Monitor tab over
  `MON$MEMORY_USAGE`, which on its own says almost nothing: a stat id, a group
  number and four byte counts. What makes it readable is joining it back to the
  attachment that owns each pool, and *left*-joining - the database's own pool
  belongs to no attachment and is usually the largest row in the table, so an
  inner join would drop exactly the row worth seeing. Largest first, since
  "which pool is big" is the question being asked.

  `src/Common/MemoryUsage.pas` holds the query, the byte formatting and the
  group names. Those numbers are the engine's and nothing in the catalogue
  explains them, so they are in one named place rather than a case statement
  inside a form - and a group a later Firebird adds reads as "Group 5" rather
  than as one of the ones that exist today. The tab is present or absent
  according to whether the server has the table at all, asked of the catalogue
  rather than of the version number, in the same shape as the Firebird 5
  compiled-statements tab beside it. Checked live: the tab appears, the query
  opens, and it comes back with pools.
- [x] **System privileges** — done. FlameRobin's "granular system privilege
  matrix" names an `RDB$SYSTEM_PRIVILEGES` *table*, which does not exist; what
  does is `RDB$ROLES.RDB$SYSTEM_PRIVILEGES`, a `CHAR(8) CHARACTER SET OCTETS`
  bitmask, and nothing in it says what any bit means. Tools > System Privileges
  shows the roles and, for the selected one, every privilege the server defines
  with a mark against the ones it has.

  Two things the implementation rests on, both established against the server
  rather than assumed. **The names come from the catalogue**: `RDB$TYPES` under
  `RDB$FIELD_NAME = 'RDB$SYSTEM_PRIVILEGES'` publishes all 27, so a privilege a
  later Firebird adds appears by itself and one this build has never heard of
  is not silently dropped - the same principle as the monitor's `MON$STATE`
  decode. **The bit layout was measured**: a role granted `USER_MANAGEMENT`
  (type 1) reads `0200000000000000`, `READ_RAW_PAGES` (2) reads `0400…`,
  `CREATE_DATABASE` (9) reads `0002…`, and all of 1, 9 and 27 together read
  `0202000800000000` - so bit *n* is privilege *n*, low byte first. The mask
  arrives through `HEX_ENCODE` rather than as raw bytes, because a binary
  column carrying NULs through a dataset into a grid is a series of small
  surprises.

  Read-only on purpose: granting one of these is an `ALTER ROLE`, and
  `CREATE_PRIVILEGED_ROLES` lets its holder grant the rest, so this is for
  finding out who can already do what. Checked live against a role created for
  the test with two named privileges - it shows exactly those two, the ones it
  lacks are listed unmarked, and `RDB$ADMIN` has all 27. A role fixture rather
  than `RDB$ADMIN` alone, since an all-ones mask would pass a decoder that
  answered yes to everything.
- [x] **JSON view of a blob** — done, as a third tab on the blob viewer rather
  than a window of its own. Firebird has no JSON type: a document lives in a
  `BLOB SUB_TYPE TEXT`, and 6.0.0 has none of the SQL/JSON functions either, so
  nothing on the server will show a document with its nesting visible or say
  that what was stored is malformed. This does both.

  The tab is there when the blob *starts* like JSON - the first thing that is
  not white space begins an object or an array - rather than when it parses. A
  document that begins with a brace and then goes wrong is exactly the case
  where someone needs to see where, and deciding by parsing would hide it: a
  broken document would simply have no tab. When it does not parse, the tab
  says so and gives the parser's own line and position.

  FPC's `fpjson` does the parsing and the formatting, so there is no
  hand-rolled JSON in here and no new dependency - it ships with the compiler.
  Read-only, like the hex tab: it is a rendering, and writing it back would
  mean deciding what to do with the reformatting. Not done, and worth saying:
  this is a formatter and a validator rather than the *tree* view FlameRobin
  describes.
- [ ] **CSV external tables** — Firebird's `EXTERNAL FILE` tables, exposed in
  the table editor.
- **Vector / AI embeddings** — depends on `fbvector`, a third-party UDF package
  that is not part of Firebird. Out of scope here, as it already was.
- **Temporal tables** — still nothing to target: `PERIOD FOR SYSTEM_TIME` is
  rejected outright by 6.0.0 (`Token unknown - FOR`), same as the `ROW` types
  probed earlier.
- **Backup scheduler with cloud sync** — needs a scheduling daemon; out of
  scope for a desktop tool with no background service.

### The VS Code extensions, re-read

[microsoft/vscode-mssql](https://github.com/microsoft/vscode-mssql) and
[microsoft/vscode-pgsql](https://github.com/microsoft/vscode-pgsql). Most of
what they offer is either already here (object explorer with type-aware search,
query results with export, plan visualisation, table designer, schema designer,
schema compare, connection groups with colour coding, backup and restore,
shortcut configuration) or belongs to their ecosystem rather than to a Firebird
desktop tool (Copilot integration, Azure and Fabric provisioning, DACPAC,
notebooks, containers, Data API builder, Apache AGE graphs). What is left and
worth having:

- [x] **Flat-file import** — done. Tools > Import Flat File reads a delimited
  file, works out what each column holds, shows the columns, the types it
  guessed and the first rows, and writes the `CREATE TABLE` and the `INSERT`s.
  `src/Common/CsvImport.pas` decides all of that, so it is checked without a
  window; the dialog picks the file and shows the preview and decides nothing.

  Two places a naive importer quietly ruins the data, and what is done about
  each. **Quoting**: a field may hold the delimiter, and a quote inside a
  quoted field is written twice - a splitter that does not know that turns one
  row into several, and an apostrophe that reaches the INSERT undoubled ends
  the literal. **Types**: a column is only a number if *every* value in it is,
  and an empty value says nothing either way, so a column of numbers with a gap
  is still numbers - the gap becomes a null rather than turning the column into
  text. Where the values genuinely disagree the column is text, which holds
  everything.

  Dates are ISO only. A file written `03/04/2026` is ambiguous in a way no
  importer can settle, so it stays text rather than being read as one of the
  two possible days. Column names a spreadsheet produced are made into ones
  Firebird will take - anything that is not an identifier character becomes an
  underscore, a name starting with a digit is prefixed, an empty one is named
  outright.

  The import is all or nothing: a half-imported file is worse than none, since
  the rows that arrived are indistinguishable from data that was already there.
  Verified at three levels - the splitting and typing without a database, the
  generated statements run into the smoke database and read back (the quoted
  comma, the apostrophe, the null, and the numbers summed *on the server* to
  prove they are numbers rather than text that looks like it), and the window's
  own preview and import against a live connection.
- [ ] **Result grid column control** — freeze, hide and show columns, which
  vscode-mssql shipped as its new results grid. Small, and the grid is already
  ours to change.
- [x] **A server dashboard** — done. Tools > Server Dashboard samples the
  database's own `MON$IO_STATS` and `MON$RECORD_STATS` counters on a timer and
  plots them. Everything else here that reads `MON$` shows a snapshot; this is
  the only thing that answers "is this getting worse".

  What is plotted is the **rate**, not the counter. Firebird's counters are
  cumulative since the attachment began, so 19,772 page fetches is a number
  with nothing to compare it to. `src/Common/ServerMetrics.pas` does that
  arithmetic and is checked without a window, including the three ways a naive
  rate goes wrong and each of which draws nonsense: two samples in the same
  instant (a division by zero), a counter lower than it was because the
  database was reattached in between (a large negative spike), and the first
  sample, which has nothing behind it - so the plot starts one reading in
  rather than drawing a raw counter as though it were a rate.

  It starts **stopped**. Sampling costs a `MON$` query every few seconds, which
  is not free on the server being watched, so the window says so and the
  interval is the user's to choose - a dashboard that began hammering the
  server the moment it opened would be its own worst example. Each sample takes
  a new transaction, because Firebird takes a fresh `MON$` snapshot for the
  first statement of one: re-using a transaction would sample the same instant
  for ever, which is this window's whole point got wrong. Checked live - a
  second reading after real work sees more fetches than the first, and turns
  into a rate above zero.

Deliberately not adopted: plan *severity* colouring and the icicle chart from
vscode-pgsql's plan visualiser. They rank nodes by cost, and Firebird's
explained plans carry no cost figures — there is nothing to rank by, and a
colour scale computed from nothing would be an invented number.

## Explicitly out of scope

Adapted-but-rejected FlameRobin roadmap items, and why:
- **MCP server tools** (`explain_query`, `list_active_sessions`, etc.) — FlameRobin's MCP integration is a C++ process feature; there's no equivalent infrastructure here and it's a separate, large undertaking.
- **Vector / AI embedding support** — still unimplemented in FlameRobin too, and tied to Firebird extensions that do not exist yet. Nothing to target.
- **Temporal tables** (`PERIOD FOR SYSTEM_TIME`) — SQL-standard temporal support is not in a released Firebird; revisit when it lands.

Previously listed here but **moved into the active roadmap** by this audit,
because the original reasoning no longer holds:
- **SQL schemas (FB6)** → Phase 7. Was deferred as "not yet in general use", but Firebird 6 ships them, `RDB$SCHEMAS` exists, and FB6 already *returns* schema-qualified names in errors and `MON$` tables — so this affects Marathon today, not hypothetically.
- **Schema comparison / migration generator** → Phase 8. Still the largest single item, but FlameRobin has since shipped it, so it belongs on the list as a real gap rather than a rejection.

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
| 7 | FB3/FB4 modern column types in DDL | **Done** |
| 7 | BIGINT round-trip fidelity | **Done** |
| 7 | Expression + FB5 partial index DDL | **Done** |
| 7 | FB3 identity columns + FB4 SQL SECURITY in DDL | **Done** |
| 7 | FB3 PSQL functions + packaged-function filtering | **Done** |
| 7 | Multi-action + database-level trigger DDL | **Done** |
| 7 | SQL SECURITY across all four object types | **Done** |
| 7 | FB3 packages: DDL extraction + bulk export | **Done** |
| 7 | FB3 packages: object tree node | **Done** |
| 7 | FB3 packages: editor form | **Done** |
| 4 | JSON export of DECFLOAT/INT128/BOOLEAN | **Done** |
| 7 | Modern-type / index CI coverage | **Done** |
| 7 | FB4 long identifiers (audited, already OK) | **Done** |
| 7 | Real server-version detection + ODS gating | **Done** |
| 7 | FB4 named time zones / replication / encryption status | **Done** |
| 7 | FB5 profiler, `MON$COMPILED_STATEMENTS`, parallel workers | **Done** |
| 7 | FB5/FB6 keywords | **Done** — taken from the server's `RDB$KEYWORDS`, not SynEdit's list |
| 7 | FB6 SQL schemas | **Done** — filtering, listing, schema DDL, scoped extraction, qualified names, `ALTER SCHEMA` |
| 7 | FB6 `EXPLAIN`, JSON functions, tablespaces | `EXPLAIN` done; JSON functions and tablespaces do not exist in FB 6.0.0 |
| 8 | Script as ALTER / DROP / MERGE | Done |
| 8 | Environment color coding / connection profiles | Done — SQL editor, every document window, and the tree |
| 8 | Quick connection switcher | **Done** |
| 8 | XLSX export | **Done** |
| 8 | Parameterized routine executor | **Done** |
| 8 | Schema comparison / migration generator | Done |
| 8 | HiDPI / scalable icons | Done — SVG source, a strip per size, chosen by display |
| 9 | Docked shell and tabbed documents | Done |
| 9 | Object explorer in the shell | Done |
| 9 | Explorer filtering and type-aware search | Done |
| 9 | Results beneath the statement | Done |
| 9 | Command palette | Done |
| 9 | Connection groups | Done; dedicated dialog judged not worth it |
| 9 | Table designer | Done — added alongside the immediate-apply editor, not converting it |
| 9 | Cleanup enabled by the shell | Done |
| — | Printing and print preview | Done — replaced the unported report writers |
| — | Query builder | Done — rewritten; the Win32 original is deleted |
| — | SQL Trace | Done — the stub monitor replaced with IBX's |
| — | Keybinding editor | Done — replaces the removed rmControls grid |
| — | Code templates and debugger glyphs | Done — the editor wrapper stub filled in |
| — | Schema sweep of the editor frames | Done — the tabs the editors carry |
