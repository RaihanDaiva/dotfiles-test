import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"

// 🔔 NOTIFICATION POPUP OVERLAY CARD (Top-Right Floating Overlay with Hyprland Blur & Pywal Styling)
PanelWindow {
    id: notifPopup

    // 🎯 PUBLIC PROPERTIES & METHODS
    property bool isOpen: false
    property var currentNotif: null
    property string summaryText: currentNotif ? (currentNotif.summary || "Notification") : ""
    property string bodyText: currentNotif ? (currentNotif.body || "") : ""
    property string appNameText: currentNotif ? (currentNotif.appName || "System") : "System"
    property string iconPath: currentNotif ? (currentNotif.appIcon || currentNotif.image || "") : ""

    // 🏷️ Wayland LayerShell Configuration (Top-Right Overlay)
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        top: true
        right: true
    }
    margins {
        top: 52
        right: 15
    }

    implicitWidth: 360
    implicitHeight: Math.max(76, mainLayout.implicitHeight + 24)
    color: "transparent"

    visible: isOpen || notifCard.opacity > 0

    // ⏱️ Auto-dismiss timer (5s default)
    Timer {
        id: autoDismissTimer
        interval: 5000
        running: notifPopup.isOpen && !cardHover.hovered
        onTriggered: dismissCurrent()
    }

    function showNotification(notif) {
        currentNotif = notif
        notifPopup.isOpen = true
        autoDismissTimer.restart()
    }

    function showTestNotification(title, msg, app) {
        currentNotif = {
            summary: title || "Cool Notification",
            body: msg || "Works with any layer-shell compatible Wayland compositor!",
            appName: app || "Quickshell",
            appIcon: "",
            image: "",
            dismiss: function() {}
        }
        notifPopup.isOpen = true
        autoDismissTimer.restart()
    }

    function dismissCurrent() {
        notifPopup.isOpen = false
        if (currentNotif && typeof currentNotif.dismiss === "function") {
            currentNotif.dismiss()
        }
    }

    // 📦 NOTIFICATION CARD CONTAINER RECTANGLE
    Rectangle {
        id: notifCard
        anchors.fill: parent
        radius: 14
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.85)
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1

        opacity: notifPopup.isOpen ? 1.0 : 0.0
        transform: Translate {
            x: notifPopup.isOpen ? 0 : 40
            Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        }

        Behavior on opacity { NumberAnimation { duration: 180; easing.type: Easing.OutCubic } }

        HoverHandler { id: cardHover }

        RowLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.margins: 14
            spacing: 14

            // 🎨 LEFT CIRCULAR AVATAR / APP ICON WITH BADGE
            Item {
                implicitWidth: 44
                implicitHeight: 44
                Layout.alignment: Qt.AlignTop

                // Primary Icon Circle
                Rectangle {
                    id: iconCircle
                    anchors.fill: parent
                    radius: 22
                    color: Theme.accent
                    clip: true

                    // Text Fallback (Nerd Font Icon / Initial)
                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -1
                        text: {
                            var app = notifPopup.appNameText.toLowerCase()
                            if (app.indexOf("spotify") !== -1) return "󰓇"
                            if (app.indexOf("firefox") !== -1) return "󰈹"
                            if (app.indexOf("discord") !== -1) return "󰙯"
                            if (app.indexOf("terminal") !== -1 || app.indexOf("kitty") !== -1) return "󰞷"
                            return "󰂚"
                        }
                        color: Theme.bgDark
                        font { family: Theme.fontMono; pixelSize: 22; bold: true }
                        visible: appIconImg.status !== Image.Ready
                    }

                    // Image Icon (If path provided)
                    Image {
                        id: appIconImg
                        anchors.fill: parent
                        source: notifPopup.iconPath
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        visible: status === Image.Ready
                    }
                }

                // Small Badge at Bottom Right of Circle
                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
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
                        font { family: Theme.fontMono; pixelSize: 9 }
                    }
                }
            }

            // 📝 RIGHT TEXT CONTENT COLUMN (Summary & Body)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                spacing: 3

                // Summary / Title Text
                Text {
                    text: notifPopup.summaryText
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 14; bold: true }
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                    maximumLineCount: 1
                }

                // Body / Message Text
                Text {
                    text: notifPopup.bodyText
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.8)
                    font { family: Theme.fontMain; pixelSize: 12 }
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    maximumLineCount: 3
                    elide: Text.ElideRight
                    visible: notifPopup.bodyText !== ""
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
                    onClicked: notifPopup.dismissCurrent()
                }
            }
        }
    }
}
