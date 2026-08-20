import "../../../services"
import "../../../theme"
import "../../../widgets"
import "../../../widgets/styledButton"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// ⚙️ SETTINGS & POPUP CUSTOMIZER (STANDALONE DRAGGABLE FLOATING WINDOW)
PanelWindow {
    // Nanti di uncomment
    // Component.onCompleted: {
    //     if (Quickshell.screens && Quickshell.screens.length > 0) {
    //         posX = Math.max(10, Math.round(Quickshell.screens[0].width / 2 - implicitWidth / 2));
    //         posY = Math.max(10, Math.round(Quickshell.screens[0].height / 2 - implicitHeight / 2));
    //     }
    // }

    id: settingsPopup

    // property bool isOpen: SettingsStore.settingsPopupOpen
    property bool isOpen: true
    property string activeTab: "popups"
    // 📍 DRAGGABLE FLOATING POSITION PROPERTIES
    property real posX: 1200
    property real posY: 150

    exclusionMode: ExclusionMode.Ignore
    onIsOpenChanged: {
        if (SettingsStore._isLoaded && SettingsStore.settingsPopupOpen !== isOpen)
            SettingsStore.settingsPopupOpen = isOpen;

    }
    width: implicitWidth
    height: implicitHeight
    implicitWidth: 580
    implicitHeight: 480
    // 🏷️ Wayland LayerShell Configuration (Overlay Layer)
    WlrLayershell.namespace: "quickshell:settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    anchors.top: true
    anchors.left: true
    margins.left: Math.round(posX)
    margins.top: Math.round(posY)
    color: "transparent"
    visible: isOpen

    Rectangle {
        id: settingsCard

        anchors.fill: parent
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.popupOpacity)
        radius: SettingsStore.popupRadius

        // 🖼️ BORDER OVERLAY (z: 9999)
        Rectangle {
            anchors.fill: parent
            radius: settingsCard.radius
            color: "transparent"
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5)
            border.width: SettingsStore.popupBorderWidth
            z: 9999
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 14

            // 🏷️ HEADER TITLE & DRAGGABLE HANDLE
            Rectangle {
                id: headerHandle

                Layout.fillWidth: true
                implicitHeight: 38
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.08)
                radius: 10
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    spacing: 8

                    Text {
                        text: "󰒓"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 18
                        }

                    }

                    Text {
                        text: "Elements Customizer"
                        color: Theme.textMain

                        font {
                            family: Theme.fontMain
                            pixelSize: 15
                            bold: true
                        }

                    }

                    Text {
                        text: "(Drag Header to Move)"
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5)

                        font {
                            family: Theme.fontMain
                            pixelSize: 11
                        }

                    }

                    Item {
                        Layout.fillWidth: true
                    }

                    // Close button
                    Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        radius: 12
                        color: closeHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "✖"
                            color: Theme.textMain
                            font.pixelSize: 12
                        }

                        HoverHandler {
                            id: closeHover
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: settingsPopup.isOpen = false
                        }

                    }

                }

                // 🖱️ MOUSEAREA UNTUK DRAG POPUP
                MouseArea {
                    id: dragArea

                    property real startMouseX: 0
                    property real startMouseY: 0
                    property real startPosX: 0
                    property real startPosY: 0

                    anchors.fill: parent
                    anchors.rightMargin: 36
                    cursorShape: Qt.SizeAllCursor
                    onPressed: (mouse) => {
                        startMouseX = mouse.x;
                        startMouseY = mouse.y;
                        startPosX = settingsPopup.posX;
                        startPosY = settingsPopup.posY;
                    }
                    onPositionChanged: (mouse) => {
                        if (pressed) {
                            var deltaX = mouse.x - startMouseX;
                            var deltaY = mouse.y - startMouseY;
                            var maxW = (Quickshell.screens && Quickshell.screens.length > 0) ? Quickshell.screens[0].width : 1920;
                            var maxH = (Quickshell.screens && Quickshell.screens.length > 0) ? Quickshell.screens[0].height : 1080;
                            settingsPopup.posX = Math.max(10, Math.min(maxW - settingsPopup.implicitWidth - 10, startPosX + deltaX));
                            settingsPopup.posY = Math.max(10, Math.min(maxH - settingsPopup.implicitHeight - 10, startPosY + deltaY));
                        }
                    }
                }
   
            }

            // 🔀 SIDEBAR + CONTENT CONTAINER
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 12

                // 📑 LEFT SIDEBAR PANEL
                Rectangle {
                    id: sidebar

                    implicitWidth: 140
                    Layout.fillHeight: true
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.03)
                    radius: 12
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                    border.width: 1

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 6

                        Text {
                            text: "SETTINGS"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                            Layout.leftMargin: 6
                            Layout.topMargin: 4
                            Layout.bottomMargin: 2

                            font {
                                family: Theme.fontMain
                                pixelSize: 10
                                bold: true
                            }

                        }

                        // 🪟 Popups Tab Button
                        StyledButton {
                            text: "Popups"
                            iconText: "󰖯"
                            Layout.fillWidth: true
                            implicitHeight: 36
                            selected: settingsPopup.activeTab === "popups"
                            onClicked: settingsPopup.activeTab = "popups"
                        }
 
                        // 🔘 Buttons Tab Button
                        StyledButton {
                            text: "Buttons"
                            iconText: "󰓠"
                            Layout.fillWidth: true
                            implicitHeight: 36
                            selected: settingsPopup.activeTab === "buttons"
                            onClicked: settingsPopup.activeTab = "buttons"
                        }

                        Item {
                            Layout.fillHeight: true
                        }

                    }

                }

                // 📜 CATEGORY CONTENT AREA (RIGHT SIDE) — Loaded dynamically per tab
                Loader {
                    id: categoryLoader

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    source: Qt.resolvedUrl("./category/" + (settingsPopup.activeTab === "buttons" ? "ButtonsCategory.qml" : "PopupsCategory.qml"))
                }

            }

        }

    }

    mask: Region {
        item: settingsCard
    }

}
