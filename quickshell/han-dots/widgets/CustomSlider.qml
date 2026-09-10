import "../theme"
import QtQuick
import QtQuick.Controls

// 🎚️ REUSABLE CUSTOM STYLED SLIDER WIDGET
Slider {
    id: sliderRoot

    implicitWidth: 160
    implicitHeight: 28

    background: Rectangle {
        x: sliderRoot.leftPadding
        y: sliderRoot.topPadding + sliderRoot.availableHeight / 2 - height / 2
        implicitWidth: 160
        implicitHeight: 7
        width: sliderRoot.availableWidth
        height: implicitHeight
        radius: 4
        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)

        Rectangle {
            width: sliderRoot.visualPosition * parent.width
            height: parent.height
            color: Theme.accent
            radius: 4
        }

    }

    handle: Rectangle {
        x: sliderRoot.leftPadding + sliderRoot.visualPosition * (sliderRoot.availableWidth - width)
        y: sliderRoot.topPadding + sliderRoot.availableHeight / 2 - height / 2
        implicitWidth: 18
        implicitHeight: 18
        radius: 9
        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.95)
    }

}
