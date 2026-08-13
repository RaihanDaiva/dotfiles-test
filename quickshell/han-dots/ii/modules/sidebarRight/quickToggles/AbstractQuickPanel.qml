import QtQuick
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

Rectangle {
    id: root

    radius: Appearance.rounding.normal
    // color: ColorUtils.transparentize(Appearance.colors.colLayer1, 0.85)
    // border.width: 0.5
    // border.color: "#e2e2e2"
    color: "transparent"

    signal openAudioOutputDialog()
    signal openAudioInputDialog()
    signal openBluetoothDialog()
    signal openNightLightDialog()
    signal openWifiDialog()
}
