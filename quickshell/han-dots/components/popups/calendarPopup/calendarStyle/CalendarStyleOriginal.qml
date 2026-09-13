import "../../../../theme"
import "../../../../widgets"
import "../../../../widgets/styledButton"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 📅 CALENDAR POPUP STYLE: ORIGINAL (Windows 11 / Catppuccin Card with StyledButton Date Grid)
Item {
    id: styleRoot

    property date displayedDate: new Date()
    property string liveTimeString: ""
    property string liveDateString: ""
    property string uptimeString: "0j 0m"
    property var calendarGridCells: []

    signal prevMonthClicked()
    signal nextMonthClicked()
    signal todayClicked()

    implicitWidth: 380
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        spacing: 14

        // 🕒 1. HEADER JAM & TANGGAL LENGKAP
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            Text {
                text: styleRoot.liveTimeString !== "" ? styleRoot.liveTimeString : Qt.formatDateTime(new Date(), "hh : mm : ss")
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
                text: styleRoot.liveDateString !== "" ? styleRoot.liveDateString : Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
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
                    onClicked: styleRoot.prevMonthClicked()
                }

            }

            Item {
                Layout.fillWidth: true
            }

            // Judul Bulan & Tahun (misal: "September 2026")
            Text {
                text: Qt.formatDateTime(styleRoot.displayedDate, "MMMM yyyy")
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
                    onClicked: styleRoot.todayClicked()
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
                    onClicked: styleRoot.nextMonthClicked()
                }

            }

        }

        // 📆 3. NAMA HARI (Sun, Mon, Tue, Wed, Thu, Fri, Sat)
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
                model: styleRoot.calendarGridCells

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
                text: "System Uptime: " + styleRoot.uptimeString
                color: Theme.accent

                font {
                    family: Theme.fontMain
                    pixelSize: 13
                }

            }

        }

    }

}
