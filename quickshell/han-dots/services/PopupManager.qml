pragma Singleton
import QtQuick

// 🪟 CENTRAL POPUP MANAGER SINGLETON (Ensures mutually exclusive popups across all status bar widgets)
QtObject {
    id: manager

    property var activePopup: null

    function requestOpen(targetPopup) {
        if (!targetPopup) return

        // If another popup is currently open, close it first!
        if (activePopup && activePopup !== targetPopup) {
            activePopup.isOpen = false
        }

        activePopup = targetPopup
    }

    function notifyClosed(targetPopup) {
        if (activePopup === targetPopup) {
            activePopup = null
        }
    }
}
