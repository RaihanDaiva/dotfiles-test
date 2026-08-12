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

    // 🚀 Application Launcher Popup (Triggered via quickshell ipc call applauncher toggle)
    AppLauncherPopup {
        id: appLauncherPopup
    }

    // 📡 Native Notification Server DBus Daemon (org.freedesktop.Notifications)
    NotificationServer {
        id: notifServer 
        onNotification: (notif) => {
            notifPopup.showNotification(notif)
        }
    }
}
