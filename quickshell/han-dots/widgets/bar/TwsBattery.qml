import QtQuick
import Quickshell
import Quickshell.Io

// 🎧 Soundcore R50i TWS Battery Indicator
CircularBatteryPill {
    id: twsRoot

    icon: "󰋋"
    autoHide: true
    tooltipText: "Soundcore R50i"
    Component.onCompleted: {
        twsProcess.running = true;
    }
    onRefreshRequested: {
        twsProcess.running = false;
        twsProcess.running = true;
    }

    Process {
        id: twsProcess

        command: [Quickshell.configDir + "/scripts/tws_battery.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim();
                twsRoot.batteryText = /^(100|[1-9]?\d)%$/.test(value) ? value : "N/A";
            }
        }

    }

    Timer {
        interval: 15000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            twsProcess.running = false;
            twsProcess.running = true;
        }
    }

}
