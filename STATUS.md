---
localization: complete
translation_en: complete
translation_fr: complete
settings_audit: complete
mod: RimScent Extended
packageId: nelim.rimscent.extended
repo: Rimworld-RimScent-Extended
visibility: public
detached: yes
stage: preTest
licence: open
licence_at: upstream repository, MIT, copyright ocarina0001 2026
dependencies: declared
showcase: complete
tested_on:
workshop:
remaining:
  - unverified: no RimWorld session was launched; runtime behavior, persistence, EN/FR layout, logs, and integrations remain unverified.
  - unverified: the minimal Pickle/Gherkin suite is written and compiled but has not run; fixture-backed scent mechanics, settings persistence, RIMMSQOL lifecycle, and save scenarios still need their own Gherkin coverage.
updated: 2026-09-22, evidence-based audit
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

## Later-stage observations

The English `About.xml` description now ends with the required, direct GitHub source-code link.
No test directories or scenarios exist, so the requirements of `preTest → done` have not been
demonstrated.

## Strictly necessary next transition

Complete the fixture-backed Pickle/Gherkin coverage for the remaining functional scenarios, then
execute the applicable offline suite again against the delivered DLL. The resulting evidence must
match that DLL before `preTest → done` can pass. Runtime work remains unverified rather than
defective.
