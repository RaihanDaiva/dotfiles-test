import "../../../services"
import "../../../theme"
import "../../../widgets/bar"
import "../../popups/calendarPopup/calendarStyle"
import "../../popups/mediaPopup/mediaStyle"
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import Quickshell
import Quickshell.Io
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
    readonly property real currentScreenWidth: (notchRoot.screen && notchRoot.screen.width > 0) ? notchRoot.screen.width : 1920
    readonly property real currentScreenHeight: (notchRoot.screen && notchRoot.screen.height > 0) ? notchRoot.screen.height : 1080
    // 🎵 MPRIS REAL-TIME TRACKER & TAB FOCUS
    property string activeTab: "media"
    readonly property int currentTabIndex: {
        if (notchRoot.activeTab === "about")
            return 0;

        if (notchRoot.activeTab === "calendar")
            return 2;

        return 1;
    }
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
    // 📅 STATE KALENDER POPUP
    property date displayedDate: new Date()
    property string liveTimeString: ""
    property string liveDateString: ""
    property string uptimeString: "0j 0m"
    property var calendarGridCells: []

    function handleSeek(targetMicros) {
        if (!notchRoot.activePlayer)
            return ;

        if (notchRoot.activePlayer.canSeek === false)
            return ;

        if (typeof notchRoot.activePlayer.seek === "function") {
            var currentPos = (notchRoot.activePlayer.position !== undefined && notchRoot.activePlayer.position > 0) ? notchRoot.activePlayer.position : notchRoot.currentPosition;
            var offsetMicros = targetMicros - currentPos;
            notchRoot.activePlayer.seek(offsetMicros);
            notchRoot.currentPosition = targetMicros;
        } else if (typeof notchRoot.activePlayer.setPosition === "function") {
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

    function getDaysInMonth(year, month) {
        return new Date(year, month + 1, 0).getDate();
    }

    function getFirstDayOfWeek(year, month) {
        return new Date(year, month, 1).getDay();
    }

    function generateCalendarGrid() {
        var year = displayedDate.getFullYear();
        var month = displayedDate.getMonth();
        var daysInCurrent = getDaysInMonth(year, month);
        var firstDayIndex = getFirstDayOfWeek(year, month);
        var daysInPrev = getDaysInMonth(year, month - 1);
        var cells = [];
        for (var i = firstDayIndex - 1; i >= 0; i--) {
            cells.push({
                "day": daysInPrev - i,
                "isCurrentMonth": false,
                "isToday": false
            });
        }
        var today = currentDate;
        for (var d = 1; d <= daysInCurrent; d++) {
            var isToday = (d === today.getDate() && month === today.getMonth() && year === today.getFullYear());
            cells.push({
                "day": d,
                "isCurrentMonth": true,
                "isToday": isToday
            });
        }
        var nextDays = 42 - cells.length;
        for (var n = 1; n <= nextDays; n++) {
            cells.push({
                "day": n,
                "isCurrentMonth": false,
                "isToday": false
            });
        }
        return cells;
    }

    function updateCells() {
        calendarGridCells = generateCalendarGrid();
    }

    onDisplayedDateChanged: updateCells()
    onCurrentDateChanged: updateCells()
    onActiveTabChanged: {
        if (activeTab === "calendar") {
            displayedDate = new Date();
            updateCells();
            uptimeProc.running = true;
        }
    }
    onIsExpandedChanged: {
        if (isExpanded) {
            currentDate = new Date();
            displayedDate = new Date();
            updateCells();
            if (activeTab === "calendar")
                uptimeProc.running = true;

        }
    }
    Component.onCompleted: {
        updateCells();
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
            screenWidth: notchRoot.currentScreenWidth
            screenHeight: notchRoot.currentScreenHeight
            rTop: 8
            rBottom: 12
            implicitWidth: leftRow.implicitWidth + 24 + rTop
            implicitHeight: notchRoot.notchBarHeight

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
            screenWidth: notchRoot.currentScreenWidth
            screenHeight: notchRoot.currentScreenHeight
            rTop: 8
            rBottom: 12
            implicitWidth: rightRow.implicitWidth + 24 + rTop
            implicitHeight: notchRoot.notchBarHeight

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

    // ⏱️ TIMER PEMBARUAN WAKTU, TANGGAL & UPTIME
    Timer {
        id: clockTicker

        interval: 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            notchRoot.currentDate = now;
            notchRoot.liveTimeString = Qt.formatDateTime(now, "hh : mm : ss");
            notchRoot.liveDateString = Qt.formatDateTime(now, "dddd, dd MMMM yyyy");
            if (notchRoot.isExpanded && notchRoot.activeTab === "calendar")
                uptimeProc.running = true;

        }
    }

    // 🐚 PROCESS PEMBACA UPTIME SISTEM
    Process {
        id: uptimeProc

        command: ["bash", "-c", "cut -d' ' -f1 /proc/uptime"]

        stdout: SplitParser {
            onRead: (data) => {
                var sec = parseFloat(data.trim());
                if (!isNaN(sec)) {
                    var hours = Math.floor(sec / 3600);
                    var mins = Math.floor((sec % 3600) / 60);
                    notchRoot.uptimeString = hours + "j " + mins + "m";
                }
            }
        }

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
        height: 580
        color: "transparent"

        // 📦 THE NOTCH CONTAINER
        Item {
            id: notchContainer

            property real notchBodyWidth: {
                if (!notchRoot.isExpanded)
                    return (notchRoot.activePlayer && (notchRoot.activePlayer.isPlaying || (notchRoot.activePlayer.trackTitle && notchRoot.activePlayer.trackTitle !== ""))) ? 240 : 160;

                return 380;
            }
            property real notchBodyHeight: {
                if (!notchRoot.isExpanded)
                    return notchRoot.notchBarHeight;

                if (notchRoot.activeTab === "calendar")
                    return 525;

                if (notchRoot.activeTab === "about")
                    return 165;

                return 204;
            }
            readonly property real rTop: 8
            property real rBottom: notchRoot.isExpanded ? 18 : 12
            readonly property real totalW: notchBodyWidth + 2 * rTop
            property color notchBorderColor: notchRoot.isExpanded ? Theme.accent : (SettingsStore.barBgEnabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 1) : "transparent")

            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            width: totalW
            height: notchBodyHeight

            // 🖤 SILUET MACBOOK NOTCH DENGAN REUSABLE NOTCHSHAPE
            NotchShape {
                id: notchShape

                anchors.fill: parent
                side: "center"
                screenWidth: notchRoot.currentScreenWidth
                screenHeight: notchRoot.currentScreenHeight
                rTop: notchContainer.rTop
                rBottom: notchContainer.rBottom
                strokeColor: notchContainer.notchBorderColor
                strokeWidth: notchRoot.isExpanded ? 1.5 : (SettingsStore.barBgEnabled ? 1 : 0)
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
                enabled: !notchRoot.isExpanded
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onEntered: {
                    collapseTimer.stop();
                    notchRoot.isExpanded = true;
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
                    // Mini animated music note jika sedang memutar musik
                    // Text {
                    //     visible: notchRoot.activePlayer && notchRoot.activePlayer.isPlaying
                    //     text: "󰎈"
                    //     color: Theme.accent
                    //     font.pixelSize: 12
                    //     font.family: Theme.fontMono
                    // }
                    // // Cuplikan judul lagu jika sedang memutar musik
                    // Text {
                    //     visible: notchRoot.activePlayer && notchRoot.activePlayer.isPlaying
                    //     text: notchRoot.activePlayer ? (notchRoot.activePlayer.trackTitle || "") : ""
                    //     color: Theme.textMain
                    //     font.pixelSize: 11
                    //     font.bold: true
                    //     font.family: Theme.fontMain
                    //     elide: Text.ElideRight
                    //     Layout.maximumWidth: 100
                    // }

                    anchors.centerIn: parent
                    spacing: 8
                    visible: !notchRoot.isExpanded
                    opacity: notchRoot.isExpanded ? 0 : 1

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

                    // 🏷️ HEADER / TABS CAROUSEL ROW (Pill-less, Animated Size & Opacity)
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 26

                        // 🎯 TABS ROW (100% Presisi di Tengah Layar Notch)
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 14

                            // Tab 1: "About"
                            Item {
                                implicitWidth: tabAboutRow.implicitWidth
                                implicitHeight: 24

                                RowLayout {
                                    id: tabAboutRow

                                    anchors.centerIn: parent
                                    spacing: 5
                                    scale: notchRoot.activeTab === "about" ? 1 : 0.74
                                    transformOrigin: Item.Center
                                    opacity: notchRoot.activeTab === "about" ? 1 : (aboutHover.containsMouse ? 0.75 : 0.45)

                                    Text {
                                        text: "󰋜"
                                        color: Theme.accent
                                        font.pixelSize: 19
                                        font.family: Theme.fontMono
                                    }

                                    Text {
                                        text: "About"
                                        color: Theme.textMain
                                        font.bold: notchRoot.activeTab === "about"
                                        font.pixelSize: 18
                                        font.family: Theme.fontMain
                                    }

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                }

                                MouseArea {
                                    id: aboutHover

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notchRoot.activeTab = "about"
                                }

                            }

                            // Tab 2: "Media"
                            Item {
                                implicitWidth: tabMediaRow.implicitWidth
                                implicitHeight: 24

                                RowLayout {
                                    id: tabMediaRow

                                    anchors.centerIn: parent
                                    spacing: 5
                                    scale: notchRoot.activeTab === "media" ? 1 : 0.74
                                    transformOrigin: Item.Center
                                    opacity: notchRoot.activeTab === "media" ? 1 : (mediaHover.containsMouse ? 0.75 : 0.45)

                                    Text {
                                        text: "󰎈"
                                        color: Theme.accent
                                        font.pixelSize: 19
                                        font.family: Theme.fontMono
                                    }

                                    Text {
                                        text: "Media"
                                        color: Theme.textMain
                                        font.bold: notchRoot.activeTab === "media"
                                        font.pixelSize: 18
                                        font.family: Theme.fontMain
                                    }

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                }

                                MouseArea {
                                    id: mediaHover

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notchRoot.activeTab = "media"
                                }

                            }

                            // Tab 3: "Calendar"
                            Item {
                                implicitWidth: tabCalRow.implicitWidth
                                implicitHeight: 24

                                RowLayout {
                                    id: tabCalRow

                                    anchors.centerIn: parent
                                    spacing: 5
                                    scale: notchRoot.activeTab === "calendar" ? 1 : 0.74
                                    transformOrigin: Item.Center
                                    opacity: notchRoot.activeTab === "calendar" ? 1 : (calHover.containsMouse ? 0.75 : 0.45)

                                    Text {
                                        text: "󰸗"
                                        color: Theme.accent
                                        font.pixelSize: 19
                                        font.family: Theme.fontMono
                                    }

                                    Text {
                                        text: "Calendar"
                                        color: Theme.textMain
                                        font.bold: notchRoot.activeTab === "calendar"
                                        font.pixelSize: 18
                                        font.family: Theme.fontMain
                                    }

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                    Behavior on opacity {
                                        NumberAnimation {
                                            duration: 250
                                            easing.type: Easing.OutCubic
                                        }

                                    }

                                }

                                MouseArea {
                                    id: calHover

                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notchRoot.activeTab = "calendar"
                                }

                            }

                        }

                        // 📌 PIN TOGGLE BUTTON (Menempel Rapi di Ujung Kanan)
                        Rectangle {
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            implicitWidth: 22
                            implicitHeight: 22
                            radius: 6
                            color: notchRoot.isPinned ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : (pinHover.containsMouse ? Qt.rgba(1, 1, 1, 0.1) : "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: notchRoot.isPinned ? "󰤱" : "󰐃"
                                color: notchRoot.isPinned ? Theme.accent : Theme.secondary
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

                    // 🎠 CONTENT VIEWPORT (LOGIKA PERSIS QUICKSETTINGSPOPUP: DIRECT X & OPACITY SLIDE)
                    Item {
                        id: bodyContainer

                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true

                        // ─── 1. VIEW ABOUT (Index 0) ─────────────────────────────────
                        Item {
                            id: notchAboutView

                            width: bodyContainer.width
                            height: bodyContainer.height
                            x: (0 - notchRoot.currentTabIndex) * bodyContainer.width
                            opacity: notchRoot.currentTabIndex === 0 ? 1 : 0
                            visible: opacity > 0

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 8

                                Rectangle {
                                    Layout.fillWidth: true
                                    implicitHeight: 46
                                    radius: 10
                                    color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12)
                                    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                                    border.width: 1

                                    RowLayout {
                                        anchors.fill: parent
                                        anchors.margins: 10
                                        spacing: 10

                                        Text {
                                            text: "󰌢"
                                            color: Theme.accent
                                            font.pixelSize: 22
                                            font.family: Theme.fontMono
                                        }

                                        ColumnLayout {
                                            spacing: 2

                                            Text {
                                                text: Quickshell.env("USER") + "@" + (Quickshell.env("HOSTNAME") || "archlinux")
                                                color: Theme.textMain
                                                font.bold: true
                                                font.pixelSize: 13
                                                font.family: Theme.fontMain
                                            }

                                            Text {
                                                text: (Quickshell.env("XDG_CURRENT_DESKTOP") || "Wayland") + " • Dynamic Notch"
                                                color: Theme.secondary
                                                font.pixelSize: 10
                                                font.family: Theme.fontMain
                                            }

                                        }

                                    }

                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 8

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 34
                                        radius: 8
                                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
                                        border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                                        border.width: 1

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 6

                                            Text {
                                                text: "󰣇"
                                                color: Theme.accent
                                                font.pixelSize: 13
                                                font.family: Theme.fontMono
                                            }

                                            Text {
                                                text: "Arch Linux"
                                                color: Theme.textMain
                                                font.pixelSize: 11
                                                font.family: Theme.fontMain
                                            }

                                        }

                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        implicitHeight: 34
                                        radius: 8
                                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05)
                                        border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                                        border.width: 1

                                        RowLayout {
                                            anchors.centerIn: parent
                                            spacing: 6

                                            Text {
                                                text: "󰅂"
                                                color: Theme.accent
                                                font.pixelSize: 13
                                                font.family: Theme.fontMono
                                            }

                                            Text {
                                                text: "han-dots v2"
                                                color: Theme.textMain
                                                font.pixelSize: 11
                                                font.family: Theme.fontMain
                                            }

                                        }

                                    }

                                }

                            }

                            Behavior on x {
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.OutCubic
                                }

                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                        // ─── 2. VIEW MEDIA PLAYER (Index 1) ──────────────────────────
                        Item {
                            id: notchMediaView

                            width: bodyContainer.width
                            height: bodyContainer.height
                            x: (1 - notchRoot.currentTabIndex) * bodyContainer.width
                            opacity: notchRoot.currentTabIndex === 1 ? 1 : 0
                            visible: opacity > 0

                            MediaStyleMinimalist {
                                id: notchMediaPlayer

                                anchors.fill: parent
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
                            }

                            Behavior on x {
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.OutCubic
                                }

                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }

                            }

                        }

                        // ─── 3. VIEW KALENDER POPUP (Index 2) ─────────────────────────
                        Item {
                            id: notchCalendarViewContainer

                            width: bodyContainer.width
                            height: bodyContainer.height
                            x: (2 - notchRoot.currentTabIndex) * bodyContainer.width
                            opacity: notchRoot.currentTabIndex === 2 ? 1 : 0
                            visible: opacity > 0

                            CalendarStyleOriginal {
                                id: notchCalendarView

                                anchors.fill: parent
                                displayedDate: notchRoot.displayedDate
                                liveTimeString: notchRoot.liveTimeString
                                liveDateString: notchRoot.liveDateString
                                uptimeString: notchRoot.uptimeString
                                calendarGridCells: notchRoot.calendarGridCells
                                onPrevMonthClicked: {
                                    var d = new Date(notchRoot.displayedDate);
                                    d.setMonth(d.getMonth() - 1);
                                    notchRoot.displayedDate = d;
                                }
                                onNextMonthClicked: {
                                    var d = new Date(notchRoot.displayedDate);
                                    d.setMonth(d.getMonth() + 1);
                                    notchRoot.displayedDate = d;
                                }
                                onTodayClicked: {
                                    notchRoot.displayedDate = new Date();
                                }
                            }

                            Behavior on x {
                                NumberAnimation {
                                    duration: 250
                                    easing.type: Easing.OutCubic
                                }

                            }

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 200
                                    easing.type: Easing.OutCubic
                                }

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
                    // easing.overshoot: 1.05

                    duration: 280
                    easing.type: Easing.OutCubic
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
