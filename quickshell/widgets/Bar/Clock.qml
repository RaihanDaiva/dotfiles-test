import QtQuick
import QtQuick.Layouts
import Quickshell

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
            color: "#ffffff"
            font {pixelSize: 14; bold: true}
        }
    }

    function updateClock()
    {
        timeText.text = Qt.formatDateTime(new Date(), "ddd, dd MMM - hh:mm")
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: updateClock()
    }
}


