import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../components/popups"
import "../../theme"
import "../../services"

// 🔔 NOTIFICATION PILL BAR WIDGET (Positioned between ControlCenter and Power)
Item {
    id: notifWidgetRoot

    property var barWindow: null
    readonly property var notifList: NotificationStore.notifList

    implicitWidth: notifPill.implicitWidth
    implicitHeight: notifPill.implicitHeight

    // 🔔 NOTIFICATION CENTER POPUP DROPDOWN (Instantiated per-bar for proper LayerShell positioning)
    NotificationCenterPopup {
        id: notifCenterPopup
        barWindow: notifWidgetRoot.barWindow
        targetItem: notifPill

        onKeepOpen: closeNotifTimer.stop()
        onStartCloseTimer: closeNotifTimer.restart()
    }

    Timer {
        id: closeNotifTimer
        interval: 300
        onTriggered: notifCenterPopup.isOpen = false
    }

    // 📦 STANDALONE NOTIFICATION PILL CONTAINER
    Rectangle {
        id: notifPill
        implicitWidth: countBadge.visible ? (pillLayout.implicitWidth + 12) : 26
        implicitHeight: 26
        radius: countBadge.visible ? 8 : 13
        color: (notifMouseArea.containsMouse || notifCenterPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
        border.color: (notifMouseArea.containsMouse || notifCenterPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on implicitWidth { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        RowLayout {
            id: pillLayout
            anchors.centerIn: parent
            spacing: 4

            // 🔔 Bell Icon
            Text {
                text: notifWidgetRoot.notifList.length > 0 ? "󱅫" : "󰂚"
                color: Theme.accent
                font { family: Theme.fontMono; pixelSize: 17 }

                Behavior on color { ColorAnimation { duration: 150 } }
            }

            // 🔴 Unread Notification Count Badge
            Text {
                id: countBadge
                visible: notifWidgetRoot.notifList.length > 0
                text: notifWidgetRoot.notifList.length.toString()
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 11; bold: true }
            }
        }

        MouseArea {
            id: notifMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                notifCenterPopup.isOpen = !notifCenterPopup.isOpen
            }
        }
    }
}
