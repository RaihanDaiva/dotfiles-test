import "../../../theme"
import QtQuick
import QtQuick.Layouts

// 🎨 TRANSLUCENT / OUTLINED BUTTON STYLE
Rectangle {
    id: styleRoot

    property string text: ""
    property string iconText: ""
    property bool selected: false
    property string alignment: "center"
    property real cornerRadius: 8
    property bool transparentUnselected: false

    anchors.fill: parent
    radius: cornerRadius
    color: selected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.18) : (btnHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08) : "transparent")
    border.color: selected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5) : (transparentUnselected ? (btnHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15) : "transparent") : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12))
    border.width: 1

    HoverHandler {
        id: btnHover
    }

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: styleRoot.alignment === "left" ? parent.left : undefined
        anchors.leftMargin: styleRoot.alignment === "left" ? 14 : 0
        anchors.horizontalCenter: styleRoot.alignment === "left" ? undefined : parent.horizontalCenter
        spacing: 10

        Text {
            visible: styleRoot.iconText !== ""
            text: styleRoot.iconText
            color: styleRoot.selected ? Theme.accent : Theme.textMain

            font {
                family: Theme.fontMono
                pixelSize: 16
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
                pixelSize: 13
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
