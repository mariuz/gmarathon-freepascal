# Marathon

[![Build](https://github.com/mariuz/gmarathon-freepascal/actions/workflows/build.yml/badge.svg)](https://github.com/mariuz/gmarathon-freepascal/actions/workflows/build.yml)

Marathon is a SQL IDE and database administration tool for [Firebird](https://firebirdsql.org/)
databases. This repository is a port of the original Delphi
[gmarathon](http://gmarathon.sourceforge.net/) codebase to
[Lazarus/FreePascal](https://www.lazarus-ide.org/), using MWASoftware's
[IBX](https://github.com/MWASoftware/ibx4lazarus) for all Firebird connectivity.

## Features

- **SQL editor** with Firebird 4 keyword highlighting, an execution plan viewer
  (rendered as an indented tree, full table scans vs. indexed access
  color-coded), and a result grid that exports to CSV/HTML/INSERT
  statements/JSON/Markdown/TSV and supports an in-memory filter box
- **Database object explorer** for tables, views, procedures, triggers,
  domains, generators, exceptions, and UDFs, with DDL reverse-engineering and
  "Script As" (CREATE / SELECT / INSERT / UPDATE / DELETE / EXECUTE) directly
  from the object tree
- **Bulk metadata extraction wizard** — export DDL for any combination of
  database objects to a single script, with dependent-object inclusion and
  metadata/data export modes
- **Live Session Monitor** (attachments, statements, transactions) with
  Cancel Statement / Disconnect Attachment, and a Query Performance Analysis
  view (indexed vs. sequential reads, record/page counters), both sourced
  from Firebird's `MON$` monitoring tables
- **Database Maintenance dialog** — sweep, validate/repair, index statistics
  recompute, and backup/restore, all via IBX's Services API
- Connection properties showing live authentication method / remote protocol

See [ROADMAP.md](ROADMAP.md) for the full feature history and status.

## Building

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

### Requirements

- Lazarus / FreePascal (developed against FPC 3.2.2, Lazarus 4.8.0)
- A running Firebird server to connect to at runtime
- Lazarus packages: `SynEdit`, `LCL`, `Printer4Lazarus`, `TAChartLazarusPkg`,
  `ibexpress`, `fbintf` (the latter two are vendored as git submodules under
  `lib/ibx4lazarus` and `lib/fbintf`)

## Testing

There's no unit test suite. `test/ibx_smoke_test.lpr` is a standalone
integration test that connects to a real Firebird server and exercises the
IBX database layer and DDL extraction end to end:

```bash
lazbuild test/ibx_smoke_test.lpi
./test/ibx_smoke_test <database> <user> <password>
```

CI (`.github/workflows/build.yml`) builds Debug and Release and runs this
smoke test against a live Firebird server on every push and pull request to
`master`.

## Releases

Pushing a `v*` tag (e.g. `v1.0.0`) triggers `.github/workflows/release.yml`,
which builds a Release binary, runs the IBX smoke test against it, packages
`marathon` plus `README.md`/`ROADMAP.md` into
`marathon-<version>-linux-x86_64.tar.gz`, and attaches it to a GitHub
release for that tag (creating one if it doesn't already exist) — the same
tag-push-triggered pattern [FlameRobin's release workflow](https://github.com/mariuz/flamerobin/blob/master/.github/workflows/release.yml)
uses, scaled down to this project's single Linux build target.

## Architecture

See [CLAUDE.md](CLAUDE.md) for a full guide to the codebase: layer-by-layer
architecture, the IBX database access pattern (and how it differs from
SQLDB/older IB Objects-based code you may still see referenced in comments),
and a reference table mapping legacy Delphi components to their Lazarus/LCL
replacements.

## License

Source files carry Mozilla Public License 1.1 headers; see individual files
for details.
