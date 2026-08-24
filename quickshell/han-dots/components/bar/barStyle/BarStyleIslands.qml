import "../../../services"
import "../../../theme"
import "../../../widgets/bar"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// 🏛️ BAR STYLE 2: 3 FLOATING ISLANDS
// Tiga PanelWindow terpisah, masing-masing punya Wayland surface sendiri.
// Niri mem-blur tiap island secara independen:
//   - "quickshell:bar-left"   → blur untuk island Workspace + MediaPlayer
//   - "quickshell:bar-center" → blur untuk island Clock (auto-centered oleh compositor)
//   - "quickshell:bar-right"  → blur untuk island SystemStats + Controls
Scope {
    id: islandsRoot

    property var screen
    property bool islandsVisible: true

    // ─────────────────────────────────────────────────────────────────────────
    // 🔲 INVISIBLE SPACER — Klaim exclusive zone penuh agar window tidak menimpa bar
    // Di LayerShell Protocol, exclusive zone hanya bekerja pada surface yang
    // membentang penuh di satu sisi (anchors.top + left + right). Island kiri/kanan
    // yang hanya anchor ke satu sisi tidak bisa klaim exclusive zone penuh.
    // Spacer ini transparan (tidak terlihat) namun mendorong window aplikasi ke bawah.
    // ─────────────────────────────────────────────────────────────────────────
    PanelWindow {
        // Tidak ada konten visual — hanya untuk klaim exclusive zone
        // Mask kosong (Region {}) memastikan spacerWindow bersifat click-through (input region = 0)
        id: spacerWindow

        screen: islandsRoot.screen
        visible: islandsRoot.islandsVisible
        WlrLayershell.namespace: "quickshell:popup"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Auto
        anchors.top: true
        anchors.left: true
        anchors.right: true
        margins.top: 8
        implicitHeight: 40
        color: "transparent"

        mask: Region {
        } 

    }

    // ─────────────────────────────────────────────────────────────────────────
    // 📍 1. ISLAND KIRI — Workspace & Media Player
    // ─────────────────────────────────────────────────────────────────────────
    PanelWindow {
        id: leftBarWindow

        screen: islandsRoot.screen
        visible: islandsRoot.islandsVisible
        WlrLayershell.namespace: "quickshell:bar-left"
        WlrLayershell.layer: WlrLayer.Top
        // Hanya spacerWindow yang ExclusionMode.Auto — island ini pakai Ignore
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        anchors.left: true
        // Tanpa anchors.right → surface menempel ke kiri saja
        margins.top: 8
        margins.left: 15
        width: leftRow.implicitWidth + 20
        height: 40
        implicitWidth: leftRow.implicitWidth + 20
        implicitHeight: 40
        color: "transparent"

        Rectangle {
            id: leftCard

            anchors.fill: parent
            implicitWidth: leftRow.implicitWidth + 20
            radius: 20
            color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.barOpacity)
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
            border.width: 1

            RowLayout {
                id: leftRow

                anchors.centerIn: parent
                spacing: 12

                Workspace {
                    barWindow: leftBarWindow
                }

                MediaPlayer {
                    barWindow: leftBarWindow
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

            }

        }

        mask: Region {
            item: leftCard
        }

    }

    // ─────────────────────────────────────────────────────────────────────────
    // 📍 2. ISLAND TENGAH — Clock
    // Tanpa anchors.left & anchors.right → compositor (Niri) otomatis center-kan!
    // ─────────────────────────────────────────────────────────────────────────
    PanelWindow {
        id: centerBarWindow

        screen: islandsRoot.screen
        visible: islandsRoot.islandsVisible
        WlrLayershell.namespace: "quickshell:bar-center"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        // ✨ Tidak ada anchors.left / anchors.right → Layer Shell Protocol:
        // Surface tanpa horizontal anchor diposisikan di tengah secara otomatis oleh compositor.
        margins.top: 8
        width: clockWidget.implicitWidth + 24
        height: 40
        implicitWidth: clockWidget.implicitWidth + 24
        implicitHeight: 40
        color: "transparent"

        Rectangle {
            id: centerCard

            anchors.fill: parent
            implicitWidth: clockWidget.implicitWidth + 24
            radius: 20
            color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.barOpacity)
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
            border.width: 1

            Clock {
                id: clockWidget

                anchors.centerIn: parent
                barWindow: centerBarWindow
            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

            }

        }

        mask: Region {
            item: centerCard
        }

    }

    // ─────────────────────────────────────────────────────────────────────────
    // 📍 3. ISLAND KANAN — System Stats, Control Center, Notification & Power
    // ─────────────────────────────────────────────────────────────────────────
    PanelWindow {
        id: rightBarWindow

        screen: islandsRoot.screen
        visible: islandsRoot.islandsVisible
        WlrLayershell.namespace: "quickshell:bar-right"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        anchors.right: true
        // Tanpa anchors.left → surface menempel ke kanan saja
        margins.top: 8
        margins.right: 15
        width: rightRow.implicitWidth + 20
        height: 40
        implicitWidth: rightRow.implicitWidth + 20
        implicitHeight: 40
        color: "transparent"

        Rectangle {
            id: rightCard

            anchors.fill: parent
            implicitWidth: rightRow.implicitWidth + 20
            radius: 20
            color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.barOpacity)
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
            border.width: 1

            RowLayout {
                id: rightRow

                anchors.centerIn: parent
                spacing: 8

                SystemStats {
                    barWindow: rightBarWindow
                }

                ControlCenter {
                    barWindow: rightBarWindow
                }

                NotificationPill {
                    barWindow: rightBarWindow
                }

                Power {
                    barWindow: rightBarWindow
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 200
                    easing.type: Easing.InOutQuad
                }

            }

        }

        mask: Region {
            item: rightCard
        }

    }

}
