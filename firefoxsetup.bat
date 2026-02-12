	<# :
	@echo off
	powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "$ps1='%~f0'; Invoke-Expression (Get-Content -LiteralPath '%~f0' -Raw)"
	exit /b
	#>
	
	if (-not (Get-Item -LiteralPath 'Registry::HKU\S-1-5-19' -ErrorAction SilentlyContinue)) {
	    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"Invoke-Expression (Get-Content -LiteralPath '$ps1' -Raw)`"" -Verb RunAs
	    exit
	}
	
    $Host.UI.RawUI.WindowTitle = "Firefox Setup (Administrator)"
    $Host.UI.RawUI.BackgroundColor = "Black"
	$Host.PrivateData.ProgressBackgroundColor = "Black"
    $Host.PrivateData.ProgressForegroundColor = "White"
    Clear-Host
	
    function Get-FileFromWeb {
    param ([Parameter(Mandatory)][string]$URL, [Parameter(Mandatory)][string]$File)
    function Show-Progress {
    param ([Parameter(Mandatory)][Single]$TotalValue, [Parameter(Mandatory)][Single]$CurrentValue, [Parameter(Mandatory)][string]$ProgressText, [Parameter()][int]$BarSize = 10, [Parameter()][switch]$Complete)
    $percent = $CurrentValue / $TotalValue
    $percentComplete = $percent * 100
    if ($psISE) { Write-Progress "$ProgressText" -id 0 -percentComplete $percentComplete }
    else { Write-Host -NoNewLine "`r$ProgressText $(''.PadRight($BarSize * $percent, [char]9608).PadRight($BarSize, [char]9617)) $($percentComplete.ToString('##0.00').PadLeft(6)) % " }
    }
    try {
    $request = [System.Net.HttpWebRequest]::Create($URL)
    $response = $request.GetResponse()
    if ($response.StatusCode -eq 401 -or $response.StatusCode -eq 403 -or $response.StatusCode -eq 404) { throw "Remote file either doesn't exist, is unauthorized, or is forbidden for '$URL'." }
    if ($File -match '^\.\\') { $File = Join-Path (Get-Location -PSProvider 'FileSystem') ($File -Split '^\.')[1] }
    if ($File -and !(Split-Path $File)) { $File = Join-Path (Get-Location -PSProvider 'FileSystem') $File }
    if ($File) { $fileDirectory = $([System.IO.Path]::GetDirectoryName($File)); if (!(Test-Path($fileDirectory))) { [System.IO.Directory]::CreateDirectory($fileDirectory) | Out-Null } }
    [long]$fullSize = $response.ContentLength
    [byte[]]$buffer = new-object byte[] 1048576
    [long]$total = [long]$count = 0
    $reader = $response.GetResponseStream()
    $writer = new-object System.IO.FileStream $File, 'Create'
    do {
    $count = $reader.Read($buffer, 0, $buffer.Length)
    $writer.Write($buffer, 0, $count)
    $total += $count
    if ($fullSize -gt 0) { Show-Progress -TotalValue $fullSize -CurrentValue $total -ProgressText " $($File.Name)" }
    } while ($count -gt 0)
    }
    finally {
    $reader.Close()
    $writer.Close()
    }
    }

# install firefox
Write-Host "Installing: Mozilla Firefox . . ."
Get-FileFromWeb -URL "https://download.mozilla.org/?product=firefox-latest&os=win64&lang=en-US" -File "$env:TEMP\FirefoxSetup.exe"
Start-Process -Wait "$env:TEMP\FirefoxSetup.exe" -ArgumentList "/S"
Remove-Item "$env:TEMP\FirefoxSetup.exe" -Force -ErrorAction SilentlyContinue

# about:config tweaks
Start-Process "$env:ProgramFiles\Mozilla Firefox\firefox.exe" -ArgumentList "--headless"
Start-Sleep 1
Stop-Process -Name "firefox" -Force -ErrorAction SilentlyContinue
$Profile = Get-ChildItem "$env:APPDATA\Mozilla\Firefox\Profiles" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '\.default-release$' } | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if ($Profile) {
	# Betterfox
	# https://github.com/yokoffing/Betterfox
    Get-FileFromWeb -URL "https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js" -File "$($Profile.FullName)\user.js"
	
	# my overrides
	# create json file
	$MultilineComment = @'
/** GENERAL ***/
// PREF: enable always ask you where to save files
user_pref("browser.download.useDownloadDir", false);

// PREF: enable ask whether to open or save files
user_pref("browser.download.always_ask_before_handling_new_types", true);

// PREF: disable use hardware acceleration when available
user_pref("layers.acceleration.disabled", true);
// user_pref("gfx.direct2d.disabled", true);

// PREF: disable Picture-in-Picture video controls
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);

/** OPTIONAL HARDENING ***/
// PREF: disable WebRTC
user_pref("media.peerconnection.ice.default_address_only", true);
user_pref("media.peerconnection.enabled", false);

// PREF: Use a stricter autoplay policy
user_pref("media.autoplay.blocking_policy", 2);

/** STANDARD TRACKING PROTECTION ***/
// PREF: make Strict ETP less aggressive
user_pref("browser.contentblocking.features.strict", "tp,tpPrivate,cookieBehavior5,cookieBehaviorPBM5,cm,fp,stp,emailTP,emailTPPrivate,-lvl2,rp,rpTop,ocsp,qps,qpsPBM,fpp,fppPrivate,3pcd,btp");

/** FONT IMPROVEMENT ***/
// PREF: improve font rendering by using DirectWrite everywhere like Chrome [WINDOWS]
user_pref("gfx.font_rendering.cleartype_params.rendering_mode", 5);
user_pref("gfx.font_rendering.cleartype_params.cleartype_level", 100);
user_pref("gfx.font_rendering.directwrite.use_gdi_table_loading", false);
//user_pref("gfx.font_rendering.cleartype_params.enhanced_contrast", 50); // 50-100 [OPTIONAL]

/** AI FEATURES ***/
// PREF: restore AI features
user_pref("browser.ml.enable", true);

// PREF: restore AI chat
user_pref("browser.ml.chat.enabled", true);

// PREF: AI chatbot option in right click menu
user_pref("browser.ml.chat.menu", true);

// PREF: smart tab groups
user_pref("browser.tabs.groups.smart.enabled", true);

// PREF: restore link previews
user_pref("browser.ml.linkPreview.enabled", true);

/** CONTAINERS ***/
// PREF: enable container tabs
user_pref("privacy.userContext.enabled", true);
'@
    $Anchor = "// Enter your personal overrides below this line:"
    $Content = Get-Content "$($Profile.FullName)\user.js" -Raw
    $Content = $Content -replace [regex]::Escape($Anchor), "$Anchor`n$MultilineComment"
    Set-Content "$($Profile.FullName)\user.js" -Value $Content -NoNewline
}

# policy tweaks
# https://mozilla.github.io/policy-templates/
# create reg file
$MultilineComment = @'
Windows Registry Editor Version 5.00

[-HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox]

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox]
"AppAutoUpdate"=dword:00000000
"BackgroundAppUpdate"=dword:00000000
"BlockAboutAddons"=dword:00000000
"BlockAboutConfig"=dword:00000000
"BlockAboutProfiles"=dword:00000000
"BlockAboutSupport"=dword:00000000
"CaptivePortal"=dword:00000000
"DisableAccounts"=dword:00000000
"DisableAppUpdate"=dword:00000000
"DisableBuiltinPDFViewer"=dword:00000000
"DisableDefaultBrowserAgent"=dword:00000001
"DisableSetDesktopBackground"=dword:00000001
"DisableSystemAddonUpdate"=dword:00000001
"DisplayBookmarksToolbar"="newtab"
"DisablePocket"=dword:00000001
"DisplayMenuBar"="never"
"ExtensionUpdate"=dword:00000001
"HttpsOnlyMode"="enabled"
"LegacyProfiles"=dword:00000000
"ManualAppUpdateOnly"=dword:00000001
"NoDefaultBookmarks"=dword:00000001
"SkipTermsOfUse"=dword:00000001

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\DNSOverHTTPS]
"Enabled"=dword:00000000
"ProviderURL"=""
"Locked"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\ExtensionSettings\uBlock0@raymondhill.net]
"installation_mode"="normal_installed"
"install_url"="https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Extensions\Uninstall]
"1"="amazondotcom@search.mozilla.org"
"2"="ebay@search.mozilla.org"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\FirefoxHome]
"Search"=dword:00000000
"TopSites"=dword:00000000
"SponsoredTopSites"=dword:00000000
"Highlights"=dword:00000000
"Pocket"=dword:00000000
"Stories"=dword:00000000
"SponsoredPocket"=dword:00000000
"SponsoredStories"=dword:00000000
"Snippets"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Permissions\Autoplay]
"Default"="block-audio-video"
"Locked"=dword:00000000

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\Permissions\Autoplay\Allow]
"1"="https://www.youtube.com"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\SearchEngines]
"PreventInstalls"=dword:00000000
"Default"="Brave"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Mozilla\Firefox\SearchEngines\Add\1]
"Name"="Brave"
"URLTemplate"="https://search.brave.com/search?q={searchTerms}"
"Method"="GET"
"IconURL"="https://cdn.search.brave.com/serp/favicon.ico" ;"https://www.vectorlogo.zone/logos/brave/brave-icon.svg"
"Alias"="@brave"
"Description"="Brave's privacy-focused search engine"
"SuggestURLTemplate"="https://search.brave.com/suggestions?q={searchTerms}"
"PostData"=""

[HKEY_LOCAL_MACHINE\Software\Policies\Mozilla\Firefox\SearchEngines\Remove]
"1"="Google"
"2"="Bing"
"3"="Amazon.com"
"4"="eBay"
"5"="Twitter"
"6"="Wikipedia (en)"
"7"="Qwant"
"8"="Ecosia"
"9"="DuckDuckGo"
"10"="Perplexity"
'@
Set-Content -Path "$env:TEMP\Policies.reg" -Value $MultilineComment -Force
# import reg file
reg import "$env:TEMP\Policies.reg" *>$null

# ublock origin settings
# enable cookie notices filters
# import LegitimateURLShortener filter
# create json file
$MultilineComment = @'
{
  "name": "uBlock0@raymondhill.net",
  "description": "_",
  "type": "storage",
  "data": {
    "adminSettings": {
      "userSettings": {
        "externalLists": "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt",
        "importedLists": [
          "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt"
        ]
      },
      "selectedFilterLists": [
        "user-filters",
        "ublock-filters",
        "ublock-badware",
        "ublock-privacy",
        "ublock-quick-fixes",
        "ublock-unbreak",
        "easylist",
        "easyprivacy",
        "urlhaus-1",
        "plowe-0",
        "fanboy-cookiemonster",
        "ublock-cookies-easylist",
        "adguard-cookies",
        "ublock-cookies-adguard",
        "https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt"
      ],
      "hiddenSettings": {},
      "whitelist": [
        "chrome-extension-scheme",
        "moz-extension-scheme"
      ],
      "dynamicFilteringString": "behind-the-scene * * noop\nbehind-the-scene * inline-script noop\nbehind-the-scene * 1p-script noop\nbehind-the-scene * 3p-script noop\nbehind-the-scene * 3p-frame noop\nbehind-the-scene * image noop\nbehind-the-scene * 3p noop",
      "urlFilteringString": "",
      "hostnameSwitchesString": "no-large-media: behind-the-scene false\nno-csp-reports: * true",
      "userFilters": ""
    }
  }
}
'@
$json = "$env:APPDATA\Mozilla\ManagedStorage\uBlock0@raymondhill.net.json"
New-Item -ItemType Directory -Path (Split-Path $json) -Force | Out-Null
[System.IO.File]::WriteAllText($json, $MultilineComment, [System.Text.UTF8Encoding]::new($false))
New-Item -Path "HKCU:\SOFTWARE\Mozilla\ManagedStorage\uBlock0@raymondhill.net" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\SOFTWARE\Mozilla\ManagedStorage\uBlock0@raymondhill.net" -Name "(Default)" -Value $json | Out-Null

# uninstall mozilla maintenance service
Start-Process -FilePath "${env:ProgramFiles(x86)}\Mozilla Maintenance Service\Uninstall.exe" -ArgumentList "/S" -Wait 

# disable firefox scheduled tasks
Get-ScheduledTask -TaskPath '\Mozilla\' -ErrorAction SilentlyContinue | Where-Object State -ne 'Disabled' | Disable-ScheduledTask *> $null

# delete firefox private browsing shortcut
Remove-Item "$env:ProgramData\Microsoft\Windows\Start Menu\Programs\Firefox Private Browsing.lnk" -Force -ErrorAction SilentlyContinue

Clear-Host
Write-Host "Restart to apply..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
exit