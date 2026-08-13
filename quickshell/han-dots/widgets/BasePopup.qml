import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../theme"

// 🪟 REUSABLE BASE POPUP SHELL (PanelWindow dengan Hyprland Blur & Smart Clamped Positioning)
PanelWindow {
    id: popupRoot

    exclusionMode: ExclusionMode.Ignore

    // 🎯 PROPERTY REUSABLE
    property var barWindow: null
    property var targetItem: null
    property bool isOpen: false

    // Signals untuk hover timer parent widget
    signal keepOpen()
    signal startCloseTimer()

    // 📦 Default property alias agar children langsung dimasukkan ke dalam container
    default property alias contentData: contentContainer.data
    property alias cardMargins: contentContainer.anchors.margins
    property alias cardRadius: popupCard.radius

    property bool requiresKeyboardFocus: false

    // 🏷️ Namespace & Layer Wayland
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: requiresKeyboardFocus ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    anchors.top: true
    anchors.left: true
    margins.top: 54

    // 📐 Kalkulasi Posisi Dinamis (Smart Auto-Centering & Clamp ke Ujung Bar)
    function updatePosition() {
        if (!targetItem) return
        var barLeft = barWindow ? barWindow.margins.left : 15
        var barWidth = barWindow ? barWindow.width : 1000
        var barTop = barWindow ? barWindow.margins.top : 8
        var barHeight = barWindow ? (barWindow.height > 0 ? barWindow.height : barWindow.implicitHeight) : 40

        var itemX = targetItem.mapToItem(null, 0, 0).x
        var itemWidth = targetItem.width
        var popupWidth = popupRoot.implicitWidth

        // 1. Posisi ideal: Centered tepat di bawah targetItem
        var desiredLeft = barLeft + itemX + (itemWidth / 2) - (popupWidth / 2)

        // 2. Batas Kiri & Kanan (Constraint sejajar dengan ujung bar jika melimpah keluar)
        var minLeft = barLeft
        var maxLeft = (barLeft + barWidth) - popupWidth

        var finalLeft = Math.max(minLeft, Math.min(maxLeft, desiredLeft))

        popupRoot.margins.left = Math.round(finalLeft)
        popupRoot.margins.top = barTop + barHeight + 6
    }

    onIsOpenChanged: {
        if (isOpen) updatePosition()
    }

    color: "transparent"
    visible: isOpen || hideAnim.running

    // 🪟 KARTU VISUAL POPUP DENGAN HYPRLAND BLUR
    Rectangle {
        id: popupCard
        anchors.fill: parent
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.5)
        radius: 18
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
        border.width: 1

        // 🌟 1. FADE ANIMATION (ENTER & EXIT)
        opacity: popupRoot.isOpen ? 1.0 : 0.0

        Behavior on opacity {
            NumberAnimation {
                id: hideAnim
                duration: 180
                easing.type: popupRoot.isOpen ? Easing.OutCubic : Easing.InQuad
            }
        }

        // 🌟 2. SLIDE ANIMATION (ENTER & EXIT)
        transform: Translate {
            y: popupRoot.isOpen ? 0 : -15

            Behavior on y {
                NumberAnimation {
                    duration: 180
                    easing.type: popupRoot.isOpen ? Easing.OutCubic : Easing.InQuad
                }
            }
        }

        // 🔑 HoverHandler melacak status hover tanpa terpemicu keluar oleh child item
        HoverHandler {
            onHoveredChanged: {
                if (hovered) popupRoot.keepOpen()
                else popupRoot.startCloseTimer()
            }
        }

        // 📦 Container Tempat Menyimpan Widget Isi Popup
        Item {
            id: contentContainer
            anchors.fill: parent
            anchors.margins: 16
        }
    }
}
