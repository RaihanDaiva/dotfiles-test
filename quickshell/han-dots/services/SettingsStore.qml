import QtQuick
import Quickshell
import Quickshell.Io
// ⚙️ CENTRAL SETTINGS STORE SINGLETON
pragma Singleton

Item {
    // "solid" or "glass"

    id: store

    // 🪟 1. GLOBAL POPUP SETTINGS
    property real popupOpacity: 0.96
    property int popupRadius: 18
    property int popupBorderWidth: 1
    property bool enableBlur: true
    // ⚙️ 2. SETTINGS POPUP STATE
    property bool settingsPopupOpen: false
    // 🎨 3. THEME MODE SETTINGS
    property bool isDarkMode: true
    // 🎵 4. MEDIA PLAYER POPUP SETTINGS
    property bool mediaBlurBgEnabled: true
    property string mediaPlayerStyle: "classic" // "classic" (full) or "minimalist" (compact)
    // 🔘 5. BUTTON & PILL STYLE SETTINGS
    property string buttonStyle: "solid"
    property int buttonRadius: 8
    property string quickSettingsStyle: "android" // "android" or "macos"
    property string pillStyle: "solid"
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
            "pillStyle": store.pillStyle
        };
        var jsonStr = JSON.stringify(obj, null, 2);
        var safeStr = jsonStr.replace(/'/g, "'\\''");
        var saveCmd = "mkdir -p ~/.config/quickshell && echo '" + safeStr + "' > " + store.configFile;
        saveProc.command = ["bash", "-c", saveCmd];
        saveProc.running = false;
        saveProc.running = true;
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

    // 📥 LOAD SETTINGS FROM JSON AT STARTUP
    Process {
        id: loadProc

        command: ["cat", store.configFile]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                var content = this.text.trim();
                if (content !== "") {
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

                        if (cfg.settingsPopupOpen !== undefined)
                            store.settingsPopupOpen = cfg.settingsPopupOpen;

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
