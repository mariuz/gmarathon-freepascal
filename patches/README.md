# Patches for the vendored submodules

Fixes to `lib/fbintf` and `lib/ibx4lazarus` that Marathon needs but that belong
upstream.

`lib/fbintf` currently points at **https://github.com/mariuz/fbintf** rather
than MWASoftware's repository, pinned to the commit carrying the fix below, so
that a fresh `git submodule update --init --recursive` builds with it. The fork
tracks upstream and carries nothing else.

**When MWASoftware/fbintf#7 is merged**, undo that in one step:

```sh
git config --file .gitmodules submodule.lib/fbintf.url https://github.com/MWASoftware/fbintf.git
git config --file .gitmodules --unset submodule.lib/fbintf.branch
git submodule sync lib/fbintf
git -C lib/fbintf fetch origin && git -C lib/fbintf checkout <upstream commit with the fix>
git add .gitmodules lib/fbintf && git commit
```

and delete `fbintf-0001-transaction-use-after-free.patch`. The patch file is
kept alongside the fork so the change is readable here, and so it can be
applied by hand to any other checkout:

```sh
git -C lib/fbintf apply ../../patches/fbintf-0001-transaction-use-after-free.patch
```

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

The build now gets this fix by default, but Marathon still does not *depend* on
it - the workarounds below stay, because they also serve users on a stock
fbintf and because the casts do more than work around the defect. Its own
queries cast
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
