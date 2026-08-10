import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"

Rectangle {
    implicitWidth: statsLayout.implicitWidth + 24
    implicitHeight: 32
    color: "transparent"
    radius: 10

    property string ramText: "0Gi"
    property string cpuTempText: "0°C"
    property int batCap: 100
    property string batStatus: "Discharging"
    property int wifiSignal: -1 // -1 = offline
    property string btStatus: "off" // "on" or "off"

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
        if (batCap <= 20) return "#f38ba8" // Red warning when <= 20%
        return Theme.accent
    }

    // 📡 Dynamic Wi-Fi Icon Logic (No SSID Text)
    readonly property string wifiIcon: {
        if (wifiSignal >= 75) return "󰤨"
        if (wifiSignal >= 50) return "󰤥"
        if (wifiSignal >= 25) return "󰤢"
        if (wifiSignal >= 1) return "󰤟"
        return "󰤮" // Disconnected / Offline
    }

    readonly property color wifiColor: wifiSignal >= 1 ? Theme.accent : Theme.secondary

    // 󰂯 Dynamic Bluetooth Icon Logic (2 Icons: Connected vs Disconnected Slash)
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
                if (lines.length >= 5 && lines[4] !== "") {
                    wifiSignal = parseInt(lines[4]) || -1
                } else {
                    wifiSignal = -1
                }
                if (lines.length >= 6 && lines[5] !== "") {
                    btStatus = lines[5].trim()
                } else {
                    btStatus = "off"
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
        spacing: 14

        // 🧠 RAM
        RowLayout {
            spacing: 4
            Text {
                text: "󰍛"
                color: Theme.accent
                font { family: Theme.fontMono; pixelSize: 16 }
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
            Text {
                text: ramText
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 14; bold: true }
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }

        // 🌡️ CPU Temp
        RowLayout {
            spacing: 4
            Text {
                text: "󰔏"
                color: Theme.accent
                font { family: Theme.fontMono; pixelSize: 16 }
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
            Text {
                text: cpuTempText
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 14; bold: true }
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }

        // 󰂯 Bluetooth (Di antara Suhu dan Wi-Fi)
        RowLayout {
            spacing: 4
            Text {
                text: btIcon
                color: btColor
                font { family: Theme.fontMono; pixelSize: 16 }

                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }

        // 📡 Wi-Fi (Dynamic Icon Only)
        RowLayout {
            spacing: 4
            Text {
                text: wifiIcon
                color: wifiColor
                font { family: Theme.fontMono; pixelSize: 16 }

                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }

        // 🔋 Battery (Dynamic Icon & Capacity Text)
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
                font { family: Theme.fontMain; pixelSize: 14; bold: true }
                Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            }
        }
    }
}