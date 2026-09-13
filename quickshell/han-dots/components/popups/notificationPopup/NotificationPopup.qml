import "../../../services"
import "../../../theme"
import "./notificationStyle"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// 🔔 MULTI-TOAST STACKED NOTIFICATION POPUP OVERLAY (DYNAMIC ORIGINAL VS MACOS STYLE)
PanelWindow {
    id: notifPopup

    // 🎯 PUBLIC PROPERTIES & LIST MODEL FOR STACKED NOTIFICATIONS
    property var notifList: []

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
            var proc = Qt.createQmlObject('import Quickshell.Io; Process{}', notifPopup);
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

    function showNotification(notif) {
        if (!notif)
            return ;

        var s = (notif.summary !== undefined && notif.summary !== "") ? notif.summary : ((notif.appName !== undefined && notif.appName !== "") ? notif.appName : "Notification");
        var b = (notif.body !== undefined) ? notif.body : "";
        var a = (notif.appName !== undefined && notif.appName !== "") ? notif.appName : "System";
        var i = (notif.appIcon !== undefined && notif.appIcon !== "") ? notif.appIcon : ((notif.image !== undefined && notif.image !== "") ? notif.image : (notif.icon !== undefined ? notif.icon : ""));
        var item = {
            "key": Date.now() + "_" + Math.floor(Math.random() * 10000),
            "summary": s,
            "body": b,
            "appName": a,
            "iconPath": i,
            "notifObj": notif
        };
        // Prepend new notification to front of array (Row 1 at top, max 4 toasts)
        var list = [item].concat(notifList.slice(0, 3));
        notifList = list;
    }

    function showTestNotification(title, msg, app) {
        var item = {
            "key": Date.now() + "_" + Math.floor(Math.random() * 10000),
            "summary": title || "Test Notification",
            "body": msg || "Works with any layer-shell compatible Wayland compositor!",
            "appName": app || "Quickshell",
            "iconPath": "",
            "notifObj": {
                "dismiss": function() {
                }
            }
        };
        var list = [item].concat(notifList.slice(0, 3));
        notifList = list;
    }

    function removeNotificationByKey(targetKey) {
        var list = [];
        for (var idx = 0; idx < notifList.length; idx++) {
            var item = notifList[idx];
            if (item.key !== targetKey) {
                list.push(item);
            } else {
                if (item.notifObj && typeof item.notifObj.dismiss === "function")
                    item.notifObj.dismiss();

            }
        }
        notifList = list;
    }

    exclusionMode: ExclusionMode.Ignore
    // 🏷️ Wayland LayerShell Configuration (Top-Right Overlay)
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    implicitWidth: 380
    implicitHeight: Math.max(0, (styleLoader.item && styleLoader.item.implicitHeight > 0) ? styleLoader.item.implicitHeight : 0)
    color: "transparent"
    visible: notifList.length > 0

    anchors {
        top: true
        right: true
    }

    margins {
        top: 54
        right: 15
    }

    // 🔄 DYNAMIC STYLE LOADER (Original vs macOS)
    Loader {
        id: styleLoader

        anchors.top: parent.top
        anchors.right: parent.right
        width: parent.width
        source: (SettingsStore.popupStyle === "macos") ? Qt.resolvedUrl("./notificationStyle/NotificationStyleMacos.qml") : Qt.resolvedUrl("./notificationStyle/NotificationStyleOriginal.qml")
        onLoaded: {
            if (item) {
                item.notifList = Qt.binding(function() {
                    return notifPopup.notifList;
                });
                item.getIconSourceCallback = notifPopup.getIconSource;
                item.notificationActivated.connect(function(itemData) {
                    notifPopup.activateNotification(itemData);
                });
                item.notificationDismissed.connect(function(key) {
                    notifPopup.removeNotificationByKey(key);
                });
            }
        }
    }

}
