import "../widgets/Bar"
import QtQuick
import QtQuick.Layouts
import Quickshell

PanelWindow {
    implicitHeight: 40
    color: '#364b4b4b'

    anchors {
        top: true
        left: true
        right: true
    }

    // 📍 1. PULAU KIRI (Workspace)
    RowLayout {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 10

        Workspace {}
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
