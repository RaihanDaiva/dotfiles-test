import QtQuick
import Quickshell
import Quickshell.Io

// 🖱️ AJAZZ Mouse Battery Indicator
CircularBatteryPill {
    id: mouseRoot

    icon: "󰍽"
    autoHide: false
    tooltipText: "AJAZZ Mouse"
    Component.onCompleted: {
        mouseProcess.running = true;
    }
    onRefreshRequested: {
        mouseProcess.running = false;
        mouseProcess.running = true;
    }

    Process {
        id: mouseProcess

        command: [Quickshell.configDir + "/scripts/mouse_battery.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim();
                mouseRoot.batteryText = /^(100|[1-9]?\d)%$/.test(value) ? value : "N/A";
            }
        }

    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            mouseProcess.running = false;
            mouseProcess.running = true;
        }
    }

}
