import QtQuick
import Quickshell
import Quickshell.Wayland
import "../widgets"
import "../theme"

// 🖼️ DESKTOP CLOCK WIDGET (Wayland PanelWindow pada Layer Bottom / Desktop)
PanelWindow {
    id: desktopClockWindow

    // 🏷️ LayerShell Config untuk Desktop Widget
    WlrLayershell.namespace: "quickshell:desktop-widget"
    WlrLayershell.layer: WlrLayer.Bottom  // Berada tepat di atas wallpaper, di bawah jendela aplikasi
    exclusionMode: ExclusionMode.Ignore   // Tidak memotong tiling window

    color: "transparent"

    // 📍 POSISI DESKTOP WIDGET (Default: Kiri Atas)
    // Silakan sesuaikan margin atau jangkar (anchors) sesuai keinginan Anda
    anchors {
        bottom: true
        left: true
    }

    margins {
        bottom: 100
        left: 80
    }

    implicitWidth: clockItem.implicitWidth
    implicitHeight: clockItem.implicitHeight

    // 🕒 KOMPONEN JAM UTAMA
    LargeClock {
        id: clockItem
        timePixelSize: 64
        datePixelSize: 18
    }
}
