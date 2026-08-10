import QtQuick
import Quickshell
import Quickshell.Io
import "../../../theme"

Row {
    id: visualizerRoot

    property bool isPlaying: false
    property var cavaValues: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    anchors.fill: parent
    anchors.leftMargin: 6
    anchors.rightMargin: 6
    anchors.bottomMargin: 2
    spacing: 2
    z: 0

    // 🎙️ CAVA REAL-TIME AUDIO PROCESS
    Process {
        id: cavaProc
        command: ["cava", "-p", Quickshell.env("HOME") + "/.config/cava/config_quickshell"]
        running: visualizerRoot.isPlaying

        stdout: SplitParser {
            splitMarker: "\n"
            onRead: data => {
                if (!data || data.trim() === "") return
                var parts = data.trim().split(";")
                if (parts.length >= 24) {
                    var vals = []
                    for (var i = 0; i < 24; i++) {
                        vals.push(parseInt(parts[i]) || 0)
                    }
                    visualizerRoot.cavaValues = vals
                }
            }
        }
    }

    Repeater {
        model: 24

        Rectangle {
            id: bar
            width: (parent.width - (23 * 2)) / 24
            height: visualizerRoot.isPlaying ? Math.max(2, (visualizerRoot.cavaValues[index] !== undefined ? visualizerRoot.cavaValues[index] : 2)) : 2
            radius: 2
            color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.35)
            anchors.bottom: parent.bottom

            Behavior on height {
                NumberAnimation {
                    duration: 50
                    easing.type: Easing.OutCubic
                }
            }
        }
    }
}
