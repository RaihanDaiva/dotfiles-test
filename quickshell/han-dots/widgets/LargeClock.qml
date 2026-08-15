import QtQuick
import QtQuick.Layouts
import Quickshell
import "../theme"

// 🕒 MINIMALIST LARGE CLOCK WIDGET (Matching Reference UI Style)
ColumnLayout {
    id: clockRoot

    // 🎯 CUSTOMIZABLE PROPERTIES
    property string fontFamily: Theme.fontMain
    property color timeColor: Theme.textMain
    property color dateColor: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.85)

    property int timePixelSize: 56
    property int datePixelSize: 16
    property bool isBold: true
    property bool lowercaseDate: true

    // Formats
    property string timeFormat: "hh:mm"
    property string dateFormat: "ddd, dd/MM"

    spacing: -10

    // 🕒 TIME DISPLAY (e.g. "09:56")
    Text {
        id: timeText
        color: clockRoot.timeColor
        font {
            family: clockRoot.fontFamily
            pixelSize: clockRoot.timePixelSize
            bold: clockRoot.isBold
        }
        lineHeight: 0.95

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    // 📅 DATE DISPLAY (e.g. "dom, 28/12" or "rab, 13/08")
    Text {
        id: dateText
        color: clockRoot.dateColor
        font {
            family: clockRoot.fontFamily
            pixelSize: clockRoot.datePixelSize
            bold: false
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    // ⏱️ TIMER UNTUK UPDATE WAKTU REAL-TIME (SETIAP 1 DETIK)
    function updateDateTime() {
        var now = new Date()
        timeText.text = Qt.formatDateTime(now, clockRoot.timeFormat)
        var rawDate = Qt.formatDateTime(now, clockRoot.dateFormat)
        dateText.text = clockRoot.lowercaseDate ? rawDate.toLowerCase() : rawDate
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: clockRoot.updateDateTime()
    }
}
