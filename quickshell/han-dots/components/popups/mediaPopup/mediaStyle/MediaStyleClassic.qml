import "../../../../theme"
import "../../../../widgets"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

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
        if (!sec || isNaN(sec) || sec <= 0)
            return "0:00";

        if (sec > 100000)
            sec = Math.floor(sec / 1e+06);

        var m = Math.floor(sec / 60);
        var s = Math.floor(sec % 60);
        return m + ":" + (s < 10 ? "0" : "") + s;
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
                visible: popupCover.status !== Image.Ready

                font {
                    family: Theme.fontMono
                    pixelSize: 56
                }

            }

        }

        // 📝 2. JUDUL LAGU & NAMA ARTIS (SCALED UP)
        ColumnLayout {
            spacing: 3
            Layout.fillWidth: true

            Text {
                text: (classicRoot.player && classicRoot.player.trackTitle) ? classicRoot.player.trackTitle : "No Media"
                color: Theme.textMain
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true

                font {
                    family: Theme.fontMain
                    pixelSize: 17
                    bold: true
                }

            }

            Text {
                text: classicRoot.artistName
                color: Theme.accent
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true

                font {
                    family: Theme.fontMain
                    pixelSize: 13
                }

            }

        }

        // 🎵 3. PROGRESS BAR INTERAKTIF (Klik / Drag untuk Seek)
        ColumnLayout {
            spacing: 5
            Layout.fillWidth: true

            // 🎚️ TRACK PROGRESS BAR
            CustomSlider {
                Layout.fillWidth: true
                from: 0
                to: (classicRoot.player && classicRoot.player.length > 0) ? classicRoot.player.length : 1
                value: classicRoot.displayPosition
                enabled: classicRoot.player && classicRoot.player.canSeek && classicRoot.player.length > 0
                onPressedChanged: {
                    if (pressed) {
                        classicRoot.seekStarted(value);
                    } else {
                        classicRoot.seekRequested(value);
                        classicRoot.seekEnded();
                    }
                }
                onMoved: {
                    if (pressed)
                        classicRoot.seekPosition = value;

                }
            }

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: classicRoot.player ? classicRoot.formatTime(classicRoot.displayPosition) : "0:00"
                    color: Theme.accent

                    font {
                        family: Theme.fontMain
                        pixelSize: 12
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }

                    }

                }

                Item {
                    Layout.fillWidth: true
                }

                Text {
                    text: classicRoot.player ? classicRoot.formatTime(classicRoot.player.length) : "0:00"
                    color: Theme.accent

                    font {
                        family: Theme.fontMain
                        pixelSize: 12
                    }

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

                    font {
                        family: Theme.fontMono
                        pixelSize: 22
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (classicRoot.player && typeof classicRoot.player.previous === "function") {
                            classicRoot.player.previous();
                        }
                    }
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

                    font {
                        family: Theme.fontMono
                        pixelSize: 24
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (classicRoot.player) {
                            if (typeof classicRoot.player.playPause === "function")
                                classicRoot.player.playPause();
                            else if (typeof classicRoot.player.togglePlaying === "function")
                                classicRoot.player.togglePlaying();
                            else
                                classicRoot.player.isPlaying = !classicRoot.player.isPlaying;
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

                    font {
                        family: Theme.fontMono
                        pixelSize: 22
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 200
                            easing.type: Easing.InOutQuad
                        }

                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (classicRoot.player && typeof classicRoot.player.next === "function") {
                            classicRoot.player.next();
                        }
                    }
                }

            }

        }

    }

}
