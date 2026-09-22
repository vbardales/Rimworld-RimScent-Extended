# Offline validation results

## 2026-09-22 — current delivered revision

`powershell -ExecutionPolicy Bypass -File Tests/Check-Mod.ps1` passed:

- 9 distributed XML files parsed successfully.
- All 9 C#-used Keyed keys are present, nonempty, unique, and parameter-compatible in English and French.
- Root/distributed `LICENSE` and `ATTRIBUTION.md` copies match.
- Preview is 896x504 and 569,315 bytes; ModIcon is 128x128 and 18,295 bytes.
- The About metadata, direct GitHub link, RimScent dependency, hidden MainButtons definition,
  French MainButtonDef injection, and delivered DLL presence passed their contracts.

`dotnet build Source/RimScentExtended.csproj -c Release --nologo` passed with 0 warnings and
0 errors. The delivered DLL SHA-256 is
`F913332FE63E3E4AF18D5E536C0AC5ACCEACD2EF97FB690D97F7A442BC0BFC13`.

These offline checks do not execute RimWorld and do not establish UI interaction, persistence,
Harmony behavior, logging, or a Pickle result. Those checks remain unverified in
[`TEST_SCENARIOS.md`](../TEST_SCENARIOS.md).

`dotnet build Tests/Pickle/Source/RimScentExtended.PickleSteps.csproj -c Release --nologo`
also passed with 0 warnings and 0 errors. It produces the test-companion-only
`RimScentExtended.PickleSteps.dll`; no game process was started and no Pickle report exists.

The companion currently contains seven Gherkin features. Loading and MainButtons are selectable
in the minimal pass; the RIMMSQOL shortcut feature is selectable only with
`wsl-deps.avec-rimmsqol.map`. Engine-regression and settings-persistence specifications are
tagged `@wip`: they name the required fixture, settings sandbox, or language observer and were
not selected or run.
