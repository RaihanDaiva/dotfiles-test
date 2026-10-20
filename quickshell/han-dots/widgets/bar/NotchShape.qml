// 🏛️ REUSABLE NOTCH SHAPE COMPONENT
// Menghasilkan siluet geometris notch dengan lengkungan cekung (concave ear)
// yang menyatu mulus ke bezel layar atas monitor.

import "../../theme"
import QtQuick
import QtQuick.Shapes

// Properti `side`:
//   - "left"   : Menempel di sudut kiri atas layar (bezel kiri & atas rata, sisi kanan berlekuk)
//   - "right"  : Menempel di sudut kanan atas layar (bezel kanan & atas rata, sisi kiri berlekuk)
//   - "center" : Menempel di tengah atas layar (kedua sisi kiri & kanan berlekuk)
Item {
    id: root

    property string side: "center" // "left" | "right" | "center"
    property real rTop: 8
    property real rBottom: 10
    property real strokeWidth: 1.2
    property color strokeColor: Theme.accent
    property color fillColor: Qt.rgba(0.04, 0.05, 0.08, 0.96)
    default property alias content: contentContainer.data

    // ─────────────────────────────────────────────────────────────────────────
    // ⬛ 1. SHAPE UNTUK SISI KIRI (Corner-flush di sudut kiri-atas)
    // ─────────────────────────────────────────────────────────────────────────
    Shape {
        id: shapeLeft

        anchors.fill: parent
        visible: root.side === "left"
        layer.enabled: true
        layer.samples: 4
        antialiasing: true

        // Background Fill Solid (tertutup, tanpa garis atas & kiri)
        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: root.fillColor
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            startX: 0
            startY: 0

            PathLine {
                x: 0
                y: root.height
            }

            PathLine {
                x: root.width - root.rTop - root.rBottom
                y: root.height
            }

            PathArc {
                x: root.width - root.rTop
                y: root.height - root.rBottom
                radiusX: root.rBottom
                radiusY: root.rBottom
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width - root.rTop
                y: root.rTop
            }

            PathArc {
                x: root.width
                y: 0
                radiusX: root.rTop
                radiusY: root.rTop
                direction: PathArc.Clockwise
            }

            PathLine {
                x: 0
                y: 0
            }

        }

        // Accent Border (hanya garis bawah dan lengkungan kanan, tanpa garis atas & bezel kiri)
        ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            startX: 0
            startY: root.height - (root.strokeWidth / 2)

            PathLine {
                x: root.width - root.rTop - root.rBottom
                y: root.height - (root.strokeWidth / 2)
            }

            PathArc {
                x: root.width - root.rTop
                y: root.height - root.rBottom - (root.strokeWidth / 2)
                radiusX: root.rBottom
                radiusY: root.rBottom
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width - root.rTop
                y: root.rTop
            }

            PathArc {
                x: root.width
                y: 0
                radiusX: root.rTop
                radiusY: root.rTop
                direction: PathArc.Clockwise
            }

        }

    }

    // ─────────────────────────────────────────────────────────────────────────
    // ⬛ 2. SHAPE UNTUK SISI KANAN (Corner-flush di sudut kanan-atas)
    // ─────────────────────────────────────────────────────────────────────────
    Shape {
        id: shapeRight

        anchors.fill: parent
        visible: root.side === "right"
        layer.enabled: true
        layer.samples: 4
        antialiasing: true

        // Background Fill Solid
        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: root.fillColor
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            startX: 0
            startY: 0

            PathArc {
                x: root.rTop
                y: root.rTop
                radiusX: root.rTop
                radiusY: root.rTop
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.rTop
                y: root.height - root.rBottom
            }

            PathArc {
                x: root.rTop + root.rBottom
                y: root.height
                radiusX: root.rBottom
                radiusY: root.rBottom
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width
                y: root.height
            }

            PathLine {
                x: root.width
                y: 0
            }

            PathLine {
                x: 0
                y: 0
            }

        }

        // Accent Border (hanya lengkungan kiri dan garis bawah, tanpa garis atas & bezel kanan)
        ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            startX: 0
            startY: 0

            PathArc {
                x: root.rTop
                y: root.rTop
                radiusX: root.rTop
                radiusY: root.rTop
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.rTop
                y: root.height - root.rBottom - (root.strokeWidth / 2)
            }

            PathArc {
                x: root.rTop + root.rBottom
                y: root.height - (root.strokeWidth / 2)
                radiusX: root.rBottom
                radiusY: root.rBottom
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width
                y: root.height - (root.strokeWidth / 2)
            }

        }

    }

    // ─────────────────────────────────────────────────────────────────────────
    // ⬛ 3. SHAPE UNTUK TENGAH (Notch MacBook di tengah atas layar)
    // ─────────────────────────────────────────────────────────────────────────
    Shape {
        id: shapeCenter

        anchors.fill: parent
        visible: root.side === "center"
        layer.enabled: true
        layer.samples: 4
        antialiasing: true

        // Background Fill Solid
        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: root.fillColor
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            startX: 0
            startY: 0

            PathArc {
                x: root.rTop
                y: root.rTop
                radiusX: root.rTop
                radiusY: root.rTop
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.rTop
                y: root.height - root.rBottom
            }

            PathArc {
                x: root.rTop + root.rBottom
                y: root.height
                radiusX: root.rBottom
                radiusY: root.rBottom
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width - root.rTop - root.rBottom
                y: root.height
            }

            PathArc {
                x: root.width - root.rTop
                y: root.height - root.rBottom
                radiusX: root.rBottom
                radiusY: root.rBottom
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width - root.rTop
                y: root.rTop
            }

            PathArc {
                x: root.width
                y: 0
                radiusX: root.rTop
                radiusY: root.rTop
                direction: PathArc.Clockwise
            }

            PathLine {
                x: 0
                y: 0
            }

        }

        // Accent Border (kontur terbuka, tanpa garis penutup di tepi atas y=0)
        ShapePath {
            strokeColor: root.strokeColor
            strokeWidth: root.strokeWidth
            fillColor: "transparent"
            joinStyle: ShapePath.RoundJoin
            capStyle: ShapePath.RoundCap
            startX: 0
            startY: 0

            PathArc {
                x: root.rTop
                y: root.rTop
                radiusX: root.rTop
                radiusY: root.rTop
                direction: PathArc.Clockwise
            }

            PathLine {
                x: root.rTop
                y: root.height - root.rBottom - (root.strokeWidth / 2)
            }

            PathArc {
                x: root.rTop + root.rBottom
                y: root.height - (root.strokeWidth / 2)
                radiusX: root.rBottom
                radiusY: root.rBottom
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width - root.rTop - root.rBottom
                y: root.height - (root.strokeWidth / 2)
            }

            PathArc {
                x: root.width - root.rTop
                y: root.height - root.rBottom - (root.strokeWidth / 2)
                radiusX: root.rBottom
                radiusY: root.rBottom
                direction: PathArc.Counterclockwise
            }

            PathLine {
                x: root.width - root.rTop
                y: root.rTop
            }

            PathArc {
                x: root.width
                y: 0
                radiusX: root.rTop
                radiusY: root.rTop
                direction: PathArc.Clockwise
            }

        }

    }

    // ─────────────────────────────────────────────────────────────────────────
    // 📦 KONTENER KONTEN (Menempatkan item anak di atas background Shape)
    // ─────────────────────────────────────────────────────────────────────────
    Item {
        id: contentContainer

        anchors.fill: parent
    }

}
