# Functional validation scenarios

These scenarios are **not executed in game**. They define the `done -> tested` evidence only;
they do not turn source inspection or a successful build into an in-game claim. Use RimWorld 1.6,
Harmony, RimScent, and this mod's delivered DLL. Record the commit, language, mod list, save
identity, expected and observed results, and the relevant Player.log excerpt for every run.

Run the settings scenarios in separate English and French launches. Use a new disposable colony
for behavior checks and a copy of any existing save; never overwrite the only save copy.

| Scenario | Preconditions and actions | Expected result |
| --- | --- | --- |
| Load and basic scan | Load a new colony with RimScent and this mod; inspect the log after map generation and several game ticks. | No patch, def, dependency, or repeated scan exception. |
| Incense switch fix | Place and fuel a flickable incense burner; compare an on, then switched-off, burner in the same room. | A switched-off fuelled burner contributes no scent; switching it back on restores the ordinary RimScent behavior. |
| Room separation fix | Position a pawn indoors beside an open doorway and outdoors beside a room boundary, with known scented targets on both sides. | Indoors, only the pawn's own room is scanned; outdoors, indoor cells are excluded. |
| Per-scent anosmia and dysosmia | Give test pawns the relevant RimScent trait-degree requirements and place them beside a scent that declares each condition. | Anosmia suppresses that scent; dysosmia inverts only the matched pawn's response; unaffected pawns retain the ordinary response. |
| Temperature | Compare an identical scent near -10 C, 20 C, and 45 C with Temperature enabled, then disabled. | Effects follow the documented 40%, 100%, and 160% factors when enabled; disabling restores the base factor. |
| Adaptation | Keep a pawn near a stable scent until the configured duration, leave the area, then return; repeat with pleasant adaptation disabled. | Strength approaches the configured floor, recovers away from the scent, and pleasant scents do not fade when their toggle is off. |
| Settings primary route | On a clean configuration, open Mod options -> RimScent Extended; change every setting, close and reopen. | Documented defaults load; all labels/tooltips are translated; values persist and change the corresponding behavior. |
| MainButtons shortcut | Without customization mods, confirm no visible or greyed shortcut. With RIMMSQOL (record version), reveal `RimScentExtended_Settings`, change a setting, reopen through Mod options, then hide it. | The hidden-by-default shortcut opens the same settings and shares values; revealing/hiding it requires no gameplay dependency. |
| Save and removal | Change settings, save, restart, reload an existing save, then remove/re-add this mod on a copy. | Global settings persist; no save component or stale adaptation state causes errors; the mod can be safely removed as documented. |
| EN/FR regression | Repeat the settings, shortcut, corpse, spoiled-food, pawn-scent, terrain-scent, and hediff-scent views in English and French. | No raw keys, fallback text, clipping, unresolved DefInjected paths, or runtime errors. |

After each scenario, inspect Player.log for exceptions, missing translations/Defs, or repeated messages.
Re-run every affected scenario after a correction.
