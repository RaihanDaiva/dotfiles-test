import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
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
        screen: controlWidgetRoot.barWindow ? controlWidgetRoot.barWindow.screen : null
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

    // 🔆 BRIGHTNESS STARTUP READER (membaca nilai asli sebelum sys_info.sh selesai)
    property int _brightCurrent: -1
    property int _brightMax: -1

    Process {
        id: brightCurrentProc
        command: ["brightnessctl", "g"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var cur = parseInt(this.text.trim())
                if (!isNaN(cur)) {
                    controlWidgetRoot._brightCurrent = cur
                    if (controlWidgetRoot._brightMax > 0)
                        controlWidgetRoot.brightPercent = Math.round(controlWidgetRoot._brightCurrent * 100 / controlWidgetRoot._brightMax)
                }
            }
        }
    }

    Process {
        id: brightMaxProc
        command: ["brightnessctl", "m"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var mx = parseInt(this.text.trim())
                if (!isNaN(mx) && mx > 0) {
                    controlWidgetRoot._brightMax = mx
                    if (controlWidgetRoot._brightCurrent >= 0)
                        controlWidgetRoot.brightPercent = Math.round(controlWidgetRoot._brightCurrent * 100 / mx)
                }
            }
        }
    }

    // 🔆 REAL-TIME KERNEL BACKLIGHT EVENT LISTENER (0ms latency, zero CPU usage saat idle)
    Process {
        id: brightUdevProc
        command: ["udevadm", "monitor", "--subsystem-match=backlight"]
        running: true
        stdout: SplitParser {
            onRead: (data) => {
                brightFetchProc.running = false
                brightFetchProc.running = true
            }
        }
    }

    Process {
        id: brightFetchProc
        command: ["brightnessctl", "g"]
        stdout: StdioCollector {
            onStreamFinished: {
                var cur = parseInt(this.text.trim())
                if (!isNaN(cur) && cur >= 0) {
                    controlWidgetRoot._brightCurrent = cur
                    if (controlWidgetRoot._brightMax > 0) {
                        var bp = Math.round(cur * 100 / controlWidgetRoot._brightMax)
                        if (controlWidgetRoot.prevBright !== -1 && controlWidgetRoot.prevBright !== bp) {
                            osdPopup.showBrightness(bp, false)
                        }
                        controlWidgetRoot.brightPercent = bp
                        controlWidgetRoot.prevBright = bp
                    }
                }
            }
        }
    }

    // 📡 QUICKSHELL IPC HANDLER FOR BRIGHTNESS SHORTCUTS
    IpcHandler {
        target: "brightness"

        function raise() {
            brightSetProc.command = ["brightnessctl", "s", "+5%"]
            brightSetProc.running = true
        }

        function lower() {
            brightSetProc.command = ["brightnessctl", "s", "5%-"]
            brightSetProc.running = true
        }
    }

    Process { id: brightSetProc }

    // 🔊 REAL-TIME PULSE/PIPEWIRE VOLUME EVENT LISTENER (0ms latency, instant OSD)
    property bool prevMuted: false

    Process {
        id: volSubscribeProc
        command: ["pactl", "subscribe"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                if (line.indexOf("change") !== -1 && line.indexOf("sink") !== -1) {
                    volReadProc.running = false
                    volReadProc.running = true
                }
            }
        }
    }

    Process {
        id: volReadProc
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var text = this.text.trim()
                var isMuted = text.indexOf("[MUTED]") !== -1
                var match = text.match(/Volume:\s*([0-9.]+)/)
                if (match && match[1]) {
                    var raw = parseFloat(match[1])
                    if (!isNaN(raw)) {
                        var v = Math.round(raw * 100)
                        if (controlWidgetRoot.prevVol !== -1 && (controlWidgetRoot.prevVol !== v || controlWidgetRoot.prevMuted !== isMuted)) {
                            osdPopup.showVolume(v, isMuted)
                        }
                        controlWidgetRoot.volPercent = v
                        controlWidgetRoot.volMuted = isMuted ? "muted" : "unmuted"
                        controlWidgetRoot.prevVol = v
                        controlWidgetRoot.prevMuted = isMuted
                    }
                }
            }
        }
    }

    // 📡 QUICKSHELL IPC HANDLER FOR VOLUME SHORTCUTS
    IpcHandler {
        target: "volume"

        function raise() {
            volActionProc.command = ["wpctl", "set-volume", "-l", "1.5", "@DEFAULT_AUDIO_SINK@", "5%+"]
            volActionProc.running = true
        }

        function lower() {
            volActionProc.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", "5%-"]
            volActionProc.running = true
        }

        function mute() {
            volActionProc.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"]
            volActionProc.running = true
        }
    }

    Process { id: volActionProc }

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
            onClicked: {
                quickSettingsPopup.isOpen = !quickSettingsPopup.isOpen
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
                    font { family: Theme.fontMono; pixelSize: 18 }
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
                    font { family: Theme.fontMono; pixelSize: 18 }
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
                    font { family: Theme.fontMono; pixelSize: 18 }
                }
            }

            // 📡 WI-FI
            RowLayout {
                spacing: 4
                Text {
                    text: wifiIcon
                    color: wifiColor
                    font { family: Theme.fontMono; pixelSize: 18 }
                }
            }

            // 🔋 BATTERY
            RowLayout {
                spacing: 4
                Text {
                    text: batIcon
                    color: batColor
                    font { family: Theme.fontMono; pixelSize: 18 }
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
