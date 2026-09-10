import "../theme"
import QtQuick
import QtQuick.Controls

// 📜 REUSABLE STYLED SCROLLBAR WIDGET
ScrollBar {
    id: scrollBarRoot

    policy: ScrollBar.AsNeeded
    hoverEnabled: true
    width: 6

    contentItem: Rectangle {
        implicitWidth: 6
        implicitHeight: scrollBarRoot.visualSize
        radius: 3
        color: scrollBarRoot.pressed ? Theme.accent : (scrollBarRoot.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.75) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.35))
        opacity: (scrollBarRoot.policy === ScrollBar.AlwaysOn || (scrollBarRoot.active && scrollBarRoot.size < 1)) ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }

        }

    }

}
