import QtQuick
import Quickshell

PanelWindow {
    // Posisi layer shell di bagian atas layar (status bar)
    anchors {
        top: true
        left: true
        right: true
    }

    // Tinggi bar dan warna background (Catppuccin Mocha)
    height: 40
    color: "#1e1e2e"

    // Teks di tengah bar
    Text {
        anchors.centerIn: parent
        text: "Testing Quickshell Bar"
        color: "#cdd6f4"
        font.pixelSize: 16
        font.bold: true
    }
}

