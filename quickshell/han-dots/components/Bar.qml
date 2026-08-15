import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../widgets/bar"
import "../theme"

PanelWindow {
    id: barWindow
    implicitHeight: 40
    color: 'transparent'

    WlrLayershell.namespace: "quickshell:bar"

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

    mask: Region {
        item: barBackground
    }

    Rectangle {
        id: barBackground
        anchors.fill: parent
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.65)
        radius: 20
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1

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

        Workspace {
            barWindow: barWindow
        }

        MediaPlayer {
            barWindow: barWindow
        }
    }

    // 📍 2. PULAU TENGAH (Clock - 100% Persis di Tengah Layar)
    Clock {
        barWindow: barWindow
        anchors.centerIn: parent
    }

    // 📍 3. PULAU KANAN (System Stats, Control Center, Notification Pill & Power)
    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10
        spacing: 8

        SystemStats {
            barWindow: barWindow
        }

        ControlCenter {
            barWindow: barWindow
        }

        NotificationPill {
            barWindow: barWindow
        }

        Power {
            barWindow: barWindow
        }
    }
}
