import "../../../theme"
import QtQuick
import QtQuick.Layouts

// 🎨 TRANSLUCENT / OUTLINED BUTTON STYLE
Rectangle {
    id: styleRoot

    property string text: ""
    property string iconText: ""
    property bool selected: false
    property real cornerRadius: 8

    anchors.fill: parent
    radius: cornerRadius
    color: selected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18) : (btnHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08) : "transparent")
    border.color: selected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12)
    border.width: 1

    HoverHandler {
        id: btnHover
    }

    RowLayout {
        anchors.centerIn: parent
        spacing: 6

        Text {
            visible: styleRoot.iconText !== ""
            text: styleRoot.iconText
            color: styleRoot.selected ? Theme.accent : Theme.textMain

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
            color: styleRoot.selected ? Theme.accent : Theme.textMain

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

    Behavior on border.color {
        ColorAnimation {
            duration: 150
        }

    }

}
