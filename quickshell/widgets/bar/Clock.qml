import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"
import "clockWidget"

Item {
    id: clockRoot

    property var barWindow: null

    // ⏱️ TIMER DELAY HOVER POPUP
    Timer {
        id: closeTimer
        interval: 300
        onTriggered: calendarPopup.isOpen = false
    }

    // 🪟 SUB-KOMPONEN 1: CALENDAR POPUP HOVER CARD
    CalendarPopup {
        id: calendarPopup
        barWindow: clockRoot.barWindow
        clockRootItem: clockRoot

        onKeepOpen: closeTimer.stop()
        onStartCloseTimer: closeTimer.restart()
    }

    implicitWidth: clockPill.implicitWidth
    implicitHeight: 32

    // 🧠🌡️ PILL RECTANGLE HOVER EFEK (PERSIS DENGAN SYSTEMSTATS)
    Rectangle {
        id: clockPill
        anchors.centerIn: parent
        implicitWidth: middleContent.implicitWidth + 16
        implicitHeight: 26
        radius: 8
        color: (clockMouseArea.containsMouse || calendarPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
        border.color: (clockMouseArea.containsMouse || calendarPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
        border.width: 1

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // 🖱️ MOUSEAREA HOVER POPUP TRIGGER
        MouseArea {
            id: clockMouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onEntered: {
                closeTimer.stop()
                calendarPopup.isOpen = true
            }
            onExited: {
                closeTimer.restart()
            }
        }

        RowLayout {
            id: middleContent
            anchors.centerIn: parent
            spacing: 6

            Text {
                id: timeText
                color: Theme.textMain
                font {
                    family: Theme.fontMain
                    pixelSize: 18
                    bold: true
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    function updateClock() {
        timeText.text = Qt.formatDateTime(new Date(), "hh : mm")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateClock()
    }
}
