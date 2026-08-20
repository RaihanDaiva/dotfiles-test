import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import "../../../widgets"
import "../../../theme"
import "../../../services"
import "./mediaStyle"

// 🎵 MEDIA PLAYER POPUP — Shell Wrapper
// Mengatur window, background blur, dan memuat style via Loader
BasePopup {
    id: popupRoot

    property var mediaRootItem: null
    targetItem: mediaRootItem

    property var player: null
    property string artistName: "Unknown Artist"

    // 🌟 REAL-TIME POSITION TRACKER
    property real currentPosition: 0
    property bool isSeeking: false
    property real seekPosition: 0

    // 📐 UKURAN POPUP PROPORSIONAL (Dinamis mengikuti ukuran asli komponen style yang di-load)
    implicitWidth: (styleLoader.item && styleLoader.item.implicitWidth > 0) ? styleLoader.item.implicitWidth + 32 : ((SettingsStore.mediaPlayerStyle === "minimalist") ? 370 : 310)
    implicitHeight: (styleLoader.item && styleLoader.item.implicitHeight > 0) ? styleLoader.item.implicitHeight + 32 : ((SettingsStore.mediaPlayerStyle === "minimalist") ? 155 : 485)

    onImplicitWidthChanged: updatePosition()

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

    // 🌫️ FROSTED BLURRED ALBUM ART BACKGROUND (MATCHING LOCKSCREEN STYLE)
    Item {
        anchors.fill: parent
        anchors.margins: -16
        z: -1
        visible: SettingsStore.mediaBlurBgEnabled && popupBlurCover.status === Image.Ready

        layer.enabled: true
        layer.effect: OpacityMask {
            maskSource: Rectangle {
                width: popupRoot.implicitWidth
                height: popupRoot.implicitHeight
                radius: SettingsStore.popupRadius
            }
        }

        // Blurred Album Cover Image
        Image {
            id: popupBlurCover
            anchors.fill: parent
            source: (popupRoot.player && popupRoot.player.trackArtUrl) ? popupRoot.player.trackArtUrl : ""
            fillMode: Image.PreserveAspectCrop 
            smooth: true
            mipmap: true
            sourceSize: Qt.size(300, 300)

            layer.enabled: true
            layer.effect: FastBlur {
                radius: 40
            }
        }   

        // Overlay for Contrast & Legibility (Aktif hanya saat album art blur diaktifkan)
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.68)
        }
    }

    // 🔄 DYNAMIC STYLE LOADER — Ganti file QML secara otomatis sesuai SettingsStore.mediaPlayerStyle
    Loader {
        id: styleLoader
        anchors.fill: parent
        source: (SettingsStore.mediaPlayerStyle === "minimalist") ? Qt.resolvedUrl("./mediaStyle/MediaStyleMinimalist.qml") : Qt.resolvedUrl("./mediaStyle/MediaStyleClassic.qml")

        onLoaded: {
            if (item) {
                item.player = Qt.binding(function() { return popupRoot.player })
                item.artistName = Qt.binding(function() { return popupRoot.artistName })
                item.currentPosition = Qt.binding(function() { return popupRoot.currentPosition })
                item.isSeeking = Qt.binding(function() { return popupRoot.isSeeking })
                item.seekPosition = Qt.binding(function() { return popupRoot.seekPosition })

                item.seekStarted.connect(function(pos) {
                    popupRoot.isSeeking = true
                    popupRoot.seekPosition = pos
                })
                item.seekRequested.connect(function(targetMicros) {
                    if (!popupRoot.player || !popupRoot.player.canSeek) return
                    var offsetMicros = targetMicros - popupRoot.player.position
                    popupRoot.player.seek(offsetMicros)
                    popupRoot.currentPosition = targetMicros
                })
                item.seekEnded.connect(function() {
                    popupRoot.isSeeking = false
                })
            }
        }
    }
}
