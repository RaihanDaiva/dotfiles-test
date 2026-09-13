import "../../../services"
import "../../../theme"
import "../../../widgets"
import "./sysStatsStyle"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell

// 🎛️ SYSTEM MONITOR PERFORMANCE POPUP (DYNAMIC ORIGINAL VS MACOS STYLE)
BasePopup {
    id: popupRoot

    property var statsRootItem: null
    property int cpuLoadPercent: 0
    property string cpuTempText: "0°C"
    property int cpuTempValue: 0
    property int gpuLoadPercent: 0
    property int gpuTempValue: 0
    property int ramPercent: 0
    property string ramUsageDetails: "0 / 0 GB"
    property int diskPercent: 0
    property string diskDetails: "0 / 0 GB"
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
    readonly property color diskStatusColor: diskPercent > 85 ? "#f38ba8" : (diskPercent > 70 ? "#f9e2af" : Theme.accent)

    targetItem: statsRootItem
    // 📐 UKURAN POPUP
    implicitWidth: 380
    implicitHeight: (styleLoader.item && styleLoader.item.implicitHeight > 0) ? styleLoader.item.implicitHeight + 32 : 555
    targetCardHeight: implicitHeight

    Loader {
        id: styleLoader

        anchors.fill: parent
        source: (SettingsStore.popupStyle === "macos") ? Qt.resolvedUrl("./sysStatsStyle/SysStatsStyleMacos.qml") : Qt.resolvedUrl("./sysStatsStyle/SysStatsStyleOriginal.qml")
        onLoaded: {
            if (item) {
                item.cpuLoadPercent = Qt.binding(() => {
                    return popupRoot.cpuLoadPercent;
                });
                item.cpuTempText = Qt.binding(() => {
                    return popupRoot.cpuTempText;
                });
                item.cpuTempValue = Qt.binding(() => {
                    return popupRoot.cpuTempValue;
                });
                item.gpuLoadPercent = Qt.binding(() => {
                    return popupRoot.gpuLoadPercent;
                });
                item.gpuTempValue = Qt.binding(() => {
                    return popupRoot.gpuTempValue;
                });
                item.ramPercent = Qt.binding(() => {
                    return popupRoot.ramPercent;
                });
                item.ramUsageDetails = Qt.binding(() => {
                    return popupRoot.ramUsageDetails;
                });
                item.diskPercent = Qt.binding(() => {
                    return popupRoot.diskPercent;
                });
                item.diskDetails = Qt.binding(() => {
                    return popupRoot.diskDetails;
                });
                item.cpuStatusText = Qt.binding(() => {
                    return popupRoot.cpuStatusText;
                });
                item.cpuStatusColor = Qt.binding(() => {
                    return popupRoot.cpuStatusColor;
                });
                item.tempStatusText = Qt.binding(() => {
                    return popupRoot.tempStatusText;
                });
                item.tempStatusColor = Qt.binding(() => {
                    return popupRoot.tempStatusColor;
                });
                item.gpuLoadStatusText = Qt.binding(() => {
                    return popupRoot.gpuLoadStatusText;
                });
                item.gpuLoadStatusColor = Qt.binding(() => {
                    return popupRoot.gpuLoadStatusColor;
                });
                item.gpuTempStatusText = Qt.binding(() => {
                    return popupRoot.gpuTempStatusText;
                });
                item.gpuTempStatusColor = Qt.binding(() => {
                    return popupRoot.gpuTempStatusColor;
                });
                item.ramStatusColor = Qt.binding(() => {
                    return popupRoot.ramStatusColor;
                });
                item.diskStatusColor = Qt.binding(() => {
                    return popupRoot.diskStatusColor;
                });
            }
        }
    }

}
