# Technical journal

The design decisions taken while building RimScent Extended and its seven expansions. They were
taken together, before the split into separate mods, and many of them answer each other across
themes — hence one document rather than a share of it in each repository.

Each section says where its content now lives.

| Section | Mod |
|---|---|
| Corpses | Decay Expansion |
| Industry and fermentation | Industry Expansion |
| Chemfuel and torches | Industry Expansion |
| Knick-knacks | Everyday Life Expansion |
| Vanilla filth | Industry Expansion (scattered documents: Everyday Life) |
| Medical Supplements and Alpha Crafts | Industry / Everyday Life |
| Flowers and decorative plants | Everyday Life Expansion |
| Coffee and cooking | Everyday Life Expansion |
| Social Supplements, diseases, Epochs | Perfume Plus / Decay / Industry |
| Vanilla Events Expanded | Weather Expansion |
| The Perfumes mod (Romyashi) | Perfume Plus Expansion |

What stayed in the socle — habituation, temperature, the two `ModExtension`s and the five C#
fixes — is documented in the [README](README.md).

---

## Corpses

RimScent gives a scent to `Filth_CorpseBile`, the puddle — **but not to the corpse**. In a mod
about smell, that was the most visible omission.

It cannot be fixed in XML: corpse defs (`Corpse_Human` and friends) are **implicit** defs,
generated at runtime, after `PatchOperation`s have run. No xpath can target them. So it is
`ScentScan` that reads `RottableUtility.GetRotStage()` and picks among three thoughts:

| State | Smell | Effect |
|---|---|---|
| `Fresh` | smell of death | −2, stack 3 |
| `Rotting` | carrion stench | −6, stack 3 |
| `Dessicated` | dried-out remains | −1, stack 2 |

The values are strong on purpose: in default mode RimScent keeps only the **dominant** smell, so
carrion does not add to the rest — it crushes it.

Three details that fall into place for free:

- **A buried body does not smell.** It is contained in the grave, therefore absent from the
  `thingGrid` the scan walks. Intended behaviour, obtained for nothing.
- **A mechanoid hulk never rots.** `GetRotStage()` returns `Fresh` by default when there is no
  `CompRottable`, so it stays at fresh death smell.
- **Psychopaths, bloodlusters and cannibals are not bothered**, through `nullifyingTraits` — a
  vanilla `ThoughtDef` field, therefore usable despite being unable to put a `ModExtension_Scent`
  on an implicit def. It is exactly the trio the base game uses for its own death thoughts
  (`Thoughts_Memory_Death.xml`): follow the precedent rather than invent a list.

## Industry and fermentation

Three gaps in the base game, spotted by contrast with Medieval Overhaul's inventory — from which
**nothing is taken**: it has no licence, and only its list of smelly buildings served as a
checklist.

| Target | Smell | Trigger |
|---|---|---|
| electric crematorium | cremation smoke, −3 | power **and** switch |
| electric smelter | hot metal, −2 | power **and** switch |
| fermenting barrel, brewery | fermenting wort, +1 | none — permanent smell |

The crematorium and the smelter both carry a `CompProperties_Flickable` on top of their power
supply: switched off, they smell of nothing. **That is precisely the test RimScent forgot**, and
that our first fix added — without it, an unlit crematorium would have stunk permanently.

The barrel and the brewery have no power at all: the smell is permanent. Defensible — a barrel
smells of yeast even empty — but it is a choice, not a necessity. Odyssey's ancient brewery is
excluded: it is a decorative ruin.

Cremation smoke reuses the corpse-smell exemption (psychopath, bloodluster, cannibal). Wort, for
its part, does nothing for a teetotaller (`DrugDesire` −1).

## Chemfuel and torches

**Chemfuel — no new thought.** `RimScent_FuelScent` exists upstream ("fuel fumes", −2) and was
only wired to `Filth_Fuel` and the generators. We extend it to the biofuel refinery, the infinite
chemreactor and the two chemfuel tanks. All gated: the first two by power plus switch, the tanks
by `CompRefuelable` — the stored chemfuel *being* their fuel, **an empty tank smells of nothing**.

**Torches — a damped variant.** `RimScent_CampfireScent` is +3, with a description about
nostalgia and hearths: right for a fire you sit around, far too much for a wall torch you place
by the dozen along a corridor. At +3 and stacking, lighting a base would have become the best
mood source in the game.

Hence `RimScentExtended_Scent_Torch` at **+1, stack 2** — brazier, wall torch, darklight torch,
darklight mushroom torch, darklight brazier, sanguophage gathering torch. The campfire and the
stone hearth keep their +3: those are fires, not lighting.

Five of the six burn `WoodLog`, the mushroom torch burns `RawFungus` — hence a description
deliberately neutral about the fuel. All have a `CompRefuelable`: a torch that is out or short of
wood smells of nothing.

## Knick-knacks: Knick Knacks, Colonists' Deco, Tabletop Trove

| Target | Smell |
|---|---|
| Knick Knacks — spray bottle (`SEX_Scents`) | air freshener, +2 |
| Knick Knacks — vase | green plant, +1 |
| Knick Knacks — loose papers | old paper, +1 |
| Colonists' Deco — bedside book | old paper, +1 |
| Colonists' Deco — boar's head, deer head | tanned hide, −1 |
| Tabletop Trove — rulebooks, GM screen, character sheets, game boxes, card decks | old paper, +1 |

**All of these thoughts are at `stackLimit` 1**, and that is the design point. These are not
buildings you place once: Knick Knacks provides a "decorating" `JobDef` and `JoyGiver`s that
furnish bedrooms and dining rooms on their own. They proliferate. At `stackLimit` 4, a room
crowded with knick-knacks would have become the best mood source in the game for three bits of
wood. A room smells of air freshener — not six times of air freshener.

That is also why the vase does **not** reuse `RimScent_FloweryScent`: its `stackLimit` of 4 would
be too generous here, and its texture shows foliage, not flowers.

What deliberately has no smell: boxes, napkin rings, photo frames, posters, dreamcatchers, brass
shapes, paper balls, archotech trinkets, and varnished wooden game boards — only paper and
cardboard smell.

## Vanilla filth

RimScent covers **12 of the 42 filth types** in the base game and the DLCs. This patch picks up
22 more, the overwhelming majority by **reusing upstream thoughts** — they exist, they are
translated, and the missing filth is often the twin of one already covered.

| Filth | Thought |
|---|---|
| firefoam | `RimScent_FirefoamScent` — **orphaned upstream** |
| blast mark | `RimScent_ExplosionScent` — **orphaned upstream** |
| dried blood, dark blood and its smear, revenant pool and smear | `RimScent_BloodScent` |
| flammable bile | `RimScent_BileScent` |
| noteworthy gray flesh | `RimScent_GrayFleshScent` |
| twisted flesh, metalhorror debris | `RimScent_TwistedFleshScent` |
| spent acid | `RimScent_ToxicScent` |
| chemfuel stain | `RimScent_FuelScent` |
| volcanic ash | `RimScent_AshScent` |
| building and rock rubble, sand, disturbed dirt | `RimScent_DirtScent` |
| scattered documents | `RimScentExtended_Scent_OldPaper` (shared with the knick-knacks) |
| mouldy uniform | **mould**, −2 — new |
| slime, pod slime | **slime**, −1 — new |

**Two of RimScent's thoughts were attached to nothing.** `RimScent_FirefoamScent` ("flat chemical
foam") and `RimScent_ExplosionScent` ("sulfur and ozone") are defined upstream and never used —
yet `Filth_FireFoam` and `Filth_BlastMark` exist and match their descriptions exactly. The same
situation as the Epochs - Incense thoughts.

Deliberately left odourless: cut hair, water, shattered ice, floor drawings, cold mechanical
debris. And two cases set aside for want of an honest answer — **amniotic fluid** and **gestation
fluid**: giving them the smell of blood would be a contradiction (its description speaks of "the
smell of violence"), and inventing a childbirth smell for two defs seemed more dubious than
abstaining.

## Medical Supplements and Alpha Crafts

| Target | Smell |
|---|---|
| smelling salts capsule (item **and** hediff) | ammonia, −2 |
| chemical mixer, stimulant lab | pharmacy smell, −1 |
| Alpha Crafts perfume (bottle **and** worn hediff) | worn perfume, +3 |
| scented candle | scented candle, +2 |
| soap | soap, +2 |
| essence, infuser | concentrated essence, +2 |
| vinegar, pickles, pickled eggs | vinegar and brine, −1 |
| artisan fermenter | **reuses** `RimScentExtended_Scent_Fermenting` (the vanilla barrel's) |

Alpha Crafts is the smelliest mod on the list: it has dedicated files for perfume, essences,
scented candles, soap, vinegar and pickles. Butter, mayonnaise, flour, yoghurt and popcorn are
excluded — they barely smell, and above all they fill the stockpiles.

Two design details:

- **`RimScentExtended_Scent_WornScent` moved to `Core`.** It lived in the Social Supplements
  section until Alpha Crafts needed it too — and one section cannot reference a `ThoughtDef`
  declared in another, since that one only loads if *its* mod is active. Any shared thought has to
  live in `Core`.
- Alpha Crafts' essence takes the name of its ingredient
  (`AlphaCrafts.CompProperties_LabelByIngredients`): it can smell of rose or of garlic. Its
  description therefore speaks of the **concentration**, not of a specific scent.

## Flowers and decorative plants

RimScent gives `RimScent_FloweryScent` to three plants by name: `Plant_Rose`, `Plant_Daylily`,
`Plant_Dandelion`. On checking, **those three are exactly, and only, the vanilla plants carrying
`plant/purpose = "Beauty"`**. The upstream mod's implicit criterion is therefore that one: the
patch makes it explicit, and every decorative plant from every mod inherits it.

No new `ThoughtDef`: we reuse the upstream one, already translated.

Across this mod list, **17 mods** contain decorative plants. Unique counts on six of them:

| Mod | Plants |
|---|---|
| Houseplants Remastered | 14 |
| Spidercamp's Decorative Plants | 12 |
| Vanilla Plants Expanded - More Plants | 11 |
| Vanilla Plants Expanded - Succulents | 10 |
| Flowers (Continued) | 8 |
| Glowmoss | 7 |

That is **62 plants against 3 in vanilla**, without enumerating a single `defName`. On top of
those come VPE Flowers, VPE Mushrooms, VIE Memes and Structures, VV New Harvest and the rest.

The predicate excludes defs that already carry a `ModExtension_Scent` — which automatically rules
out the three vanilla plants and Overflowing Flowers, patched by RimScent before us — as well as
abstract defs, so as not to add the extension to the parent and then to the child inheriting from
it. Both XPath predicates were tested against a real document before shipping.


## Coffee and cooking

RimScent scents **no cooking building, not even vanilla ones**: its building patch only covers the
campfire, fire and the two generators. A kitchen in full service smelled of nothing.

| Target | Smell | Mod |
|---|---|---|
| electric stove, fuelled stove | cooking smell, +2 | vanilla |
| electric cauldron, grill, deep fryer | cooking smell, +2 | Vanilla Cooking Expanded |
| bakery ovens (wood and electric) | fresh bread, +3 | VCE Bakery |
| espresso machine | coffee aroma, +3 | VBE Coffees and Teas |
| 9 coffees | coffee aroma, +3 | same |
| 8 teas | brewed tea, +2 | same |

**The trigger is free.** All eight buildings carry either a `CompPowerTrader` or a
`CompRefuelable` — checked one by one — which RimScent's scan already tests, and the switch as
well since our fix. An unpowered kitchen, out of wood or switched off, therefore smells of
nothing, without one more line of code.

Deliberately left out: canning machine, condiment table and cheese press, which cook nothing.

The patches use the **disjoint-predicate pattern** (`… and modExtensions` /
`… and not(modExtensions)`) rather than `match`/`nomatch`. With a list of defs grouped by `or`, a
classic `match`/`nomatch` would only patch those that already have `modExtensions`, or only those
that do not — never both. It is also what makes it safe to include the drinks VBE only loads
alongside Vanilla Cooking Expanded: an `or` that finds only some of its defs simply patches the
ones that exist.

Checked against the real defs: 25 targets, `with modExtensions` + `without` = the total for each
of the six groups, so coverage is complete.

## Social Supplements, diseases, Epochs

| Target | Smell | Note |
|---|---|---|
| 3 worn "Scenters" (hediffs) | worn perfume, +3 | same shape as Perfumes: the mod has a whole perfumery section without a single `ModExtension_Scent` |
| 2 vape hediffs | vapour cloud, −1 | the smell lasts as long as the effect, like `SmokeleafHigh` upstream |
| mouthwash, mint tea, mint plant and leaves | mint, +2 | |
| chillies, hot sauce | pepper in the air, −1 | |
| polyflower, petals, juice | **reuses** `RimScent_FloweryScent` | it does **not** carry `purpose="Beauty"` — checked — so the flower patch was not catching it |
| 10 germ filth types | sickroom air, −2 | germs do not smell, a sickroom does |
| 2 Epochs incense burners | **their own thoughts** | see below |

Two Epochs / Stoneborn sections come on top:

| Target | Smell |
|---|---|
| tallow torches, wall torch, raw tallow | burning tallow, −1 |
| tallow hearth | **cooking smell** — it is a cooking station (`DV_DoBillsCookTallowHearth`), and the meal dominates the fuel |
| grill, dwarven oven, portable cauldron, quantum microgenerator | cooking smell |
| meat drier | drying meat, +1 |
| insectiary | insectiary, −2 — *moved to [Farmyard Expansion](https://github.com/vbardales/Rimworld-RimScent-Extended-Farmyard-Expansion)*, with the bees |

Tallow torches have no `CompRefuelable` but a `CompProperties_DestroyAfterDelay`: they destroy
themselves when they burn out, so **a torch that exists is a torch that is lit** — the gate is
automatic. The drier and the insectiary, on the other hand, have no power supply and will smell
permanently: correct, for what they are.

**Epochs - Incense defines two `ThoughtDef`s that nothing applies.** `IncenseThought` and
`StandingIncenseThought`, both "pleasant smell" at +2, are cited nowhere outside their own file —
in no mod on the Workshop — and the mod ships no assembly. Its incense burners are therefore
purely decorative, while their description promises "a pleasant floral aroma". We wire them into
RimScent by reusing **the author's own thoughts** rather than creating ours: it is what they
intended, and no double-counting is possible since nothing else applies them.

Two traps met along the way:

- **Six of the ten germ filth types do not always exist.** Communicable Diseases only creates them
  through a `PatchOperationFindMod` gated on *Diseases Overhauled*, absent from this mod list. Only
  four will therefore actually be patched here. The disjoint-predicate pattern tolerates that
  without error.
- **Load order matters** for this particular case: patch operations apply in mod order, so
  `About.xml` now declares in `loadAfter` **every** mod this one patches, not just the RimScent
  family.

## Vanilla Events Expanded

VEE adds 5 weathers and 10 conditions, none of which smelled of anything. RimScent reads
conditions and weather **at map scale**, outside the cell loop: each smell here hits the whole
colony at once, hence the restraint on the values.

| Event | Smell | Source |
|---|---|---|
| drought | parched air, −2 | new |
| global heat wave + *swelter* and *inferno* weathers | stifling air, −2 | new |
| psychic bloom | alien bloom, +2 | new |
| orbital wreck fall | sulphur and ozone, −2 | **reuses** `RimScent_ExplosionScent` |
| psychic rain | petrichor, +3 | **reuses** `RimScent_PetrichorScent` |

**What deliberately has no smell**: *whiteout*, *long night*, *psychic stimulation*, *psychic
overdrive*, *psychic hum*. Cold and psychic phenomena have no smell, and inventing one for them
would be noise.

Three points of detail:

- *Inferno* and *swelter* really are **heat**, not fires — checked in their defs (`rainRate 0`,
  `snowRate 0`, no fire component). Hence stifling air rather than `RimScent_FireScent`.
- For psychic rain we patch the **weather** and not the identically named condition: both exist,
  and since `RimScent_PetrichorScent` has a `stackLimit` of 4, patching both would count the smell
  twice. It is the weather that actually falls (`rainRate 1`, sound `Ambient_Rain`).
- Four of the targets already carry `modExtensions` of their own
  (`VEF.Maps.MapConditionExtension`): the *match* branch adds to them instead of overwriting.

## The Perfumes mod (Romyashi)

[Perfumes](https://steamcommunity.com/sharedfiles/filedetails/?id=3013711969) gives the wearer a
mood bonus and stat bonuses, but **not one `ModExtension_Scent` in the whole mod**: nobody around
them could smell anything. That is the gap RimScent's perfume expansion fills for its own
perfumes.

| Perfume | Effect on the wearer (original mod) | Smell others perceive |
|---|---|---|
| floral | beauty, negotiation, trade price | +3 |
| herbal | taming and training +15 % | +2 |
| hunting | hunting stealth +50 % | **−1** — it is made of hay, and exists so as *not* to smell human |
| ancient | beauty +3, social and trade +30 % | +5 |
| anima | psychic sensitivity | +3 (only with Anima Expansion) |
| aromafleur petals | — | +2, stack 4 |

No double-counting: RimScent only reads the hediffs of **neighbouring** pawns
(`otherPawn != pawn`), so the wearer does not smell themselves and keeps the original mod's bonus.
The standing flower is already covered by the flower patch — it carries `purpose="Beauty"`; only
the harvested petals, which are an item, needed a patch.

Two traps handled:

- The anima perfume carries a `MayRequire` on Anima Expansion, absent from this mod list. The patch
  is wrapped in a nested conditional: if the def does not exist, nothing happens and no error is
  raised.
- Since its `ThoughtDef` also carries `MayRequire`, **its translation is isolated** in
  `RomyPerfumesAnima/`, gated on the same mod — a key aimed at a missing def is a load error.
  `Check-DefInjected.ps1` now flags that case.
