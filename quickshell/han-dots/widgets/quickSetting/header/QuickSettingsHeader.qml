import "../../../services"
import QtQuick
import QtQuick.Layouts

Item {
    id: headerRoot

    property string userNameText: "User"
    property string batIcon: "󰁹"
    property int batCap: 100
    property string popupStyle: SettingsStore.popupStyle || "macos"

    signal gearClicked()

    function updateStyle() {
        var styleName = (headerRoot.popupStyle === "macos") ? "Macos" : "Original";
        var styleUrl = Qt.resolvedUrl("./headerStyle/HeaderStyle" + styleName + ".qml");
        styleLoader.setSource(styleUrl, {
            "userNameText": headerRoot.userNameText,
            "batIcon": headerRoot.batIcon,
            "batCap": headerRoot.batCap
        });
    }

    function updateProps() {
        if (styleLoader.item) {
            styleLoader.item.userNameText = headerRoot.userNameText;
            styleLoader.item.batIcon = headerRoot.batIcon;
            styleLoader.item.batCap = headerRoot.batCap;
        }
    }

    implicitWidth: (styleLoader.item && styleLoader.item.implicitWidth > 0) ? styleLoader.item.implicitWidth : 328
    implicitHeight: (styleLoader.item && styleLoader.item.implicitHeight > 0) ? styleLoader.item.implicitHeight : (popupStyle === "macos" ? 36 : 55)
    Layout.fillWidth: true
    Layout.preferredHeight: implicitHeight
    Component.onCompleted: updateStyle()
    onPopupStyleChanged: updateStyle()
    onUserNameTextChanged: updateProps()
    onBatIconChanged: updateProps()
    onBatCapChanged: updateProps()

    Loader {
        id: styleLoader

        anchors.fill: parent
    }

    Connections {
        function onGearClicked() {
            headerRoot.gearClicked();
        }

        target: styleLoader.item
        ignoreUnknownSignals: true
    }

}
