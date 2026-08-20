import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🎚️ REUSABLE STYLED SLIDER WRAPPER (DYNAMIC QUICKSETTINGS SLIDER STYLE RESOLVER)
Item {
    id: sliderRoot

    property string iconText: "󰃠"
    property string titleText: "Brightness"
    property real value: 50
    property real maxValue: 100
    property string valueSuffix: "%"
    property color iconColor: Theme.accent
    property color fillColor: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25)
    property color textColor: Theme.textMain
    property real cornerRadius: 12
    property string quickSettingsStyle: SettingsStore.quickSettingsStyle

    signal valueMoved(real newValue)
    signal valuePressed(real newValue)

    function updateStyle() {
        var styleName = sliderRoot.quickSettingsStyle || "android";
        var formatted = styleName.charAt(0).toUpperCase() + styleName.slice(1).toLowerCase();
        var styleUrl = Qt.resolvedUrl("./sliderStyle/SliderStyle" + formatted + ".qml");
        styleLoader.setSource(styleUrl, {
            "iconText": sliderRoot.iconText,
            "titleText": sliderRoot.titleText,
            "value": sliderRoot.value,
            "maxValue": sliderRoot.maxValue,
            "valueSuffix": sliderRoot.valueSuffix,
            "iconColor": sliderRoot.iconColor,
            "fillColor": sliderRoot.fillColor,
            "textColor": sliderRoot.textColor,
            "cornerRadius": sliderRoot.cornerRadius
        });
    }

    function updateProps() {
        if (styleLoader.item) {
            styleLoader.item.iconText = sliderRoot.iconText;
            styleLoader.item.titleText = sliderRoot.titleText;
            styleLoader.item.value = sliderRoot.value;
            styleLoader.item.maxValue = sliderRoot.maxValue;
            styleLoader.item.valueSuffix = sliderRoot.valueSuffix;
            styleLoader.item.iconColor = sliderRoot.iconColor;
            styleLoader.item.fillColor = sliderRoot.fillColor;
            styleLoader.item.textColor = sliderRoot.textColor;
            styleLoader.item.cornerRadius = sliderRoot.cornerRadius;
        }
    }

    implicitWidth: 200
    implicitHeight: 46
    Layout.fillWidth: true
    Component.onCompleted: updateStyle()
    onQuickSettingsStyleChanged: updateStyle()
    onIconTextChanged: updateProps()
    onTitleTextChanged: updateProps()
    onValueChanged: updateProps()
    onMaxValueChanged: updateProps()
    onValueSuffixChanged: updateProps()
    onIconColorChanged: updateProps()
    onFillColorChanged: updateProps()
    onTextColorChanged: updateProps()
    onCornerRadiusChanged: updateProps()

    Loader {
        id: styleLoader

        anchors.fill: parent
    }

    Connections {
        function onValueMoved(val) {
            sliderRoot.valueMoved(val);
        }

        function onValuePressed(val) {
            sliderRoot.valuePressed(val);
        }

        target: styleLoader.item
        ignoreUnknownSignals: true
    }

}
