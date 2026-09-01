using System.Reflection;
using HarmonyLib;
using UnityEngine;
using Verse;

namespace RimScentExtended
{
    /// <summary>
    /// Correctifs pour RimScent (reo, ocarina0001, MIT). Le detail de chaque bug,
    /// avec les references de ligne en amont, est dans BUGS.md a la racine du mod.
    /// </summary>
    public class RimScentExtendedMod : Mod
    {
        public static RimScentExtendedSettings Settings;

        public RimScentExtendedMod(ModContentPack content) : base(content)
        {
            Settings = GetSettings<RimScentExtendedSettings>();
            new Harmony("nelim.rimscent.fr").PatchAll(Assembly.GetExecutingAssembly());
        }

        public override string SettingsCategory() => "RimScentExtended.Settings.Category".Translate();

        public override void DoSettingsWindowContents(Rect inRect)
        {
            Listing_Standard list = new Listing_Standard();
            list.Begin(inRect);

            list.CheckboxLabeled("RimScentExtended.Settings.Temperature".Translate(),
                ref Settings.temperatureEnabled, "RimScentExtended.Settings.TemperatureTip".Translate());

            list.GapLine();

            list.CheckboxLabeled("RimScentExtended.Settings.Adaptation".Translate(),
                ref Settings.adaptationEnabled, "RimScentExtended.Settings.AdaptationTip".Translate());

            if (Settings.adaptationEnabled)
            {
                list.Label("RimScentExtended.Settings.Floor".Translate(
                    Settings.adaptationFloor.ToStringPercent()));
                Settings.adaptationFloor = list.Slider(Settings.adaptationFloor, 0.05f, 1f);

                list.Label("RimScentExtended.Settings.Hours".Translate(
                    Settings.adaptationHours.ToString("0.0")));
                Settings.adaptationHours = list.Slider(Settings.adaptationHours, 0.5f, 12f);

                list.CheckboxLabeled("RimScentExtended.Settings.Pleasant".Translate(),
                    ref Settings.adaptToPleasant, "RimScentExtended.Settings.PleasantTip".Translate());
            }

            list.End();
        }

        public override void WriteSettings()
        {
            base.WriteSettings();
            // Les compteurs d'exposition sont calibres sur les reglages : les garder apres
            // un changement donnerait des facteurs incoherents pendant deux heures de jeu.
            ScentAdaptation.Clear();
        }
    }
}
