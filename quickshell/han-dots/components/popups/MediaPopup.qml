import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import "../../widgets"
import "../../theme"

// 🎵 MEDIA PLAYER POPUP (Berada di components/popups/ & Inherit BasePopup dari widgets/)
BasePopup {
    id: popupRoot

    property var mediaRootItem: null
    targetItem: mediaRootItem

    property var player: null
    property string artistName: "Unknown Artist"

    // 🌟 REAL-TIME POSITION TRACKER
    property real currentPosition: 0

    // 🌟 STATE SAAT USER SEDANG DRAGGING PROGRESS BAR
    property bool isSeeking: false
    property real seekPosition: 0

    // Posisi yang aktif ditampilkan: pakai seekPosition saat dragging, currentPosition saat normal
    readonly property real displayPosition: isSeeking ? seekPosition : currentPosition

    // 📐 UKURAN POPUP PROPOSIONAL DI-SCALE UP (310x450 px)
    implicitWidth: 310
    implicitHeight: 485

    // ⏱️ TIMER DETIK REAL-TIME
    Timer {
        id: posTicker
        interval: 1000
        running: popupRoot.isOpen && popupRoot.player !== null && popupRoot.player.isPlaying
        repeat: true
        onTriggered: {
            if (popupRoot.player) {
                var dbusPos = popupRoot.player.position
                if (dbusPos !== undefined && dbusPos > 0) {
                    popupRoot.currentPosition = dbusPos
                } else {
                    popupRoot.currentPosition += 1000000
                }
            }
        }
        onRunningChanged: {
            if (running && popupRoot.player) {
                popupRoot.currentPosition = popupRoot.player.position || 0
            }
        }
    }

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
                source: (player && player.trackArtUrl) ? player.trackArtUrl : ""
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
                text: (player && player.trackTitle) ? player.trackTitle : "No Media"
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 17; bold: true }
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: popupRoot.artistName
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
                    height: seekMouseArea.containsMouse || popupRoot.isSeeking ? 10 : 8
                    radius: height / 2
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.2)

                    Behavior on height {
                        NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                    }

                    // Track fill (garis aksen berwarna)
                    Rectangle {
                        id: progressFill
                        height: parent.height
                        width: progressTrack.width * ((player && player.length > 0) ? Math.min(1.0, Math.max(0.0, popupRoot.displayPosition / player.length)) : 0.0)
                        radius: parent.radius
                        color: Theme.accent

                        Behavior on width {
                            enabled: !popupRoot.isSeeking
                            NumberAnimation { duration: 250; easing.type: Easing.OutCubic }
                        }
                    }

                    // Thumb (lingkaran putih kecil di ujung fill)
                    Rectangle {
                        id: progressThumb
                        anchors.verticalCenter: parent.verticalCenter
                        x: Math.min(progressFill.width - width / 2, progressTrack.width - width)
                        width: seekMouseArea.containsMouse || popupRoot.isSeeking ? 16 : 0
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
                        if (!player || !player.canSeek || player.length <= 0) return
                        popupRoot.isSeeking = true
                        var ratio = Math.min(1.0, Math.max(0.0, mouse.x / progressTrack.width))
                        popupRoot.seekPosition = ratio * player.length
                    }

                    onPositionChanged: (mouse) => {
                        if (!popupRoot.isSeeking || !player || player.length <= 0) return
                        var ratio = Math.min(1.0, Math.max(0.0, mouse.x / progressTrack.width))
                        popupRoot.seekPosition = ratio * player.length
                    }

                    onReleased: {
                        if (!popupRoot.isSeeking || !player || !player.canSeek) return
                        var targetMicros = popupRoot.seekPosition
                        var offsetMicros = targetMicros - player.position
                        player.seek(offsetMicros)
                        popupRoot.currentPosition = targetMicros
                        popupRoot.isSeeking = false
                    }

                    onCanceled: { popupRoot.isSeeking = false }
                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: player ? popupRoot.formatTime(popupRoot.displayPosition) : "0:00"
                    color: Theme.accent
                    font { family: Theme.fontMain; pixelSize: 12 }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: player ? popupRoot.formatTime(player.length) : "0:00"
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
                    onClicked: if (player && typeof player.previous === "function") player.previous()
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
                    anchors.horizontalCenterOffset: (player && player.isPlaying) ? 0 : 1.5
                    text: (player && player.isPlaying) ? "󰏤" : "󰐊"
                    color: Theme.textMain
                    font { family: Theme.fontMono; pixelSize: 24 }
                    Behavior on color { ColorAnimation { duration: 200; easing.type: Easing.InOutQuad } }
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
                    onClicked: if (player && typeof player.next === "function") player.next()
                }
            }
        }
    }
}
