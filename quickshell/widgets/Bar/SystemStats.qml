import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Rectangle {
    implicitWidth: statsLayout.implicitWidth + 24
    implicitHeight: 32
    color: "transparent"
    radius: 10

    property string ramText: "0Gi"
    property string cpuTempText: "0°C"
    property string batText: "100%"
    property string wifiText: "Offline"

    Process {
        id: sysProcess
        command: [Quickshell.configDir + "/scripts/sys_info.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                if (lines.length >= 1 && lines[0] !== "") ramText = lines[0]
                if (lines.length >= 2 && lines[1] !== "") cpuTempText = lines[1]
                if (lines.length >= 3 && lines[2] !== "") batText = lines[2] + (lines[2].includes("%") ? "" : "%")
                if (lines.length >= 4 && lines[3] !== "") wifiText = lines[3]
            }
        }
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: sysProcess.running = true
    }

    RowLayout {
        id: statsLayout
        anchors.centerIn: parent
        spacing: 12

        RowLayout {
            spacing: 4
            Text { text: "🧠"; font.pixelSize: 12 }
            Text { text: ramText; color: "#cba6f7"; font { pixelSize: 12; bold: true } }
        }

        RowLayout {
            spacing: 4
            Text { text: "🌡️"; font.pixelSize: 12 }
            Text { text: cpuTempText; color: "#f38ba8"; font { pixelSize: 12; bold: true } }
        }

        RowLayout {
            spacing: 4
            Text { text: "🔋"; font.pixelSize: 12 }
            Text { text: batText; color: "#a6e3a1"; font { pixelSize: 12; bold: true } }
        }

        RowLayout {
            spacing: 4
            Text { text: "📡"; font.pixelSize: 12 }
            Text { text: wifiText; color: "#89b4fa"; font { pixelSize: 12; bold: true } }
        }
    }
}