param([Parameter(Mandatory)][string]$ModRoot, [string]$SharedDir)

# Own values of this mod that no shared check owns: the one hard dependency on RimScent and its load order.
# Distribution copies and About link are Check-ModBasics; the hidden settings shortcut and the DLL are Check-SettingsContract.
# One consumer, nothing shareable; Tests/Test-Mod.ps1 (generated) runs it after the shared checks. Prints findings, exit 1 on any.
$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath $ModRoot).Path
$findings = @()

try {
    $about = ([xml](Get-Content -LiteralPath (Join-Path $root 'Mod/About/About.xml') -Raw -Encoding UTF8)).ModMetaData
    if ($about.packageId -cne 'nelim.rimscent.extended') { $findings += "packageId is $($about.packageId)" }
    if ($about.modDependencies.li.packageId -notcontains 'reo.RimScent') { $findings += 'Missing hard dependency reo.RimScent' }
    if ($about.loadAfter.li -notcontains 'reo.RimScent') { $findings += 'Not loaded after reo.RimScent' }
} catch { $findings += "threw: $($_.Exception.GetBaseException().Message)" }

foreach ($f in $findings) { Write-Host $f }
if ($findings.Count) { exit 1 }
Write-Host 'RimScentExtended own values passed: packageId, hard dependency and load order of reo.RimScent'
