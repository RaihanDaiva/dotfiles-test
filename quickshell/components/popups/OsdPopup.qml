import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import "../../theme"

// 🎚️ ON-SCREEN DISPLAY (OSD) POPUP OVERLAY CARD FOR VOLUME & BRIGHTNESS
PanelWindow {
    id: osdRoot

    exclusionMode: ExclusionMode.Ignore

    // 🎯 PUBLIC PROPERTIES & METHODS
    property bool isOpen: false
    property string osdIcon: "󰃠"
    property string osdTitle: "Brightness"
    property int osdValue: 50

    // Functions to trigger OSD popup
    function showBrightness(val, isSecond) {
        osdIcon = "󰃠"
        osdTitle = isSecond ? "Brightness (second)" : "Brightness"
        osdValue = Math.min(100, Math.max(0, val))
        triggerShow()
    }

    function showVolume(val, isMuted) {
        if (isMuted || val <= 0) {
            osdIcon = "󰝟"
        } else if (val >= 66) {
            osdIcon = "󰕾"
        } else if (val >= 33) {
            osdIcon = "󰖀"
        } else {
            osdIcon = "󰕿"
        }
        osdTitle = "Volume"
        osdValue = Math.min(150, Math.max(0, val))
        triggerShow()
    }

    function triggerShow() {
        isOpen = true 
        hideTimer.restart() 
    }

    // 🏷️ Wayland LayerShell Configuration (Floating Overlay at Bottom Center)
    WlrLayershell.namespace: "quickshell:popup"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

    anchors {
        bottom: true
    }
    margins {
        bottom: 110
    }

    implicitWidth: 320
    implicitHeight: 52
    color: "transparent"

    visible: isOpen || osdCard.opacity > 0

    // ⏱️ Auto-hide timer
    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: osdRoot.isOpen = false
    }

    // 📦 OSD CARD CONTAINER RECTANGLE
    Rectangle {
        id: osdCard
        anchors.fill: parent
        radius: 16
        color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.82)
        border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
        border.width: 1

        opacity: osdRoot.isOpen ? 1.0 : 0.0
        scale: osdRoot.isOpen ? 1.0 : 0.94

        Behavior on opacity { NumberAnimation { duration: osdRoot.isOpen ? 120 : 250; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: osdRoot.isOpen ? 120 : 250; easing.type: Easing.OutCubic } }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            spacing: 12

            // 🎨 ICON
            Text {
                text: osdRoot.osdIcon
                color: Theme.accent
                font { family: Theme.fontMono; pixelSize: 22 }
            }

            // 📊 PROGRESS BAR TRACK & FILL
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 8
                radius: 4
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)

                Rectangle {
                    height: parent.height
                    width: parent.width * Math.min(1.0, Math.max(0, (osdRoot.osdTitle === "Volume" ? (osdRoot.osdValue / 150) : (osdRoot.osdValue / 100))))
                    radius: parent.radius
                    color: (osdRoot.osdTitle === "Volume" && osdRoot.osdValue > 100) ? "#f38ba8" : Theme.accent

                    Behavior on width { NumberAnimation { duration: 100; easing.type: Easing.OutCubic } }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }
            }

            // 🔢 PERCENTAGE TEXT
            Text {
                text: osdRoot.osdValue + "%"
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 14; bold: true }
                Layout.alignment: Qt.AlignVCenter
            }
        }
    }
}
