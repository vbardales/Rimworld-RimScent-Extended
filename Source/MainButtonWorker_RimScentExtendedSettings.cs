using RimWorld;
using Verse;

namespace RimScentExtended
{
    /// <summary>
    /// Optional MainButtons shortcut. Its definition is hidden by default so RIMMSQOL and
    /// compatible customization mods may reveal it without changing the primary Mod options route.
    /// </summary>
    public class MainButtonWorker_RimScentExtendedSettings : MainButtonWorker
    {
        public override void Activate()
        {
            Find.WindowStack.Add(new Dialog_ModSettings(RimScentExtendedMod.Instance));
        }
    }
}
