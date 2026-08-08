import QtQuick
import Quickshell
import "./components/"
import "./theme/"

Scope {
    // 🔄 Service pemantau warna Pywal di background
    PywalService {}

    // 🖥️ Status Bar Utama
    Bar {}
}
