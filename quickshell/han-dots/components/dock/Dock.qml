import "../../services"
import "../../theme"
import "../../widgets"
import "../popups/"
import "./dockStyle"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// ⛵ APPLICATION DOCK SURFACE (Centralized Scope Controller with Dynamic Style Loader)
Scope {
    id: dockScope

    required property var screen
    // 🖥️ DETEKSI COMPOSITOR
    readonly property bool isNiri: {
        var sock = Quickshell.env("NIRI_SOCKET") || "";
        var desk = Quickshell.env("XDG_CURRENT_DESKTOP") || "";
        return sock !== "" || desk.toLowerCase().indexOf("niri") !== -1;
    }
    // 📌 DEFAULT PINNED / FAVORITE APPS
    readonly property var defaultApps: [{
        "name": "Terminal",
        "icon": "kitty",
        "exec": "kitty",
        "appClass": "kitty"
    }, {
        "name": "Visual Studio Code",
        "icon": "vscode",
        "exec": "code",
        "appClass": "code"
    }, {
        "name": "Antigravity IDE",
        "icon": "antigravity",
        "exec": "antigravity-ide",
        "appClass": "antigravity-ide"
    }, {
        "name": "Arduino IDE",
        "icon": "cc.arduino.IDE2",
        "exec": "cc.arduino.IDE2",
        "appClass": "cc.arduino.IDE2"
    }, {
        "name": "Godot Engine",
        "icon": "godot",
        "exec": "godot",
        "appClass": "godot"
    }, {
        "name": "Obdisidian",
        "icon": "obsidian",
        "exec": "obsidian",
        "appClass": "obsidian"
    }, {
        "name": "Zen Browser",
        "icon": "zen-browser",
        "exec": "zen-browser",
        "appClass": "zen"
    }, {
        "name": "Firefox",
        "icon": "firefox",
        "exec": "firefox",
        "appClass": "firefox"
    }, {
        "name": "Spotify",
        "icon": "spotify",
        "exec": "spotify",
        "appClass": "spotify"
    }, {
        "name": "Files",
        "icon": "system-file-manager",
        "exec": "thunar",
        "appClass": "thunar"
    }, {
        "name": "Discord",
        "icon": "discord",
        "exec": "discord",
        "appClass": "discor"
    }, {
        "name": "OBS Studio",
        "icon": "obs",
        "exec": "obs",
        "appClass": "obs"
    }, {
        "name": "Kdenlive",
        "icon": "kdenlive",
        "exec": "kdenlive",
        "appClass": "kdenlive"
    }, {
        "name": "Minecraft Bedrock Launcher",
        "icon": "io.mrarm.mcpelauncher",
        "exec": "io.mrarm.mcpelauncher",
        "appClass": "io.mrarm.mcpelauncher"
    }, {
        "name": "Sober",
        "icon": "org.vinegarhq.Sober",
        "exec": "org.vinegarhq.Sober",
        "appClass": "org.vinegarhq.Sober"
    }]
    property var openWindows: []
    property var dockItems: []
    // 👁️ AUTO-HIDE STATE WITH DEBOUNCE
    property bool isRevealedState: SettingsStore.dockMode !== "auto_hide"
    // 🎞️ SLIDE ANIMATION: 0 = dock visible (at bottom of window), 80 = dock hidden (below window)
    property real slideOffset: (SettingsStore.dockMode === "auto_hide" && !isRevealedState) ? 80 : 0
 
    function checkReveal() {
        if (SettingsStore.dockMode !== "auto_hide") {
            autoHideTimer.stop();
            isRevealedState = true;
        } else if (triggerHover.hovered || (dockStyleLoader.item && dockStyleLoader.item.containsMouse)) {
            autoHideTimer.stop();
            isRevealedState = true;
        } else {
            autoHideTimer.restart();
        }
    }

    function focusWindow(win) {
        if (!win)
            return ;

        if (dockScope.isNiri) {
            if (win.id !== undefined)
                Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", win.id.toString()]);

        } else {
            var addr = win.address || win.id;
            if (addr)
                Quickshell.execDetached(["bash", "-c", "hyprctl dispatch 'hl.dsp.focus({ window = \"address:" + addr + "\" })' || hyprctl dispatch focuswindow address:" + addr]);

        }
    }

    function getAppIconName(appClass) {
        if (!appClass || appClass === "")
            return "application-x-executable";

        var cls = appClass.toLowerCase().trim();
        if (cls.indexOf("kitty") !== -1)
            return "kitty";

        if (cls.indexOf("alacritty") !== -1)
            return "alacritty";

        if (cls.indexOf("chromium") !== -1)
            return "chromium";

        if (cls.indexOf("chrome") !== -1)
            return "google-chrome";

        if (cls.indexOf("firefox") !== -1)
            return "firefox";

        if (cls.indexOf("zen") !== -1)
            return "zen-browser";

        if (cls.indexOf("brave") !== -1)
            return "brave-browser";

        if (cls.indexOf("vesktop") !== -1 || cls.indexOf("discord") !== -1)
            return "vesktop";

        if (cls.indexOf("code") !== -1)
            return "vscode";

        if (cls.indexOf("thunar") !== -1 || cls.indexOf("nautilus") !== -1 || cls.indexOf("dolphin") !== -1)
            return "system-file-manager";

        if (cls.indexOf("spotify") !== -1)
            return "spotify";

        if (cls.indexOf("obsidian") !== -1)
            return "obsidian";

        if (cls.indexOf("telegram") !== -1)
            return "telegram";

        if (cls.indexOf("pavucontrol") !== -1)
            return "pavucontrol";

        if (cls.indexOf("vlc") !== -1)
            return "vlc";

        if (cls.indexOf("gimp") !== -1)
            return "gimp";

        if (cls.indexOf("inkscape") !== -1)
            return "inkscape";

        if (typeof DesktopEntries !== "undefined" && DesktopEntries.applications) {
            for (var i = 0; i < DesktopEntries.applications.values.length; i++) {
                var app = DesktopEntries.applications.values[i];
                if (app && app.id && app.id.toLowerCase().indexOf(cls) !== -1) {
                    if (app.icon)
                        return app.icon;

                }
            }
        }
        return cls;
    }

    function updateDockItems() {
        var items = [];
        var processedWinIds = {
        };
        for (var i = 0; i < dockScope.defaultApps.length; i++) {
            var pin = dockScope.defaultApps[i];
            var matchingWins = [];
            var isFocused = false;
            for (var j = 0; j < dockScope.openWindows.length; j++) {
                var w = dockScope.openWindows[j];
                var cls = (w.app_id || w.title || "").toLowerCase();
                var targetCls = (pin.appClass || "").toLowerCase();
                var isMatch = cls.indexOf(targetCls) !== -1;
                if (!isMatch && pin.name && pin.name.toLowerCase() === "discord") {
                    if (cls.indexOf("discord") !== -1 || cls.indexOf("vesktop") !== -1)
                        isMatch = true;

                }
                if (!isMatch && pin.name && pin.name.toLowerCase() === "terminal") {
                    if (cls.indexOf("kitty") !== -1 || cls.indexOf("alacritty") !== -1 || cls.indexOf("foot") !== -1)
                        isMatch = true;

                }
                if (!isMatch && pin.name && pin.name.toLowerCase().indexOf("code") !== -1) {
                    if (cls.indexOf("code") !== -1 || cls.indexOf("vscodium") !== -1)
                        isMatch = true;

                }
                if (isMatch) {
                    matchingWins.push(w);
                    if (w.is_focused || w.is_active)
                        isFocused = true;

                    processedWinIds[w.id] = true;
                }
            }
            items.push({
                "name": pin.name,
                "icon": pin.icon,
                "exec": pin.exec,
                "appClass": pin.appClass,
                "isPinned": true,
                "isOpen": matchingWins.length > 0,
                "isFocused": isFocused,
                "wins": matchingWins,
                "primaryWin": matchingWins.length > 0 ? matchingWins[0] : null
            });
        }
        for (var k = 0; k < dockScope.openWindows.length; k++) {
            var win = dockScope.openWindows[k];
            if (processedWinIds[win.id])
                continue;

            var rawClass = win.app_id || win.title || "application";
            var iconName = getAppIconName(rawClass);
            var cleanName = rawClass.charAt(0).toUpperCase() + rawClass.slice(1);
            var existingUnpinned = null;
            for (var m = 0; m < items.length; m++) {
                if (!items[m].isPinned && items[m].icon === iconName) {
                    existingUnpinned = items[m];
                    break;
                }
            }
            if (existingUnpinned) {
                existingUnpinned.wins.push(win);
                if (win.is_focused || win.is_active)
                    existingUnpinned.isFocused = true;

            } else {
                items.push({
                    "name": cleanName,
                    "icon": iconName,
                    "exec": rawClass.toLowerCase(),
                    "appClass": rawClass,
                    "isPinned": false,
                    "isOpen": true,
                    "isFocused": win.is_focused || win.is_active,
                    "wins": [win],
                    "primaryWin": win
                });
            }
        }
        dockScope.dockItems = items;
    }

    Component.onCompleted: {
        dockScope.updateDockItems();
    }

    Timer {
        id: autoHideTimer

        interval: 800
        repeat: false
        onTriggered: {
            if (SettingsStore.dockMode === "auto_hide" && !triggerHover.hovered)
                dockScope.isRevealedState = false;

        }
    }

    Connections {
        function onDockModeChanged() {
            dockScope.checkReveal();
        }

        target: SettingsStore
    }

    // 🔤 MINECRAFT PIXEL FONT LOADER (FOR MINECRAFT DOCK TOOLTIP)
    FontLoader {
        id: mcFont

        source: Qt.resolvedUrl("../../assets/fonts/Minecraft.ttf")
    }

    // 🎯 EDGE TRIGGER WINDOW FOR AUTO-HIDE REVEAL
    PanelWindow {
        id: edgeTriggerWindow

        screen: dockScope.screen
        WlrLayershell.namespace: "quickshell:popup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        anchors.bottom: true
        anchors.left: true
        anchors.right: true
        implicitHeight: 16
        color: "transparent"
        visible: SettingsStore.dockEnabled && SettingsStore.dockMode === "auto_hide"

        HoverHandler {
            id: triggerHover

            onHoveredChanged: dockScope.checkReveal()
        }

    }

    // 🏷️ TOOLTIP OVERLAY WINDOW (Adaptive Original vs Minecraft Style)
    PanelWindow {
        id: dockTooltipWindow

        property real hoveredIconCenterX: 0
        property string tooltipText: ""

        screen: dockScope.screen
        WlrLayershell.namespace: "quickshell:popup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusionMode: ExclusionMode.Ignore
        anchors.bottom: true
        anchors.left: true
        margins.bottom: (SettingsStore.dockMode === "always_visible" ? 76 : 80) + (SettingsStore.dockStyle === "minecraft" ? 4 : 0)
        margins.left: Math.round(hoveredIconCenterX - implicitWidth / 2)
        width: implicitWidth
        height: implicitHeight
        implicitWidth: SettingsStore.dockStyle === "minecraft" ? mcTooltipCard.implicitWidth : tooltipCard.implicitWidth
        implicitHeight: SettingsStore.dockStyle === "minecraft" ? mcTooltipCard.implicitHeight : tooltipCard.implicitHeight
        color: "transparent"
        visible: SettingsStore.dockEnabled && dockScope.isRevealedState && tooltipText !== ""

        // Original Style Tooltip
        Rectangle {
            id: tooltipCard

            visible: SettingsStore.dockStyle !== "minecraft"
            implicitWidth: tooltipLabel.implicitWidth + 16
            implicitHeight: 24
            radius: 8
            color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.95)
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
            border.width: 1

            Text {
                id: tooltipLabel

                anchors.centerIn: parent
                text: dockTooltipWindow.tooltipText
                color: Theme.textMain

                font {
                    family: Theme.fontMain
                    pixelSize: 11
                    bold: true
                }

            }

        }

        // Minecraft Style Tooltip
        Rectangle {
            id: mcTooltipCard

            visible: SettingsStore.dockStyle === "minecraft"
            implicitWidth: mcTooltipLabel.implicitWidth + 18
            implicitHeight: 26
            radius: 2
            color: "#f0100010"
            border.color: "#28007f"
            border.width: 2

            Rectangle {
                anchors.fill: parent
                anchors.margins: -2
                color: "transparent"
                border.color: "#5000ff"
                border.width: 2
                radius: 3
                z: -1
            }

            Text {
                id: mcTooltipLabel

                anchors.centerIn: parent
                text: dockTooltipWindow.tooltipText
                color: "#ffffff"
                renderType: Text.NativeRendering

                font {
                    family: mcFont.name
                    pixelSize: 13
                }

            }

        }

    }

    // ⛵ DOCK PANEL WINDOW
    PanelWindow {
        id: dockWindow

        readonly property real currentCardHeight: dockStyleLoader.item ? dockStyleLoader.item.cardHeight : 64

        screen: dockScope.screen
        WlrLayershell.namespace: "quickshell:dock"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: SettingsStore.dockMode === "always_visible" ? ExclusionMode.Auto : ExclusionMode.Ignore
        anchors.bottom: true
        margins.bottom: SettingsStore.dockMode === "always_visible" ? 8 : 10
        width: dockStyleLoader.item ? dockStyleLoader.item.implicitWidth : 500
        height: SettingsStore.dockMode === "auto_hide" ? (currentCardHeight + 80) : currentCardHeight
        implicitWidth: width
        implicitHeight: currentCardHeight
        color: "transparent"
        visible: SettingsStore.dockEnabled

        // 📡 HYPRLAND WINDOWS IPC STREAMER
        Process {
            id: hyprWinProc

            command: ["hyprctl", "clients", "-j"]
            running: !dockScope.isNiri && SettingsStore.dockEnabled

            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        var data = JSON.parse(this.text);
                        if (Array.isArray(data)) {
                            var formatted = [];
                            for (var i = 0; i < data.length; i++) {
                                var c = data[i];
                                if (!c)
                                    continue;

                                if (c.mapped === false || c.hidden === true)
                                    continue;

                                formatted.push({
                                    "id": c.address,
                                    "address": c.address,
                                    "app_id": c.class || c.initialClass || "",
                                    "title": c.title || "",
                                    "is_focused": c.focusHistoryID === 0,
                                    "is_active": c.focusHistoryID === 0,
                                    "workspace": c.workspace,
                                    "pid": c.pid
                                });
                            }
                            dockScope.openWindows = formatted;
                            dockScope.updateDockItems();
                        }
                    } catch (e) {
                    }
                }
            }

        }

        // ⚡ REAL-TIME HYPRLAND EVENT LISTENER
        Connections {
            function onRawEvent(event) {
                if (SettingsStore.dockEnabled) {
                    hyprWinProc.running = false;
                    hyprWinProc.running = true;
                }
            }

            target: Hyprland
            enabled: !dockScope.isNiri
        }

        // 📡 NIRI WINDOWS IPC STREAMER
        Process {
            id: niriWinProc

            command: ["niri", "msg", "-j", "windows"]
            running: dockScope.isNiri && SettingsStore.dockEnabled

            stdout: StdioCollector {
                onStreamFinished: {
                    try {
                        var data = JSON.parse(this.text);
                        if (Array.isArray(data)) {
                            dockScope.openWindows = data;
                            dockScope.updateDockItems();
                        }
                    } catch (e) {
                    }
                }
            }

        }

        Process {
            id: niriEventProc

            command: ["niri", "msg", "-j", "event-stream"]
            running: dockScope.isNiri && SettingsStore.dockEnabled

            stdout: SplitParser {
                onRead: (data) => {
                    if (dockScope.isNiri && SettingsStore.dockEnabled) {
                        niriWinProc.running = false;
                        niriWinProc.running = true;
                    }
                }
            }

        }

        Timer {
            interval: 400
            running: SettingsStore.dockEnabled
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                if (dockScope.isNiri) {
                    if (!niriWinProc.running)
                        niriWinProc.running = true;

                } else {
                    if (!hyprWinProc.running)
                        hyprWinProc.running = true;

                }
            }
        }

        // 🔄 DYNAMIC DOCK STYLE LOADER (Original vs Minecraft Hotbar)
        Loader {
            id: dockStyleLoader

            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            y: dockWindow.height - (item ? item.cardHeight : 64) + dockScope.slideOffset
            source: {
                if (SettingsStore.dockStyle === "minecraft")
                    return Qt.resolvedUrl("./dockStyle/DockStyleMinecraft.qml");

                return Qt.resolvedUrl("./dockStyle/DockStyleOriginal.qml");
            }
            onLoaded: {
                if (item) {
                    item.dockItems = Qt.binding(function() {
                        return dockScope.dockItems;
                    });
                    item.dockScope = dockScope;
                    item.appClicked.connect(function(appData) {
                        var wins = appData.wins || [];
                        if (wins.length > 0) {
                            var focusedIdx = -1;
                            for (var i = 0; i < wins.length; i++) {
                                if (wins[i].is_focused || wins[i].is_active) {
                                    focusedIdx = i;
                                    break;
                                }
                            }
                            var nextIdx = (focusedIdx + 1) % wins.length;
                            dockScope.focusWindow(wins[nextIdx]);
                        } else if (appData.primaryWin) {
                            dockScope.focusWindow(appData.primaryWin);
                        } else {
                            Quickshell.execDetached(["bash", "-c", appData.exec]);
                        }
                    });
                    item.appHovered.connect(function(iconCenterX, name) {
                        var screenW = (dockWindow.screen && dockWindow.screen.width) ? dockWindow.screen.width : ((Quickshell.screens && Quickshell.screens.length > 0) ? Quickshell.screens[0].width : 1920);
                        var dockLeft = (screenW - dockWindow.width) / 2;
                        dockTooltipWindow.hoveredIconCenterX = dockLeft + iconCenterX;
                        dockTooltipWindow.tooltipText = name;
                    });
                    item.appExited.connect(function() {
                        dockTooltipWindow.tooltipText = "";
                    });
                    item.checkRevealRequested.connect(function() {
                        dockScope.checkReveal();
                    });
                }
            }
        }

        // Mask tracks dockStyleLoader's item visual position — input follows the card
        mask: Region {
            item: dockStyleLoader.item
        }

    }

    Behavior on slideOffset {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }

    }

}
