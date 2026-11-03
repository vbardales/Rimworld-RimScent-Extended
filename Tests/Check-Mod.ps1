# Mod-specific contracts only. XML syntax, Keyed/DefInjected coverage and images are checked by
# ../scripts/Check-ModBasics.ps1 and ../scripts/Check-Translations.ps1.
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

foreach ($name in @('LICENSE', 'ATTRIBUTION.md')) {
    if ((Get-FileHash $name).Hash -ne (Get-FileHash "Mod/$name").Hash) { throw "Distribution copy mismatch: $name" }
}

[xml]$about = Get-Content -Raw Mod/About/About.xml
$repositoryLink = '[url=https://github.com/vbardales/Rimworld-RimScent-Extended]Source code on GitHub[/url]'
if (!$about.ModMetaData.description.Trim().EndsWith($repositoryLink)) { throw 'Missing final repository link' }
if ($about.ModMetaData.url -ne 'https://github.com/vbardales/Rimworld-RimScent-Extended') { throw 'Repository URL mismatch' }
if ($about.ModMetaData.modDependencies.li.packageId -notcontains 'reo.RimScent') { throw 'Missing RimScent dependency' }

[xml]$buttons = Get-Content -Raw Mod/Defs/MainButtons_RimScentExtended.xml
$button = $buttons.Defs.MainButtonDef
if ($button.defName -ne 'RimScentExtended_Settings' -or $button.buttonVisible -ne 'false' -or
    $button.workerClass -ne 'RimScentExtended.MainButtonWorker_RimScentExtendedSettings') {
    throw 'MainButtons shortcut contract mismatch'
}
if (!(Test-Path Mod/Assemblies/RimScentExtended.dll)) { throw 'Delivered DLL is missing' }
'RimScentExtended contracts passed: distribution copies, About link/URL/dependency, hidden MainButtons shortcut, DLL present'
