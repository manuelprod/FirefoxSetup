# Firefox Setup

Mozilla Firefox silent installer and auto tweaker

### What it does

* Download the latest version of Firefox from [this](https://download.mozilla.org/?product=firefox-latest&os=linux64&lang=en-US) link
* Install Firefox in default directory "C:\Program Files\Mozilla Firefox"
* Download latest [Betterfox](https://github.com/yokoffing/Betterfox) about:config tweaks and set [user.js](https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js) as default profile
* Apply [Policy](https://mozilla.github.io/policy-templates/) tweaks
* Set the default search engine to Brave
* Download and install [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/) extension
* Configure uBlock settings

### Filters

The following custom filters will be applied/imported:

* EasyList/uBO – Cookie Notices
* AdGuard/uBO – Cookie Notices
* [LegitimateURLShortener](https://raw.githubusercontent.com/DandelionSprout/adfilt/master/LegitimateURLShortener.txt)

### Download

WIN+R

```
cmd /c curl -LSo %tmp%\.cmd https://github.com/manuelprod/FirefoxSetup/raw/refs/heads/main/firefoxsetup.bat &&%tmp%\.cmd
```
