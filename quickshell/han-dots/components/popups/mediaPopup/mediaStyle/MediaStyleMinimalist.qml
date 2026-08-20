import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import "../../../../theme"

// 🎵 MEDIA PLAYER STYLE: MINIMALIST (Compact Horizontal Layout 340×155 px)
Item {
    id: minimalistRoot

    implicitWidth: 320
    implicitHeight: Math.max(120, mainRow.implicitHeight)

    // Props yang dioper dari shell wrapper (MediaPopup.qml)
    property var player: null
    property string artistName: "Unknown Artist"
    property real currentPosition: 0
    property bool isSeeking: false
    property real seekPosition: 0
    readonly property real displayPosition: isSeeking ? seekPosition : currentPosition

    // Signals untuk diteruskan ke shell wrapper
    signal seekRequested(real targetMicros)
    signal seekStarted(real pos)
    signal seekEnded()

    // Helper fungsi format detik ke MM:SS
    function formatTime(sec) {
        if (!sec || isNaN(sec) || sec <= 0) return "0:00"
        if (sec > 100000) sec = Math.floor(sec / 1000000)
        var m = Math.floor(sec / 60)
        var s = Math.floor(sec % 60)
        return m + ":" + (s < 10 ? "0" : "") + s
    }

    // 📦 KONTEN HORIZONAL RINGKAS
    RowLayout {
        id: mainRow
        anchors.fill: parent
        spacing: 14

        // 🖼️ 1. COVER ALBUM KECIL PERSEGI 1:1 (90x90 px)
        Rectangle {
            id: coverContainer
            implicitWidth: 120
            implicitHeight: 120
            radius: 12
            color: Theme.accent
            clip: true
            Layout.alignment: Qt.AlignVCenter

            Image {
                id: popupCover
                anchors.fill: parent
                source: (minimalistRoot.player && minimalistRoot.player.trackArtUrl) ? minimalistRoot.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                sourceSize: Qt.size(180, 180)
                visible: status === Image.Ready

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: maskRect
                }
            }

            Rectangle {
                id: maskRect
                width: coverContainer.width
                height: coverContainer.height
                radius: 12
                visible: false
                layer.enabled: true
            }

            Text {
                anchors.centerIn: parent
                text: "󰎈"
                color: Theme.bgDark
                font { family: Theme.fontMono; pixelSize: 32 }
                visible: popupCover.status !== Image.Ready
            }
        }

        // 📝 2. DETAIL INFORMASI, PROGRESS BAR, & KONTROL MEDIA (KOLOM KANAN)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 6

            Item { Layout.fillHeight: true }

            // Judul Lagu & Nama Artis
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    text: (minimalistRoot.player && minimalistRoot.player.trackTitle) ? minimalistRoot.player.trackTitle : "No Media"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 14; bold: true }
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }

                Text {
                    text: minimalistRoot.artistName
                    color: Theme.accent
                    font { family: Theme.fontMain; pixelSize: 12 }
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                }
            }

            // Progress Bar Ringkas
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 14

                    Rectangle {
                        id: progressTrack
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: seekMouseArea.containsMouse || minimalistRoot.isSeeking ? 6 : 4
                        radius: height / 2
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.2)

                        Behavior on height {
                            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                        }

                        Rectangle {
                            id: progressFill
                            height: parent.height
                            width: progressTrack.width * ((minimalistRoot.player && minimalistRoot.player.length > 0) ? Math.min(1.0, Math.max(0.0, minimalistRoot.displayPosition / minimalistRoot.player.length)) : 0.0)
                            radius: parent.radius
                            color: Theme.accent

                            Behavior on width {
                                enabled: !minimalistRoot.isSeeking
                                NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                            }
                        }

                        Rectangle {
                            anchors.verticalCenter: parent.verticalCenter
                            x: Math.min(progressFill.width - width / 2, progressTrack.width - width)
                            width: seekMouseArea.containsMouse || minimalistRoot.isSeeking ? 12 : 0
                            height: width
                            radius: width / 2
                            color: Theme.textMain

                            Behavior on width {
                                NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                            }
                        }
                    }

                    MouseArea {
                        id: seekMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor

                        onPressed: (mouse) => {
                            if (!minimalistRoot.player || !minimalistRoot.player.canSeek || minimalistRoot.player.length <= 0) return
                            var ratio = Math.min(1.0, Math.max(0.0, mouse.x / progressTrack.width))
                            minimalistRoot.seekStarted(ratio * minimalistRoot.player.length)
                        }

                        onPositionChanged: (mouse) => {
                            if (!minimalistRoot.isSeeking || !minimalistRoot.player || minimalistRoot.player.length <= 0) return
                            var ratio = Math.min(1.0, Math.max(0.0, mouse.x / progressTrack.width))
                            minimalistRoot.seekPosition = ratio * minimalistRoot.player.length
                        }

                        onReleased: {
                            if (!minimalistRoot.isSeeking || !minimalistRoot.player || !minimalistRoot.player.canSeek) return
                            minimalistRoot.seekRequested(minimalistRoot.seekPosition)
                            minimalistRoot.seekEnded()
                        }

                        onCanceled: { minimalistRoot.seekEnded() }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true

                    Text {
                        text: minimalistRoot.player ? minimalistRoot.formatTime(minimalistRoot.displayPosition) : "0:00"
                        color: Theme.accent
                        font { family: Theme.fontMain; pixelSize: 10 }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: minimalistRoot.player ? minimalistRoot.formatTime(minimalistRoot.player.length) : "0:00"
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)
                        font { family: Theme.fontMain; pixelSize: 10 }
                    }
                }
            }

            // Tombol Kontrol Media Ringkas (Prev, Play/Pause, Next)
            RowLayout {
                spacing: 16
                Layout.alignment: Qt.AlignCenter

                // Previous
                Item {
                    implicitWidth: 28
                    implicitHeight: 28

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 16 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (minimalistRoot.player && typeof minimalistRoot.player.previous === "function") minimalistRoot.player.previous()
                    }
                }

                // Play / Pause
                Rectangle {
                    implicitWidth: 36
                    implicitHeight: 36
                    radius: 18
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                    border.color: Theme.textMain
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: (minimalistRoot.player && minimalistRoot.player.isPlaying) ? 0 : 1
                        text: (minimalistRoot.player && minimalistRoot.player.isPlaying) ? "󰏤" : "󰐊"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 16 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (minimalistRoot.player) {
                                if (typeof minimalistRoot.player.playPause === "function") minimalistRoot.player.playPause()
                                else if (typeof minimalistRoot.player.togglePlaying === "function") minimalistRoot.player.togglePlaying()
                                else minimalistRoot.player.isPlaying = !minimalistRoot.player.isPlaying
                            }
                        }
                    }
                }

                // Next
                Item {
                    implicitWidth: 28
                    implicitHeight: 28

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 16 }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (minimalistRoot.player && typeof minimalistRoot.player.next === "function") minimalistRoot.player.next()
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }
}
