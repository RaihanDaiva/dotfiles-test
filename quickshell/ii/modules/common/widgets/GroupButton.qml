import qs.modules.common
import qs.modules.common.widgets
import qs.modules.common.functions
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

/**
 * Material 3 button with expressive bounciness. 
 * See https://m3.material.io/components/button-groups/overview
 */
Button {
    id: root
    property bool toggled
    property string buttonText
    property real buttonRadius: Appearance?.rounding?.small ?? 8
    property real buttonRadiusPressed: Appearance?.rounding?.small ?? 6
    property var downAction // When left clicking (down)
    property var releaseAction // When left clicking (release)
    property var altAction // When right clicking
    property var middleClickAction // When middle clicking
    property bool bounce: true
    property real baseWidth: contentItem.implicitWidth + horizontalPadding * 2
    property real baseHeight: contentItem.implicitHeight + verticalPadding * 2
    property bool enableImplicitWidthAnimation: true
    property bool enableImplicitHeightAnimation: true
    property real clickedWidth: baseWidth + (isAtSide ? 10 : 20)
    property real clickedHeight: baseHeight
    property var parentGroup: root.parent
    property int indexInParent: parentGroup?.children.indexOf(root) ?? -1
    property int clickIndex: parentGroup?.clickIndex ?? -1
    property bool isAtSide: indexInParent === 0 || indexInParent === (parentGroup?.childrenCount - 1)

    Layout.fillWidth: (clickIndex - 1 <= indexInParent && indexInParent <= clickIndex + 1)
    Layout.fillHeight: (clickIndex - 1 <= indexInParent && indexInParent <= clickIndex + 1)
    implicitWidth: (root.down && bounce) ? clickedWidth : baseWidth
    implicitHeight: (root.down && bounce) ? clickedHeight : baseHeight

    property color colBackground: ColorUtils.transparentize(colBackgroundHover, 1) || "transparent"
    property color colBackgroundHover: Appearance?.colors.colLayer1Hover ?? "#E5DFED"
    property color colBackgroundActive: Appearance?.colors.colLayer1Active ?? "#D6CEE2"
    property color colBackgroundToggled: Appearance?.colors.colPrimary ?? "#65558F"
    property color colBackgroundToggledHover: Appearance?.colors.colPrimaryHover ?? "#77699C"
    property color colBackgroundToggledActive: Appearance?.colors.colPrimaryActive ?? "S#6600ffff"

    property real radius: root.down ? root.buttonRadiusPressed : root.buttonRadius
    property real leftRadius: root.down ? root.buttonRadiusPressed : root.buttonRadius
    property real rightRadius: root.down ? root.buttonRadiusPressed : root.buttonRadius
    property color color: root.enabled ? (root.toggled ? 
        (root.down ? colBackgroundToggledActive : 
            root.hovered ? colBackgroundToggledHover : 
            colBackgroundToggled) :
        (root.down ? colBackgroundActive : 
            root.hovered ? colBackgroundHover : 
            colBackground)) : colBackground

    onDownChanged: {
        if (root.down) {
            if (root.parent.clickIndex !== undefined) {
                root.parent.clickIndex = parent.children.indexOf(root)
            }
        }
    }

    Behavior on implicitWidth {
        enabled: root.enableImplicitWidthAnimation
        animation: Appearance.animation.clickBounce.numberAnimation.createObject(this)
    }

    Behavior on implicitHeight {
        enabled: root.enableImplicitHeightAnimation
        animation: Appearance.animation.clickBounce.numberAnimation.createObject(this)
    }

    Behavior on leftRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }
    Behavior on rightRadius {
        animation: Appearance.animation.elementMoveFast.numberAnimation.createObject(this)
    }

    property alias mouseArea: buttonMouseArea
    MouseArea {
        id: buttonMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: (event) => { 
            if(event.button === Qt.RightButton) {
                if (root.altAction) root.altAction();
                return;
            }
            if(event.button === Qt.MiddleButton) {
                if (root.middleClickAction) root.middleClickAction();
                return;
            }
            root.down = true
            if (root.downAction) root.downAction();
        }
        onReleased: (event) => {
            root.down = false
            if (event.button != Qt.LeftButton) return;
            if (root.releaseAction) root.releaseAction();
        }
        onClicked: (event) => {
            if (event.button != Qt.LeftButton) return;
            root.click()
        }
        onCanceled: (event) => {
            root.down = false
        }

        onPressAndHold: () => {
            altAction(); 
            root.down = false; 
            root.clicked = false;
        };
    }


    // background: Rectangle {
    //     id: buttonBackground
    //     topLeftRadius: root.leftRadius
    //     topRightRadius: root.rightRadius
    //     bottomLeftRadius: root.leftRadius
    //     bottomRightRadius: root.rightRadius
    //     implicitHeight: 50

    //     // Default
    //     color: root.color
    //     Behavior on color {
    //         animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    //     }

    //     // --- UBAH MENJADI INI ---
    //     // color: ColorUtils.transparentize(Appearance.colors.colLayer1, 0.85)
        
    //     // Aktifkan border agar terlihat rapi
    //     // border.width: 0.5
    //     // border.color: ColorUtils.transparentize("#e2e2e2", 0.5)

    //     // // Animasi warna (tetap biarkan agar transisi halus jika ada perubahan)
    //     // Behavior on color {
    //     //     animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
    //     // }

    // //         color: ColorUtils.transparentize(Appearance.colors.colLayer1, 0.85)
    // // border.width: 0.5
    // // border.color: ColorUtils.transparentize("#e2e2e2", 0.5)
    // }

background: Rectangle {
        id: buttonBackground
        topLeftRadius: root.leftRadius
        topRightRadius: root.rightRadius
        bottomLeftRadius: root.leftRadius
        bottomRightRadius: root.rightRadius
        implicitHeight: 50

        // --- [LOGIKA HYBRID] ---

        color: root.toggled ? 
            // 1. KONDISI AKTIF (ON): 
            // Gunakan warna SOLID/TERFILL (Primary Color)
            // Ditambah logika hover/klik agar interaktif
            (root.down ? root.colBackgroundToggledActive : 
             root.hovered ? root.colBackgroundToggledHover : 
             root.colBackgroundToggled) :
            
            // 2. KONDISI MATI (OFF): 
            // Gunakan warna TRANSPARAN (Glass Style)
            ColorUtils.transparentize(Appearance.colors.colLayer1, 0.85)

        // --- [BORDER] ---
        // Saat Solid (Aktif), hilangkan border (0) agar terlihat bersih/modern.
        // Saat Transparan (Mati), tampilkan border tipis (0.5) sebagai batas.
        border.width: root.toggled ? 0 : 0.5
        
        border.color: ColorUtils.transparentize("#e2e2e2", 0.5)

        // --------------------

        Behavior on color {
            animation: Appearance.animation.elementMoveFast.colorAnimation.createObject(this)
        }
        
        Behavior on border.width {
            NumberAnimation { duration: 200 }
        }
    }
}
