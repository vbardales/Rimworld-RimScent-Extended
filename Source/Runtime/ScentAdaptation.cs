using System.Collections.Generic;
using RimWorld;
using UnityEngine;
using Verse;

namespace RimScentExtended
{
    /// <summary>
    /// Accoutumance olfactive : une odeur constante finit par ne plus se remarquer, et
    /// revient de plein fouet apres une absence.
    ///
    /// Sans ca, un colon qui vit dans une etable est malheureux en permanence, ce qui est
    /// faux et surtout punitif : le jeu n'offre aucun moyen de « s'y faire ». C'est aussi
    /// ce qui rend la variete interessante - alterner les encens vaut mieux que d'en
    /// brancher un et l'oublier.
    ///
    /// Etat en memoire vive uniquement, volontairement : rien n'entre dans la sauvegarde,
    /// conformement au reste du mod. L'accoutumance se reinitialise donc au chargement -
    /// un defaut acceptable pour un effet qui se reconstruit en deux heures de jeu.
    /// </summary>
    internal static class ScentAdaptation
    {
        private class Exposure
        {
            public int lastSeenTick;
            public readonly Dictionary<ThoughtDef, int> ticks = new Dictionary<ThoughtDef, int>();
        }

        // La recuperation est deux fois plus rapide que l'accoutumance : on se desaccoutume
        // plus vite qu'on ne s'habitue, ce qui est le sens physiologique et evite qu'un
        // colon reste insensible longtemps apres avoir quitte la piece.
        private const int RecoveryMultiplier = 2;
        private const int PurgeInterval = 60000;
        private const int ForgetAfter = 60000;

        private static readonly Dictionary<int, Exposure> exposures = new Dictionary<int, Exposure>();
        private static readonly List<ThoughtDef> scratch = new List<ThoughtDef>();
        private static readonly List<int> stale = new List<int>();
        private static int lastPurgeTick;

        public static void Clear() => exposures.Clear();

        /// <summary>
        /// Met a jour les compteurs d'exposition du pion : ce qu'il sent a l'instant monte,
        /// le reste redescend. Appele une fois par passage de scan.
        /// </summary>
        public static void Update(Pawn pawn, Dictionary<ThoughtDef, int> smelledNow, int intervalTicks)
        {
            RimScentExtendedSettings settings = RimScentExtendedMod.Settings;
            if (settings == null || !settings.adaptationEnabled) return;

            int now = Find.TickManager?.TicksGame ?? 0;
            Purge(now);

            if (!exposures.TryGetValue(pawn.thingIDNumber, out Exposure exposure))
            {
                exposure = new Exposure();
                exposures[pawn.thingIDNumber] = exposure;
            }
            exposure.lastSeenTick = now;

            int cap = settings.AdaptationTicks;

            scratch.Clear();
            foreach (KeyValuePair<ThoughtDef, int> kv in exposure.ticks)
                if (!smelledNow.ContainsKey(kv.Key)) scratch.Add(kv.Key);
            for (int i = 0; i < scratch.Count; i++)
            {
                int reduced = exposure.ticks[scratch[i]] - intervalTicks * RecoveryMultiplier;
                if (reduced <= 0) exposure.ticks.Remove(scratch[i]);
                else exposure.ticks[scratch[i]] = reduced;
            }

            foreach (KeyValuePair<ThoughtDef, int> kv in smelledNow)
            {
                exposure.ticks.TryGetValue(kv.Key, out int current);
                exposure.ticks[kv.Key] = Mathf.Min(current + intervalTicks, cap);
            }
        }

        /// <summary>
        /// Facteur multiplicatif a appliquer a cette odeur pour ce pion : 1 quand elle est
        /// nouvelle, jusqu'au plancher des reglages quand l'accoutumance est complete.
        /// </summary>
        public static float Factor(Pawn pawn, ThoughtDef thought)
        {
            RimScentExtendedSettings settings = RimScentExtendedMod.Settings;
            if (settings == null || !settings.adaptationEnabled) return 1f;
            if (thought?.stages == null || thought.stages.Count == 0) return 1f;

            // Odeur agreable et accoutumance limitee aux mauvaises : on ne touche a rien.
            if (!settings.adaptToPleasant && thought.stages[0].baseMoodEffect > 0f) return 1f;

            if (!exposures.TryGetValue(pawn.thingIDNumber, out Exposure exposure)) return 1f;
            if (!exposure.ticks.TryGetValue(thought, out int elapsed) || elapsed <= 0) return 1f;

            float progress = Mathf.Clamp01((float)elapsed / settings.AdaptationTicks);
            return Mathf.Lerp(1f, Mathf.Clamp(settings.adaptationFloor, 0.05f, 1f), progress);
        }

        private static void Purge(int now)
        {
            if (now - lastPurgeTick < PurgeInterval) return;
            lastPurgeTick = now;
            stale.Clear();
            foreach (KeyValuePair<int, Exposure> kv in exposures)
                if (now - kv.Value.lastSeenTick > ForgetAfter) stale.Add(kv.Key);
            for (int i = 0; i < stale.Count; i++) exposures.Remove(stale[i]);
        }
    }
}
