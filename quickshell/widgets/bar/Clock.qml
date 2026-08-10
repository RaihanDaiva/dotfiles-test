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

    // 🪟 SUB-KOMPONEN 1: CALENDAR POPUP HOVER CARD (ENTER & EXIT ANIMATED)
    CalendarPopup {
        id: calendarPopup
        barWindow: clockRoot.barWindow
        clockRootItem: clockRoot

        onKeepOpen: closeTimer.stop()
        onStartCloseTimer: closeTimer.restart()
    }

    implicitWidth: middleContent.implicitWidth + 20
    implicitHeight: 32

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 8

        // 🖱️ MOUSEAREA HOVER POPUP TRIGGER
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
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
