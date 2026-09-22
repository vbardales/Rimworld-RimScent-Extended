using RimWorld;
using Verse;

namespace RimScentExtended
{
    /// <summary>
    /// Odeur portee par le sol lui-meme.
    ///
    /// RimScent ne lit que le thingGrid : des objets poses sur des cases. Le terrain
    /// n'est pas un objet - l'eau, la vase, le sable, la glace n'ont pas de ThingDef -
    /// donc rien de ce qui fait l'odeur d'un lieu n'etait accessible. Cette extension se
    /// pose sur un TerrainDef et ScentScan lit la grille de terrain sur les memes cases
    /// qu'il parcourt deja : un acces indexe, aucun cout de parcours supplementaire.
    ///
    /// L'odeur est comptee par case, et non une fois pour toutes. C'est voulu : trois
    /// cases d'eau au bord d'un ruisseau ne sentent pas comme un marecage a perte de
    /// vue, et le stackLimit de la ThoughtDef plafonne le total. Le nombre de cases est
    /// donc une mesure de « combien il y en a autour de toi », gratuitement.
    ///
    /// <see cref="aboveTemperature"/> conditionne l'odeur a la temperature ambiante.
    /// La vase ne sent qu'a la chaleur : en dessous du seuil, la case ne compte pas du
    /// tout. C'est distinct du facteur de temperature global du socle, qui attenue ou
    /// amplifie une odeur deja presente ; ici l'odeur n'existe pas.
    /// </summary>
    public class ModExtension_TerrainScent : DefModExtension
    {
        public ThoughtDef thought;

        /// <summary>
        /// Seuil en degres Celsius. NaN (la valeur par defaut si le champ est absent du
        /// XML) signifie « aucune condition », ce qui est le cas courant.
        /// </summary>
        public float aboveTemperature = float.NaN;

        public bool AppliesAt(float celsius)
        {
            if (thought == null) return false;
            return float.IsNaN(aboveTemperature) || celsius >= aboveTemperature;
        }
    }
}
