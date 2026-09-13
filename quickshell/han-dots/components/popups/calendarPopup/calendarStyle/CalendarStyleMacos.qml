import "../../../../services"
import "../../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 📅 CALENDAR POPUP STYLE: MACOS (Frosted Glass Capsules, Concentric Badges & Dedicated Calendar Grid Container Card)
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
        spacing: 12

        // 🏷️ 1. TOP HEADER ROW (Calendar Badge & Uptime Capsule)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Calendar Capsule Badge
            Rectangle {
                implicitHeight: 32
                implicitWidth: headerRow.implicitWidth + 22
                radius: height / 2
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                border.width: 1

                RowLayout {
                    id: headerRow

                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        text: "󰃭"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 15
                        }

                    }

                    Text {
                        text: "Calendar"
                        color: Theme.textMain

                        font {
                            family: Theme.fontMain
                            pixelSize: 12
                            bold: true
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            // System Uptime Capsule Badge
            Rectangle {
                implicitHeight: 26
                implicitWidth: uptimeRow.implicitWidth + 16
                radius: height / 2
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.04)
                border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                border.width: 1

                RowLayout {
                    id: uptimeRow

                    anchors.centerIn: parent
                    spacing: 5

                    Text {
                        text: "󰅐"
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)

                        font {
                            family: Theme.fontMono
                            pixelSize: 12
                        }

                    }

                    Text {
                        text: "Uptime: " + styleRoot.uptimeString
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                        font {
                            family: Theme.fontMain
                            pixelSize: 11
                            bold: true
                        }

                    }

                }

            }

        }

        // 🕒 2. CLOCK & DATE FROSTED BANNER CARD
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: clockBannerCol.implicitHeight + 20
            radius: 18
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
            border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
            border.width: 1

            ColumnLayout {
                id: clockBannerCol

                anchors.centerIn: parent
                spacing: 3

                // Big Digital Clock
                Text {
                    text: styleRoot.liveTimeString !== "" ? styleRoot.liveTimeString : Qt.formatDateTime(new Date(), "hh : mm : ss")
                    color: Theme.textMain
                    Layout.alignment: Qt.AlignHCenter

                    font {
                        family: Theme.fontMain
                        pixelSize: 26
                        bold: true
                    }

                }

                // Full Date Subtitle
                Text {
                    text: styleRoot.liveDateString !== "" ? styleRoot.liveDateString : Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
                    color: Theme.accent
                    Layout.alignment: Qt.AlignHCenter

                    font {
                        family: Theme.fontMain
                        pixelSize: 12
                    }

                }

            }

        }

        // 📅 3. MONTH & YEAR NAVIGATION (Segmented Capsule Buttons)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Previous Month Button (<)
            Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: 15
                color: prevHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                border.color: prevHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰅁"
                    color: prevHover.hovered ? Theme.accent : Theme.textMain

                    font {
                        family: Theme.fontMono
                        pixelSize: 16
                    }

                }

                HoverHandler {
                    id: prevHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: styleRoot.prevMonthClicked()
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            // Month-Year Capsule Pill
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 30
                radius: 15
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: Qt.formatDateTime(styleRoot.displayedDate, "MMMM yyyy")
                    color: Theme.textMain

                    font {
                        family: Theme.fontMain
                        pixelSize: 13
                        bold: true
                    }

                }

            }

            // Today Reset Pill Button
            Rectangle {
                implicitHeight: 30
                implicitWidth: todayRow.implicitWidth + 18
                radius: 15
                color: todayHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                border.color: todayHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                border.width: 1

                RowLayout {
                    id: todayRow

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󰃭"
                        color: todayHover.hovered ? (Theme.isDarkMode ? Theme.bgDark : "#ffffff") : Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 12
                        }

                    }

                    Text {
                        text: "Today"
                        color: todayHover.hovered ? (Theme.isDarkMode ? Theme.bgDark : "#ffffff") : Theme.textMain

                        font {
                            family: Theme.fontMain
                            pixelSize: 11
                            bold: true
                        }

                    }

                }

                HoverHandler {
                    id: todayHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: styleRoot.todayClicked()
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

            // Next Month Button (>)
            Rectangle {
                implicitWidth: 30
                implicitHeight: 30
                radius: 15
                color: nextHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.22) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                border.color: nextHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰅂"
                    color: nextHover.hovered ? Theme.accent : Theme.textMain

                    font {
                        family: Theme.fontMono
                        pixelSize: 16
                    }

                }

                HoverHandler {
                    id: nextHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: styleRoot.nextMonthClicked()
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        // 📅 4. CALENDAR GRID CONTAINER CARD (Holds Day Names Bar & 7x6 Date Cells Grid for High Readability)
        Rectangle {
            id: calendarGridCard

            Layout.fillWidth: true
            implicitHeight: gridCardCol.implicitHeight + 20
            radius: 18
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
            border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
            border.width: 1

            ColumnLayout {
                id: gridCardCol

                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                // 📆 Day Names Bar (macOS Subtle Header Typography)
                GridLayout {
                    Layout.fillWidth: true
                    columns: 7
                    columnSpacing: 4

                    Repeater {
                        model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 22

                            Text {
                                anchors.centerIn: parent
                                text: modelData
                                color: {
                                    if (index === 0)
                                        return Qt.rgba(0.95, 0.55, 0.66, 0.9);
 // Soft red for Sunday
                                    if (index === 6)
                                        return Theme.accent;
 // Accent for Saturday
                                    return Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6);
                                }

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 11
                                    bold: true
                                }

                            }

                        }

                    }

                }

                // 🔢 7x6 Date Cells Grid (Circular / Capsule Discs)
                GridLayout {
                    id: calendarGrid

                    Layout.fillWidth: true
                    columns: 7
                    rowSpacing: 4
                    columnSpacing: 4

                    Repeater {
                        model: styleRoot.calendarGridCells

                        Rectangle {
                            id: dayCell

                            property var cellData: modelData
                            property bool isToday: cellData.isToday
                            property bool isCurrentMonth: cellData.isCurrentMonth
                            property bool isHovered: cellHover.hovered

                            Layout.fillWidth: true
                            implicitHeight: 34
                            radius: height / 2
                            // ⭕ Active Today: Solid Theme.accent | Hover: frosted glass | Default: transparent
                            color: {
                                if (isToday)
                                    return Theme.accent;

                                if (isHovered && isCurrentMonth)
                                    return Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.14);

                                return "transparent";
                            }
                            border.color: {
                                if (isToday)
                                    return Theme.accent;

                                if (isHovered && isCurrentMonth)
                                    return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35);

                                return "transparent";
                            }
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: cellData.day.toString()
                                color: {
                                    if (dayCell.isToday)
                                        return Theme.isDarkMode ? Theme.bgDark : "#ffffff";

                                    if (dayCell.isHovered && dayCell.isCurrentMonth)
                                        return Theme.accent;

                                    if (dayCell.isCurrentMonth)
                                        return Theme.textMain;

                                    return Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3);
                                }

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: dayCell.isToday
                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 120
                                    }

                                }

                            }

                            HoverHandler {
                                id: cellHover
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                            Behavior on border.color {
                                ColorAnimation {
                                    duration: 120
                                }

                            }

                        }

                    }

                }

            }

        }

    }

}
