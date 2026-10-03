import "../../theme"
import QtQuick

// 🔋 Reusable Standalone Pill Widget with Circular Battery Progress Ring & Nerd Font Icon
Rectangle {
    id: pillRoot

    property string icon: "󰍽"
    property string iconFamily: Theme.fontMono
    property int iconPixelSize: 11
    property string batteryText: "N/A"
    property bool autoHide: false
    property string tooltipText: ""
    readonly property int batteryPercent: ring.batteryPercent
    readonly property bool isValid: ring.isValid

    signal refreshRequested()

    visible: !autoHide || isValid
    implicitWidth: ring.implicitWidth + 14
    implicitHeight: 26
    radius: 8
    color: pillHover.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
    border.color: pillHover.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
    border.width: 1

    CircularBatteryRing {
        id: ring

        anchors.centerIn: parent
        icon: pillRoot.icon
        iconFamily: pillRoot.iconFamily
        iconPixelSize: pillRoot.iconPixelSize
        batteryText: pillRoot.batteryText
    }

    MouseArea {
        id: pillHover

        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: pillRoot.refreshRequested()
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
