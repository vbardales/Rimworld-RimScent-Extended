using Verse;

namespace RimScentExtended
{
    /// <summary>
    /// Se pose sur un ThingDef diffuseur, a cote de RimScentReworked.ModExtension_Scent :
    /// celle-ci porte l'humeur, celle-la l'effet physiologique.
    ///
    /// Le cadre RimScent ne sait appliquer qu'une ThoughtDef. Le hediff est donc pose par
    /// ScentScan, qui parcourt deja les cellules et connait deja les filtres (combustible,
    /// courant, interrupteur, piece, ligne de vue) : rien a dupliquer.
    /// </summary>
    public class ModExtension_ScentHediff : DefModExtension
    {
        public HediffDef hediff;
    }
}
