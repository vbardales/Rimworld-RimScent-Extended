# Confirmed bugs in RimScent 1.6

Five defects in RimScent's C# code, all verified by decompiling
`Assembly-CSharp.dll` (RimWorld 1.6.4871) rather than from memory. Line references are in the
upstream mod's `1.6/Source/RimScentReworked/Pawn_ScentTracker.cs`.

All five are fixed by this mod, through a Harmony patch on `Pawn_ScentTracker`:
`Source/Runtime/ScentScan.cs` replaces `UpdateScent`, `Source/Patches/Patch_ScentTracker.cs`
holds `CompTick`. The upstream mod stays installed and up to date; nothing is forked.


---

## 1. An unlit incense burner scents the room anyway — line 155

```csharp
CompRefuelable refuelable = thing.TryGetComp<CompRefuelable>();
if (refuelable != null && !refuelable.HasFuel) continue;
CompPowerTrader power = thing.TryGetComp<CompPowerTrader>();
if (power != null && !power.PowerOn) continue;
```

The scan tests fuel and power, **never `CompFlickable`**.

But `CompRefuelable.CompTick` only consumes when the switch is on:

```csharp
if (!Props.consumeFuelOnlyWhenUsed && (flickComp == null || flickComp.SwitchIsOn) && ...)
    ConsumeFuel(ConsumptionRatePerTick);
```

An unlit incense burner therefore keeps its full tank indefinitely, `HasFuel` stays true, and the
smell keeps applying. That is a permanent, free `+6` to mood.

That glow and heat *do* stop shows the intent: `CompGlower` goes through
`FlickUtility.WantsToBeOn`, and `Verse.CompHeatPusherPowered.ShouldPushHeatNow` tests
`FlickUtility.WantsToBeOn(parent)`, `powerComp.PowerOn` **and** `refuelableComp.HasFuel`.

**Fix:** add the switch test in the same place.

```csharp
CompFlickable flick = thing.TryGetComp<CompFlickable>();
if (flick != null && !flick.SwitchIsOn) continue;
```

Electrically powered sources already escaped the problem, since `CompPowerTrader.PowerOn` goes
false when the switch is cut. Only **fuelled and flickable** sources were affected — that is,
exactly the two incense burners.

---

## 2. Dangling `else`: no indoor room partitioning at all — lines 126-128

```csharp
if (pawnOutdoors)
    if (!cellOutdoors) continue;
else if (cellRoom != pawnRoom)
    continue;
```

The indentation lies. In C#, `else` binds to the **nearest unmatched** `if`, so to the inner one:

```csharp
if (pawnOutdoors) {
    if (!cellOutdoors) continue;
    else if (cellRoom != pawnRoom) continue;
}
```

When the pawn is **indoors**, no cell filtering happens at all: they smell everything within the
radius and in line of sight, including another room through an open door, or the outdoors. The
"same room" restriction never applies.

**Fix:** explicit braces, and an indoor branch that requires the same room.

---

## 3. Per-scent dysosmia and anosmia triggered for everyone — lines 244 and 261

```csharp
if (ext.dysosmicTraitDegrees != null)
    return true;
```

The field is never compared against the pawn's traits: its mere **presence in the def** is enough
to return `true`. Same for `anosmicTraitDegrees` at line 261. The first scent def to declare
`dysosmicTraitDegrees` therefore inverts the mood of the entire colony.

No def in the upstream mod uses either field today — the bug is dormant, but it traps the first
person to follow the API documentation.

**Fix:** walk the list and test `TraitRequirement.HasTrait(pawn)`, the way the `dysosmicTraits` /
`anosmicTraits` branches just above do for trait names.

---

## 4. Anosmia triples the smell instead of cancelling it — line 291

```csharp
float offset = baseMood * (smellFactor - 1f);
if (dysosmic) offset -= baseMood * 2f;
if (anosmic)  offset += baseMood * 2f;
mem.moodOffset = Mathf.RoundToInt(offset);
```

`RimWorld.Thought_Memory.MoodOffset()` is `baseMoodEffect * moodPowerFactor + moodOffset`. The
total is therefore `baseMood + offset`:

| Case | `offset` | Total | Expected |
|---|---|---|---|
| normal (`smellFactor` = 1) | `0` | `baseMood` | `baseMood` |
| keen nose (`smellFactor` = 2) | `baseMood` | `2 × baseMood` | `2 × baseMood` |
| dysosmia | `−2 × baseMood` | `−baseMood` | inverted |
| **anosmia** | `+2 × baseMood` | **`3 × baseMood`** | **`0`** |

The sign is inverted. In practice, a `VTE_Desensitized` pawn — declared under `anosmicTraits` for
blood in `Core_Filth_Patch.xml` — takes **−6** instead of **−2** near blood, when the trait is
supposed to make them insensitive to it.

The `RimScent_Anosmic` trait does not go through this path: it cancels via a `statOffsets` of
`-999` on `RimScent_SmellSensitivity`, which puts `smellFactor` at 0 and triggers an early exit.
Only **per-scent** anosmia is affected.

**Fix:** do not add the memory at all when `anosmic` is true, rather than rigging a compensating
offset.

---

## 5. Dereference before null check — line 50

```csharp
Pawn pawn = Pawn;                 // parent as Pawn
if (pawn.IsAnimal) return;
if (pawn == null || !pawn.Spawned || pawn.needs?.mood == null) return;
```

`pawn.IsAnimal` runs before the `pawn == null` test. Since the comp is only put on the `Human`
`ThingDef` by `PawnScentPatch.xml`, the case does not arise today; it takes one mod adding the
comp elsewhere to get a `NullReferenceException` on every tick.

**Fix:** swap the two lines.
