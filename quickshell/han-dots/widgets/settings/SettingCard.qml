import "../../theme"
import QtQuick
import QtQuick.Layouts

// 🃏 REUSABLE SETTING CARD CONTAINER (Title & Subtitle Left, Custom Control Right)
Rectangle {
    id: cardRoot

    property string title: ""
    property string subtitle: ""
    property alias controlContent: rightContainer.children
    default property alias defaultContent: rightContainer.data

    Layout.fillWidth: true
    implicitHeight: 64
    radius: 12
    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
    border.width: 1

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // 📝 LEFT COLUMN: TITLE & SUBTITLE
        ColumnLayout {
            spacing: 2

            Text {
                visible: cardRoot.title !== ""
                text: cardRoot.title
                color: Theme.textMain

                font {
                    family: Theme.fontMain
                    pixelSize: 13
                    bold: true
                }

            }

            Text {
                visible: cardRoot.subtitle !== ""
                text: cardRoot.subtitle
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                font {
                    family: Theme.fontMain
                    pixelSize: 11
                }

            }

        }

        Item {
            Layout.fillWidth: true
        }

        // 🎛️ RIGHT CONTAINER: CUSTOM CONTROL WIDGET (SLIDER, SWITCH, BUTTONS)
        RowLayout {
            id: rightContainer

            spacing: 6
        }

    }

}
