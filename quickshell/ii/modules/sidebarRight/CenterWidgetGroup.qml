import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import qs.services
import qs.modules.sidebarRight.notifications
import qs.modules.sidebarRight.volumeMixer
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: root
    radius: Appearance.rounding.normal
    // color: ColorUtils.transparentize(Appearance.colors.colLayer1, 0.85)
    // border.width: 0.5
    // border.color: ColorUtils.transparentize("#e2e2e2", 0.5)
    color: "transparent"

    NotificationList {
        anchors.fill: parent
        anchors.margins: 5
    }
}
