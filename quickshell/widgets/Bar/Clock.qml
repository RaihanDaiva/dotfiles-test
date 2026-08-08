import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../theme"

Rectangle {
    implicitWidth: middleContent.implicitWidth + 20
    implicitHeight: 32
    color: 'transparent'

    RowLayout {
        id: middleContent
        anchors.centerIn: parent
        spacing: 6

        Text {
            id: timeText
            color: Theme.textMain
            font {
                family: Theme.fontMain
                pixelSize: 20
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

    function updateClock()
    {
        // timeText.text = Qt.formatDateTime(new Date(), "ddd, dd MMM - hh:mm")
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


