---
localization: complete
translation_en: complete
translation_fr: complete
settings_audit: partial
mod: RimScent Extended
packageId: nelim.rimscent.extended
repo: Rimworld-RimScent-Extended
visibility: public
detached: yes
workflow_stage: writeTests[1.0.0]
licence: open
licence_at: upstream repository, MIT, copyright ocarina0001 2026
dependencies: declared
showcase: complete
tested_on:
workshop:
remaining:
  - open: 7.d features 05, 06, 06b, 07 rewritten on generic steps (Check-Steps clean); 04 and 08 (46 lines) wait for NPT probe ticket adee (trait degree, room temperature, fuel, corpse/food rot, static member). Mod-removal pass of 06: pass 2 hosted by PickleTools removal-check.feature (NPT, not yet played; map wsl-deps.removal-pass2.map here), chain: 06 copies the save to the run folder, copy it to the fixtures of both mods, then PickleTools pass, then 06b. No local step.
  - done: ticket 3dce, feature 07 French, 2 of 2 green (summary.json and junit agree), evidence Tests/Pickle/Inbox/07-french; the two @review screenshots are not yet opened, 07 English not played (translation report only for non-English).
  - done: ticket 45bb, feature 05 scenario 1 green on NPT fix 472f955 (summary.json and junit agree), evidence Tests/Pickle/Inbox/05-fifth; scenario 2 green in 45c2. Feature 05 proved.
  - done: ticket f322 (P1, feature 06) green, 1 of 1 (summary.json and junit agree), evidence Tests/Pickle/Inbox/06-p1; save copied to Fixtures here and to ../PickleTools removal-check.rws (git-ignored).
  - done: ticket 2a29 (P2 removal-check) red, 4 benign "did not load any content" messages of NPT's own code-only mods; fixed by NPT in PickleTools b020d19. Refiled as 20261103-101656-405-c1c5 (Tests/Pickle/Inbox/removal-check-p2).
  - done: ticket 20261103-100746-763-8d06 (P3, feature 06b save reload) green, 1 of 1 (summary.json exitReason "passed", junit agrees), evidence Tests/Pickle/Inbox/06b. Save chain of feature 06 proved on RSE side (f322 + 8d06).
  - done: ticket 20261103-101656-405-c1c5 (P2 removal-check refile on PickleTools b020d19) green, 1 of 1 (summary.json exitReason "passed"), evidence ../PickleTools/Tests/Pickle/Inbox/removal-check-p2. Whole save chain of feature 06 green (f322, c1c5, 8d06).
  - waiting: features 04 and 08 (fixture generation, scanner observer) after NPT worldprobe replay; rot placement is a test-side fixture step of feature 08 scenario "corpses and spoiled food use their rot-stage thoughts" (no code change; rot logic already in Source/Runtime/ScentScan.cs). NPT probe ticket 20261103-084846-808-adee gates the rewrite of 04 and 08 (46 lines). Submit-PickleRun.ps1 lives in ../Rimworld-Ticket-Dispatcher/scripts (forward slashes from bash).
  - done: Preview regenerated 2026-11-03 (echo without width/height; icon trimmed to Art/ModIcon-badge.png, margin over 5 %); echo visible, no clipping, no overlap with title. Social preview upload and social_preview_sha256 still due from writeDocs.
  - unverified: no RimWorld session was launched; runtime behavior, persistence, EN/FR layout, logs, and integrations remain unverified.
  - unverified: eight Pickle/Gherkin features are written and compiled but none has run; five remain @wip pending fixture-generation ticket or missing observer/sandbox steps.
updated: 2026-11-03, workflow_stage set to writeTests[1.0.0]
protocols_read_sha: b51c6cdc44399e67ca7f768aa1b7ba2d9051baec
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

## Settings audit — static gate

`SettingsCategory()` and `DoSettingsWindowContents()` provide the primary Mod options page.
`MainButtons_RimScentExtended.xml` now supplies the optional
`RimScentExtended_Settings` shortcut with `buttonVisible=false`, so it is neither visible nor
greyed out by default and remains available to compatible customization mods. Its worker opens
`Dialog_ModSettings(RimScentExtendedMod.Instance)`, the same settings UI as the primary route.
The shortcut and its French label/description compiled and parsed successfully. No game run was
used to infer any runtime result; those interaction checks remain part of the later `tested` gate.

### Usage review (5.e) and offline tests (5.f): 2026-11-03

Scope: all five settings live in `RimScentExtendedSettings` (a `ModSettings`), so they are global
to the game install, never per save. Application time: `temperatureEnabled` is read on each scan
(`ScentScan.cs`), so it applies immediately; the adaptation settings are read by
`ScentAdaptation` on each use, and `WriteSettings` clears the exposure counters on closing the
options, so the new values apply at once from a clean exposure. The floor and hours sliders are
shown only while adaptation is on (dependent controls hidden, not greyed). Each control has a
translated label, and both checkboxes with a tooltip; floor is shown as a percentage and hours
with one decimal. No reset-to-defaults button is offered (five options, defaults in the code).

| Area | Expected | Observed |
| --- | --- | --- |
| First use | Missing values give defaults (adaptation on, floor 0.5, 2.5 h, pleasant on, temperature on) | Source: `Scribe_Values.Look` defaults match the field defaults. In game: unverified |
| Primary access | Options page "Mod options → RimScent Extended" | `SettingsCategory()` and `DoSettingsWindowContents()` present. In game: unverified |
| Actual effect | Each option changes scan result at once | Source: read in `ScentScan.cs` and `ScentAdaptation.cs`. In game: unverified |
| Persistence | Values survive restart | `ExposeData` saves all five keys. In game: unverified |
| Input validation | Sliders bounded; floor clamped to 0.05 to 1, hours to 0.5 to 12 | Source: `Slider` bounds and `Mathf.Clamp` in `ScentAdaptation`; `AdaptationTicks` at least 1. Passed by inspection |
| Defaults and upgrades | Missing key keeps default | `Scribe_Values.Look` default argument. Passed by inspection |
| Optional dependencies | None | Not applicable: only the hard dependency on RimScent |
| Shortcut default | No visible or greyed MainButton | `Tests/Check-Mod.ps1` passed: `buttonVisible=false`, worker class matches |
| Shortcut integration | RIMMSQOL reveals it and opens the same dialog | Worker opens `Dialog_ModSettings(RimScentExtendedMod.Instance)`. In game: unverified |
| Runtime robustness | No exception when opening, editing, saving | In game: unverified |

Offline runs 2026-11-03: `Tests/Check-Mod.ps1` passed; `Check-ModBasics.ps1` PASS (9 XML files, 3
defs); `Check-Translations.ps1` PASS (9 Keyed calls). `settings_audit` is set to `partial`: the
in-game rows above move to `playTests`.

## Translation audit — complete for static readiness

All player-facing C# UI text is routed through the nine owned Keyed keys; remaining string
literals are identifiers, serialization keys, reflection names, or Def names. EN/FR Keyed
coverage, placeholder parity, and loaded French DefInjected paths were checked statically.
In-game EN/FR display remains explicitly unverified, as required for the later `tested` gate.

Checks 2026-11-03 (stage 6): 6.a/6.b the player texts are the nine Keyed keys, the MainButtonDef
label and description, and the two own ThoughtDefs (`worn scent`, `fermenting wort`; their
English Def values are the EN coverage, French in `Mod/Core/Languages/French/DefInjected`, loaded
only with RimScent) plus the RimScent core thought `RimScent_FreshOxygen`. 6.c
`Check-Translations.ps1` PASS (9 Keyed calls, 6 source texts); 2 French injection paths are nested
or inherited and not in its inventory, `Check-DefInjected.ps1` was not usable for this mod (0 keys
checked), so those two paths stay `unverified`. 6.d French read sentence by sentence: no tu, vous
or nous, impersonal and infinitive forms, no gendered text. 6.e not applicable (no pawn-agreeing
text). 6.f `FRENCH_REVIEW.md` generated at revision 998f372 by `Make-FrenchReview.ps1`. 6.g French
review by Virginie done 2026-11-03 (`translation_fr: complete`): reviewer Virginie, revision 50a38ee (`FRENCH_REVIEW.md` generated at 23961e1), corrections = the ChatGPT fixes below, accepted by her; sixth ChatGPT review found nothing. ChatGPT review of page 1 (2026-11-03): one fix applied with her agreement (`fermenting_wort` description, now "Quelque chose se prépare."); the `PUBLICATION.md` remark is moot until `writeDocs`. Second ChatGPT review of page 1 (2026-11-03): two fixes applied (`PleasantTip`: "ce qui correspond à la réalité", "d'en installer une"); third ChatGPT review: two fixes applied (`Hours`: "nécessaires pour atteindre ce seuil", `worn_scent` description: "a appliqué quelque chose. C'est discret, délibéré et efficace."), `AdaptationTip` rewording left out (original already natural). Fourth review: `TemperatureTip` reworded ("atteint 40 % de sa force ... 100 % à 20 °C"), applied; the empty Original and English columns for `RimScent_FreshOxygen` come from RimScent's own text, French unchanged. Fifth review: `TemperatureTip` "Cela s'applique aux bonnes comme aux mauvaises odeurs" applied. The optional `TemperatureTip` rewording ("L'intensité d'une odeur est de 40 %") left out because it breaks the parallel with "sa pleine force" and "160 %".

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
- 4.b/4.d checked 2026-11-03: RimScent (reo.RimScent) itself lists `brrainz.harmony` in its
  `modDependencies`, so Harmony is guaranteed transitively and `loadAfter` is enough here.
  `sort-load-order.py` with reo.rimscent and this mod active: order `reo.rimscent`, then
  `nelim.rimscent.extended`, exit 0, no cycle.

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
