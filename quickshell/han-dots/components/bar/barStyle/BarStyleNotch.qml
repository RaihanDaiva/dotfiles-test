import "../../../services"
import "../../../theme"
import "../../../widgets/bar"
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.Mpris
import Quickshell.Wayland

// 🏛️ BAR STYLE 3: DYNAMIC MACBOOK NOTCH
// Menghadirkan siluet fisik notch MacBook yang autentik (dengan lengkungan
// cekung / concave ears di sudut kiri & kanan atas yang menyatu ke bezel layar),
// sayap kiri (Workspace), dan sayap kanan (System Stats, Battery & Controls).
Scope {
    id: notchRoot

    property var screen
    property bool notchVisible: true
    property bool isExpanded: false
    property bool isPinned: false
    property var currentDate: new Date()
    // 🎵 MPRIS MEDIA PLAYER RESOLVER
    readonly property var activePlayer: {
        var players = Mpris.players.values;
        if (!players || players.length === 0)
            return null;

        for (var i = 0; i < players.length; i++) {
            if (players[i] && players[i].isPlaying)
                return players[i];

        }
        for (var j = 0; j < players.length; j++) {
            if (players[j] && players[j].trackTitle)
                return players[j];

        }
        return players[0];
    }

    function getArtistName(p) {
        if (!p)
            return "No Artist";

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
        return "Unknown Artist";
    }

    // 📅 HELPER MEMBUAT DAFTAR HARI DI SEKITAR HARI INI
    function getDayList() {
        var list = [];
        var now = notchRoot.currentDate;
        for (var i = -2; i <= 2; i++) {
            var target = new Date(now.getFullYear(), now.getMonth(), now.getDate() + i);
            list.push({
                "dayNum": (target.getDate() < 10 ? "0" : "") + target.getDate(),
                "dayName": Qt.formatDateTime(target, "ddd"),
                "isToday": (i === 0)
            });
        }
        return list;
    }

    // ⏱️ TIMER PEMBARUAN WAKTU & TANGGAL
    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: notchRoot.currentDate = new Date()
    }

    // ⏱️ DELAY COLLAPSE TIMER (Mencegah notch tertutup mendadak jika kursor meleset sedikit)
    Timer {
        id: collapseTimer

        interval: 350
        onTriggered: {
            if (!notchRoot.isPinned)
                notchRoot.isExpanded = false;

        }
    }

    // ─────────────────────────────────────────────────────────────────────────
    // 🔲 INVISIBLE TOP SPACER (Menjaga exclusive zone agar jendela tidak tertutup bar)
    // ─────────────────────────────────────────────────────────────────────────
    PanelWindow {
        screen: notchRoot.screen
        visible: notchRoot.notchVisible
        WlrLayershell.namespace: "quickshell:notch-spacer"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Auto
        anchors.top: true
        anchors.left: true
        anchors.right: true
        height: 40
        color: "transparent"

        mask: Region {
        }

    }

    // ─────────────────────────────────────────────────────────────────────────
    // 📍 1. ISLAND KIRI — Workspace
    // ─────────────────────────────────────────────────────────────────────────
    // PanelWindow {
    //     id: leftBarWindow

    //     screen: notchRoot.screen
    //     visible: notchRoot.notchVisible
    //     WlrLayershell.namespace: "quickshell:bar-left"
    //     WlrLayershell.layer: WlrLayer.Top
    //     exclusionMode: ExclusionMode.Ignore
    //     anchors.top: true
    //     anchors.left: true
    //     margins.top: 6
    //     margins.left: 15
    //     width: leftRow.implicitWidth + 20
    //     height: 38
    //     implicitWidth: leftRow.implicitWidth + 20
    //     implicitHeight: 38
    //     color: "transparent"

    //     Rectangle {
    //         id: leftCard

    //         anchors.fill: parent
    //         implicitWidth: leftRow.implicitWidth + 20
    //         radius: 19
    //         color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.barOpacity)
    //         border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
    //         border.width: 1

    //         RowLayout {
    //             id: leftRow

    //             anchors.centerIn: parent
    //             spacing: 10

    //             Workspace {
    //                 barWindow: leftBarWindow
    //             }

    //         }

    //         Behavior on color {
    //             ColorAnimation {
    //                 duration: 200
    //             }

    //         }

    //     }

    //     mask: Region {
    //         item: leftCard
    //     }

    // }

    // ─────────────────────────────────────────────────────────────────────────
    // 📍 2. ISLAND KANAN — Controls, Stats, Battery & Power
    // ─────────────────────────────────────────────────────────────────────────
    // PanelWindow {
    //     id: rightBarWindow

    //     screen: notchRoot.screen
    //     visible: notchRoot.notchVisible
    //     WlrLayershell.namespace: "quickshell:bar-right"
    //     WlrLayershell.layer: WlrLayer.Top
    //     exclusionMode: ExclusionMode.Ignore
    //     anchors.top: true
    //     anchors.right: true
    //     margins.top: 6
    //     margins.right: 15
    //     width: rightRow.implicitWidth + 20
    //     height: 38
    //     implicitWidth: rightRow.implicitWidth + 20
    //     implicitHeight: 38
    //     color: "transparent"

    //     Rectangle {
    //         id: rightCard

    //         anchors.fill: parent
    //         implicitWidth: rightRow.implicitWidth + 20
    //         radius: 19
    //         color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.barOpacity)
    //         border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
    //         border.width: 1

    //         RowLayout {
    //             id: rightRow

    //             anchors.centerIn: parent
    //             spacing: 8

    //             DeviceBattery {
    //             }

    //             SystemStats {
    //                 barWindow: rightBarWindow
    //             }

    //             ControlCenter {
    //                 barWindow: rightBarWindow
    //             }

    //             NotificationPill {
    //                 barWindow: rightBarWindow
    //             }

    //             Power {
    //                 barWindow: rightBarWindow
    //             }

    //         }

    //         Behavior on color {
    //             ColorAnimation {
    //                 duration: 200
    //             }

    //         }

    //     }

    //     mask: Region {
    //         item: rightCard
    //     }

    // }

    // ─────────────────────────────────────────────────────────────────────────
    // 📍 3. DYNAMIC MACBOOK NOTCH (Tengah Atas Layar)
    // ─────────────────────────────────────────────────────────────────────────
    PanelWindow {
        id: notchWindow

        screen: notchRoot.screen
        visible: notchRoot.notchVisible
        WlrLayershell.namespace: "quickshell:notch"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        margins.top: 0
        width: 640
        height: 165
        color: "transparent"

        // 📦 THE NOTCH CONTAINER
        Item {
            id: notchContainer

            property real notchBodyWidth: notchRoot.isExpanded ? 580 : ((notchRoot.activePlayer && notchRoot.activePlayer.isPlaying) ? 230 : 160)
            property real notchBodyHeight: notchRoot.isExpanded ? 142 : 32
            readonly property real rTop: 10
            property real rBottom: notchRoot.isExpanded ? 20 : 14
            readonly property real totalW: notchBodyWidth + 2 * rTop

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: totalW
            height: notchBodyHeight

            // 🖤 SILUET MACBOOK NOTCH DENGAN LENGKUNGAN CEKUNG (EARS/WINGS) DI ATAS
            Shape {
                id: notchShape

                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4
                antialiasing: true

                ShapePath {
                    id: notchPath

                    strokeColor: notchRoot.isExpanded ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                    strokeWidth: 1
                    fillColor: Qt.rgba(0.04, 0.05, 0.08, 0.96)
                    joinStyle: ShapePath.RoundJoin
                    capStyle: ShapePath.RoundCap
                    startX: 0
                    startY: 0

                    // 1. Lengkungan cekung atas-kiri (Concave Ear/Fillet)
                    PathArc {
                        x: notchContainer.rTop
                        y: notchContainer.rTop
                        radiusX: notchContainer.rTop
                        radiusY: notchContainer.rTop
                        direction: PathArc.Clockwise
                    }

                    // 2. Dinding tegak sisi kiri
                    PathLine {
                        x: notchContainer.rTop
                        y: notchContainer.notchBodyHeight - notchContainer.rBottom
                    }

                    // 3. Sudut membulat cembung bawah-kiri
                    PathArc {
                        x: notchContainer.rTop + notchContainer.rBottom
                        y: notchContainer.notchBodyHeight
                        radiusX: notchContainer.rBottom
                        radiusY: notchContainer.rBottom
                        direction: PathArc.Counterclockwise
                    }

                    // 4. Garis horizontal bawah notch
                    PathLine {
                        x: notchContainer.totalW - notchContainer.rTop - notchContainer.rBottom
                        y: notchContainer.notchBodyHeight
                    }

                    // 5. Sudut membulat cembung bawah-kanan
                    PathArc {
                        x: notchContainer.totalW - notchContainer.rTop
                        y: notchContainer.notchBodyHeight - notchContainer.rBottom
                        radiusX: notchContainer.rBottom
                        radiusY: notchContainer.rBottom
                        direction: PathArc.Counterclockwise
                    }

                    // 6. Dinding tegak sisi kanan
                    PathLine {
                        x: notchContainer.totalW - notchContainer.rTop
                        y: notchContainer.rTop
                    }

                    // 7. Lengkungan cekung atas-kanan (Concave Ear/Fillet)
                    PathArc {
                        x: notchContainer.totalW
                        y: 0
                        radiusX: notchContainer.rTop
                        radiusY: notchContainer.rTop
                        direction: PathArc.Clockwise
                    }

                    // 8. Menutup kembali ke titik awal di sepanjang tepi atas layar
                    PathLine {
                        x: 0
                        y: 0
                    }

                }

            }

            // 🖱️ MOUSE SENSOR AREA
            MouseArea {
                id: notchHoverArea

                anchors.fill: parent
                hoverEnabled: true
                cursorShape: notchRoot.isExpanded ? Qt.ArrowCursor : Qt.PointingHandCursor
                onEntered: {
                    collapseTimer.stop();
                    notchRoot.isExpanded = true;
                }
                onExited: {
                    if (!notchRoot.isPinned)
                        collapseTimer.restart();

                }
                onClicked: {
                    if (!notchRoot.isExpanded)
                        notchRoot.isExpanded = true;

                }
            }

            // ─────────────────────────────────────────────────────────────────
            // 📦 AREA KONTEN (Di dalam batas badan notch, di antara kedua sayap)
            // ─────────────────────────────────────────────────────────────────
            Item {
                id: notchContentArea

                x: notchContainer.rTop
                y: 0
                width: notchContainer.notchBodyWidth
                height: notchContainer.notchBodyHeight
                clip: true

                // 🌟 1. COLLAPSED NOTCH CONTENT (Tampil saat idle / tidak di-hover)
                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8
                    visible: !notchRoot.isExpanded
                    opacity: notchRoot.isExpanded ? 0 : 1

                    // Mini animated music note jika sedang memutar musik
                    Text {
                        visible: notchRoot.activePlayer && notchRoot.activePlayer.isPlaying
                        text: "󰎈"
                        color: Theme.accent
                        font.pixelSize: 12
                        font.family: Theme.fontMono
                    }

                    // Cuplikan judul lagu jika sedang memutar musik
                    Text {
                        visible: notchRoot.activePlayer && notchRoot.activePlayer.isPlaying
                        text: notchRoot.activePlayer ? (notchRoot.activePlayer.trackTitle || "") : ""
                        color: Theme.textMain
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontMain
                        elide: Text.ElideRight
                        Layout.maximumWidth: 100
                    }

                    // 📷 Kamera Dot Estetika MacBook Notch
                    Rectangle {
                        width: 7
                        height: 7
                        radius: 3.5
                        color: (notchRoot.activePlayer && notchRoot.activePlayer.isPlaying) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Qt.rgba(1, 1, 1, 0.25)
                        border.color: Qt.rgba(0, 0, 0, 0.8)
                        border.width: 1
                    }

                    // Jam Ringkas
                    Text {
                        text: Qt.formatDateTime(notchRoot.currentDate, "hh:mm")
                        color: Theme.textMain
                        font.pixelSize: 11
                        font.bold: true
                        font.family: Theme.fontMain
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

                // 🌟 2. EXPANDED NOTCH CONTENT (Tampil saat di-hover / mengembang)
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 8
                    visible: notchRoot.isExpanded
                    opacity: notchRoot.isExpanded ? 1 : 0

                    // 🏷️ HEADER / TABS ROW
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // Tab Pill 1: "Nook / Media"
                        Rectangle {
                            implicitWidth: tabMediaText.implicitWidth + 14
                            implicitHeight: 20
                            radius: 10
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: "󰎈"
                                    color: Theme.accent
                                    font.pixelSize: 11
                                    font.family: Theme.fontMono
                                }

                                Text {
                                    id: tabMediaText

                                    text: "Nook"
                                    color: Theme.accent
                                    font.bold: true
                                    font.pixelSize: 10
                                    font.family: Theme.fontMain
                                }

                            }

                        }

                        // Tab Pill 2: "Glance / Calendar"
                        Rectangle {
                            implicitWidth: tabGlanceText.implicitWidth + 14
                            implicitHeight: 20
                            radius: 10
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: "󰸗"
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    font.family: Theme.fontMono
                                }

                                Text {
                                    id: tabGlanceText

                                    text: "Calendar"
                                    color: Theme.textMuted
                                    font.pixelSize: 10
                                    font.family: Theme.fontMain
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        // 📌 PIN TOGGLE BUTTON (Menjaga notch tetap terbuka jika diklik)
                        Rectangle {
                            implicitWidth: 22
                            implicitHeight: 20
                            radius: 6
                            color: notchRoot.isPinned ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : (pinHover.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: notchRoot.isPinned ? "󰤱" : "󰐃"
                                color: notchRoot.isPinned ? Theme.accent : Theme.textMuted
                                font.pixelSize: 11
                                font.family: Theme.fontMono
                            }

                            MouseArea {
                                id: pinHover

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notchRoot.isPinned = !notchRoot.isPinned
                            }

                        }

                    }

                    // 📦 MAIN SPLIT ROW: MEDIA PLAYER (KIRI) | SEPARATOR | KALENDER (KANAN)
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 14

                        // ─────────────────────────────────────────────────────
                        // 🎵 SAYAP KIRI: MEDIA PLAYER WIDGET
                        // ─────────────────────────────────────────────────────
                        RowLayout {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 270
                            Layout.fillHeight: true
                            spacing: 12

                            // 🖼️ Album Art Box
                            Rectangle {
                                implicitWidth: 68
                                implicitHeight: 68
                                radius: 12
                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                                border.width: 1
                                clip: true

                                Image {
                                    id: albumImage

                                    anchors.fill: parent
                                    source: (notchRoot.activePlayer && notchRoot.activePlayer.trackArtUrl) ? notchRoot.activePlayer.trackArtUrl : ""
                                    fillMode: Image.PreserveAspectCrop
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰎈"
                                    color: Theme.accent
                                    font.pixelSize: 26
                                    font.family: Theme.fontMono
                                    visible: !albumImage.visible
                                }

                                // Provider Badge di sudut kanan-bawah album
                                Rectangle {
                                    anchors.bottom: parent.bottom
                                    anchors.right: parent.right
                                    anchors.margins: 3
                                    width: 18
                                    height: 18
                                    radius: 9
                                    color: (notchRoot.activePlayer && notchRoot.activePlayer.identity && notchRoot.activePlayer.identity.toLowerCase().indexOf("spotify") !== -1) ? "#1db954" : "#fa2d48"

                                    Text {
                                        anchors.centerIn: parent
                                        text: (notchRoot.activePlayer && notchRoot.activePlayer.identity && notchRoot.activePlayer.identity.toLowerCase().indexOf("spotify") !== -1) ? "" : "󰝚"
                                        color: "#ffffff"
                                        font.pixelSize: 10
                                        font.family: Theme.fontMono
                                    }

                                }

                            }

                            // 🎶 Info Lagu & Kontrol
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 3

                                Text {
                                    Layout.fillWidth: true
                                    text: notchRoot.activePlayer ? (notchRoot.activePlayer.trackTitle || "No Media Playing") : "No Media Playing"
                                    color: Theme.textMain
                                    font.pixelSize: 12
                                    font.bold: true
                                    font.family: Theme.fontMain
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                Text {
                                    Layout.fillWidth: true
                                    text: notchRoot.activePlayer ? notchRoot.getArtistName(notchRoot.activePlayer) : "Play music to display"
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    font.family: Theme.fontMain
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                }

                                // ⏯️ Kontrol Playback (Prev, Play/Pause, Next)
                                RowLayout {
                                    spacing: 10
                                    Layout.topMargin: 4

                                    // Previous Track
                                    Text {
                                        text: "󰒮"
                                        color: Theme.textMain
                                        font.pixelSize: 15
                                        font.family: Theme.fontMono
                                        opacity: prevBtnHover.containsMouse ? 1 : 0.7

                                        MouseArea {
                                            id: prevBtnHover

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (notchRoot.activePlayer && notchRoot.activePlayer.canGoPrevious)
                                                    notchRoot.activePlayer.previous();

                                            }
                                        }

                                    }

                                    // Play / Pause Button
                                    Rectangle {
                                        implicitWidth: 26
                                        implicitHeight: 26
                                        radius: 13
                                        color: Theme.accent

                                        Text {
                                            anchors.centerIn: parent
                                            text: (notchRoot.activePlayer && notchRoot.activePlayer.isPlaying) ? "󰏤" : "󰐊"
                                            color: Theme.bgDark
                                            font.pixelSize: 12
                                            font.family: Theme.fontMono
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (notchRoot.activePlayer)
                                                    notchRoot.activePlayer.playPause();

                                            }
                                        }

                                    }

                                    // Next Track
                                    Text {
                                        text: "󰒭"
                                        color: Theme.textMain
                                        font.pixelSize: 15
                                        font.family: Theme.fontMono
                                        opacity: nextBtnHover.containsMouse ? 1 : 0.7

                                        MouseArea {
                                            id: nextBtnHover

                                            anchors.fill: parent
                                            hoverEnabled: true
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                if (notchRoot.activePlayer && notchRoot.activePlayer.canGoNext)
                                                    notchRoot.activePlayer.next();

                                            }
                                        }

                                    }

                                }

                            }

                        }

                        // ─── VERTICAL SEPARATOR ───
                        Rectangle {
                            implicitWidth: 1
                            Layout.fillHeight: true
                            color: Qt.rgba(1, 1, 1, 0.08)
                        }

                        // ─────────────────────────────────────────────────────
                        // 📅 SAYAP KANAN: KALENDER & DAILY GLANCE
                        // ─────────────────────────────────────────────────────
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.preferredWidth: 270
                            Layout.fillHeight: true
                            spacing: 8

                            // 📆 Month & Horizontal Days Strip
                            RowLayout {
                                spacing: 6

                                // Nama Bulan (misal: "Oct")
                                Text {
                                    text: Qt.formatDateTime(notchRoot.currentDate, "MMM")
                                    color: Theme.textMain
                                    font.pixelSize: 16
                                    font.bold: true
                                    font.family: Theme.fontMain
                                    Layout.rightMargin: 4
                                }

                                // Daftar 5 Hari Berdampingan
                                Repeater {
                                    model: notchRoot.getDayList()

                                    Rectangle {
                                        implicitWidth: modelData.isToday ? 28 : 22
                                        implicitHeight: modelData.isToday ? 34 : 22
                                        radius: modelData.isToday ? 8 : 6
                                        color: modelData.isToday ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)

                                        ColumnLayout {
                                            anchors.centerIn: parent
                                            spacing: 1

                                            // Label Hari (Tue) khusus hari ini
                                            Text {
                                                visible: modelData.isToday
                                                text: modelData.dayName.toUpperCase()
                                                color: Theme.bgDark
                                                font.pixelSize: 8
                                                font.bold: true
                                                font.family: Theme.fontMain
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                            // Angka Tanggal
                                            Text {
                                                text: modelData.dayNum
                                                color: modelData.isToday ? Theme.bgDark : Theme.textMuted
                                                font.pixelSize: modelData.isToday ? 12 : 11
                                                font.bold: modelData.isToday
                                                font.family: Theme.fontMain
                                                Layout.alignment: Qt.AlignHCenter
                                            }

                                        }

                                    }

                                }

                            }

                            // 📝 Agenda / Schedule Reminder
                            RowLayout {
                                spacing: 6
                                Layout.topMargin: 2

                                Text {
                                    text: "󰸗"
                                    color: Theme.accent
                                    font.pixelSize: 13
                                    font.family: Theme.fontMono
                                }

                                Text {
                                    text: "Nothing for today"
                                    color: Theme.textMain
                                    font.pixelSize: 11
                                    font.bold: true
                                    font.family: Theme.fontMain
                                }

                            }

                            // 🕒 Full Date Subtitle
                            Text {
                                text: Qt.formatDateTime(notchRoot.currentDate, "dddd, d MMMM yyyy")
                                color: Theme.textMuted
                                font.pixelSize: 10
                                font.family: Theme.fontMain
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }

                        }

                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                        }

                    }

                }

            }

            Behavior on notchBodyWidth {
                NumberAnimation {
                    duration: 320
                    easing.type: Easing.OutBack
                    easing.overshoot: 1.05
                }

            }

            Behavior on notchBodyHeight {
                NumberAnimation {
                    duration: 280
                    easing.type: Easing.OutCubic
                }

            }

            Behavior on rBottom {
                NumberAnimation {
                    duration: 220
                }

            }

        }

        mask: Region {
            item: notchContainer
        }

    }

}
