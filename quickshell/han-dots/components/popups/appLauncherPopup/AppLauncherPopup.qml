import "../../../services"
import "../../../theme"
import "./appLauncherStyle"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets

// 🚀 APPLICATION LAUNCHER POPUP OVERLAY (Shell Window Wrapper with Dynamic Style Loader)
PanelWindow {
    id: launcherPopup

    property bool isOpen: false
    property string searchQuery: ""
    property int selectedIndex: 0
    property var filteredApps: []
    readonly property real maxCardHeight: 540
    readonly property real minCardHeight: 140
    readonly property real maxListHeight: 452
    readonly property real calculatedListHeight: {
        var count = filteredApps.length;
        if (count === 0)
            return searchQuery === "" ? maxListHeight : 0;

        var total = count * 52 + Math.max(0, count - 1) * 4;
        return Math.min(maxListHeight, total);
    }
    readonly property real targetCardHeight: {
        if (filteredApps.length === 0 && searchQuery !== "")
            return minCardHeight;

        return Math.min(maxCardHeight, calculatedListHeight + 88);
    }

    signal requestOpen()

    // 🖼️ Helper function to resolve Freedesktop system icons
    function getIconSource(iconName) {
        if (!iconName || iconName === "")
            return "";

        if (iconName.indexOf("/") === 0 || iconName.indexOf("file://") === 0)
            return iconName;

        return "image://icon/" + iconName;
    }

    function updateFilteredApps() {
        var query = searchQuery.trim().toLowerCase();
        var list = [];
        var entries = [];
        if (typeof DesktopEntries !== "undefined" && DesktopEntries.applications) {
            var appsModel = DesktopEntries.applications;
            if (appsModel.values && appsModel.values.length) {
                entries = appsModel.values;
            } else if (typeof appsModel.count !== "undefined" && appsModel.count > 0) {
                for (var i = 0; i < appsModel.count; i++) {
                    var item = appsModel.get ? appsModel.get(i) : appsModel[i];
                    if (item)
                        entries.push(item);

                }
            }
        }
        for (var j = 0; j < entries.length; j++) {
            var entry = entries[j];
            if (!entry || !entry.name)
                continue;

            var name = entry.name || "";
            var comment = entry.comment || entry.genericName || "";
            var exec = entry.execString || "";
            if (query === "" || name.toLowerCase().indexOf(query) !== -1 || comment.toLowerCase().indexOf(query) !== -1 || exec.toLowerCase().indexOf(query) !== -1)
                list.push(entry);

        }
        // Sort alphabetically by name
        list.sort(function(a, b) {
            return a.name.localeCompare(b.name);
        });
        filteredApps = list;
        if (selectedIndex >= filteredApps.length)
            selectedIndex = Math.max(0, filteredApps.length - 1);

    }

    function launchSelected() {
        if (filteredApps.length > 0 && selectedIndex >= 0 && selectedIndex < filteredApps.length) {
            var entry = filteredApps[selectedIndex];
            if (entry && typeof entry.execute === "function") {
                launcherPopup.isOpen = false;
                entry.execute();
            }
        }
    }

    exclusionMode: ExclusionMode.Ignore
    // 🏷️ Wayland LayerShell Configuration (Bottom-Center Overlay)
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    implicitWidth: 480
    implicitHeight: maxCardHeight
    color: "transparent"
    visible: isOpen || launcherCard.opacity > 0
    Component.onCompleted: updateFilteredApps()
    onSearchQueryChanged: updateFilteredApps()
    onIsOpenChanged: {
        if (isOpen) {
            searchQuery = "";
            selectedIndex = 0;
            updateFilteredApps();
            if (styleLoader.item && typeof styleLoader.item.focusInput === "function")
                styleLoader.item.focusInput();

        }
    }
    onVisibleChanged: {
        if (!visible) {
            searchQuery = "";
            selectedIndex = 0;
            updateFilteredApps();
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

    // ⏱️ Auto-Retry Timer if desktop entries scan finishes after boot
    Timer {
        id: initPopulateTimer

        interval: 300
        running: filteredApps.length === 0
        repeat: true
        onTriggered: {
            updateFilteredApps();
            if (filteredApps.length > 0)
                stop();

        }
    }

    // 📡 QUICKSHELL IPC HANDLER FOR SHORTCUT (`quickshell ipc call applauncher toggle`)
    IpcHandler {
        function toggle() {
            if (launcherPopup.isOpen)
                launcherPopup.isOpen = false;
            else
                launcherPopup.requestOpen();
        }

        function open() {
            launcherPopup.requestOpen();
        }

        function close() {
            launcherPopup.isOpen = false;
        }

        target: "applauncher"
    }

    // 🪟 CARD CONTAINER ITEM (Positions at bottom, animates height & slide-up smoothly)
    Item {
        id: launcherCard

        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: launcherPopup.targetCardHeight
        opacity: launcherPopup.isOpen ? 1 : 0

        // 🔄 DYNAMIC STYLE LOADER (Original vs macOS)
        Loader {
            id: styleLoader

            anchors.fill: parent
            source: (SettingsStore.popupStyle === "macos") ? Qt.resolvedUrl("./appLauncherStyle/AppLauncherStyleMacos.qml") : Qt.resolvedUrl("./appLauncherStyle/AppLauncherStyleOriginal.qml")
            onLoaded: {
                if (item) {
                    item.filteredApps = Qt.binding(function() {
                        return launcherPopup.filteredApps;
                    });
                    item.selectedIndex = Qt.binding(function() {
                        return launcherPopup.selectedIndex;
                    });
                    item.searchQuery = Qt.binding(function() {
                        return launcherPopup.searchQuery;
                    });
                    item.isOpen = Qt.binding(function() {
                        return launcherPopup.isOpen;
                    });
                    item.iconSourceCallback = launcherPopup.getIconSource;
                    item.appClicked.connect(function(index) {
                        launcherPopup.selectedIndex = index;
                        launcherPopup.launchSelected();
                    });
                    item.appHovered.connect(function(index) {
                        launcherPopup.selectedIndex = index;
                    });
                    item.searchTextChanged.connect(function(text) {
                        launcherPopup.searchQuery = text;
                        launcherPopup.selectedIndex = 0;
                        if (styleLoader.item && typeof styleLoader.item.positionTop === "function")
                            styleLoader.item.positionTop();

                    });
                    item.upPressed.connect(function() {
                        if (launcherPopup.selectedIndex > 0) {
                            launcherPopup.selectedIndex--;
                            if (styleLoader.item && typeof styleLoader.item.positionVisible === "function")
                                styleLoader.item.positionVisible(launcherPopup.selectedIndex);

                        }
                    });
                    item.downPressed.connect(function() {
                        if (launcherPopup.selectedIndex < launcherPopup.filteredApps.length - 1) {
                            launcherPopup.selectedIndex++;
                            if (styleLoader.item && typeof styleLoader.item.positionVisible === "function")
                                styleLoader.item.positionVisible(launcherPopup.selectedIndex);

                        }
                    });
                    item.returnPressed.connect(function() {
                        launcherPopup.launchSelected();
                    });
                    item.escapePressed.connect(function() {
                        launcherPopup.isOpen = false;
                    });
                    if (launcherPopup.isOpen && typeof item.focusInput === "function")
                        item.focusInput();

                }
            }
        }

        Behavior on height {
            enabled: launcherPopup.isOpen

            NumberAnimation {
                duration: 200
                easing.type: Easing.OutCubic
            }

        }

        transform: Translate {
            y: launcherPopup.isOpen ? 0 : 50

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
        item: launcherCard
    }

}
