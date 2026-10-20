// 🏛️ REUSABLE NOTCH SHAPE COMPONENT
// Menghasilkan siluet geometris notch dengan lengkungan cekung (concave ear)
// yang menyatu mulus ke bezel layar atas monitor.
// Mendukung efek frosted-glass blur menggunakan logika yang sama dengan BasePopup (blurred wallpaper mask).

import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import Quickshell

// Properti `side`:
//   - "left"   : Menempel di sudut kiri atas layar (bezel kiri & atas rata, sisi kanan berlekuk)
//   - "right"  : Menempel di sudut kanan atas layar (bezel kanan & atas rata, sisi kiri berlekuk)
//   - "center" : Menempel di tengah atas layar (kedua sisi kiri & kanan berlekuk)
Item {
    id: root

    property string side: "center" // "left" | "right" | "center"
    property real rTop: 8
    property real rBottom: 10
    property real strokeWidth: SettingsStore.barBgEnabled ? 1 : 0
    property color strokeColor: SettingsStore.barBgEnabled ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 1) : "transparent"
    property color fillColor: SettingsStore.barBgEnabled ? Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, SettingsStore.barOpacity) : "transparent"
    // 📐 Koordinat Layar untuk Sinkronisasi Posisi Blur Wallpaper (Logika Persis PopupStyleOriginal)
    property real screenWidth: (Screen.width > 0) ? Screen.width : 1920
    property real screenHeight: (Screen.height > 0) ? Screen.height : 1080
    readonly property real screenX: {
        if (root.side === "left")
            return 0;

        if (root.side === "right")
            return root.screenWidth - root.width;

        return (root.screenWidth - root.width) / 2;
    }
    readonly property real screenY: 0
    readonly property bool enableBlur: SettingsStore.barBlurEnabled && SettingsStore.barBgEnabled
    default property alias content: contentContainer.data

    // ─────────────────────────────────────────────────────────────────────────
    // 🎭 MASK SILUET NOTCH (Digunakan oleh MultiEffect untuk memotong Wallpaper Blur)
    // ─────────────────────────────────────────────────────────────────────────
    Item {
        id: maskContainer

        width: root.width
        height: root.height

        // 1. Mask Siluet Kiri
        Shape {
            anchors.fill: parent
            visible: root.side === "left"
            layer.enabled: true
            layer.samples: 4
            antialiasing: true

            ShapePath {
                strokeColor: "transparent"
                strokeWidth: 0
                fillColor: "white"
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

        }

        // 2. Mask Siluet Kanan
        Shape {
            anchors.fill: parent
            visible: root.side === "right"
            layer.enabled: true
            layer.samples: 4
            antialiasing: true

            ShapePath {
                strokeColor: "transparent"
                strokeWidth: 0
                fillColor: "white"
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

        }

        // 3. Mask Siluet Tengah (Notch)
        Shape {
            anchors.fill: parent
            visible: root.side === "center"
            layer.enabled: true
            layer.samples: 4
            antialiasing: true

            ShapePath {
                strokeColor: "transparent"
                strokeWidth: 0
                fillColor: "white"
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

        }

    }

    // ─────────────────────────────────────────────────────────────────────────
    // 🖼️ AURORA WALLPAPER BLUR BACKDROP (PERSIS SEPERTI LOGIKA POPUP)
    // ─────────────────────────────────────────────────────────────────────────
    Item {
        id: backdropContainer

        anchors.fill: parent
        visible: root.enableBlur && backdropImage.status === Image.Ready
        layer.enabled: true

        Image {
            id: backdropImage

            x: -root.screenX
            y: -root.screenY
            width: root.screenWidth
            height: root.screenHeight
            source: "file://" + Quickshell.env("HOME") + "/.cache/blurred_wallpaper.jpg"
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
        }

        layer.effect: MultiEffect {
            maskEnabled: true

            maskSource: ShaderEffectSource {
                sourceItem: maskContainer
                hideSource: true
                live: true
            }

        }

    }

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

        // Background Tint Solid (di atas wallpaper blur)
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

        // Accent Border
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

        // Background Tint Solid
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

        // Accent Border
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

        // Background Tint Solid
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

        // Accent Border
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

    // 🔄 REFRESH WALLPAPER BLUR JIKA THEME / WALLPAPER BERUBAH
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

    Behavior on fillColor {
        ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }

    }

    Behavior on strokeColor {
        ColorAnimation {
            duration: 200
            easing.type: Easing.InOutQuad
        }

    }

}
