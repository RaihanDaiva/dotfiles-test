import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../../theme"

// 🪟 Menggunakan PanelWindow agar terkena layerrule blur Hyprland
// (PopupWindow = xdg_popup, tidak bisa kena layerrule)
PanelWindow {
    id: popupRoot

    property var barWindow: null
    property var mediaRootItem: null
    property var player: null
    property string artistName: "Unknown Artist"

    // 🌟 REAL-TIME POSITION TRACKER
    property real currentPosition: 0

    // 🌟 STATE SAAT USER SEDANG DRAGGING PROGRESS BAR
    property bool isSeeking: false
    property real seekPosition: 0

    // Posisi yang aktif ditampilkan: pakai seekPosition saat dragging, currentPosition saat normal
    readonly property real displayPosition: isSeeking ? seekPosition : currentPosition

    // 🌟 CONTROL STATE UNTUK ANIMASI IN & OUT
    property bool isOpen: false

    signal keepOpen()
    signal startCloseTimer()

    // 🏷️ Namespace khusus popup agar bisa di-blur via layerrule Hyprland
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    // 📐 Posisi popup: tepat di bawah bar, tengah-tengah MediaPlayer
    anchors.top: true
    anchors.left: true

    // 📐 Fungsi kalkulasi posisi horizontal (Centered tepat di bawah MediaPlayer)
    function updatePosition() {
        if (!mediaRootItem) return
        var barLeft = barWindow ? barWindow.margins.left : 15
        var itemX = mediaRootItem.mapToItem(null, 0, 0).x
        var itemWidth = mediaRootItem.width
        var popupWidth = popupRoot.implicitWidth
        popupRoot.margins.left = Math.max(8, Math.round(barLeft + itemX + (itemWidth / 2) - (popupWidth / 2)))
    }

    onIsOpenChanged: {
        if (isOpen) updatePosition()
    }

    // Posisi vertikal: 6px di bawah bar (LayerShell otomatis memosisikan di bawah exclusive zone bar)
    margins.top: 6

    // 📐 UKURAN POPUP PRESISI DENGAN GAP BAWAH (420px height)
    implicitWidth: 270
    implicitHeight: 420

    // Warna transparent agar blur dari Hyprland terlihat
    color: "transparent"

    // 🪟 Hanya visible saat isOpen atau saat animasi keluar masih berjalan
    visible: isOpen || hideAnim.running

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
                    // position dalam mikrodetik, tambahkan 1 detik = 1.000.000 mikrodetik
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

    Rectangle {
        id: popupCard
        anchors.fill: parent
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.5)
        radius: 18
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1

        // 🌟 1. FADE ANIMATION (ENTER & EXIT)
        opacity: popupRoot.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                id: hideAnim
                duration: 180
                easing.type: popupRoot.isOpen ? Easing.OutCubic : Easing.InQuad
            }
        }

        // 🌟 2. SLIDE ANIMATION (ENTER & EXIT)
        transform: Translate {
            y: popupRoot.isOpen ? 0 : -15

            Behavior on y {
                NumberAnimation {
                    duration: 180
                    easing.type: popupRoot.isOpen ? Easing.OutCubic : Easing.InQuad
                }
            }
        }

        // 🔑 HoverHandler menggantikan MouseArea untuk hover detection
        // HoverHandler TIDAK memicu "exited" saat cursor masuk ke child item
        HoverHandler {
            onHoveredChanged: {
                if (hovered) popupRoot.keepOpen()
                else popupRoot.startCloseTimer()
            }
        }

        ColumnLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            // 🖼️ 1. COVER ALBUM 1:1 ASPECT RATIO DENGAN CORNER RADIUS
            Rectangle {
                id: coverContainer
                Layout.fillWidth: true
                implicitHeight: width
                radius: 14
                color: Theme.accent
                clip: true
                

                Image {
                    id: popupCover
                    anchors.fill: parent
                    source: (player && player.trackArtUrl) ? player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectCrop
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
                    radius: 14
                    visible: false
                    layer.enabled: true
                }

                Text {
                    anchors.centerIn: parent
                    text: "󰎈"
                    color: Theme.bgDark
                    font { family: Theme.fontMono; pixelSize: 48 }
                    visible: popupCover.status !== Image.Ready
                }
            }

            // 🎵 2. PROGRESS BAR INTERAKTIF (Klik / Drag untuk Seek)
            ColumnLayout {
                spacing: 4
                Layout.fillWidth: true

                // 🎚️ TRACK PROGRESS BAR
                Item {
                    Layout.fillWidth: true
                    implicitHeight: 18 // Area touch lebih besar agar mudah diklik

                    // Track background (garis abu-abu)
                    Rectangle {
                        id: progressTrack
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.right: parent.right
                        height: seekMouseArea.containsMouse || popupRoot.isSeeking ? 8 : 6
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
                            width: seekMouseArea.containsMouse || popupRoot.isSeeking ? 14 : 0
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

                        // 👇 KLIK: Langsung seek ke posisi yang diklik
                        onPressed: (mouse) => {
                            if (!player || !player.canSeek || player.length <= 0) return
                            popupRoot.isSeeking = true
                            var ratio = Math.min(1.0, Math.max(0.0, mouse.x / progressTrack.width))
                            popupRoot.seekPosition = ratio * player.length
                        }

                        // 👆 DRAG: Update posisi seek sambil geser
                        onPositionChanged: (mouse) => {
                            if (!popupRoot.isSeeking || !player || player.length <= 0) return
                            var ratio = Math.min(1.0, Math.max(0.0, mouse.x / progressTrack.width))
                            popupRoot.seekPosition = ratio * player.length
                        }

                        // ✅ RELEASE: Kirim perintah seek ke MPRIS player
                        onReleased: {
                            if (!popupRoot.isSeeking || !player || !player.canSeek) return
                            // player.position & seekPosition sudah dalam MIKRODETIK
                            // seek() menerima offset RELATIF dalam mikrodetik → cukup kurangi saja
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
                        color: popupRoot.isSeeking ? Theme.accent : Theme.accent
                        font { family: Theme.fontMain; pixelSize: 10 }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }

                    Item { Layout.fillWidth: true }

                    Text {
                        text: player ? popupRoot.formatTime(player.length) : "0:00"
                        color: Theme.accent
                        font { family: Theme.fontMain; pixelSize: 10 }
                    }
                }
            }

            // 📝 3. JUDUL LAGU & NAMA ARTIS
            ColumnLayout {
                spacing: 2
                Layout.fillWidth: true

                Text {
                    text: (player && player.trackTitle) ? player.trackTitle : "No Media"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 14; bold: true }
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: popupRoot.artistName
                    color: Theme.accent
                    font { family: Theme.fontMain; pixelSize: 11 }
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }
            }

            // ⏯️ 4. TOMBOL KONTROL PREV, PLAY/PAUSE, NEXT
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 20

                // 󰒮 Previous
                Item {
                    implicitWidth: 32
                    implicitHeight: 32

                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 18 }
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
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: 20
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                    border.color: Theme.textMain
                    border.width: 1

                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: (player && player.isPlaying) ? 0 : 1.5
                        text: (player && player.isPlaying) ? "󰏤" : "󰐊"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 20 }
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
                    implicitWidth: 32
                    implicitHeight: 32

                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 18 }
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
}
