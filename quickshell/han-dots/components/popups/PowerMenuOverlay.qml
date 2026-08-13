import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import "../../theme"

// 🔌 FULL POWER MENU OVERLAY (Slide-up from bottom with Circle-to-Pill Morphing Animation)
PanelWindow {
    id: powerMenuRoot

    exclusionMode: ExclusionMode.Ignore

    property bool isOpen: false
    property int selectedIndex: -1 // -1 means none keyboard-selected (hover active)

    // 🏷️ Wayland LayerShell Configuration
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"

    visible: isOpen || contentCard.opacity > 0

    // ─── SYSTEM ACTION PROCESSES ─────────────────────────────────────────────
    Process { id: shutdownProc; command: ["systemctl", "poweroff"] }
    Process { id: rebootProc; command: ["systemctl", "reboot"] }
    Process { id: suspendProc; command: ["systemctl", "suspend"] }
    Process { id: lockProc; command: ["hyprlock"] }
    Process { id: logoutProc; command: ["hyprctl", "dispatch", "exit"] }

    function executeAction(index) {
        isOpen = false
        if (index === 0) shutdownProc.running = true
        else if (index === 1) rebootProc.running = true
        else if (index === 2) suspendProc.running = true
        else if (index === 3) lockProc.running = true
        else if (index === 4) logoutProc.running = true
    }

    // 📡 QUICKSHELL IPC HANDLER FOR "SUPER + P" SHORTCUT (`qs ipc call powermenu toggle`)
    IpcHandler {
        target: "powermenu"

        function toggle() {
            powerMenuRoot.isOpen = !powerMenuRoot.isOpen
            if (powerMenuRoot.isOpen) powerMenuRoot.selectedIndex = 1 // Default highlight Reboot or none
        }

        function open() {
            powerMenuRoot.isOpen = true
            powerMenuRoot.selectedIndex = 1
        }

        function close() {
            powerMenuRoot.isOpen = false
        }
    }

    // ⌨️ KEYBOARD EVENT LISTENER (Arrow Keys, Enter, Escape)
    Item {
        anchors.fill: parent
        focus: powerMenuRoot.isOpen

        Keys.onEscapePressed: powerMenuRoot.isOpen = false
        Keys.onLeftPressed: {
            if (powerMenuRoot.selectedIndex <= 0) powerMenuRoot.selectedIndex = 4
            else powerMenuRoot.selectedIndex--
        }
        Keys.onRightPressed: {
            if (powerMenuRoot.selectedIndex < 0 || powerMenuRoot.selectedIndex >= 4) powerMenuRoot.selectedIndex = 0
            else powerMenuRoot.selectedIndex++
        }
        Keys.onReturnPressed: {
            if (powerMenuRoot.selectedIndex >= 0) executeAction(powerMenuRoot.selectedIndex)
        }
        Keys.onSpacePressed: {
            if (powerMenuRoot.selectedIndex >= 0) executeAction(powerMenuRoot.selectedIndex)
        }
    }

    // ⬛ DARK BACKDROP OVERLAY
    Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.45)
        opacity: powerMenuRoot.isOpen ? 1.0 : 0.0

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

        MouseArea {
            anchors.fill: parent
            onClicked: powerMenuRoot.isOpen = false
        }
    }

    // 🪟 FLOATING BOTTOM-CENTER CONTAINER CARD WITH SLIDE-UP ANIMATION
    Rectangle {
        id: contentCard
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 60

        implicitWidth: actionsRow.implicitWidth + 36
        implicitHeight: 96
        radius: 48
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.85)
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1

        opacity: powerMenuRoot.isOpen ? 1.0 : 0.0
        transform: Translate {
            y: powerMenuRoot.isOpen ? 0 : 100
            Behavior on y { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }
        }

        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on implicitWidth { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

        // Prevent clicking inside the card from closing backdrop
        MouseArea { anchors.fill: parent }

        // 🔘 HORIZONTAL ROW OF 5 MORPHING POWER ACTION BUTTONS
        RowLayout {
            id: actionsRow
            anchors.centerIn: parent
            spacing: 14

            // MODEL DATA: [icon, label, defaultColor, highlightColor]
            Repeater {
                model: [
                    { icon: "󰐥", label: "Shutdown", color: Theme.accent },
                    { icon: "󰑐", label: "Reboot", color: Theme.accent },
                    { icon: "󰤄", label: "Sleep", color: Theme.accent },
                    { icon: "󰌾", label: "Lock Screen", color: Theme.accent },
                    { icon: "󰍃", label: "Log Out", color: Theme.accent }
                ]

                delegate: Rectangle {
                    id: actionButton
                    property bool isHovered: itemHover.hovered
                    property bool isSelected: powerMenuRoot.selectedIndex === index || isHovered

                    // 📐 MORPHING ANIMATION: CIRCLE (64px) -> HORIZONTAL PILL (180px)
                    implicitWidth: isSelected ? 180 : 64
                    implicitHeight: 64
                    radius: 32

                    color: isSelected ? modelData.color : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                    border.color: isSelected ? modelData.color : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                    border.width: 1

                    Behavior on implicitWidth { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 180 } }

                    HoverHandler {
                        id: itemHover
                        onHoveredChanged: {
                            if (hovered) powerMenuRoot.selectedIndex = index
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: executeAction(index)
                    }

                    // 🎨 CONTENT LAYOUT INSIDE MORPHING BUTTON
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: isSelected ? 20 : 0
                        anchors.rightMargin: isSelected ? 20 : 0
                        spacing: 12

                        // Icon Container (Centered when unselected, Left-aligned when pill)
                        Item {
                            implicitWidth: isSelected ? 24 : 64
                            implicitHeight: 64
                            Layout.alignment: Qt.AlignVCenter

                            Text {
                                anchors.centerIn: parent
                                anchors.horizontalCenterOffset: -1
                                text: modelData.icon
                                color: isSelected ? Theme.bgDark : Theme.textMain
                                font { family: Theme.fontMono; pixelSize: 24; bold: true }

                                Behavior on color { ColorAnimation { duration: 180 } }
                            }
                        }

                        // Label Text (Fades and expands in when Pill)
                        Text {
                            text: modelData.label
                            color: Theme.bgDark
                            font { family: Theme.fontMain; pixelSize: 16; bold: true }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            visible: actionButton.implicitWidth > 100
                            opacity: actionButton.implicitWidth > 120 ? 1.0 : 0.0

                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }
                    }
                }
            }
        }
    }
}
