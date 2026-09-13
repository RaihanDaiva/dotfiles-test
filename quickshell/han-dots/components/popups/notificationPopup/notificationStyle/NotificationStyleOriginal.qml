import "../../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🔔 NOTIFICATION POPUP STYLE: ORIGINAL (Floating Stacked Dark Glass Cards)
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

    // 📦 VERTICAL STACK COLUMN FOR TOAST CARDS
    ColumnLayout {
        id: notifColumn

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: 8

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
                implicitHeight: Math.max(84, notifContentRow.implicitHeight + 20)
                radius: 14
                color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.96)
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                border.width: 1
                // 🌟 ANIMASI TRANSLASI SLIDE (IN: Kanan -> Kiri | OUT: Kiri -> Kanan)
                opacity: isClosing ? 0 : 1

                // ⏱️ Auto-dismiss timer per card (5s default)
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
                                visible: appIconImg.status !== Image.Ready

                                font {
                                    family: Theme.fontMono
                                    pixelSize: 20
                                    bold: true
                                }

                            }

                            // Image Icon (If path or system icon provided)
                            Image {
                                id: appIconImg

                                anchors.fill: parent
                                anchors.margins: 3
                                source: styleRoot.resolveIcon(itemData.iconPath, itemData.appName)
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

                                font {
                                    family: Theme.fontMono
                                    pixelSize: 8
                                }

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
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            maximumLineCount: 1

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                        // Summary / Title Text
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

                        // Body / Message Text
                        Text {
                            text: itemData.body || ""
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.85)
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

                            font {
                                family: Theme.fontMono
                                pixelSize: 13
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

                    }

                }

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

            }

        }

    }

}
