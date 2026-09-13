import "../../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: root

    property int cpuLoadPercent: 0
    property string cpuTempText: "0°C"
    property int cpuTempValue: 0
    property int gpuLoadPercent: 0
    property int gpuTempValue: 0
    property int ramPercent: 0
    property string ramUsageDetails: "0 / 0 GB"
    property int diskPercent: 0
    property string diskDetails: "0 / 0 GB"
    property string cpuStatusText: "Normal"
    property color cpuStatusColor: Theme.accent
    property string tempStatusText: "Good"
    property color tempStatusColor: Theme.accent
    property string gpuLoadStatusText: "Normal"
    property color gpuLoadStatusColor: Theme.accent
    property string gpuTempStatusText: "Good"
    property color gpuTempStatusColor: Theme.accent
    property color ramStatusColor: Theme.accent
    property color diskStatusColor: Theme.accent

    implicitWidth: 348
    implicitHeight: col.implicitHeight

    ColumnLayout {
        id: col

        anchors.fill: parent
        spacing: 12

        // 🏷️ 1. HEADER CAPSULE BADGE
        RowLayout {
            Layout.fillWidth: true

            Rectangle {
                implicitHeight: 34
                implicitWidth: headerRow.implicitWidth + 24
                radius: height / 2
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                border.width: 1

                RowLayout {
                    id: headerRow

                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        text: "󰓅"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 18
                        }

                    }

                    Text {
                        text: "System Monitor"
                        color: Theme.textMain

                        font {
                            family: Theme.fontMain
                            pixelSize: 13
                            bold: true
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

        }

        // ⭕ 2. UNIFIED 3x2 METRICS GRID (PERFECT ALIGNMENT & SYMMETRY)
        GridLayout {
            id: statsGrid

            Layout.fillWidth: true
            columns: 2
            columnSpacing: 16
            rowSpacing: 14

            // 🌀 1. CPU LOAD
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    id: cpuDisc

                    implicitWidth: 115
                    implicitHeight: 115
                    radius: width / 2
                    Layout.alignment: Qt.AlignHCenter
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1
                    onWidthChanged: cpuCanvas.requestPaint()

                    Canvas {
                        id: cpuCanvas

                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12);
                            ctx.lineWidth = 7;
                            ctx.stroke();
                            var startAngle = -Math.PI / 2;
                            var progressAngle = (root.cpuLoadPercent / 100) * 2 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle);
                            ctx.strokeStyle = root.cpuStatusColor;
                            ctx.lineWidth = 7;
                            ctx.stroke();
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰻠"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMono
                                pixelSize: 22
                            }

                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.cpuLoadPercent + "%"
                            color: root.cpuStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 14
                                bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 26
                    implicitWidth: 148
                    radius: height / 2
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "CPU Load"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                            }

                        }

                        Text {
                            text: "•"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)

                            font {
                                pixelSize: 10
                            }

                        }

                        Text {
                            text: root.cpuStatusText
                            color: root.cpuStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                    }

                }

                Connections {
                    function onCpuLoadPercentChanged() {
                        cpuCanvas.requestPaint();
                    }

                    target: root
                }

            }

            // 🌀 2. GPU LOAD
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    id: gpuDisc

                    implicitWidth: 115
                    implicitHeight: 115
                    radius: width / 2
                    Layout.alignment: Qt.AlignHCenter
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1
                    onWidthChanged: gpuLoadCanvas.requestPaint()

                    Canvas {
                        id: gpuLoadCanvas

                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12);
                            ctx.lineWidth = 7;
                            ctx.stroke();
                            var startAngle = -Math.PI / 2;
                            var progressAngle = (root.gpuLoadPercent / 100) * 2 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle);
                            ctx.strokeStyle = root.gpuLoadStatusColor;
                            ctx.lineWidth = 7;
                            ctx.stroke();
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰢮"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMono
                                pixelSize: 22
                            }

                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.gpuLoadPercent + "%"
                            color: root.gpuLoadStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 14
                                bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 26
                    implicitWidth: 148
                    radius: height / 2
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "GPU Load"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                            }

                        }

                        Text {
                            text: "•"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)

                            font {
                                pixelSize: 10
                            }

                        }

                        Text {
                            text: root.gpuLoadStatusText
                            color: root.gpuLoadStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                    }

                }

                Connections {
                    function onGpuLoadPercentChanged() {
                        gpuLoadCanvas.requestPaint();
                    }

                    target: root
                }

            }

            // 🌀 3. CPU TEMP
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    id: cpuTempDisc

                    implicitWidth: 115
                    implicitHeight: 115
                    radius: width / 2
                    Layout.alignment: Qt.AlignHCenter
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1
                    onWidthChanged: tempCanvas.requestPaint()

                    Canvas {
                        id: tempCanvas

                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12);
                            ctx.lineWidth = 7;
                            ctx.stroke();
                            var startAngle = -Math.PI / 2;
                            var progressAngle = (Math.min(100, root.cpuTempValue) / 100) * 2 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle);
                            ctx.strokeStyle = root.tempStatusColor;
                            ctx.lineWidth = 7;
                            ctx.stroke();
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰔏"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMono
                                pixelSize: 22
                            }

                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.cpuTempText
                            color: root.tempStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 14
                                bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 26
                    implicitWidth: 148
                    radius: height / 2
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "CPU Temp"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                            }

                        }

                        Text {
                            text: "•"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)

                            font {
                                pixelSize: 10
                            }

                        }

                        Text {
                            text: root.tempStatusText
                            color: root.tempStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                    }

                }

                Connections {
                    function onCpuTempValueChanged() {
                        tempCanvas.requestPaint();
                    }

                    target: root
                }

            }

            // 🌀 4. GPU TEMP
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    id: gpuTempDisc

                    implicitWidth: 115
                    implicitHeight: 115
                    radius: width / 2
                    Layout.alignment: Qt.AlignHCenter
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1
                    onWidthChanged: gpuTempCanvas.requestPaint()

                    Canvas {
                        id: gpuTempCanvas

                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12);
                            ctx.lineWidth = 7;
                            ctx.stroke();
                            var startAngle = -Math.PI / 2;
                            var progressAngle = (Math.min(100, root.gpuTempValue) / 100) * 2 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle);
                            ctx.strokeStyle = root.gpuTempStatusColor;
                            ctx.lineWidth = 7;
                            ctx.stroke();
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰔏"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMono
                                pixelSize: 22
                            }

                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.gpuTempValue + "°C"
                            color: root.gpuTempStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 14
                                bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 26
                    implicitWidth: 148
                    radius: height / 2
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "GPU Temp"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                            }

                        }

                        Text {
                            text: "•"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)

                            font {
                                pixelSize: 10
                            }

                        }

                        Text {
                            text: root.gpuTempStatusText
                            color: root.gpuTempStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                    }

                }

                Connections {
                    function onGpuTempValueChanged() {
                        gpuTempCanvas.requestPaint();
                    }

                    target: root
                }

            }

            // 🌀 5. MEMORY (RAM)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    id: ramDisc

                    implicitWidth: 115
                    implicitHeight: 115
                    radius: width / 2
                    Layout.alignment: Qt.AlignHCenter
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1
                    onWidthChanged: ramCanvas.requestPaint()

                    Canvas {
                        id: ramCanvas

                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12);
                            ctx.lineWidth = 7;
                            ctx.stroke();
                            var startAngle = -Math.PI / 2;
                            var progressAngle = (root.ramPercent / 100) * 2 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle);
                            ctx.strokeStyle = root.ramStatusColor;
                            ctx.lineWidth = 7;
                            ctx.stroke();
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰍛"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMono
                                pixelSize: 22
                            }

                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.ramPercent + "%"
                            color: root.ramStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 14
                                bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 26
                    implicitWidth: 148
                    radius: height / 2
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "Memory"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                            }

                        }

                        Text {
                            text: "•"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)

                            font {
                                pixelSize: 10
                            }

                        }

                        Text {
                            text: root.ramUsageDetails
                            color: Theme.accent

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                    }

                }

                Connections {
                    function onRamPercentChanged() {
                        ramCanvas.requestPaint();
                    }

                    target: root
                }

            }

            // 🌀 6. STORAGE (DISK)
            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 6

                Rectangle {
                    id: diskDisc

                    implicitWidth: 115
                    implicitHeight: 115
                    radius: width / 2
                    Layout.alignment: Qt.AlignHCenter
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1
                    onWidthChanged: diskCanvas.requestPaint()

                    Canvas {
                        id: diskCanvas

                        anchors.fill: parent
                        onPaint: {
                            var ctx = getContext("2d");
                            ctx.clearRect(0, 0, width, height);
                            var centerX = width / 2, centerY = height / 2, radius = width / 2 - 9;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                            ctx.strokeStyle = Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12);
                            ctx.lineWidth = 7;
                            ctx.stroke();
                            var startAngle = -Math.PI / 2;
                            var progressAngle = (Math.min(100, Math.max(0, root.diskPercent)) / 100) * 2 * Math.PI;
                            ctx.beginPath();
                            ctx.arc(centerX, centerY, radius, startAngle, startAngle + progressAngle);
                            ctx.strokeStyle = root.diskStatusColor;
                            ctx.lineWidth = 7;
                            ctx.stroke();
                        }
                    }

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 1

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: "󰋊"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMono
                                pixelSize: 22
                            }

                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.diskPercent + "%"
                            color: root.diskStatusColor

                            font {
                                family: Theme.fontMain
                                pixelSize: 14
                                bold: true
                            }

                        }

                    }

                }

                Rectangle {
                    Layout.alignment: Qt.AlignHCenter
                    implicitHeight: 26
                    implicitWidth: 148
                    radius: height / 2
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 5

                        Text {
                            text: "Storage"
                            color: Theme.textMain

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                            }

                        }

                        Text {
                            text: "•"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3)

                            font {
                                pixelSize: 10
                            }

                        }

                        Text {
                            text: root.diskDetails
                            color: Theme.accent

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                    }

                }

                Connections {
                    function onDiskPercentChanged() {
                        diskCanvas.requestPaint();
                    }

                    target: root
                }

            }

        }

    }

}
