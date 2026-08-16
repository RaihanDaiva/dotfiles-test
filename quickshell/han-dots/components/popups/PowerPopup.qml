import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "../../theme"
import "../../widgets"

// 🔌 POWER MENU POPUP DROPDOWN (VERTICAL PILL LIST WITH HYPRLAND BLUR & PYWAL STYLING)
BasePopup {
    id: powerPopup

    implicitWidth: 240
    implicitHeight: mainLayout.implicitHeight + 28

    // 🎯 USER DATA & METRICS
    property string userNameText: "User"
    property string uptimeText: "Uptime: -"

    // ─── SYSTEM ACTION PROCESSES ─────────────────────────────────────────────
    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: suspendProc; command: ["systemctl", "suspend"] }
    Process { id: lockProc; command: ["quickshell", "ipc", "call", "lockscreen", "lock"] }
    Process { id: logoutProc; command: ["hyprctl", "dispatch", "exit"] }

    // 📦 VERTICAL LIST CONTAINER
    ColumnLayout {
        id: mainLayout
        anchors.fill: parent
        spacing: 6

        // 👤 USER PROFILE & UPTIME HEADER
        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            Rectangle {
                implicitWidth: 32
                implicitHeight: 32
                radius: 16
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: -1
                    text: "󰀉"
                    color: Theme.accent
                    font { family: Theme.fontMono; pixelSize: 16 }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1

                Text {
                    text: powerPopup.userNameText
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    elide: Text.ElideRight
                }

                Text {
                    text: powerPopup.uptimeText
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)
                    font { family: Theme.fontMain; pixelSize: 10 }
                    elide: Text.ElideRight
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
            color: shutdownHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: shutdownHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰐥"
                    color: shutdownHover.hovered ? Theme.accent : Theme.accent
                    font { family: Theme.fontMono; pixelSize: 16 }
                }

                Text {
                    text: "Shutdown"
                    color: shutdownHover.hovered ? Theme.accent : Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    Layout.fillWidth: true
                }

                Text {
                    text: "󰅂"
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                    font { family: Theme.fontMono; pixelSize: 12 }
                }
            }

            HoverHandler { id: shutdownHover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false
                    shutdownProc.running = true
                }
            }
        }

        // 2. 󰑐 REBOOT PILL
        Rectangle {
            id: rebootItem
            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: rebootHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: rebootHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰑐"
                    color: rebootHover.hovered ? Theme.accent : Theme.accent
                    font { family: Theme.fontMono; pixelSize: 16 }
                }

                Text {
                    text: "Reboot"
                    color: rebootHover.hovered ? Theme.accent : Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    Layout.fillWidth: true
                }

                Text {
                    text: "󰅂"
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                    font { family: Theme.fontMono; pixelSize: 12 }
                }
            }

            HoverHandler { id: rebootHover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false
                    rebootProc.running = true
                }
            }
        }

        // 3. 󰤄 SUSPEND / SLEEP PILL
        Rectangle {
            id: suspendItem
            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: suspendHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: suspendHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰤄"
                    color: suspendHover.hovered ? Theme.accent : Theme.accent
                    font { family: Theme.fontMono; pixelSize: 16 }
                }

                Text {
                    text: "Suspend"
                    color: suspendHover.hovered ? Theme.accent : Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    Layout.fillWidth: true
                }

                Text {
                    text: "󰅂"
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                    font { family: Theme.fontMono; pixelSize: 12 }
                }
            }

            HoverHandler { id: suspendHover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false
                    suspendProc.running = true
                }
            }
        }

        // 4. 󰌾 LOCK SCREEN PILL
        Rectangle {
            id: lockItem
            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: lockHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: lockHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰌾"
                    color: lockHover.hovered ? Theme.accent : Theme.accent
                    font { family: Theme.fontMono; pixelSize: 16 }
                }

                Text {
                    text: "Lock Screen"
                    color: lockHover.hovered ? Theme.accent : Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    Layout.fillWidth: true
                }

                Text {
                    text: "󰅂"
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                    font { family: Theme.fontMono; pixelSize: 12 }
                }
            }

            HoverHandler { id: lockHover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false
                    lockProc.running = true
                }
            }
        }

        // 5. 󰍃 LOG OUT PILL
        Rectangle {
            id: logoutItem
            Layout.fillWidth: true
            implicitHeight: 38
            radius: 10
            color: logoutHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
            border.color: logoutHover.hovered ? Theme.accent : "transparent"
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 10

                Text {
                    text: "󰍃"
                    color: logoutHover.hovered ? Theme.accent : Theme.accent
                    font { family: Theme.fontMono; pixelSize: 16 }
                }

                Text {
                    text: "Log Out"
                    color: logoutHover.hovered ? Theme.accent : Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    Layout.fillWidth: true
                }

                Text {
                    text: "󰅂"
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                    font { family: Theme.fontMono; pixelSize: 12 }
                }
            }

            HoverHandler { id: logoutHover }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    powerPopup.isOpen = false
                    logoutProc.running = true
                }
            }
        }
    }
}
