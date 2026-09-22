$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

$xmlFiles = @(Get-ChildItem Mod -Recurse -Filter *.xml)
foreach ($file in $xmlFiles) { $null = [xml](Get-Content -Raw $file.FullName) }
"XML syntax: $($xmlFiles.Count) files passed"

$tables = @{}
foreach ($language in @('English', 'French')) {
    [xml]$document = Get-Content -Raw "Mod/Languages/$language/Keyed/RimScentExtended.xml"
    $table = @{}
    foreach ($node in $document.LanguageData.ChildNodes | Where-Object NodeType -eq Element) {
        if ($table.ContainsKey($node.Name) -or [string]::IsNullOrWhiteSpace($node.InnerText)) {
            throw "Duplicate or empty $language Keyed key: $($node.Name)"
        }
        $table[$node.Name] = $node.InnerText
    }
    $tables[$language] = $table
}

$source = (Get-ChildItem Source -Recurse -Filter *.cs | Get-Content -Raw) -join "`n"
$keys = @([regex]::Matches($source, '"(RimScentExtended\.[^"]+)"\.Translate\(') |
    ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique)
foreach ($key in $keys) {
    foreach ($language in @('English', 'French')) {
        if (!$tables[$language].ContainsKey($key)) { throw "Missing $language Keyed key: $key" }
    }
    $englishParameters = @([regex]::Matches($tables.English[$key], '\{\d+\}') | ForEach-Object Value) -join ','
    $frenchParameters = @([regex]::Matches($tables.French[$key], '\{\d+\}') | ForEach-Object Value) -join ','
    if ($englishParameters -ne $frenchParameters) { throw "Parameter mismatch: $key" }
}
"Keyed: $($keys.Count) used keys covered in EN/FR with parameter parity"

foreach ($name in @('LICENSE', 'ATTRIBUTION.md')) {
    if ((Get-FileHash $name).Hash -ne (Get-FileHash "Mod/$name").Hash) { throw "Distribution copy mismatch: $name" }
    "$name distribution copy matches"
}

Add-Type -AssemblyName System.Drawing
foreach ($name in @('Preview', 'ModIcon')) {
    $file = Get-Item "Mod/About/$name.png"
    $image = [System.Drawing.Image]::FromFile($file.FullName)
    if ($name -eq 'Preview' -and $file.Length -ge 1MB) { throw 'Preview exceeds 1 MiB' }
    "${name}: $($image.Width)x$($image.Height), $($file.Length) bytes"
    $image.Dispose()
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
[xml]$french = Get-Content -Raw Mod/Languages/French/DefInjected/MainButtonDef/MainButtons_RimScentExtended.xml
foreach ($field in @('label', 'description')) {
    $node = $french.LanguageData.SelectSingleNode("RimScentExtended_Settings.$field")
    if ($null -eq $node -or [string]::IsNullOrWhiteSpace($node.InnerText)) { throw "Missing French shortcut $field" }
}
if (!(Test-Path Mod/Assemblies/RimScentExtended.dll)) { throw 'Delivered DLL is missing' }
"Metadata, dependency, hidden MainButtons shortcut, French injection, and delivered DLL: passed"
