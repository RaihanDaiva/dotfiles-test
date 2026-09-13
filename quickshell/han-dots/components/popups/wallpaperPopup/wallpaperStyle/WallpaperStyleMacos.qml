import "../../../../services"
import "../../../../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🖼️ WALLPAPER SELECTOR STYLE: MACOS (Frameless Floating Card with Per-Wallpaper Capsule Badges & Pill Search Bar)
Item {
    id: styleRoot

    property var filteredWallpapers: []
    property int selectedIndex: 0
    property string searchQuery: ""
    property string activeWallpaperPath: ""
    property bool isOpen: false

    signal wallpaperClicked(int index)
    signal wallpaperHovered(int index)
    signal searchTextChanged(string text)
    signal leftPressed()
    signal rightPressed()
    signal returnPressed()
    signal escapePressed()

    function focusInput() {
        searchInput.forceActiveFocus();
        searchInput.cursorPosition = searchInput.text.length;
    }

    function resetInput() {
        searchInput.text = "";
    }

    function positionCenter(index) {
        if (wallListView.count > index && index >= 0)
            wallListView.positionViewAtIndex(index, ListView.Center);

    }

    anchors.fill: parent

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
            clip: false
            spacing: 18
            snapMode: ListView.SnapToItem
            highlightRangeMode: ListView.NoHighlightRange
            model: styleRoot.filteredWallpapers

            delegate: Item {
                id: wallDelegate

                property bool isHovered: itemHover.hovered
                property bool isSelected: styleRoot.selectedIndex === index || isHovered

                implicitWidth: 170
                implicitHeight: wallListView.height

                ColumnLayout {
                    anchors.centerIn: parent
                    width: parent.width
                    spacing: 8

                    // 🖼️ Outer Border Rectangle (Handles Scale & Crisp Accent Border)
                    Rectangle {
                        id: outerBorderRect

                        Layout.fillWidth: true
                        implicitHeight: 110
                        radius: 16
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                        border.color: wallDelegate.isSelected ? Theme.accent : (wallDelegate.isHovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.24) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1))
                        border.width: wallDelegate.isSelected ? 2 : 1
                        scale: wallDelegate.isSelected ? 1.08 : 1

                        Item {
                            anchors.fill: parent
                            anchors.margins: wallDelegate.isSelected ? 2 : 1
                            layer.enabled: true

                            Image {
                                id: wallpaperImg

                                anchors.fill: parent
                                source: "file://" + modelData.path
                                fillMode: Image.PreserveAspectCrop
                                smooth: true
                                mipmap: true
                                sourceSize: Qt.size(340, 220)
                                asynchronous: true
                            }

                            layer.effect: OpacityMask {

                                maskSource: Rectangle {
                                    width: outerBorderRect.width - (wallDelegate.isSelected ? 4 : 2)
                                    height: outerBorderRect.height - (wallDelegate.isSelected ? 4 : 2)
                                    radius: 14
                                }

                            }

                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }

                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                    // 🏷️ MACOS CAPSULE BADGE BELOW THUMBNAIL (Never bare text, always readable frosted pill)
                    Rectangle {
                        id: titleCapsule

                        Layout.alignment: Qt.AlignHCenter
                        implicitHeight: 26
                        implicitWidth: Math.min(170, titleRow.implicitWidth + 24)
                        radius: height / 2
                        color: wallDelegate.isSelected ? Theme.accent : (wallDelegate.isHovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.14) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06))
                        border.color: wallDelegate.isSelected ? Theme.accent : (wallDelegate.isHovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.24) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1))
                        border.width: 1

                        RowLayout {
                            id: titleRow

                            anchors.centerIn: parent
                            spacing: 6

                            // 🟢 Subtle Dot Indicator if this is the currently applied wallpaper
                            Rectangle {
                                visible: modelData.path === styleRoot.activeWallpaperPath
                                implicitWidth: 6
                                implicitHeight: 6
                                radius: 3
                                color: wallDelegate.isSelected ? (Theme.isDarkMode ? "#ffffff" : Theme.bgDark) : Theme.accent
                            }

                            Text {
                                text: modelData.title || modelData.filename
                                color: wallDelegate.isSelected ? (Theme.isDarkMode ? "#ffffff" : Theme.bgDark) : Theme.textMain
                                elide: Text.ElideRight
                                maximumLineCount: 1

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 11
                                    bold: wallDelegate.isSelected
                                }

                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                        Behavior on border.color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                }

                HoverHandler {
                    id: itemHover

                    onHoveredChanged: {
                        if (hovered)
                            styleRoot.wallpaperHovered(index);

                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        styleRoot.wallpaperClicked(index);
                    }
                }

            }

        }

        // 🔍 BOTTOM SECTION: COMMAND / SEARCH BAR (Full macOS Capsule Pill)
        Rectangle {
            id: searchBarContainer

            Layout.fillWidth: true
            implicitHeight: 44
            radius: height / 2
            color: searchInput.activeFocus ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
            border.color: searchInput.activeFocus ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 16
                anchors.rightMargin: 16
                spacing: 10

                Text {
                    text: "󰍉"
                    color: searchInput.activeFocus ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5)

                    font {
                        family: Theme.fontMono
                        pixelSize: 16
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
                    Keys.onLeftPressed: styleRoot.leftPressed()
                    Keys.onRightPressed: styleRoot.rightPressed()
                    Keys.onReturnPressed: styleRoot.returnPressed()
                    Keys.onEscapePressed: styleRoot.escapePressed()

                    font {
                        family: Theme.fontMain
                        pixelSize: 14
                    }

                    Text {
                        text: "Search Wallpapers"
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                        visible: searchInput.text === "" && !searchInput.inputMethodComposing

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                        }

                    }

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

                        font {
                            family: Theme.fontMono
                            pixelSize: 12
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

            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }

            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

}
