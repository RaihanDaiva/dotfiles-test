import "../../../../services"
import "../../../../theme"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🖼️ WALLPAPER SELECTOR STYLE: ORIGINAL (Solid Rounded Glass Card with Border)
Rectangle {
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
    radius: 24
    color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.96)
    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
    border.width: 1

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

                    Rectangle {
                        id: outerBorderRect

                        Layout.fillWidth: true
                        implicitHeight: 110
                        radius: 14
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                        border.color: wallDelegate.isSelected ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
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
                                    radius: 12
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

                    // Wallpaper Name Text Below Thumbnail
                    Text {
                        text: modelData.title || modelData.filename
                        color: wallDelegate.isSelected ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1

                        font {
                            family: Theme.fontMain
                            pixelSize: 12
                            bold: wallDelegate.isSelected
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

        // 🔍 BOTTOM SECTION: COMMAND / SEARCH BAR
        Rectangle {
            id: searchBarContainer

            Layout.fillWidth: true
            implicitHeight: 44
            radius: 14
            color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.6)
            border.color: searchInput.activeFocus ? Theme.accent : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
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

        }

    }

}
