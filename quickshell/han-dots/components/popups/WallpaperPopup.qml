import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../theme"

// 🖼️ WALLPAPER SELECTOR POPUP OVERLAY (5-Item Center Selection Carousel from ~/.config/wallpapers)
PanelWindow {
    id: wallpaperPopup

    exclusionMode: ExclusionMode.Ignore

    property bool isOpen: false
    property string searchQuery: ""
    property int selectedIndex: 2
    property var allWallpapers: []
    property var filteredWallpapers: []
    property string targetApplyPath: ""
    property string activeWallpaperPath: ""

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

    implicitWidth: 960
    implicitHeight: 290
    color: "transparent"

    mask: Region {
        item: wallpaperCard
    }

    visible: isOpen || wallpaperCard.opacity > 0

    // 🖼️ Helper function to update search filtering and auto-center selection at index 2
    function updateFilteredWallpapers() {
        var query = searchQuery.trim().toLowerCase()
        if (query.indexOf(">wallpaper") === 0) {
            query = query.substring(10).trim()
        } else if (query.indexOf(">") === 0) {
            query = query.substring(1).trim()
        }

        var list = []
        for (var i = 0; i < wallpaperPopup.allWallpapers.length; i++) {
            var item = wallpaperPopup.allWallpapers[i]
            if (query === "" || item.title.toLowerCase().indexOf(query) !== -1 || item.filename.toLowerCase().indexOf(query) !== -1) {
                list.push(item)
            }
        }

        filteredWallpapers = list

        // Find index of currently active wallpaper
        var activeIdx = -1
        if (wallpaperPopup.activeWallpaperPath !== "") {
            for (var k = 0; k < list.length; k++) {
                if (list[k].path === wallpaperPopup.activeWallpaperPath) {
                    activeIdx = k
                    break
                }
            }
        }

        if (activeIdx !== -1) {
            selectedIndex = activeIdx
        } else if (list.length >= 5) {
            selectedIndex = 2 // Default center item out of 5
        } else if (list.length > 0) {
            selectedIndex = Math.floor(list.length / 2)
        } else {
            selectedIndex = 0
        }

        Qt.callLater(function() {
            if (wallListView.count > selectedIndex && selectedIndex >= 0) {
                wallListView.positionViewAtIndex(selectedIndex, ListView.Center)
            }
        })
    }

    // 📡 PROCESS FOR DETECTING CURRENT ACTIVE WALLPAPER ON BOOT
    Process {
        id: detectProc
        command: ["readlink", "-f", Quickshell.env("HOME") + "/.cache/current_wallpaper.jpg"]

        stdout: StdioCollector {
            onStreamFinished: {
                var target = this.text.trim()
                if (target !== "") {
                    wallpaperPopup.activeWallpaperPath = target
                    wallpaperPopup.updateFilteredWallpapers()
                }
            }
        }
    }

    Component.onCompleted: {
        detectProc.running = true
    }

    // 📡 PROCESS FOR SCANNING WALLPAPERS (wallpaper_list.sh)
    Process {
        id: scanProc
        command: [Quickshell.configDir + "/scripts/wallpaper_list.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n")
                var list = []
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line === "") continue
                    var parts = line.split("|")
                    if (parts.length >= 3) {
                        list.push({
                            filename: parts[0],
                            path: parts[1],
                            title: parts[2]
                        })
                    }
                }
                wallpaperPopup.allWallpapers = list
                wallpaperPopup.updateFilteredWallpapers()
            }
        }
    }

    // 📡 PROCESS FOR APPLYING SELECTED WALLPAPER (apply_wallpaper.sh)
    Process {
        id: applyProc
    }

    onSearchQueryChanged: updateFilteredWallpapers()
    onIsOpenChanged: {
        if (isOpen) {
            searchQuery = ""
            searchInput.text = ""
            scanProc.running = false
            scanProc.running = true
            searchInput.forceActiveFocus()
            searchInput.cursorPosition = searchInput.text.length
        }
    }

    function applySelected() {
        if (filteredWallpapers.length > 0 && selectedIndex >= 0 && selectedIndex < filteredWallpapers.length) {
            var item = filteredWallpapers[selectedIndex]
            if (item && item.path) {
                activeWallpaperPath = item.path // Remember applied wallpaper!
                wallpaperPopup.isOpen = false
                applyProc.command = [Quickshell.configDir + "/scripts/apply_wallpaper.sh", item.path]
                applyProc.running = false
                applyProc.running = true
            }
        }
    }

    function selectIndex(idx) {
        if (idx >= 0 && idx < filteredWallpapers.length) {
            selectedIndex = idx
            wallListView.positionViewAtIndex(idx, ListView.Center)
        }
    }

    signal requestOpen()

    // 📡 QUICKSHELL IPC HANDLER FOR SHORTCUT (`quickshell ipc call wallpaperselect toggle`)
    IpcHandler {
        target: "wallpaperselect"

        function toggle() {
            if (wallpaperPopup.isOpen) {
                wallpaperPopup.isOpen = false
            } else {
                wallpaperPopup.requestOpen()
            }
        }

        function open() {
            wallpaperPopup.requestOpen()
        }

        function close() {
            wallpaperPopup.isOpen = false
        }
    }

    // 🪟 CARD CONTAINER RECTANGLE WITH HYPRLAND BLUR & SLIDE-UP ANIMATION
    Rectangle {
        id: wallpaperCard
        anchors.fill: parent
        radius: 24
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.96)
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1

        opacity: wallpaperPopup.isOpen ? 1.0 : 0.0
        transform: Translate {
            y: wallpaperPopup.isOpen ? 0 : 50
            Behavior on y { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
        }

        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        // 📦 MAIN WALLPAPER SELECTOR LAYOUT (5-Item Carousel at Top, Search Bar at Bottom)
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 18
            spacing: 14

            // 🖼️ TOP SECTION: HORIZONTAL CAROUSEL OF 5 WALLPAPERS WITH CENTER FOCUS
            ListView {
                id: wallListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                orientation: ListView.Horizontal
                clip: false // Disable clip so elevated center item is never truncated!
                spacing: 18
                snapMode: ListView.SnapToItem
                highlightRangeMode: ListView.ApplyRange

                model: wallpaperPopup.filteredWallpapers

                delegate: Item {
                    id: wallDelegate
                    implicitWidth: 170
                    implicitHeight: wallListView.height

                    property bool isHovered: itemHover.hovered
                    property bool isSelected: wallpaperPopup.selectedIndex === index || isHovered

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 10

                        // Outer Border Rectangle (Handles Scale & Crisp Accent Border)
                        Rectangle {
                            id: outerBorderRect
                            Layout.fillWidth: true
                            implicitHeight: 110
                            // radius: 16
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                            border.color: wallDelegate.isSelected ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                            border.width: wallDelegate.isSelected ? 1 : 1

                            scale: wallDelegate.isSelected ? 1.12 : 1.0

                            Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }
                            Behavior on border.color { ColorAnimation { duration: 150 } }

                            // 🖼️ Inner Image Container with Inset Margin & Clip for Smooth Rounded Corners
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: wallDelegate.isSelected ? 2 : 1
                                radius: 14
                                clip: true
                                color: "transparent"

                                Image {
                                    id: wallpaperImg
                                    anchors.fill: parent
                                    source: "file://" + modelData.path
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    asynchronous: true
                                }
                            }
                        }

                        // Wallpaper Name Text Below Thumbnail
                        Text {
                            text: modelData.title || modelData.filename
                            color: wallDelegate.isSelected ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)
                            font { family: Theme.fontMain; pixelSize: 12; bold: wallDelegate.isSelected }
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }
                    }

                    HoverHandler {
                        id: itemHover
                        onHoveredChanged: {
                            if (hovered) wallpaperPopup.selectIndex(index)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            wallpaperPopup.selectIndex(index)
                            wallpaperPopup.applySelected()
                        }
                    }
                }
            }

            // 🔍 BOTTOM SECTION: COMMAND / SEARCH BAR
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
                            text: "Search Wallpapers"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                            font { family: Theme.fontMain; pixelSize: 14 }
                            visible: searchInput.text === "" && !searchInput.inputMethodComposing
                        }

                        onTextChanged: {
                            wallpaperPopup.searchQuery = text
                        }

                        Keys.onLeftPressed: {
                            if (wallpaperPopup.selectedIndex > 0) {
                                wallpaperPopup.selectIndex(wallpaperPopup.selectedIndex - 1)
                            }
                        }

                        Keys.onRightPressed: {
                            if (wallpaperPopup.selectedIndex < wallpaperPopup.filteredWallpapers.length - 1) {
                                wallpaperPopup.selectIndex(wallpaperPopup.selectedIndex + 1)
                            }
                        }

                        Keys.onReturnPressed: wallpaperPopup.applySelected()
                        Keys.onEscapePressed: wallpaperPopup.isOpen = false
                    }

                    // Clear button
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
