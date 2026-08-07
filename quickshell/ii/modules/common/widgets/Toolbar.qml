import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions

/**
 * Material 3 expressive style toolbar.
 * https://m3.material.io/components/toolbars
 */
Item {
    id: root

    property real padding: 8
    property alias colBackground: background.color
    property alias spacing: toolbarLayout.spacing
    default property alias data: toolbarLayout.data
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    property alias radius: background.radius

    // StyledRectangularShadow {
    //     target: background
    // }

    Rectangle {
        id: background
        anchors.fill: parent
        color: ColorUtils.transparentize(Appearance.colors.colLayer1, 0.85)
        border.width: 0.5
        border.color: ColorUtils.transparentize("#e2e2e2", 0.5)
        implicitHeight: Math.max(toolbarLayout.implicitHeight + root.padding * 2, 56)
        implicitWidth: toolbarLayout.implicitWidth + root.padding * 2
        radius: height / 2

        RowLayout {
            id: toolbarLayout
            spacing: 4
            anchors {
                fill: parent
                margins: root.padding
            }
        }
    }
}
