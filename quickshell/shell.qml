import QtQuick
import Quickshell
import Quickshell.Services.Notifications
import "./components/"
import "./components/popups/"
import "./theme/"

Scope {
    // 🔄 Service pemantau warna Pywal di background
    PywalService {}

    // 🖥️ Status Bar Utama
    Bar {} 

    // 🔔 Notification Popup Overlay Card (Menggunakan BasePopup & Pywal Theme)
    NotificationPopup {
        id: notifPopup
    }

    // 🔌 Fullscreen Power Menu Overlay (Triggered by Super + P via quickshell ipc call powermenu toggle)
    PowerMenuOverlay {
        id: powerMenuOverlay
    }

    // ⏱️ Sequenced Popup Opening Timer (Ensures current popup finishes exit animation before new popup slides up)
    Timer {
        id: popupOpenTimer
        interval: 200
        repeat: false
        property var pendingOpenAction: null

        onTriggered: {
            if (pendingOpenAction) {
                pendingOpenAction()
                pendingOpenAction = null
            }
        }
    }

    // 🚀 Application Launcher Popup (Triggered via quickshell ipc call applauncher toggle)
    AppLauncherPopup {
        id: appLauncherPopup
        onRequestOpen: {
            if (wallpaperPopup.isOpen) {
                wallpaperPopup.isOpen = false
                popupOpenTimer.pendingOpenAction = function() { appLauncherPopup.isOpen = true }
                popupOpenTimer.restart()
            } else {
                appLauncherPopup.isOpen = true
            }
        }
    }

    // 🖼️ Wallpaper Selector Popup (Triggered via quickshell ipc call wallpaperselect toggle)
    WallpaperPopup {
        id: wallpaperPopup
        onRequestOpen: {
            if (appLauncherPopup.isOpen) {
                appLauncherPopup.isOpen = false
                popupOpenTimer.pendingOpenAction = function() { wallpaperPopup.isOpen = true }
                popupOpenTimer.restart()
            } else {
                wallpaperPopup.isOpen = true
            }
        }
    }

    // 📡 Native Notification Server DBus Daemon (org.freedesktop.Notifications)
    NotificationServer {
        id: notifServer 
        onNotification: (notif) => {
            notifPopup.showNotification(notif)
        }
    }
}
