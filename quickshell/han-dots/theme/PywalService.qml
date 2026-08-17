import QtQuick
import Quickshell
import Quickshell.Io

// 🎨 PYWAL SERVICE — Membaca warna dari ~/.cache/wal/colors.json dan
// mengaplikasikan KEDUA palette (dark & light) sekaligus via Theme.applyPywalColors().
//
// Pemetaan warna dari colors.json:
//   Dark  → special.background / special.foreground / color4 / color3
//   Light → color15 (bg terang) / color0 (teks gelap) / color4 (accent) / color8 (mid-tone)
//
// color15 = warna paling terang dari palette wallpaper (near-white atau pastel)
// color0  = warna paling gelap (sama dengan background dark) → cocok sebagai teks di bg terang
// color8  = mid-tone, cocok sebagai secondary/dimmer text di bg terang

Item {
    id: pywalService

    Process {
        id: walReader
        command: ["cat", Quickshell.env("HOME") + "/.cache/wal/colors.json"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (!this.text || this.text.trim() === "") return
                try {
                    var json = JSON.parse(this.text)
                    if (json && json.special && json.colors) {
                        Theme.applyPywalColors(
                            // ── Dark palette ──────────────────────────────────
                            json.special.background,   // dark bg
                            json.special.foreground,   // dark text
                            json.colors.color4,        // dark accent
                            json.colors.color3,        // dark secondary

                            // ── Light palette (derived dari wallpaper) ────────
                            json.colors.color15,       // light bg  (warna paling terang)
                            json.colors.color0,        // light text (warna paling gelap)
                            json.colors.color4,        // light accent (sama — accent universal)
                            json.colors.color8         // light secondary (mid-tone)
                        )
                    }
                } catch (e) {
                    console.log("[PywalService] Error parsing colors.json: " + e)
                }
            }
        }
    }

    // Poll setiap 2 detik agar sinkron otomatis saat wallpaper berganti
    Timer {
        interval: 2000
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
