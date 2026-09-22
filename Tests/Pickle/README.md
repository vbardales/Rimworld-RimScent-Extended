# Pickle suite

This companion is development-only and is never part of `Mod/`.

The minimal pass runs `01-loading.feature` and `02-mainbuttons-settings.feature` in English and
French. They establish only what requires RimWorld: a minimal load, the hidden-by-default live
MainButtons shortcut, and the dialog it opens. The `@review` capture must be opened after a
passing report; a screenshot file alone is not visual evidence.

`03-rimmsqol-shortcut.feature` runs only in the `avec-rimmsqol` pass selected with
`-DepMap wsl-deps.avec-rimmsqol.map`. It uses the shared RIMMSQOL steps to inspect, reveal, and
hide the actual customization-mod entry; RIMMSQOL is not a gameplay dependency of this mod.

Build the local steps after building the mod:

```powershell
dotnet build Tests/Pickle/Source/RimScentExtended.PickleSteps.csproj -c Release
```

Run only through the shared WSL launcher, never through Windows RimWorld:

```powershell
powershell.exe -ExecutionPolicy Bypass -File scripts/Run-PickleWsl.ps1 -Mod RimScentExtended -Language English
powershell.exe -ExecutionPolicy Bypass -File scripts/Run-PickleWsl.ps1 -Mod RimScentExtended -Language French
powershell.exe -ExecutionPolicy Bypass -File scripts/Run-PickleWsl.ps1 -Mod RimScentExtended -DepMap wsl-deps.avec-rimmsqol.map -Filter 03-rimmsqol-shortcut.feature
```

The scent mechanics, settings persistence/restart, RIMMSQOL reveal/hide lifecycle, and save
compatibility require dedicated fixtures or the optional RIMMSQOL pass. They are specified in
[`TEST_SCENARIOS.md`](../../TEST_SCENARIOS.md), not claimed by this minimal suite. No Pickle pass
has been run yet.

`04-engine-regressions.feature`, `05-settings-persistence.feature`,
`06-save-compatibility.feature`, and `07-language-regression.feature` are intentionally tagged
`@wip`. They are written acceptance specifications, but cannot be selected until a ticket creates
the named engine/save fixture and the missing sandbox or observer steps. `@wip` is not a pass and
must only be included with a narrow filter after those prerequisites are delivered.
