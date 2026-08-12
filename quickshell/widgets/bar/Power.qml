import QtQuick
import Quickshell
import "../../components/popups"
import "../../theme"

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
        color: (powerMouseArea.containsMouse || powerPopup.isOpen) ? Qt.rgba(243/255, 139/255, 168/255, 0.25) : Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.5)
        border.color: (powerMouseArea.containsMouse || powerPopup.isOpen) ? "#f38ba8" : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        Text {
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: 0
            text: "󰐥"
            color: (powerMouseArea.containsMouse || powerPopup.isOpen) ? "#f38ba8" : Theme.accent
            font { family: Theme.fontMono; pixelSize: 14 }

            Behavior on color { ColorAnimation { duration: 150 } }
        }

        MouseArea {
            id: powerMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                closePowerTimer.stop()
            }
            onExited: {
                closePowerTimer.restart()
            }
            onClicked: {
                powerPopup.isOpen = !powerPopup.isOpen
            }
        }
    }
}
