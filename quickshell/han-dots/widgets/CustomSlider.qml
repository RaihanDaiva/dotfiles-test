import "../theme"
import QtQuick
import QtQuick.Controls

// 🎚️ REUSABLE CUSTOM STYLED SLIDER WIDGET
Slider {
    id: sliderRoot

    implicitWidth: 140
    implicitHeight: 24

    background: Rectangle {
        x: sliderRoot.leftPadding
        y: sliderRoot.topPadding + sliderRoot.availableHeight / 2 - height / 2
        implicitWidth: 140
        implicitHeight: 6
        width: sliderRoot.availableWidth
        height: implicitHeight
        radius: 3
        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)

        Rectangle {
            width: sliderRoot.visualPosition * parent.width
            height: parent.height
            color: Theme.accent
            radius: 3
        }

    }

    handle: Rectangle {
        x: sliderRoot.leftPadding + sliderRoot.visualPosition * (sliderRoot.availableWidth - width)
        y: sliderRoot.topPadding + sliderRoot.availableHeight / 2 - height / 2
        implicitWidth: 16
        implicitHeight: 16
        radius: 8
        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.95)
    }

}
