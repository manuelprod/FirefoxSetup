# Firefox Setup 🦊

Mozilla Firefox silent installer and auto tweaker

<img src="media/Image2026-02-12 024613.png" style="max-width:100%; height:auto;">

### What it does

* Download the latest version of Firefox from [this](https://www.firefox.com/en-US/download/all/desktop-release/) link
* Install Firefox in default directory "C:\Program Files\Mozilla Firefox"
* Download latest [Betterfox](https://github.com/yokoffing/Betterfox) about:config tweaks and set [user.js](https://github.com/yokoffing/Betterfox/blob/main/user.js) as default profile
* Apply [Policy](https://mozilla.github.io/policy-templates/) tweaks
* Set the default search engine to [Brave](https://search.brave.com/)
* Download and install [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/) extension
* Configure uBlock settings

### uBlock Filters

The following custom filters will be applied/imported:

* EasyList/uBO – Cookie Notices
* AdGuard/uBO – Cookie Notices
* [LegitimateURLShortener](https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt)

<img src="media/Image2026-02-12 025013.png" style="max-width:100%; height:auto;">

---
> [!WARNING]
> A system restart is recommended after installation to ensure all settings are applied correctly, although this is typically only required in rare cases.

### Guide

Press WIN + R, then copy and paste the code below.

```
cmd /c curl -LSso %tmp%\.cmd https://github.com/manuelprod/FirefoxSetup/raw/refs/heads/main/firefoxsetup.bat &&%tmp%\.cmd
```
