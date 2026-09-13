import "../../../services"
import "../../../theme"
import "../../../widgets"
import "./powerStyle"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// 🔌 POWER MENU POPUP DROPDOWN (DYNAMIC ORIGINAL VS MACOS STYLE)
BasePopup {
    id: powerPopup

    property string userNameText: "User"
    property string uptimeText: "Uptime: -"

    implicitWidth: (SettingsStore.popupStyle === "macos") ? 260 : 240
    implicitHeight: (styleLoader.item && styleLoader.item.implicitHeight > 0) ? styleLoader.item.implicitHeight + 28 : 280
    targetCardHeight: implicitHeight

    // ─── SYSTEM ACTION PROCESSES ─────────────────────────────────────────────
    Process {
        id: shutdownProc

        command: ["systemctl", "poweroff"]
    }

    Process {
        id: rebootProc

        command: ["systemctl", "reboot"]
    }

    Process {
        id: suspendProc

        command: ["systemctl", "suspend"]
    }

    Process {
        id: lockProc

        command: ["quickshell", "ipc", "call", "lockscreen", "lock"]
    }

    Process {
        id: logoutProc

        command: ["bash", "-c", "niri msg action quit --skip-confirmation 2>/dev/null || hyprctl dispatch exit 2>/dev/null || loginctl terminate-user $USER"]
    }

    Loader {
        id: styleLoader

        anchors.fill: parent
        source: (SettingsStore.popupStyle === "macos") ? Qt.resolvedUrl("./powerStyle/PowerStyleMacos.qml") : Qt.resolvedUrl("./powerStyle/PowerStyleOriginal.qml")
        onLoaded: {
            if (item) {
                item.userNameText = Qt.binding(function() {
                    return powerPopup.userNameText;
                });
                item.uptimeText = Qt.binding(function() {
                    return powerPopup.uptimeText;
                });
                item.shutdownClicked.connect(function() {
                    powerPopup.isOpen = false;
                    shutdownProc.running = true;
                });
                item.rebootClicked.connect(function() {
                    powerPopup.isOpen = false;
                    rebootProc.running = true;
                });
                item.suspendClicked.connect(function() {
                    powerPopup.isOpen = false;
                    suspendProc.running = true;
                });
                item.lockClicked.connect(function() {
                    powerPopup.isOpen = false;
                    lockProc.running = true;
                });
                item.logoutClicked.connect(function() {
                    powerPopup.isOpen = false;
                    logoutProc.running = true;
                });
            }
        }
    }

}
