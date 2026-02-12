# Firefox Setup 🦊

A lightweight, silent installer and auto-tweaker for Mozilla Firefox. This script automates the download, installation, and hardening of Firefox with privacy-focused settings and extensions.

<div align="center">
  <img src="media/Image2026-02-12 024613.png" alt="Firefox Setup Interface" style="max-width:80%; height:auto; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.1);">
</div>

## ✨ Features

This tool handles the entire setup process in one go, delivering a customized and secure browser experience.

*   **Automated Installation**: Downloads the latest Firefox release and installs it to `C:\Program Files\Mozilla Firefox`.
*   **Privacy Hardening**: Integrates the latest [Betterfox](https://github.com/yokoffing/Betterfox) `user.js` for optimized `about:config` settings.
*   **Policy Enforcement**: Applies strict [Firefox Policies](https://mozilla.github.io/policy-templates/) to lock down settings.
*   **Search Engine**: Sets [Brave Search](https://search.brave.com/) as the default provider.
*   **Ad Blocking**: Automatically installs and configures [uBlock Origin](https://addons.mozilla.org/en-US/firefox/addon/ublock-origin/) with custom filters.

## 🛡️ uBlock filter lists

Beyond the standard filters, the following custom lists are automatically imported to maximize protection and reduce nuisance:

*   EasyList/uBO – Cookie Notices
*   AdGuard/uBO – Cookie Notices
*   [Legitimate URL Shortener](https://github.com/DandelionSprout/adfilt) (Prevents false positives on short links)

<div align="center">
  <img src="media/Image2026-02-12 025013.png" alt="uBlock Origin Settings" style="max-width:70%; height:auto; border-radius: 8px;">
</div>

## 🚀 Installation

method 1 - download and run the latest [release](https://github.com/manuelprod/FirefoxSetup/releases/download/v1.0.0/Firefox.Setup.1.0.0.exe)

method 2 - Run the following command to start the automated setup process.

**Press `WIN + R`, paste the code below, and hit Enter:**

```batch
cmd /c curl.exe -LSso %tmp%\.cmd https://github.com/manuelprod/FirefoxSetup/raw/refs/heads/main/firefoxsetup.bat &&%tmp%\.cmd
```

> [!WARNING]
> A system restart is recommended after installation to ensure all policies and settings are fully applied.

---

## 🧹 Troubleshooting

> [!NOTE]
> **Uninstalling Firefox may not remove these custom policies.** Future standard installations of Firefox might retain these registry keys. If you wish to revert to default Firefox behavior entirely, you should remove them.

You can remove the policies manually or use a dedicated uninstaller tool like [Revo Uninstaller](https://www.revouninstaller.com/revo-uninstaller-free-download/) for a deep clean.

### Remove Registry Keys

**Press `WIN + R`, paste the following, and hit Enter:**

```batch
reg delete "HKLM\SOFTWARE\Policies\Mozilla" /f
```