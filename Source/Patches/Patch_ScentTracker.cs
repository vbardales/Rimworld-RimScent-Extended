using HarmonyLib;
using RimScentReworked;
using Verse;

namespace RimScentExtended
{
    /// <summary>
    /// Bugs 1 a 4 : la boucle de scan est remplacee en entier. Les quatre defauts sont
    /// dans le meme corps de methode (test d'interrupteur absent, else pendant, handles
    /// de traits ignores, signe de l'anosmie), et une methode privee ne se corrige pas
    /// morceau par morceau depuis l'exterieur.
    /// </summary>
    [HarmonyPatch(typeof(Pawn_ScentTracker), "UpdateScent")]
    internal static class Patch_ScentTracker_UpdateScent
    {
        private static bool Prefix(Pawn_ScentTracker __instance, Pawn pawn)
        {
            ScentScan.Run(__instance, pawn);
            return false;
        }
    }

    /// <summary>
    /// Bug 5 : CompTick lit pawn.IsAnimal avant de tester pawn == null. Le comp n'est
    /// pose que sur le ThingDef Human aujourd'hui, mais il suffit qu'un mod l'ajoute
    /// ailleurs pour lever une NullReferenceException a chaque tick.
    /// </summary>
    [HarmonyPatch(typeof(Pawn_ScentTracker), "CompTick")]
    internal static class Patch_ScentTracker_CompTick
    {
        private static bool Prefix(Pawn_ScentTracker __instance)
        {
            return __instance.parent is Pawn;
        }
    }
}
