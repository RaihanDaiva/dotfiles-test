import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import "../../theme"

// 🚀 APPLICATION LAUNCHER POPUP OVERLAY (Bottom-Center Floating Card with Slide-up Animation)
PanelWindow {
    id: launcherPopup

    exclusionMode: ExclusionMode.Ignore

    property bool isOpen: false
    property string searchQuery: ""
    property int selectedIndex: 0
    property var filteredApps: []

    // 🏷️ Wayland LayerShell Configuration (Bottom-Center Overlay)
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        bottom: true
    }
    margins {
        bottom: 10
    }

    implicitWidth: 480
    implicitHeight: 540
    color: "transparent"

    mask: Region {
        item: launcherCard
    }

    visible: isOpen || launcherCard.opacity > 0

    // 🖼️ Helper function to resolve Freedesktop system icons
    function getIconSource(iconName) {
        if (!iconName || iconName === "") return ""
        if (iconName.indexOf("/") === 0 || iconName.indexOf("file://") === 0) return iconName
        return "image://icon/" + iconName
    }

    function updateFilteredApps() {
        var query = searchQuery.trim().toLowerCase()
        var list = []
        var entries = []

        if (typeof DesktopEntries !== "undefined" && DesktopEntries.applications) {
            var appsModel = DesktopEntries.applications
            if (appsModel.values && appsModel.values.length) {
                entries = appsModel.values
            } else if (typeof appsModel.count !== "undefined" && appsModel.count > 0) {
                for (var i = 0; i < appsModel.count; i++) {
                    var item = appsModel.get ? appsModel.get(i) : appsModel[i]
                    if (item) entries.push(item)
                }
            }
        }

        for (var j = 0; j < entries.length; j++) {
            var entry = entries[j]
            if (!entry || !entry.name) continue

            var name = entry.name || ""
            var comment = entry.comment || entry.genericName || ""
            var exec = entry.execString || ""

            if (query === "" || name.toLowerCase().indexOf(query) !== -1 || comment.toLowerCase().indexOf(query) !== -1 || exec.toLowerCase().indexOf(query) !== -1) {
                list.push(entry)
            }
        }

        // Sort alphabetically by name
        list.sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })

        filteredApps = list
        if (selectedIndex >= filteredApps.length) {
            selectedIndex = Math.max(0, filteredApps.length - 1)
        }
    }

    Component.onCompleted: updateFilteredApps()

    // ⏱️ Auto-Retry Timer if desktop entries scan finishes after boot
    Timer {
        id: initPopulateTimer
        interval: 300
        running: filteredApps.length === 0
        repeat: true
        onTriggered: {
            updateFilteredApps()
            if (filteredApps.length > 0) stop()
        }
    }

    onSearchQueryChanged: updateFilteredApps()
    onIsOpenChanged: {
        if (isOpen) {
            searchQuery = ""
            searchInput.text = ""
            selectedIndex = 0
            updateFilteredApps()
            searchInput.forceActiveFocus()
        }
    }

    function launchSelected() {
        if (filteredApps.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            var entry = filteredApps[selectedIndex]
            if (entry && typeof entry.execute === "function") {
                launcherPopup.isOpen = false
                entry.execute()
            }
        }
    }

    signal requestOpen()

    // 📡 QUICKSHELL IPC HANDLER FOR SHORTCUT (`quickshell ipc call applauncher toggle`)
    IpcHandler {
        target: "applauncher"

        function toggle() {
            if (launcherPopup.isOpen) {
                launcherPopup.isOpen = false
            } else {
                launcherPopup.requestOpen()
            }
        }

        function open() {
            launcherPopup.requestOpen()
        }

        function close() {
            launcherPopup.isOpen = false
        }
    }

    // 🪟 CARD CONTAINER RECTANGLE WITH HYPRLAND BLUR & SLIDE-UP ANIMATION
    Rectangle {
        id: launcherCard
        anchors.fill: parent
        radius: 20
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.96)
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1

        opacity: launcherPopup.isOpen ? 1.0 : 0.0
        transform: Translate {
            y: launcherPopup.isOpen ? 0 : 50
            Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        }

        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        // 📦 MAIN LAUNCHER LAYOUT (App List at Top, Search Input Bar at Bottom)
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            // 📋 TOP SECTION: APP LIST VIEW
            ListView {
                id: appListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4

                model: launcherPopup.filteredApps

                delegate: Rectangle {
                    id: appDelegate
                    width: appListView.width
                    implicitHeight: 52
                    radius: 12

                    property bool isHovered: itemHover.hovered
                    property bool isSelected: launcherPopup.selectedIndex === index || isHovered

                    color: isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"
                    border.color: isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : "transparent"
                    border.width: 1

                    Behavior on color { ColorAnimation { duration: 150 } }

                    HoverHandler {
                        id: itemHover
                        onHoveredChanged: {
                            if (hovered) launcherPopup.selectedIndex = index
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            launcherPopup.selectedIndex = index
                            launcherPopup.launchSelected()
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 12
                        anchors.rightMargin: 12
                        spacing: 12

                        // App Icon
                        Item {
                            implicitWidth: 34
                            implicitHeight: 34
                            Layout.alignment: Qt.AlignVCenter

                            IconImage {
                                id: appIcon
                                anchors.fill: parent
                                source: launcherPopup.getIconSource(modelData.icon)
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                text: "󰀉"
                                color: Theme.accent
                                font { family: Theme.fontMono; pixelSize: 20 }
                                visible: appIcon.status !== Image.Ready
                            }
                        }

                        // App Title & Comment Column
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 2

                            Text {
                                text: modelData.name || "Application"
                                color: appDelegate.isSelected ? Theme.accent : Theme.textMain
                                font { family: Theme.fontMain; pixelSize: 14; bold: true }
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                            }

                            Text {
                                text: modelData.comment || modelData.genericName || modelData.execString || ""
                                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.65)
                                font { family: Theme.fontMain; pixelSize: 11 }
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                visible: text !== ""
                            }
                        }
                    }
                }

                // Scroll position tracking
                onCurrentIndexChanged: {
                    if (currentIndex >= 0) positionViewAtIndex(currentIndex, ListView.Beginning)
                }
            }

            // 🔍 BOTTOM SECTION: SEARCH INPUT BAR
            Rectangle {
                id: searchBarContainer
                Layout.fillWidth: true
                implicitHeight: 44
                radius: 14
                color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.6)
                border.color: searchInput.activeFocus ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                border.width: 1

                Behavior on border.color { ColorAnimation { duration: 150 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 14
                    anchors.rightMargin: 14
                    spacing: 10

                    Text {
                        text: "󰍉"
                        color: searchInput.activeFocus ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5)
                        font { family: Theme.fontMono; pixelSize: 16 }
                    }

                    TextInput {
                        id: searchInput
                        Layout.fillWidth: true
                        color: Theme.textMain
                        font { family: Theme.fontMain; pixelSize: 14 }
                        clip: true
                        focus: true

                        Text {
                            text: 'Search Apps'
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                            font { family: Theme.fontMain; pixelSize: 14 }
                            visible: searchInput.text === "" && !searchInput.inputMethodComposing
                        }

                        onTextChanged: {
                            launcherPopup.searchQuery = text
                            launcherPopup.selectedIndex = 0
                        }

                        Keys.onUpPressed: {
                            if (launcherPopup.selectedIndex > 0) {
                                launcherPopup.selectedIndex--
                                appListView.currentIndex = launcherPopup.selectedIndex
                            }
                        }

                        Keys.onDownPressed: {
                            if (launcherPopup.selectedIndex < launcherPopup.filteredApps.length - 1) {
                                launcherPopup.selectedIndex++
                                appListView.currentIndex = launcherPopup.selectedIndex
                            }
                        }

                        Keys.onReturnPressed: launcherPopup.launchSelected()
                        Keys.onEscapePressed: launcherPopup.isOpen = false
                    }

                    // Clear button when text is typed
                    Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: clearHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"
                        visible: searchInput.text !== ""

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: Theme.accent
                            font { family: Theme.fontMono; pixelSize: 12 }
                        }

                        HoverHandler { id: clearHover }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                searchInput.text = ""
                                searchInput.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }
}
