# Patches for the vendored submodules

Fixes and additions to `lib/fbintf` and `lib/ibx4lazarus` that Marathon needs
but that belong upstream.

Both submodules currently point at forks under **mariuz** rather than
MWASoftware, pinned to commits carrying the changes below, so that a fresh
`git submodule update --init --recursive` builds with them. The forks track
upstream and carry nothing else. The same changes are exported here as patch
files so they stay readable, and so they can be applied by hand to any other
checkout:

```sh
git -C lib/fbintf      apply ../../patches/fbintf-transaction-and-parallel-workers.patch
git -C lib/ibx4lazarus apply ../../patches/ibx4lazarus-parallel-workers.patch
```

| Change | Upstream PR | Submodule branch |
| --- | --- | --- |
| Transaction use-after-free | [MWASoftware/fbintf#7](https://github.com/MWASoftware/fbintf/pull/7) | `fbintf: marathon-integration` |
| Parallel workers SPB constants | [MWASoftware/fbintf#8](https://github.com/MWASoftware/fbintf/pull/8) | as above |
| Parallel workers property | [MWASoftware/ibx4lazarus#23](https://github.com/MWASoftware/ibx4lazarus/pull/23) | `ibx4lazarus: add-parallel-workers` |

The fbintf fork keeps each change on its own branch so the two pull requests
stay independent (`fix-use-after-free-in-transaction-end` and
`add-parallel-workers-spb`); `marathon-integration` is just the two together,
and is what the submodule pins.

**Once a pull request is merged**, repoint that submodule back at MWASoftware
and drop the corresponding patch:

```sh
git config --file .gitmodules submodule.lib/fbintf.url https://github.com/MWASoftware/fbintf.git
git config --file .gitmodules --unset submodule.lib/fbintf.branch
git submodule sync lib/fbintf
git -C lib/fbintf fetch origin && git -C lib/fbintf checkout <upstream commit with the change>
git add .gitmodules lib/fbintf && git commit
```

## fbintf: transaction use-after-free

Reading a Firebird 4 `WITH TIME ZONE` column and then disconnecting raises
`EObjectCheck: Object reference is Nil` from inside IBX's own
`TFBTransaction.DoDefaultTransactionEnd`.

Reading a time zone value creates `TFB30TimeZoneServices`, which starts an
internal transaction for the `rdb$time_zone_util` lookups and registers itself
on it. At disconnect, `DoDefaultTransactionEnd` calls `TransactionEnding` on
each registered user; the time zone services clears its own reference, and
since the interface list holds raw object pointers rather than counted
references, that is the last one. The transaction is destroyed while
`DoDefaultTransactionEnd` is still running, and the `Commit` at the end of that
method operates on freed memory. The patch holds a reference to `self` for the
duration.

The build now gets this fix by default, but Marathon still does not *depend* on
it - the workarounds stay, because they also serve users on a stock fbintf and
because the casts do more than work around the defect. Its own queries cast
`WITH TIME ZONE` columns to text, which both preserves the IANA zone name and
avoids the defect, and `src/Common/SafeDisconnect.pas` contains the fault if a
user's own query in the SQL editor triggers it. `test/ibx_smoke_test.lpr`
reports which state it is in:

- unpatched: `Disconnect hardening OK (contained: EObjectCheck ...)`
- patched:   `Disconnect hardening OK (clean - this fbintf has the fix ...)`

`test/timezone_disconnect_repro.lpr` is the standalone reproduction.

## Parallel workers (both submodules)

Firebird 5 can run a backup or restore with several workers, as `gbak -par`
does. Neither submodule could ask for it: `consts_pub.inc` predates Firebird 5
and defines no `isc_spb_bkp_parallel_workers`, and `IBXServices.pas` builds its
service parameter block without one. The fbintf side adds the constants (values
taken from the header shipped with Firebird 6.0.0, not from documentation); the
ibx4lazarus side adds a published `ParallelWorkers` property to
`TIBXBackupRestoreService`, sent only when it is greater than one and the
server is Firebird 5 or later.

Marathon offers it on the Database Maintenance dialog. Verified against a live
Firebird 6.0.0 server: with one worker the parameter is not sent, with four it
is, the server accepts it, and the resulting backup restores to a working
database.

## Not patched, and why

- **Inline ODS upgrade** still has nothing to drive it: it is a Services API
  repair action, and neither the vendored headers nor Firebird's own define an
  `isc_spb_rpr_*` constant for it. Unlike parallel workers there is also no way
  to exercise it here - the test server has no old-ODS database to upgrade - so
  it is left as a roadmap item rather than an untested patch.
- **`TIBQuery.Params[i].DataType` is always `ftUnknown`**, so a caller cannot
  learn a parameter's declared type from a `TIBQuery`; the types are only
  reachable by preparing a `TIBSQL` alongside, which is what
  `SQLForm.BindStatementParameters` does. Populating it at prepare time would
  be a real improvement, but it changes binding behaviour for every existing
  caller and there is no IBX regression suite here to justify that against.
- **`fb_info_crypt_state` is not classified** by `FBOutputBlock.pas`'s
  DB-information parser, so every accessor rejects the item even though the
  server returns it (type 134, size 4). Adding it to the integer group looked
  like a one-line fix but did not take effect in testing and the reason was not
  established, so it is deliberately not proposed. Marathon reads the same
  state from `MON$DATABASE.MON$CRYPT_STATE` instead.
