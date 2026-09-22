using RimWorld;
using Verse;

namespace RimScentExtended
{
    /// <summary>
    /// Odeur portee par un pion lui-meme, et non par un objet ou un hediff.
    ///
    /// RimScent ne lit sur un pion voisin que ses HediffDef : le ThingDef de race n'est
    /// jamais consulte, donc un animal ne peut pas sentir en l'etat. Cette extension se
    /// pose sur le ThingDef de race et ScentScan s'en charge.
    ///
    /// <see cref="aboveStat"/> permet de conditionner l'odeur a une statistique du pion.
    /// Pour le betail on vise FilthRate >= 4, le seuil exact de Alert_AnimalFilth en
    /// vanilla : l'animal sent quand le jeu lui-meme le juge assez sale pour alerter.
    /// Housebroken, qui multiplie FilthRate par la proprete de l'animal, fait donc
    /// taire l'odeur en meme temps que l'alerte, sans qu'aucun des deux mods ait a
    /// connaitre l'autre.
    /// </summary>
    public class ModExtension_PawnScent : DefModExtension
    {
        public ThoughtDef thought;
        public StatDef aboveStat;
        public float aboveValue;

        public bool AppliesTo(Pawn pawn)
        {
            if (thought == null) return false;
            if (aboveStat == null) return true;
            return pawn.GetStatValue(aboveStat) >= aboveValue;
        }
    }
}
