import "../../services"
import "../../theme"
import "../../widgets"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// 🔔 NOTIFICATION CENTER POPUP (Extending BasePopup)
BasePopup {
    id: notifCenterPopup

    // 🎯 LIST MODEL FROM CENTRAL NOTIFICATION STORE
    readonly property var notifList: NotificationStore.notifList

    function removeNotificationByKey(targetKey) {
        NotificationStore.removeNotificationByKey(targetKey);
    }

    function clearAll() {
        NotificationStore.clearAll();
    }

    function activateNotification(itemData) {
        if (!itemData)
            return ;

        if (itemData.notifObj) {
            try {
                if (typeof itemData.notifObj.invokeAction === "function")
                    itemData.notifObj.invokeAction("default");
                else if (typeof itemData.notifObj.activate === "function")
                    itemData.notifObj.activate();
            } catch (e) {
            }
        }
        var app = (itemData.appName || "").trim();
        var icon = (itemData.iconPath || "").trim().toLowerCase();
        if (app === "" || app.toLowerCase() === "system" || app.toLowerCase() === "notification") {
            if (icon.indexOf("discord") !== -1 || icon.indexOf("vesktop") !== -1)
                app = "discord";
            else if (icon.indexOf("spotify") !== -1)
                app = "spotify";
            else if (icon.indexOf("firefox") !== -1)
                app = "firefox";
            else if (icon.indexOf("zen") !== -1)
                app = "zen";
            else if (icon.indexOf("telegram") !== -1)
                app = "telegram";
            else if (icon.indexOf("whatsapp") !== -1)
                app = "whatsapp";
            else if (icon.indexOf("code") !== -1 || icon.indexOf("vscode") !== -1)
                app = "code";
            else if (icon.indexOf("kitty") !== -1)
                app = "kitty";
        }
        if (app !== "" && app.toLowerCase() !== "system" && app.toLowerCase() !== "quickshell") {
            var safeApp = app.replace(/'/g, "'\\''");
            var cmd = "app='" + safeApp + "'; " + "if [ \"$(echo $app | tr '[:upper:]' '[:lower:]')\" = \"discord\" ] || [ \"$(echo $app | tr '[:upper:]' '[:lower:]')\" = \"vesktop\" ]; then " + "  win_id=$(niri msg -j windows 2>/dev/null | jq -r '.[] | select((.app_id | ascii_downcase | contains(\"discord\")) or (.app_id | ascii_downcase | contains(\"vesktop\")) or (.title | ascii_downcase | contains(\"discord\"))) | .id' | head -n1); " + "else " + "  win_id=$(niri msg -j windows 2>/dev/null | jq -r --arg app \"$app\" '.[] | select((.app_id | ascii_downcase | contains($app | ascii_downcase)) or (.title | ascii_downcase | contains($app | ascii_downcase))) | .id' | head -n1); " + "fi; " + "if [ -n \"$win_id\" ] && [ \"$win_id\" != \"null\" ]; then " + "  niri msg action focus-window --id \"$win_id\"; " + "else " + "  gtk-launch \"$app\" 2>/dev/null || gtk-launch \"$(echo $app | tr '[:upper:]' '[:lower:]')\" 2>/dev/null; " + "fi";
            var proc = Qt.createQmlObject('import Quickshell.Io; Process{}', notifCenterPopup);
            proc.command = ["bash", "-c", cmd];
            proc.running = true;
        }
    }

    function getIconSource(icon, appName) {
        var target = (icon && icon !== "") ? icon : (appName ? appName.toLowerCase() : "");
        if (!target || target === "")
            return "";

        if (target.indexOf("file://") === 0 || target.indexOf("image://") === 0)
            return target;

        if (target.indexOf("/") === 0)
            return "file://" + target;

        return "image://icon/" + target;
    }

    implicitWidth: 360
    implicitHeight: Math.min(520, mainColumn.implicitHeight + 32)

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

            // In macOS mode: Capsule badge
            Rectangle {
                visible: SettingsStore.popupStyle === "macos"
                implicitHeight: 32
                implicitWidth: macosHeaderRow.implicitWidth + 20
                radius: height / 2
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                border.width: 1

                RowLayout {
                    id: macosHeaderRow

                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        text: "󰂚"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 15
                        }

                    }

                    Text {
                        text: "Notification Center"
                        color: Theme.textMain

                        font {
                            family: Theme.fontMain
                            pixelSize: 12
                            bold: true
                        }

                    }

                }

            }

            // In Original mode: Icon and title
            Text {
                visible: SettingsStore.popupStyle !== "macos"
                text: "󰂚"
                color: Theme.accent

                font {
                    family: Theme.fontMono
                    pixelSize: 24
                }

            }

            Text {
                visible: SettingsStore.popupStyle !== "macos"
                text: "Notification Center"
                color: Theme.textMain
                Layout.fillWidth: true

                font {
                    family: Theme.fontMain
                    pixelSize: 16
                    bold: true
                }

            }

            Item {
                visible: SettingsStore.popupStyle === "macos"
                Layout.fillWidth: true
            }

            Rectangle {
                visible: notifCenterPopup.notifList.length > 0
                implicitWidth: badgeText.implicitWidth + 14
                implicitHeight: 22
                radius: 11
                color: (SettingsStore.popupStyle === "macos") ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.2)
                border.color: Theme.accent
                border.width: 1

                Text {
                    id: badgeText

                    anchors.centerIn: parent
                    text: notifCenterPopup.notifList.length.toString()
                    color: Theme.accent

                    font {
                        family: Theme.fontMain
                        pixelSize: 11
                        bold: true
                    }

                }

            }

        }

        // ➖ SEPARATOR LINE (Hidden in macOS mode)
        Rectangle {
            visible: SettingsStore.popupStyle !== "macos"
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

            Item {
                Layout.fillHeight: true
            }

            Text {
                text: "󰂛"
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)
                Layout.alignment: Qt.AlignHCenter

                font {
                    family: Theme.fontMono
                    pixelSize: 36
                }

            }

            Text {
                text: "No Notifications"
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)
                Layout.alignment: Qt.AlignHCenter

                font {
                    family: Theme.fontMain
                    pixelSize: 13
                    bold: true
                }

            }

            Item {
                Layout.fillHeight: true
            }

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

                        property var itemData: modelData

                        Layout.fillWidth: true
                        implicitHeight: Math.max(72, itemContentRow.implicitHeight + 16)
                        radius: (SettingsStore.popupStyle === "macos") ? 16 : 12
                        color: {
                            if (SettingsStore.popupStyle === "macos")
                                return itemHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.05);

                            return Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.6);
                        }
                        border.color: {
                            if (SettingsStore.popupStyle === "macos")
                                return itemHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1);

                            return itemHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08);
                        }
                        border.width: 1

                        HoverHandler {
                            id: itemHover
                        }

                        // 🖱️ CLICK CARD TO REDIRECT TO APP
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                notifCenterPopup.activateNotification(itemData);
                                notifCenterPopup.removeNotificationByKey(itemData.key);
                            }
                        }

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
                                radius: (SettingsStore.popupStyle === "macos") ? 10 : 18
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
                                    visible: itemIconImg.status !== Image.Ready

                                    font {
                                        family: Theme.fontMono
                                        pixelSize: 16
                                    }

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
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight

                                        font {
                                            family: Theme.fontMain
                                            pixelSize: 11
                                            bold: true
                                        }

                                    }

                                    Text {
                                        text: itemData.time || ""
                                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.4)

                                        font {
                                            family: Theme.fontMain
                                            pixelSize: 10
                                        }

                                    }

                                }

                                Text {
                                    text: itemData.summary || ""
                                    color: Theme.textMain
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    visible: itemData.summary !== ""

                                    font {
                                        family: Theme.fontMain
                                        pixelSize: 12
                                        bold: true
                                    }

                                }

                                Text {
                                    text: itemData.body || ""
                                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.8)
                                    Layout.fillWidth: true
                                    wrapMode: Text.Wrap
                                    maximumLineCount: 2
                                    elide: Text.ElideRight
                                    visible: itemData.body !== ""

                                    font {
                                        family: Theme.fontMain
                                        pixelSize: 11
                                    }

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

                                    font {
                                        family: Theme.fontMono
                                        pixelSize: 12
                                    }

                                }

                                HoverHandler {
                                    id: itemCloseHover
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: notifCenterPopup.removeNotificationByKey(itemData.key)
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

        }

        // 4. FOOTER: CLEAR ALL BUTTON (Paling bawah setelah list notifikasi)
        Rectangle {
            id: clearAllBtn

            Layout.fillWidth: true
            implicitHeight: (SettingsStore.popupStyle === "macos") ? 36 : 32
            radius: (SettingsStore.popupStyle === "macos") ? height / 2 : 10
            visible: notifCenterPopup.notifList.length > 0
            color: {
                if (SettingsStore.popupStyle === "macos")
                    return clearHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06);

                return clearHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.1);
            }
            border.color: {
                if (SettingsStore.popupStyle === "macos")
                    return clearHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12);

                return Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4);
            }
            border.width: 1

            HoverHandler {
                id: clearHover
            }

            RowLayout {
                anchors.centerIn: parent
                spacing: 6

                Text {
                    text: "󰎟"
                    color: (SettingsStore.popupStyle === "macos" && clearHover.hovered) ? (Theme.isDarkMode ? Theme.bgDark : "#ffffff") : Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 14
                    }

                }

                Text {
                    text: "Clear All"
                    color: (SettingsStore.popupStyle === "macos" && clearHover.hovered) ? (Theme.isDarkMode ? Theme.bgDark : "#ffffff") : Theme.textMain

                    font {
                        family: Theme.fontMain
                        pixelSize: 12
                        bold: true
                    }

                }

            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: notifCenterPopup.clearAll()
            }

            Behavior on color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

    }

}
