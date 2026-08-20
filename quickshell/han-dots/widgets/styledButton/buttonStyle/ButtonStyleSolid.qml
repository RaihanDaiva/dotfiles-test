import "../../../theme"
import QtQuick
import QtQuick.Layouts

// 🎨 SOLID BUTTON STYLE
Rectangle {
    id: styleRoot

    property string text: ""
    property string iconText: ""
    property bool selected: false
    property real cornerRadius: 8

    anchors.fill: parent
    radius: cornerRadius
    color: selected ? Theme.accent : (btnHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06))
    border.color: "transparent"
    border.width: 0

    HoverHandler {
        id: btnHover
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            visible: styleRoot.iconText !== ""
            text: styleRoot.iconText
            color: styleRoot.selected ? Theme.textMain : Theme.textMain

            font {
                family: Theme.fontMono
                pixelSize: 14
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        Text {
            visible: styleRoot.text !== ""
            text: styleRoot.text
            color: styleRoot.selected ? Theme.textMain : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 1)

            font {
                family: Theme.fontMain
                pixelSize: 12
                bold: styleRoot.selected
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

    Behavior on color {
        ColorAnimation {
            duration: 150
        }

    }

}
