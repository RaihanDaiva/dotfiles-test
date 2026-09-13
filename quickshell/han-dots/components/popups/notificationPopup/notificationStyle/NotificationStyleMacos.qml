import "../../../../services"
import "../../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🔔 NOTIFICATION POPUP STYLE: MACOS (Frosted Glass Floating Card with Header Bar, Squircle Icon, and Action Pills)
Item {
    id: styleRoot

    property var notifList: []
    property var getIconSourceCallback: null

    signal notificationActivated(var itemData)
    signal notificationDismissed(string key)

    function resolveIcon(icon, appName) {
        if (typeof getIconSourceCallback === "function")
            return getIconSourceCallback(icon, appName);

        var target = (icon && icon !== "") ? icon : (appName ? appName.toLowerCase() : "");
        if (!target || target === "")
            return "";

        if (target.indexOf("file://") === 0 || target.indexOf("image://") === 0)
            return target;

        if (target.indexOf("/") === 0)
            return "file://" + target;

        return "image://icon/" + target;
    }

    implicitWidth: 380
    implicitHeight: notifColumn.implicitHeight

    // 📦 VERTICAL STACK COLUMN FOR MACOS TOAST CARDS
    ColumnLayout {
        id: notifColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 10

        Repeater {
            model: styleRoot.notifList

            delegate: Rectangle {
                id: notifCard

                property var itemData: modelData
                property bool isClosing: false

                function startCloseAnimation() {
                    notifCard.isClosing = true;
                    removeTimer.start();
                }

                Layout.fillWidth: true
                implicitHeight: cardContentCol.implicitHeight + 24
                radius: 20
                // 🌫️ Translucent Frosted Glass Background
                color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, Math.min(0.88, (SettingsStore.popupOpacity || 0.72) + 0.12))
                border.color: cardHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12)
                border.width: 1
                // 🌟 ANIMATION TRANSLATE & FADE
                opacity: isClosing ? 0 : 1

                // ⏱️ Auto-dismiss timer per card (5s default, pauses on hover)
                Timer {
                    interval: 5000
                    running: !cardHover.hovered && !notifCard.isClosing
                    onTriggered: notifCard.startCloseAnimation()
                }

                Timer {
                    id: removeTimer

                    interval: 230
                    onTriggered: styleRoot.notificationDismissed(itemData.key)
                }

                HoverHandler {
                    id: cardHover
                }

                // 🖱️ CLICK TOAST CARD TO REDIRECT TO APP
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        styleRoot.notificationActivated(itemData);
                        notifCard.startCloseAnimation();
                    }
                }

                ColumnLayout {
                    id: cardContentCol

                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 8

                    // 🏷️ 1. TOP HEADER BAR (macOS App Header + Timestamp + Close Button)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 7

                        // Mini Squircle App Icon
                        Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 5
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                            border.width: 1
                            clip: true

                            Image {
                                id: miniAppIconImg

                                anchors.fill: parent
                                anchors.margins: 2
                                source: styleRoot.resolveIcon(itemData.iconPath, itemData.appName)
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    var app = (itemData.appName || "").toLowerCase();
                                    if (app.indexOf("spotify") !== -1)
                                        return "󰓇";

                                    if (app.indexOf("firefox") !== -1)
                                        return "󰈹";

                                    if (app.indexOf("discord") !== -1 || app.indexOf("vesktop") !== -1)
                                        return "󰙯";

                                    if (app.indexOf("terminal") !== -1 || app.indexOf("kitty") !== -1)
                                        return "󰞷";

                                    return "󰂚";
                                }
                                color: Theme.accent
                                visible: miniAppIconImg.status !== Image.Ready

                                font {
                                    family: Theme.fontMono
                                    pixelSize: 12
                                }

                            }

                        }

                        // App Name
                        Text {
                            text: itemData.appName || "Notification"
                            color: Theme.textMain
                            opacity: 0.85
                            elide: Text.ElideRight

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                        // Bullet separator
                        Text {
                            text: "•"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)

                            font {
                                pixelSize: 10
                            }

                        }

                        // Time / "now"
                        Text {
                            text: "now"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.45)

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        // Frosted Circle Close Button
                        Rectangle {
                            implicitWidth: 20
                            implicitHeight: 20
                            radius: 10
                            color: closeHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.2) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                            border.color: closeHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3) : "transparent"
                            border.width: 1

                            Text {
                                anchors.centerIn: parent
                                text: "󰅖"
                                color: closeHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)

                                font {
                                    family: Theme.fontMono
                                    pixelSize: 11
                                }

                            }

                            HoverHandler {
                                id: closeHover
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: notifCard.startCloseAnimation()
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                    }

                    // 📝 2. MAIN CONTENT ROW (Large Squircle Avatar + Title & Body)
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 12

                        // Left Large Squircle Avatar
                        Rectangle {
                            implicitWidth: 38
                            implicitHeight: 38
                            radius: 12
                            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
                            border.width: 1
                            clip: true
                            Layout.alignment: Qt.AlignTop

                            Image {
                                id: bodyAppIconImg

                                anchors.fill: parent
                                anchors.margins: 4
                                source: styleRoot.resolveIcon(itemData.iconPath, itemData.appName)
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                visible: status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                text: {
                                    var app = (itemData.appName || "").toLowerCase();
                                    if (app.indexOf("spotify") !== -1)
                                        return "󰓇";

                                    if (app.indexOf("firefox") !== -1)
                                        return "󰈹";

                                    if (app.indexOf("discord") !== -1 || app.indexOf("vesktop") !== -1)
                                        return "󰙯";

                                    if (app.indexOf("terminal") !== -1 || app.indexOf("kitty") !== -1)
                                        return "󰞷";

                                    return "󰂚";
                                }
                                color: Theme.accent
                                visible: bodyAppIconImg.status !== Image.Ready

                                font {
                                    family: Theme.fontMono
                                    pixelSize: 18
                                    bold: true
                                }

                            }

                        }

                        // Right Text Column (Title & Message)
                        ColumnLayout {
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            spacing: 3

                            // Title
                            Text {
                                text: itemData.summary || ""
                                color: Theme.textMain
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                maximumLineCount: 1
                                visible: itemData.summary !== ""

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            // Body
                            Text {
                                text: itemData.body || ""
                                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.8)
                                Layout.fillWidth: true
                                wrapMode: Text.Wrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                visible: itemData.body !== ""

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 12
                                }

                            }

                        }

                    }

                    // 🔘 3. BOTTOM ACTION PILL ROW
                    RowLayout {
                        Layout.fillWidth: true
                        visible: cardHover.hovered

                        Item {
                            Layout.fillWidth: true
                        }

                        Rectangle {
                            id: openPill

                            implicitHeight: 22
                            implicitWidth: openRow.implicitWidth + 16
                            radius: 11
                            color: openHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                            border.color: openHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                            border.width: 1

                            RowLayout {
                                id: openRow

                                anchors.centerIn: parent
                                spacing: 4

                                Text {
                                    text: "Open"
                                    color: openHover.hovered ? (Theme.isDarkMode ? Theme.bgDark : "#ffffff") : Theme.textMain

                                    font {
                                        family: Theme.fontMain
                                        pixelSize: 10
                                        bold: true
                                    }

                                }

                                Text {
                                    text: "󰅂"
                                    color: openHover.hovered ? (Theme.isDarkMode ? Theme.bgDark : "#ffffff") : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5)

                                    font {
                                        family: Theme.fontMono
                                        pixelSize: 10
                                    }

                                }

                            }

                            HoverHandler {
                                id: openHover
                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    styleRoot.notificationActivated(itemData);
                                    notifCard.startCloseAnimation();
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

                transform: Translate {
                    id: translateTransform

                    x: notifCard.isClosing ? 420 : 0

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

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

    }

}
