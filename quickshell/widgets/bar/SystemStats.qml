import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../components/popups"
import "../../theme"

// 📊 SYSTEM PERFORMANCE MONITOR WIDGET (RAM & CPU TEMP)
Item {
    id: statsRoot

    property var barWindow: null

    implicitWidth: ramTempPill.implicitWidth
    implicitHeight: ramTempPill.implicitHeight

    // 🌟 PERFORMANCE METRICS
    property string ramText: "0.0Gi"
    property string cpuTempText: "0°C"
    property int cpuLoadPercent: 0
    property int cpuTempValue: 0
    property int gpuLoadPercent: 0
    property int gpuTempValue: 0
    property int ramPercent: 0
    property string ramUsageDetails: "0 / 0 GB"
    property int diskPercent: 0
    property string diskDetails: "0 / 0 GB"

    // 🪟 SYSTEM MONITOR PERFORMANCE POPUP
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

    Timer {
        id: closeSysTimer
        interval: 300
        onTriggered: sysStatsPopup.isOpen = false
    }

    // 📡 FETCH SYSTEM PERFORMANCE METRICS (sys_info.sh)
    Process {
        id: sysProc
        command: [Quickshell.configDir + "/scripts/sys_info.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 1 && lines[0] !== "") ramText = lines[0]
                if (lines.length >= 2 && lines[1] !== "") cpuTempText = lines[1]
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
            sysProc.running = false
            sysProc.running = true
        }
    }

    // 📦 RAM & TEMP PILL CONTAINER
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
            spacing: 8

            // 󰍛 RAM %
            RowLayout {
                spacing: 4
                Text {
                    text: "󰍛"
                    color: Theme.accent
                    font { family: Theme.fontMono; pixelSize: 15 }
                }
                Text {
                    text: statsRoot.ramText
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                }
            }

            // 󰔏 CPU TEMP
            RowLayout {
                spacing: 4
                Text {
                    text: "󰔏"
                    color: "#f38ba8"
                    font { family: Theme.fontMono; pixelSize: 15 }
                }
                Text {
                    text: statsRoot.cpuTempText
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                }
            }
        }
    }
}