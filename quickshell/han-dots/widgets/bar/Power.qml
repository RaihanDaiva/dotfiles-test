import "../../components/popups"
import "../../components/popups/powerPopup"
import "../../theme"
import QtQuick
import Quickshell

// 🔌 STANDALONE POWER BUTTON BAR WIDGET
Item {
    id: powerWidgetRoot

    property var barWindow: null

    implicitWidth: powerPill.implicitWidth
    implicitHeight: powerPill.implicitHeight

    // 🔌 POWER MENU POPUP DROPDOWN
    PowerPopup {
        id: powerPopup

        barWindow: powerWidgetRoot.barWindow
        targetItem: powerPill
        userNameText: "Han"
        onKeepOpen: closePowerTimer.stop()
        onStartCloseTimer: closePowerTimer.restart()
    }

    Timer {
        id: closePowerTimer

        interval: 300
        onTriggered: powerPopup.isOpen = false
    }

    // 📦 STANDALONE POWER PILL CONTAINER
    Rectangle {
        id: powerPill

        implicitWidth: 26
        implicitHeight: 26
        radius: 13
        color: (powerMouseArea.containsMouse || powerPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
        border.color: (powerMouseArea.containsMouse || powerPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
        border.width: 1

        Text {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 0
            text: "󰐥"
            color: (powerMouseArea.containsMouse || powerPopup.isOpen) ? Theme.accent : Theme.accent

            font {
                family: Theme.fontMono
                pixelSize: 18
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        MouseArea {
            id: powerMouseArea

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                closePowerTimer.stop();
            }
            onExited: {
                closePowerTimer.restart();
            }
            onClicked: {
                powerPopup.isOpen = !powerPopup.isOpen;
            }
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

    }

}
