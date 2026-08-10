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

            // 🎶 Judul Lagu & Artis (Dengan Seamless Endless Infinite Marquee Loop)
            ColumnLayout {
                spacing: 0
                Layout.preferredWidth: 80
                Layout.maximumWidth: 80

                // 📜 1. SEAMLESS INFINITE MARQUEE JUDUL LAGU
                Item {
                    id: titleContainer
                    Layout.preferredWidth: 80
                    Layout.maximumWidth: 80
                    implicitHeight: titleText1.implicitHeight
                    clip: true

                    readonly property bool isOverflowing: titleText1.contentWidth > titleContainer.width
                    readonly property real loopSpan: titleText1.contentWidth + 24

                    // Copy 1
                    Text {
                        id: titleText1
                        x: titleContainer.isOverflowing ? titleAnim.xOffset : 0
                        text: (player && player.trackTitle) ? player.trackTitle : "No Media"
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 11; bold: true }

                        Behavior on color {
                            ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
                        }
                    }

                    // Copy 2 (Berada di belakang Copy 1 untuk efek Seamless Loop tanpa henti)
                    Text {
                        id: titleText2
                        x: titleContainer.isOverflowing ? (titleAnim.xOffset + titleContainer.loopSpan) : 0
                        text: titleText1.text
                        color: Theme.textMain
                        font: titleText1.font
                        visible: titleContainer.isOverflowing

                        Behavior on color {
                            ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
                        }
                    }

                    // Animasi Bergeser Linear Tanpa Ujung (Continuous Endless Loop)
                    NumberAnimation {
                        id: titleAnim
                        property real xOffset: 0
                        target: titleAnim
                        property: "xOffset"
                        from: 0
                        to: -titleContainer.loopSpan
                        duration: Math.max(3000, titleContainer.loopSpan * 45)
                        loops: Animation.Infinite
                        running: titleContainer.isOverflowing && player && player.isPlaying
                        easing.type: Easing.Linear

                        onRunningChanged: if (!running) xOffset = 0
                    }
                }

                // 📜 2. SEAMLESS INFINITE MARQUEE NAMA ARTIS
                Item {
                    id: artistContainer
                    Layout.preferredWidth: 100
                    Layout.maximumWidth: 100
                    implicitHeight: artistText1.implicitHeight
                    clip: true

                    readonly property bool isOverflowing: artistText1.contentWidth > artistContainer.width
                    readonly property real loopSpan: artistText1.contentWidth + 24

                    // Copy 1
                    Text {
                        id: artistText1
                        x: artistContainer.isOverflowing ? artistAnim.xOffset : 0
                        text: mediaRoot.getArtistName(player)
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 9 }

                        Behavior on color {
                            ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
                        }
                    }

                    // Copy 2 (Berada di belakang Copy 1 untuk efek Seamless Loop tanpa henti)
                    Text {
                        id: artistText2
                        x: artistContainer.isOverflowing ? (artistAnim.xOffset + artistContainer.loopSpan) : 0
                        text: artistText1.text
                        color: Theme.textMain
                        font: artistText1.font
                        visible: artistContainer.isOverflowing

                        Behavior on color {
                            ColorAnimation { duration: 300; easing.type: Easing.InOutQuad }
                        }
                    }

                    // Animasi Bergeser Linear Tanpa Ujung (Continuous Endless Loop)
                    NumberAnimation {
                        id: artistAnim
                        property real xOffset: 0
                        target: artistAnim
                        property: "xOffset"
                        from: 0
                        to: -artistContainer.loopSpan
                        duration: Math.max(3000, artistContainer.loopSpan * 45)
                        loops: Animation.Infinite
                        running: artistContainer.isOverflowing && player && player.isPlaying
                        easing.type: Easing.Linear

                        onRunningChanged: if (!running) xOffset = 0
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
