import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../../components/popups"

Rectangle {
    id: statsRoot

    property var barWindow: null

    implicitWidth: statsLayout.implicitWidth + 24
    implicitHeight: 32
    color: "transparent"
    radius: 10

    property string ramText: "0Gi"
    property string cpuTempText: "0°C"
    property int batCap: 100
    property string batStatus: "Discharging"
    property int wifiSignal: -1
    property string btStatus: "off"

    // 🔆 BRIGHTNESS & 🔊 VOLUME METRICS
    property int brightPercent: 100
    property int volPercent: 80
    property string volMuted: "unmuted"

    property int prevVol: -1
    property int prevBright: -1

    onVolPercentChanged: {
        if (prevVol !== -1 && prevVol !== volPercent) {
            osdPopup.showVolume(volPercent, volMuted === "muted")
        }
        prevVol = volPercent
    }

    onBrightPercentChanged: {
        if (prevBright !== -1 && prevBright !== brightPercent) {
            osdPopup.showBrightness(brightPercent, false)
        }
        prevBright = brightPercent
    }

    // 🌟 POPUP METRICS
    property int cpuLoadPercent: 0
    property int cpuTempValue: 0
    property int gpuLoadPercent: 0
    property int gpuTempValue: 0
    property int ramPercent: 0
    property string ramUsageDetails: "0 / 0 GB"
    property int diskPercent: 0
    property string diskDetails: "0 / 0 GB"

    // ⏱️ TIMER DELAY HOVER POPUP SYSTEM MONITOR
    Timer {
        id: closeSysTimer
        interval: 300
        onTriggered: sysStatsPopup.isOpen = false
    }

    // ⏱️ TIMER DELAY HOVER POPUP QUICK SETTINGS
    Timer {
        id: closeQuickTimer
        interval: 300
        onTriggered: quickSettingsPopup.isOpen = false
    }

    // 🪟 SUB-KOMPONEN 1: SYSTEM MONITOR PERFORMANCE POPUP CARD (Dari components/popups/)
    SysStatsPopup {
        id: sysStatsPopup
        barWindow: statsRoot.barWindow
        statsRootItem: ramTempPill

        cpuLoadPercent: statsRoot.cpuLoadPercent
        cpuTempText: statsRoot.cpuTempText
        cpuTempValue: statsRoot.cpuTempValue
        gpuLoadPercent: statsRoot.gpuLoadPercent
        gpuTempValue: statsRoot.gpuTempValue
        ramPercent: statsRoot.ramPercent
        ramUsageDetails: statsRoot.ramUsageDetails
        diskPercent: statsRoot.diskPercent
        diskDetails: statsRoot.diskDetails

        onKeepOpen: closeSysTimer.stop()
        onStartCloseTimer: closeSysTimer.restart()
    }

    // 🎚️ SUB-KOMPONEN 0: ON-SCREEN DISPLAY (OSD) OVERLAY POPUP CARD
    OsdPopup {
        id: osdPopup
    }

    // 🪟 SUB-KOMPONEN 2: QUICK SETTINGS / CONTROL CENTER POPUP CARD (Dari components/popups/)
    QuickSettingsPopup {
        id: quickSettingsPopup
        barWindow: statsRoot.barWindow
        controlRootItem: controlPill
        osdItem: osdPopup

        onKeepOpen: closeQuickTimer.stop()
        onStartCloseTimer: closeQuickTimer.restart()
    }

    // 🔊 Dynamic Volume Icon Logic
    readonly property string volIcon: {
        if (volMuted === "muted" || volPercent <= 0) return "󰝟"
        if (volPercent >= 66) return "󰕾"
        if (volPercent >= 33) return "󰖀"
        return "󰕿"
    }

    // 🔋 Dynamic Battery Icon Logic
    readonly property string batIcon: {
        if (batStatus === "Charging") return "󰂄"
        if (batCap >= 90) return "󰁹"
        if (batCap >= 70) return "󰂀"
        if (batCap >= 50) return "󰁾"
        if (batCap >= 30) return "󰁽"
        if (batCap >= 15) return "󰁼"
        return "󰂃"
    }

    readonly property color batColor: {
        if (batStatus === "Charging") return Theme.accent
        if (batCap <= 20) return "#f38ba8"
        return Theme.accent
    }

    // 📡 Dynamic Wi-Fi Icon Logic
    readonly property string wifiIcon: {
        if (wifiSignal >= 75) return "󰤨"
        if (wifiSignal >= 50) return "󰤥"
        if (wifiSignal >= 25) return "󰤢"
        if (wifiSignal >= 1) return "󰤟"
        return "󰤮"
    }

    readonly property color wifiColor: wifiSignal >= 1 ? Theme.accent : Theme.secondary

    // 󰂯 Dynamic Bluetooth Icon Logic
    readonly property string btIcon: (btStatus === "on" || btStatus === "connected") ? "󰂯" : "󰂲"
    readonly property color btColor: (btStatus === "on" || btStatus === "connected") ? Theme.accent : Theme.secondary

    // ⚡ REAL-TIME SYSTEM EVENT MONITOR (0ms latency for Fn Volume & Brightness keys)
    Process {
        id: eventMonitorProc
        command: [Quickshell.configDir + "/scripts/sys_event_monitor.sh"]
        running: true

        stdout: SplitParser {
            onRead: data => {
                var line = data.trim()
                if (line.indexOf("VOL:") === 0) {
                    var parts = line.split(":")
                    if (parts.length >= 3) {
                        var v = parseInt(parts[1])
                        var m = parts[2]
                        if (!isNaN(v)) {
                            if (statsRoot.prevVol !== -1 && statsRoot.prevVol !== v) {
                                osdPopup.showVolume(v, m === "muted")
                            }
                            statsRoot.volPercent = v
                            statsRoot.volMuted = m
                            statsRoot.prevVol = v
                        }
                    }
                } else if (line.indexOf("BRIGHT:") === 0) {
                    var parts = line.split(":")
                    if (parts.length >= 2) {
                        var b = parseInt(parts[1])
                        if (!isNaN(b)) {
                            if (statsRoot.prevBright !== -1 && statsRoot.prevBright !== b) {
                                osdPopup.showBrightness(b, false)
                            }
                            statsRoot.brightPercent = b
                            statsRoot.prevBright = b
                        }
                    }
                }
            }
        }
    }

    Process {
        id: sysProcess
        command: [Quickshell.configDir + "/scripts/sys_info.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 1 && lines[0] !== "") ramText = lines[0]
                if (lines.length >= 2 && lines[1] !== "") cpuTempText = lines[1]
                if (lines.length >= 3 && lines[2] !== "") batCap = parseInt(lines[2]) || 100
                if (lines.length >= 4 && lines[3] !== "") batStatus = lines[3].trim()
                if (lines.length >= 5 && lines[4] !== "") wifiSignal = parseInt(lines[4]) || -1
                if (lines.length >= 6 && lines[5] !== "") btStatus = lines[5].trim()
                if (lines.length >= 7 && lines[6] !== "") cpuLoadPercent = parseInt(lines[6]) || 0
                if (lines.length >= 8 && lines[7] !== "") cpuTempValue = parseInt(lines[7]) || 0
                if (lines.length >= 9 && lines[8] !== "") ramPercent = parseInt(lines[8]) || 0
                if (lines.length >= 10 && lines[9] !== "") ramUsageDetails = lines[9].trim()
                if (lines.length >= 11 && lines[10] !== "") diskPercent = parseInt(lines[10]) || 0
                if (lines.length >= 12 && lines[11] !== "") diskDetails = lines[11].trim()
                if (lines.length >= 13 && lines[12] !== "") gpuLoadPercent = parseInt(lines[12]) || 0
                if (lines.length >= 14 && lines[13] !== "") gpuTempValue = parseInt(lines[13]) || 0
                if (lines.length >= 15 && lines[14] !== "") volPercent = parseInt(lines[14]) || 0
                if (lines.length >= 16 && lines[15] !== "") volMuted = lines[15].trim()
                if (lines.length >= 17 && lines[16] !== "") {
                    var bp = parseInt(lines[16])
                    brightPercent = isNaN(bp) ? 100 : bp
                }
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            sysProcess.running = false
            sysProcess.running = true
        }
    }

    RowLayout {
        id: statsLayout
        anchors.centerIn: parent
        spacing: 10

        // 🧠🌡️ PILL RECTANGLE 1: RAM & CPU TEMP (HOVER TRIGGER FOR SYSSTATS POPUP)
        Rectangle {
            id: ramTempPill
            implicitWidth: ramTempLayout.implicitWidth + 12
            implicitHeight: 26
            radius: 8
            color: (ramTempMouseArea.containsMouse || sysStatsPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
            border.color: (ramTempMouseArea.containsMouse || sysStatsPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: ramTempMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    closeSysTimer.stop()
                    sysStatsPopup.isOpen = true
                }
                onExited: {
                    closeSysTimer.restart()
                }
            }

            RowLayout {
                id: ramTempLayout
                anchors.centerIn: parent
                spacing: 10

                // 🧠 RAM
                RowLayout {
                    spacing: 4
                    Text {
                        text: "󰍛"
                        color: Theme.accent
                        font { family: Theme.fontMono; pixelSize: 15 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                    Text {
                        text: ramText
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 13; bold: true }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                }

                // 🌡️ CPU Temp
                RowLayout {
                    spacing: 4
                    Text {
                        text: "󰔏"
                        color: Theme.accent
                        font { family: Theme.fontMono; pixelSize: 15 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                    Text {
                        text: cpuTempText
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 13; bold: true }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                }
            }
        }

        // 🎛️ PILL RECTANGLE 2: VOLUME %, BLUETOOTH, & WI-FI (HOVER TRIGGER FOR CONTROL CENTER POPUP)
        Rectangle {
            id: controlPill
            implicitWidth: controlLayout.implicitWidth + 12
            implicitHeight: 26
            radius: 8
            color: (controlMouseArea.containsMouse || quickSettingsPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
            border.color: (controlMouseArea.containsMouse || quickSettingsPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: controlMouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    closeQuickTimer.stop()
                    quickSettingsPopup.isOpen = true
                }
                onExited: {
                    closeQuickTimer.restart()
                }
            }

            RowLayout {
                id: controlLayout
                anchors.centerIn: parent
                spacing: 10

                // 🔆 BRIGHTNESS % (Disebelah Kiri Volume)
                RowLayout {
                    spacing: 4
                    Text {
                        text: "󰃠"
                        color: Theme.accent
                        font { family: Theme.fontMono; pixelSize: 15 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                    Text {
                        text: statsRoot.brightPercent + "%"
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 13; bold: true }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                }

                // 🔊 VOLUME %
                RowLayout {
                    spacing: 4
                    Text {
                        text: statsRoot.volIcon
                        color: statsRoot.volMuted === "muted" ? "#f38ba8" : Theme.accent
                        font { family: Theme.fontMono; pixelSize: 15 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                    Text {
                        text: statsRoot.volPercent + "%"
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 13; bold: true }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                }

                // 󰂯 BLUETOOTH
                RowLayout {
                    spacing: 4
                    Text {
                        text: btIcon
                        color: btColor
                        font { family: Theme.fontMono; pixelSize: 15 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                }

                // 📡 WI-FI
                RowLayout {
                    spacing: 4
                    Text {
                        text: wifiIcon
                        color: wifiColor
                        font { family: Theme.fontMono; pixelSize: 15 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                }

                // 🔋 BATTERY (DYNAMIC ICON & CAPACITY TEXT)
                RowLayout {
                    spacing: 4
                    Text {
                        text: batIcon
                        color: batColor
                        font { family: Theme.fontMono; pixelSize: 16 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                    Text {
                        text: batCap + "%"
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 13; bold: true }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }
                }
            }
        }
    }
}