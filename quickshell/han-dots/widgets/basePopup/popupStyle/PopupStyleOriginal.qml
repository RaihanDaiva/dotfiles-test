import "../../../services"
import "../../../theme"
import QtQuick
import QtQuick.Effects
import Quickshell

// 🪟 ORIGINAL POPUP STYLE (Crisp Rounded Glass Card with Border)
Item {
    id: styleRoot

    property real cardRadius: SettingsStore.popupRadius
    property int borderWidth: SettingsStore.popupBorderWidth
    property bool enableBlur: SettingsStore.enableBlur
    property real popupOpacity: SettingsStore.popupOpacity
    property real marginLeft: 0
    property real marginTop: 0
    property real screenWidth: 1920
    property real screenHeight: 1080

    // 🖼️ AURORA WALLPAPER BLUR BACKDROP
    Item {
        id: backdropContainer

        anchors.fill: parent
        visible: styleRoot.enableBlur && backdropImage.status === Image.Ready
        layer.enabled: true

        Image {
            id: backdropImage

            x: -styleRoot.marginLeft
            y: -styleRoot.marginTop
            width: styleRoot.screenWidth
            height: styleRoot.screenHeight
            source: "file://" + Quickshell.env("HOME") + "/.cache/blurred_wallpaper.jpg"
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
        }

        layer.effect: MultiEffect {
            maskEnabled: true

            maskSource: ShaderEffectSource {

                sourceItem: Rectangle {
                    width: styleRoot.width
                    height: styleRoot.height
                    radius: styleRoot.cardRadius
                    color: "white"
                }

            }

        }

    }

    // 🎨 FROSTED TINT OVERLAY
    Rectangle {
        anchors.fill: parent
        radius: styleRoot.cardRadius
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, Math.max(0.45, styleRoot.popupOpacity * 0.75))
    }

    // 🖼️ BORDER OVERLAY
    Rectangle {
        anchors.fill: parent
        radius: styleRoot.cardRadius
        color: "transparent"
        border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5)
        border.width: styleRoot.borderWidth
        z: 9999
    }

    Connections {
        function onAccentChanged() {
            if (backdropImage) {
                var s = backdropImage.source;
                backdropImage.source = "";
                backdropImage.source = s;
            }
        }

        target: Theme
    }

}
