import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Mpris

// 🎵 MACOS CONTROL CENTER MEDIA TILE (Compact Now-Playing Card)
Rectangle {
    id: mediaTileRoot

    readonly property var activePlayer: {
        var players = Mpris.players.values;
        if (!players || players.length === 0)
            return null;

        for (var i = 0; i < players.length; i++) {
            var p = players[i];
            if (p && p.isPlaying)
                return p;

        }
        for (var j = 0; j < players.length; j++) {
            var p2 = players[j];
            if (p2 && p2.trackTitle && p2.trackTitle !== "")
                return p2;

        }
        return players[0];
    }
    readonly property var player: activePlayer
    readonly property bool hasMedia: player !== null && (player.trackTitle !== "" || player.isPlaying)

    function getArtistName(p) {
        if (!p)
            return "";

        if (p.trackArtist && p.trackArtist !== "")
            return p.trackArtist;

        if (p.trackAlbumArtist && p.trackAlbumArtist !== "")
            return p.trackAlbumArtist;

        if (p.trackArtists && p.trackArtists.length > 0 && p.trackArtists[0] !== "")
            return p.trackArtists.join(", ");

        if (p.metadata) {
            var metaArtist = p.metadata["xesam:artist"] || p.metadata["xesam:albumArtist"];
            if (metaArtist)
                return Array.isArray(metaArtist) ? metaArtist.join(", ") : metaArtist;

        }
        return "";
    }

    implicitWidth: 155
    implicitHeight: 114
    radius: 25
    color: mediaHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.14) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.09)
    border.color: mediaHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.24) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.14)
    border.width: 1

    HoverHandler {
        id: mediaHover
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 10
        anchors.bottomMargin: 10
        spacing: 0

        // 🖼️ 1. ALBUM ART COVER (TOP-LEFT)
        Rectangle {
            id: artCoverBox

            implicitWidth: 36
            implicitHeight: 36
            radius: 8
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12)
            border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
            border.width: 1

            Image {
                id: artImg

                anchors.fill: parent
                source: (mediaTileRoot.hasMedia && mediaTileRoot.player && mediaTileRoot.player.trackArtUrl) ? mediaTileRoot.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                visible: status === Image.Ready
                layer.enabled: true

                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: artMask
                }

            }

            Rectangle {
                id: artMask

                anchors.fill: parent
                radius: 8
                visible: false
                layer.enabled: true
            }

            Text {
                anchors.centerIn: parent
                visible: !artImg.visible && mediaTileRoot.hasMedia
                text: "󰎆"
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.35)

                font {
                    family: Theme.fontMono
                    pixelSize: 18
                }

            }

        }

        Item {
            Layout.fillHeight: true
        }

        // 📝 2. TRACK TITLE & ARTIST (MIDDLE)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                Layout.fillWidth: true
                text: mediaTileRoot.hasMedia ? (mediaTileRoot.player.trackTitle || "Unknown Track") : "Not Playing"
                color: Theme.textMain
                elide: Text.ElideRight
                maximumLineCount: 1

                font {
                    family: Theme.fontMain
                    pixelSize: 12
                    bold: true
                }

            }

            Text {
                Layout.fillWidth: true
                visible: mediaTileRoot.hasMedia && text !== ""
                text: mediaTileRoot.hasMedia ? mediaTileRoot.getArtistName(mediaTileRoot.player) : ""
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)
                elide: Text.ElideRight
                maximumLineCount: 1

                font {
                    family: Theme.fontMain
                    pixelSize: 10
                }

            }

        }

        Item {
            Layout.fillHeight: true
        }

        // ⏯️ 3. PLAYBACK CONTROLS (BOTTOM)
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: 14

            // 󰒮 Previous
            Item {
                implicitWidth: 28
                implicitHeight: 22

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: prevHover.hovered ? Theme.accent : (mediaTileRoot.hasMedia ? Theme.textMain : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4))

                    font {
                        family: Theme.fontMono
                        pixelSize: 16
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                HoverHandler {
                    id: prevHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: mediaTileRoot.hasMedia
                    onClicked: {
                        if (mediaTileRoot.player && typeof mediaTileRoot.player.previous === "function")
                            mediaTileRoot.player.previous();

                    }
                }

            }

            // 󰐊 / 󰏤 Play / Pause
            Item {
                implicitWidth: 32
                implicitHeight: 22

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: (mediaTileRoot.hasMedia && mediaTileRoot.player && mediaTileRoot.player.isPlaying) ? 0 : 1
                    text: (mediaTileRoot.hasMedia && mediaTileRoot.player && mediaTileRoot.player.isPlaying) ? "󰏤" : "󰐊"
                    color: playHover.hovered ? Theme.accent : Theme.textMain

                    font {
                        family: Theme.fontMono
                        pixelSize: 22
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                HoverHandler {
                    id: playHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: mediaTileRoot.hasMedia
                    onClicked: {
                        if (mediaTileRoot.player) {
                            if (typeof mediaTileRoot.player.playPause === "function")
                                mediaTileRoot.player.playPause();
                            else if (typeof mediaTileRoot.player.togglePlaying === "function")
                                mediaTileRoot.player.togglePlaying();
                            else
                                mediaTileRoot.player.isPlaying = !mediaTileRoot.player.isPlaying;
                        }
                    }
                }

            }

            // 󰒭 Next
            Item {
                implicitWidth: 28
                implicitHeight: 22

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: nextHover.hovered ? Theme.accent : (mediaTileRoot.hasMedia ? Theme.textMain : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4))

                    font {
                        family: Theme.fontMono
                        pixelSize: 16
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                HoverHandler {
                    id: nextHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    enabled: mediaTileRoot.hasMedia
                    onClicked: {
                        if (mediaTileRoot.player && typeof mediaTileRoot.player.next === "function")
                            mediaTileRoot.player.next();

                    }
                }

            }

        }

    }

}
