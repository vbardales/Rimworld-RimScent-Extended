# Bugs confirmés dans RimScent 1.6

Cinq défauts du code C# de RimScent, tous vérifiés par décompilation de
`Assembly-CSharp.dll` (RimWorld 1.6.4871) plutôt que de mémoire. Références de ligne
dans `1.6/Source/RimScentReworked/Pawn_ScentTracker.cs` du mod amont.

Les cinq sont corrigés par ce mod, via un patch Harmony sur `Pawn_ScentTracker` :
`Source/Runtime/ScentScan.cs` remplace `UpdateScent`, `Source/Patches/Patch_ScentTracker.cs`
garde `CompTick`. Le mod amont reste installé et à jour ; rien n'est forké.


---

## 1. Un brûle-encens éteint parfume quand même — ligne 155

```csharp
CompRefuelable refuelable = thing.TryGetComp<CompRefuelable>();
if (refuelable != null && !refuelable.HasFuel) continue;
CompPowerTrader power = thing.TryGetComp<CompPowerTrader>();
if (power != null && !power.PowerOn) continue;
```

Le scan teste le combustible et le courant, **jamais `CompFlickable`**.

Or `CompRefuelable.CompTick` ne consomme que si l'interrupteur est sur marche :

```csharp
if (!Props.consumeFuelOnlyWhenUsed && (flickComp == null || flickComp.SwitchIsOn) && ...)
    ConsumeFuel(ConsumptionRatePerTick);
```

Un brûle-encens éteint garde donc son plein indéfiniment, `HasFuel` reste vrai, et
l'odeur continue de s'appliquer. C'est `+6` d'humeur permanent et gratuit.

Que la lueur et la chaleur, elles, s'arrêtent bien montre l'intention : `CompGlower`
passe par `FlickUtility.WantsToBeOn`, et `Verse.CompHeatPusherPowered.ShouldPushHeatNow`
teste `FlickUtility.WantsToBeOn(parent)`, `powerComp.PowerOn` **et** `refuelableComp.HasFuel`.

**Correctif :** ajouter le test de l'interrupteur au même endroit.

```csharp
CompFlickable flick = thing.TryGetComp<CompFlickable>();
if (flick != null && !flick.SwitchIsOn) continue;
```

Les sources alimentées en électricité échappaient déjà au problème, `CompPowerTrader.PowerOn`
tombant à faux quand on coupe l'interrupteur. Seules les sources **à combustible et
allumables** étaient touchées — c'est-à-dire exactement les deux brûle-encens.

---

## 2. `else` pendant : aucun cloisonnement par pièce à l'intérieur — lignes 126-128

```csharp
if (pawnOutdoors)
    if (!cellOutdoors) continue;
else if (cellRoom != pawnRoom)
    continue;
```

L'indentation ment. En C#, `else` se rattache au `if` **le plus proche non apparié**,
donc à l'interne :

```csharp
if (pawnOutdoors) {
    if (!cellOutdoors) continue;
    else if (cellRoom != pawnRoom) continue;
}
```

Quand le pion est **à l'intérieur**, plus aucun filtrage de cellule n'a lieu : il sent
tout ce qui est dans le rayon et en ligne de vue, y compris une autre pièce par une
porte ouverte, ou l'extérieur. La restriction « même pièce » ne s'applique jamais.

**Correctif :** accolades explicites, et la branche intérieure qui exige la même pièce.

---

## 3. Dysosmie et anosmie par odeur déclenchées pour tout le monde — lignes 244 et 261

```csharp
if (ext.dysosmicTraitDegrees != null)
    return true;
```

Le champ n'est pas comparé aux traits du pion : sa seule **présence dans le def** suffit
à renvoyer `true`. Même chose pour `anosmicTraitDegrees` ligne 261. Le premier scent def
qui déclare `dysosmicTraitDegrees` inverse donc l'humeur de la colonie entière.

Aucun def du mod amont n'utilise ces deux champs aujourd'hui — le bug est dormant, mais
il piège le premier qui suit la documentation de l'API.

**Correctif :** parcourir la liste et tester `TraitRequirement.HasTrait(pawn)`, comme les
branches `dysosmicTraits` / `anosmicTraits` juste au-dessus le font pour les noms de traits.

---

## 4. L'anosmie triple l'odeur au lieu de l'annuler — ligne 291

```csharp
float offset = baseMood * (smellFactor - 1f);
if (dysosmic) offset -= baseMood * 2f;
if (anosmic)  offset += baseMood * 2f;
mem.moodOffset = Mathf.RoundToInt(offset);
```

`RimWorld.Thought_Memory.MoodOffset()` vaut `baseMoodEffect * moodPowerFactor + moodOffset`.
Le total est donc `baseMood + offset` :

| Cas | `offset` | Total | Attendu |
|---|---|---|---|
| normal (`smellFactor` = 1) | `0` | `baseMood` | `baseMood` |
| odorat fin (`smellFactor` = 2) | `baseMood` | `2 × baseMood` | `2 × baseMood` |
| dysosmie | `−2 × baseMood` | `−baseMood` | inversé |
| **anosmie** | `+2 × baseMood` | **`3 × baseMood`** | **`0`** |

Le signe est inversé. Concrètement, un pion `VTE_Desensitized` — déclaré `anosmicTraits`
sur le sang dans `Core_Filth_Patch.xml` — prend **−6** au lieu de **−2** près du sang,
alors que le trait est censé le rendre insensible.

Le trait `RimScent_Anosmic`, lui, ne passe pas par là : il annule via un `statOffsets`
de `-999` sur `RimScent_SmellSensitivity`, ce qui met `smellFactor` à 0 et provoque une
sortie anticipée. Seule l'anosmie **par odeur** est touchée.

**Correctif :** ne pas ajouter la mémoire du tout quand `anosmic` est vrai, plutôt que
de bricoler un offset compensatoire.

---

## 5. Déréférencement avant test de nullité — ligne 50

```csharp
Pawn pawn = Pawn;                 // parent as Pawn
if (pawn.IsAnimal) return;
if (pawn == null || !pawn.Spawned || pawn.needs?.mood == null) return;
```

`pawn.IsAnimal` s'exécute avant le test `pawn == null`. Le comp n'étant posé que sur
`ThingDef` `Human` par `PawnScentPatch.xml`, le cas ne se produit pas aujourd'hui ;
il suffit qu'un mod ajoute le comp ailleurs pour obtenir une `NullReferenceException`
à chaque tick.

**Correctif :** intervertir les deux lignes.
