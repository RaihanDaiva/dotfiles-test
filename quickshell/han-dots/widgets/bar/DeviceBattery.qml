import "../../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// 🔋 Unified Peripherals Battery Widget (Mouse & TWS inside 1 single Rectangle)
Rectangle {
    id: root

    // ─────────────────────────────────────────────────────────────────────────
    // 🖱️ MOUSE BATTERY PROCESS
    // ─────────────────────────────────────────────────────────────────────────
    property string mouseBatteryText: "N/A"
    // ─────────────────────────────────────────────────────────────────────────
    // 🎧 TWS SOUNDCORE R50i BATTERY PROCESS
    // ─────────────────────────────────────────────────────────────────────────
    property string twsBatteryText: "N/A"

    function refreshAll() {
        mouseProcess.running = false;
        mouseProcess.running = true;
        twsProcess.running = false;
        twsProcess.running = true;
    }

    // Visual Pill Container
    implicitWidth: devicesRow.implicitWidth + 14
    implicitHeight: 26
    radius: 8
    color: pillHover.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
    border.color: pillHover.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
    border.width: 1
    visible: mouseRing.visible || twsRing.visible
    Component.onCompleted: {
        mouseProcess.running = true;
        twsProcess.running = true;
    }

    Process {
        id: mouseProcess

        command: [Quickshell.configDir + "/scripts/mouse_battery.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim();
                root.mouseBatteryText = /^(100|[1-9]?\d)%$/.test(value) ? value : "N/A";
            }
        }

    }

    Timer {
        id: mouseTimer

        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            mouseProcess.running = false;
            mouseProcess.running = true;
        }
    }

    Process {
        id: twsProcess

        command: [Quickshell.configDir + "/scripts/tws_battery.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim();
                root.twsBatteryText = /^(100|[1-9]?\d)%$/.test(value) ? value : "N/A";
            }
        }

    }

    Timer {
        id: twsTimer

        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            twsProcess.running = false;
            twsProcess.running = true;
        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 📦 SINGLE ROW CONTAINER FOR BOTH INDICATORS
    // ─────────────────────────────────────────────────────────────────────────
    RowLayout {
        id: devicesRow

        anchors.centerIn: parent
        spacing: 8

        // 🖱️ Mouse Battery
        CircularBatteryRing {
            id: mouseRing

            icon: "󰍽"
            batteryText: root.mouseBatteryText
            visible: true
        }

        // 🎧 Soundcore R50i TWS Battery (Auto-hides if disconnected)
        CircularBatteryRing {
            id: twsRing

            icon: "󰋋"
            batteryText: root.twsBatteryText
            visible: isValid
        }

    }

    MouseArea {
        id: pillHover

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.refreshAll()
    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }

    }

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 200
            easing.type: Easing.OutCubic
        }

    }

}
