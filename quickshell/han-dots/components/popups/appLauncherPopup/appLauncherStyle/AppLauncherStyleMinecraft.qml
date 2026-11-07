import "../../../../services"
import "../../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

// ⛏️ APPLICATION LAUNCHER STYLE: MINECRAFT INVENTORY (Creative Inventory GUI with Custom Font & Pixel Tooltip)
Item {
    id: styleRoot

    property var filteredApps: []
    property int selectedIndex: 0
    property string searchQuery: ""
    property var iconSourceCallback: null
    property bool isOpen: false
    property var keyHandler: null
    readonly property int columns: 9
    readonly property int visibleRows: 5
    readonly property int totalVisibleSlots: columns * visibleRows
    property int scrollRow: 0
    readonly property int totalRows: Math.max(visibleRows, Math.ceil(filteredApps.length / columns))
    readonly property int maxScrollRow: Math.max(0, totalRows - visibleRows)
    property var hoveredApp: null
    property real mouseHoverX: 0
    property real mouseHoverY: 0

    signal appClicked(int index)
    signal appHovered(int index)
    signal searchTextChanged(string text)
    signal requestClose()

    function focusInput() {
        searchInput.forceActiveFocus();
    }

    function resetInput() {
        searchInput.text = "";
    }

    function positionVisible(index) {
        if (index >= 0 && index < filteredApps.length) {
            var row = Math.floor(index / columns);
            if (row < scrollRow)
                scrollRow = row;
            else if (row >= scrollRow + visibleRows)
                scrollRow = row - visibleRows + 1;
        }
    }

    function positionTop() {
        scrollRow = 0;
    }

    property var fixedHotbarApps: []

    function updateFixedHotbar() {
        if (fixedHotbarApps.length >= 9)
            return;

        var entries = [];
        if (typeof DesktopEntries !== "undefined" && DesktopEntries.applications) {
            var appsModel = DesktopEntries.applications;
            if (appsModel.values && appsModel.values.length) {
                entries = appsModel.values;
            } else if (typeof appsModel.count !== "undefined" && appsModel.count > 0) {
                for (var k = 0; k < appsModel.count; k++) {
                    var item = appsModel.get ? appsModel.get(k) : appsModel[k];
                    if (item)
                        entries.push(item);
                }
            }
        }

        if (entries.length === 0 && searchQuery === "" && filteredApps && filteredApps.length > 0) {
            entries = filteredApps;
        }

        if (entries.length === 0)
            return;

        var list = [];
        var favorites = ["kitty", "zen", "firefox", "obsidian", "discord", "code", "antigravity", "spotify", "dolphin"];
        var used = {};

        for (var f = 0; f < favorites.length; f++) {
            var fav = favorites[f];
            for (var i = 0; i < entries.length; i++) {
                if (used[i])
                    continue;
                var app = entries[i];
                var name = (app.name || "").toLowerCase();
                var id = (app.id || "").toLowerCase();
                var exec = (app.execString || "").toLowerCase();
                if (name.indexOf(fav) !== -1 || id.indexOf(fav) !== -1 || exec.indexOf(fav) !== -1) {
                    list.push(app);
                    used[i] = true;
                    break;
                }
            }
        }

        for (var j = 0; j < entries.length && list.length < 9; j++) {
            if (!used[j]) {
                list.push(entries[j]);
                used[j] = true;
            }
        }

        if (list.length > 0)
            fixedHotbarApps = list;
    }

    onFilteredAppsChanged: {
        if (searchQuery === "")
            updateFixedHotbar();
    }

    Component.onCompleted: {
        updateFixedHotbar();
    }

    onSearchQueryChanged: {
        scrollRow = 0;
    }
    anchors.fill: parent

    // 🔤 MINECRAFT PIXEL FONT LOADER
    FontLoader {
        id: mcFont

        source: Qt.resolvedUrl("../../../../assets/fonts/Minecraft.ttf")
    }

    // 🌑 FULLSCREEN BACKDROP DIMMER & CLICK-OUTSIDE-TO-CLOSE
    Rectangle {
        id: backdropDim

        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        opacity: styleRoot.isOpen ? 1 : 0

        MouseArea {
            anchors.fill: parent
            onClicked: {
                styleRoot.requestClose();
            }
        }

        Behavior on opacity {
            NumberAnimation {
                duration: 160
                easing.type: Easing.OutCubic
            }

        }

    }

    // ⛏️ INVENTORY BASE GUI IMAGE
    Image {
        id: inventoryBg

        readonly property real imageAspect: (sourceSize.width > 0 && sourceSize.height > 0) ? (sourceSize.width / sourceSize.height) : (195 / 164)
        // Fixed pixel-perfect 4x integer scaling (780 x 656) centered on screen
        readonly property real baseWidth: Math.min(780, parent.width - 40)
        readonly property real scaleRatio: baseWidth / 195
        readonly property real mainBoxTop: 28 * scaleRatio

        anchors.centerIn: parent
        width: baseWidth
        height: width / imageAspect
        source: Qt.resolvedUrl("../../../../assets/image/inventory.png")
        fillMode: Image.Stretch
        smooth: false
        scale: styleRoot.isOpen ? 1 : 0.75
        opacity: styleRoot.isOpen ? 1 : 0
        transformOrigin: Item.Center

        // Absorb mouse clicks inside the GUI box so clicking on gray borders doesn't close it
        MouseArea {
            anchors.fill: parent
        }

        // 🏷️ "Search Apps" LABEL (Pixel Font in Minecraft GUI dark gray)
        Text {
            id: searchLabel

            x: 8 * inventoryBg.scaleRatio
            y: inventoryBg.mainBoxTop + 6.5 * inventoryBg.scaleRatio
            text: "Search Apps"
            color: "#404040"
            renderType: Text.NativeRendering

            font {
                family: mcFont.name
                pixelSize: Math.round(8 * inventoryBg.scaleRatio)
            }

        }

        // 🔍 MINECRAFT SEARCH TEXT INPUT (Inside the top-right dark inset box)
        Item {
            id: searchBoxArea

            x: 76 * inventoryBg.scaleRatio
            y: inventoryBg.mainBoxTop + 3.9 * inventoryBg.scaleRatio
            width: 90 * inventoryBg.scaleRatio
            height: 12 * inventoryBg.scaleRatio

            TextInput {
                // Text {
                //     anchors.fill: parent
                //     verticalAlignment: Text.AlignVCenter
                //     text: ""
                //     color: "#808080"
                //     visible: searchInput.text === "" && !searchInput.inputMethodComposing
                //     renderType: Text.NativeRendering
                //     font {
                //         family: mcFont.name
                //         pixelSize: Math.round(6.5 * inventoryBg.scaleRatio)
                //     }
                // }

                id: searchInput

                anchors.fill: parent
                anchors.leftMargin: 2 * inventoryBg.scaleRatio
                anchors.rightMargin: 2 * inventoryBg.scaleRatio
                color: "#ffffff"
                clip: true
                focus: true
                verticalAlignment: TextInput.AlignVCenter
                renderType: Text.NativeRendering
                onTextChanged: {
                    styleRoot.searchTextChanged(text);
                }
                Keys.onPressed: (event) => {
                    if (styleRoot.keyHandler)
                        styleRoot.keyHandler(event);

                }

                font {
                    family: mcFont.name
                    pixelSize: Math.round(6.5 * inventoryBg.scaleRatio)
                }

            }

        }

        // 📦 MAIN 9x5 CREATIVE INVENTORY GRID AREA
        Item {
            id: mainGridArea

            x: 8 * inventoryBg.scaleRatio
            y: inventoryBg.mainBoxTop + 17 * inventoryBg.scaleRatio
            width: 9 * 18 * inventoryBg.scaleRatio
            height: 5 * 18 * inventoryBg.scaleRatio

            // 🖱️ Mouse wheel scrolling over inventory grid
            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.NoButton
                onWheel: (wheel) => {
                    if (wheel.angleDelta.y < 0)
                        styleRoot.scrollRow = Math.min(styleRoot.maxScrollRow, styleRoot.scrollRow + 1);
                    else if (wheel.angleDelta.y > 0)
                        styleRoot.scrollRow = Math.max(0, styleRoot.scrollRow - 1);
                }
            }

            // 45 Slot Item Grid
            Repeater {
                model: 45

                Item {
                    id: slotItem

                    required property int index
                    readonly property int col: slotItem.index % 9
                    readonly property int row: Math.floor(slotItem.index / 9)
                    readonly property int globalAppIndex: (styleRoot.scrollRow + slotItem.row) * 9 + slotItem.col
                    readonly property var appData: (globalAppIndex >= 0 && globalAppIndex < styleRoot.filteredApps.length) ? styleRoot.filteredApps[globalAppIndex] : null
                    readonly property bool isSelected: styleRoot.selectedIndex === globalAppIndex
                    readonly property bool isSlotHovered: slotMouseArea.containsMouse

                    x: col * 18 * inventoryBg.scaleRatio
                    y: row * 18 * inventoryBg.scaleRatio
                    width: 18 * inventoryBg.scaleRatio
                    height: 18 * inventoryBg.scaleRatio

                    // ✨ Inner 16x16 Slot Container (Centered inside 18x18 bordered slot)
                    Item {
                        id: slotInner

                        anchors.centerIn: parent
                        width: 16 * inventoryBg.scaleRatio
                        height: 16 * inventoryBg.scaleRatio

                        // ✨ Minecraft Classic White Slot Highlight on Hover/Select
                        Rectangle {
                            anchors.fill: parent
                            color: slotItem.isSelected ? Qt.rgba(1, 1, 1, 0.45) : (slotItem.isSlotHovered ? Qt.rgba(1, 1, 1, 0.3) : "transparent")
                            border.color: slotItem.isSelected ? "#ffffff" : "transparent"
                            border.width: slotItem.isSelected ? 1 : 0
                            visible: slotItem.appData !== null && (slotItem.isSelected || slotItem.isSlotHovered)
                        }

                        // 🖼️ Application Icon in Slot (Perfectly Centered)
                        IconImage {
                            id: appIcon

                            anchors.centerIn: parent
                            width: 14 * inventoryBg.scaleRatio
                            height: 14 * inventoryBg.scaleRatio
                            source: (styleRoot.iconSourceCallback && slotItem.appData) ? styleRoot.iconSourceCallback(slotItem.appData.icon) : ""
                            visible: slotItem.appData !== null && status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰀉"
                            color: slotItem.isSelected ? Theme.accent : "#ffffff"
                            visible: slotItem.appData !== null && appIcon.status !== Image.Ready
                            font.family: Theme.fontMono
                            font.pixelSize: Math.round(14 * inventoryBg.scaleRatio)
                        }

                    }

                    MouseArea {
                        id: slotMouseArea

                        anchors.fill: parent
                        hoverEnabled: slotItem.appData !== null
                        cursorShape: slotItem.appData !== null ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onEntered: {
                            if (slotItem.appData) {
                                styleRoot.hoveredApp = slotItem.appData;
                                styleRoot.appHovered(slotItem.globalAppIndex);
                                var screenPt = mapToItem(styleRoot, slotMouseArea.mouseX, slotMouseArea.mouseY);
                                styleRoot.mouseHoverX = screenPt.x;
                                styleRoot.mouseHoverY = screenPt.y;
                            }
                        }
                        onPositionChanged: (mouse) => {
                            if (slotItem.appData) {
                                var screenPt = mapToItem(styleRoot, mouse.x, mouse.y);
                                styleRoot.mouseHoverX = screenPt.x;
                                styleRoot.mouseHoverY = screenPt.y;
                            }
                        }
                        onExited: {
                            if (styleRoot.hoveredApp === slotItem.appData)
                                styleRoot.hoveredApp = null;

                        }
                        onClicked: {
                            if (slotItem.appData)
                                styleRoot.appClicked(slotItem.globalAppIndex);

                        }
                    }

                }

            }

        }

        // 📜 VERTICAL SCROLLBAR TRACK & THUMB
        Item {
            id: scrollTrack

            readonly property real thumbHeight: 15 * inventoryBg.scaleRatio
            readonly property real availableTravel: height - thumbHeight
            readonly property real thumbY: styleRoot.maxScrollRow > 0 ? (styleRoot.scrollRow / styleRoot.maxScrollRow) * availableTravel : 0

            x: 177 * inventoryBg.scaleRatio
            y: inventoryBg.mainBoxTop + 18 * inventoryBg.scaleRatio
            width: 12 * inventoryBg.scaleRatio
            height: 5 * 18 * inventoryBg.scaleRatio

            // Track click to jump
            MouseArea {
                anchors.fill: parent
                onClicked: (mouse) => {
                    if (scrollTrack.availableTravel > 0) {
                        var ratio = Math.max(0, Math.min(1, (mouse.y - scrollTrack.thumbHeight / 2) / scrollTrack.availableTravel));
                        styleRoot.scrollRow = Math.round(ratio * styleRoot.maxScrollRow);
                    }
                }
            }

            // 🖱️ Draggable Scroll Thumb
            Image {
                id: scrollThumb

                x: -8
                y: scrollTrack.thumbY
                width: 12 * inventoryBg.scaleRatio
                height: 15 * inventoryBg.scaleRatio
                source: Qt.resolvedUrl("../../../../assets/image/scroll-button.png")
                smooth: false
                opacity: styleRoot.maxScrollRow > 0 ? 1 : 0.45

                MouseArea {
                    id: thumbDragArea

                    anchors.fill: parent
                    cursorShape: styleRoot.maxScrollRow > 0 ? Qt.PointingHandCursor : Qt.ArrowCursor
                    drag.target: scrollThumb
                    drag.axis: Drag.YAxis
                    drag.minimumY: 0
                    drag.maximumY: scrollTrack.availableTravel
                    onPositionChanged: {
                        if (drag.active && scrollTrack.availableTravel > 0) {
                            var ratio = scrollThumb.y / scrollTrack.availableTravel;
                            styleRoot.scrollRow = Math.max(0, Math.min(styleRoot.maxScrollRow, Math.round(ratio * styleRoot.maxScrollRow)));
                        }
                    }
                }

                Behavior on y {
                    enabled: !thumbDragArea.drag.active

                    NumberAnimation {
                        duration: 80
                        easing.type: Easing.OutCubic
                    }

                }

            }

        }

        // 🗡️ BOTTOM HOTBAR (1x9 PINNED APPS ROW)
        Item {
            id: hotbarArea

            function getHotbarApp(idx) {
                if (styleRoot.fixedHotbarApps && idx < styleRoot.fixedHotbarApps.length)
                    return styleRoot.fixedHotbarApps[idx];

                return null;
            }

            x: 8 * inventoryBg.scaleRatio
            y: inventoryBg.mainBoxTop + 111.5 * inventoryBg.scaleRatio
            width: 9 * 18 * inventoryBg.scaleRatio
            height: 18 * inventoryBg.scaleRatio

            Repeater {
                model: 9

                Item {
                    id: hotbarSlot

                    required property int index
                    readonly property var appData: hotbarArea.getHotbarApp(hotbarSlot.index)
                    readonly property bool isHovered: hotbarMouseArea.containsMouse

                    x: hotbarSlot.index * 18 * inventoryBg.scaleRatio
                    y: 0
                    width: 18 * inventoryBg.scaleRatio
                    height: 18 * inventoryBg.scaleRatio

                    // ✨ Inner 16x16 Hotbar Container (Centered inside 18x18 bordered slot)
                    Item {
                        id: hotbarInner

                        anchors.centerIn: parent
                        width: 16 * inventoryBg.scaleRatio
                        height: 16 * inventoryBg.scaleRatio

                        // ✨ Minecraft White Slot Highlight (Hanya saat kursor mouse hover di slot hotbar ini)
                        Rectangle {
                            anchors.fill: parent
                            color: hotbarSlot.isHovered ? Qt.rgba(1, 1, 1, 0.45) : "transparent"
                            border.color: hotbarSlot.isHovered ? "#ffffff" : "transparent"
                            border.width: hotbarSlot.isHovered ? 1 : 0
                            visible: hotbarSlot.appData !== null && hotbarSlot.isHovered
                        }

                        IconImage {
                            id: hotbarIcon

                            anchors.centerIn: parent
                            width: 14 * inventoryBg.scaleRatio
                            height: 14 * inventoryBg.scaleRatio
                            source: (styleRoot.iconSourceCallback && hotbarSlot.appData) ? styleRoot.iconSourceCallback(hotbarSlot.appData.icon) : ""
                            visible: hotbarSlot.appData !== null && status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰀉"
                            color: hotbarSlot.isHovered ? Theme.accent : "#ffffff"
                            visible: hotbarSlot.appData !== null && hotbarIcon.status !== Image.Ready
                            font.family: Theme.fontMono
                            font.pixelSize: Math.round(14 * inventoryBg.scaleRatio)
                        }

                    }

                    MouseArea {
                        id: hotbarMouseArea

                        anchors.fill: parent
                        hoverEnabled: hotbarSlot.appData !== null
                        cursorShape: hotbarSlot.appData !== null ? Qt.PointingHandCursor : Qt.ArrowCursor
                        onEntered: {
                            if (hotbarSlot.appData) {
                                styleRoot.hoveredApp = hotbarSlot.appData;
                                var screenPt = mapToItem(styleRoot, hotbarMouseArea.mouseX, hotbarMouseArea.mouseY);
                                styleRoot.mouseHoverX = screenPt.x;
                                styleRoot.mouseHoverY = screenPt.y;
                            }
                        }
                        onPositionChanged: (mouse) => {
                            if (hotbarSlot.appData) {
                                var screenPt = mapToItem(styleRoot, mouse.x, mouse.y);
                                styleRoot.mouseHoverX = screenPt.x;
                                styleRoot.mouseHoverY = screenPt.y;
                            }
                        }
                        onExited: {
                            if (styleRoot.hoveredApp === hotbarSlot.appData)
                                styleRoot.hoveredApp = null;

                        }
                        onClicked: {
                            if (hotbarSlot.appData) {
                                if (typeof hotbarSlot.appData.execute === "function") {
                                    hotbarSlot.appData.execute();
                                    styleRoot.requestClose();
                                } else {
                                    for (var k = 0; k < styleRoot.filteredApps.length; k++) {
                                        if (styleRoot.filteredApps[k] === hotbarSlot.appData) {
                                            styleRoot.appClicked(k);
                                            return ;
                                        }
                                    }
                                }
                            }
                        }
                    }

                }

            }

        }

        // 🔍 EMPTY SEARCH STATE MESSAGE
        Text {
            anchors.centerIn: mainGridArea
            text: "No Items Found"
            color: "#808080"
            visible: styleRoot.filteredApps.length === 0
            renderType: Text.NativeRendering

            font {
                family: mcFont.name
                pixelSize: Math.round(12 * inventoryBg.scaleRatio)
            }

        }

        Behavior on scale {
            NumberAnimation {
                duration: 180
                easing.type: Easing.OutBack
            }

        }

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }

        }

    }

    // 💬 CLASSIC MINECRAFT ITEM TOOLTIP (FULLSCREEN AWARE - WILL NEVER BE CUT OFF)
    Rectangle {
        id: mcTooltip

        visible: styleRoot.hoveredApp !== null && styleRoot.isOpen
        z: 9999
        width: tooltipLayout.implicitWidth + 24
        height: tooltipLayout.implicitHeight + 16
        color: "#f0100010"
        border.color: "#28007f"
        border.width: 2
        radius: 2
        // Smart positioning: clamp within screen bounds with comfortable margins
        x: {
            var targetX = styleRoot.mouseHoverX + 16;
            if (targetX + width > styleRoot.width - 16)
                targetX = styleRoot.mouseHoverX - width - 16;

            return Math.max(16, Math.min(styleRoot.width - width - 16, targetX));
        }
        y: {
            var targetY = styleRoot.mouseHoverY - height - 12;
            if (targetY < 16)
                targetY = styleRoot.mouseHoverY + 24;

            return Math.max(16, Math.min(styleRoot.height - height - 16, targetY));
        }

        // Outer subtle purple border for authentic Minecraft tooltip frame
        Rectangle {
            anchors.fill: parent
            anchors.margins: -2
            color: "transparent"
            border.color: "#5000ff"
            border.width: 2
            radius: 3
            z: -1
        }

        ColumnLayout {
            id: tooltipLayout

            anchors.centerIn: parent
            spacing: 4

            Text {
                text: styleRoot.hoveredApp ? (styleRoot.hoveredApp.name || "") : ""
                color: "#ffffff"
                renderType: Text.NativeRendering

                font {
                    family: mcFont.name
                    pixelSize: 18
                }

            }

            Text {
                text: styleRoot.hoveredApp ? (styleRoot.hoveredApp.comment || styleRoot.hoveredApp.genericName || "") : ""
                visible: text !== ""
                color: "#aaaaaa"
                renderType: Text.NativeRendering

                font {
                    family: mcFont.name
                    pixelSize: 14
                }

            }

        }

    }

}
