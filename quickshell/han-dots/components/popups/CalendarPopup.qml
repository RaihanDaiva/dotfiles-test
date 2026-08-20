import "../../theme"
import "../../widgets"
import "../../widgets/styledButton"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Io

// 📅 KALENDER POPUP (Berada di components/popups/ & Inherit BasePopup dari widgets/)
BasePopup {
    id: popupRoot

    property var clockRootItem: null
    // 📅 STATE KALENDER
    property date currentDate: new Date()
    property date displayedDate: new Date()
    property string liveTimeString: ""
    property string liveDateString: ""
    property string uptimeString: "0j 0m"

    // 🧮 HELPER LOGIKA KALENDER
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
        // Hari dari bulan sebelumnya
        for (var i = firstDayIndex - 1; i >= 0; i--) {
            cells.push({
                "day": daysInPrev - i,
                "isCurrentMonth": false,
                "isToday": false
            });
        }
        // Hari bulan berjalan
        var today = currentDate;
        for (var d = 1; d <= daysInCurrent; d++) {
            var isToday = (d === today.getDate() && month === today.getMonth() && year === today.getFullYear());
            cells.push({
                "day": d,
                "isCurrentMonth": true,
                "isToday": isToday
            });
        }
        // Hari bulan berikutnya
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

    targetItem: clockRootItem
    // 📐 UKURAN POPUP LEBIH BESAR & SEIMBANG (380x450 px)
    implicitWidth: 380
    implicitHeight: 485
    onIsOpenChanged: {
        if (isOpen) {
            currentDate = new Date();
            displayedDate = new Date();
            updatePosition();
        }
    }

    // ⏱️ TIMER PEMBARUAN WAKTU & UPTIME REAL-TIME
    Timer {
        id: clockTicker

        interval: 1000
        running: popupRoot.isOpen
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            var now = new Date();
            popupRoot.currentDate = now;
            popupRoot.liveTimeString = Qt.formatDateTime(now, "hh : mm : ss");
            popupRoot.liveDateString = Qt.formatDateTime(now, "dddd, dd MMMM yyyy");
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
                    popupRoot.uptimeString = hours + "j " + mins + "m";
                }
            }
        }

    }

    // 📦 KONTEN UTAMA KALENDER
    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        // 🕒 1. HEADER JAM & TANGGAL LENGKAP
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: popupRoot.liveTimeString !== "" ? popupRoot.liveTimeString : Qt.formatDateTime(popupRoot.currentDate, "hh : mm : ss")
                color: Theme.textMain
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true

                font {
                    family: Theme.fontMain
                    pixelSize: 26
                    bold: true
                }

            }

            Text {
                text: popupRoot.liveDateString !== "" ? popupRoot.liveDateString : Qt.formatDateTime(popupRoot.currentDate, "dddd, dd MMMM yyyy")
                color: Theme.accent
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true

                font {
                    family: Theme.fontMain
                    pixelSize: 14
                }

            }

        }

        // ➖ GARIS PEMISAH
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
        }

        // 📅 2. NAVIGASI BULAN & TAHUN
        RowLayout {
            Layout.fillWidth: true

            // Tombol Bulan Lalu (<)
            Item {
                implicitWidth: 32
                implicitHeight: 32

                Text {
                    anchors.centerIn: parent
                    text: "󰅁"
                    color: Theme.textMain

                    font {
                        family: Theme.fontMono
                        pixelSize: 18
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var d = new Date(popupRoot.displayedDate);
                        d.setMonth(d.getMonth() - 1);
                        popupRoot.displayedDate = d;
                    }
                }

            }

            Item {
                Layout.fillWidth: true
            }

            // Judul Bulan & Tahun (misal: "Agustus 2026")
            Text {
                text: Qt.formatDateTime(popupRoot.displayedDate, "MMMM yyyy")
                color: Theme.textMain

                font {
                    family: Theme.fontMain
                    pixelSize: 16
                    bold: true
                }

            }

            Item {
                Layout.fillWidth: true
            }

            // Tombol Hari Ini (Reset ke Bulan Sekarang)
            Item {
                implicitWidth: 32
                implicitHeight: 32

                Text {
                    anchors.centerIn: parent
                    text: "󰃭"
                    color: Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 17
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popupRoot.displayedDate = new Date();
                    }
                }

            }

            // Tombol Bulan Depan (>)
            Item {
                implicitWidth: 32
                implicitHeight: 32

                Text {
                    anchors.centerIn: parent
                    text: "󰅂"
                    color: Theme.textMain

                    font {
                        family: Theme.fontMono
                        pixelSize: 18
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        var d = new Date(popupRoot.displayedDate);
                        d.setMonth(d.getMonth() + 1);
                        popupRoot.displayedDate = d;
                    }
                }

            }

        }

        // 📆 3. NAMA HARI BAHASA INGGRIS & PRESISI SEJAJAR (Sun, Mon, Tue, Wed, Thu, Fri, Sat)
        GridLayout {
            Layout.fillWidth: true
            columns: 7
            columnSpacing: 5

            Repeater {
                model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                Item {
                    Layout.fillWidth: true
                    implicitHeight: 24

                    Text {
                        anchors.centerIn: parent
                        text: modelData
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 13
                            bold: true
                        }

                    }

                }

            }

        }

        // 🔢 4. GRID TANGGAL KALENDER (7x6 Grid)
        GridLayout {
            id: calendarGrid

            Layout.fillWidth: true
            columns: 7
            rowSpacing: 5
            columnSpacing: 5

            Repeater {
                model: popupRoot.generateCalendarGrid()

                StyledButton {
                    Layout.fillWidth: true
                    implicitHeight: 34
                    radius: 10
                    text: modelData.day
                    selected: modelData.isToday
                    opacity: modelData.isCurrentMonth ? 1 : 0.35
                }

            }

        }

        Item {
            Layout.fillHeight: true
        }

        // ➖ GARIS PEMISAH FOOTER
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
        }

        // 󰅐 5. FOOTER SYSTEM UPTIME
        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 8

            Text {
                text: "󰅐"
                color: Theme.accent

                font {
                    family: Theme.fontMono
                    pixelSize: 16
                }

            }

            Text {
                text: "System Uptime: " + popupRoot.uptimeString
                color: Theme.accent

                font {
                    family: Theme.fontMain
                    pixelSize: 13
                }

            }

        }

    }

}
