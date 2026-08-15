import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import "../../widgets"
import "../../theme"

// 🎛️ CONTROL CENTER / QUICK SETTINGS POPUP (WINDOWS 11 STYLE SLIDING DRILL-DOWN)
BasePopup {
    id: popupRoot

    property var controlRootItem: null
    targetItem: controlRootItem

    // 🎯 REUSABLE & OSD REFERENCES
    property var osdItem: null

    // 👤 USER & BATTERY DATA
    property string userNameText: "User"
    property int batCap: 100
    property string batStatus: "Discharging"

    // 📡 WI-FI DYNAMIC METRICS
    property int wifiSignal: -1
    property string wifiSSID: "Off"
    property bool wifiEnabled: false
    property var wifiNetworks: []      // [{ssid, signal, connected}]

    // 📡 WI-FI CONNECT PAGE METRICS
    property string connectingSSID: ""
    property string connectStatusMsg: ""
    property bool isConnecting: false
    property bool showPassword: false

    // 󰂯 BLUETOOTH DYNAMIC METRICS
    property string btStatus: "off"
    property string btConnectedName: "Not connected"
    property var btDevices: []         // [{name, mac, connected}]

    // 🎚️ SLIDER METRICS & MULTI-DISPLAY BRIGHTNESS
    property int displayCount: 1
    property string brightName1: "Screen Brightness"
    property int brightVal1: 100
    property string brightType1: "backlight"

    property string brightName2: "Screen Brightness (second)"
    property int brightVal2: 100
    property string brightType2: "ddcutil:1"

    property int volumeVal: 80
    property bool volumeMuted: false

    // 🔄 EXPANDED STATE ("" = main page, "wifi" = Wi-Fi list, "bt" = BT list, "wifi_connect" = Wi-Fi pass input)
    property string expandedMode: ""

    // 🔑 BIND WAYLAND KEYBOARD FOCUS FOR PASSWORD TEXT INPUT
    requiresKeyboardFocus: expandedMode === "wifi_connect"

    // 📐 UKURAN POPUP
    implicitWidth: 360
    implicitHeight: mainColumn.implicitHeight + 32

    Behavior on implicitHeight {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    // 🔋 Dynamic Battery Icon
    readonly property string batIcon: {
        if (batStatus === "Charging") return "󰂄"
        if (batCap >= 90) return "󰁹"
        if (batCap >= 70) return "󰂀"
        if (batCap >= 50) return "󰁾"
        if (batCap >= 30) return "󰁽"
        if (batCap >= 15) return "󰁼"
        return "󰂃"
    }

    // 📡 Dynamic Wi-Fi Icon
    readonly property string wifiIcon: {
        if (!wifiEnabled || wifiSignal <= 0) return "󰤮"
        if (wifiSignal >= 75) return "󰤨"
        if (wifiSignal >= 50) return "󰤥"
        if (wifiSignal >= 25) return "󰤢"
        return "󰤟"
    }

    // 󰂯 Dynamic Bluetooth Icon
    readonly property string btIcon: (btStatus !== "off") ? "󰂯" : "󰂲"

    Component.onCompleted: {
        sysProc.running = true
        wifiProc.running = true
        btProc.running = true
    }

    onIsOpenChanged: {
        if (isOpen) {
            sysProc.running = false
            sysProc.running = true
            wifiProc.running = false
            wifiProc.running = true
            btProc.running = false
            btProc.running = true
        }
    }

    // ─── 1. SYSTEM INFO PROCESS (sys_info.sh) ────────────────────────────────
    Process {
        id: sysProc
        command: [Quickshell.configDir + "/scripts/sys_info.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 3  && lines[2]  !== "") batCap       = parseInt(lines[2])   || 100
                if (lines.length >= 4  && lines[3]  !== "") batStatus    = lines[3].trim()
                if (lines.length >= 5  && lines[4]  !== "") {
                    var sig = parseInt(lines[4])
                    wifiSignal  = isNaN(sig) ? -1 : sig
                    wifiEnabled = wifiSignal > 0
                }
                if (lines.length >= 6  && lines[5]  !== "") btStatus     = lines[5].trim()
                if (lines.length >= 15 && lines[14] !== "") volumeVal    = parseInt(lines[14]) || 80
                if (lines.length >= 16 && lines[15] !== "") volumeMuted  = (lines[15].trim() === "muted")
                if (lines.length >= 17 && lines[16] !== "") brightnessVal = parseInt(lines[16]) || 100
                if (lines.length >= 18 && lines[17] !== "") userNameText = lines[17].trim()
            }
        }
    }

    // ─── 2. WI-FI LIST PROCESS (wifi_list.sh) ────────────────────────────────
    Process {
        id: wifiProc
        command: [Quickshell.configDir + "/scripts/wifi_list.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                var nets = []
                var connectedSSID = ""
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line === "") continue
                    var parts = line.split(":")
                    if (parts.length < 3) continue
                    var active = parts[0] === "yes"
                    var ssid   = parts[1]
                    var sig    = parseInt(parts[2]) || 0
                    if (ssid === "") continue
                    if (active) connectedSSID = ssid
                    nets.push({ ssid: ssid, signal: sig, connected: active })
                }
                wifiNetworks = nets
                if (connectedSSID !== "") {
                    wifiSSID    = connectedSSID
                    wifiEnabled = true
                    for (var k = 0; k < nets.length; k++) {
                        if (nets[k].connected) {
                            wifiSignal = nets[k].signal
                            break
                        }
                    }
                } else if (nets.length > 0) {
                    wifiSSID    = "Disconnected"
                    wifiEnabled = true
                    wifiSignal  = 0
                } else {
                    wifiSSID    = "Off"
                    wifiEnabled = false
                    wifiSignal  = -1
                }
            }
        }
    }

    // ─── 3. BLUETOOTH LIST PROCESS (bt_list.sh) ──────────────────────────────
    Process {
        id: btProc
        command: [Quickshell.configDir + "/scripts/bt_list.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                var devs = []
                var foundConnected = ""
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line === "") continue
                    var parts = line.split("|")
                    if (parts.length < 3) continue
                    var status   = parts[0]
                    var mac      = parts[1]
                    var name     = parts[2]
                    if (!name || name === "") continue
                    var isConn = (status === "connected")
                    if (isConn && foundConnected === "") foundConnected = name
                    devs.push({ name: name, mac: mac, connected: isConn })
                }
                devs.sort(function(a, b) { return (b.connected ? 1 : 0) - (a.connected ? 1 : 0) })
                btDevices = devs
                btConnectedName = foundConnected !== "" ? foundConnected : (devs.length > 0 ? "On" : "Not connected")
            }
        }
    }

    // ─── 4. WI-FI CONNECT ACTION PROCESS ────────────────────────────────────
    Process {
        id: wifiConnectProc
        onExited: (exitCode, exitStatus) => {
            popupRoot.isConnecting = false
            if (exitCode === 0) {
                popupRoot.connectStatusMsg = "Connected!"
                wifiProc.running = false
                wifiProc.running = true
                backToWifiTimer.start()
            } else {
                popupRoot.connectStatusMsg = "Connection failed"
            }
        }
    }

    Timer {
        id: backToWifiTimer
        interval: 1200
        onTriggered: popupRoot.expandedMode = "wifi"
    }

    // ─── POLLING TIMERS ───────────────────────────────────────────────────────
    Timer {
        id: sysTimer
        interval: 3000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { sysProc.running = false; sysProc.running = true }
    }

    Timer {
        id: wifiTimer
        interval: 5000
        running: popupRoot.isOpen && (popupRoot.expandedMode === "wifi" || popupRoot.expandedMode === "wifi_connect")
        repeat: true
        triggeredOnStart: true
        onTriggered: { wifiProc.running = false; wifiProc.running = true }
    }

    Timer {
        id: btTimer
        interval: 5000
        running: popupRoot.isOpen && popupRoot.expandedMode === "bt"
        repeat: true
        triggeredOnStart: true
        onTriggered: { btProc.running = false; btProc.running = true }
    }

    Timer {
        id: passFocusTimer
        interval: 280
        onTriggered: passInput.forceActiveFocus()
    }

    // Trigger list load on expand
    onExpandedModeChanged: {
        if (expandedMode === "wifi" || expandedMode === "wifi_connect") {
            wifiProc.running = false; wifiProc.running = true
        }
        if (expandedMode === "wifi_connect") {
            passFocusTimer.start()
        }
        if (expandedMode === "bt") {
            btProc.running = false; btProc.running = true
        }
    }

    // ─── MULTI-DISPLAY BRIGHTNESS DETECTION & ACTION PROCESSES ───────────────
    Process {
        id: brightInfoProc
        command: [Quickshell.configDir + "/scripts/brightness_info.sh"]
        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 4) {
                    var dCount = parseInt(lines[0])
                    popupRoot.displayCount = isNaN(dCount) ? 1 : dCount
                    popupRoot.brightName1 = lines[1].trim()
                    var b1 = parseInt(lines[2])
                    popupRoot.brightVal1 = isNaN(b1) ? 100 : b1
                    popupRoot.brightType1 = lines[3].trim()
                    if (popupRoot.displayCount >= 2 && lines.length >= 7) {
                        popupRoot.brightName2 = lines[4].trim()
                        var b2 = parseInt(lines[5])
                        popupRoot.brightVal2 = isNaN(b2) ? 100 : b2
                        popupRoot.brightType2 = lines[6].trim()
                    }
                }
            }
        }
    }

    Timer {
        id: brightPollTimer
        interval: 3000
        running: popupRoot.isOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: { brightInfoProc.running = false; brightInfoProc.running = true }
    }

    Process { id: bright1Proc }
    Process { id: bright2Proc }
    Process { id: volProc }
    Process { id: wifiToggleProc }
    Process { id: btToggleProc }

    // ─── HELPER: Signal strength → Nerd Font icon ────────────────────────────
    function wifiSigIcon(sig) {
        if (sig >= 75) return "󰤨"
        if (sig >= 50) return "󰤥"
        if (sig >= 25) return "󰤢"
        return "󰤟"
    }

    // ─── MAIN CONTAINER LAYOUT ────────────────────────────────────────────────
    ColumnLayout {
        id: mainColumn
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
        }
        spacing: 10

        // 👤 1. USER PROFILE HEADER (FIXED AT TOP)
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: Theme.accent

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 1
                    text: "󰀉"
                    color: Theme.bgDark
                    font { family: Theme.fontMono; pixelSize: 22 }
                }
            }

            ColumnLayout {
                spacing: 1
                Text {
                    text: popupRoot.userNameText
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 15; bold: true }
                }
                RowLayout {
                    spacing: 4
                    Text {
                        text: popupRoot.batIcon
                        color: Theme.accent
                        font { family: Theme.fontMono; pixelSize: 13 }
                    }
                    Text {
                        text: popupRoot.batCap + "%"
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 12 }
                    }
                }
            }
            Item { Layout.fillWidth: true }
        }

        // ➖ DIVIDER LINE (FIXED AT TOP)
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
        }

        // 🎞️ 2. SLIDING BODY CONTAINER (WINDOWS 11 STYLE DRILL-DOWN NAVIGATION)
        Item {
            id: bodyContainer
            Layout.fillWidth: true
            implicitHeight: popupRoot.expandedMode !== "" ? 225 : mainPage.implicitHeight
            clip: true

            Behavior on implicitHeight {
                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
            }

            // ─── 🅰️ PAGE 0: MAIN PAGE (PILLS & SLIDERS) ──────────────────────
            ColumnLayout {
                id: mainPage
                width: bodyContainer.width
                x: popupRoot.expandedMode === "" ? 0 : (popupRoot.expandedMode === "wifi_connect" ? -bodyContainer.width * 2 : -bodyContainer.width)
                spacing: 10

                Behavior on x {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }

                // 🎛️ CONNECTIVITY PILLS
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 10

                    // 📡 WI-FI PILL
                    ControlPill {
                        Layout.fillWidth: true
                        iconText: popupRoot.wifiIcon
                        titleText: "Wi-Fi"
                        subtitleText: popupRoot.wifiEnabled ? popupRoot.wifiSSID : "Off"
                        isActive: popupRoot.wifiEnabled
                        isExpanded: popupRoot.expandedMode === "wifi" || popupRoot.expandedMode === "wifi_connect"

                        onToggleClicked: {
                            popupRoot.wifiEnabled = !popupRoot.wifiEnabled
                            wifiToggleProc.command = ["nmcli", "radio", "wifi", popupRoot.wifiEnabled ? "on" : "off"]
                            wifiToggleProc.running = true
                        }
                        onExpandClicked: {
                            popupRoot.expandedMode = "wifi"
                        }
                    }

                    // 󰂯 BLUETOOTH PILL
                    ControlPill {
                        Layout.fillWidth: true
                        iconText: popupRoot.btIcon
                        titleText: "Bluetooth"
                        subtitleText: popupRoot.btStatus !== "off" ? popupRoot.btConnectedName : "Off"
                        isActive: popupRoot.btStatus !== "off"
                        isExpanded: popupRoot.expandedMode === "bt"

                        onToggleClicked: {
                            var turningOff = (popupRoot.btStatus !== "off")
                            popupRoot.btStatus = turningOff ? "off" : "on"
                            btToggleProc.command = ["bluetoothctl", "power", turningOff ? "off" : "on"]
                            btToggleProc.running = true
                        }
                        onExpandClicked: {
                            popupRoot.expandedMode = "bt"
                        }
                    }
                }

                // 🔆 BRIGHTNESS SLIDER 1 (PRIMARY / FIRST)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1

                    Rectangle {
                        height: parent.height
                        width: parent.width * (popupRoot.brightVal1 / 100)
                        radius: parent.radius
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        Text { text: "󰃠"; color: Theme.accent; font { family: Theme.fontMono; pixelSize: 18 } }
                        Text {
                            text: popupRoot.displayCount > 1 ? "Screen Brightness (first)" : "Screen Brightness"
                            color: Theme.textMain
                            font { family: Theme.fontMain; pixelSize: 13; bold: true }
                            Layout.fillWidth: true
                        }
                        Text { text: popupRoot.brightVal1 + "%"; color: Theme.textMain; font { family: Theme.fontMain; pixelSize: 13; bold: true } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: (mouse) => {
                            var pct = Math.min(100, Math.max(0, Math.round((mouse.x / width) * 100)))
                            popupRoot.brightVal1 = pct
                            bright1Proc.command = ["brightnessctl", "s", pct + "%"]
                            bright1Proc.running = true
                            if (popupRoot.osdItem) popupRoot.osdItem.showBrightness(pct, false)
                        }
                        onPressed: (mouse) => {
                            var pct = Math.min(100, Math.max(0, Math.round((mouse.x / width) * 100)))
                            popupRoot.brightVal1 = pct
                            bright1Proc.command = ["brightnessctl", "s", pct + "%"]
                            bright1Proc.running = true
                            if (popupRoot.osdItem) popupRoot.osdItem.showBrightness(pct, false)
                        }
                    }
                }

                // 🔆 BRIGHTNESS SLIDER 2 (SECONDARY / SECOND MONITOR - AUTOMATICALLY APPEARS WHEN EXTERNAL MONITOR CONNECTED)
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1
                    visible: popupRoot.displayCount >= 2

                    Rectangle {
                        height: parent.height
                        width: parent.width * (popupRoot.brightVal2 / 100)
                        radius: parent.radius
                        color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        Text { text: "󰃠"; color: Theme.accent; font { family: Theme.fontMono; pixelSize: 18 } }
                        Text {
                            text: popupRoot.brightName2 !== "" ? popupRoot.brightName2 : "Screen Brightness (second)"
                            color: Theme.textMain
                            font { family: Theme.fontMain; pixelSize: 13; bold: true }
                            Layout.fillWidth: true
                        }
                        Text { text: popupRoot.brightVal2 + "%"; color: Theme.textMain; font { family: Theme.fontMain; pixelSize: 13; bold: true } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: (mouse) => {
                            var pct = Math.min(100, Math.max(0, Math.round((mouse.x / width) * 100)))
                            popupRoot.brightVal2 = pct
                            if (popupRoot.brightType2.indexOf("ddcutil") === 0) {
                                bright2Proc.command = ["ddcutil", "setvcp", "10", pct.toString()]
                            } else if (popupRoot.brightType2.indexOf("brightnessctl:") === 0) {
                                var dev = popupRoot.brightType2.split(":")[1]
                                bright2Proc.command = ["brightnessctl", "-d", dev, "s", pct + "%"]
                            } else {
                                bright2Proc.command = ["brightnessctl", "s", pct + "%"]
                            }
                            bright2Proc.running = true
                            if (popupRoot.osdItem) popupRoot.osdItem.showBrightness(pct, true)
                        }
                        onPressed: (mouse) => {
                            var pct = Math.min(100, Math.max(0, Math.round((mouse.x / width) * 100)))
                            popupRoot.brightVal2 = pct
                            if (popupRoot.brightType2.indexOf("ddcutil") === 0) {
                                bright2Proc.command = ["ddcutil", "setvcp", "10", pct.toString()]
                            } else if (popupRoot.brightType2.indexOf("brightnessctl:") === 0) {
                                var dev = popupRoot.brightType2.split(":")[1]
                                bright2Proc.command = ["brightnessctl", "-d", dev, "s", pct + "%"]
                            } else {
                                bright2Proc.command = ["brightnessctl", "s", pct + "%"]
                            }
                            bright2Proc.running = true
                            if (popupRoot.osdItem) popupRoot.osdItem.showBrightness(pct, true)
                        }
                    }
                }

                // 🔊 VOLUME SLIDER
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 46
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1

                    Rectangle {
                        height: parent.height
                        width: parent.width * Math.min(1.0, Math.max(0, popupRoot.volumeVal / 150))
                        radius: parent.radius
                        color: popupRoot.volumeMuted
                            ? Qt.rgba(243/255, 139/255, 168/255, 0.25)
                            : (popupRoot.volumeVal > 100
                                ? Qt.rgba(243/255, 139/255, 168/255, 0.35)
                                : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25))
                        Behavior on width { NumberAnimation { duration: 80 } }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        Text {
                            text: popupRoot.volumeMuted ? "󰝟" : (popupRoot.volumeVal > 100 ? "󱄡" : (popupRoot.volumeVal >= 66 ? "󰕾" : (popupRoot.volumeVal >= 33 ? "󰖀" : "󰕿")))
                            color: popupRoot.volumeMuted ? "#f38ba8" : (popupRoot.volumeVal > 100 ? "#f38ba8" : Theme.accent)
                            font { family: Theme.fontMono; pixelSize: 18 }
                        }
                        Text {
                            text: "Volume"
                            color: Theme.textMain
                            font { family: Theme.fontMain; pixelSize: 13; bold: true }
                            Layout.fillWidth: true
                        }
                        Text {
                            text: popupRoot.volumeVal + "%"
                            color: popupRoot.volumeMuted ? "#f38ba8" : (popupRoot.volumeVal > 100 ? "#f38ba8" : Theme.textMain)
                            font { family: Theme.fontMain; pixelSize: 13; bold: true }
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onPositionChanged: (mouse) => {
                            var pct = Math.min(150, Math.max(0, Math.round((mouse.x / width) * 150)))
                            popupRoot.volumeVal = pct
                            volProc.command = ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", pct + "%"]
                            volProc.running = true
                            if (popupRoot.osdItem) popupRoot.osdItem.showVolume(pct, popupRoot.volumeMuted)
                        }
                        onPressed: (mouse) => {
                            var pct = Math.min(150, Math.max(0, Math.round((mouse.x / width) * 150)))
                            popupRoot.volumeVal = pct
                            volProc.command = ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", pct + "%"]
                            volProc.running = true
                            if (popupRoot.osdItem) popupRoot.osdItem.showVolume(pct, popupRoot.volumeMuted)
                        }
                    }
                }
            }

            // ─── 🅱️ PAGE 1: DETAIL LIST PAGE (WI-FI OR BLUETOOTH LIST) ──────
            ColumnLayout {
                id: detailPage
                width: bodyContainer.width
                height: bodyContainer.height
                x: popupRoot.expandedMode === "wifi_connect" ? -bodyContainer.width : (popupRoot.expandedMode !== "" ? 0 : bodyContainer.width)
                spacing: 8

                Behavior on x {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }

                // 📌 DETAIL PAGE HEADER (Back Arrow + Title + Refresh + Master Switch)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // ⬅️ BACK BUTTON
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: backHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰁍"
                            color: Theme.textMain
                            font { family: Theme.fontMono; pixelSize: 16 }
                        }

                        HoverHandler { id: backHover }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popupRoot.expandedMode = ""
                        }
                    }

                    // 🏷️ PAGE TITLE
                    Text {
                        text: (popupRoot.expandedMode === "wifi" || popupRoot.expandedMode === "wifi_connect") ? "Wi-Fi Networks" : "Bluetooth Devices"
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 14; bold: true }
                        Layout.fillWidth: true
                    }

                    // 󰑐 REFRESH / SCAN BUTTON
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: refreshHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰑐"
                            color: Theme.accent
                            font { family: Theme.fontMono; pixelSize: 15 }
                        }

                        HoverHandler { id: refreshHover }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (popupRoot.expandedMode === "wifi" || popupRoot.expandedMode === "wifi_connect") {
                                    wifiProc.running = false; wifiProc.running = true
                                } else {
                                    btProc.running = false; btProc.running = true
                                }
                            }
                        }
                    }

                    // 🎚️ TOGGLE SWITCH BUTTON
                    Rectangle {
                        id: toggleSwitchTrack
                        implicitWidth: 44
                        implicitHeight: 24
                        radius: 12
                        readonly property bool isToggled: (popupRoot.expandedMode === "wifi" || popupRoot.expandedMode === "wifi_connect") ? popupRoot.wifiEnabled : popupRoot.btStatus !== "off"
                        color: isToggled ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.18)

                        Behavior on color { ColorAnimation { duration: 200 } }

                        // ⚪ SLIDING KNOB THUMB
                        Rectangle {
                            id: toggleSwitchKnob
                            width: 18
                            height: 18
                            radius: 9
                            anchors.verticalCenter: parent.verticalCenter
                            x: toggleSwitchTrack.isToggled ? (toggleSwitchTrack.width - width - 3) : 3
                            color: toggleSwitchTrack.isToggled ? Theme.bgDark : Theme.textMain

                            Behavior on x { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 200 } }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (popupRoot.expandedMode === "wifi" || popupRoot.expandedMode === "wifi_connect") {
                                    popupRoot.wifiEnabled = !popupRoot.wifiEnabled
                                    wifiToggleProc.command = ["nmcli", "radio", "wifi", popupRoot.wifiEnabled ? "on" : "off"]
                                    wifiToggleProc.running = true
                                } else {
                                    var turningOff = (popupRoot.btStatus !== "off")
                                    popupRoot.btStatus = turningOff ? "off" : "on"
                                    btToggleProc.command = ["bluetoothctl", "power", turningOff ? "off" : "on"]
                                    btToggleProc.running = true
                                }
                            }
                        }
                    }
                }

                // 📋 DETAIL LIST CONTAINER
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.04)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1
                    clip: true

                    // 📡 WI-FI LIST
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 6
                        clip: true
                        spacing: 4
                        visible: popupRoot.expandedMode === "wifi" || popupRoot.expandedMode === "wifi_connect"
                        model: popupRoot.wifiNetworks

                        delegate: Rectangle {
                            width: ListView.view.width
                            implicitHeight: 34
                            radius: 8
                            color: modelData.connected
                                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
                                : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: popupRoot.wifiSigIcon(modelData.signal)
                                    color: modelData.connected ? Theme.accent : Theme.textMain
                                    font { family: Theme.fontMono; pixelSize: 16 }
                                }
                                Text {
                                    text: modelData.ssid
                                    color: Theme.textMain
                                    font { family: Theme.fontMain; pixelSize: 14; bold: modelData.connected }
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.signal + "%"
                                    color: Theme.secondary
                                    font { family: Theme.fontMain; pixelSize: 12 }
                                }
                                Text {
                                    text: modelData.connected ? "Connected" : "Connect"
                                    color: modelData.connected ? Theme.accent : Theme.secondary
                                    font { family: Theme.fontMain; pixelSize: 12; bold: modelData.connected }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (!modelData.connected) {
                                                popupRoot.connectingSSID = modelData.ssid
                                                popupRoot.connectStatusMsg = ""
                                                popupRoot.isConnecting = false
                                                popupRoot.showPassword = false
                                                passInput.text = ""
                                                popupRoot.expandedMode = "wifi_connect"
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Empty state (scanning)
                        Text {
                            anchors.centerIn: parent
                            text: "Scanning networks…"
                            color: Theme.secondary
                            font { family: Theme.fontMain; pixelSize: 12 }
                            visible: popupRoot.wifiNetworks.length === 0
                        }
                    }

                    // 󰂯 BLUETOOTH LIST
                    ListView {
                        anchors.fill: parent
                        anchors.margins: 6
                        clip: true
                        spacing: 4
                        visible: popupRoot.expandedMode === "bt"
                        model: popupRoot.btDevices

                        delegate: Rectangle {
                            width: ListView.view.width
                            implicitHeight: 34
                            radius: 8
                            color: modelData.connected
                                ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18)
                                : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: modelData.connected ? "󰂯" : "󰂲"
                                    color: modelData.connected ? Theme.accent : Theme.secondary
                                    font { family: Theme.fontMono; pixelSize: 16 }
                                }
                                Text {
                                    text: modelData.name
                                    color: Theme.textMain
                                    font { family: Theme.fontMain; pixelSize: 14; bold: modelData.connected }
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                Text {
                                    text: modelData.connected ? "Connected" : "Connect"
                                    color: modelData.connected ? Theme.accent : Theme.secondary
                                    font { family: Theme.fontMain; pixelSize: 12; bold: modelData.connected }
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (!modelData.connected) {
                                                var p = Qt.createQmlObject('import Quickshell.Io; Process{}', popupRoot)
                                                p.command = ["bluetoothctl", "connect", modelData.mac]
                                                p.running = true
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Empty state
                        Text {
                            anchors.centerIn: parent
                            text: "No paired devices"
                            color: Theme.secondary
                            font { family: Theme.fontMain; pixelSize: 12 }
                            visible: popupRoot.btDevices.length === 0
                        }
                    }
                }
            }

            // ─── Ⓒ PAGE 2: WI-FI PASSWORD INPUT PAGE ────────────────────────
            ColumnLayout {
                id: wifiConnectPage
                width: bodyContainer.width
                height: bodyContainer.height
                x: popupRoot.expandedMode === "wifi_connect" ? 0 : bodyContainer.width
                spacing: 10

                Behavior on x {
                    NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                }

                // 📌 CONNECT PAGE HEADER (Back Arrow + Title)
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // ⬅️ BACK BUTTON (Kembali ke List Wi-Fi)
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        color: connBackHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)

                        Behavior on color { ColorAnimation { duration: 150 } }

                        Text {
                            anchors.centerIn: parent
                            text: "󰁍"
                            color: Theme.textMain
                            font { family: Theme.fontMono; pixelSize: 16 }
                        }

                        HoverHandler { id: connBackHover }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: popupRoot.expandedMode = "wifi"
                        }
                    }

                    // 🏷️ PAGE TITLE
                    Text {
                        text: "Enter Password"
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 14; bold: true }
                        Layout.fillWidth: true
                    }
                }

                // 📦 CARD INPUT CONTAINER
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.04)
                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12

                        // 📡 TARGET SSID DISPLAY ROW
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 10

                            Text {
                                text: "󰤨"
                                color: Theme.accent
                                font { family: Theme.fontMono; pixelSize: 20 }
                            }

                            ColumnLayout {
                                spacing: 1
                                Layout.fillWidth: true

                                Text {
                                    text: "Connect to"
                                    color: Theme.secondary
                                    font { family: Theme.fontMain; pixelSize: 11 }
                                }

                                Text {
                                    text: popupRoot.connectingSSID
                                    color: Theme.textMain
                                    font { family: Theme.fontMain; pixelSize: 14; bold: true }
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                            }
                        }

                        // 🔒 PASSWORD INPUT BOX
                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 38
                            radius: 10
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                            border.color: passInput.activeFocus ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                            border.width: 1

                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 10
                                spacing: 8

                                Text {
                                    text: "󰌾"
                                    color: Theme.secondary
                                    font { family: Theme.fontMono; pixelSize: 15 }
                                }

                                TextInput {
                                    id: passInput
                                    Layout.fillWidth: true
                                    color: Theme.textMain
                                    font { family: Theme.fontMain; pixelSize: 13 }
                                    echoMode: popupRoot.showPassword ? TextInput.Normal : TextInput.Password
                                    clip: true
                                    activeFocusOnPress: true

                                    Text {
                                        text: "Enter Wi-Fi password"
                                        color: Theme.secondary
                                        font { family: Theme.fontMain; pixelSize: 13 }
                                        visible: passInput.text === "" && !passInput.activeFocus
                                    }

                                    onAccepted: connectBtn.submitConnect()
                                }

                                // 👁️ TOGGLE SHOW/HIDE PASSWORD
                                Text {
                                    text: popupRoot.showPassword ? "󰈈" : "󰈂"
                                    color: Theme.secondary
                                    font { family: Theme.fontMono; pixelSize: 16 }

                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: popupRoot.showPassword = !popupRoot.showPassword
                                    }
                                }
                            }
                        }

                        // 💬 STATUS MESSAGE & ACTION BUTTONS
                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: popupRoot.connectStatusMsg
                                color: popupRoot.connectStatusMsg === "Connected!" ? Theme.accent : "#f38ba8"
                                font { family: Theme.fontMain; pixelSize: 12; bold: true }
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                            // 🔵 CONNECT BUTTON
                            Rectangle {
                                id: connectBtn
                                implicitWidth: 90
                                implicitHeight: 32
                                radius: 8
                                color: popupRoot.isConnecting
                                    ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
                                    : (connBtnHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.85) : Theme.accent)

                                Behavior on color { ColorAnimation { duration: 150 } }

                                HoverHandler { id: connBtnHover }

                                Text {
                                    anchors.centerIn: parent
                                    text: popupRoot.isConnecting ? "Connecting…" : "Connect"
                                    color: Theme.bgDark
                                    font { family: Theme.fontMain; pixelSize: 12; bold: true }
                                }

                                function submitConnect() {
                                    if (popupRoot.isConnecting || popupRoot.connectingSSID === "") return
                                    popupRoot.isConnecting = true
                                    popupRoot.connectStatusMsg = "Connecting…"
                                    if (passInput.text.trim() !== "") {
                                        wifiConnectProc.command = ["nmcli", "dev", "wifi", "connect", popupRoot.connectingSSID, "password", passInput.text]
                                    } else {
                                        wifiConnectProc.command = ["nmcli", "dev", "wifi", "connect", popupRoot.connectingSSID]
                                    }
                                    wifiConnectProc.running = true
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: connectBtn.submitConnect()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
