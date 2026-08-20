import "../../services"
import "../../theme"
import QtQuick
import QtQuick.Controls

// 🔘 REUSABLE STYLED BUTTON WRAPPER
// Mendukung berbagai style dinamis (solid, translucent, dsb) tanpa ternary logic panjang!
Item {
    id: buttonRoot

    property string text: ""
    property string iconText: ""
    property bool selected: false
    property string buttonStyle: SettingsStore.buttonStyle
    property real radius: 8

    signal clicked()

    function updateStyle() {
        var styleName = buttonRoot.buttonStyle || "solid";
        var formatted = styleName.charAt(0).toUpperCase() + styleName.slice(1).toLowerCase();
        var styleUrl = Qt.resolvedUrl("./buttonStyle/ButtonStyle" + formatted + ".qml");
        styleLoader.setSource(styleUrl, {
            "text": buttonRoot.text,
            "iconText": buttonRoot.iconText,
            "selected": buttonRoot.selected,
            "cornerRadius": buttonRoot.radius
        });
    }

    function updateProps() {
        if (styleLoader.item) {
            styleLoader.item.text = buttonRoot.text;
            styleLoader.item.iconText = buttonRoot.iconText;
            styleLoader.item.selected = buttonRoot.selected;
            styleLoader.item.cornerRadius = buttonRoot.radius;
        }
    }

    implicitWidth: 80
    implicitHeight: 32
    Component.onCompleted: updateStyle()
    onButtonStyleChanged: updateStyle()
    onTextChanged: updateProps()
    onIconTextChanged: updateProps()
    onSelectedChanged: updateProps()
    onRadiusChanged: updateProps()

    Loader {
        id: styleLoader

        anchors.fill: parent
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: buttonRoot.clicked()
    }

}
