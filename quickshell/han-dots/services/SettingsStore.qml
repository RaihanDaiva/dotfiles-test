import QtQuick
import Quickshell
import Quickshell.Io
// ⚙️ CENTRAL SETTINGS STORE (Singleton Manajer Pengaturan UI)
// Menyimpan state pengaturan dan menyimpannya secara persisten ke ~/.config/quickshell/settings.json
pragma Singleton

Item {
    id: store

    // 🪟 1. POPUP SETTINGS
    property real popupOpacity: 0.94
    property int popupRadius: 18
    property int popupBorderWidth: 1
    property bool enableBlur: true
    property bool settingsPopupOpen: false
    // 🎨 2. THEME SETTINGS
    property bool isDarkMode: true
    // 🎵 4. MEDIA PLAYER POPUP SETTINGS
    property bool mediaBlurBgEnabled: true
    property string mediaPlayerStyle: "classic" // "classic" (full) or "minimalist" (compact)
    // 🔘 5. BUTTON & PILL STYLE SETTINGS
    property string buttonStyle: "solid"
    property int buttonRadius: 8
    property string quickSettingsStyle: "android" // "android" or "macos"
    property string pillStyle: "solid"
    // 🏛️ 6. STATUS BAR SETTINGS
    property real barOpacity: 0.65
    property bool barBlurEnabled: true
    property bool barBgEnabled: true
    property string barStyle: "unified" // "unified" (single bar) or "islands" (3 separate cards)
    // ⛵ 7. DOCK SETTINGS
    property bool dockEnabled: true
    property string dockMode: "always_visible" // "always_visible", "auto_hide", or "overlay"
    property bool dockBlurEnabled: true
    // 💾 FILE PATH UNTUK PERSISTENSI SETTINGS
    readonly property string configFile: Quickshell.env("HOME") + "/.config/quickshell/settings.json"
    // 🔒 FLAG UNTUK MENCEGAH OVERWRITE SETTINGS SAAT BOOT
    property bool _isLoaded: false

    // 📤 SAVE SETTINGS TO JSON FILE
    function saveSettings() {
        if (!store._isLoaded)
            return ;

        var obj = {
            "popupOpacity": store.popupOpacity,
            "popupRadius": store.popupRadius,
            "popupBorderWidth": store.popupBorderWidth,
            "enableBlur": store.enableBlur,
            "settingsPopupOpen": store.settingsPopupOpen,
            "isDarkMode": store.isDarkMode,
            "mediaBlurBgEnabled": store.mediaBlurBgEnabled,
            "mediaPlayerStyle": store.mediaPlayerStyle,
            "buttonStyle": store.buttonStyle,
            "buttonRadius": store.buttonRadius,
            "quickSettingsStyle": store.quickSettingsStyle,
            "pillStyle": store.pillStyle,
            "barOpacity": store.barOpacity,
            "barBlurEnabled": store.barBlurEnabled,
            "barBgEnabled": store.barBgEnabled,
            "barStyle": store.barStyle,
            "dockEnabled": store.dockEnabled,
            "dockMode": store.dockMode,
            "dockBlurEnabled": store.dockBlurEnabled
        };
        var jsonStr = JSON.stringify(obj, null, 2);
        var safeStr = jsonStr.replace(/'/g, "'\\''");
        var saveCmd = "mkdir -p ~/.config/quickshell && echo '" + safeStr + "' > " + store.configFile;
        saveProc.command = ["bash", "-c", saveCmd];
        saveProc.running = false;
        saveProc.running = true;
    }

    function updateNiriBarBlur() {
        saveSettings();
        if (!store._isLoaded)
            return ;

        var isBlurOn = store.barBgEnabled && store.barBlurEnabled;
        var targetVal = isBlurOn ? "true" : "false";
        var blurCmd = "sed -i '/match namespace=\"quickshell:bar/,/}/s/blur .*/blur " + targetVal + "/' ~/.config/niri/config.d/90-user-extra.kdl 2>/dev/null; [ -f ~/dotfiles-test/niri/config.d/90-user-extra.kdl ] && sed -i '/match namespace=\"quickshell:bar/,/}/s/blur .*/blur " + targetVal + "/' ~/dotfiles-test/niri/config.d/90-user-extra.kdl 2>/dev/null; niri msg action load-config-file 2>/dev/null";
        niriBlurProc.command = ["bash", "-c", blurCmd];
        niriBlurProc.running = false;
        niriBlurProc.running = true;
    }

    onPopupOpacityChanged: saveSettings()
    onPopupRadiusChanged: saveSettings()
    onPopupBorderWidthChanged: saveSettings()
    onEnableBlurChanged: saveSettings()
    onSettingsPopupOpenChanged: saveSettings()
    onIsDarkModeChanged: saveSettings()
    onMediaBlurBgEnabledChanged: saveSettings()
    onMediaPlayerStyleChanged: saveSettings()
    onButtonStyleChanged: saveSettings()
    onButtonRadiusChanged: saveSettings()
    onQuickSettingsStyleChanged: saveSettings()
    onPillStyleChanged: saveSettings()
    onBarOpacityChanged: saveSettings()
    onBarStyleChanged: saveSettings()
    onBarBgEnabledChanged: {
        if (!barBgEnabled)
            barStyle = "unified";

        updateNiriBarBlur();
    }
    onDockEnabledChanged: saveSettings()
    onDockModeChanged: saveSettings()
    onBarBlurEnabledChanged: updateNiriBarBlur()
    onDockBlurEnabledChanged: {
        saveSettings();
        if (!store._isLoaded)
            return ;

        var targetVal = store.dockBlurEnabled ? "true" : "false";
        var blurCmd = "sed -i '/match namespace=\"quickshell:dock\"/,/}/s/blur .*/blur " + targetVal + "/' ~/.config/niri/config.d/90-user-extra.kdl 2>/dev/null; [ -f ~/dotfiles-test/niri/config.d/90-user-extra.kdl ] && sed -i '/match namespace=\"quickshell:dock\"/,/}/s/blur .*/blur " + targetVal + "/' ~/dotfiles-test/niri/config.d/90-user-extra.kdl 2>/dev/null; niri msg action load-config-file 2>/dev/null";
        niriBlurProc.command = ["bash", "-c", blurCmd];
        niriBlurProc.running = false;
        niriBlurProc.running = true;
    }

    Process {
        id: niriBlurProc
    }

    // 📥 LOAD SETTINGS FROM JSON AT STARTUP
    Process {
        id: loadProc

        command: ["cat", store.configFile]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var content = this.text.trim();
                if (content.length > 0) {
                    try {
                        var cfg = JSON.parse(content);
                        if (cfg.popupOpacity !== undefined)
                            store.popupOpacity = cfg.popupOpacity;

                        if (cfg.popupRadius !== undefined)
                            store.popupRadius = cfg.popupRadius;

                        if (cfg.popupBorderWidth !== undefined)
                            store.popupBorderWidth = cfg.popupBorderWidth;

                        if (cfg.enableBlur !== undefined)
                            store.enableBlur = cfg.enableBlur;

                        if (cfg.isDarkMode !== undefined)
                            store.isDarkMode = cfg.isDarkMode;

                        if (cfg.mediaBlurBgEnabled !== undefined)
                            store.mediaBlurBgEnabled = cfg.mediaBlurBgEnabled;

                        if (cfg.mediaPlayerStyle !== undefined)
                            store.mediaPlayerStyle = cfg.mediaPlayerStyle;

                        if (cfg.buttonStyle !== undefined)
                            store.buttonStyle = cfg.buttonStyle;

                        if (cfg.buttonRadius !== undefined)
                            store.buttonRadius = cfg.buttonRadius;

                        if (cfg.quickSettingsStyle !== undefined)
                            store.quickSettingsStyle = cfg.quickSettingsStyle;

                        if (cfg.pillStyle !== undefined)
                            store.pillStyle = cfg.pillStyle;

                        if (cfg.barOpacity !== undefined)
                            store.barOpacity = cfg.barOpacity;

                        if (cfg.barBlurEnabled !== undefined)
                            store.barBlurEnabled = cfg.barBlurEnabled;

                        if (cfg.barBgEnabled !== undefined)
                            store.barBgEnabled = cfg.barBgEnabled;

                        if (cfg.barStyle !== undefined)
                            store.barStyle = cfg.barStyle;

                        if (cfg.dockEnabled !== undefined)
                            store.dockEnabled = cfg.dockEnabled;

                        if (cfg.dockMode !== undefined)
                            store.dockMode = cfg.dockMode;

                        if (cfg.dockBlurEnabled !== undefined)
                            store.dockBlurEnabled = cfg.dockBlurEnabled;

                    } catch (e) {
                        console.log("Failed to parse settings.json: " + e);
                    }
                }
                store._isLoaded = true;
            }
        }

    }

    Process {
        id: saveProc
    }

}
