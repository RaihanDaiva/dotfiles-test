import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland

Rectangle {
    id: root

    readonly property var romanNums: ["I", "II", "III", "IV", "V", "VI", "VII", "VIII", "IX", "X"]

    // Posisi X dari kapsul aktif (dihitung secara independen, TIDAK di dalam RowLayout)
    property real pillX: 0

    // Setiap kali workspace aktif berubah, perbarui posisi pill
    function updatePillX() {
        var idx = workspaceRepeater.modelList.indexOf(
            Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : 1
        )
        if (idx < 0) idx = 0
        var item = workspaceRepeater.itemAt(idx)
        if (item) {
            // Konversi koordinat item ke koordinat root (bukan leftContent)
            var mapped = leftContent.mapToItem(root, item.x, item.y)
            pillX = mapped.x
        }
    }

    implicitWidth: leftContent.implicitWidth + 16
    implicitHeight: 32
    color: "#1e1e2e"
    radius: 10

    // 🌟 KAPSUL AKTIF (Di luar RowLayout, mengapung bebas tanpa memengaruhi layout)
    Rectangle {
        id: activePill
        z: 0
        x: root.pillX
        anchors.verticalCenter: parent.verticalCenter
        width: 32
        height: 24
        color: "#89b4fa"
        radius: 8

        // ✨ ANIMASI SLIDE MULUS
        Behavior on x {
            NumberAnimation {
                duration: 250
                easing.type: Easing.OutCubic
            }
        }
    }

    // Tombol-tombol workspace
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
                    if (!list.includes(id))
                        list.push(id)
                }

                if (Hyprland.focusedWorkspace && !list.includes(Hyprland.focusedWorkspace.id))
                    list.push(Hyprland.focusedWorkspace.id)

                return list.sort((a, b) => a - b)
            }

            model: modelList

            // Perbarui posisi pill setiap model berubah
            onModelChanged: Qt.callLater(root.updatePillX)

            Item {
                implicitWidth: 32
                implicitHeight: 24

                property int wsId: modelData
                property var ws: Hyprland.workspaces.values.find(w => w.id == wsId)
                property bool isActive: Hyprland.focusedWorkspace && Hyprland.focusedWorkspace.id == wsId

                // Perbarui posisi pill saat item ini menjadi aktif
                onIsActiveChanged: if (isActive) Qt.callLater(root.updatePillX)

                // Background untuk workspace yang ada isinya tapi tidak aktif
                Rectangle {
                    anchors.fill: parent
                    radius: 8
                    color: !isActive && ws ? "#313244" : "transparent"

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    text: root.romanNums[wsId - 1] !== undefined ? root.romanNums[wsId - 1] : wsId
                    color: isActive ? "#11111b" : (ws ? "#cdd6f4" : "#585b70")
                    font { pixelSize: 12; bold: true }

                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Hyprland.dispatch("workspace " + wsId)
                }
            }
        }
    }

    // Inisialisasi posisi pill saat pertama kali dimuat
    Component.onCompleted: Qt.callLater(root.updatePillX)
}
