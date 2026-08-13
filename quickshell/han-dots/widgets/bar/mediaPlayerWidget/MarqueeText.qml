import QtQuick
import QtQuick.Layouts
import "../../../theme"

Item {
    id: marqueeRoot

    property string text: ""
    property font textFont
    property color textColor: Theme.textMain
    property int targetWidth: 90
    property bool isPlaying: false

    Layout.preferredWidth: targetWidth
    Layout.maximumWidth: targetWidth
    implicitHeight: text1.implicitHeight
    clip: true

    readonly property bool isOverflowing: text1.contentWidth > marqueeRoot.targetWidth
    readonly property real loopSpan: text1.contentWidth + 24

    // Copy 1
    Text {
        id: text1
        x: marqueeRoot.isOverflowing ? anim.xOffset : 0
        text: marqueeRoot.text
        color: marqueeRoot.textColor
        font: marqueeRoot.textFont

        Behavior on color {
            ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }
    }

    // Copy 2 (Duplikat untuk efek Seamless Infinite Loop)
    Text {
        id: text2
        x: marqueeRoot.isOverflowing ? (anim.xOffset + marqueeRoot.loopSpan) : 0
        text: text1.text
        color: marqueeRoot.textColor
        font: text1.font
        visible: marqueeRoot.isOverflowing

        Behavior on color {
            ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
        }
    }

    // Animasi Bergeser Linear Tanpa Ujung (Continuous Endless Loop)
    NumberAnimation {
        id: anim
        property real xOffset: 0
        target: anim
        property: "xOffset"
        from: 0
        to: -marqueeRoot.loopSpan
        duration: Math.max(3000, marqueeRoot.loopSpan * 45)
        loops: Animation.Infinite
        running: marqueeRoot.isOverflowing && marqueeRoot.isPlaying
        easing.type: Easing.Linear

        onRunningChanged: if (!running) xOffset = 0
    }
}
