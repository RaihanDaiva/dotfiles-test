import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import "../../widgets"
import "../../theme"
import "../../services"

// 🔔 NOTIFICATION CENTER POPUP (Extending BasePopup)
BasePopup {
    id: notifCenterPopup

    implicitWidth: 360
    implicitHeight: Math.min(520, mainColumn.implicitHeight + 32)

    // 🎯 LIST MODEL FROM CENTRAL NOTIFICATION STORE
    readonly property var notifList: NotificationStore.notifList

    function removeNotificationByKey(targetKey) {
        NotificationStore.removeNotificationByKey(targetKey)
    }

    function clearAll() {
        NotificationStore.clearAll()
    }

    function getIconSource(icon, appName) {
        var target = (icon && icon !== "") ? icon : (appName ? appName.toLowerCase() : "")
        if (!target || target === "") return ""
        if (target.indexOf("file://") === 0 || target.indexOf("image://") === 0) return target
        if (target.indexOf("/") === 0) return "file://" + target
        return "image://icon/" + target
    }

    // 📦 MAIN CONTENT COLUMN
    ColumnLayout {
        id: mainColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 12

        // 1. HEADER (Title & Unread Count)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰂚"
                color: Theme.accent
                font { family: Theme.fontMono; pixelSize: 18 }
            }

            Text {
                text: "Notification Center"
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 14; bold: true }
                Layout.fillWidth: true
            }

            Rectangle {
                visible: notifCenterPopup.notifList.length > 0
                implicitWidth: badgeText.implicitWidth + 12
                implicitHeight: 20
                radius: 10
                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                border.color: Theme.accent
                border.width: 1

                Text {
                    id: badgeText
                    anchors.centerIn: parent
                    text: notifCenterPopup.notifList.length.toString()
                    color: Theme.accent
                    font { family: Theme.fontMain; pixelSize: 11; bold: true }
                }
            }
        }

        // ➖ SEPARATOR LINE
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12)
        }

        // 2. EMPTY STATE (When list is empty)
        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 50
            anchors.centerIn: parent
            Layout.preferredHeight: 120
            visible: notifCenterPopup.notifList.length === 0
            spacing: 8

            Item { Layout.fillHeight: true }

            Text {
                text: "󰂛"
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)
                font { family: Theme.fontMono; pixelSize: 36 }
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "No Notifications"
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                font { family: Theme.fontMain; pixelSize: 13; bold: true }
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.fillHeight: true }
        }

        // 3. SCROLLABLE NOTIFICATION LIST (When list has items)
        Flickable {
            id: listFlickable
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(340, listColumn.implicitHeight)
            contentHeight: listColumn.implicitHeight
            clip: true
            visible: notifCenterPopup.notifList.length > 0

            ColumnLayout {
                id: listColumn
                width: listFlickable.width
                spacing: 8

                Repeater {
                    model: notifCenterPopup.notifList

                    delegate: Rectangle {
                        id: itemCard
                        Layout.fillWidth: true
                        implicitHeight: Math.max(72, itemContentRow.implicitHeight + 16)
                        radius: 12
                        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.6)
                        border.color: itemHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                        border.width: 1

                        property var itemData: modelData

                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        HoverHandler { id: itemHover }

                        RowLayout {
                            id: itemContentRow
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.top: parent.top
                            anchors.margins: 10
                            spacing: 10

                            // App Icon
                            Rectangle {
                                implicitWidth: 36
                                implicitHeight: 36
                                radius: 18
                                color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                                border.width: 1
                                Layout.alignment: Qt.AlignTop

                                Image {
                                    id: itemIconImg
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    source: notifCenterPopup.getIconSource(itemData.iconPath, itemData.appName)
                                    fillMode: Image.PreserveAspectFit
                                    smooth: true
                                    visible: status === Image.Ready
                                }

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰂚"
                                    color: Theme.accent
                                    font { family: Theme.fontMono; pixelSize: 16 }
                                    visible: itemIconImg.status !== Image.Ready
                                }
                            }

                            // Text Info
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                RowLayout {
                                    Layout.fillWidth: true

                                    Text {
                                        text: itemData.appName || "System"
                                        color: Theme.accent
                                        font { family: Theme.fontMain; pixelSize: 11; bold: true }
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }

                                    Text {
                                        text: itemData.time || ""
                                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                                        font { family: Theme.fontMain; pixelSize: 10 }
                                    }
                                }

                                Text {
                                    text: itemData.summary || ""
                                    color: Theme.textMain
                                    font { family: Theme.fontMain; pixelSize: 12; bold: true }
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    visible: itemData.summary !== ""
                                }

                                Text {
                                    text: itemData.body || ""
                                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.8)
                                    font { family: Theme.fontMain; pixelSize: 11 }
                                    Layout.fillWidth: true
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    visible: itemData.body !== ""
                                }
                            }

                            // Individual Dismiss Button
                            Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                radius: 10
                                color: itemCloseHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : "transparent"
                                Layout.alignment: Qt.AlignTop

                                Text {
                                    anchors.centerIn: parent
                                    text: "󰅖"
                                    color: itemCloseHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                                    font { family: Theme.fontMono; pixelSize: 12 }
                                }

                                HoverHandler { id: itemCloseHover }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notifCenterPopup.removeNotificationByKey(itemData.key)
                                }
                            }
                        }
                    }
                }
            }
        }

        // 4. FOOTER: CLEAR ALL BUTTON (Paling bawah setelah list notifikasi)
        Rectangle {
            id: clearAllBtn
            Layout.fillWidth: true
            implicitHeight: 32
            radius: 10
            visible: notifCenterPopup.notifList.length > 0
            color: clearHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1)
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4)
            border.width: 1

            Behavior on color { ColorAnimation { duration: 150 } }

            HoverHandler { id: clearHover }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰎟"
                    color: Theme.accent
                    font { family: Theme.fontMono; pixelSize: 14 }
                }

                Text {
                    text: "Clear All"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 12; bold: true }
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: notifCenterPopup.clearAll()
            }
        }
    }
}
