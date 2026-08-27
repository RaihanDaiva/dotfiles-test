import "../../theme"
import "../../widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// 🔌 POWER MENU POPUP DROPDOWN (VERTICAL PILL LIST WITH HYPRLAND BLUR & PYWAL STYLING)
BasePopup {
    id: powerPopup

    // 🎯 USER DATA & METRICS
    property string userNameText: "User"
    property string uptimeText: "Uptime: -"

    implicitWidth: 240
    implicitHeight: mainLayout.implicitHeight + 28

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

        command: ["hyprctl", "dispatch", "exit"]
    }

    // 📦 VERTICAL LIST CONTAINER
    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        spacing: 6

        // Header (Icon & Title)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰐥"
                color: Theme.accent

                font {
                    family: Theme.fontMono
                    pixelSize: 24
                }

            }

            Text {
                text: "Power Options"
                color: Theme.textMain
                Layout.fillWidth: true

                font {
                    family: Theme.fontMain
                    pixelSize: 16
                    bold: true
                }

            }

        }

        // ➖ SEPARATOR LINE
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12)
            Layout.topMargin: 4
            Layout.bottomMargin: 4
        }

        // 1. 󰐥 SHUTDOWN PILL
        Rectangle {
            id: shutdownItem

            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: shutdownHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: shutdownHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰐥"
                    color: shutdownHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.accent) : Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 18
                    }

                }

                Text {
                    text: "Shutdown"
                    color: shutdownHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.textMain) : Theme.textMain
                    Layout.fillWidth: true

                    font {
                        family: Theme.fontMain
                        pixelSize: 15
                        bold: true
                    }

                }

                Text {
                    text: "󰅂"
                    color: shutdownHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)

                    font {
                        family: Theme.fontMono
                        pixelSize: 14
                    }

                }

            }

            HoverHandler {
                id: shutdownHover
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false;
                    shutdownProc.running = true;
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        // 2. 󰑐 REBOOT PILL
        Rectangle {
            id: rebootItem

            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: rebootHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: rebootHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰑐"
                    color: rebootHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.accent) : Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 18
                    }

                }

                Text {
                    text: "Reboot"
                    color: rebootHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.textMain) : Theme.textMain
                    Layout.fillWidth: true

                    font {
                        family: Theme.fontMain
                        pixelSize: 15
                        bold: true
                    }

                }

                Text {
                    text: "󰅂"
                    color: rebootHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)

                    font {
                        family: Theme.fontMono
                        pixelSize: 14
                    }

                }

            }

            HoverHandler {
                id: rebootHover
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false;
                    rebootProc.running = true;
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        // 3. 󰤄 SUSPEND / SLEEP PILL
        Rectangle {
            id: suspendItem

            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: suspendHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: suspendHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰤄"
                    color: suspendHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.accent) : Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 18
                    }

                }

                Text {
                    text: "Suspend"
                    color: suspendHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.textMain) : Theme.textMain
                    Layout.fillWidth: true

                    font {
                        family: Theme.fontMain
                        pixelSize: 15
                        bold: true
                    }

                }

                Text {
                    text: "󰅂"
                    color: suspendHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)

                    font {
                        family: Theme.fontMono
                        pixelSize: 14
                    }

                }

            }

            HoverHandler {
                id: suspendHover
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false;
                    suspendProc.running = true;
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        // 4. 󰌾 LOCK SCREEN PILL
        Rectangle {
            id: lockItem

            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: lockHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: lockHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰌾"
                    color: lockHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.accent) : Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 18
                    }

                }

                Text {
                    text: "Lock Screen"
                    color: lockHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.textMain) : Theme.textMain
                    Layout.fillWidth: true

                    font {
                        family: Theme.fontMain
                        pixelSize: 15
                        bold: true
                    }

                }

                Text {
                    text: "󰅂"
                    color: lockHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)

                    font {
                        family: Theme.fontMono
                        pixelSize: 14
                    }

                }

            }

            HoverHandler {
                id: lockHover
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false;
                    lockProc.running = true;
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        // 5. 󰍃 LOG OUT PILL
        Rectangle {
            id: logoutItem

            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: logoutHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: logoutHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰍃"
                    color: logoutHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.accent) : Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 18
                    }

                }

                Text {
                    text: "Log Out"
                    color: logoutHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Theme.textMain) : Theme.textMain
                    Layout.fillWidth: true

                    font {
                        family: Theme.fontMain
                        pixelSize: 15
                        bold: true
                    }

                }

                Text {
                    text: "󰅂"
                    color: logoutHover.hovered ? (SettingsStore.buttonStyle === "solid" ? Theme.bgDark : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)

                    font {
                        family: Theme.fontMono
                        pixelSize: 14
                    }

                }

            }

            HoverHandler {
                id: logoutHover
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false;
                    logoutProc.running = true;
                }
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

}
