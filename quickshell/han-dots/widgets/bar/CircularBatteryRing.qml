import "../../theme"
import QtQuick
import QtQuick.Shapes

// ⭕ Reusable Circular Battery Progress Ring with Nerd Font Icon
Item {
    id: ringRoot

    property string icon: "󰍽"
    property string iconFamily: Theme.fontMono
    property int iconPixelSize: 11
    property string batteryText: "N/A"
    readonly property int batteryPercent: {
        var match = batteryText.match(/^(\d+)%$/);
        return match ? parseInt(match[1]) : 0;
    }
    readonly property bool isValid: batteryText !== "N/A"

    implicitWidth: 22
    implicitHeight: 22

    Shape {
        id: progressShape

        anchors.fill: parent
        antialiasing: true
        layer.enabled: true
        layer.samples: 4

        // Background Track
        ShapePath {
            strokeColor: ringRoot.isValid ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
            strokeWidth: 2
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 11
                centerY: 11
                radiusX: 9
                radiusY: 9
                startAngle: -90
                sweepAngle: 360
            }

        }

        // Active Progress Ring
        ShapePath {
            strokeColor: !ringRoot.isValid ? "transparent" : (ringRoot.batteryPercent <= 20 ? "#f38ba8" : Theme.accent)
            strokeWidth: 2
            fillColor: "transparent"
            capStyle: ShapePath.RoundCap

            PathAngleArc {
                centerX: 11
                centerY: 11
                radiusX: 9
                radiusY: 9
                startAngle: -90
                sweepAngle: ringRoot.isValid ? (ringRoot.batteryPercent / 100) * 360 : 0

                Behavior on sweepAngle {
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

    }

    // Centered Nerd Font Icon
    Text {
        anchors.centerIn: parent
        text: ringRoot.icon
        color: !ringRoot.isValid ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4) : (ringRoot.batteryPercent <= 20 ? "#f38ba8" : Theme.accent)

        font {
            family: ringRoot.iconFamily
            pixelSize: ringRoot.iconPixelSize
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
            }

        }

    }

}
