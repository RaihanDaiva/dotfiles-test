import QtQuick
import QtQuick.Layouts
import "../theme"

// 🎛️ REUSABLE CONTROL PILL WIDGET (Toggle Icon Left + Info Middle + Chevron Right)
Rectangle {
    id: pillRoot

    property string iconText: "󰤨"
    property string titleText: "Wi-Fi"
    property string subtitleText: "Off"
    property bool isActive: false
    property bool isExpanded: false
    property bool showChevron: true

    signal toggleClicked()
    signal expandClicked()

    implicitWidth: 160
    implicitHeight: 52
    radius: 16
    color: isActive ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
    border.color: isActive ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on border.color { ColorAnimation { duration: 200 } }

    // 🖐️ FULL RECTANGLE CLICKABLE AREA (ACTIVE WHEN SHOWCHEVRON IS FALSE)
    MouseArea {
        anchors.fill: parent
        enabled: !pillRoot.showChevron
        cursorShape: Qt.PointingHandCursor
        onClicked: pillRoot.toggleClicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: pillRoot.showChevron ? 12 : 8
        spacing: 8

        // ⭕ 1. TOMBOL LINGKARAN IKON KIRI (QUICK TOGGLE ON / OFF)
        Rectangle {
            id: iconCircle
            implicitWidth: 36
            implicitHeight: 36
            radius: 18
            color: pillRoot.isActive ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12)

            Behavior on color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 1
                text: pillRoot.iconText
                color: pillRoot.isActive ? Theme.bgDark : Theme.textMain
                font { family: Theme.fontMono; pixelSize: 17 }

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: pillRoot.toggleClicked()
            }
        }

        // 📝 2. TEKS JUDUL & STATUS SUBTITLE (MARQUEE SCROLLING JIKA TEKS TERLALU PANJANG)
        ColumnLayout {
            id: infoColumn
            Layout.fillWidth: true
            spacing: 1

            // 🏷️ TITLE MARQUEE
            Item {
                id: titleBox
                Layout.fillWidth: true
                implicitHeight: titleText1.implicitHeight
                clip: true

                readonly property bool isOverflowing: titleText1.contentWidth > titleBox.width
                readonly property real loopSpan: titleText1.contentWidth + 24

                Text {
                    id: titleText1
                    x: titleBox.isOverflowing ? titleAnim.xOffset : 0
                    text: pillRoot.titleText
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                }

                Text {
                    id: titleText2
                    x: titleBox.isOverflowing ? (titleAnim.xOffset + titleBox.loopSpan) : 0
                    text: titleText1.text
                    color: Theme.textMain
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

                    onRunningChanged: if (!running) xOffset = 0
                }
            }

            // 🏷️ SUBTITLE MARQUEE
            Item {
                id: subtitleBox
                Layout.fillWidth: true
                implicitHeight: subtitleText1.implicitHeight
                clip: true

                readonly property bool isOverflowing: subtitleText1.contentWidth > subtitleBox.width
                readonly property real loopSpan: subtitleText1.contentWidth + 24

                Text {
                    id: subtitleText1
                    x: subtitleBox.isOverflowing ? subtitleAnim.xOffset : 0
                    text: pillRoot.subtitleText
                    color: pillRoot.isActive ? Theme.accent : Theme.secondary
                    font { family: Theme.fontMain; pixelSize: 11 }

                    Behavior on color { ColorAnimation { duration: 200 } }
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

                    onRunningChanged: if (!running) xOffset = 0
                }
            }

            MouseArea {
                anchors.fill: infoColumn
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (pillRoot.showChevron) {
                        pillRoot.expandClicked()
                    } else {
                        pillRoot.toggleClicked()
                    }
                }
            }
        }

        // ❯ 3. TOMBOL CHEVRON DROPDOWN KANAN (∨ / ∧ UNTUK EXPAND SUB-PANEL)
        Item {
            implicitWidth: pillRoot.showChevron ? 20 : 0
            implicitHeight: 20
            visible: pillRoot.showChevron

            Text {
                anchors.centerIn: parent
                text: "󰅂"
                color: pillRoot.isExpanded ? Theme.accent : Theme.secondary
                font { family: Theme.fontMono; pixelSize: 16 }

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: pillRoot.expandClicked()
            }
        }
    }
}
