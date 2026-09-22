using System.Linq;
using RimWorld;
using RimWorks.Pickle;
using Verse;

namespace RimScentExtended.PickleSteps
{
    [PickleSteps]
    public class MainButtonSteps
    {
        private static MainButtonDef Button(PickleContext context, string defName)
        {
            MainButtonDef button = DefDatabase<MainButtonDef>.GetNamedSilentFail(defName);
            context.Require(button != null, $"No MainButtonDef named '{defName}' is loaded.");
            return button;
        }

        [Then("RimScent Extended MainButtonDef {string} is hidden by default")]
        public void IsHidden(PickleContext context, string defName)
        {
            MainButtonDef button = Button(context, defName);
            context.Assert(!button.buttonVisible,
                $"{defName}.buttonVisible is true; the shortcut must be hidden until a customization mod reveals it.");
            context.Assert(!button.Worker.Disabled,
                $"{defName} is disabled; a revealed shortcut must not be greyed out.");
        }

        [When("RimScent Extended activates the MainButtonDef {string}")]
        public void Activate(PickleContext context, string defName)
        {
            MainButtonDef button = Button(context, defName);
            context.Require(button.Worker != null, $"{defName} has no worker.");
            button.Worker.Activate();
        }

        [Then("RimScent Extended sees its settings dialog open")]
        public void SettingsDialog(PickleContext context)
        {
            Window dialog = Find.WindowStack.Windows.FirstOrDefault(window => window is Dialog_ModSettings);
            context.Require(dialog != null, "No Dialog_ModSettings is open.");
            var modField = dialog.GetType().GetFields(System.Reflection.BindingFlags.Instance |
                System.Reflection.BindingFlags.Public | System.Reflection.BindingFlags.NonPublic)
                .FirstOrDefault(field => typeof(Mod).IsAssignableFrom(field.FieldType));
            context.Require(modField != null, "Dialog_ModSettings exposes no Mod field.");
            Mod owner = modField.GetValue(dialog) as Mod;
            context.Assert(owner == RimScentExtendedMod.Instance,
                "The MainButtons shortcut opened another mod's settings dialog.");
        }
    }
}
