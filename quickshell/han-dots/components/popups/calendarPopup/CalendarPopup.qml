import "../../../services"
import "../../../theme"
import "../../../widgets"
import "./calendarStyle"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

// 📅 CALENDAR POPUP (DYNAMIC ORIGINAL VS MACOS STYLE)
BasePopup {
    id: popupRoot

    property var clockRootItem: null
    // 📅 STATE KALENDER
    property date currentDate: new Date()
    property date displayedDate: new Date()
    property string liveTimeString: ""
    property string liveDateString: ""
    property string uptimeString: "0j 0m"
    property var calendarGridCells: []

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

    function updateCells() {
        calendarGridCells = generateCalendarGrid();
    }

    targetItem: clockRootItem
    // 📐 UKURAN POPUP
    implicitWidth: 380
    implicitHeight: (styleLoader.item && styleLoader.item.implicitHeight > 0) ? styleLoader.item.implicitHeight + 28 : 485
    targetCardHeight: implicitHeight
    onDisplayedDateChanged: updateCells()
    onCurrentDateChanged: updateCells()
    onIsOpenChanged: {
        if (isOpen) {
            currentDate = new Date();
            displayedDate = new Date();
            updateCells();
            updatePosition();
        }
    }
    Component.onCompleted: {
        updateCells();
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

    // 🔄 DYNAMIC STYLE LOADER (Original vs macOS)
    Loader {
        id: styleLoader

        anchors.fill: parent
        source: (SettingsStore.popupStyle === "macos") ? Qt.resolvedUrl("./calendarStyle/CalendarStyleMacos.qml") : Qt.resolvedUrl("./calendarStyle/CalendarStyleOriginal.qml")
        onLoaded: {
            if (item) {
                item.displayedDate = Qt.binding(function() {
                    return popupRoot.displayedDate;
                });
                item.liveTimeString = Qt.binding(function() {
                    return popupRoot.liveTimeString;
                });
                item.liveDateString = Qt.binding(function() {
                    return popupRoot.liveDateString;
                });
                item.uptimeString = Qt.binding(function() {
                    return popupRoot.uptimeString;
                });
                item.calendarGridCells = Qt.binding(function() {
                    return popupRoot.calendarGridCells;
                });
                item.prevMonthClicked.connect(function() {
                    var d = new Date(popupRoot.displayedDate);
                    d.setMonth(d.getMonth() - 1);
                    popupRoot.displayedDate = d;
                });
                item.nextMonthClicked.connect(function() {
                    var d = new Date(popupRoot.displayedDate);
                    d.setMonth(d.getMonth() + 1);
                    popupRoot.displayedDate = d;
                });
                item.todayClicked.connect(function() {
                    popupRoot.displayedDate = new Date();
                });
            }
        }
    }

}
