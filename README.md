# RimScent Extended

Le socle de la famille RimScent Extended : cinq correctifs au moteur de
[RimScent](https://steamcommunity.com/sharedfiles/filedetails/?id=3645569466)
(reo, ocarina0001), deux mécaniques qui lui manquaient, et deux points d'extension qu'il
n'avait pas. RimWorld 1.6.

**Seul, il n'ajoute presque aucun contenu.** C'est ce sur quoi les sept extensions sont
construites.

## Les sept extensions

| Mod | Thème |
|---|---|
| [Incense Plus](https://github.com/vbardales/Rimworld-rimscent-extended-incense-plus-expansion) | six encens à effet, et l'équilibrage de l'Incense Expansion |
| [Perfume Plus](https://github.com/vbardales/Rimworld-RimScent-Extended-Perfume-Plus-Expansion) | parfums portés, vapotage, menthe |
| [Everyday Life](https://github.com/vbardales/Rimworld-RimScent-Extended-Everyday-Life-Expansion) | cuisine, café, pain, fleurs, bibelots |
| [Decay](https://github.com/vbardales/Rimworld-RimScent-Extended-Decay-Expansion) | cadavres gradués, nourriture avariée, chambre de malade |
| [Farmyard](https://github.com/vbardales/Rimworld-RimScent-Extended-Farmyard-Expansion) | crottes, bétail, ruches, insectarium |
| Industry | crématorium, fonderie, suif, torches, chimiburant, saletés |
| [Weather](https://github.com/vbardales/Rimworld-RimScent-Extended-Weather-Expansion) | sécheresse, canicule, floraison psychique |

Le raisonnement de conception derrière chacune est dans [NOTES.md](NOTES.md) : il a été mené
avant la séparation, et beaucoup de décisions se répondent d'un thème à l'autre.

## Traduction

Le socle ne traduit que ce que RimScent laisse en anglais dans son propre cœur :
`RimScent_FreshOxygen`, la seule de ses 35 pensées à ne pas être traduite en amont.

Les traductions des deux extensions officielles — ni l'une ni l'autre n'a de dossier
`Languages` — sont portées par les mods qui les étendent : l'Incense Expansion par
**Incense Plus**, la Perfume Expansion par **Perfume Plus**.

Le texte anglais d'origine est repris en commentaire au-dessus de chaque clé. Les libellés
sont en anglais et le français est injecté par-dessus : le mod fonctionne dans n'importe
quelle langue.

## `ModExtension_PawnScent`

**RimScent ne lit sur un pion voisin que ses `HediffDef`**, jamais son `ThingDef` de race :
un animal, une créature, un pion d'une faction donnée ne pouvaient pas sentir. Cette
extension ajoute une odeur portée par un def de pion, conditionnée à un seuil de stat :

```xml
<li Class="RimScentExtended.ModExtension_PawnScent">
  <thought>MonOdeur</thought>
  <aboveStat>FilthRate</aboveStat>
  <aboveValue>4</aboveValue>
</li>
```

Posée sur un parent abstrait comme `AnimalThingBase`, elle couvre tous les enfants — donc
les mods animaliers — sans les énumérer.

Le seuil est ce qui rend la chose jouable : une odeur permanente sur toute créature serait
une punition constante. Le premier client est **RimScent Extended: Farmyard Expansion**,
qui la cale sur `FilthRate >= 4`, la valeur exacte testée par `RimWorld.Alert_AnimalFilth` —
*un animal sent quand le jeu lui-même le juge assez sale pour alerter le joueur*.
Conséquence utile : [Housebroken](../Housebroken/README.md), qui multiplie `FilthRate` par
la propreté de l'animal, éteint l'odeur en même temps que l'alerte — sans qu'aucun des deux
mods ait à connaître l'autre.

## L'accoutumance olfactive

Une odeur constante finit par ne plus se remarquer, et revient de plein fouet après une
absence. Sans cela, un colon qui vit près d'une étable est malheureux **pour toujours**,
sans aucun moyen de s'y faire — ce qui est faux et surtout punitif, le jeu n'offrant aucune
réponse.

L'exposition monte à chaque passage du scan, redescend **deux fois plus vite** quand l'odeur
disparaît — on se déshabitue plus vite qu'on ne s'habitue — et le facteur descend de 1 vers
un plancher réglable.

L'accoutumance entre aussi dans le **concours de dominance**, et pas seulement dans l'humeur
finale : une odeur devenue familière doit pouvoir se faire supplanter par une odeur nouvelle
et pourtant plus faible. C'est exactement ce qui se passe quand on rentre chez soi sans plus
sentir sa maison, mais qu'un plat inhabituel saute au nez.

**État en mémoire vive uniquement** : rien n'entre dans la sauvegarde, conformément au reste
du mod. L'accoutumance se réinitialise donc au chargement — acceptable pour un effet qui se
reconstruit en deux heures de jeu.

### Le compromis, et pourquoi il est réglable

L'accoutumance touche aussi les **bonnes** odeurs. Physiologiquement c'est juste : on
s'habitue à son parfum comme à son fumier. Mais cela réduit d'autant le bonus de l'encens et
des parfums — c'est-à-dire précisément ce pour quoi on les a construits.

Plutôt que de trancher, le mod expose quatre réglages :

| Réglage | Défaut |
|---|---|
| La température agit sur les odeurs | activé |
| Accoutumance olfactive | activé |
| Force restante une fois l'odeur familière | 50 % |
| Heures d'exposition continue pour y arriver | 2,5 |
| S'habituer aussi aux bonnes odeurs | activé |

Désactiver le dernier préserve tout le bonus de l'encens tout en gardant l'estompement des
mauvaises odeurs. Changer un réglage vide les compteurs d'exposition, sans quoi ils
resteraient calibrés sur l'ancienne valeur pendant deux heures de jeu.

## La température amplifie les odeurs

La chaleur volatilise les composés odorants, le froid les fige. `ScentScan` multiplie donc
le facteur d'odorat par un coefficient de température ambiante — et comme le total d'une
odeur vaut `baseMoodEffect × smellFactor`, cela amplifie ou atténue **toute** l'odeur, bonne
comme mauvaise.

| Température | Facteur | Une charogne à −6 devient |
|---|---|---|
| −10 °C et moins | 0,40 | −2,4 |
| 0 °C | 0,60 | −3,6 |
| 20 °C | 1,00 | −6,0 |
| 30 °C | 1,24 | −7,4 |
| 45 °C et plus | 1,60 | −9,6 |

L'intérêt de jeu : **la réfrigération devient une réponse olfactive**. Un charnier en chambre
froide ne pue presque plus ; le même sous une canicule devient intenable. Ça donne enfin un
sens à congeler les corps au-delà de la conservation de la viande, et ça se combine avec le
volet cadavres et la canicule de Vanilla Events Expanded.

Le facteur s'applique **après** la sortie anticipée sur l'odorat du colon : un anosmique le
reste, et le facteur ne descend jamais sous 0,40 — une odeur qui disparaîtrait complètement
ferait clignoter la pensée au gré des courants d'air.

## `ModExtension_TerrainScent`

RimScent ne lit que le `thingGrid` : des objets posés sur des cases. **Le terrain n'est pas
un objet** — l'eau, la vase, le sable et la glace n'ont pas de `ThingDef` — donc rien de ce
qui fait l'odeur d'un lieu n'était accessible. Cette extension se pose sur un `TerrainDef`,
et `ScentScan` lit la grille de terrain sur les mêmes cases qu'il parcourt déjà : un accès
indexé, aucun coût de parcours supplémentaire.

```xml
<li Class="RimScentExtended.ModExtension_TerrainScent">
  <thought>MonOdeur</thought>
  <aboveTemperature>18</aboveTemperature>
</li>
```

**L'odeur est comptée par case**, et non une fois pour toutes comme la météo. C'est voulu :
trois cases d'eau au bord d'un ruisseau ne sentent pas comme un marécage à perte de vue, et
le `stackLimit` de la `ThoughtDef` plafonne le total. Le nombre de cases devient donc une
mesure de « combien il y en a autour de toi », gratuitement.

`aboveTemperature` est optionnel et vaut `NaN` par défaut, ce qui signifie « aucune
condition ». Sous le seuil, **la case ne compte pas du tout** — c'est distinct du facteur de
température global ci-dessus, qui atténue ou amplifie une odeur déjà présente. La vase ne
sent qu'à la chaleur : ce n'est pas une odeur atténuée par le froid, c'est une odeur qui
n'existe pas.

Le terrain est lu **avant** les objets de la case : un tapis posé sur de la vase ne la fait
pas disparaître, les deux odeurs entrent au concours de dominance.

Le premier client est **RimScent Extended: Weather Expansion** — eau douce, océan, vase,
sources chaudes, lave et sol forestier.

## `ModExtension_ScentHediff`

Le cadre ne sait appliquer qu'une `ThoughtDef` : une odeur ne peut faire que de l'humeur.
Cette extension ajoute un second point d'accroche, à poser sur le même def à côté de
`ModExtension_Scent`, qui pose en plus un `HediffDef` — la première porte l'humeur, la
seconde l'effet.

```xml
<li Class="RimScentExtended.ModExtension_ScentHediff">
  <hediff>MonEffet</hediff>
</li>
```

`ScentScan` parcourant déjà les cellules avec tous les filtres (combustible, courant,
interrupteur, pièce, ligne de vue), rien n'est dupliqué. `HediffComp_Disappears` sert de
minuterie, repoussée à chaque passage tant que le colon reste exposé : **aucune donnée
n'est ajoutée à la sauvegarde**, et retirer le mod en cours de partie ne laisse rien
derrière.

Deux choix assumés :

- L'effet ne passe **pas** par le concours d'odeur dominante. Respirer deux fumées, c'est
  subir les deux — seule l'humeur est arbitrée par RimScent.
- Un colon anosmique ne reçoit **rien**, ni humeur ni effet : la sensibilité nulle coupe
  le scan en amont. C'est cohérent avec le cadre, mais discutable pour un effet
  physiologique. Le point de bascule est le test `smellFactor <= 0f` dans `ScentScan.Run`.

Le premier client de cette extension est **RimScent Extended: Incense Plus Expansion**,
qui s'en sert pour six encens à effet — et qui porte désormais, avec eux, l'équilibrage
et la traduction de l'Incense Expansion.

## Vérification

`scripts/Check-DefInjected.ps1` contrôle que chaque clé pointe sur un def, un dossier
de type et une étape (`handle`) réellement présents dans les mods cibles. Les étapes
de pensée se traduisent par le libellé anglais normalisé, pas par un index :
`RimScent_SoothingIncenseScent.stages.soothing_incense.label`. `Verse.TranslationHandleUtility.NormalizedHandle`
remplace les espaces par `_`, supprime `.` et `-`, et **conserve la casse** — d'où
`Berry_aroma` et non `berry_aroma`.

## Correctifs C#

Cinq bugs du code C# de RimScent, confirmés par décompilation, sont corrigés par un
patch Harmony : brûle-encens éteint qui parfume quand même, `else` pendant qui
supprimait tout cloisonnement par pièce à l'intérieur, handles de traits jamais
consultés, anosmie qui triplait l'odeur au lieu de l'annuler, déréférencement avant
test de nullité. Le détail, avec les références de ligne en amont, est dans `BUGS.md`.

Le mod amont n'est pas forké : il reste installé et continue de recevoir ses mises
à jour. `Source/Runtime/ScentScan.cs` remplace `UpdateScent` par une version corrigée
qui suit la structure d'origine, pour que la comparaison reste faisable.
