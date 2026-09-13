import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// 🪟 REUSABLE BASE POPUP SHELL (Modular Multi-Style PanelWindow)
PanelWindow {
    id: popupRoot

    // 🎯 PROPERTY REUSABLE
    property var barWindow: null
    property var targetItem: null
    property bool isOpen: false
    property string popupStyle: SettingsStore.popupStyle || "macos"
    // 📦 Default property alias agar children langsung dimasukkan ke dalam container
    default property alias contentData: contentContainer.data
    property alias cardMargins: contentContainer.anchors.margins
    property alias cardRadius: popupCard.radius
    property bool requiresKeyboardFocus: false
    property real targetCardHeight: -1

    // Signals untuk hover timer parent widget
    signal keepOpen()
    signal startCloseTimer()

    function updateStyle() {
        var styleName = popupRoot.popupStyle || "macos";
        var formatted = styleName.charAt(0).toUpperCase() + styleName.slice(1).toLowerCase();
        var styleUrl = Qt.resolvedUrl("./popupStyle/PopupStyle" + formatted + ".qml");
        styleLoader.setSource(styleUrl, {
            "cardRadius": popupRoot.cardRadius,
            "borderWidth": SettingsStore.popupBorderWidth,
            "enableBlur": SettingsStore.enableBlur,
            "popupOpacity": SettingsStore.popupOpacity,
            "marginLeft": popupRoot.margins.left,
            "marginTop": popupRoot.margins.top,
            "screenWidth": (popupRoot.screen && popupRoot.screen.width > 0) ? popupRoot.screen.width : 1920,
            "screenHeight": (popupRoot.screen && popupRoot.screen.height > 0) ? popupRoot.screen.height : 1080
        });
    }
   
    function updateProps() {
        if (styleLoader.item) {
            styleLoader.item.cardRadius = popupRoot.cardRadius;
            styleLoader.item.borderWidth = SettingsStore.popupBorderWidth;
            styleLoader.item.enableBlur = SettingsStore.enableBlur;
            styleLoader.item.popupOpacity = SettingsStore.popupOpacity;
            styleLoader.item.marginLeft = popupRoot.margins.left;
            styleLoader.item.marginTop = popupRoot.margins.top;
            styleLoader.item.screenWidth = (popupRoot.screen && popupRoot.screen.width > 0) ? popupRoot.screen.width : 1920;
            styleLoader.item.screenHeight = (popupRoot.screen && popupRoot.screen.height > 0) ? popupRoot.screen.height : 1080;
        }
    }

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
        popupRoot.updateProps();
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
    Component.onCompleted: updateStyle()
    onPopupStyleChanged: updateStyle()
    mask: (popupRoot.popupStyle === "original" || popupRoot.targetCardHeight > 0) ? cardRegion : null

    // 🪟 KARTU VISUAL POPUP
    Rectangle {
        id: popupCard

        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        height: popupRoot.targetCardHeight > 0 ? popupRoot.targetCardHeight : parent.height
        color: "transparent"
        radius: SettingsStore.popupRadius
        // 🌟 1. FADE ANIMATION (ENTER & EXIT)
        opacity: popupRoot.isOpen ? 1 : 0

        // 🎨 DYNAMIC POPUP STYLE LOADER
        Loader {
            id: styleLoader

            anchors.fill: parent
            z: 0

            Binding {
                target: styleLoader.item
                property: "marginLeft"
                value: popupRoot.margins.left
            }

            Binding {
                target: styleLoader.item
                property: "marginTop"
                value: popupRoot.margins.top
            }

            Binding {
                target: styleLoader.item
                property: "screenWidth"
                value: (popupRoot.screen && popupRoot.screen.width > 0) ? popupRoot.screen.width : 1920
            }

            Binding {
                target: styleLoader.item
                property: "screenHeight"
                value: (popupRoot.screen && popupRoot.screen.height > 0) ? popupRoot.screen.height : 1080
            }

        }

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
            z: 1
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

    Region {
        id: cardRegion

        item: popupCard
    }

}
