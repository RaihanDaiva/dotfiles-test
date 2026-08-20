import "../../../services"
import "../../../theme"
import QtQuick
import QtQuick.Layouts

// 🎛️ MACOS CAPSULE PILL STYLE (Radius 26px / Capsule)
Rectangle {
    id: styleRoot

    property string iconText: "󰤨"
    property string titleText: "Wi-Fi"
    property string subtitleText: "Off"
    property bool isActive: false
    property bool isExpanded: false
    property bool showChevron: true
    readonly property bool isSolid: SettingsStore.buttonStyle === "solid"

    signal toggleClicked()
    signal expandClicked()

    anchors.fill: parent
    radius: height / 2
    color: isActive ? (isSolid ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
    border.color: isActive ? (isSolid ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
    border.width: 1

    MouseArea {
        anchors.fill: parent
        enabled: !styleRoot.showChevron
        cursorShape: Qt.PointingHandCursor
        onClicked: styleRoot.toggleClicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: styleRoot.showChevron ? 14 : 8
        spacing: 8

        Rectangle {
            id: iconCircle

            implicitWidth: 36
            implicitHeight: 36
            radius: 18
            color: styleRoot.isActive ? (styleRoot.isSolid ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.85) : Theme.accent) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12)

            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 1
                text: styleRoot.iconText
                color: styleRoot.isActive ? (styleRoot.isSolid ? Theme.accent : Theme.textMain) : Theme.textMain

                font {
                    family: Theme.fontMono
                    pixelSize: 17
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 200
                    }

                }

            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: styleRoot.toggleClicked()
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        ColumnLayout {
            id: infoColumn

            Layout.fillWidth: true
            spacing: 1

            Item {
                id: titleBox

                readonly property bool isOverflowing: titleText1.contentWidth > titleBox.width
                readonly property real loopSpan: titleText1.contentWidth + 24

                Layout.fillWidth: true
                implicitHeight: titleText1.implicitHeight
                clip: true

                Text {
                    id: titleText1

                    x: titleBox.isOverflowing ? titleAnim.xOffset : 0
                    text: styleRoot.titleText
                    color: styleRoot.isActive ? (styleRoot.isSolid ? Theme.textMain : Theme.textMain) : Theme.textMain

                    font {
                        family: Theme.fontMain
                        pixelSize: 13
                        bold: true
                    }

                }

                Text {
                    id: titleText2

                    x: titleBox.isOverflowing ? (titleAnim.xOffset + titleBox.loopSpan) : 0
                    text: titleText1.text
                    color: titleText1.color
                    font: titleText1.font
                    visible: titleBox.isOverflowing
                }

                NumberAnimation {
                    id: titleAnim

                    property real xOffset: 0

                    target: titleAnim
                    property: "xOffset"
                    from: 0
                    to: -titleBox.loopSpan
                    duration: Math.max(3000, titleBox.loopSpan * 45)
                    loops: Animation.Infinite
                    running: titleBox.isOverflowing
                    easing.type: Easing.Linear
                    onRunningChanged: {
                        if (!running) {
                            xOffset = 0;
                        }
                    }
                }

            }

            Item {
                id: subtitleBox

                readonly property bool isOverflowing: subtitleText1.contentWidth > subtitleBox.width
                readonly property real loopSpan: subtitleText1.contentWidth + 24

                Layout.fillWidth: true
                implicitHeight: subtitleText1.implicitHeight
                clip: true

                Text {
                    id: subtitleText1

                    x: subtitleBox.isOverflowing ? subtitleAnim.xOffset : 0
                    text: styleRoot.subtitleText
                    color: styleRoot.isSolid ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.75) : Theme.accent

                    font {
                        family: Theme.fontMain
                        pixelSize: 11
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                        }

                    }

                }

                Text {
                    id: subtitleText2

                    x: subtitleBox.isOverflowing ? (subtitleAnim.xOffset + subtitleBox.loopSpan) : 0
                    text: subtitleText1.text
                    color: subtitleText1.color
                    font: subtitleText1.font
                    visible: subtitleBox.isOverflowing
                }

                NumberAnimation {
                    id: subtitleAnim

                    property real xOffset: 0

                    target: subtitleAnim
                    property: "xOffset"
                    from: 0
                    to: -subtitleBox.loopSpan
                    duration: Math.max(3000, subtitleBox.loopSpan * 45)
                    loops: Animation.Infinite
                    running: subtitleBox.isOverflowing
                    easing.type: Easing.Linear
                    onRunningChanged: {
                        if (!running) {
                            xOffset = 0;
                        }
                    }
                }

            }

            MouseArea {
                anchors.fill: infoColumn
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (styleRoot.showChevron)
                        styleRoot.expandClicked();
                    else
                        styleRoot.toggleClicked();
                }
            }

        }

        Item {
            implicitWidth: styleRoot.showChevron ? 20 : 0
            implicitHeight: 20
            visible: styleRoot.showChevron

            Text {
                anchors.centerIn: parent
                text: "󰅂"
                color: styleRoot.isActive ? (styleRoot.isSolid ? Theme.textMain : Theme.accent) : (styleRoot.isExpanded ? Theme.accent : Theme.secondary)

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

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: styleRoot.expandClicked()
            }

        }

    }

    Behavior on color {
        ColorAnimation {
            duration: 200
        }

    }

    Behavior on border.color {
        ColorAnimation {
            duration: 200
        }

    }

}
