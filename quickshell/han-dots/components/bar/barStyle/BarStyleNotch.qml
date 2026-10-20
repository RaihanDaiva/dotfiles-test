import "../../../services"
import "../../../theme"
import "../../../widgets/bar"
import "../../popups/mediaPopup/mediaStyle"
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
    // 📐 Geometri Notch & Wings (Disinkronkan: tinggi bar 40px, gap ke aplikasi 8px)
    readonly property real notchBarHeight: 40
    readonly property real notchBarGap: 0
    // 🎵 MPRIS REAL-TIME TRACKER & TAB FOCUS
    property string activeTab: "media"
    property real currentPosition: 0
    property bool isSeeking: false
    property real seekPosition: 0
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

    function handleSeek(targetMicros) {
        if (notchRoot.activePlayer && typeof notchRoot.activePlayer.setPosition === "function") {
            notchRoot.activePlayer.setPosition(targetMicros);
            notchRoot.currentPosition = targetMicros;
        }
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

    Timer {
        id: posTicker

        interval: 1000
        running: notchRoot.isExpanded && notchRoot.activePlayer !== null && notchRoot.activePlayer.isPlaying
        repeat: true
        onTriggered: {
            if (notchRoot.activePlayer) {
                var dbusPos = notchRoot.activePlayer.position;
                if (dbusPos !== undefined && dbusPos > 0)
                    notchRoot.currentPosition = dbusPos;
                else
                    notchRoot.currentPosition += 1e+06;
            }
        }
        onRunningChanged: {
            if (running && notchRoot.activePlayer)
                notchRoot.currentPosition = notchRoot.activePlayer.position || 0;

        }
    }
    // 🎵 MPRIS MEDIA PLAYER RESOLVER

    // ─────────────────────────────────────────────────────────────────────────
    // 📍 1. ISLAND KIRI — Workspace (Corner-Flush Notch Wing)
    // ─────────────────────────────────────────────────────────────────────────
    PanelWindow {
        id: leftBarWindow

        screen: notchRoot.screen
        visible: notchRoot.notchVisible
        WlrLayershell.namespace: "quickshell:notch"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        anchors.left: true
        margins.top: 0
        margins.left: 0
        width: leftNotch.implicitWidth
        height: notchRoot.notchBarHeight
        implicitWidth: leftNotch.implicitWidth
        implicitHeight: notchRoot.notchBarHeight
        color: "transparent"

        NotchShape {
            id: leftNotch

            side: "left"
            anchors.fill: parent
            rTop: 8
            rBottom: 12
            implicitWidth: leftRow.implicitWidth + 24 + rTop
            implicitHeight: notchRoot.notchBarHeight
            strokeColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.75)
            strokeWidth: 1.2

            RowLayout {
                id: leftRow

                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10

                Workspace {
                    barWindow: leftBarWindow
                }

            }

        }

        mask: Region {
            item: leftNotch
        }

    }

    // ─────────────────────────────────────────────────────────────────────────
    // 📍 2. ISLAND KANAN — Controls, Stats, Battery & Power (Corner-Flush Notch Wing)
    // ─────────────────────────────────────────────────────────────────────────
    PanelWindow {
        id: rightBarWindow

        screen: notchRoot.screen
        visible: notchRoot.notchVisible
        WlrLayershell.namespace: "quickshell:notch"
        WlrLayershell.layer: WlrLayer.Top
        exclusionMode: ExclusionMode.Ignore
        anchors.top: true
        anchors.right: true
        margins.top: 0
        margins.right: 0
        width: rightNotch.implicitWidth
        height: notchRoot.notchBarHeight
        implicitWidth: rightNotch.implicitWidth
        implicitHeight: notchRoot.notchBarHeight
        color: "transparent"

        NotchShape {
            id: rightNotch

            side: "right"
            anchors.fill: parent
            rTop: 8
            rBottom: 12
            implicitWidth: rightRow.implicitWidth + 24 + rTop
            implicitHeight: notchRoot.notchBarHeight
            strokeColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.75)
            strokeWidth: 1.2

            RowLayout {
                id: rightRow

                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8

                DeviceBattery {
                }

                SystemStats {
                    barWindow: rightBarWindow
                }

                ControlCenter {
                    barWindow: rightBarWindow
                }

                NotificationPill {
                    barWindow: rightBarWindow
                }

                Power {
                    barWindow: rightBarWindow
                }

            }

        }

        mask: Region {
            item: rightNotch
        }

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
        height: notchRoot.notchBarHeight + notchRoot.notchBarGap
        color: "transparent"

        mask: Region {
        }

    }

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
        height: 220
        color: "transparent"

        // 📦 THE NOTCH CONTAINER
        Item {
            id: notchContainer

            property real notchBodyWidth: {
                if (!notchRoot.isExpanded)
                    return (notchRoot.activePlayer && (notchRoot.activePlayer.isPlaying || (notchRoot.activePlayer.trackTitle && notchRoot.activePlayer.trackTitle !== ""))) ? 240 : 160;

                return notchRoot.activeTab === "media" ? 380 : 360;
            }
            property real notchBodyHeight: {
                if (!notchRoot.isExpanded)
                    return notchRoot.notchBarHeight;

                return notchRoot.activeTab === "media" ? 180 : 150;
            }
            readonly property real rTop: 8
            property real rBottom: notchRoot.isExpanded ? 18 : 12
            readonly property real totalW: notchBodyWidth + 2 * rTop
            property color notchBorderColor: notchRoot.isExpanded ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.75)

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: totalW
            height: notchBodyHeight

            // 🖤 SILUET MACBOOK NOTCH DENGAN REUSABLE NOTCHSHAPE
            NotchShape {
                id: notchShape

                anchors.fill: parent
                side: "center"
                rTop: notchContainer.rTop
                rBottom: notchContainer.rBottom
                strokeColor: notchContainer.notchBorderColor
                strokeWidth: notchRoot.isExpanded ? 1.5 : 1.2
            }

            // 🖱️ MOUSE SENSOR AREA
            HoverHandler {
                id: notchHoverHandler

                onHoveredChanged: {
                    if (hovered) {
                        collapseTimer.stop();
                        notchRoot.isExpanded = true;
                    } else {
                        if (!notchRoot.isPinned)
                            collapseTimer.restart();

                    }
                }
            }

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
                    // 📷 Kamera Dot Estetika MacBook Notch
                    // Rectangle {
                    //     width: 7
                    //     height: 7
                    //     radius: 3.5
                    //     color: (notchRoot.activePlayer && notchRoot.activePlayer.isPlaying) ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Qt.rgba(1, 1, 1, 0.25)
                    //     border.color: Qt.rgba(0, 0, 0, 0.8)
                    //     border.width: 1
                    // }

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

                    // Jam Ringkas
                    Text {
                        text: Qt.formatDateTime(notchRoot.currentDate, "hh:mm")
                        color: Theme.textMain
                        font.pixelSize: 18
                        font.bold: true
                        font.family: Theme.fontMain
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

                // 🌟 2. EXPANDED NOTCH CONTENT — DYNAMIC ISLAND FOCUS
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 8
                    visible: notchRoot.isExpanded
                    opacity: notchRoot.isExpanded ? 1 : 0

                    // 🏷️ HEADER / TABS ROW
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        // Tab Pill 1: "Media"
                        Rectangle {
                            implicitWidth: tabMediaRow.implicitWidth + 16
                            implicitHeight: 22
                            radius: 11
                            color: notchRoot.activeTab === "media" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                            border.color: notchRoot.activeTab === "media" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5) : "transparent"
                            border.width: 1

                            RowLayout {
                                id: tabMediaRow

                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    text: "󰎈"
                                    color: notchRoot.activeTab === "media" ? Theme.accent : Theme.textMuted
                                    font.pixelSize: 11
                                    font.family: Theme.fontMono
                                }

                                Text {
                                    text: "Media"
                                    color: notchRoot.activeTab === "media" ? Theme.textMain : Theme.textMuted
                                    font.bold: notchRoot.activeTab === "media"
                                    font.pixelSize: 11
                                    font.family: Theme.fontMain
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notchRoot.activeTab = "media"
                            }

                        }

                        // Tab Pill 2: "Calendar"
                        Rectangle {
                            implicitWidth: tabCalRow.implicitWidth + 16
                            implicitHeight: 22
                            radius: 11
                            color: notchRoot.activeTab === "calendar" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                            border.color: notchRoot.activeTab === "calendar" ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5) : "transparent"
                            border.width: 1

                            RowLayout {
                                id: tabCalRow

                                anchors.centerIn: parent
                                spacing: 5

                                Text {
                                    text: "󰸗"
                                    color: notchRoot.activeTab === "calendar" ? Theme.accent : Theme.textMuted
                                    font.pixelSize: 11
                                    font.family: Theme.fontMono
                                }

                                Text {
                                    text: "Calendar"
                                    color: notchRoot.activeTab === "calendar" ? Theme.textMain : Theme.textMuted
                                    font.bold: notchRoot.activeTab === "calendar"
                                    font.pixelSize: 11
                                    font.family: Theme.fontMain
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notchRoot.activeTab = "calendar"
                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        // 📌 PIN TOGGLE BUTTON (Menjaga notch tetap terbuka)
                        Rectangle {
                            implicitWidth: 24
                            implicitHeight: 22
                            radius: 7
                            color: notchRoot.isPinned ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : (pinHover.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: notchRoot.isPinned ? "󰤱" : "󰐃"
                                color: notchRoot.isPinned ? Theme.accent : Theme.textMuted
                                font.pixelSize: 12
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

                    // 🌟 1. VIEW MEDIA PLAYER (MediaStyleMinimalist Asli dari MediaPopup)
                    MediaStyleMinimalist {
                        id: notchMediaPlayer

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: notchRoot.activeTab === "media"
                        opacity: notchRoot.activeTab === "media" ? 1 : 0
                        player: notchRoot.activePlayer
                        artistName: notchRoot.getArtistName(notchRoot.activePlayer)
                        currentPosition: notchRoot.currentPosition
                        isSeeking: notchRoot.isSeeking
                        seekPosition: notchRoot.seekPosition
                        onSeekRequested: (targetMicros) => {
                            notchRoot.handleSeek(targetMicros);
                        }
                        onSeekStarted: (pos) => {
                            notchRoot.isSeeking = true;
                            notchRoot.seekPosition = pos;
                        }
                        onSeekEnded: () => {
                            notchRoot.isSeeking = false;
                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 180
                            }

                        }

                    }

                    // 🌟 2. VIEW KALENDER & AGENDA (Aktif saat tab Calendar dipilih)
                    ColumnLayout {
                        id: notchCalendarView

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: notchRoot.activeTab === "calendar"
                        opacity: notchRoot.activeTab === "calendar" ? 1 : 0
                        spacing: 10

                        // 📆 Month & Horizontal Days Strip
                        RowLayout {
                            spacing: 8
                            Layout.alignment: Qt.AlignHCenter

                            Text {
                                text: Qt.formatDateTime(notchRoot.currentDate, "MMMM yyyy")
                                color: Theme.textMain
                                font.pixelSize: 15
                                font.bold: true
                                font.family: Theme.fontMain
                                Layout.rightMargin: 6
                            }

                            Repeater {
                                model: notchRoot.getDayList()

                                Rectangle {
                                    implicitWidth: modelData.isToday ? 30 : 24
                                    implicitHeight: modelData.isToday ? 36 : 24
                                    radius: modelData.isToday ? 9 : 6
                                    color: modelData.isToday ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)

                                    ColumnLayout {
                                        anchors.centerIn: parent
                                        spacing: 1

                                        Text {
                                            visible: modelData.isToday
                                            text: modelData.dayName.toUpperCase()
                                            color: Theme.bgDark
                                            font.pixelSize: 8
                                            font.bold: true
                                            font.family: Theme.fontMain
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                        Text {
                                            text: modelData.dayNum
                                            color: modelData.isToday ? Theme.bgDark : Theme.textMuted
                                            font.pixelSize: modelData.isToday ? 13 : 11
                                            font.bold: modelData.isToday
                                            font.family: Theme.fontMain
                                            Layout.alignment: Qt.AlignHCenter
                                        }

                                    }

                                }

                            }

                        }

                        // 📝 Agenda / Schedule Reminder
                        Rectangle {
                            Layout.fillWidth: true
                            Layout.topMargin: 4
                            implicitHeight: 34
                            radius: 10
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
                            border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                            border.width: 1

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: 8

                                Text {
                                    text: "󰸗"
                                    color: Theme.accent
                                    font.pixelSize: 13
                                    font.family: Theme.fontMono
                                }

                                Text {
                                    text: "No upcoming events scheduled"
                                    color: Theme.textMuted
                                    font.pixelSize: 11
                                    font.family: Theme.fontMain
                                }

                            }

                        }

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 180
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

            Behavior on notchBorderColor {
                ColorAnimation {
                    duration: 200
                }

            }

        }

        mask: Region {
            item: notchContainer
        }

    }

}
