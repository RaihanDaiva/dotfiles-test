import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"

// 🔔 MULTI-TOAST STACKED NOTIFICATION POPUP OVERLAY CARD (Top-Right Floating Overlay with Hyprland Blur & Pywal Styling)
PanelWindow {
    id: notifPopup

    exclusionMode: ExclusionMode.Ignore

    // 🎯 PUBLIC PROPERTIES & LIST MODEL FOR STACKED NOTIFICATIONS
    property var notifList: []

    function getIconSource(icon, appName) {
        var target = (icon && icon !== "") ? icon : (appName ? appName.toLowerCase() : "")
        if (!target || target === "") return ""
        if (target.indexOf("file://") === 0 || target.indexOf("image://") === 0) return target
        if (target.indexOf("/") === 0) return "file://" + target
        return "image://icon/" + target
    }

    // 🏷️ Wayland LayerShell Configuration (Top-Right Overlay)
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
    }
    margins {
        top: 54
        right: 15
    }

    implicitWidth: 380
    implicitHeight: Math.max(0, notifColumn.implicitHeight)
    color: "transparent"

    visible: notifList.length > 0

    function showNotification(notif) {
        if (!notif) return

        var s = (notif.summary !== undefined && notif.summary !== "") ? notif.summary : ((notif.appName !== undefined && notif.appName !== "") ? notif.appName : "Notification")
        var b = (notif.body !== undefined) ? notif.body : ""
        var a = (notif.appName !== undefined && notif.appName !== "") ? notif.appName : "System"
        var i = (notif.appIcon !== undefined && notif.appIcon !== "") ? notif.appIcon : ((notif.image !== undefined && notif.image !== "") ? notif.image : (notif.icon !== undefined ? notif.icon : ""))

        var item = {
            key: Date.now() + "_" + Math.floor(Math.random() * 10000),
            summary: s,
            body: b,
            appName: a,
            iconPath: i,
            notifObj: notif
        }

        // Prepend new notification to front of array (Row 1 at top)
        var list = [item].concat(notifList.slice(0, 3)) // Keep max 4 toasts stacked
        notifList = list
    }

    function showTestNotification(title, msg, app) {
        var item = {
            key: Date.now() + "_" + Math.floor(Math.random() * 10000),
            summary: title || "Test Notification",
            body: msg || "Works with any layer-shell compatible Wayland compositor!",
            appName: app || "Quickshell",
            iconPath: "",
            notifObj: { dismiss: function() {} }
        }
        var list = [item].concat(notifList.slice(0, 3))
        notifList = list
    }

    function removeNotificationByKey(targetKey) {
        var list = []
        for (var idx = 0; idx < notifList.length; idx++) {
            var item = notifList[idx]
            if (item.key !== targetKey) {
                list.push(item)
            } else {
                if (item.notifObj && typeof item.notifObj.dismiss === "function") {
                    item.notifObj.dismiss()
                }
            }
        }
        notifList = list
    }

    // 📦 VERTICAL STACK COLUMN FOR TOAST CARDS
    ColumnLayout {
        id: notifColumn
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8

        Repeater {
            model: notifPopup.notifList

            delegate: Rectangle {
                id: notifCard
                Layout.fillWidth: true
                implicitHeight: Math.max(84, notifContentRow.implicitHeight + 20)
                radius: 14
                color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.5)
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                border.width: 1

                property var itemData: modelData
                property bool isClosing: false

                // 🌟 ANIMASI TRANSLASI SLIDE (IN: Kanan -> Kiri | OUT: Kiri -> Kanan)
                opacity: isClosing ? 0.0 : 1.0

                transform: Translate {
                    id: translateTransform
                    x: notifCard.isClosing ? 400 : 0

                    Behavior on x {
                        NumberAnimation {
                            duration: notifCard.isClosing ? 220 : 280
                            easing.type: notifCard.isClosing ? Easing.InQuad : Easing.OutCubic
                        }
                    }
                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: notifCard.isClosing ? 200 : 250
                        easing.type: notifCard.isClosing ? Easing.InQuad : Easing.OutCubic
                    }
                }

                // ⏱️ Auto-dismiss timer per card (5s default)
                Timer {
                    interval: 5000
                    running: !cardHover.hovered && !notifCard.isClosing
                    onTriggered: startCloseAnimation()
                }

                Timer {
                    id: removeTimer
                    interval: 230
                    onTriggered: notifPopup.removeNotificationByKey(itemData.key)
                }

                function startCloseAnimation() {
                    notifCard.isClosing = true
                    removeTimer.start()
                }

                HoverHandler { id: cardHover }

                RowLayout {
                    id: notifContentRow
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.margins: 12
                    spacing: 12

                    // 🎨 LEFT CIRCULAR AVATAR / APP ICON WITH BADGE
                    Item {
                        implicitWidth: 42
                        implicitHeight: 42
                        Layout.alignment: Qt.AlignVCenter

                        // Primary Icon Circle
                        Rectangle {
                            id: iconCircle
                            anchors.fill: parent
                            radius: 21
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                            border.color: Theme.accent
                            border.width: 1
                            clip: true

                            // Text Fallback (Nerd Font Icon / Initial)
                            Text {
                                anchors.centerIn: parent
                                text: {
                                    var app = (itemData.appName || "").toLowerCase()
                                    if (app.indexOf("spotify") !== -1) return "󰓇"
                                    if (app.indexOf("firefox") !== -1) return "󰈹"
                                    if (app.indexOf("discord") !== -1 || app.indexOf("vesktop") !== -1) return "󰙯"
                                    if (app.indexOf("terminal") !== -1 || app.indexOf("kitty") !== -1) return "󰞷"
                                    return "󰂚"
                                }
                                color: Theme.accent
                                font { family: Theme.fontMono; pixelSize: 20; bold: true }
                                visible: appIconImg.status !== Image.Ready
                            }

                            // Image Icon (If path or system icon provided)
                            Image {
                                id: appIconImg
                                anchors.fill: parent
                                anchors.margins: 3
                                source: notifPopup.getIconSource(itemData.iconPath, itemData.appName)
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: status === Image.Ready
                            }
                        }

                        // Small Badge at Bottom Right of Circle
                        Rectangle {
                            width: 15
                            height: 15
                            radius: 7.5
                            color: Theme.bgDark
                            border.color: Theme.accent
                            border.width: 1
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.rightMargin: -2
                            anchors.bottomMargin: -2

                            Text {
                                anchors.centerIn: parent
                                text: "󰅍"
                                color: Theme.accent
                                font { family: Theme.fontMono; pixelSize: 8 }
                            }
                        }
                    }

                    // 📝 RIGHT TEXT CONTENT COLUMN (App Name, Summary & Body)
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 2

                        // Header: App Name
                        Text {
                            text: itemData.appName || "Notification"
                            color: Theme.accent
                            font { family: Theme.fontMain; pixelSize: 11; bold: true }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                        }

                        // Summary / Title Text
                        Text {
                            text: itemData.summary || ""
                            color: Theme.textMain
                            font { family: Theme.fontMain; pixelSize: 13; bold: true }
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1
                            visible: itemData.summary !== ""
                        }

                        // Body / Message Text
                        Text {
                            text: itemData.body || ""
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.85)
                            font { family: Theme.fontMain; pixelSize: 12 }
                            Layout.fillWidth: true
                            wrapMode: Text.Wrap
                            maximumLineCount: 3
                            elide: Text.ElideRight
                            visible: itemData.body !== ""
                        }
                    }

                    // ✖️ CLOSE / DISMISS BUTTON
                    Rectangle {
                        implicitWidth: 22
                        implicitHeight: 22
                        radius: 11
                        color: closeHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2) : "transparent"
                        Layout.alignment: Qt.AlignTop

                        Text {
                            anchors.centerIn: parent
                            text: "󰅖"
                            color: closeHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5)
                            font { family: Theme.fontMono; pixelSize: 13 }
                        }

                        HoverHandler { id: closeHover }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: notifCard.startCloseAnimation()
                        }
                    }
                }
            }
        }
    }
}
