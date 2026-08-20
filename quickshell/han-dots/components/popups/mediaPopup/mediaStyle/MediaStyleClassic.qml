import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import "../../../../theme"

// 🎵 MEDIA PLAYER STYLE: CLASSIC (310×485 px)
// Pure move dari MediaPopup.qml — tidak ada perubahan kode sama sekali
Item {
    id: classicRoot

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

    // 📦 KONTEN UTAMA MEDIA PLAYER POPUP
    ColumnLayout {
        anchors.fill: parent
        spacing: 12

        // 🖼️ 1. COVER ALBUM 1:1 ASPECT RATIO DENGAN CORNER RADIUS (DI-SCALE UP)
        Rectangle {
            id: coverContainer
            Layout.fillWidth: true
            implicitHeight: width
            radius: 16
            color: Theme.accent
            clip: true

            Image {
                id: popupCover
                anchors.fill: parent
                source: (classicRoot.player && classicRoot.player.trackArtUrl) ? classicRoot.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectCrop
                smooth: true
                mipmap: true
                sourceSize: Qt.size(300, 300)
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
                radius: 16
                visible: false
                layer.enabled: true
            }

            Text {
                anchors.centerIn: parent
                text: "󰎈"
                color: Theme.bgDark
                font { family: Theme.fontMono; pixelSize: 56 }
                visible: popupCover.status !== Image.Ready
            }
        }

        // 📝 2. JUDUL LAGU & NAMA ARTIS (SCALED UP)
        ColumnLayout {
            spacing: 3
            Layout.fillWidth: true

            Text {
                text: (classicRoot.player && classicRoot.player.trackTitle) ? classicRoot.player.trackTitle : "No Media"
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 17; bold: true }
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: classicRoot.artistName
                color: Theme.accent
                font { family: Theme.fontMain; pixelSize: 13 }
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }
        }

        // 🎵 3. PROGRESS BAR INTERAKTIF (Klik / Drag untuk Seek)
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            // 🎚️ TRACK PROGRESS BAR
            Item {
                Layout.fillWidth: true
                implicitHeight: 20

                // Track background (garis abu-abu)
                Rectangle {
                    id: progressTrack
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    height: seekMouseArea.containsMouse || classicRoot.isSeeking ? 10 : 8
                    radius: height / 2
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.2)

                    Behavior on height {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

                    // Track fill (garis aksen berwarna)
                    Rectangle {
                        id: progressFill
                        height: parent.height
                        width: progressTrack.width * ((classicRoot.player && classicRoot.player.length > 0) ? Math.min(1.0, Math.max(0.0, classicRoot.displayPosition / classicRoot.player.length)) : 0.0)
                        radius: parent.radius
                        color: Theme.accent

                        Behavior on width {
                            enabled: !classicRoot.isSeeking
                            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                        }
                    }

                    // Thumb (lingkaran putih kecil di ujung fill)
                    Rectangle {
                        id: progressThumb
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.min(progressFill.width - width / 2, progressTrack.width - width)
                        width: seekMouseArea.containsMouse || classicRoot.isSeeking ? 16 : 0
                        height: width
                        radius: width / 2
                        color: Theme.textMain

                        Behavior on width {
                            NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                        }
                    }
                }

                // 🖱️ MOUSEAREA UNTUK KLIK & DRAG SEEK
                MouseArea {
                    id: seekMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor

                    onPressed: (mouse) => {
                        if (!classicRoot.player || !classicRoot.player.canSeek || classicRoot.player.length <= 0) return
                        var ratio = Math.min(1.0, Math.max(0.0, mouse.x / progressTrack.width))
                        classicRoot.seekStarted(ratio * classicRoot.player.length)
                    }

                    onPositionChanged: (mouse) => {
                        if (!classicRoot.isSeeking || !classicRoot.player || classicRoot.player.length <= 0) return
                        var ratio = Math.min(1.0, Math.max(0.0, mouse.x / progressTrack.width))
                        classicRoot.seekPosition = ratio * classicRoot.player.length
                    }

                    onReleased: {
                        if (!classicRoot.isSeeking || !classicRoot.player || !classicRoot.player.canSeek) return
                        classicRoot.seekRequested(classicRoot.seekPosition)
                        classicRoot.seekEnded()
                    }

                    onCanceled: { classicRoot.seekEnded() }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: classicRoot.player ? classicRoot.formatTime(classicRoot.displayPosition) : "0:00"
                    color: Theme.accent
                    font { family: Theme.fontMain; pixelSize: 12 }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: classicRoot.player ? classicRoot.formatTime(classicRoot.player.length) : "0:00"
                    color: Theme.accent
                    font { family: Theme.fontMain; pixelSize: 12 }
                }
            }
        }

        // ⏯️ 4. TOMBOL KONTROL PREV, PLAY/PAUSE, NEXT (SCALED UP TO 48px)
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 24

            // 󰒮 Previous
            Item {
                implicitWidth: 38
                implicitHeight: 38

                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    color: Theme.textMain
                    font { family: Theme.fontMono; pixelSize: 22 }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (classicRoot.player && typeof classicRoot.player.previous === "function") classicRoot.player.previous()
                }
            }

            // 󰏤 / 󰐊 Play / Pause
            Rectangle {
                implicitWidth: 48
                implicitHeight: 48
                radius: 24
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                border.color: Theme.textMain
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: (classicRoot.player && classicRoot.player.isPlaying) ? 0 : 1.5
                    text: (classicRoot.player && classicRoot.player.isPlaying) ? "󰏤" : "󰐊"
                    color: Theme.textMain
                    font { family: Theme.fontMono; pixelSize: 24 }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (classicRoot.player) {
                            if (typeof classicRoot.player.playPause === "function") classicRoot.player.playPause()
                            else if (typeof classicRoot.player.togglePlaying === "function") classicRoot.player.togglePlaying()
                            else classicRoot.player.isPlaying = !classicRoot.player.isPlaying
                        }
                    }
                }
            }

            // 󰒭 Next
            Item {
                implicitWidth: 38
                implicitHeight: 38

                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    color: Theme.textMain
                    font { family: Theme.fontMono; pixelSize: 22 }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: if (classicRoot.player && typeof classicRoot.player.next === "function") classicRoot.player.next()
                }
            }
        }
    }
}
