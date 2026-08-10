import QtQuick
import QtQuick.Layouts
import Quickshell
import "../widgets/Bar"
import "../theme"

PanelWindow {
    implicitHeight: 40
    color: 'transparent'

    anchors {
        top: true
        left: true
        right: true
    }

    margins {
        top: 8
        left: 15
        right: 15
    }

    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.5)
        radius: 20

        // ✨ ANIMASI FADE WARNA BACKGROUND (Saat ganti wallpaper)
        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    // 📍 1. PULAU KIRI (Workspace & Media Player)
    RowLayout {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10
        spacing: 12

        Workspace {}

        MediaPlayer {}
    }

    // 📍 2. PULAU TENGAH (Clock - 100% Persis di Tengah Layar)
    Clock {
        anchors.centerIn: parent
    }

    // 📍 3. PULAU KANAN (System Stats: RAM, CPU, Battery, Wi-Fi)
    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10

        SystemStats {}
    }
}
