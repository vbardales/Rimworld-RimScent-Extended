# RimScent Extended

The socle of the RimScent Extended family: five fixes to the engine of
[RimScent](https://steamcommunity.com/sharedfiles/filedetails/?id=3645569466)
(reo, ocarina0001), two mechanics it was missing, and two extension points it did not have.
For RimWorld 1.6.

**On its own it adds almost no content.** It is what the seven expansions are built on.

## The seven expansions

| Mod | Theme |
|---|---|
| [Incense Plus](https://github.com/vbardales/Rimworld-rimscent-extended-incense-plus-expansion) | six incenses with real effects, and the Incense Expansion rebalanced |
| [Perfume Plus](https://github.com/vbardales/Rimworld-RimScent-Extended-Perfume-Plus-Expansion) | worn perfumes, vaping, mint |
| [Everyday Life](https://github.com/vbardales/Rimworld-RimScent-Extended-Everyday-Life-Expansion) | cooking, coffee, bread, flowers, knick-knacks |
| [Decay](https://github.com/vbardales/Rimworld-RimScent-Extended-Decay-Expansion) | graded corpses, spoiled food, sickroom |
| [Farmyard](https://github.com/vbardales/Rimworld-RimScent-Extended-Farmyard-Expansion) | droppings, livestock, hives, insectiary |
| Industry | crematorium, smelter, tallow, torches, chemfuel, filth |
| [Weather](https://github.com/vbardales/Rimworld-RimScent-Extended-Weather-Expansion) | drought, heat wave, psychic bloom |

The design reasoning behind each one is in [NOTES.md](NOTES.md): it was worked out before they
were split apart, and many decisions answer each other across themes.

## Translation

The socle translates only what RimScent leaves in English in its own core:
`RimScent_FreshOxygen`, the one of its 35 thoughts that is not translated upstream.

Translations for the two official expansions — neither has a `Languages` folder — are carried by
the mods that extend them: the Incense Expansion by **Incense Plus**, the Perfume Expansion by
**Perfume Plus**.

The original English text is kept as a comment above each key. Labels are in English with French
injected on top, so the mod works in any language.

## `ModExtension_PawnScent`

**On a neighbouring pawn RimScent reads only `HediffDef`s**, never the race's `ThingDef`: an
animal, a creature, a pawn of a given faction could not smell of anything. This extension adds a
scent carried by a pawn def, gated on a stat threshold:

```xml
<li Class="RimScentExtended.ModExtension_PawnScent">
  <thought>MyScent</thought>
  <aboveStat>FilthRate</aboveStat>
  <aboveValue>4</aboveValue>
</li>
```

Put on an abstract parent such as `AnimalThingBase`, it covers every child — animal mods
included — without enumerating them.

The threshold is what makes it playable: a permanent smell on every creature would be a constant
punishment. The first client is **RimScent Extended: Farmyard Expansion**, which sets it at
`FilthRate >= 4`, the exact value tested by `RimWorld.Alert_AnimalFilth` — *an animal smells when
the game itself judges it dirty enough to warn the player*. A useful consequence:
[Housebroken](https://github.com/vbardales/Rimworld-Housebroken), which multiplies `FilthRate` by
how house-trained an animal is, silences the smell and the alert together — without either mod
having to know the other exists.

## Olfactory habituation

A constant smell stops being noticed, and comes back full force after an absence. Without that, a
colonist living near a barn is unhappy **forever**, with no way to get used to it — which is wrong
and, worse, punitive, since the game offers no answer.

Exposure rises on every scan pass, falls **twice as fast** when the smell goes away — you
un-habituate faster than you habituate — and the factor descends from 1 towards an adjustable
floor.

Habituation also enters the **dominance contest**, not just the final mood: a smell that has
become familiar has to be able to be displaced by a newer and yet weaker one. That is exactly what
happens when you come home no longer smelling your own house, but an unusual dish jumps out at
you.

**State is held in memory only**: nothing enters the save, in keeping with the rest of the mod.
Habituation therefore resets on load — acceptable for an effect that rebuilds itself in two hours
of play.

### The trade-off, and why it is adjustable

Habituation also affects **good** smells. Physiologically that is correct: you get used to your
perfume as much as to your manure. But it cuts into the bonus from incense and perfumes — that is,
precisely what they were built for.

Rather than decide for you, the mod exposes four settings:

| Setting | Default |
|---|---|
| Temperature affects smells | on |
| Olfactory habituation | on |
| Strength left once a smell is familiar | 50 % |
| Hours of continuous exposure to get there | 2.5 |
| Habituate to good smells too | on |

Turning the last one off preserves the full incense bonus while keeping bad smells fading.
Changing a setting clears the exposure counters, which would otherwise stay calibrated on the old
value for two hours of play.

## Temperature amplifies smells

Heat volatilises odorous compounds, cold locks them down. `ScentScan` therefore multiplies the
smell factor by an ambient temperature coefficient — and since a smell totals
`baseMoodEffect × smellFactor`, this amplifies or damps **the whole** smell, good or bad.

| Temperature | Factor | Carrion at −6 becomes |
|---|---|---|
| −10 °C and below | 0.40 | −2.4 |
| 0 °C | 0.60 | −3.6 |
| 20 °C | 1.00 | −6.0 |
| 30 °C | 1.24 | −7.4 |
| 45 °C and above | 1.60 | −9.6 |

The gameplay point: **refrigeration becomes an answer to smell**. A charnel house in a freezer
barely stinks; the same one in a heat wave becomes unbearable. It finally gives freezing bodies a
purpose beyond preserving meat, and it combines with the corpse section and Vanilla Events
Expanded's heat wave.

The factor applies **after** the early exit on the colonist's sense of smell: someone anosmic stays
anosmic, and the factor never drops below 0.40 — a smell that vanished completely would make the
thought flicker with every draught.

## `ModExtension_TerrainScent`

RimScent only reads the `thingGrid`: things sitting on cells. **Terrain is not a thing** — water,
marsh, sand and ice have no `ThingDef` — so none of what makes a place smell the way it does was
reachable. This extension goes on a `TerrainDef`, and `ScentScan` reads the terrain grid on the
same cells it already walks: an indexed lookup, with no extra traversal cost.

```xml
<li Class="RimScentExtended.ModExtension_TerrainScent">
  <thought>MyScent</thought>
  <aboveTemperature>18</aboveTemperature>
</li>
```

**The smell is counted per cell**, not once for the whole map like weather. That is deliberate:
three water cells at the edge of a stream do not smell like a swamp stretching to the horizon, and
the `ThoughtDef`'s `stackLimit` caps the total. The cell count therefore becomes a measure of "how
much of it is around you", for free.

`aboveTemperature` is optional and defaults to `NaN`, meaning "no condition". Below the threshold
**the cell does not count at all** — which is distinct from the global temperature factor above,
which damps or amplifies a smell already present. Marsh only smells in the heat: it is not a smell
damped by cold, it is a smell that does not exist.

Terrain is read **before** the things on the cell: a carpet laid over marsh does not make it go
away, and both smells enter the dominance contest.

The first client is **RimScent Extended: Weather Expansion** — fresh water, ocean, marsh, hot
springs, lava and forest floor.

## `ModExtension_ScentHediff`

The framework can only apply a `ThoughtDef`: a smell can only affect mood. This extension adds a
second hook, put on the same def alongside `ModExtension_Scent`, which also applies a `HediffDef` —
the first carries the mood, the second the effect.

```xml
<li Class="RimScentExtended.ModExtension_ScentHediff">
  <hediff>MyEffect</hediff>
</li>
```

Since `ScentScan` already walks the cells with every filter applied (fuel, power, switch, room,
line of sight), nothing is duplicated. `HediffComp_Disappears` acts as a timer, pushed back on
every pass for as long as the colonist stays exposed: **no data is added to the save**, and
removing the mod mid-game leaves nothing behind.

Two accepted choices:

- The effect does **not** go through the dominant-smell contest. Breathing two smokes means
  suffering both — only mood is arbitrated by RimScent.
- An anosmic colonist receives **nothing**, neither mood nor effect: zero sensitivity cuts the scan
  off upstream. That is consistent with the framework, but debatable for a physiological effect.
  The tipping point is the `smellFactor <= 0f` test in `ScentScan.Run`.

The first client of this extension is **RimScent Extended: Incense Plus Expansion**, which uses it
for six incenses with real effects — and which now also carries the Incense Expansion's rebalance
and translation.

## Verification

`scripts/Check-DefInjected.ps1` checks that every key points at a def, a type folder and a stage
(`handle`) actually present in the target mods. Thought stages are translated through the
normalised English label, not through an index:
`RimScent_SoothingIncenseScent.stages.soothing_incense.label`.
`Verse.TranslationHandleUtility.NormalizedHandle` replaces spaces with `_`, strips `.` and `-`, and
**preserves case** — hence `Berry_aroma` and not `berry_aroma`.

## C# fixes

Five bugs in RimScent's C# code, confirmed by decompilation, are fixed by a Harmony patch: an
unlit incense burner scenting the room anyway, a dangling `else` that removed all indoor
room-partitioning, trait handles never consulted, anosmia tripling a smell instead of cancelling
it, and a dereference before a null check. The details, with upstream line references, are in
`BUGS.md`.

The upstream mod is not forked: it stays installed and keeps receiving its updates.
`Source/Runtime/ScentScan.cs` replaces `UpdateScent` with a corrected version that follows the
original structure, so the comparison stays feasible.
