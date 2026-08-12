import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../components/popups"
import "../../theme"

// 🎛️ CONTROL CENTER BAR WIDGET (BRIGHTNESS, VOLUME, BLUETOOTH, WI-FI, BATTERY)
Item {
    id: controlWidgetRoot

    property var barWindow: null

    implicitWidth: controlPill.implicitWidth
    implicitHeight: controlPill.implicitHeight

    // 🔆 BRIGHTNESS & 🔊 VOLUME METRICS
    property int brightPercent: 100
    property int volPercent: 80
    property string volMuted: "unmuted"

    property int prevVol: -1
    property int prevBright: -1

    // 🔋 BATTERY & 📡 NETWORK/BT METRICS
    property int batCap: 100
    property string batStatus: "Discharging"
    property int wifiSignal: -1
    property string btStatus: "off"

    // 🎚️ SUB-KOMPONEN 0: ON-SCREEN DISPLAY (OSD) OVERLAY POPUP CARD
    OsdPopup {
        id: osdPopup
    }

    // 🪟 SUB-KOMPONEN 1: QUICK SETTINGS / CONTROL CENTER POPUP CARD
    QuickSettingsPopup {
        id: quickSettingsPopup
        barWindow: controlWidgetRoot.barWindow
        controlRootItem: controlPill
        osdItem: osdPopup

        onKeepOpen: closeQuickTimer.stop()
        onStartCloseTimer: closeQuickTimer.restart()
    }

    Timer {
        id: closeQuickTimer
        interval: 300
        onTriggered: quickSettingsPopup.isOpen = false
    }

    // 🔊 Dynamic Volume Icon Logic
    readonly property string volIcon: {
        if (volMuted === "muted" || volPercent <= 0) return "󰝟"
        if (volPercent > 100) return "󱄡"
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
                            if (controlWidgetRoot.prevVol !== -1 && controlWidgetRoot.prevVol !== v) {
                                osdPopup.showVolume(v, m === "muted")
                            }
                            controlWidgetRoot.volPercent = v
                            controlWidgetRoot.volMuted = m
                            controlWidgetRoot.prevVol = v
                        }
                    }
                } else if (line.indexOf("BRIGHT:") === 0) {
                    var parts = line.split(":")
                    if (parts.length >= 2) {
                        var b = parseInt(parts[1])
                        if (!isNaN(b)) {
                            if (controlWidgetRoot.prevBright !== -1 && controlWidgetRoot.prevBright !== b) {
                                osdPopup.showBrightness(b, false)
                            }
                            controlWidgetRoot.brightPercent = b
                            controlWidgetRoot.prevBright = b
                        }
                    }
                }
            }
        }
    }

    // 📡 METRICS POLLING PROCESS (sys_info.sh)
    Process {
        id: sysProc
        command: [Quickshell.configDir + "/scripts/sys_info.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 3 && lines[2] !== "") batCap = parseInt(lines[2]) || 100
                if (lines.length >= 4 && lines[3] !== "") batStatus = lines[3].trim()
                if (lines.length >= 5 && lines[4] !== "") wifiSignal = parseInt(lines[4]) || -1
                if (lines.length >= 6 && lines[5] !== "") btStatus = lines[5].trim()
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
            sysProc.running = false
            sysProc.running = true
        }
    }

    // 📦 CONTROL PILL CONTAINER
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

            // 🔆 BRIGHTNESS %
            RowLayout {
                spacing: 4
                Text {
                    text: "󰃠"
                    color: Theme.accent
                    font { family: Theme.fontMono; pixelSize: 15 }
                }
                Text {
                    text: controlWidgetRoot.brightPercent + "%"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                }
            }

            // 🔊 VOLUME %
            RowLayout {
                spacing: 4
                Text {
                    text: controlWidgetRoot.volIcon
                    color: controlWidgetRoot.volMuted === "muted" ? "#f38ba8" : (controlWidgetRoot.volPercent > 100 ? "#f38ba8" : Theme.accent)
                    font { family: Theme.fontMono; pixelSize: 15 }
                }
                Text {
                    text: controlWidgetRoot.volPercent + "%"
                    color: controlWidgetRoot.volMuted === "muted" ? "#f38ba8" : (controlWidgetRoot.volPercent > 100 ? "#f38ba8" : Theme.textMain)
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                }
            }

            // 󰂯 BLUETOOTH
            RowLayout {
                spacing: 4
                Text {
                    text: btIcon
                    color: btColor
                    font { family: Theme.fontMono; pixelSize: 15 }
                }
            }

            // 📡 WI-FI
            RowLayout {
                spacing: 4
                Text {
                    text: wifiIcon
                    color: wifiColor
                    font { family: Theme.fontMono; pixelSize: 15 }
                }
            }

            // 🔋 BATTERY
            RowLayout {
                spacing: 4
                Text {
                    text: batIcon
                    color: batColor
                    font { family: Theme.fontMono; pixelSize: 16 }
                }
                Text {
                    text: batCap + "%"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                }
            }
        }
    }
}
