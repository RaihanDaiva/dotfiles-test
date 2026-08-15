pragma Singleton
import QtQuick

// 📡 CENTRAL NOTIFICATION STORE SINGLETON
QtObject {
    id: store

    property var notifList: []

    function addNotification(notif) {
        if (!notif) return

        var s = (notif.summary !== undefined && notif.summary !== "") ? notif.summary : ((notif.appName !== undefined && notif.appName !== "") ? notif.appName : "Notification")
        var b = (notif.body !== undefined) ? notif.body : ""
        var a = (notif.appName !== undefined && notif.appName !== "") ? notif.appName : "System"
        var i = (notif.appIcon !== undefined && notif.appIcon !== "") ? notif.appIcon : ((notif.image !== undefined && notif.image !== "") ? notif.image : (notif.icon !== undefined ? notif.icon : ""))

        var now = new Date()
        var timeStr = now.getHours().toString().padStart(2, '0') + ":" + now.getMinutes().toString().padStart(2, '0')

        var item = {
            key: Date.now() + "_" + Math.floor(Math.random() * 10000),
            summary: s,
            body: b,
            appName: a,
            iconPath: i,
            time: timeStr,
            notifObj: notif
        }

        notifList = [item].concat(notifList)
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

    function clearAll() {
        for (var idx = 0; idx < notifList.length; idx++) {
            var item = notifList[idx]
            if (item.notifObj && typeof item.notifObj.dismiss === "function") {
                item.notifObj.dismiss()
            }
        }
        notifList = []
    }
}
