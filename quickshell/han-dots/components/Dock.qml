import "../services"
import "../theme"
import "../widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// ⛵ APPLICATION DOCK SURFACE
Scope {
    id: dockScope

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
        "name": "Browser",
        "icon": "firefox",
        "exec": "zen-browser",
        "appClass": "zen"
    }, {
        "name": "Code Editor",
        "icon": "vscode",
        "exec": "code",
        "appClass": "code"
    }, {
        "name": "Files",
        "icon": "system-file-manager",
        "exec": "thunar",
        "appClass": "thunar"
    }, {
        "name": "Spotify",
        "icon": "spotify",
        "exec": "spotify",
        "appClass": "spotify"
    }, {
        "name": "Discord",
        "icon": "vesktop",
        "exec": "vesktop",
        "appClass": "vesktop"
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
            return "firefox";

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
                if (cls.indexOf(targetCls) !== -1) {
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
                if (dockScope.isNiri && !niriWinProc.running)
                    niriWinProc.running = true;

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
            color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.barOpacity)
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
            border.width: 1

            HoverHandler {
                id: dockCardHover

                onHoveredChanged: dockScope.checkReveal()
            }

            RowLayout {
                id: dockRow

                anchors.centerIn: parent
                spacing: 12

                Repeater {
                    model: dockScope.dockItems

                    Item {
                        id: dockItem

                        property var appData: modelData

                        implicitWidth: 48
                        implicitHeight: 48

                        Item {
                            id: iconContainer

                            anchors.fill: parent
                            scale: itemHover.hovered ? 1.22 : 1

                            Image {
                                anchors.centerIn: parent
                                source: dockItem.appData.icon ? (dockItem.appData.icon.indexOf("/") !== -1 ? "file://" + dockItem.appData.icon : "image://icon/" + dockItem.appData.icon) : "image://icon/application-x-executable"
                                width: 38
                                height: 38
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                mipmap: true
                                sourceSize: Qt.size(64, 64)
                            }

                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 1
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: dockItem.appData.isFocused ? 16 : 6
                                height: 4
                                radius: 2
                                color: dockItem.appData.isFocused ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.45)
                                visible: dockItem.appData.isOpen

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
                                    if (dockItem.appData.isOpen && dockItem.appData.primaryWin && dockItem.appData.primaryWin.id !== undefined)
                                        Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", dockItem.appData.primaryWin.id.toString()]);
                                    else
                                        Quickshell.execDetached(["bash", "-c", dockItem.appData.exec]);
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
