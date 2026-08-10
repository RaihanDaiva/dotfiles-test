import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import "../../theme"

Rectangle {
    id: root

    readonly property var romanNums: ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

    property real pillX: 0

    function updatePillX() {
        var activeId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
        var idx = workspaceRepeater.modelList.indexOf(activeId)
        if (idx < 0) return

        var item = workspaceRepeater.itemAt(idx)
        if (item && item.width > 0) {
            var mapped = leftContent.mapToItem(root, item.x, item.y)
            if (mapped.x >= 0) {
                pillX = mapped.x
            }
        } else {
            pillUpdateTimer.restart()
        }
    }

    implicitWidth: leftContent.implicitWidth + 16
    implicitHeight: 32
    color: "transparent"
    radius: 10

    Timer {
        id: pillUpdateTimer
        interval: 32
        repeat: false
        onTriggered: root.updatePillX()
    }

    Component.onCompleted: pillUpdateTimer.restart()

    // 🌟 KAPSUL SLIDING AKTIF
    Rectangle {
        id: activePill
        z: 0
        x: root.pillX
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 24
        color: Theme.accent
        radius: 8

        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Behavior on color {
            ColorAnimation {
                duration: 200
                easing.type: Easing.InOutQuad
            }
        }
    }

    // TOMBOL WORKSPACE
    RowLayout {
        id: leftContent
        z: 1
        anchors.centerIn: parent
        spacing: 6

        Repeater {
            id: workspaceRepeater

            property var modelList: {
                var list = [1, 2, 3, 4, 5]

                for (var i = 0; i < Hyprland.workspaces.values.length; i++) {
                    var id = Hyprland.workspaces.values[i].id
                    if (!list.includes(id)) {
                        list.push(id)
                    }
                }

                if (Hyprland.focusedWorkspace && !list.includes(Hyprland.focusedWorkspace.id)) {
                    list.push(Hyprland.focusedWorkspace.id)
                }

                return list.sort((a, b) => a - b)
            }

            model: modelList
            onModelChanged: pillUpdateTimer.restart()

            Item {
                implicitWidth: 32
                implicitHeight: 24

                property int wsId: modelData
                property var ws: Hyprland.workspaces.values.find(w => w.id == wsId)
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id == wsId

                onIsActiveChanged: if (isActive) pillUpdateTimer.restart()
                onXChanged: if (isActive) pillUpdateTimer.restart()

                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: "transparent"
                }

                Text {
                    anchors.centerIn: parent
                    text: root.romanNums[wsId - 1] !== undefined ? root.romanNums[wsId - 1] : wsId

                    // 🎯 HIERARKI WARNA VISUAL LOGIS:
                    // 1. AKTIF: Warna Gelap Pekat (kontras tinggi di atas kapsul aksen)
                    // 2. TERISI APP: Warna Terang Jelas (100% Theme.textMain)
                    // 3. KOSONG: Warna Redup Transparan (35% Opacity)
                    color: isActive ? Theme.bgDark : (ws ? Theme.textMain : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.35))

                    font {
                        family: Theme.fontMain
                        pixelSize: 14
                        bold: true
                    }

                    Behavior on color {
                        ColorAnimation { 
                            duration: 200 
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + wsId)
                }
            }
        }
    }
}
