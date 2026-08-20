import "../../../services"
import "../../../theme"
import QtQuick
import QtQuick.Layouts

// 🎚️ ANDROID MATERIAL 3 SLIDER STYLE (Card Track, 12px Radius)
Rectangle {
    id: styleRoot

    property string iconText: "󰃠"
    property string titleText: "Brightness"
    property real value: 50
    property real maxValue: 100
    property string valueSuffix: "%"
    property color iconColor: Theme.accent
    property color fillColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
    property color textColor: Theme.textMain
    property real cornerRadius: 12

    signal valueMoved(real newValue)
    signal valuePressed(real newValue)

    anchors.fill: parent
    radius: cornerRadius
    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
    border.width: 1

    Rectangle {
        height: parent.height
        width: parent.width * Math.min(1, Math.max(0, styleRoot.value / styleRoot.maxValue))
        radius: parent.radius
        color: styleRoot.fillColor

        Behavior on width {
            NumberAnimation {
                duration: 80
            }

        }

    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12

        Text {
            text: styleRoot.iconText
            color: styleRoot.iconColor

            font {
                family: Theme.fontMono
                pixelSize: 18
            }

        }

        Text {
            text: styleRoot.titleText
            color: styleRoot.textColor
            Layout.fillWidth: true

            font {
                family: Theme.fontMain
                pixelSize: 13
                bold: true
            }

        }

        Text {
            text: Math.round(styleRoot.value) + styleRoot.valueSuffix
            color: styleRoot.textColor

            font {
                family: Theme.fontMain
                pixelSize: 13
                bold: true
            }

        }

    }

    MouseArea {
        function updateVal(mouse) {
            var pct = Math.min(styleRoot.maxValue, Math.max(0, Math.round((mouse.x / width) * styleRoot.maxValue)));
            styleRoot.valueMoved(pct);
        }

        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: (mouse) => {
            return updateVal(mouse);
        }
        onPressed: (mouse) => {
            return updateVal(mouse);
        }
    }

}
