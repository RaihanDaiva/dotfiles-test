import "../theme"
import QtQuick
import QtQuick.Controls

// 🔘 STYLED REUSABLE SWITCH / TOGGLE BUTTON
Switch {
    id: switchRoot

    implicitWidth: 50
    implicitHeight: 28
    padding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    indicator: Rectangle {
        implicitWidth: 50
        implicitHeight: 28
        x: 0
        y: (parent.height - height) / 2
        radius: 14
        color: switchRoot.checked ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)

        Rectangle {
            x: switchRoot.checked ? parent.width - width - 3 : 3
            y: (parent.height - height) / 2
            width: 22
            height: 22
            radius: 11
            color: switchRoot.checked ? Theme.textMain : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)

            Behavior on x {
                NumberAnimation {
                    duration: 150
                    easing.type: Easing.InOutQuad
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        Behavior on color {
            ColorAnimation {
                duration: 150
            }

        }

    }

}
