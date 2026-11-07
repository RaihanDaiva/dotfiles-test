import "../../../services"
import "../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ⛵ APPLICATION DOCK STYLE: ORIGINAL (Rounded Glass Dock Card)
Item {
    id: dockStyleRoot

    property var dockItems: []
    property var dockScope: null
    readonly property real cardHeight: 64

    signal appClicked(var appData)
    signal appHovered(real iconCenterX, string name)
    signal appExited()
    signal checkRevealRequested()

    implicitWidth: dockCard.width
    implicitHeight: cardHeight

    Rectangle {
        id: dockCard

        anchors.fill: parent
        radius: 22
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.dockBlurEnabled ? 0.35 : SettingsStore.barOpacity)
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, SettingsStore.dockBlurEnabled ? 0.25 : 0.3)
        border.width: 1

        HoverHandler {
            id: dockCardHover

            onHoveredChanged: dockStyleRoot.checkRevealRequested()
        }

        RowLayout {
            id: dockRow

            anchors.centerIn: parent
            spacing: 5

            Repeater {
                model: dockStyleRoot.dockItems

                Item {
                    id: dockItem

                    property var appData: modelData

                    implicitWidth: 58
                    implicitHeight: 58

                    Item {
                        id: iconContainer

                        anchors.fill: parent
                        scale: itemHover.hovered ? 1.22 : 1

                        Image {
                            anchors.centerIn: parent
                            source: dockItem.appData.icon ? (dockItem.appData.icon.indexOf("/") !== -1 ? "file://" + dockItem.appData.icon : "image://icon/" + dockItem.appData.icon) : "image://icon/application-x-executable"
                            width: 48
                            height: 48
                            fillMode: Image.PreserveAspectFit
                            smooth: true
                            mipmap: true
                            sourceSize: Qt.size(64, 64)
                        }

                        // 🔴 TITIK / PIL INDIKATOR INSTANCE WINDOW TERBUKA
                        RowLayout {
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            spacing: 3
                            visible: dockItem.appData.isOpen

                            Repeater {
                                model: (dockItem.appData.wins && dockItem.appData.wins.length > 0) ? dockItem.appData.wins : (dockItem.appData.isOpen ? [dockItem.appData.primaryWin] : [])

                                Rectangle {
                                    id: dotIndicator

                                    property bool isWinFocused: modelData ? (modelData.is_focused || modelData.is_active) : false

                                    width: isWinFocused ? 16 : 4
                                    height: 4
                                    radius: 2
                                    color: isWinFocused ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.45)

                                    Behavior on width {
                                        NumberAnimation {
                                            duration: 180
                                            easing.type: Easing.OutCubic
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

                        HoverHandler {
                            id: itemHover

                            onHoveredChanged: {
                                if (hovered) {
                                    var localPos = iconContainer.mapToItem(null, 0, 0);
                                    dockStyleRoot.appHovered(localPos.x + iconContainer.width / 2, dockItem.appData.name);
                                } else {
                                    dockStyleRoot.appExited();
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                dockStyleRoot.appClicked(dockItem.appData);
                            }
                        }

                        Behavior on scale {
                            NumberAnimation {
                                duration: 180
                                easing.type: Easing.OutCubic
                            }

                        }

                    }

                }

            }

        }

    }

}
