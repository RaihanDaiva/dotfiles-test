import "../../../services"
import "../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ⛏️ APPLICATION DOCK STYLE: MINECRAFT HOTBAR (HUD Hotbar Texture with Sliding Selector)
Item {
    id: dockStyleRoot

    property var dockItems: []
    property var dockScope: null
    readonly property real scaleRatio: 3
    readonly property real cardHeight: 22 * scaleRatio
    readonly property bool containsMouse: dockCardHover.hovered
    // 🔄 Dynamic list of only currently open applications
    readonly property var openApps: {
        var list = [];
        for (var i = 0; i < dockItems.length; i++) {
            var item = dockItems[i];
            if (item && item.isOpen)
                list.push(item);

        }
        return list;
    }
    // 🖥️ 9 visible slots in the Minecraft Hotbar (supporting smart window scrolling if > 9 open apps)
    readonly property var visibleApps: {
        if (openApps.length <= 9)
            return openApps;

        var focIdx = -1;
        for (var i = 0; i < openApps.length; i++) {
            if (openApps[i].isFocused) {
                focIdx = i;
                break;
            }
        }
        if (focIdx < 9)
            return openApps.slice(0, 9);

        var start = Math.min(focIdx - 8, openApps.length - 9);
        return openApps.slice(start, start + 9);
    }
    property int hoveredIndex: -1
    readonly property int focusedIndex: {
        for (var i = 0; i < visibleApps.length && i < 9; i++) {
            if (visibleApps[i] && visibleApps[i].isFocused)
                return i;

        }
        return -1;
    }
    readonly property int activeSlotIndex: {
        if (hoveredIndex >= 0 && hoveredIndex < 9)
            return hoveredIndex;

        if (focusedIndex >= 0 && focusedIndex < 9)
            return focusedIndex;

        return 0;
    }

    signal appClicked(var appData)
    signal appHovered(real iconCenterX, string name)
    signal appExited()
    signal checkRevealRequested()

    implicitWidth: 182 * scaleRatio
    implicitHeight: cardHeight

    // ⛏️ HOTBAR BASE GUI (Pixel-perfect 182x22 Texture Scaled at Integer 3x)
    Image {
        id: hotbarBg

        anchors.fill: parent
        source: Qt.resolvedUrl("../../../assets/image/Hotbar.png")
        fillMode: Image.Stretch
        smooth: false

        HoverHandler {
            id: dockCardHover

            onHoveredChanged: dockStyleRoot.checkRevealRequested()
        }

    }

    // 🎯 MINECRAFT HOTBAR SELECTOR (24x24 pixel texture, overlaps active slot by 2px on all sides)
    Image {
        id: selectorImg

        source: Qt.resolvedUrl("../../../assets/image/Hotbar_selector.png")
        smooth: false
        width: 24 * dockStyleRoot.scaleRatio
        height: 24 * dockStyleRoot.scaleRatio
        x: (dockStyleRoot.activeSlotIndex * 20 - 1) * dockStyleRoot.scaleRatio
        y: -1 * dockStyleRoot.scaleRatio
        z: 10
        visible: dockStyleRoot.openApps.length > 0 || dockStyleRoot.hoveredIndex >= 0

        Behavior on x {
            NumberAnimation {
                duration: 120
                easing.type: Easing.OutCubic
            }

        }

    }

    // 📦 DOCK SLOTS CONTAINER (9 slots, each 20px wide at 3x scale)
    Item {
        id: slotsContainer

        x: 1 * dockStyleRoot.scaleRatio
        y: 0
        width: 9 * 20 * dockStyleRoot.scaleRatio
        height: dockStyleRoot.cardHeight

        Repeater {
            model: 9

            Item {
                id: slotItem

                required property int index
                readonly property var appData: (index < dockStyleRoot.visibleApps.length) ? dockStyleRoot.visibleApps[index] : null
                readonly property bool hasApp: appData !== null

                x: slotItem.index * 20 * dockStyleRoot.scaleRatio
                y: 0
                width: 20 * dockStyleRoot.scaleRatio
                height: 22 * dockStyleRoot.scaleRatio

                // ✨ Inner 16x16 Slot Area
                Item {
                    id: slotInner

                    anchors.centerIn: parent
                    width: 16 * dockStyleRoot.scaleRatio
                    height: 16 * dockStyleRoot.scaleRatio

                    Image {
                        id: appIcon

                        anchors.centerIn: parent
                        width: 42
                        height: 42
                        fillMode: Image.PreserveAspectFit
                        source: slotItem.hasApp && slotItem.appData && slotItem.appData.icon ? (slotItem.appData.icon.indexOf("/") !== -1 ? "file://" + slotItem.appData.icon : "image://icon/" + slotItem.appData.icon) : ""
                        smooth: true
                        mipmap: true
                        sourceSize: Qt.size(64, 64)
                        scale: slotHoverArea.containsMouse ? 1.08 : 1
                        visible: slotItem.hasApp

                        Behavior on scale {
                            NumberAnimation {
                                duration: 140
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                    // 🟩 MINECRAFT EXPERIENCE GREEN PIXEL DOTS FOR RUNNING APPS
                    RowLayout {
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 2 * dockStyleRoot.scaleRatio
                        anchors.horizontalCenter: parent.horizontalCenter
                        spacing: 2 * dockStyleRoot.scaleRatio
                        visible: slotItem.hasApp

                        Repeater {
                            model: (slotItem.hasApp && slotItem.appData && slotItem.appData.wins && slotItem.appData.wins.length > 0) ? slotItem.appData.wins : (slotItem.hasApp ? [slotItem.appData.primaryWin] : [])

                            Rectangle {
                                required property var modelData
                                readonly property bool isWinFocused: modelData ? (modelData.is_focused || modelData.is_active) : false

                                width: isWinFocused ? (4 * dockStyleRoot.scaleRatio) : (1.3 * dockStyleRoot.scaleRatio)
                                height: 1.3 * dockStyleRoot.scaleRatio
                                color: isWinFocused ? "#55ff55" : "#2e8f2e"
                            }

                        }

                    }

                }

                MouseArea {
                    id: slotHoverArea

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: slotItem.hasApp ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onEntered: {
                        dockStyleRoot.hoveredIndex = slotItem.index;
                        if (slotItem.hasApp && slotItem.appData) {
                            var localPos = mapToItem(dockStyleRoot, 0, 0);
                            dockStyleRoot.appHovered(localPos.x + width / 2, slotItem.appData.name || "");
                        } else {
                            dockStyleRoot.appExited();
                        }
                    }
                    onExited: {
                        if (dockStyleRoot.hoveredIndex === slotItem.index)
                            dockStyleRoot.hoveredIndex = -1;

                        dockStyleRoot.appExited();
                    }
                    onClicked: {
                        if (slotItem.hasApp && slotItem.appData)
                            dockStyleRoot.appClicked(slotItem.appData);

                    }
                }

            }

        }

    }

}
