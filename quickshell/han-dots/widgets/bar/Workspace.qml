import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Widgets
import "../../theme"

Rectangle {
    id: root

    readonly property var romanNums: ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

    property var barWindow: null
    property var screen: barWindow ? barWindow.screen : null

    // 🕵️ DETEKSI AUTOMATIS COMPOSITOR (Hyprland vs Niri)
    readonly property bool isNiri: {
        var sock = Quickshell.env("NIRI_SOCKET") || ""
        var desk = Quickshell.env("XDG_CURRENT_DESKTOP") || ""
        return sock !== "" || desk.toLowerCase().indexOf("niri") !== -1
    }

    // 🖥️ HYPRLAND MONITOR SPECIFIC (eDP-1 / DP-1)
    readonly property var hypMonitor: screen ? Hyprland.monitorFor(screen) : Hyprland.focusedMonitor

    // 📡 NIRI STATE (Workspaces & Active ID Map)
    property int niriActiveWsId: 1
    property var niriWorkspacesList: [1, 2, 3, 4, 5]
    property var niriWsMap: ({})

    // 🌟 WORKSPACE AKTIF UNTUK COMPOSITOR AKTIF (Niri / Hyprland)
    readonly property var activeWorkspace: {
        if (root.isNiri) {
            return { id: root.niriActiveWsId }
        }
        if (hypMonitor && hypMonitor.activeWorkspace) {
            return hypMonitor.activeWorkspace
        }
        return Hyprland.focusedWorkspace
    }

    property real pillX: 0
    property real pillWidth: 32

    // 🌟 Deteksi Sifat Special Workspace (Scratchpad dengan ID Negatif)
    readonly property bool isSpecialActive: !root.isNiri && root.activeWorkspace && root.activeWorkspace.id < 0

    readonly property bool hasSpecialWorkspace: {
        if (root.isNiri) return false
        for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
            var w = Hyprland.workspaces.values[i]
            if (w.id < 0 || (w.name && w.name.indexOf("special") === 0)) {
                return true
            }
        }
        return isSpecialActive
    }

    // 📡 METRIKS APLIKASI TERBUKA (HYPRLAND: hyprctl | NIRI: niri msg)
    property var clientList: []

    Process {
        id: clientProc
        command: ["hyprctl", "clients", "-j"]
        running: !root.isNiri

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text)
                    if (Array.isArray(data)) {
                        root.clientList = data
                        pillUpdateTimer.restart()
                    }
                } catch(e) {}
            }
        }
    }

    // 📡 NIRI WORKSPACES IPC STREAMER
    Process {
        id: niriWsProc
        command: ["niri", "msg", "-j", "workspaces"]
        running: root.isNiri

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text)
                    if (Array.isArray(data)) {
                        var list = []
                        var map = {}
                        for (var idx = 0; idx < data.length; idx++) {
                            var w = data[idx]
                            var wid = w.idx !== undefined ? w.idx : (w.id !== undefined ? w.id : (idx + 1))
                            list.push(wid)
                            if (w.id !== undefined) {
                                map[w.id] = wid
                            }
                            if (w.is_active || w.is_focused) {
                                root.niriActiveWsId = wid
                            }
                        }
                        root.niriWsMap = map
                        if (list.length > 0) root.niriWorkspacesList = list
                        pillUpdateTimer.restart()
                    }
                } catch(e) {}
            }
        }
    }

    // 📡 NIRI WINDOWS IPC STREAMER
    Process {
        id: niriClientsProc
        command: ["niri", "msg", "-j", "windows"]
        running: root.isNiri

        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(this.text)
                    if (Array.isArray(data)) {
                        var formatted = []
                        for (var idx = 0; idx < data.length; idx++) {
                            var win = data[idx]
                            var mappedWsId = (win.workspace_id !== undefined && root.niriWsMap[win.workspace_id] !== undefined) ? root.niriWsMap[win.workspace_id] : (win.workspace_idx !== undefined ? win.workspace_idx : (win.workspace_id !== undefined ? win.workspace_id : 1))
                            formatted.push({
                                workspace: { id: mappedWsId },
                                class: win.app_id || win.title || ""
                            })
                        }
                        root.clientList = formatted
                        pillUpdateTimer.restart()
                    }
                } catch(e) {}
            }
        }
    }

    // ⚡ 0MS REAL-TIME NIRI EVENT-STREAM LISTENER
    Process {
        id: niriEventProc
        command: ["niri", "msg", "-j", "event-stream"]
        running: root.isNiri

        stdout: SplitParser {
            onRead: (data) => {
                if (root.isNiri) {
                    niriWsProc.running = false
                    niriWsProc.running = true
                    niriClientsProc.running = false
                    niriClientsProc.running = true
                }
            }
        }
    }

    Timer {
        interval: 250
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            if (root.isNiri) {
                if (!niriWsProc.running) niriWsProc.running = true
                if (!niriClientsProc.running) niriClientsProc.running = true
            } else {
                if (!clientProc.running) clientProc.running = true
            }
        }
    }

    // 🚀 SWITCH WORKSPACE DISPATCHER (Hyprland / Niri)
    function switchWorkspace(targetWsId) {
        if (root.isNiri) {
            root.niriActiveWsId = targetWsId
            pillUpdateTimer.restart()
            var niriSwitch = Quickshell.createProcess(["niri", "msg", "action", "focus-workspace", targetWsId.toString()])
            niriSwitch.running = true
        } else {
            Hyprland.dispatch("workspace " + targetWsId)
        }
    }

    // 🖼️ HELPER PEMETAAN IKON APLIKASI GTK FREEDESKTOP
    function getAppIconName(appClass) {
        if (!appClass) return ""
        var cls = appClass.toLowerCase().trim()

        if (cls.indexOf("kitty") !== -1) return "kitty"
        if (cls.indexOf("alacritty") !== -1) return "alacritty"
        if (cls.indexOf("firefox") !== -1) return "firefox"
        if (cls.indexOf("zen") !== -1) return "firefox"
        if (cls.indexOf("chrome") !== -1) return "google-chrome"
        if (cls.indexOf("brave") !== -1) return "brave-browser"
        if (cls.indexOf("vesktop") !== -1 || cls.indexOf("discord") !== -1) return "vesktop"
        if (cls.indexOf("code") !== -1) return "vscode"
        if (cls.indexOf("thunar") !== -1) return "system-file-manager"
        if (cls.indexOf("nautilus") !== -1) return "system-file-manager"
        if (cls.indexOf("spotify") !== -1) return "spotify"
        if (cls.indexOf("obsidian") !== -1) return "obsidian"
        if (cls.indexOf("telegram") !== -1) return "telegram"
        if (cls.indexOf("pavucontrol") !== -1) return "pavucontrol"
        if (cls.indexOf("vlc") !== -1) return "vlc"

        if (typeof DesktopEntries !== "undefined" && DesktopEntries.applications) {
            for (var i = 0; i < DesktopEntries.applications.values.length; i++) {
                var app = DesktopEntries.applications.values[i]
                if (app && app.id && app.id.toLowerCase().indexOf(cls) !== -1) {
                    if (app.icon) return app.icon
                }
            }
        }

        return cls
    }

    // 📦 HELPER KUMPULAN APLIKASI AKTIF PADA WORKSPACE CERTAIN (Grouping + Count Instance)
    function getWorkspaceApps(targetWsId) {
        if (targetWsId === undefined || targetWsId === null) return []

        var appMap = {}
        var order = []

        for (var i = 0; i < root.clientList.length; i++) {
            var client = root.clientList[i]
            if (client && client.workspace && client.workspace.id === targetWsId) {
                var rawClass = client.class || client.initialClass || ""
                if (!rawClass) continue

                var iconName = getAppIconName(rawClass)
                if (!iconName) continue

                if (!appMap[iconName]) {
                    appMap[iconName] = { icon: iconName, count: 1 }
                    order.push(iconName)
                } else {
                    appMap[iconName].count++
                }
            }
        }

        var result = []
        for (var k = 0; k < order.length; k++) {
            result.push(appMap[order[k]])
        }
        return result
    }

    function updatePillX() {
        if (root.isSpecialActive && specialItem.visible) {
            var mappedSpecial = leftContent.mapToItem(root, specialItem.x, specialItem.y)
            if (mappedSpecial.x >= 0) {
                pillX = mappedSpecial.x
                pillWidth = specialItem.width
                return
            }
        }

        var activeId = root.activeWorkspace ? root.activeWorkspace.id : 1
        var idx = workspaceRepeater.modelList.indexOf(activeId)
        if (idx < 0) return

        var item = workspaceRepeater.itemAt(idx)
        if (item && item.width > 0) {
            var mapped = leftContent.mapToItem(root, item.x, item.y)
            if (mapped.x >= 0) {
                pillX = mapped.x
                pillWidth = item.width
            }
        } else {
            pillUpdateTimer.restart()
        }
    }

    implicitWidth: leftContent.implicitWidth + 16
    implicitHeight: 32
    color: "transparent"
    radius: 10

    Timer {
        id: pillUpdateTimer
        interval: 32
        repeat: false
        onTriggered: root.updatePillX()
    }

    Component.onCompleted: pillUpdateTimer.restart()

    // 🌟 KAPSUL SLIDING AKTIF (Dinamis Mengikuti X dan Lebar Item Workspace)
    Rectangle {
        id: activePill
        z: 0
        x: root.pillX
        width: root.pillWidth
        anchors.verticalCenter: parent.verticalCenter
        height: 30
        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
        border.color: Theme.accent
        border.width: 1
        radius: 8

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Behavior on width {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    // TOMBOL WORKSPACE
    RowLayout {
        id: leftContent
        z: 1
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            id: workspaceRepeater

            // 🎯 DAFTAR WORKSPACE (Hyprland / Niri Auto-Support)
            property var modelList: {
                var list = root.isNiri ? root.niriWorkspacesList.slice() : [1, 2, 3, 4, 5]

                if (!root.isNiri) {
                    for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                        var id = Hyprland.workspaces.values[i].id
                        if (id > 0 && !list.includes(id)) {
                            list.push(id)
                        }
                    }
                }

                var actId = root.activeWorkspace ? root.activeWorkspace.id : 1
                if (actId > 0 && !list.includes(actId)) {
                    list.push(actId)
                }

                return list.sort((a, b) => a - b)
            }

            model: modelList
            onModelChanged: pillUpdateTimer.restart()

            Item {
                id: wsItem
                implicitWidth: Math.max(32, wsItemRow.implicitWidth + 12)
                implicitHeight: 24

                property int wsId: modelData
                property var ws: root.isNiri ? true : Hyprland.workspaces.values.find(w => w.id == wsId)
                property bool isActive: root.activeWorkspace && root.activeWorkspace.id == wsId
                property var wsApps: root.getWorkspaceApps(wsId)

                onIsActiveChanged: if (isActive) pillUpdateTimer.restart()
                onXChanged: if (isActive) pillUpdateTimer.restart()
                onWsAppsChanged: pillUpdateTimer.restart()

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: "transparent"
                }

                RowLayout {
                    id: wsItemRow
                    anchors.centerIn: parent
                    spacing: 5

                    // 1. ANGKA ROMAWI WORKSPACE
                    Text {
                        text: root.romanNums[wsId - 1] !== undefined ? root.romanNums[wsId - 1] : wsId
                        color: ws ? Theme.textMain : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.35)
                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                            bold: true
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 200
                                easing.type: Easing.InOutQuad
                            }
                        }
                    }

                    // 2. DAFTAR IKON APLIKASI DI SEBELAH KANAN ANGKA WORKSPACE
                    RowLayout {
                        spacing: 4
                        visible: wsItem.wsApps.length > 0

                        Repeater {
                            model: wsItem.wsApps

                            Item {
                                implicitWidth: 16
                                implicitHeight: 22

                                // 🖼️ IKON APLIKASI GTK / FREEDESKTOP
                                Image {
                                    id: appIconImg
                                    source: modelData.icon ? (modelData.icon.indexOf("/") !== -1 ? "file://" + modelData.icon : "image://icon/" + modelData.icon) : ""
                                    width: 17
                                    height: 17
                                    fillMode: Image.PreserveAspectFit
                                    anchors.top: parent.top
                                    anchors.topMargin: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }

                                // 🔴 TITIK INDIKATOR JUMLAH APLIKASI DI BAWAH IKON
                                RowLayout {
                                    anchors.bottom: parent.bottom
                                    anchors.bottomMargin: 1
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    spacing: 2
                                    visible: modelData.count > 0

                                    Repeater {
                                        model: Math.min(4, modelData.count)

                                        Rectangle {
                                            width: 3
                                            height: 3
                                            radius: 1.5
                                            color: Theme.accent

                                            Behavior on color {
                                                ColorAnimation {
                                                    duration: 200
                                                    easing.type: Easing.InOutQuad
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.isNiri) {
                            root.niriActiveWsId = wsId
                            pillUpdateTimer.restart()
                        }
                        root.switchWorkspace(wsId)
                    }
                }
            }
        }

        // ✨ INDIKATOR SPECIAL WORKSPACE (Ditampilkan di Ujung Kanan Paling Akhir)
        Item {
            id: specialItem
            implicitWidth: 32
            implicitHeight: 24
            visible: root.hasSpecialWorkspace

            property bool isActive: root.isSpecialActive

            onIsActiveChanged: if (isActive) pillUpdateTimer.restart()
            onXChanged: if (isActive) pillUpdateTimer.restart()
            onVisibleChanged: pillUpdateTimer.restart()

            Rectangle {
                anchors.fill: parent
                radius: 8
                color: "transparent"
            }

            Text {
                anchors.centerIn: parent
                text: "★"
                color: specialItem.isActive ? Theme.bgDark : Theme.accent

                font {
                    family: Theme.fontMain
                    pixelSize: 14
                    bold: true
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Hyprland.dispatch("togglespecialworkspace")
            }
        }
    }
}
