import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: pywalService

    // 🔄 Process untuk membaca colors.json Pywal dengan StdioCollector
    Process {
        id: walReader
        command: ["cat", Quickshell.env("HOME") + "/.cache/wal/colors.json"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (!this.text || this.text.trim() === "") return
                try {
                    var json = JSON.parse(this.text)
                    if (json && json.special && json.colors) {
                        Theme.bgDark = json.special.background
                        Theme.textMain = json.special.foreground
                        Theme.accent = json.colors.color4
                        Theme.secondary = json.colors.color2
                    }
                } catch (e) {
                    console.log("[PywalService] Error parsing colors.json: " + e)
                }
            }
        }
    }

    // 🕐 Timer polling setiap 2 detik untuk menyinkronkan warna dari Pywal
    Timer {
        interval: 200
        running: true
        repeat: true
        onTriggered: {
            walReader.running = false
            walReader.running = true
        }
    }

    Component.onCompleted: {
        walReader.running = true
    }
}
