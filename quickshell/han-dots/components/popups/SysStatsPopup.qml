import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import "../../widgets"
import "../../theme"

// 🎛️ SYSTEM MONITOR PERFORMANCE POPUP (Berada di components/popups/ & Inherit BasePopup dari widgets/)
BasePopup {
    id: popupRoot

    property var statsRootItem: null
    targetItem: statsRootItem

    property int cpuLoadPercent: 0
    property string cpuTempText: "0°C"
    property int cpuTempValue: 0
    property int gpuLoadPercent: 0
    property int gpuTempValue: 0
    property int ramPercent: 0
    property string ramUsageDetails: "0 / 0 GB"
    property int diskPercent: 0
    property string diskDetails: "0 / 0 GB"

    // 📐 UKURAN POPUP SESUAI UNTUK LINGKARAN DENGAN DIAMETER LEBIH BESAR (380x650 px)
    implicitWidth: 380
    implicitHeight: 665

    // 🎨 STATUS LOGIC
    readonly property string cpuStatusText: cpuLoadPercent > 85 ? "Critical" : (cpuLoadPercent > 60 ? "High" : "Normal")
    readonly property color cpuStatusColor: cpuLoadPercent > 85 ? "#f38ba8" : (cpuLoadPercent > 60 ? "#f9e2af" : Theme.accent)

    readonly property string tempStatusText: cpuTempValue > 80 ? "Hot" : (cpuTempValue > 65 ? "Warm" : "Good")
    readonly property color tempStatusColor: cpuTempValue > 80 ? "#f38ba8" : (cpuTempValue > 65 ? "#f9e2af" : Theme.accent)

    readonly property string gpuLoadStatusText: gpuLoadPercent > 85 ? "Critical" : (gpuLoadPercent > 60 ? "High" : "Normal")
    readonly property color gpuLoadStatusColor: gpuLoadPercent > 85 ? "#f38ba8" : (gpuLoadPercent > 60 ? "#f9e2af" : Theme.accent)

    readonly property string gpuTempStatusText: gpuTempValue > 80 ? "Hot" : (gpuTempValue > 65 ? "Warm" : "Good")
    readonly property color gpuTempStatusColor: gpuTempValue > 80 ? "#f38ba8" : (gpuTempValue > 65 ? "#f9e2af" : Theme.accent)

    readonly property color ramStatusColor: ramPercent > 85 ? "#f38ba8" : (ramPercent > 70 ? "#f9e2af" : Theme.accent)

    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        
        // 1. Header (Icon & Title)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: "󰓅"
                color: Theme.accent
                font { family: Theme.fontMono; pixelSize: 24 }
            }

            Text {
                text: "System Monitor"
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 16; bold: true }
                Layout.fillWidth: true
            }

        }

        // ➖ GARIS PEMISAH TOP
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
        }

        // ⭕ 2. ROW 1: CPU LOAD & GPU LOAD (2 CIRCLES - ENLARGED TO 115x115px)
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // 🌀 CIRCLE 1: CPU LOAD
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Item {
                    implicitWidth: 115
                    implicitHeight: 115
                    Layout.alignment: Qt.AlignHCenter

                    Canvas {
                        id: cpuCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9

                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                            ctx.lineWidth = 8
                            ctx.stroke()

                            var startAngle = -Math.PI / 2
                            var progressAngle = (popupRoot.cpuLoadPercent / 100) * 2 * Math.PI
                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle)
                            ctx.strokeStyle = popupRoot.cpuStatusColor
                            ctx.lineWidth = 8
                            ctx.stroke()
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰻠"
                            color: Theme.textMain
                            font { family: Theme.fontMono; pixelSize: 24 }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: popupRoot.cpuLoadPercent + "%"
                            color: popupRoot.cpuStatusColor
                            font { family: Theme.fontMain; pixelSize: 15; bold: true }
                        }
                    }

                    onWidthChanged: cpuCanvas.requestPaint()
                }

                Text {
                    text: "CPU Load"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 12 }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: popupRoot.cpuStatusText
                    color: popupRoot.cpuStatusColor
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Connections {
                    target: popupRoot
                    function onCpuLoadPercentChanged() { cpuCanvas.requestPaint() }
                }
            }

            // 🌀 CIRCLE 2: GPU LOAD
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Item {
                    implicitWidth: 115
                    implicitHeight: 115
                    Layout.alignment: Qt.AlignHCenter

                    Canvas {
                        id: gpuLoadCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9

                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                            ctx.lineWidth = 8
                            ctx.stroke()

                            var startAngle = -Math.PI / 2
                            var progressAngle = (popupRoot.gpuLoadPercent / 100) * 2 * Math.PI
                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle)
                            ctx.strokeStyle = popupRoot.gpuLoadStatusColor
                            ctx.lineWidth = 8
                            ctx.stroke()
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰢮"
                            color: Theme.textMain
                            font { family: Theme.fontMono; pixelSize: 24 }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: popupRoot.gpuLoadPercent + "%"
                            color: popupRoot.gpuLoadStatusColor
                            font { family: Theme.fontMain; pixelSize: 15; bold: true }
                        }
                    }

                    onWidthChanged: gpuLoadCanvas.requestPaint()
                }

                Text {
                    text: "GPU Load"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 12 }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: popupRoot.gpuLoadStatusText
                    color: popupRoot.gpuLoadStatusColor
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Connections {
                    target: popupRoot
                    function onGpuLoadPercentChanged() { gpuLoadCanvas.requestPaint() }
                }
            }
        }

        // ⭕ 3. ROW 2: CPU TEMP & GPU TEMP (2 CIRCLES - ENLARGED TO 115x115px)
        RowLayout {
            Layout.fillWidth: true
            spacing: 16

            // 🌀 CIRCLE 3: CPU TEMP
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Item {
                    implicitWidth: 115
                    implicitHeight: 115
                    Layout.alignment: Qt.AlignHCenter

                    Canvas {
                        id: tempCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9

                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                            ctx.lineWidth = 8
                            ctx.stroke()

                            var startAngle = -Math.PI / 2
                            var progressAngle = (Math.min(100, popupRoot.cpuTempValue) / 100) * 2 * Math.PI
                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle)
                            ctx.strokeStyle = popupRoot.tempStatusColor
                            ctx.lineWidth = 8
                            ctx.stroke()
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰔏"
                            color: Theme.textMain
                            font { family: Theme.fontMono; pixelSize: 24 }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: popupRoot.cpuTempText
                            color: popupRoot.tempStatusColor
                            font { family: Theme.fontMain; pixelSize: 15; bold: true }
                        }
                    }

                    onWidthChanged: tempCanvas.requestPaint()
                }

                Text {
                    text: "CPU Temp"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 12 }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: popupRoot.tempStatusText
                    color: popupRoot.tempStatusColor
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Connections {
                    target: popupRoot
                    function onCpuTempValueChanged() { tempCanvas.requestPaint() }
                }
            }

            // 🌀 CIRCLE 4: GPU TEMP
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4

                Item {
                    implicitWidth: 115
                    implicitHeight: 115
                    Layout.alignment: Qt.AlignHCenter

                    Canvas {
                        id: gpuTempCanvas
                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d")
                            ctx.clearRect(0, 0, width, height)
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9

                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                            ctx.lineWidth = 8
                            ctx.stroke()

                            var startAngle = -Math.PI / 2
                            var progressAngle = (Math.min(100, popupRoot.gpuTempValue) / 100) * 2 * Math.PI
                            ctx.beginPath()
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle)
                            ctx.strokeStyle = popupRoot.gpuTempStatusColor
                            ctx.lineWidth = 8
                            ctx.stroke()
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰔏"
                            color: Theme.textMain
                            font { family: Theme.fontMono; pixelSize: 24 }
                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: popupRoot.gpuTempValue + "°C"
                            color: popupRoot.gpuTempStatusColor
                            font { family: Theme.fontMain; pixelSize: 15; bold: true }
                        }
                    }

                    onWidthChanged: gpuTempCanvas.requestPaint()
                }

                Text {
                    text: "GPU Temp"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 12 }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Text {
                    text: popupRoot.gpuTempStatusText
                    color: popupRoot.gpuTempStatusColor
                    font { family: Theme.fontMain; pixelSize: 13; bold: true }
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                Connections {
                    target: popupRoot
                    function onGpuTempValueChanged() { gpuTempCanvas.requestPaint() }
                }
            }
        }

        // ⭕ 4. ROW 3: MEMORY (RAM) (1 CENTERED CIRCLE - ENLARGED TO 115x115px)
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            Item {
                implicitWidth: 115
                implicitHeight: 115
                Layout.alignment: Qt.AlignHCenter

                Canvas {
                    id: ramCanvas
                    anchors.fill: parent
                    onPaint: {
                        var ctx = getContext("2d")
                        ctx.clearRect(0, 0, width, height)
                        var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9

                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                        ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
                        ctx.lineWidth = 8
                        ctx.stroke()

                        var startAngle = -Math.PI / 2
                        var progressAngle = (popupRoot.ramPercent / 100) * 2 * Math.PI
                        ctx.beginPath()
                        ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle)
                        ctx.strokeStyle = popupRoot.ramStatusColor
                        ctx.lineWidth = 8
                        ctx.stroke()
                    }
                }

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 1

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: "󰍛"
                        color: Theme.textMain
                        font { family: Theme.fontMono; pixelSize: 24 }
                    }

                    Text {
                        Layout.alignment: Qt.AlignHCenter
                        text: popupRoot.ramPercent + "%"
                        color: popupRoot.ramStatusColor
                        font { family: Theme.fontMain; pixelSize: 15; bold: true }
                    }
                }

                onWidthChanged: ramCanvas.requestPaint()
            }

            Text {
                text: "Memory"
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 12 }
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
            }

            Text {
                text: popupRoot.ramUsageDetails
                color: Theme.accent
                font { family: Theme.fontMain; pixelSize: 12; bold: true }
                horizontalAlignment: Text.AlignHCenter
                Layout.fillWidth: true
                elide: Text.ElideRight
            }

            Connections {
                target: popupRoot
                function onRamPercentChanged() { ramCanvas.requestPaint() }
            }
        }

        // ➖ GARIS PEMISAH BOTTOM
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
        }

        // 💾 5. STORAGE DISK USAGE BAR (Partisi Root /)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "󰋊  Storage ( Root / )"
                    color: Theme.textMain
                    font { family: Theme.fontMain; pixelSize: 14; bold: true }
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: popupRoot.diskDetails
                    color: Theme.secondary
                    font { family: Theme.fontMain; pixelSize: 13 }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 10
                radius: 5
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)

                Rectangle {
                    height: parent.height
                    width: parent.width * (popupRoot.diskPercent / 100)
                    radius: 5
                    color: popupRoot.diskPercent > 85 ? "#f38ba8" : Theme.accent

                    Behavior on width {
                        NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}
