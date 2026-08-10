import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "systemStatsWidget"

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

    // 🌟 POPUP METRICS
    property int cpuLoadPercent: 0
    property int cpuTempValue: 0
    property int gpuLoadPercent: 0
    property int gpuTempValue: 0
    property int ramPercent: 0
    property string ramUsageDetails: "0 / 0 GB"
    property int diskPercent: 0
    property string diskDetails: "0 / 0 GB"

    // ⏱️ TIMER DELAY HOVER POPUP
    Timer {
        id: closeTimer
        interval: 300
        onTriggered: sysStatsPopup.isOpen = false
    }

    // 🪟 SUB-KOMPONEN 1: SYSTEM MONITOR POPUP CARD
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

        onKeepOpen: closeTimer.stop()
        onStartCloseTimer: closeTimer.restart()
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
    readonly property color btColor: (btStatus === "on" || btStatus === "connected") ? Theme.accent : Theme.accent

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
        spacing: 14

        // 🧠🌡️ PILL RECTANGLE GABUNGAN RAM & CPU TEMP (HOVER TRIGGER FOR POPUP)
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
                    closeTimer.stop()
                    sysStatsPopup.isOpen = true
                }
                onExited: {
                    closeTimer.restart()
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

        // 󰂯 Bluetooth
        RowLayout {
            spacing: 4
            Text {
                text: btIcon
                color: btColor
                font { family: Theme.fontMono; pixelSize: 16 }
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }

        // 📡 Wi-Fi
        RowLayout {
            spacing: 4
            Text {
                text: wifiIcon
                color: wifiColor
                font { family: Theme.fontMono; pixelSize: 16 }
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }

        // 🔋 Battery
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