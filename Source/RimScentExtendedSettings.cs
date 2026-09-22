using UnityEngine;
using Verse;

namespace RimScentExtended
{
    public class RimScentExtendedSettings : ModSettings
    {
        /// <summary>Accoutumance olfactive : une odeur constante finit par ne plus se remarquer.</summary>
        public bool adaptationEnabled = true;

        /// <summary>
        /// Part de l'odeur qui subsiste une fois l'accoutumance complete. Jamais zero :
        /// on ne cesse jamais totalement de sentir, et une odeur qui disparaitrait
        /// ferait clignoter la pensee.
        /// </summary>
        public float adaptationFloor = 0.5f;

        /// <summary>Duree d'exposition continue, en heures de jeu, pour atteindre ce plancher.</summary>
        public float adaptationHours = 2.5f;

        /// <summary>
        /// Si faux, seules les odeurs desagreables s'estompent. Physiologiquement faux -
        /// on s'habitue aussi bien a son parfum qu'a son fumier - mais ca preserve les
        /// bonus de l'encens et des parfums pour qui les a construits pour ca.
        /// </summary>
        public bool adaptToPleasant = true;

        /// <summary>La temperature ambiante amplifie ou attenue les odeurs.</summary>
        public bool temperatureEnabled = true;

        public int AdaptationTicks => Mathf.Max(1, Mathf.RoundToInt(adaptationHours * 2500f));

        public override void ExposeData()
        {
            Scribe_Values.Look(ref adaptationEnabled, "adaptationEnabled", true);
            Scribe_Values.Look(ref adaptationFloor, "adaptationFloor", 0.5f);
            Scribe_Values.Look(ref adaptationHours, "adaptationHours", 2.5f);
            Scribe_Values.Look(ref adaptToPleasant, "adaptToPleasant", true);
            Scribe_Values.Look(ref temperatureEnabled, "temperatureEnabled", true);
            base.ExposeData();
        }
    }
}
