import "../services"
import "../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// 🪟 REUSABLE BASE POPUP SHELL (PanelWindow dengan Hyprland Blur & Smart Clamped Positioning)
PanelWindow {
    id: popupRoot

    // 🎯 PROPERTY REUSABLE
    property var barWindow: null
    property var targetItem: null
    property bool isOpen: false
    // 📦 Default property alias agar children langsung dimasukkan ke dalam container
    default property alias contentData: contentContainer.data
    property alias cardMargins: contentContainer.anchors.margins
    property alias cardRadius: popupCard.radius
    property bool requiresKeyboardFocus: false

    // Signals untuk hover timer parent widget
    signal keepOpen()
    signal startCloseTimer()

    // 📐 Kalkulasi Posisi Dinamis (Smart Auto-Centering & Clamp ke Ujung Bar / Screen)
    function updatePosition() {
        if (!targetItem)
            return ;

        var screenW = (barWindow && barWindow.screen && barWindow.screen.width > 0) ? barWindow.screen.width : ((popupRoot.screen && popupRoot.screen.width > 0) ? popupRoot.screen.width : 1920);
        var barW = barWindow ? (barWindow.width > 0 ? barWindow.width : barWindow.implicitWidth) : screenW;
        var barTop = barWindow ? barWindow.margins.top : 8;
        var barHeight = barWindow ? (barWindow.height > 0 ? barWindow.height : barWindow.implicitHeight) : 40;
        // Hitung posisi awal X dari barWindow di layar (Layar Kiri = 0)
        var windowLeft = 15;
        if (barWindow) {
            if (barWindow.anchors.left && barWindow.anchors.right)
                windowLeft = barWindow.margins.left;
            else if (barWindow.anchors.right && !barWindow.anchors.left)
                windowLeft = screenW - barWindow.margins.right - barW;
            else if (barWindow.anchors.left && !barWindow.anchors.right)
                windowLeft = barWindow.margins.left;
            else
                // Surface tanpa anchor kiri/kanan di-center-kan oleh compositor
                windowLeft = Math.round((screenW - barW) / 2);
        }
        var itemX = targetItem.mapToItem(null, 0, 0).x;
        var itemWidth = targetItem.width;
        var popupWidth = popupRoot.implicitWidth;
        // 1. Posisi ideal: Centered tepat di bawah targetItem (Screen X)
        var targetScreenCenterX = windowLeft + itemX + (itemWidth / 2);
        var desiredLeft = targetScreenCenterX - (popupWidth / 2);
        // 2. Batas Kiri & Kanan (Constraint agar popup tidak melimpah keluar layar)
        var minLeft = 15;
        var maxLeft = screenW - popupWidth - 15;
        var finalLeft = Math.max(minLeft, Math.min(maxLeft, desiredLeft));
        popupRoot.margins.left = Math.round(finalLeft);
        popupRoot.margins.top = barTop + barHeight + 6;
    }

    exclusionMode: ExclusionMode.Ignore
    // 🏷️ Namespace & Layer Wayland
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: requiresKeyboardFocus ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    anchors.top: true
    anchors.left: true
    margins.top: 54
    color: "transparent"
    onIsOpenChanged: {
        if (isOpen) {
            updatePosition();
            PopupManager.requestOpen(popupRoot);
        } else {
            PopupManager.notifyClosed(popupRoot);
        }
    }
    visible: isOpen || hideAnim.running

    // 🪟 KARTU VISUAL POPUP DENGAN HYPRLAND BLUR
    Rectangle {
        id: popupCard

        anchors.fill: parent
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.popupOpacity)
        radius: SettingsStore.popupRadius
        // 🌟 1. FADE ANIMATION (ENTER & EXIT)
        opacity: popupRoot.isOpen ? 1 : 0

        // 🔑 HoverHandler melacak status hover tanpa terpemicu keluar oleh child item
        HoverHandler {
            onHoveredChanged: {
                if (hovered)
                    popupRoot.keepOpen();
                else
                    popupRoot.startCloseTimer();
            }
        }

        // 📦 Container Tempat Menyimpan Widget Isi Popup
        Item {
            id: contentContainer

            anchors.fill: parent
            anchors.margins: 16
        }

        // 🖼️ BORDER OVERLAY (z: 9999 memastikan garis border SELALU berada di paling atas melingkupi background & gambar!)
        Rectangle {
            anchors.fill: parent
            radius: popupCard.radius
            color: "transparent"
            border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5)
            border.width: SettingsStore.popupBorderWidth
            z: 9999
        }

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

    }

    mask: Region {
        item: popupCard
    }

}
