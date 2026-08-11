import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris
import "../../theme"
import "../../components/popups"
import "mediaPlayerWidget"

Item {
    id: mediaRoot

    property var barWindow: null

    // 🎵 Smart-select player MPRIS yang sedang aktif/diputar (mengabaikan instance browser yang idle)
    readonly property var activePlayer: {
        var players = Mpris.players.values
        if (!players || players.length === 0) return null

        // 1. Prioritaskan player yang sedang diputar (isPlaying == true)
        for (var i = 0; i < players.length; i++) {
            var p = players[i]
            if (p && p.isPlaying) return p
        }

        // 2. Jika tidak ada yang diputar, prioritaskan player yang memiliki trackTitle
        for (var j = 0; j < players.length; j++) {
            var p2 = players[j]
            if (p2 && p2.trackTitle && p2.trackTitle !== "") return p2
        }

        return players[0]
    }

    readonly property var player: activePlayer
    readonly property bool hasMedia: player !== null && (player.trackTitle !== "" || player.isPlaying)

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

    // ⏱️ TIMER DELAY HOVER POPUP
    Timer {
        id: closeTimer
        interval: 300
        onTriggered: mediaPopup.isOpen = false
    }

    // 🪟 SUB-KOMPONEN 1: MEDIA POPUP HOVER CARD
    MediaPopup {
        id: mediaPopup
        barWindow: mediaRoot.barWindow
        mediaRootItem: mediaRoot
        player: mediaRoot.player
        artistName: mediaRoot.getArtistName(mediaRoot.player)

        onKeepOpen: closeTimer.stop()
        onStartCloseTimer: closeTimer.restart()
    }

    implicitWidth: hasMedia ? mediaLayout.implicitWidth + 8 : 0
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

        // 🌊 SUB-KOMPONEN 2: CAVA AUDIO VISUALIZER BARS (z: 0)
        CavaVisualizer {
            isPlaying: mediaRoot.hasMedia && mediaRoot.player ? mediaRoot.player.isPlaying : false
        }

        // 🎶 KONTEN UTAMA STATUS BAR (z: 1)
        RowLayout {
            id: mediaLayout
            anchors.centerIn: parent
            spacing: 8
            z: 1

            // 🧠🌡️ PILL RECTANGLE HOVER EFEK PADA COVER & TEKS MEDIA (PERSIS SYSTEMSTATS & CLOCK)
            Rectangle {
                id: mediaPill
                implicitWidth: infoLayout.implicitWidth + 10
                implicitHeight: 26
                radius: 8
                color: (mediaMouseArea.containsMouse || mediaPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15) : "transparent"
                border.color: (mediaMouseArea.containsMouse || mediaPopup.isOpen) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : "transparent"
                border.width: 1

                Behavior on color { ColorAnimation { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                // 🖱️ MOUSEAREA UNTUK COVER & TEKS MEDIA
                MouseArea {
                    id: mediaMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: {
                        closeTimer.stop()
                        mediaPopup.isOpen = true
                    }
                    onExited: {
                        closeTimer.restart()
                    }
                }

                RowLayout {
                    id: infoLayout
                    anchors.centerIn: parent
                    spacing: 6

                    // 🖼️ Cover Album / Art Image
                    Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 5
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
                            font { family: Theme.fontMono; pixelSize: 11 }
                            visible: coverImage.status !== Image.Ready
                        }
                    }

                    // 🎶 MARQUEE TEXT JUDUL & ARTIS
                    Item {
                        implicitWidth: 90
                        implicitHeight: textColumn.implicitHeight
                        Layout.preferredWidth: 90
                        Layout.maximumWidth: 90

                        ColumnLayout {
                            id: textColumn
                            anchors.fill: parent
                            spacing: 0

                            MarqueeText {
                                text: (player && player.trackTitle) ? player.trackTitle : "No Media"
                                textFont.family: Theme.fontMain
                                textFont.pixelSize: 11
                                textFont.bold: true
                                textColor: Theme.textMain
                                targetWidth: 90
                                isPlaying: mediaRoot.player ? mediaRoot.player.isPlaying : false
                            }

                            MarqueeText {
                                text: mediaRoot.getArtistName(player)
                                textFont.family: Theme.fontMain
                                textFont.pixelSize: 9
                                textColor: Theme.secondary
                                targetWidth: 90
                                isPlaying: mediaRoot.player ? mediaRoot.player.isPlaying : false
                            }
                        }
                    }
                }
            }

            // ⏯️ TOMBOL KONTROL (Previous, Play/Pause, Next)
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
                        onClicked: if (player && typeof player.previous === "function") player.previous()
                    }
                }

                // 󰏤 / 󰐊 Play / Pause
                Item {
                    implicitWidth: 24
                    implicitHeight: 24

                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: (player && player.isPlaying) ? 0 : 1
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
                        onClicked: if (player && typeof player.next === "function") player.next()
                    }
                }
            }
        }
    }
}
