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
# One-time: fetch the vendored IBX packages (three git submodules)
git submodule update --init --recursive

# Register the IBX packages with lazbuild (one-time per machine)
lazbuild --add-package-link lib/fbintf/fbintf.lpk
lazbuild --add-package-link lib/ibx4lazarus/ibexpress.lpk

# Debug build
lazbuild --build-mode=Debug src/Source/marathon.lpi

# Release build
lazbuild --build-mode=Release src/Source/marathon.lpi
```

### Working in the Lazarus IDE

The two package links above are all `lazbuild` needs, and all CI needs. They are
*not* enough to open the project in the IDE: registering a link makes a package
available to build against, while the form designer can only place a component
whose design-time package is compiled into the IDE binary. Without that, opening
any form carrying IBX components fails with

```
Unable to find the component class "TIBQuery".
It is not registered via RegisterClass and no lfm was found.
It is needed by unit: .../src/Source/EditorGrant.pas
```

and the only button is "Cancel loading this component". It recurs form by form —
most of the 75 `.lfm` files carry a `TIBQuery` or `TIBDatabase`.

The design-time package is `dclibx.lpk`, and it depends on `ibcontrols`, which
upstream moved out of `ibx4lazarus` into its own repository. That is why there is
a third submodule: `dclibx` will not build without it, even though Marathon uses
none of the `ibcontrols` components itself — only six of `dclibx`'s own property
editors do.

```bash
# One-time per machine, on top of the two links above
lazbuild --add-package-link lib/ibcontrols/ibcontrols.lpk
lazbuild --add-package-link lib/ibx4lazarus/ibLegacyServices.lpk
lazbuild --add-package-link lib/ibx4lazarus/iblocaldb.lpk

# Install the design-time package and rebuild the IDE (a few minutes)
lazbuild --add-package lib/ibx4lazarus/dclibx.lpk --build-ide=

# Then open the project with startlazarus, NOT lazarus-ide
startlazarus src/Source/marathon.lpi
```

The rebuild writes a private IDE to `~/.lazarus/bin/lazarus` and leaves the
system install (`/usr/share/lazarus/...`) untouched; `startlazarus` is the
launcher that prefers the private build, which is why `lazarus-ide` would still
give you the old one. To undo the whole thing, delete `~/.lazarus/bin`.

Two traps worth knowing. `ibexpress.lpk` is the runtime package and cannot be
installed — `lazbuild` answers `Package "..." is only for runtime`; `dclibx` is
the design-time half. And `lazbuild` exits non-zero on these failures, so run it
without a pipe: `lazbuild ... | tail` reports `tail`'s exit code and a broken
dependency looks like success.

### Running

```bash
cd src/Source && ./marathon
```

Setting `MARATHON_TRACE_EXCEPTIONS` makes Marathon print a Pascal backtrace —
unit names and line numbers — to stderr for every exception, as well as showing
the usual dialog:

```bash
cd src/Source && MARATHON_TRACE_EXCEPTIONS=1 ./marathon
```

Worth reaching for whenever a dialog reports something a message alone cannot
place, because `gdb` is of limited help here: the FPC RTL is compiled without
frame pointers, so a fault raised inside it (a list index check, say) unwinds
to `#2 0x0` and the calling code is lost. The variable costs a normal run
nothing when unset.

### Requirements

- Lazarus / FreePascal (developed against FPC 3.2.2, Lazarus 4.8.0)
- A running Firebird server to connect to at runtime
- Lazarus packages: `SynEdit`, `LCL`, `Printer4Lazarus`, `TAChartLazarusPkg`,
  `ibexpress`, `fbintf` (the latter two are vendored as git submodules under
  `lib/ibx4lazarus` and `lib/fbintf`)
- `lib/ibcontrols` is a third submodule, needed only to open the project in the
  Lazarus IDE — see [Working in the Lazarus IDE](#working-in-the-lazarus-ide).
  Building from the command line and CI do not use it.

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
which builds Release binaries for Linux, Windows, and macOS and attaches
them to a GitHub release for that tag (creating one if it doesn't already
exist) — the same tag-push-triggered, per-platform-job pattern
[FlameRobin's release workflow](https://github.com/mariuz/flamerobin/blob/master/.github/workflows/release.yml)
uses.

- **Linux** (`marathon-<version>-linux-x86_64.tar.gz`) also runs the IBX
  smoke test against the build before packaging it, since a live Firebird
  server is easy to stand up on the Linux runner (same as `build.yml`).
- **Windows** (`marathon-<version>-windows-x86_64.zip`) and **macOS**
  (`marathon-<version>-macos-arm64.zip`, native Apple Silicon) build only —
  this port has only ever been built and tested on Linux, so these jobs are
  best-effort and may need follow-up fixes (widgetset/package differences,
  `marathon.lpi` hardcoding `TargetOS=linux`, worked around in the workflow via
  `lazbuild --os=... --cpu=...`) once they've actually run.

## Architecture

See [CLAUDE.md](CLAUDE.md) for a full guide to the codebase: layer-by-layer
architecture, the IBX database access pattern (and how it differs from
SQLDB/older IB Objects-based code you may still see referenced in comments),
and a reference table mapping legacy Delphi components to their Lazarus/LCL
replacements.

## License

Source files carry Mozilla Public License 1.1 headers; see individual files
for details.
