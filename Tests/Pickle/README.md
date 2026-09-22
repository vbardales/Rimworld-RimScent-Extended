# Pickle suite

This companion is development-only and is never part of `Mod/`.

The minimal pass runs `01-loading.feature` and `02-mainbuttons-settings.feature` in English and
French. They establish only what requires RimWorld: a minimal load, the hidden-by-default live
MainButtons shortcut, and the dialog it opens. The `@review` capture must be opened after a
passing report; a screenshot file alone is not visual evidence.

Build the local steps after building the mod:

```powershell
dotnet build Tests/Pickle/Source/RimScentExtended.PickleSteps.csproj -c Release
```

Run only through the shared WSL launcher, never through Windows RimWorld:

```powershell
powershell.exe -ExecutionPolicy Bypass -File scripts/Run-PickleWsl.ps1 -Mod RimScentExtended -Language English
powershell.exe -ExecutionPolicy Bypass -File scripts/Run-PickleWsl.ps1 -Mod RimScentExtended -Language French
```

The scent mechanics, settings persistence/restart, RIMMSQOL reveal/hide lifecycle, and save
compatibility require dedicated fixtures or the optional RIMMSQOL pass. They are specified in
[`TEST_SCENARIOS.md`](../../TEST_SCENARIOS.md), not claimed by this minimal suite. No Pickle pass
has been run yet.
