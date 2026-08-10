import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import "../../theme"

Item {
    id: mediaRoot

    // 🎵 Ambil player MPRIS pertama yang aktif
    readonly property var player: Mpris.players.values.length > 0 ? Mpris.players.values[0] : null
    readonly property bool hasMedia: player !== null && (player.trackTitle !== "" || player.isPlaying)

    // 🌊 Real Cava Audio Values Array (24 Batang)
    property var cavaValues: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    // 🔍 Helper fungsi untuk mendapatkan nama Artis
    function getArtistName(p) {
        if (!p) return ""
        if (p.trackArtist && p.trackArtist !== "") return p.trackArtist
        if (p.trackAlbumArtist && p.trackAlbumArtist !== "") return p.trackAlbumArtist
        if (p.trackArtists && p.trackArtists.length > 0 && p.trackArtists[0] !== "") {
            return p.trackArtists.join(", ")
        }
        if (p.metadata) {
            var metaArtist = p.metadata["xesam:artist"] || p.metadata["xesam:albumArtist"]
            if (metaArtist) {
                return Array.isArray(metaArtist) ? metaArtist.join(", ") : metaArtist
            }
        }
        return "Unknown Artist"
    }

    // 🎙️ CAVA REAL-TIME AUDIO PROCESS (PipeWire / PulseAudio Input)
    Process {
        id: cavaProc
        command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/config_quickshell"]
        running: hasMedia && player.isPlaying

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data || data.trim() === "") return
                var parts = data.trim().split(";")
                if (parts.length >= 24) {
                    var vals = []
                    for (var i = 0; i < 24; i++) {
                        vals.push(parseInt(parts[i]) || 0)
                    }
                    mediaRoot.cavaValues = vals
                }
            }
        }
    }

    implicitWidth: hasMedia ? mediaLayout.implicitWidth + 24 : 0
    implicitHeight: 32
    visible: hasMedia

    Behavior on implicitWidth {
        NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
    }

    Rectangle {
        anchors.fill: parent
        color: "transparent"
        radius: 8
        clip: true

        // 🌊 BACKGROUND CAVA AUDIO VISUALIZER BARS (Melebar Memenuhi SELURUH Container Rectangle)
        Row {
            anchors.fill: parent
            anchors.leftMargin: 6
            anchors.rightMargin: 6
            anchors.bottomMargin: 2
            spacing: 2
            z: 0

            Repeater {
                model: 24 // 24 Batang Cava melebarkan visualizer dari Ujung Kiri ke Ujung Kanan

                Rectangle {
                    id: bar
                    width: (parent.width - (23 * 2)) / 24
                    height: (player && player.isPlaying) ? Math.max(2, (mediaRoot.cavaValues[index] !== undefined ? mediaRoot.cavaValues[index] : 2)) : 2
                    radius: 2
                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
                    anchors.bottom: parent.bottom

                    Behavior on height {
                        NumberAnimation {
                            duration: 50
                            easing.type: Easing.OutCubic
                        }
                    }
                }
            }
        }

        // 🎶 KONTEN UTAMA (z: 1, Di Depan Visualizer Cava)
        RowLayout {
            id: mediaLayout
            anchors.centerIn: parent
            spacing: 8
            z: 1

            // 🖼️ Cover Album / Art Image
            Rectangle {
                implicitWidth: 24
                implicitHeight: 24
                radius: 6
                color: Theme.accent
                clip: true

                Image {
                    id: coverImage
                    anchors.fill: parent
                    source: (player && player.trackArtUrl) ? player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
                    visible: status === Image.Ready
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰎈"
                    color: Theme.bgDark
                    font { family: Theme.fontMono; pixelSize: 13 }
                    visible: coverImage.status !== Image.Ready
                }
            }

            // 🎶 Judul Lagu & Artis
            ColumnLayout {
                spacing: 0
                Layout.maximumWidth: 140

                Text {
                    text: (player && player.trackTitle) ? player.trackTitle : "No Media"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 11; bold: true }
                    elide: Text.ElideRight
                    Layout.fillWidth: true

                    Behavior on color {
                        ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
                    }
                }

                Text {
                    text: mediaRoot.getArtistName(player)
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 9 }
                    elide: Text.ElideRight
                    Layout.fillWidth: true

                    Behavior on color {
                        ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
                    }
                }
            }

            // ⏯️ Tombol Kontrol (Previous, Play/Pause, Next)
            RowLayout {
                spacing: 2

                // 󰒮 Previous
                Item {
                    implicitWidth: 22
                    implicitHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 14 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (player) {
                                if (typeof player.previous === "function") player.previous()
                            }
                        }
                    }
                }

                // 󰏤 / 󰐊 Play / Pause
                Item {
                    implicitWidth: 24
                    implicitHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: (player && player.isPlaying) ? "󰏤" : "󰐊"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 16 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (player) {
                                if (typeof player.playPause === "function") player.playPause()
                                else if (typeof player.togglePlaying === "function") player.togglePlaying()
                                else player.isPlaying = !player.isPlaying
                            }
                        }
                    }
                }

                // 󰒭 Next
                Item {
                    implicitWidth: 22
                    implicitHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 14 }
                        Behavior on color { ColorAnimation { duration: 300; easing.type: Easing.InOutQuad } }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (player) {
                                if (typeof player.next === "function") player.next()
                            }
                        }
                    }
                }
            }
        }
    }
}
