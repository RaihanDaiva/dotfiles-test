import "../../theme"
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io

// 🖱️ AJAZZ Mouse Battery Indicator with Circular Progress & Nerd Font Icon
Item {
    id: batteryRoot

    property string batteryText: "N/A"
    readonly property int batteryPercent: {
        var match = batteryText.match(/^(\d+)%$/);
        return match ? parseInt(match[1]) : 0;
    }
    readonly property bool isValid: batteryText !== "N/A"

    implicitWidth: batteryPill.implicitWidth
    implicitHeight: batteryPill.implicitHeight

    Process {
        id: batteryProcess

        command: [Quickshell.configDir + "/scripts/mouse_battery.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                const value = this.text.trim();
                batteryRoot.batteryText = /^(100|[1-9]?\d)%$/.test(value) ? value : "N/A";
            }
        }

    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            batteryProcess.running = false;
            batteryProcess.running = true;
        }
    }

    Rectangle {
        id: batteryPill

        implicitWidth: batteryContent.implicitWidth + 14
        implicitHeight: 26
        radius: 8
        color: batteryHover.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
        border.color: batteryHover.containsMouse ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
        border.width: 1

        RowLayout {
            id: batteryContent

            anchors.centerIn: parent
            spacing: 6

            // ⭕ Circular Battery Progress Ring with Nerd Font Mouse Icon
            Item {
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
                        strokeColor: batteryRoot.isValid ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
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
                        strokeColor: !batteryRoot.isValid ? "transparent" : (batteryRoot.batteryPercent <= 20 ? "#f38ba8" : Theme.accent)
                        strokeWidth: 2
                        fillColor: "transparent"
                        capStyle: ShapePath.RoundCap

                        PathAngleArc {
                            centerX: 11
                            centerY: 11
                            radiusX: 9
                            radiusY: 9
                            startAngle: -90
                            sweepAngle: batteryRoot.isValid ? (batteryRoot.batteryPercent / 100) * 360 : 0

                            Behavior on sweepAngle {
                                NumberAnimation {
                                    duration: 400
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                    }

                }

                // 󰍽 Nerd Font Mouse Icon in Center
                Text {
                    anchors.centerIn: parent
                    text: "󰍽"
                    color: !batteryRoot.isValid ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4) : (batteryRoot.batteryPercent <= 20 ? "#f38ba8" : Theme.accent)

                    font {
                        family: Theme.fontMono
                        pixelSize: 11
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

            }

            // // Battery Percentage Text
            // Text {
            //     text: batteryRoot.batteryText
            //     color: !batteryRoot.isValid ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4) : Theme.textMain

            //     font {
            //         family: Theme.fontMain
            //         pixelSize: 12
            //         bold: true
            //     }

            // }

        }

        MouseArea {
            id: batteryHover

            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                batteryProcess.running = false;
                batteryProcess.running = true;
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

}
