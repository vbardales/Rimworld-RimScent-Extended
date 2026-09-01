using System.Collections.Generic;
using HarmonyLib;
using RimScentReworked;
using RimWorld;
using UnityEngine;
using Verse;

namespace RimScentExtended
{
    /// <summary>
    /// Version corrigee de Pawn_ScentTracker.UpdateScent. La structure suit celle de
    /// l'amont pour que la comparaison reste lisible ; les quatre ecarts sont signales
    /// par un commentaire BUG n, detaille dans BUGS.md.
    /// </summary>
    internal static class ScentScan
    {
        // activeThought est prive mais sauvegarde par PostExposeData en amont. On s'en
        // sert plutot que de tenir un etat parallele, pour ne rien changer au format de
        // sauvegarde et pour que ClearThought de l'amont reste coherent.
        private static readonly AccessTools.FieldRef<Pawn_ScentTracker, ThoughtDef> ActiveThought =
            AccessTools.FieldRefAccess<Pawn_ScentTracker, ThoughtDef>("activeThought");

        private static PawnCapacityDef smellCapacity;
        private static StatDef smellStat;
        private static HashSet<ThingDef> scentThings;
        private static HashSet<HediffDef> scentHediffs;
        private static HashSet<ThingDef> aromaThings;
        private static HashSet<ThingDef> bodyScentThings;
        // Les cadavres n'ont pas de def patchable : Corpse_Human et consorts sont generes
        // a l'execution, apres les PatchOperation. On retrouve donc les trois pensees par
        // defName, comme RimScent le fait pour sa capacite et son stat d'odorat.
        private static ThoughtDef corpseFresh, corpseRotting, corpseDessicated;
        // Objets susceptibles de pourrir. Sans ce cache il faudrait un TryGetComp par objet
        // et par cellule : un entrepot bien rempli le paierait cher a chaque passage.
        private static HashSet<ThingDef> rottableThings;
        private static ThoughtDef rottenFood;
        private static Dictionary<TerrainDef, ModExtension_TerrainScent> scentTerrains;
        private static bool cacheBuilt;

        private static void EnsureCache()
        {
            if (cacheBuilt) return;
            smellCapacity = DefDatabase<PawnCapacityDef>.GetNamedSilentFail("RimScent_Smell");
            smellStat = DefDatabase<StatDef>.GetNamedSilentFail("RimScent_SmellSensitivity");
            scentThings = new HashSet<ThingDef>();
            aromaThings = new HashSet<ThingDef>();
            bodyScentThings = new HashSet<ThingDef>();
            foreach (ThingDef d in DefDatabase<ThingDef>.AllDefs)
            {
                if (d.GetModExtension<ModExtension_Scent>()?.thought != null) scentThings.Add(d);
                if (d.GetModExtension<ModExtension_ScentHediff>()?.hediff != null) aromaThings.Add(d);
                if (d.GetModExtension<ModExtension_PawnScent>()?.thought != null) bodyScentThings.Add(d);
            }
            scentHediffs = new HashSet<HediffDef>();
            foreach (HediffDef d in DefDatabase<HediffDef>.AllDefs)
                if (d.GetModExtension<ModExtension_Scent>()?.thought != null) scentHediffs.Add(d);
            // Le terrain odorant est mis en cache dans un dictionnaire plutot qu'un
            // ensemble : la boucle de cases fait un acces par case, et on veut l'extension
            // elle-meme sans repasser par GetModExtension a chaque fois.
            scentTerrains = new Dictionary<TerrainDef, ModExtension_TerrainScent>();
            foreach (TerrainDef d in DefDatabase<TerrainDef>.AllDefs)
            {
                ModExtension_TerrainScent ext = d.GetModExtension<ModExtension_TerrainScent>();
                if (ext?.thought != null) scentTerrains[d] = ext;
            }
            // On teste l'heritage plutot que l'egalite de type : un mod peut sous-classer
            // CompRottable, et ThingDef.HasComp ne compare que la classe exacte.
            rottableThings = new HashSet<ThingDef>();
            foreach (ThingDef d in DefDatabase<ThingDef>.AllDefs)
            {
                if (d.comps == null) continue;
                for (int i = 0; i < d.comps.Count; i++)
                {
                    if (d.comps[i]?.compClass != null
                        && typeof(CompRottable).IsAssignableFrom(d.comps[i].compClass))
                    {
                        rottableThings.Add(d);
                        break;
                    }
                }
            }
            rottenFood = DefDatabase<ThoughtDef>.GetNamedSilentFail("RimScentExtended_Scent_RottenFood");
            corpseFresh = DefDatabase<ThoughtDef>.GetNamedSilentFail("RimScentExtended_Scent_CorpseFresh");
            corpseRotting = DefDatabase<ThoughtDef>.GetNamedSilentFail("RimScentExtended_Scent_CorpseRotting");
            corpseDessicated = DefDatabase<ThoughtDef>.GetNamedSilentFail("RimScentExtended_Scent_CorpseDessicated");
            cacheBuilt = true;
        }

        public static void Run(Pawn_ScentTracker comp, Pawn pawn)
        {
            if (pawn?.Map == null || pawn.needs?.mood == null) return;
            EnsureCache();
            RimScentReworkedSettings settings = RimScentReworkedMod.Settings;

            float capacity = smellCapacity != null ? pawn.health.capacities.GetLevel(smellCapacity) : 1f;
            float sensitivity = smellStat != null ? pawn.GetStatValue(smellStat) : 1f;
            float smellFactor = capacity * sensitivity;
            if (smellFactor <= 0f) { Clear(comp, pawn); return; }

            // Le gene anosmique force le trait RimScent_Anosmic, qui met la sensibilite a
            // zero : on est deja sorti au-dessus. Le test reste au cas ou un mod ajouterait
            // un gene anosmique sans le trait.
            if (HasGeneContaining(pawn, "Anosmic")) { Clear(comp, pawn); return; }

            // La chaleur rend les odeurs volatiles, le froid les fige. On applique le
            // facteur APRES la sortie anticipee ci-dessus : un pion anosmique le reste, et
            // une chambre froide attenue les odeurs sans jamais supprimer l'odorat.
            float ambientTemperature = pawn.AmbientTemperature;
            if (RimScentExtendedMod.Settings?.temperatureEnabled ?? true)
                smellFactor *= TemperatureFactor(ambientTemperature);

            bool dysosmicPawn = HasDysosmicTrait(pawn) || HasGeneContaining(pawn, "Dysosmic");
            HashSet<string> traitNames = TraitNames(pawn);
            HashSet<string> geneNames = GeneNames(pawn);

            Dictionary<ThoughtDef, int> counts = new Dictionary<ThoughtDef, int>();
            Dictionary<ThoughtDef, bool> dysosmic = new Dictionary<ThoughtDef, bool>();
            HashSet<HediffDef> aromas = null;

            Room pawnRoom = pawn.GetRoom();
            bool pawnOutdoors = pawnRoom == null || pawnRoom.PsychologicallyOutdoors;
            int radius = settings?.scentRadius ?? 8;
            bool homeOnly = settings?.homeOnly ?? false;
            Area home = homeOnly ? pawn.Map.areaManager?.Home : null;

            foreach (IntVec3 cell in GenRadial.RadialCellsAround(pawn.Position, radius, true))
            {
                if (!cell.InBounds(pawn.Map)) continue;
                if (homeOnly && home != null && !home[cell]) continue;
                if (!GenSight.LineOfSight(pawn.Position, cell, pawn.Map, true)) continue;

                Room cellRoom = cell.GetRoom(pawn.Map);
                bool cellOutdoors = cellRoom == null || cellRoom.PsychologicallyOutdoors;

                // BUG 2 - else pendant. En amont :
                //     if (pawnOutdoors)
                //         if (!cellOutdoors) continue;
                //     else if (cellRoom != pawnRoom)
                //         continue;
                // le else se rattache au if interne. Un pion a l'interieur ne filtrait
                // donc rien du tout, et sentait les pieces voisines comme le dehors.
                if (pawnOutdoors)
                {
                    if (!cellOutdoors) continue;
                }
                else if (cellRoom != pawnRoom)
                {
                    continue;
                }

                // Le sol de la case. Compte par case, donc proportionnel a la surface
                // d'eau ou de vase autour du pion, et plafonne par le stackLimit de la
                // pensee. Lu avant les objets : un tapis pose sur de la vase ne la fait
                // pas disparaitre, les deux odeurs entrent au concours de dominance.
                if (scentTerrains.Count > 0)
                {
                    TerrainDef terrain = pawn.Map.terrainGrid.TerrainAt(cell);
                    ModExtension_TerrainScent soil;
                    if (terrain != null && scentTerrains.TryGetValue(terrain, out soil)
                        && soil.AppliesAt(ambientTemperature))
                        Record(soil.thought, dysosmicPawn, counts, dysosmic);
                }

                List<Thing> things = pawn.Map.thingGrid.ThingsListAtFast(cell);
                for (int i = 0; i < things.Count; i++)
                {
                    Thing thing = things[i];

                    if (thing is Pawn other && other != pawn)
                    {
                        List<Hediff> hediffs = other.health?.hediffSet?.hediffs;
                        if (hediffs != null)
                            for (int h = 0; h < hediffs.Count; h++)
                            {
                                if (!scentHediffs.Contains(hediffs[h].def)) continue;
                                Accumulate(hediffs[h].def.GetModExtension<ModExtension_Scent>(),
                                    pawn, traitNames, geneNames, dysosmicPawn, counts, dysosmic);
                            }

                        // L'odeur du pion lui-meme. RimScent ne regarde que les hediffs
                        // d'un voisin, jamais son ThingDef de race : sans ca, un troupeau
                        // entier ne sentirait rien.
                        if (bodyScentThings.Contains(other.def))
                        {
                            ModExtension_PawnScent body = other.def.GetModExtension<ModExtension_PawnScent>();
                            if (body != null && body.AppliesTo(other))
                                Record(body.thought, dysosmicPawn, counts, dysosmic);
                        }
                        continue;
                    }

                    // Les cadavres, gradues par leur etat de putrefaction. Un corps
                    // enterre est contenu dans la tombe, donc absent du thingGrid : il
                    // ne sent pas, ce qui est le comportement voulu et gratuit.
                    if (thing is Corpse corpse)
                    {
                        ThoughtDef rot = CorpseThought(corpse);
                        if (rot != null) Record(rot, dysosmicPawn, counts, dysosmic);
                        continue;
                    }

                    // Nourriture avariee. Les cadavres sont deja partis par la branche
                    // ci-dessus, donc aucun double compte. Un objet garde son odeur propre
                    // en plus - du smokeleaf pourri sent les deux, et le concours de
                    // dominance tranche.
                    if (rottenFood != null && rottableThings.Contains(thing.def)
                        && thing.GetRotStage() != RotStage.Fresh)
                        Record(rottenFood, dysosmicPawn, counts, dysosmic);

                    if (!scentThings.Contains(thing.def) && !aromaThings.Contains(thing.def)) continue;

                    CompRefuelable refuelable = thing.TryGetComp<CompRefuelable>();
                    if (refuelable != null && !refuelable.HasFuel) continue;
                    CompPowerTrader power = thing.TryGetComp<CompPowerTrader>();
                    if (power != null && !power.PowerOn) continue;

                    // BUG 1 - interrupteur ignore. CompRefuelable.CompTick ne consomme que
                    // si flickComp.SwitchIsOn, mais HasFuel n'en tient pas compte : un
                    // brule-encens eteint gardait son plein et parfumait sans fin.
                    CompFlickable flick = thing.TryGetComp<CompFlickable>();
                    if (flick != null && !flick.SwitchIsOn) continue;

                    // Effet physiologique de nos aromes. Il ne passe pas par le concours
                    // d'odeur dominante : respirer deux fumees, c'est subir les deux.
                    HediffDef aroma = thing.def.GetModExtension<ModExtension_ScentHediff>()?.hediff;
                    if (aroma != null) (aromas ?? (aromas = new HashSet<HediffDef>())).Add(aroma);

                    Accumulate(thing.def.GetModExtension<ModExtension_Scent>(),
                        pawn, traitNames, geneNames, dysosmicPawn, counts, dysosmic);
                }
            }

            foreach (GameCondition condition in pawn.Map.gameConditionManager.ActiveConditions)
                Accumulate(condition.def.GetModExtension<ModExtension_Scent>(),
                    pawn, traitNames, geneNames, dysosmicPawn, counts, dysosmic);

            WeatherDef weather = pawn.Map.weatherManager.curWeather;
            if (weather != null)
                Accumulate(weather.GetModExtension<ModExtension_Scent>(),
                    pawn, traitNames, geneNames, dysosmicPawn, counts, dysosmic);

            // Avant le retour anticipe ci-dessous : un arome peut etre present alors
            // qu'aucune pensee ne l'est (odeur annulee par un precepte, par exemple).
            if (aromas != null)
                foreach (HediffDef aroma in aromas) RefreshAroma(pawn, aroma);

            // Accoutumance : on met a jour les compteurs d'exposition AVANT le retour
            // anticipe, pour que les odeurs disparues redescendent meme quand le pion ne
            // sent plus rien du tout.
            ScentAdaptation.Update(pawn, counts, settings?.scentTickInterval ?? 500);

            if (counts.Count == 0) return;

            if (!(settings?.uncappedScents ?? false))
            {
                ThoughtDef winner = null;
                float winnerMagnitude = 0f;
                foreach (KeyValuePair<ThoughtDef, int> kv in counts)
                {
                    // L'accoutumance entre dans le concours de dominance, et pas seulement
                    // dans l'humeur finale : une odeur a laquelle on s'est habitue doit
                    // pouvoir se faire supplanter par une odeur nouvelle et plus faible.
                    float magnitude = Magnitude(kv.Key, kv.Value, settings)
                                    * ScentAdaptation.Factor(pawn, kv.Key);
                    if (magnitude > winnerMagnitude) { winnerMagnitude = magnitude; winner = kv.Key; }
                }
                if (winner == null) return;

                ThoughtDef active = ActiveThought(comp);
                if (active != null &&
                    winnerMagnitude <= Magnitude(active, CountThought(pawn, active), settings)
                                     * ScentAdaptation.Factor(pawn, active))
                    return;

                Clear(comp, pawn);
                ActiveThought(comp) = winner;
                Apply(pawn, winner, counts[winner], smellFactor * ScentAdaptation.Factor(pawn, winner),
                    DysosmicFor(dysosmic, winner), settings);
            }
            else
            {
                Clear(comp, pawn);
                ActiveThought(comp) = null;
                foreach (KeyValuePair<ThoughtDef, int> kv in counts)
                    Apply(pawn, kv.Key, kv.Value, smellFactor * ScentAdaptation.Factor(pawn, kv.Key),
                        DysosmicFor(dysosmic, kv.Key), settings);
            }
        }

        private static void Accumulate(ModExtension_Scent ext, Pawn pawn,
            HashSet<string> traitNames, HashSet<string> geneNames, bool dysosmicPawn,
            Dictionary<ThoughtDef, int> counts, Dictionary<ThoughtDef, bool> dysosmic)
        {
            if (ext?.thought == null) return;

            // BUG 4 - signe de l'anosmie. En amont, AddMemory ajoutait +2 x baseMood a
            // l'offset ; or MoodOffset() vaut baseMood + moodOffset, donc l'odeur etait
            // triplee au lieu d'etre annulee. Un pion insensible a une odeur ne doit pas
            // la percevoir du tout : on ne la compte meme pas.
            if (Matches(ext.anosmicTraits, traitNames)
                || HasAnyTraitDegree(pawn, ext.anosmicTraitDegrees)
                || Matches(ext.anosmicGenes, geneNames))
                return;

            bool d = dysosmicPawn
                || Matches(ext.dysosmicTraits, traitNames)
                // BUG 3 - en amont : if (ext.dysosmicTraitDegrees != null) return true;
                // la seule presence du champ dans le def suffisait, le pion n'etait jamais
                // consulte. Meme defaut sur anosmicTraitDegrees, teste ci-dessus.
                || HasAnyTraitDegree(pawn, ext.dysosmicTraitDegrees)
                || Matches(ext.dysosmicGenes, geneNames);
            Record(ext.thought, d, counts, dysosmic);
        }

        /// <summary>
        /// Facteur de volatilite selon la temperature ambiante. Le total d'une odeur vaut
        /// baseMoodEffect x smellFactor (voir Apply et Thought_Memory.MoodOffset), donc
        /// multiplier smellFactor amplifie ou attenue toute l'odeur, bonne comme mauvaise.
        ///
        /// C'est physiquement juste - la chaleur volatilise les composes odorants, le froid
        /// les fige - et ca donne enfin un interet olfactif a la refrigeration : un charnier
        /// en chambre froide ne pue presque plus, le meme sous 40 degres devient intenable.
        ///
        /// Jamais zero : meme a -50 degres il reste 40 % de l'odeur. Une odeur qui
        /// disparaitrait completement ferait clignoter la pensee au gre des courants d'air.
        /// </summary>
        private static float TemperatureFactor(float celsius)
        {
            if (celsius <= -10f) return 0.4f;
            if (celsius <= 20f) return Mathf.Lerp(0.4f, 1f, (celsius + 10f) / 30f);
            if (celsius <= 45f) return Mathf.Lerp(1f, 1.6f, (celsius - 20f) / 25f);
            return 1.6f;
        }

        /// <summary>
        /// RottableUtility.GetRotStage renvoie Fresh par defaut quand le cadavre n'a pas
        /// de CompRottable - cas des mecanoides et des entites, qui ne pourrissent pas.
        /// Une carcasse de mecanoide ne sent donc que la mort fraiche, jamais la charogne.
        /// </summary>
        private static ThoughtDef CorpseThought(Corpse corpse)
        {
            switch (corpse.GetRotStage())
            {
                case RotStage.Rotting: return corpseRotting;
                case RotStage.Dessicated: return corpseDessicated;
                default: return corpseFresh;
            }
        }

        private static void Record(ThoughtDef thought, bool dysosmicHere,
            Dictionary<ThoughtDef, int> counts, Dictionary<ThoughtDef, bool> dysosmic)
        {
            counts.TryGetValue(thought, out int count);
            counts[thought] = count + 1;
            dysosmic[thought] = dysosmic.TryGetValue(thought, out bool prev)
                ? (prev || dysosmicHere)
                : dysosmicHere;
        }

        private static void Apply(Pawn pawn, ThoughtDef def, int sources, float smellFactor,
            bool dysosmic, RimScentReworkedSettings settings)
        {
            int target = Mathf.Min(sources, StackLimit(def, settings));
            int existing = CountThought(pawn, def);

            if (existing < target)
            {
                float baseMood = def.stages[0].baseMoodEffect;
                float offset = baseMood * (smellFactor - 1f);
                if (dysosmic) offset -= baseMood * 2f;
                int moodOffset = Mathf.RoundToInt(offset);
                for (int i = existing; i < target; i++)
                {
                    Thought_Memory memory = (Thought_Memory)ThoughtMaker.MakeThought(def);
                    memory.moodOffset = moodOffset;
                    pawn.needs.mood.thoughts.memories.TryGainMemory(memory);
                }
            }

            int excess = CountThought(pawn, def) - target;
            if (excess <= 0) return;
            List<Thought_Memory> matching = new List<Thought_Memory>();
            List<Thought_Memory> memories = pawn.needs.mood.thoughts.memories.Memories;
            for (int i = 0; i < memories.Count; i++)
                if (memories[i].def == def) matching.Add(memories[i]);
            for (int i = 0; i < excess && i < matching.Count; i++)
                pawn.needs.mood.thoughts.memories.RemoveMemory(matching[i]);
        }

        /// <summary>
        /// Pose l'arome, ou repousse son echeance s'il est deja la. HediffComp_Disappears
        /// sert de minuterie : tant que le colon reste expose, chaque passage du scan la
        /// remet a plein, et l'effet s'estompe tout seul apres son depart. Rien n'est donc
        /// a retirer explicitement, y compris si le mod est desinstalle en cours de partie.
        /// </summary>
        private static void RefreshAroma(Pawn pawn, HediffDef def)
        {
            Hediff existing = pawn.health.hediffSet.GetFirstHediffOfDef(def);
            if (existing == null)
            {
                pawn.health.AddHediff(def);
                return;
            }
            HediffComp_Disappears timer = (existing as HediffWithComps)?.TryGetComp<HediffComp_Disappears>();
            if (timer != null && timer.ticksToDisappear < timer.disappearsAfterTicks)
                timer.ticksToDisappear = timer.disappearsAfterTicks;
        }

        private static void Clear(Pawn_ScentTracker comp, Pawn pawn)
        {
            ThoughtDef active = ActiveThought(comp);
            if (active == null) return;
            pawn.needs.mood.thoughts.memories.RemoveMemoriesOfDef(active);
            ActiveThought(comp) = null;
        }

        private static bool DysosmicFor(Dictionary<ThoughtDef, bool> map, ThoughtDef def)
            => map.TryGetValue(def, out bool value) && value;

        private static int StackLimit(ThoughtDef def, RimScentReworkedSettings settings)
        {
            if (!(settings?.allowMoodStacking ?? true)) return 1;
            return def.stackLimit > 0 ? def.stackLimit : 1;
        }

        private static float Magnitude(ThoughtDef def, int sources, RimScentReworkedSettings settings)
            => Mathf.Abs(def.stages[0].baseMoodEffect) * Mathf.Min(sources, StackLimit(def, settings));

        private static int CountThought(Pawn pawn, ThoughtDef def)
        {
            int n = 0;
            List<Thought_Memory> memories = pawn.needs.mood.thoughts.memories.Memories;
            for (int i = 0; i < memories.Count; i++)
                if (memories[i].def == def) n++;
            return n;
        }

        private static bool HasDysosmicTrait(Pawn pawn)
        {
            List<Trait> traits = pawn.story?.traits?.allTraits;
            if (traits == null) return false;
            for (int i = 0; i < traits.Count; i++)
                if (traits[i].def.GetModExtension<ModExtension_Dysosmic>() != null) return true;
            return false;
        }

        private static bool HasGeneContaining(Pawn pawn, string fragment)
        {
            if (pawn.genes == null) return false;
            List<Gene> genes = pawn.genes.GenesListForReading;
            for (int i = 0; i < genes.Count; i++)
                if (genes[i].def.defName.Contains(fragment)) return true;
            return false;
        }

        private static HashSet<string> TraitNames(Pawn pawn)
        {
            HashSet<string> set = new HashSet<string>();
            List<Trait> traits = pawn.story?.traits?.allTraits;
            if (traits != null)
                for (int i = 0; i < traits.Count; i++) set.Add(traits[i].def.defName);
            return set;
        }

        private static HashSet<string> GeneNames(Pawn pawn)
        {
            HashSet<string> set = new HashSet<string>();
            if (pawn.genes == null) return set;
            List<Gene> genes = pawn.genes.GenesListForReading;
            for (int i = 0; i < genes.Count; i++) set.Add(genes[i].def.defName);
            return set;
        }

        private static bool Matches(List<string> wanted, HashSet<string> owned)
        {
            if (wanted == null || owned == null) return false;
            for (int i = 0; i < wanted.Count; i++)
                if (owned.Contains(wanted[i])) return true;
            return false;
        }

        private static bool HasAnyTraitDegree(Pawn pawn, List<TraitRequirement> requirements)
        {
            if (requirements == null) return false;
            for (int i = 0; i < requirements.Count; i++)
                if (requirements[i]?.def != null && requirements[i].HasTrait(pawn)) return true;
            return false;
        }
    }
}
