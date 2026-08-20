import "../theme"
import QtQuick
import QtQuick.Controls

// 🔘 STYLED REUSABLE SWITCH / TOGGLE BUTTON
Switch {
    id: switchRoot

    implicitWidth: 46
    implicitHeight: 24

    indicator: Rectangle {
        implicitWidth: 46
        implicitHeight: 24
        x: switchRoot.leftPadding
        y: parent.height / 2 - height / 2
        radius: 12
        color: switchRoot.checked ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)

        Rectangle {
            x: switchRoot.checked ? parent.width - width - 3 : 3
            y: (parent.height - height) / 2
            width: 18
            height: 18
            radius: 9
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
