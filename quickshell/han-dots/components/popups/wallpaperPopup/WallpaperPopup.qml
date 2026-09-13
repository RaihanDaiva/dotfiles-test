import "../../../services"
import "../../../theme"
import "./wallpaperStyle"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

// 🖼️ WALLPAPER SELECTOR POPUP OVERLAY (Modular Multi-Style Wallpaper Picker with Dynamic Style Loader)
PanelWindow {
    id: wallpaperPopup

    property bool isOpen: false
    property string searchQuery: ""
    property int selectedIndex: 2
    property var allWallpapers: []
    property var filteredWallpapers: []
    property string targetApplyPath: ""
    property string activeWallpaperPath: ""

    signal requestOpen()

    // 🖼️ Helper function to update search filtering and auto-center selection at index 2
    function updateFilteredWallpapers() {
        var query = searchQuery.trim().toLowerCase();
        if (query.indexOf(">wallpaper") === 0)
            query = query.substring(10).trim();
        else if (query.indexOf(">") === 0)
            query = query.substring(1).trim();
        var list = [];
        for (var i = 0; i < wallpaperPopup.allWallpapers.length; i++) {
            var item = wallpaperPopup.allWallpapers[i];
            if (query === "" || item.title.toLowerCase().indexOf(query) !== -1 || item.filename.toLowerCase().indexOf(query) !== -1)
                list.push(item);

        }
        filteredWallpapers = list;
        // Find index of currently active wallpaper
        var activeIdx = -1;
        if (wallpaperPopup.activeWallpaperPath !== "") {
            for (var k = 0; k < list.length; k++) {
                if (list[k].path === wallpaperPopup.activeWallpaperPath) {
                    activeIdx = k;
                    break;
                }
            }
        }
        if (activeIdx !== -1)
            selectedIndex = activeIdx;
        else if (list.length >= 5)
            selectedIndex = 2;
        else if (list.length > 0)
            selectedIndex = Math.floor(list.length / 2);
        else
            selectedIndex = 0;
        Qt.callLater(function() {
            if (styleLoader.item && typeof styleLoader.item.positionCenter === "function")
                styleLoader.item.positionCenter(selectedIndex);

        });
    }

    function applySelected() {
        if (filteredWallpapers.length > 0 && selectedIndex >= 0 && selectedIndex < filteredWallpapers.length) {
            var item = filteredWallpapers[selectedIndex];
            if (item && item.path) {
                activeWallpaperPath = item.path;
                wallpaperPopup.isOpen = false;
                applyProc.command = [Quickshell.configDir + "/scripts/apply_wallpaper.sh", item.path];
                applyProc.running = false;
                applyProc.running = true;
            }
        }
    }

    function selectIndex(idx) {
        if (idx >= 0 && idx < filteredWallpapers.length) {
            selectedIndex = idx;
            if (styleLoader.item && typeof styleLoader.item.positionCenter === "function")
                styleLoader.item.positionCenter(idx);

        }
    }

    exclusionMode: ExclusionMode.Ignore
    // 🏷️ Wayland LayerShell Configuration (Bottom-Center Overlay)
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    implicitWidth: 960
    implicitHeight: 290
    color: "transparent"
    visible: isOpen || wallpaperCard.opacity > 0
    Component.onCompleted: {
        detectProc.running = true;
    }
    onSearchQueryChanged: updateFilteredWallpapers()
    onIsOpenChanged: {
        if (isOpen) {
            searchQuery = "";
            scanProc.running = false;
            scanProc.running = true;
            if (styleLoader.item && typeof styleLoader.item.resetInput === "function")
                styleLoader.item.resetInput();

            if (styleLoader.item && typeof styleLoader.item.focusInput === "function")
                styleLoader.item.focusInput();

        }
    }
    onVisibleChanged: {
        if (!visible) {
            searchQuery = "";
            if (styleLoader.item && typeof styleLoader.item.resetInput === "function")
                styleLoader.item.resetInput();

        }
    }

    anchors {
        bottom: true
    }

    margins {
        bottom: 10
    }

    // 📡 PROCESS FOR DETECTING CURRENT ACTIVE WALLPAPER ON BOOT
    Process {
        id: detectProc

        command: ["readlink", "-f", Quickshell.env("HOME") + "/.cache/current_wallpaper.jpg"]

        stdout: StdioCollector {
            onStreamFinished: {
                var target = this.text.trim();
                if (target !== "") {
                    wallpaperPopup.activeWallpaperPath = target;
                    wallpaperPopup.updateFilteredWallpapers();
                }
            }
        }

    }

    // 📡 PROCESS FOR SCANNING WALLPAPERS (wallpaper_list.sh)
    Process {
        id: scanProc

        command: [Quickshell.configDir + "/scripts/wallpaper_list.sh"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = this.text.trim().split("\n");
                var list = [];
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (line === "")
                        continue;

                    var parts = line.split("|");
                    if (parts.length >= 3)
                        list.push({
                        "filename": parts[0],
                        "path": parts[1],
                        "title": parts[2]
                    });

                }
                wallpaperPopup.allWallpapers = list;
                wallpaperPopup.updateFilteredWallpapers();
            }
        }

    }

    // 📡 PROCESS FOR APPLYING SELECTED WALLPAPER (apply_wallpaper.sh)
    Process {
        id: applyProc
    }

    // 📡 QUICKSHELL IPC HANDLER FOR SHORTCUT (`quickshell ipc call wallpaperselect toggle`)
    IpcHandler {
        function toggle() {
            if (wallpaperPopup.isOpen)
                wallpaperPopup.isOpen = false;
            else
                wallpaperPopup.requestOpen();
        }

        function open() {
            wallpaperPopup.requestOpen();
        }

        function close() {
            wallpaperPopup.isOpen = false;
        }

        target: "wallpaperselect"
    }

    // 🪟 CARD CONTAINER ITEM (Positions at bottom, animates slide-up smoothly)
    Item {
        id: wallpaperCard

        anchors.fill: parent
        opacity: wallpaperPopup.isOpen ? 1 : 0

        // 🔄 DYNAMIC STYLE LOADER (Original vs macOS)
        Loader {
            id: styleLoader

            anchors.fill: parent
            source: (SettingsStore.popupStyle === "macos") ? Qt.resolvedUrl("./wallpaperStyle/WallpaperStyleMacos.qml") : Qt.resolvedUrl("./wallpaperStyle/WallpaperStyleOriginal.qml")
            onLoaded: {
                if (item) {
                    item.filteredWallpapers = Qt.binding(function() {
                        return wallpaperPopup.filteredWallpapers;
                    });
                    item.selectedIndex = Qt.binding(function() {
                        return wallpaperPopup.selectedIndex;
                    });
                    item.searchQuery = Qt.binding(function() {
                        return wallpaperPopup.searchQuery;
                    });
                    item.activeWallpaperPath = Qt.binding(function() {
                        return wallpaperPopup.activeWallpaperPath;
                    });
                    item.isOpen = Qt.binding(function() {
                        return wallpaperPopup.isOpen;
                    });
                    item.wallpaperClicked.connect(function(index) {
                        wallpaperPopup.selectIndex(index);
                        wallpaperPopup.applySelected();
                    });
                    item.wallpaperHovered.connect(function(index) {
                        wallpaperPopup.selectedIndex = index;
                    });
                    item.searchTextChanged.connect(function(text) {
                        wallpaperPopup.searchQuery = text;
                    });
                    item.leftPressed.connect(function() {
                        if (wallpaperPopup.selectedIndex > 0)
                            wallpaperPopup.selectIndex(wallpaperPopup.selectedIndex - 1);

                    });
                    item.rightPressed.connect(function() {
                        if (wallpaperPopup.selectedIndex < wallpaperPopup.filteredWallpapers.length - 1)
                            wallpaperPopup.selectIndex(wallpaperPopup.selectedIndex + 1);

                    });
                    item.returnPressed.connect(function() {
                        wallpaperPopup.applySelected();
                    });
                    item.escapePressed.connect(function() {
                        wallpaperPopup.isOpen = false;
                    });
                    if (wallpaperPopup.isOpen && typeof item.focusInput === "function")
                        item.focusInput();

                }
            }
        }

        transform: Translate {
            y: wallpaperPopup.isOpen ? 0 : 50

            Behavior on y {
                NumberAnimation {
                    duration: 220
                    easing.type: Easing.OutCubic
                }

            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutCubic
            }

        }

    }

    mask: Region {
        item: wallpaperCard
    }

}
