import "../../../services"
import "../../../theme"
import "../../../widgets/bar"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// 🏛️ BAR STYLE 1: UNIFIED BAR
// Satu PanelWindow tunggal (namespace "quickshell:bar").
// Niri mem-blur seluruh permukaan ini sebagai satu kesatuan.
PanelWindow {
    id: unifiedBar

    WlrLayershell.namespace: "quickshell:bar"
    WlrLayershell.layer: WlrLayer.Top
    exclusionMode: ExclusionMode.Auto
    implicitHeight: 40
    color: "transparent"

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
        id: barBackground

        anchors.fill: parent
        color: SettingsStore.barBgEnabled ? Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.barOpacity) : "transparent"
        radius: 20
        border.color: SettingsStore.barBgEnabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
        border.width: SettingsStore.barBgEnabled ? 1 : 0

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
            barWindow: unifiedBar
        }

        MediaPlayer {
            barWindow: unifiedBar
        }
 
    }

    // 📍 2. PULAU TENGAH (Clock - 100% Persis di Tengah Layar)
    Clock {
        barWindow: unifiedBar
        anchors.centerIn: parent
    }

    // 📍 3. PULAU KANAN (System Stats, Control Center, Notification Pill & Power)
    RowLayout {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 10
        spacing: 8

        SystemStats {
            barWindow: unifiedBar
        }

        ControlCenter {
            barWindow: unifiedBar
        }

        NotificationPill {
            barWindow: unifiedBar
        }

        Power {
            barWindow: unifiedBar
        }

    }

    mask: Region {
        item: barBackground
    }

}
