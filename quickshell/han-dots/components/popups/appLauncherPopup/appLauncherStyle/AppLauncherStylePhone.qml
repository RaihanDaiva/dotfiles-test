import "../../../../services"
import "../../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

// 📱 APPLICATION LAUNCHER STYLE: PHONE (GTA V iFruit Style with Horizontal Paging)
Item {
    id: styleRoot

    property var filteredApps: []
    property int selectedIndex: 0
    property string searchQuery: ""
    property var iconSourceCallback: null
    property bool isOpen: false
    property var keyHandler: null
    readonly property int columns: 4
    readonly property int rows: 5
    readonly property int appsPerPage: columns * rows

    signal appClicked(int index)
    signal appHovered(int index)
    signal searchTextChanged(string text)

    function focusInput() {
        searchInput.forceActiveFocus();
    }

    function resetInput() {
        searchInput.text = "";
    }

    function positionVisible(index) {
        if (styleRoot.filteredApps.length > 0 && index >= 0 && index < styleRoot.filteredApps.length) {
            var page = Math.floor(index / styleRoot.appsPerPage);
            if (pagesListView.currentIndex !== page)
                pagesListView.positionViewAtIndex(page, ListView.Contain);

        }
    }

    function positionTop() {
        if (pagesListView.count > 0)
            pagesListView.positionViewAtBeginning();

    }

    anchors.fill: parent

    // 📱 PHONE HARDWARE CHASSIS & WALLPAPER BACKGROUND
    Image {
        id: phoneFrame

        anchors.fill: parent
        source: Qt.resolvedUrl("../../../../assets/image/phone.png")
        fillMode: Image.PreserveAspectFit
        smooth: true
    }

    // 🔲 INNER PHONE SCREEN CONTAINER
    Item {
        id: screenArea

        property var currentTime: new Date()

        anchors.fill: parent
        anchors.topMargin: 14
        anchors.bottomMargin: 14
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        clip: true

        Timer {
            interval: 1000
            running: styleRoot.isOpen
            repeat: true
            onTriggered: screenArea.currentTime = new Date()
        }

        MouseArea {
            anchors.fill: parent
            z: -1
            onClicked: {
                searchInput.forceActiveFocus();
            }
        }

        // 🕒 LIVE SYSTEM CLOCK (LEFT OF NOTCH)
        Text {
            id: statusTime

            anchors.left: parent.left
            anchors.leftMargin: 24
            anchors.top: parent.top
            anchors.topMargin: 13
            text: Qt.formatTime(screenArea.currentTime, "hh:mm")
            color: "white"
            renderType: Text.NativeRendering

            font {
                family: Theme.fontMain
                pixelSize: 12
                bold: true
            }

        }

        // 📶 HARDWARE STATUS ICONS (RIGHT OF NOTCH: CELLULAR, BATTERY)
        RowLayout {
            anchors.right: parent.right
            anchors.rightMargin: 24
            anchors.top: parent.top
            anchors.topMargin: 13
            spacing: 5

            Text {
                text: "󰤨"
                color: "white"
                renderType: Text.NativeRendering

                font {
                    family: Theme.fontMono
                    pixelSize: 12
                }

            }

            Text {
                text: "󰁹"
                color: "white"
                renderType: Text.NativeRendering

                font {
                    family: Theme.fontMono
                    pixelSize: 13
                }

            }

        }

        // 📋 APP GRID HORIZONTAL PAGED VIEW
        ListView {
            id: pagesListView

            anchors.top: parent.top
            anchors.topMargin: 44
            anchors.bottom: pageDotsContainer.top
            anchors.bottomMargin: 4
            anchors.left: parent.left
            anchors.right: parent.right
            orientation: ListView.Horizontal
            snapMode: ListView.SnapOneItem
            highlightRangeMode: ListView.StrictlyEnforceRange
            highlightMoveDuration: 250
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            visible: styleRoot.filteredApps.length > 0
            model: Math.max(1, Math.ceil(styleRoot.filteredApps.length / styleRoot.appsPerPage))

            delegate: Item {
                id: pageDelegate

                required property int index
                readonly property int pageStartIndex: pageDelegate.index * styleRoot.appsPerPage
                readonly property int pageItemCount: Math.min(styleRoot.appsPerPage, Math.max(0, styleRoot.filteredApps.length - pageStartIndex))

                width: pagesListView.width
                height: pagesListView.height

                Grid {
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 6
                    width: styleRoot.columns * 58 + (styleRoot.columns - 1) * columnSpacing
                    columns: styleRoot.columns
                    rows: styleRoot.rows
                    columnSpacing: 14
                    rowSpacing: 8

                    Repeater {
                        model: pageDelegate.pageItemCount

                        Item {
                            id: appItem

                            required property int index
                            readonly property int globalAppIndex: pageDelegate.pageStartIndex + appItem.index
                            readonly property var appData: (appItem.globalAppIndex >= 0 && appItem.globalAppIndex < styleRoot.filteredApps.length) ? styleRoot.filteredApps[appItem.globalAppIndex] : null
                            readonly property bool isSelected: styleRoot.selectedIndex === globalAppIndex
                            readonly property bool isHovered: itemMouseArea.containsMouse

                            width: 58
                            height: 70

                            ColumnLayout {
                                anchors.centerIn: parent
                                spacing: 3

                                Item {
                                    id: iconWrapper

                                    Layout.alignment: Qt.AlignHCenter
                                    width: 50
                                    height: 50
                                    scale: appItem.isSelected ? 1.12 : (appItem.isHovered ? 1.06 : 1)

                                    // Subtle indicator ring / glow on active or hovered item
                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width + 6
                                        height: parent.height + 6
                                        radius: 13
                                        color: appItem.isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35) : (appItem.isHovered ? Qt.rgba(1, 1, 1, 0.18) : "transparent")
                                        visible: appItem.isSelected || appItem.isHovered
                                        border.color: appItem.isSelected ? Theme.accent : Qt.rgba(1, 1, 1, 0.3)
                                        border.width: appItem.isSelected ? 1.5 : 1

                                        Behavior on color {
                                            ColorAnimation {
                                                duration: 140
                                            }

                                        }

                                        Behavior on border.color {
                                            ColorAnimation {
                                                duration: 140
                                            }

                                        }

                                    }

                                    IconImage {
                                        id: appIcon

                                        anchors.fill: parent
                                        source: (styleRoot.iconSourceCallback && appItem.appData) ? styleRoot.iconSourceCallback(appItem.appData.icon) : ""
                                        visible: status === Image.Ready
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰀉"
                                        color: appItem.isSelected ? Theme.accent : "white"
                                        visible: appIcon.status !== Image.Ready

                                        font {
                                            family: Theme.fontMono
                                            pixelSize: 34
                                        }

                                    }

                                    Behavior on scale {
                                        NumberAnimation {
                                            duration: 140
                                            easing.type: Easing.OutQuad
                                        }

                                    }

                                }

                                Text {
                                    Layout.preferredWidth: 66
                                    Layout.alignment: Qt.AlignHCenter
                                    text: appItem.appData ? (appItem.appData.name || "") : ""
                                    color: appItem.isSelected ? Theme.accent : "white"
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    maximumLineCount: 1
                                    renderType: Text.NativeRendering

                                    font {
                                        family: Theme.fontMain
                                        pixelSize: 11
                                        bold: appItem.isSelected
                                    }

                                }

                            }

                            MouseArea {
                                id: itemMouseArea

                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onEntered: {
                                    styleRoot.appHovered(appItem.globalAppIndex);
                                }
                                onClicked: {
                                    styleRoot.appClicked(appItem.globalAppIndex);
                                }
                            }

                        }

                    }

                }

            }

        }

        // 🔘 PAGINATION DOTS (Centered above search bar)
        Row {
            id: pageDotsContainer

            anchors.bottom: searchBarContainer.top
            anchors.bottomMargin: 8
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 6
            visible: pagesListView.count > 1

            Repeater {
                model: pagesListView.count

                Rectangle {
                    id: dotItem

                    required property int index

                    width: pagesListView.currentIndex === index ? 16 : 6
                    height: 6
                    radius: 3
                    color: pagesListView.currentIndex === index ? "white" : Qt.rgba(1, 1, 1, 0.4)

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: pagesListView.positionViewAtIndex(dotItem.index, ListView.Contain)
                    }

                    Behavior on width {
                        NumberAnimation {
                            duration: 160
                            easing.type: Easing.OutCubic
                        }

                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                        }

                    }

                }

            }

        }

        // 🔍 BOTTOM SECTION: SEARCH INPUT BAR (macOS capsule pill style)
        Rectangle {
            id: searchBarContainer

            anchors.bottom: homeBar.top
            anchors.bottomMargin: 8
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            implicitHeight: 38
            radius: height / 2
            color: searchInput.activeFocus ? Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.75) : Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.55)
            border.color: searchInput.activeFocus ? Theme.accent : Qt.rgba(1, 1, 1, 0.22)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Text {
                    text: "󰍉"
                    color: searchInput.activeFocus ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)

                    font {
                        family: Theme.fontMono
                        pixelSize: 15
                    }

                }

                TextInput {
                    id: searchInput

                    Layout.fillWidth: true
                    color: Theme.textMain
                    clip: true
                    focus: true
                    onTextChanged: {
                        styleRoot.searchTextChanged(text);
                    }
                    Keys.onPressed: (event) => {
                        if (styleRoot.keyHandler)
                            styleRoot.keyHandler(event);

                    }

                    font {
                        family: Theme.fontMain
                        pixelSize: 13
                    }

                    Text {
                        text: "Search Apps"
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.45)
                        visible: searchInput.text === "" && !searchInput.inputMethodComposing

                        font {
                            family: Theme.fontMain
                            pixelSize: 13
                        }

                    }

                }

                // Clear button when text is typed
                Rectangle {
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: clearHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent"
                    visible: searchInput.text !== ""

                    Text {
                        anchors.centerIn: parent
                        text: "󰅖"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 11
                        }

                    }

                    HoverHandler {
                        id: clearHover
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            searchInput.text = "";
                            searchInput.forceActiveFocus();
                        }
                    }

                }

            }

        }

        // 📱 IPHONE HOME INDICATOR BAR
        Rectangle {
            id: homeBar

            anchors.bottom: parent.bottom
            anchors.bottomMargin: 110
            anchors.horizontalCenter: parent.horizontalCenter
            width: 90
            height: 4
            radius: 2
            color: Qt.rgba(1, 1, 1, 0.5)
        }

        // 🔍 EMPTY SEARCH STATE
        ColumnLayout {
            anchors.centerIn: parent
            spacing: 8
            visible: styleRoot.filteredApps.length === 0

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "󰍉"
                color: Qt.rgba(1, 1, 1, 0.5)

                font {
                    family: Theme.fontMono
                    pixelSize: 32
                }

            }

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "No applications found"
                color: Qt.rgba(1, 1, 1, 0.8)

                font {
                    family: Theme.fontMain
                    pixelSize: 13
                    bold: true
                }

            }

        }

    }

}
