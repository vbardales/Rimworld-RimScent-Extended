---
localization: complete
translation_en: complete
translation_fr: unchecked
settings_audit: complete
mod: RimScent Extended
packageId: nelim.rimscent.extended
repo: Rimworld-RimScent-Extended
visibility: public
detached: yes
workflow_stage: code[1.0.0]
licence: open
licence_at: upstream repository, MIT, copyright ocarina0001 2026
dependencies: declared
showcase: complete
tested_on:
workshop:
remaining:
  - open: 7.d features 05, 06, 06b, 07 rewritten on generic steps (Check-Steps clean); 04 and 08 (46 lines) wait for NPT probe ticket adee (trait degree, room temperature, fuel, corpse/food rot, static member). Mod-removal pass of 06: pass 2 hosted by PickleTools removal-check.feature (NPT, not yet played; map wsl-deps.removal-pass2.map here), chain: 06 copies the save to the run folder, copy it to the fixtures of both mods, then PickleTools pass, then 06b. No local step.
  - unverified: no RimWorld session was launched; runtime behavior, persistence, EN/FR layout, logs, and integrations remain unverified.
  - unverified: eight Pickle/Gherkin features are written and compiled but none has run; five remain @wip pending fixture-generation ticket or missing observer/sandbox steps.
updated: 2026-11-02, replay-audit: workflow_stage set to code[1.0.0]
protocols_read_sha: ea9bb723555c6edf9624522fb2cc8b6142d4b537
---

# RimScent Extended — status

## Audit — 2026-09-22

**Retained stage: `preTest`.** The audit began while this was a folder in the shared `rimworld`
monorepo. It is now an autonomous public repository at
`https://github.com/vbardales/Rimworld-RimScent-Extended`, with `main` pushed at
`1d6d1f9704e3c194cf26f75c13c42ba93e15e23e`. `STATUS.md`, package identity, public visibility,
MIT attribution, `CHANGELOG.md`, `.gitignore`, `.gitattributes`, and English repository
documentation are present. `BUGS.md` and `NOTES.md` were re-read and are already English.

The audit was made against the files currently on disk. `git status -- RimScentExtended`
was clean before and after the checks; the enclosing monorepo has unrelated local work.
No RimWorld instance was started.

## Independent validations retained

- `dotnet build Source/RimScentExtended.csproj -c Release --nologo`: passed with 0 warnings
  and 0 errors after the settings-shortcut addition. The delivered
  `Mod/Assemblies/RimScentExtended.dll` SHA-256 is
  `F913332FE63E3E4AF18D5E536C0AC5ACCEACD2EF97FB690D97F7A442BC0BFC13`.
- All nine distributed XML files parsed successfully, including `About.xml`, `LoadFolders.xml`,
  defs, French DefInjected resources, and EN/FR Keyed resources.
- `ModIcon.png` is 128x128 (18,295 bytes); `Preview.png` is 896x504 (569,315 bytes, under
  1 MiB). Both were directly inspected. The preview uses a RimWorld-like overhead scene and
  distinct orange, green, and pink scent accents; no concrete visual defect was observed.
- The useful settings are Temperature; olfactory adaptation; its floor, duration, and pleasant-
  scent toggle. Their defaults are serialized by `RimScentExtendedSettings.ExposeData`, and the
  UI uses nine mod-prefixed translated keys. The matching EN and FR files each contain all nine
  keys once; their `{0}` placeholders agree. The two own ThoughtDef labels/descriptions have
  French DefInjected entries, while their English Def values are the native fallback.
- `About.xml` correctly declares the `reo.RimScent` hard dependency used by the compiled code;
  `LoadFolders.xml` conditions `Core` on that same package. Harmony is only `loadAfter`, matching
  the packaged Harmony reference.

## Settings audit — complete for the preOptions-to-options static gate

`SettingsCategory()` and `DoSettingsWindowContents()` provide the primary Mod options page.
`MainButtons_RimScentExtended.xml` now supplies the optional
`RimScentExtended_Settings` shortcut with `buttonVisible=false`, so it is neither visible nor
greyed out by default and remains available to compatible customization mods. Its worker opens
`Dialog_ModSettings(RimScentExtendedMod.Instance)`, the same settings UI as the primary route.
The shortcut and its French label/description compiled and parsed successfully. No game run was
used to infer any runtime result; those interaction checks remain part of the later `tested` gate.

## Translation audit — complete for static readiness

All player-facing C# UI text is routed through the nine owned Keyed keys; remaining string
literals are identifiers, serialization keys, reflection names, or Def names. EN/FR Keyed
coverage, placeholder parity, and loaded French DefInjected paths were checked statically.
In-game EN/FR display remains explicitly unverified, as required for the later `tested` gate.

## Dependency record (4.g): 2026-11-03, revision 169a9f5

- Hard dependency: `reo.RimScent` (Workshop 3645569466), declared in `About.xml` `modDependencies`
  with its Workshop URL. The compiled code references `RimScentReworked.dll` and patches its
  scent tracker, so the dependency is technically required.
- `loadAfter`: `brrainz.harmony`, `Ludeon.RimWorld`, `reo.RimScent`. Harmony is only ordered, not
  required: the packaged `Lib.Harmony` 2.4.3 reference is compile-time only (`ExcludeAssets runtime`).
- `LoadFolders.xml` (v1.6): root always loaded; `Core` (French DefInjected for the RimScent thoughts)
  loaded only `IfModActive="reo.rimscent"`.
- No DLC dependency and no `incompatibleWith`. Optional integrations: none in this mod; the seven
  expansion mods declare this mod as their dependency. RIMMSQOL only reveals the hidden settings
  shortcut and is not referenced.
- Not an animal mod: the four animal integrations of `ANIMALS.md` do not apply.

## Unit tests (7.b): 2026-11-03

No `Tests/*.Tests.csproj` exists, on purpose: the C# is a small Harmony patch plus data classes that
only work against the running RimScent and RimWorld engine, so a unit test would mock the engine it
is meant to check. The offline proof is `Tests/Check-Mod.ps1` (mod-specific contracts, see
`TESTING.md`) together with the shared `Check-ModBasics.ps1`, `Check-Translations.ps1` and the
release build. Behaviour is covered by the Pickle features, not yet run (see `remaining`).

## Later-stage observations

The English `About.xml` description now ends with the required, direct GitHub source-code link.
No test directories or scenarios exist, so the requirements of `preTest → done` have not been
demonstrated.

## Strictly necessary next transition

Obtain a fixture-generation ticket and implement the fixture-backed, settings-sandbox, and
language-observer steps, removing every `@wip` only once its real prerequisite exists. Then
execute the applicable offline suite again against the delivered DLL. The resulting evidence must
match that DLL before `preTest → done` can pass. For `done → tested`, every conditional scenario
must run in its required dependency and language configuration, all applicable automated checks
must be green, and no manual validation may remain; `@review` captures must be opened and
actually reviewed. Runtime work remains unverified rather than defective.
