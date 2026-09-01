# Journal technique

Les décisions de conception prises en construisant RimScent Extended et ses sept extensions.
Elles ont été prises ensemble, avant la séparation en mods distincts, et beaucoup se
répondent d'un thème à l'autre — d'où un seul document plutôt qu'une part dans chaque dépôt.

Chaque section indique où son contenu vit désormais.

| Section | Mod |
|---|---|
| Cadavres | Decay Expansion |
| Industrie et fermentation | Industry Expansion |
| Chimiburant et torches | Industry Expansion |
| Bibelots | Everyday Life Expansion |
| Saletés vanilla | Industry Expansion (les documents éparpillés : Everyday Life) |
| Medical Supplements et Alpha Crafts | Industry / Everyday Life |
| Fleurs et plantes décoratives | Everyday Life Expansion |
| Café et cuisine | Everyday Life Expansion |
| Social Supplements, maladies, Epochs | Perfume Plus / Decay / Industry |
| Vanilla Events Expanded | Weather Expansion |
| Mod Perfumes (Romyashi) | Perfume Plus Expansion |

Ce qui est resté dans le socle — l'accoutumance, la température, les deux `ModExtension` et
les cinq correctifs C# — est documenté dans le [README](README.md).

---

## Cadavres

RimScent parfume `Filth_CorpseBile`, la flaque — **mais pas le cadavre**. Dans un mod dont
le sujet est l'odorat, c'était l'omission la plus visible.

Elle ne se répare pas en XML : les defs de cadavres (`Corpse_Human` et consorts) sont des
defs **implicites**, générées à l'exécution, après le passage des `PatchOperation`. Aucun
xpath ne peut les cibler. C'est donc `ScentScan` qui lit `RottableUtility.GetRotStage()` et
choisit parmi trois pensées :

| État | Odeur | Effet |
|---|---|---|
| `Fresh` | odeur de mort | −2, cumul 3 |
| `Rotting` | puanteur de charogne | −6, cumul 3 |
| `Dessicated` | restes desséchés | −1, cumul 2 |

Les valeurs sont fortes à dessein : en mode par défaut RimScent ne retient que l'odeur
**dominante**, donc une charogne ne s'ajoute pas au reste — elle l'écrase.

Trois détails qui tombent juste sans effort :

- **Un corps enterré ne sent pas.** Il est contenu dans la tombe, donc absent du `thingGrid`
  que le scan parcourt. Comportement voulu, obtenu gratuitement.
- **Une carcasse de mécanoïde ne pourrit jamais.** `GetRotStage()` renvoie `Fresh` par défaut
  quand il n'y a pas de `CompRottable`, donc elle en reste à l'odeur de mort fraîche.
- **Psychopathes, sanguinaires et cannibales ne sont pas incommodés**, via `nullifyingTraits`
  — un champ vanilla de `ThoughtDef`, donc utilisable malgré l'impossibilité de poser une
  `ModExtension_Scent` sur un def implicite. C'est exactement le trio que le jeu de base
  utilise pour ses propres pensées de mort (`Thoughts_Memory_Death.xml`) : on suit le
  précédent plutôt que d'inventer sa liste.

## Industrie et fermentation

Trois trous du jeu de base, repérés par contraste avec l'inventaire de Medieval Overhaul —
dont **rien n'est repris** : il n'a pas de licence, seule sa liste de bâtiments odorants a
servi de checklist.

| Cible | Odeur | Déclencheur |
|---|---|---|
| crématorium électrique | fumée de crémation, −3 | courant **et** interrupteur |
| fonderie électrique | métal chaud, −2 | courant **et** interrupteur |
| fût de fermentation, brasserie | moût en fermentation, +1 | aucun — odeur permanente |

Le crématorium et la fonderie portent tous deux un `CompProperties_Flickable` en plus de
leur alimentation : éteints, ils ne sentent rien. **C'est précisément le test que RimScent
oubliait**, et que notre premier correctif a ajouté — sans lui, un crématorium éteint aurait
empesté en permanence.

Le fût et la brasserie n'ont aucune alimentation : l'odeur est permanente. Défendable — un
fût sent la levure même vide — mais c'est un choix, pas une fatalité. La brasserie ancienne
d'Odyssey est écartée : c'est une ruine décorative.

La fumée de crémation reprend l'exemption des odeurs de cadavre (psychopathe, sanguinaire,
cannibale). Le moût, lui, n'apporte rien à un abstinent (`DrugDesire` −1).

## Chimiburant et torches

**Chimiburant — aucune nouvelle pensée.** `RimScent_FuelScent` existe en amont (« fuel
fumes », −2) et n'était branchée que sur `Filth_Fuel` et les générateurs. On l'étend à la
raffinerie de biocarburant, au chimioréacteur infini et aux deux cuves à chimiburant.
Tous gatés : les deux premiers par courant + interrupteur, les cuves par `CompRefuelable` —
le chimiburant stocké *étant* leur combustible, **une cuve vide ne sent rien**.

**Torches — variante atténuée.** `RimScent_CampfireScent` vaut +3, avec une description qui
parle de nostalgie et de foyer : juste pour un feu autour duquel on s'assoit, beaucoup trop
pour une torche murale qu'on pose par dizaines le long d'un couloir. À +3 et en cumul,
éclairer une base serait devenu la meilleure source d'humeur du jeu.

D'où `RimScentExtended_Scent_Torch` à **+1, cumul 2** — brasier, torche murale, torche sombre,
torche sombre à champignons, brasier de lumière noire, torche de réunion sanguophage. Le feu
de camp et le foyer de pierre gardent leur +3 : ce sont des feux, pas de l'éclairage.

Cinq des six brûlent du `WoodLog`, la torche à champignons du `RawFungus` — d'où une
description volontairement neutre quant au combustible. Toutes ont un `CompRefuelable` :
une torche éteinte ou à court de bois ne sent rien.

## Bibelots : Knick Knacks, Colonists' Deco, Tabletop Trove

| Cible | Odeur |
|---|---|
| Knick Knacks — flacon vaporisateur (`SEX_Scents`) | désodorisant, +2 |
| Knick Knacks — vase | plante verte, +1 |
| Knick Knacks — feuilles volantes | vieux papier, +1 |
| Colonists' Deco — livre de chevet | vieux papier, +1 |
| Colonists' Deco — hure de sanglier, tête de cerf | peau tannée, −1 |
| Tabletop Trove — manuels, écran de meneur, feuilles de personnage, boîtes de jeu, paquets de cartes | vieux papier, +1 |

**Toutes ces pensées sont à `stackLimit` 1**, et c'est le point de conception. Ces objets ne
sont pas des bâtiments qu'on pose une fois : Knick Knacks fournit un `JobDef` « decorating »
et des `JoyGiver` qui font meubler chambres et salles à manger tout seuls. Ils prolifèrent.
À `stackLimit` 4, une pièce encombrée de bibelots serait devenue la meilleure source
d'humeur du jeu pour trois bouts de bois. Une pièce sent le désodorisant — pas six fois le
désodorisant.

C'est aussi pourquoi le vase ne réutilise **pas** `RimScent_FloweryScent` : son `stackLimit`
de 4 serait trop généreux ici, et sa texture montre du feuillage, pas des fleurs.

Ce qui n'a volontairement aucune odeur : boîtes, ronds de serviette, cadres photo, affiches,
attrape-rêves, formes en laiton, boules de papier, bibelots archotech, et les plateaux de jeu
en bois verni — seuls le papier et le carton sentent.

## Saletés vanilla

RimScent couvre **12 des 42 saletés** du jeu de base et des DLC. Ce patch en rattrape 22 de
plus, dont l'écrasante majorité en **réutilisant les pensées de l'amont** — elles existent,
elles sont traduites, et la saleté manquante est souvent la jumelle d'une saleté déjà
couverte.

| Saletés | Pensée |
|---|---|
| mousse anti-incendie | `RimScent_FirefoamScent` — **orpheline en amont** |
| marque d'explosion | `RimScent_ExplosionScent` — **orpheline en amont** |
| sang séché, sang sombre et sa traînée, flaque et traînée de revenant | `RimScent_BloodScent` |
| bile inflammable | `RimScent_BileScent` |
| chair grise remarquable | `RimScent_GrayFleshScent` |
| chair mutante, débris de métalhorreur | `RimScent_TwistedFleshScent` |
| acide usé | `RimScent_ToxicScent` |
| tache de chimiburant | `RimScent_FuelScent` |
| cendre volcanique | `RimScent_AshScent` |
| gravats de bâtiment et de roche, sable, terre remuée | `RimScent_DirtScent` |
| documents éparpillés | `RimScentExtended_Scent_OldPaper` (partagée avec les bibelots) |
| uniforme moisi | **moisissure**, −2 — nouvelle |
| limon, limon de nacelle | **limon**, −1 — nouvelle |

**Deux pensées de RimScent n'étaient accrochées à rien.** `RimScent_FirefoamScent` (« flat
chemical foam ») et `RimScent_ExplosionScent` (« sulfur and ozone ») sont définies en amont
et jamais utilisées — or `Filth_FireFoam` et `Filth_BlastMark` existent et correspondent
exactement à leur description. Même cas de figure que les pensées d'Epochs - Incense.

Restent volontairement inodores : cheveux coupés, eau, glace éclatée, dessins au sol, débris
mécaniques froids. Et deux cas écartés faute d'une réponse honnête — **liquide amniotique**
et **fluide de gestation** : leur donner l'odeur du sang serait un contresens (sa description
parle de « l'odeur de la violence »), et inventer une odeur d'accouchement pour deux defs m'a
paru plus douteux que de m'abstenir.

## Medical Supplements et Alpha Crafts

| Cible | Odeur |
|---|---|
| capsule de sels d'ammoniac (objet **et** hediff) | ammoniac, −2 |
| mélangeur chimique, laboratoire de stimulants | odeur de pharmacie, −1 |
| parfum d'Alpha Crafts (flacon **et** hediff porté) | parfum porté, +3 |
| bougie parfumée | bougie parfumée, +2 |
| savon | savon, +2 |
| essence, infuseur | essence concentrée, +2 |
| vinaigre, cornichons, œufs au vinaigre | vinaigre et saumure, −1 |
| fermenteur artisanal | **réutilise** `RimScentExtended_Scent_Fermenting` (celle du fût vanilla) |

Alpha Crafts est le mod le plus odorant de la liste : il a des fichiers dédiés au parfum,
aux essences, aux bougies parfumées, au savon, au vinaigre et aux cornichons. Beurre,
mayonnaise, farine, yaourt et popcorn sont écartés — ils sentent peu, et surtout ils
remplissent les réserves.

Deux détails de conception :

- **`RimScentExtended_Scent_WornScent` a déménagé dans `Core`.** Elle vivait dans le volet Social
  Supplements jusqu'à ce qu'Alpha Crafts en ait besoin aussi — or un volet ne peut pas
  référencer une `ThoughtDef` déclarée dans un autre, puisque celui-ci ne se charge que si
  *son* mod est actif. Toute pensée partagée doit vivre dans `Core`.
- L'essence d'Alpha Crafts prend le nom de son ingrédient
  (`AlphaCrafts.CompProperties_LabelByIngredients`) : elle peut sentir la rose comme l'ail.
  Sa description parle donc de la **concentration**, pas d'un parfum précis.

## Fleurs et plantes décoratives

RimScent donne `RimScent_FloweryScent` à trois plantes, nommément : `Plant_Rose`,
`Plant_Daylily`, `Plant_Dandelion`. Vérification faite, **ces trois-là sont exactement, et
seules, les plantes vanilla portant `plant/purpose = "Beauty"`**. Le critère implicite de
l'amont est donc celui-ci : le patch le rend explicite, et toutes les plantes décoratives
des mods en héritent.

Aucune nouvelle `ThoughtDef` : on réutilise celle de l'amont, déjà traduite.

Sur cette liste de mods, **17 mods** contiennent des plantes décoratives. Comptage unique
sur six d'entre eux :

| Mod | Plantes |
|---|---|
| Houseplants Remastered | 14 |
| Spidercamp's Decorative Plants | 12 |
| Vanilla Plants Expanded - More Plants | 11 |
| Vanilla Plants Expanded - Succulents | 10 |
| Flowers (Continued) | 8 |
| Glowmoss | 7 |

Soit **62 plantes contre 3 en vanilla**, sans énumérer un seul `defName`. S'y ajoutent
VPE Flowers, VPE Mushrooms, VIE Memes and Structures, VV New Harvest et les autres.

Le prédicat exclut les defs portant déjà une `ModExtension_Scent` — ce qui écarte
automatiquement les trois plantes vanilla et Overflowing Flowers, patchés par RimScent
avant nous — ainsi que les defs abstraits, pour ne pas ajouter l'extension au parent
puis à l'enfant qui en hérite. Les deux prédicats XPath ont été testés sur un document
réel avant livraison.


## Café et cuisine

RimScent ne parfume **aucun bâtiment de cuisine, pas même vanilla** : son patch de
bâtiments ne couvre que le feu de camp, le feu et les deux générateurs. Une cuisine en
plein service ne sentait rien.

| Cible | Odeur | Mod |
|---|---|---|
| fourneau électrique, fourneau à bois | odeur de cuisine, +2 | vanilla |
| marmite électrique, gril, friteuse | odeur de cuisine, +2 | Vanilla Cooking Expanded |
| fours de boulangerie (à bois et électrique) | pain frais, +3 | VCE Bakery |
| machine à espresso | arôme de café, +3 | VBE Coffees and Teas |
| 9 cafés | arôme de café, +3 | idem |
| 8 thés | thé infusé, +2 | idem |

**Le déclencheur est gratuit.** Les huit bâtiments portent tous un `CompPowerTrader` ou un
`CompRefuelable` — vérifié un par un — que le scan de RimScent teste déjà, et l'interrupteur
depuis notre correctif. Une cuisine non alimentée, à court de bois ou éteinte ne sent donc
rien, sans une ligne de code de plus.

Laissés de côté volontairement : machine à conserves, table à condiments et presse à
fromage, qui ne cuisent rien.

Les patchs utilisent le **motif à prédicats disjoints** (`… and modExtensions` /
`… and not(modExtensions)`) plutôt que `match`/`nomatch`. Avec une liste de defs groupés
par `or`, un `match`/`nomatch` classique ne patcherait que ceux qui ont déjà des
`modExtensions`, ou que ceux qui n'en ont pas — jamais les deux. C'est aussi ce qui permet
d'inclure sans risque les boissons que VBE ne charge qu'avec Vanilla Cooking Expanded :
un `or` qui ne trouve qu'une partie de ses defs patche simplement ceux qui existent.

Vérifié sur les defs réels : 25 cibles, `avec modExtensions` + `sans` = total pour chacun
des six groupes, donc couverture intégrale.

## Social Supplements, maladies, Epochs

| Cible | Odeur | Remarque |
|---|---|---|
| 3 « Scenters » portés (hediffs) | parfum porté, +3 | même forme que Perfumes : le mod a tout un volet parfumerie, sans une seule `ModExtension_Scent` |
| 2 vapotages (hediffs) | nuage de vapeur, −1 | l'odeur dure ce que dure l'effet, comme `SmokeleafHigh` en amont |
| bain de bouche, thé à la menthe, plante et feuilles de menthe | menthe, +2 | |
| piments, sauce piquante | piment dans l'air, −1 | |
| polyfleur, pétales, jus | **réutilise** `RimScent_FloweryScent` | elle ne porte **pas** `purpose="Beauty"` — vérifié — donc le patch fleurs ne l'attrapait pas |
| 10 saletés de germes | air de chambre de malade, −2 | les germes ne sentent pas, une chambre de malade si |
| 2 brûle-encens Epochs | **leurs propres pensées** | voir ci-dessous |

Deux volets Epochs / Stoneborn s'y ajoutent :

| Cible | Odeur |
|---|---|
| torches au suif, torche murale, suif brut | suif qui brûle, −1 |
| âtre au suif | **odeur de cuisine** — c'est un poste de cuisson (`DV_DoBillsCookTallowHearth`), le repas domine le combustible |
| gril, four nain, marmite portative, micro-générateur quantique | odeur de cuisine |
| séchoir à viande | viande qui sèche, +1 |
| insectarium | insectarium, −2 — *parti dans [Farmyard Expansion](https://github.com/vbardales/Rimworld-RimScent-Extended-Farmyard-Expansion)*, avec les abeilles |

Les torches au suif n'ont pas de `CompRefuelable` mais un `CompProperties_DestroyAfterDelay` :
elles se détruisent en s'éteignant, donc **une torche qui existe est une torche allumée** —
le gate est automatique. Le séchoir et l'insectarium, eux, n'ont aucune alimentation et
sentiront en permanence : correct pour ce qu'ils sont.

**Epochs - Incense définit deux `ThoughtDef` que rien n'applique.** `IncenseThought` et
`StandingIncenseThought`, toutes deux « pleasant smell » à +2, ne sont citées nulle part
ailleurs que dans leur propre fichier — dans aucun mod du Workshop — et le mod ne contient
aucune assembly. Ses brûle-encens sont donc purement décoratifs, alors que leur description
promet « a pleasant floral aroma ». On les branche sur RimScent en réutilisant **les pensées
de l'auteur** plutôt qu'en créant les nôtres : c'est ce qu'il avait prévu, et aucun double
compte n'est possible puisque rien d'autre ne les pose.

Deux pièges rencontrés :

- **Six des dix saletés de germes n'existent pas toujours.** Communicable Diseases ne les
  crée que par un `PatchOperationFindMod` conditionné à *Diseases Overhauled*, absent de
  cette liste de mods. Seules quatre seront donc réellement patchées ici. Le motif à
  prédicats disjoints le tolère sans erreur.
- **L'ordre de chargement compte** pour ce cas précis : les opérations de patch s'appliquent
  dans l'ordre des mods, donc `About.xml` déclare désormais en `loadAfter` **tous** les mods
  que ce mod patche, pas seulement la famille RimScent.

## Vanilla Events Expanded

VEE ajoute 5 météos et 10 conditions, dont aucune ne sentait quoi que ce soit. RimScent
lit les conditions et la météo **à l'échelle de la carte**, hors boucle de cellules :
chaque odeur ici touche toute la colonie d'un coup, d'où la retenue sur les valeurs.

| Événement | Odeur | Source |
|---|---|---|
| sécheresse | air desséché, −2 | nouvelle |
| canicule mondiale + météos *swelter* et *inferno* | air étouffant, −2 | nouvelle |
| floraison psychique | floraison étrangère, +2 | nouvelle |
| chute d'épave orbitale | soufre et ozone, −2 | **réutilise** `RimScent_ExplosionScent` |
| pluie psychique | pétrichor, +3 | **réutilise** `RimScent_PetrichorScent` |

**Ce qui n'a délibérément aucune odeur** : *whiteout*, *long night*, *psychic stimulation*,
*psychic overdrive*, *psychic hum*. Le froid et les phénomènes psychiques n'ont pas d'odeur,
et leur en inventer une serait du bruit.

Trois précisions :

- *Inferno* et *swelter* sont bien des **chaleurs**, pas des incendies — vérifié dans leurs
  defs (`rainRate 0`, `snowRate 0`, aucune composante de feu). D'où l'air étouffant plutôt
  que `RimScent_FireScent`.
- Pour la pluie psychique on patche la **météo** et non la condition homonyme : les deux
  existent, et `RimScent_PetrichorScent` ayant un `stackLimit` de 4, patcher les deux
  compterait l'odeur deux fois. C'est la météo qui tombe réellement (`rainRate 1`, son
  `Ambient_Rain`).
- Quatre des cibles portent déjà des `modExtensions` à elles (`VEF.Maps.MapConditionExtension`) :
  la branche *match* s'y ajoute au lieu d'écraser.

## Mod Perfumes (Romyashi)

[Perfumes](https://steamcommunity.com/sharedfiles/filedetails/?id=3013711969) donne au
porteur un bonus d'humeur et des bonus de stats, mais **aucune `ModExtension_Scent` dans
tout le mod** : personne autour de lui ne sentait quoi que ce soit. C'est le trou que
l'extension parfums de RimScent comble pour ses propres parfums.

| Parfum | Effet sur le porteur (mod d'origine) | Odeur perçue par les autres |
|---|---|---|
| floral | beauté, négociation, prix d'échange | +3 |
| végétal | apprivoisement et dressage +15 % | +2 |
| chasse | discrétion à la chasse +50 % | **−1** — il est fait de foin, et sert à ne *pas* sentir l'humain |
| ancien | beauté +3, social et commerce +30 % | +5 |
| anima | sensibilité psychique | +3 (seulement avec Anima Expansion) |
| pétales d'aromafleur | — | +2, cumul 4 |

Aucun double compte : RimScent ne lit les hediffs que des pions **voisins**
(`otherPawn != pawn`), donc le porteur ne se sent pas lui-même et garde le bonus du mod
d'origine. La fleur sur pied est déjà couverte par le patch fleurs — elle porte
`purpose="Beauty"` ; seules les pétales récoltées, qui sont un objet, demandaient un patch.

Deux pièges traités :

- Le parfum d'anima porte un `MayRequire` sur Anima Expansion, absent de cette liste. Le
  patch est enveloppé dans un conditionnel imbriqué : si le def n'existe pas, rien ne se
  produit et aucune erreur n'est levée.
- Sa `ThoughtDef` portant elle aussi `MayRequire`, **sa traduction est isolée** dans
  `RomyPerfumesAnima/`, conditionné au même mod — une clé qui vise un def absent est une
  erreur de chargement. `Check-DefInjected.ps1` signale désormais ce cas.

