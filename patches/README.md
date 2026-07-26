# Patches for the vendored submodules

Fixes to `lib/fbintf` and `lib/ibx4lazarus` that Marathon needs but that belong
upstream. They are kept here as patch files rather than by pointing the
submodules at a fork, so that `git submodule update --init --recursive` keeps
working against MWASoftware's repositories for everyone.

Apply them with:

```sh
git -C lib/fbintf apply ../../patches/fbintf-*.patch
```

Drop a patch once the corresponding pull request is merged and the submodule is
bumped past it.

## fbintf-0001-transaction-use-after-free.patch

**Upstream PR:** https://github.com/MWASoftware/fbintf/pull/7

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

Marathon does not depend on the patch being applied. Its own queries cast
`WITH TIME ZONE` columns to text, which both preserves the IANA zone name and
avoids the defect, and `src/Common/SafeDisconnect.pas` contains the fault if a
user's own query in the SQL editor triggers it. `test/ibx_smoke_test.lpr`
reports which state it is in:

- unpatched: `Disconnect hardening OK (contained: EObjectCheck ...)`
- patched:   `Disconnect hardening OK (clean - the IBX defect appears fixed ...)`

`test/timezone_disconnect_repro.lpr` is the standalone reproduction.

## Not patched, and why

- **Parallel workers in backup/restore/sweep** and **inline ODS upgrade** both
  need new Services API surface in `ibx4lazarus`: its `TIBXValidationService`
  exposes seven repair options with no upgrade among them, and the vendored
  headers carry no `isc_spb_rpr_*` constant for one. Adding either would mean
  proposing an API upstream that cannot be exercised here — there is no
  old-ODS database to upgrade on this test server — so they are left as
  roadmap items rather than untested patches.
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
