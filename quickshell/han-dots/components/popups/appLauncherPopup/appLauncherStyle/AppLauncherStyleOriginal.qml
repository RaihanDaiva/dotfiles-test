import "../../../../services"
import "../../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Widgets

// 🚀 APPLICATION LAUNCHER STYLE: ORIGINAL (Solid Rounded Glass Card with Border)
Rectangle {
    id: styleRoot

    property var filteredApps: []
    property int selectedIndex: 0
    property string searchQuery: ""
    property var iconSourceCallback: null
    property bool isOpen: false

    signal appClicked(int index)
    signal appHovered(int index)
    signal searchTextChanged(string text)
    signal upPressed()
    signal downPressed()
    signal returnPressed()
    signal escapePressed()

    function focusInput() {
        searchInput.forceActiveFocus();
    }

    function resetInput() {
        searchInput.text = "";
    }

    function positionVisible(index) {
        if (appListView.count > index && index >= 0)
            appListView.positionViewAtIndex(index, ListView.Contain);

    }

    function positionTop() {
        if (appListView.count > 0)
            appListView.positionViewAtBeginning();

    }

    anchors.fill: parent
    radius: 20
    color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.96)
    border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
    border.width: 1

    ColumnLayout {
        id: mainLayout

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
            visible: styleRoot.filteredApps.length > 0
            model: styleRoot.filteredApps
            currentIndex: styleRoot.selectedIndex

            delegate: Rectangle {
                id: appDelegate

                property bool isHovered: itemHover.hovered
                property bool isSelected: styleRoot.selectedIndex === index || isHovered

                width: appListView.width
                implicitHeight: 52
                radius: 12
                color: isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"
                border.color: isSelected ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : "transparent"
                border.width: 1

                HoverHandler {
                    id: itemHover

                    onHoveredChanged: {
                        if (hovered)
                            styleRoot.appHovered(index);

                    }
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        styleRoot.appClicked(index);
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
                            source: styleRoot.iconSourceCallback ? styleRoot.iconSourceCallback(modelData.icon) : ""
                            visible: status === Image.Ready
                        }

                        Text {
                            anchors.centerIn: parent
                            text: "󰀉"
                            color: Theme.accent
                            visible: appIcon.status !== Image.Ready

                            font {
                                family: Theme.fontMono
                                pixelSize: 20
                            }

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
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1

                            font {
                                family: Theme.fontMain
                                pixelSize: 14
                                bold: true
                            }

                        }

                        Text {
                            text: modelData.comment || modelData.genericName || modelData.execString || ""
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.65)
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            visible: text !== ""

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                            }

                        }

                    }

                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

        // 📭 EMPTY STATE PLACEHOLDER (when search yields no results)
        Item {
            id: emptyPlaceholder

            Layout.fillWidth: true
            Layout.preferredHeight: 52
            implicitHeight: 52
            visible: styleRoot.filteredApps.length === 0 && styleRoot.searchQuery !== ""

            RowLayout {
                anchors.centerIn: parent
                spacing: 8

                Text {
                    text: "󰅖"
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)

                    font {
                        family: Theme.fontMono
                        pixelSize: 16
                    }

                }

                Text {
                    text: "No applications found"
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5)

                    font {
                        family: Theme.fontMain
                        pixelSize: 13
                    }

                }

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
                    Keys.onUpPressed: styleRoot.upPressed()
                    Keys.onDownPressed: styleRoot.downPressed()
                    Keys.onReturnPressed: styleRoot.returnPressed()
                    Keys.onEscapePressed: styleRoot.escapePressed()

                    font {
                        family: Theme.fontMain
                        pixelSize: 14
                    }

                    Text {
                        text: "Search Apps"
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                        visible: searchInput.text === "" && !searchInput.inputMethodComposing

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                        }

                    }

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
