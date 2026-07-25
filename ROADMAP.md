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
- [ ] **Named time zone display** — the DDL side is done (`WITH TIME ZONE` above). Checked what actually reaches the grid: IBX surfaces these as `ftDateTime`/`ftTime` rendering as e.g. `25-7-26 14:30:00 +02:00`, so the *value* is right and only the zone name is missing — an IANA name (`Europe/Berlin`) would be more informative than the offset. `RDB$TIME_ZONES` is available for the lookup. Lower priority than it first looked, since nothing is wrong, only less readable.
- [x] **FB3/FB4 values in the result grid and JSON export** — verified what these types look like once IBX has them: `DECFLOAT`, `INT128` and `NUMERIC(38,x)` all arrive as BCD fields and `BOOLEAN` as `ftBoolean`, with correct values including the full 128-bit range. That exposed a bug in the Phase 4 JSON exporter, which handled only the plain integer and float types and so emitted every one of these as a *quoted string* (`"1.5"`, `"True"`) instead of a JSON number or boolean. Now emitted unquoted, via `AsString` rather than `AsFloat` — routing a `DECFLOAT` or `INT128` through a float would silently destroy exactly the precision those types exist to provide. Confirmed by exporting 2^127-1 and parsing it back as an exact integer.
- [x] **Replication monitoring** — a *Replication* branch now appears under each connection, listing `RDB$PUBLICATIONS` and gated on ODS 13 (empty on FB3 and earlier, where the table does not exist). It is deliberately the one header here that does **not** filter on `RDB$SYSTEM_FLAG = 0`: the built-in `RDB$DEFAULT` publication is flagged as a system object, and since Firebird 4/5/6 have no `CREATE PUBLICATION` statement it is the only row the table ever holds — the usual filter would have left the branch permanently empty, which is how this looked at first. `TDDLExtractor` gained `ddlPublication`, and because the publication is unnamed at the DDL level its whole surface is `ALTER DATABASE`: enable/disable from `RDB$ACTIVE_FLAG`, then either `include all to publication` (when `RDB$AUTO_ENABLE` is set) or an explicit `include table a, b to publication` built from `RDB$PUBLICATION_TABLES`. `INCLUDE ALL` opts in every table created from then on, so it has to be reproduced as such rather than as the current member list — but a table can still be excluded afterwards without clearing the flag (verified live), so any user table missing from the member list is named in a following `exclude table`. Right-click → *Script As > CREATE* on a publication opens a SQL editor with that script; a row under any other publication name emits a comment saying this server has no DDL for named publications. Verified against a live FB6 server, round-tripping both shapes (auto-enable + an exclusion; explicit list, disabled) into a fresh database and re-extracting byte-identical output, plus the pristine state (`disable publication` alone) and a non-existent name (empty). `test/ibx_smoke_test.lpr` covers it, gated on engine major ≥ 4 — including a table does not switch replication on, and the test excludes it again to leave the database as found.
- [ ] **Database encryption status** — surface whether the database is encrypted in the connection properties dialog, alongside the auth-method/protocol fields added in Phase 3. Note `IAttachment` exposes no encryption accessor; this needs the raw `fb_info_wire_crypt` / `isc_info_db_encrypted` info item.
- [ ] **`SCROLL` attribute on cursors** — show it in procedure/trigger DDL where present.
- [x] **Read-committed read-consistency isolation** — the Session Monitor's Transactions tab showed `MON$ISOLATION_MODE` as a bare code number, so FB4's new mode 4 read as "4". Rather than hard-code a decode table (which would go stale the next time Firebird adds a mode), the three `MON$` grids now `left join RDB$TYPES`, which is where the server itself publishes the meaning of every code — `MON$ISOLATION_MODE`, `MON$STATE` and `RDB$OBJECT_TYPE` all have rows there. A code the running server does not know about falls back to its number via `coalesce` instead of being mislabelled, and this needs no ODS gate since it names no version-specific column. That also settled the mapping without guessing: mode 4 is `READ_COMMITTED_READ_CONSISTENCY`, and modes 2/3 (`READ_COMMITTED_VERSION` / `_NO_VERSION`) came from the same catalogue — worth noting because they were *not* reproducible on the test server, since FB4+ ships `ReadConsistency = 1` and silently upgrades both legacy read-committed sub-modes to 4, verified live by asking for each in turn and getting 4 back every time. The tab also gained readable Read Only and Lock Timeout columns. Aliases are unquoted upper case because IBX normalises a field name to that anyway, so a prettier quoted alias would not survive to the grid.

### Firebird 5 (ODS 13.1)

- [x] **Partial index DDL** — see correctness fixes above.
- [ ] **`SKIP LOCKED` keyword highlighting** — blocked on the SynEdit ceiling described at the top; needs locally-added keywords or an upstream Lazarus patch.
- [ ] **Parallel workers in Backup / Restore / Sweep** — blocked: this IBX version's `IBXServices.pas` exposes no `ParallelWorkers` SPB parameter (verified by grep), so it needs a vendored-submodule patch rather than a dialog change. The Maintenance dialog from Phase 5 is where the option would live.
- [ ] **SQL / PSQL profiler** — `RDB$PROFILER` package confirmed present on the FB6 test server; a UI panel driving `START_SESSION`/`FINISH_SESSION` and reading the profiler tables would complement the Phase 3 performance work.
- [x] **`MON$COMPILED_STATEMENTS` visibility** — a fourth Session Monitor tab, gated on ODS 13.1 (FB5) and simply hidden on older servers, since querying a table that does not exist is a hard error. Unlike the other three tabs this is a server-wide *cache* rather than a view of live activity — confirmed live that rows outlive the attachment that compiled them — so it answers "what does Firebird still have compiled, and what plan did it pick". A splitter-resizable pane under the grid shows the selected row's `MON$SQL_TEXT` and `MON$EXPLAINED_PLAN`, which is the part a grid cell cannot render (both arrive as `ftMemo`). `MON$OBJECT_NAME`/`MON$OBJECT_TYPE`/`MON$PACKAGE_NAME` are selected and decoded, but came back NULL for every probe on the FB6 test server — including a stored procedure querying the table from inside its own body — so in practice this surfaces top-level DSQL, not PSQL routines.
- [ ] **Multi-row `RETURNING`** — FB5 allows `INSERT ... RETURNING` to yield multiple rows; confirm `SQLForm.pas`'s execution path shows them all rather than only the first.
- [ ] **Inline ODS upgrade** — expose FB5's upgrade-without-backup/restore in the Maintenance dialog.

### Firebird 6 (ODS 14.x)

The test server for this audit is Firebird 6.0.0, so all of the following were
confirmed to exist rather than taken from release notes.

- [ ] **SQL schemas** — the largest item here by far. `RDB$SCHEMAS` exists, and FB6 already returns schema-qualified names (`"PUBLIC"."IBX_SMOKE_TEST"` shows up in FB6 error messages and `MON$TABLE_STATS.MON$SCHEMA_NAME`). Full support means a schema container level in the object tree, schema-qualified DDL generation, and `CREATE`/`ALTER`/`DROP SCHEMA` dialogs. Marathon's DDL is currently unqualified, which is still valid but ignores schemas entirely.
- [ ] **JSON functions** — keyword/completion support for `JSON_VALUE`, `JSON_QUERY`, `JSON_OBJECT`, `JSON_ARRAY`, `JSON_EXISTS`. Same SynEdit constraint as `SKIP LOCKED`.
- [ ] **`EXPLAIN` statement** — distinct from the `PLAN` clause. Phase 6's plan tree already parses Firebird 3+'s indentation-structured explained-plan format, so this is mostly wiring a new statement type through `SQLForm.pas` rather than new parsing.
- [ ] **Tablespaces** — show tablespace assignment in table/index properties and DDL.
- [ ] **Newer SQL:2023 surface** — `GREATEST`/`LEAST`, `UNLIST`, `ANY_VALUE`, named procedure arguments (`proc(arg => val)`), `ROW` types, underscores in numeric literals (`1_000_000`). Mostly keyword/completion work, same SynEdit constraint.

### Cross-cutting

- [x] **Server version detection** — `TMarathonCacheConnection` now reads and caches the real engine version and ODS on connect, exposed as `ServerVersion`/`ServerMajorVersion`/`ODSMajor`/`ODSMinor` plus two predicates: `IsFirebirdAtLeast(major)` for SQL-level features and `IsODSAtLeast(major, minor)` for anything depending on the on-disk schema. Both are needed because they can disagree — a database created by an older engine keeps its older ODS when opened by a newer server, and it is the ODS that decides which `RDB$` columns exist. Named constants (`FB_VERSION_4..6`, `ODS_FB3_MAJOR`, `ODS_FB4_MAJOR`, `ODS_FB5_MINOR`, `ODS_FB6_MAJOR`) replace scattered magic numbers; note FB4 and FB5 share ODS major 13 and differ only in the minor. Engine version comes from `RDB$GET_CONTEXT('SYSTEM','ENGINE_VERSION')` with an ODS-based fallback (that context variable only exists from FB2 on), and ODS from IBX's `IAttachment.GetODSMajorVersion`/`GetODSMinorVersion` — no query needed. Verified against the live FB6 server: engine 6.0.0, ODS 14.0, all predicates correct. Surfaced in the connection properties dialog next to the Phase 3 auth/protocol fields.
  `IsIB5`/`IsIB6` are deliberately left returning `True`: despite the names they are not version detection but "does this server use InterBase 6 semantics", which callers pass to `MakeQuotedIdent`/`ConvertFieldType` for quoted identifiers and dialect-3 types. Every Firebird release Marathon can connect to answers yes, so `True` is correct rather than a placeholder — they are now commented to say so, since they read like stubs.
- [ ] **System-table column audit** — the `MON$`/`RDB$` queries in `MarathonProjectCache.pas` and `DDLExtractor.pas` were written for IB6-era schemas; several have gained useful columns since (e.g. `RDB$RELATIONS.RDB$SQL_SECURITY` in FB4). Audit and widen them where the ODS allows, using `FindField` for version-conditional columns as the partial-index fix does.
- [x] **Packages (FB3) — DDL extraction and bulk export** — `TDDLExtractor` gained `ddlPackage`, reusing the same header/body subtype split as stored procedures (`ddlstHeader` → `CREATE OR ALTER PACKAGE ... AS <header>`, `ddlstProc` → `RECREATE PACKAGE BODY ... AS <body>`), ODS-12 gated. `TIBMetaExtract.WritePackages` writes all headers before any body, since a body may reference routines declared in another package's header — the same two-pass ordering stored procedures already use — and the bulk wizard has a Packages tab. A package may legitimately have a header and no body, so an empty body emits nothing rather than being treated as an error. Verified by round-trip: a package recreated from the generated script returns the same value from its packaged function.
- [x] **Packages (FB3) — object tree node** — a *Packages* branch now appears under each connection, listing `RDB$PACKAGES` and gated on ODS 12 (the branch is simply empty on older servers, since querying a missing table is a hard error). Selecting a package shows its DDL — header followed by body, which together are what recreating it actually takes — and the tree's "Extract Metadata" pre-selects it on the wizard's Packages tab. The persistence worry recorded here previously turned out to be unfounded: `TGSSCacheType` is serialised to the project XML by *name* via `GetEnumName`/`GetEnumValue`, not by ordinal, so appending values cannot invalidate saved projects. Two gaps left by that pass are closed alongside the replication work below: *Script As > CREATE* now works on a package (emitting header + body, the same pairing the DDL tab uses) rather than being restricted to tables/views/procedures, and "Extract Metadata" on the *Packages* header node now pre-selects every package under it, as the other header nodes already did.
- [ ] **Package editor** — packages are read-only for now: the tree shows them and the DDL tab renders them, but there is no editor form, so double-clicking does not open one the way it does for tables or procedures.

## Phase 8 — Remaining FlameRobin IDE Parity

Items FlameRobin lists that Marathon has not done. Ordered roughly by
value-for-effort; none are blocked on engine or library limits.

- [ ] **`Script as ALTER` / `DROP` / `MERGE`** — Phase 2 covers CREATE/SELECT/INSERT/UPDATE/DELETE/EXECUTE. FlameRobin also scripts `ALTER`, `DROP`, and `MERGE`. `DROP` is trivial; `MERGE` reuses the existing column-list helper; `ALTER` is the real work.
- [ ] **Environment color coding / connection profiles** — tag connections as Production/Staging/Development and color-code window headers. Cheap, and genuinely protective against running DDL on the wrong database.
- [ ] **Quick connection switcher in the SQL editor** — a dropdown to repoint an open script at another connection without reopening the tab.
- [ ] **XLSX result export** — Phase 4 added JSON/Markdown/TSV to the existing CSV/INSERT formats. XLSX needs a zip+XML writer (FPC's `fpspreadsheet`, or hand-rolled OOXML).
- [ ] **Interactive parameterized routine executor** — a dialog to fill a procedure's input parameters with per-type validation and show results in a grid, rather than hand-editing the generated `EXECUTE PROCEDURE`.
- [ ] **PSQL routine parameter helper** — call-signature tooltips/completion for procedures and packaged functions. Related to the SQL Insight templates that are stubbed on this port (see `CLAUDE.md`).
- [ ] **Schema comparison & migration generator** — compare two databases (or a database against a DDL script) and emit a migration script. Was listed as out of scope below on grounds of size; FlameRobin has since shipped it, so it is recorded here as a real gap rather than a rejection. Still the single largest item on this list.
- [ ] **HiDPI / scalable icons** — FlameRobin moved from XPM to SVG with `wxBitmapBundle`. The LCL equivalent would be replacing the `.RES`-embedded bitmap strips with scalable images for 4K displays.

---

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
| 7 | FB3 packages: editor form | Not started |
| 4 | JSON export of DECFLOAT/INT128/BOOLEAN | **Done** |
| 7 | Modern-type / index CI coverage | **Done** |
| 7 | FB4 long identifiers (audited, already OK) | **Done** |
| 7 | Real server-version detection + ODS gating | **Done** |
| 7 | FB4 named time zones / replication / encryption status | Not started |
| 7 | FB5 profiler, `MON$COMPILED_STATEMENTS`, parallel workers | Not started |
| 7 | FB5/FB6 keywords (blocked: SynEdit stops at `sqlFirebird40`) | Not started |
| 7 | FB6 SQL schemas | Not started |
| 7 | FB6 `EXPLAIN`, JSON functions, tablespaces | Not started |
| 8 | Script as ALTER / DROP / MERGE | Not started |
| 8 | Environment color coding / connection profiles | Not started |
| 8 | Quick connection switcher | Not started |
| 8 | XLSX export | Not started |
| 8 | Parameterized routine executor | Not started |
| 8 | Schema comparison / migration generator | Not started |
| 8 | HiDPI / scalable icons | Not started |
