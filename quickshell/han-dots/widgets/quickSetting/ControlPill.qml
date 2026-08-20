import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🎛️ REUSABLE CONTROL PILL WRAPPER (DYNAMIC QUICKSETTINGS PILL STYLE RESOLVER)
Item {
    id: pillRoot

    property string iconText: "󰤨"
    property string titleText: "Wi-Fi"
    property string subtitleText: "Off"
    property bool isActive: false
    property bool isExpanded: false
    property bool showChevron: true
    property string quickSettingsStyle: SettingsStore.quickSettingsStyle

    signal toggleClicked()
    signal expandClicked()

    function updateStyle() {
        var styleName = pillRoot.quickSettingsStyle || "android";
        var formatted = styleName.charAt(0).toUpperCase() + styleName.slice(1).toLowerCase();
        var styleUrl = Qt.resolvedUrl("./pillStyle/PillStyle" + formatted + ".qml");
        styleLoader.setSource(styleUrl, {
            "iconText": pillRoot.iconText,
            "titleText": pillRoot.titleText,
            "subtitleText": pillRoot.subtitleText,
            "isActive": pillRoot.isActive,
            "isExpanded": pillRoot.isExpanded,
            "showChevron": pillRoot.showChevron
        });
    }

    function updateProps() {
        if (styleLoader.item) {
            styleLoader.item.iconText = pillRoot.iconText;
            styleLoader.item.titleText = pillRoot.titleText;
            styleLoader.item.subtitleText = pillRoot.subtitleText;
            styleLoader.item.isActive = pillRoot.isActive;
            styleLoader.item.isExpanded = pillRoot.isExpanded;
            styleLoader.item.showChevron = pillRoot.showChevron;
        }
    }

    implicitWidth: 160
    implicitHeight: 52
    Component.onCompleted: updateStyle()
    onQuickSettingsStyleChanged: updateStyle()
    onIconTextChanged: updateProps()
    onTitleTextChanged: updateProps()
    onSubtitleTextChanged: updateProps()
    onIsActiveChanged: updateProps()
    onIsExpandedChanged: updateProps()
    onShowChevronChanged: updateProps()

    Loader {
        id: styleLoader

        anchors.fill: parent
    }

    Connections {
        function onToggleClicked() {
            pillRoot.toggleClicked();
        }

        function onExpandClicked() {
            pillRoot.expandClicked();
        }

        target: styleLoader.item
        ignoreUnknownSignals: true
    }

}
