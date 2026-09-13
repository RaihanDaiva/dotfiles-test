import "../services"
import "../theme"
import "../widgets"
import "./popups/"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// ⛵ APPLICATION DOCK SURFACE
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
    },  {
        "name": "Antigravity IDE",
        "icon": "antigravity",
        "exec": "antigravity-ide",
        "appClass": "antigravity-ide"
    },  {
        "name": "Obdisidian",
        "icon": "obsidian",
        "exec": "obsidian",
        "appClass": "obsidian"
    },  {
        "name": "Zen Browser",
        "icon": "zen-browser",
        "exec": "zen-browser",
        "appClass": "zen"
    },  {
        "name": "Spotify",
        "icon": "spotify",
        "exec": "spotify",
        "appClass": "spotify"
    },  {
        "name": "Files",
        "icon": "system-file-manager",
        "exec": "thunar",
        "appClass": "thunar"
    },  {
        "name": "Discord",
        "icon": "discord",
        "exec": "vesktop",
        "appClass": "vesktop"
    },  {
        "name": "OBS Studio",
        "icon": "obs",
        "exec": "obs",
        "appClass": "obs"
    }]
    property var openWindows: []
    property var dockItems: []
    // 👁️ AUTO-HIDE STATE WITH DEBOUNCE
    property bool isRevealedState: SettingsStore.dockMode !== "auto_hide"
    // 🎞️ SLIDE ANIMATION: 0 = dock visible (at bottom of window), 80 = dock hidden (below window)
    // Uses internal Y offset instead of negative margins (negative margins get clamped by compositor)
    property real slideOffset: (SettingsStore.dockMode === "auto_hide" && !isRevealedState) ? 80 : 0

    function checkReveal() {
        if (SettingsStore.dockMode !== "auto_hide") {
            autoHideTimer.stop();
            isRevealedState = true;
        } else if (triggerHover.hovered || dockCardHover.hovered) {
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
            if (SettingsStore.dockMode === "auto_hide" && !triggerHover.hovered && !dockCardHover.hovered)
                dockScope.isRevealedState = false;

        }
    }

    Connections {
        function onDockModeChanged() {
            dockScope.checkReveal();
        }

        target: SettingsStore
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

    // 🏷️ TOOLTIP OVERLAY WINDOW
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
        margins.bottom: SettingsStore.dockMode === "always_visible" ? 76 : 80
        margins.left: Math.round(hoveredIconCenterX - implicitWidth / 2)
        width: implicitWidth
        height: implicitHeight
        implicitWidth: tooltipCard.implicitWidth
        implicitHeight: tooltipCard.implicitHeight
        color: "transparent"
        visible: SettingsStore.dockEnabled && dockScope.isRevealedState && tooltipText !== ""

        Rectangle {
            id: tooltipCard

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

    }

    // ⛵ DOCK PANEL WINDOW
    // In auto_hide mode: window height = 64 (card) + 80 (slide room below).
    // dockCard slides WITHIN this taller window using y offset.
    // mask: Region tracks dockCard's actual y — so input follows the visual card perfectly.
    // This avoids negative margins (which Niri/Wayland clamp to 0, breaking smooth IN animation).
    PanelWindow {
        id: dockWindow

        screen: dockScope.screen
        WlrLayershell.namespace: "quickshell:dock"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: SettingsStore.dockMode === "always_visible" ? ExclusionMode.Auto : ExclusionMode.Ignore
        anchors.bottom: true
        margins.bottom: SettingsStore.dockMode === "always_visible" ? 8 : 10
        width: dockCard.width
        // Taller window in auto_hide to give the card room to slide down out of view
        height: SettingsStore.dockMode === "auto_hide" ? 64 + 80 : 64
        implicitWidth: dockCard.width
        // implicitHeight controls workspace exclusion zone — always 64px for always_visible
        implicitHeight: 64
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

        // 🖼️ DOCK CARD — positioned at bottom of window, slides down via slideOffset
        Rectangle {
            id: dockCard

            // y = window.height - cardHeight + slideOffset
            // revealed (slideOffset=0): card at bottom of window → fully visible
            // hidden (slideOffset=80): card at window.height → fully below window → clipped
            y: dockWindow.height - 64 + dockScope.slideOffset
            x: 0
            width: dockRow.implicitWidth + 24
            height: 64
            radius: 22
            color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.dockBlurEnabled ? 0.35 : SettingsStore.barOpacity)
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, SettingsStore.dockBlurEnabled ? 0.25 : 0.3)
            border.width: 1

            HoverHandler {
                id: dockCardHover

                onHoveredChanged: dockScope.checkReveal()
            }

            RowLayout {
                id: dockRow

                anchors.centerIn: parent
                spacing: 5

                Repeater {
                    model: dockScope.dockItems

                    Item {
                        id: dockItem

                        property var appData: modelData

                        implicitWidth: 58
                        implicitHeight: 58

                        Item {
                            id: iconContainer

                            anchors.fill: parent
                            scale: itemHover.hovered ? 1.22 : 1

                            Image {
                                anchors.centerIn: parent
                                source: dockItem.appData.icon ? (dockItem.appData.icon.indexOf("/") !== -1 ? "file://" + dockItem.appData.icon : "image://icon/" + dockItem.appData.icon) : "image://icon/application-x-executable"
                                width: 48
                                height: 48
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                                sourceSize: Qt.size(64, 64)
                            }

                            // 🔴 TITIK / PIL INDIKATOR INSTANCE WINDOW TERBUKA
                            RowLayout {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 1
                                anchors.horizontalCenter: parent.horizontalCenter
                                spacing: 3
                                visible: dockItem.appData.isOpen

                                Repeater {
                                    model: (dockItem.appData.wins && dockItem.appData.wins.length > 0) ? dockItem.appData.wins : (dockItem.appData.isOpen ? [dockItem.appData.primaryWin] : [])

                                    Rectangle {
                                        id: dotIndicator

                                        property bool isWinFocused: modelData ? (modelData.is_focused || modelData.is_active) : false

                                        width: isWinFocused ? 16 : 4
                                        height: 4
                                        radius: 2
                                        color: isWinFocused ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.45)

                                        Behavior on width {
                                            NumberAnimation {
                                                duration: 180
                                                easing.type: Easing.OutCubic
                                            }

                                        }

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 150
                                            }

                                        }

                                    }

                                }

                            }

                            HoverHandler {
                                id: itemHover

                                onHoveredChanged: {
                                    if (hovered) {
                                        var screenW = (dockWindow.screen && dockWindow.screen.width) ? dockWindow.screen.width : ((Quickshell.screens && Quickshell.screens.length > 0) ? Quickshell.screens[0].width : 1920);
                                        var dockLeft = (screenW - dockWindow.width) / 2;
                                        var localPos = iconContainer.mapToItem(null, 0, 0);
                                        dockTooltipWindow.hoveredIconCenterX = dockLeft + localPos.x + iconContainer.width / 2;
                                        dockTooltipWindow.tooltipText = dockItem.appData.name;
                                    } else if (dockTooltipWindow.tooltipText === dockItem.appData.name) {
                                        dockTooltipWindow.tooltipText = "";
                                    }
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    var wins = dockItem.appData.wins || [];
                                    if (wins.length > 0) {
                                        // Cari indeks window yang saat ini sedang aktif/fokus
                                        var focusedIdx = -1;
                                        for (var i = 0; i < wins.length; i++) {
                                            if (wins[i].is_focused || wins[i].is_active) {
                                                focusedIdx = i;
                                                break;
                                            }
                                        }
                                        // Rotasi ke window berikutnya satu-per-satu (Window 1 -> 2 -> 3 -> 1)
                                        var nextIdx = (focusedIdx + 1) % wins.length;
                                        dockScope.focusWindow(wins[nextIdx]);
                                    } else if (dockItem.appData.primaryWin) {
                                        dockScope.focusWindow(dockItem.appData.primaryWin);
                                    } else {
                                        // Aplikasi belum terbuka -> jalankan exec
                                        Quickshell.execDetached(["bash", "-c", dockItem.appData.exec]);
                                    }
                                }
                            }

                            Behavior on scale {
                                NumberAnimation {
                                    duration: 180
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                    }

                }

            }

        }

        // Mask tracks dockCard's actual visual position — input perfectly aligned
        mask: Region {
            item: dockCard
        }

    }

    Behavior on slideOffset {
        NumberAnimation {
            duration: 260
            easing.type: Easing.OutCubic
        }

    }

}
