import "../../../services"
import "../../../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// 🎚️ MACOS CONTROL CENTER SLIDER STYLE (Header Label + Thin Capsule Track + White Fill)
Rectangle {
    id: styleRoot

    property string iconText: "󰃠"
    property string titleText: "Brightness"
    property real value: 50
    property real maxValue: 100
    property string valueSuffix: "%"
    property color iconColor: Theme.accent
    property color fillColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
    property color textColor: Theme.textMain
    property real cornerRadius: 16
    readonly property bool isDisplay: {
        var t = styleRoot.titleText.toLowerCase();
        return t.indexOf("brightness") !== -1 || t.indexOf("display") !== -1 || t.indexOf("screen") !== -1;
    }
    readonly property bool isSound: {
        var t = styleRoot.titleText.toLowerCase();
        return t.indexOf("volume") !== -1 || t.indexOf("sound") !== -1 || t.indexOf("audio") !== -1;
    }
    readonly property string displayTitle: {
        if (isDisplay) {
            if (styleRoot.titleText.indexOf("second") !== -1 || styleRoot.titleText.indexOf("(second)") !== -1)
                return "Display (2)";

            if (styleRoot.titleText.indexOf("first") !== -1 || styleRoot.titleText.indexOf("(first)") !== -1)
                return "Display (1)";

            return "Display";
        }
        if (isSound)
            return "Sound";

        return styleRoot.titleText;
    }
    readonly property string leftIconGlyph: {
        if (isDisplay)
            return "󰃞";

        if (isSound)
            return (styleRoot.value <= 0 || styleRoot.iconText === "󰝟") ? "󰝟" : "󰕿";

        return styleRoot.iconText;
    }
    readonly property string rightIconGlyph: {
        if (isDisplay)
            return "󰃠";

        if (isSound)
            return "󰕾";

        return "";
    }

    signal valueMoved(real newValue)
    signal valuePressed(real newValue)

    implicitWidth: 200
    implicitHeight: 66
    radius: 25
    color: sliderHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.14) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.09)
    border.color: sliderHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.24) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.14)
    border.width: 1

    HoverHandler {
        id: sliderHover
    }

    Process {
        id: audioSettingsProc

        command: ["pavucontrol"]
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        anchors.topMargin: 11
        anchors.bottomMargin: 11
        spacing: 6

        // 🏷️ TOP ROW: TITLE & DYNAMIC VALUE HOVER INDICATOR
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: styleRoot.displayTitle
                color: styleRoot.textColor

                font {
                    family: Theme.fontMain
                    pixelSize: 13
                    bold: true
                }

            }

            Item {
                Layout.fillWidth: true
            }

            Text {
                visible: trackMouseArea.containsMouse || trackMouseArea.pressed
                text: Math.round(styleRoot.value) + styleRoot.valueSuffix
                color: styleRoot.iconColor

                font {
                    family: Theme.fontMain
                    pixelSize: 11
                    bold: true
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

        }

        // 🎚️ BOTTOM ROW: LEFT ICON + SLIDER TRACK + RIGHT ICON + AIRPLAY ACTION BUTTON
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10

            // 🔅 Left Icon Slot (Fixed 20px Slot for Exact Alignment)
            Item {
                id: leftIconSlot

                implicitWidth: 20
                implicitHeight: 20
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20

                Text {
                    id: leftIconText

                    anchors.centerIn: parent
                    text: styleRoot.leftIconGlyph
                    color: leftIconHover.hovered ? styleRoot.iconColor : Qt.rgba(styleRoot.iconColor.r, styleRoot.iconColor.g, styleRoot.iconColor.b, 0.85)

                    font {
                        family: Theme.fontMono
                        pixelSize: 15
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

                HoverHandler {
                    id: leftIconHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (styleRoot.isSound)
                            styleRoot.valueMoved(0);
                        else
                            styleRoot.valueMoved(Math.max(1, Math.round(styleRoot.maxValue * 0.1)));
                    }
                }

            }

            // 📏 Center Slider Track Container
            Item {
                id: trackContainer

                Layout.fillWidth: true
                implicitHeight: 24

                // Dark Translucent Track Groove
                Rectangle {
                    id: trackBg

                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width
                    height: 5
                    radius: height / 2
                    color: Qt.rgba(0, 0, 0, 0.25)
                }

                // Bright White Filled Capsule Pill
                Rectangle {
                    id: trackFill

                    anchors.verticalCenter: parent.verticalCenter
                    x: 0
                    height: 5
                    radius: height / 2
                    width: Math.max(0, Math.min(trackContainer.width, trackContainer.width * (styleRoot.value / styleRoot.maxValue)))
                    color: (styleRoot.isSound && styleRoot.value <= 0) ? Qt.rgba(styleRoot.textColor.r, styleRoot.textColor.g, styleRoot.textColor.b, 0.35) : (Theme.isDarkMode ? "#ffffff" : Theme.accent)

                    Behavior on width {
                        enabled: !trackMouseArea.pressed

                        NumberAnimation {
                            duration: 100
                            easing.type: Easing.OutCubic
                        }

                    }

                }

                // Mouse interaction area over the track
                MouseArea {
                    id: trackMouseArea

                    function updateVal(mouse) {
                        var ratio = Math.min(1, Math.max(0, mouse.x / width));
                        var newVal = Math.round(ratio * styleRoot.maxValue);
                        styleRoot.valueMoved(newVal);
                    }

                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onPressed: (mouse) => {
                        return updateVal(mouse);
                    }
                    onPositionChanged: (mouse) => {
                        if (pressed)
                            updateVal(mouse);

                    }
                    onWheel: (wheel) => {
                        var step = Math.max(1, styleRoot.maxValue / 20);
                        var delta = wheel.angleDelta.y > 0 ? step : -step;
                        var newVal = Math.min(styleRoot.maxValue, Math.max(0, styleRoot.value + delta));
                        styleRoot.valueMoved(Math.round(newVal));
                        wheel.accepted = true;
                    }
                }

            }

            // 🔆 Right Icon Slot (Fixed 20px Slot for Exact Alignment)
            Item {
                id: rightIconSlot

                implicitWidth: 20
                implicitHeight: 20
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                visible: styleRoot.rightIconGlyph !== ""

                Text {
                    id: rightIconText

                    anchors.centerIn: parent
                    text: styleRoot.rightIconGlyph
                    color: rightIconHover.hovered ? styleRoot.iconColor : Qt.rgba(styleRoot.iconColor.r, styleRoot.iconColor.g, styleRoot.iconColor.b, 0.85)

                    font {
                        family: Theme.fontMono
                        pixelSize: 16
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

                HoverHandler {
                    id: rightIconHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        styleRoot.valueMoved(styleRoot.maxValue);
                    }
                }

            }

        }

    }

}
