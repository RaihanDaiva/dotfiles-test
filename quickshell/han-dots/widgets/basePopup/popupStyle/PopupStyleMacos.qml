import "../../../services"
import "../../../theme"
import QtQuick
import QtQuick.Effects
import Quickshell

// 🪟 MACOS POPUP STYLE (Zero Background Rectangle / Frameless Transparent)
Item {
    id: styleRoot

    property real cardRadius: SettingsStore.popupRadius
    property int borderWidth: 0
    property bool enableBlur: SettingsStore.enableBlur
    property real popupOpacity: 0
    property real marginLeft: 0
    property real marginTop: 0
    property real screenWidth: 1920
    property real screenHeight: 1080

    // 🚫 Seluruh background rectangle dihilangkan (100% transparan / tanpa efek feathered edge)
    opacity: 0
    visible: false
}
