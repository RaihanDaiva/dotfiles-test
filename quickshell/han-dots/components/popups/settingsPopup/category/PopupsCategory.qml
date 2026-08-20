import "../../../../services"
import "../../../../theme"
import "../../../../widgets"
import "../../../../widgets/styledButton"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🪟 POPUPS CATEGORY PAGE — Isian settings untuk kategori Popups
Item {
    id: popupsPage

    anchors.fill: parent

    ScrollView {
        id: scrollArea

        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: scrollArea.availableWidth
            spacing: 18

            // -------------------------------------------------------------
            // 🪟 SECTION 1: GLOBAL POPUP SETTINGS
            // -------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    spacing: 8

                    Text {
                        text: "󰖯"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 15
                        }

                    }

                    Text {
                        text: "Global Popup Settings"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                            bold: true
                        }

                    }

                }

                // 1. Popup Opacity Slider
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 54
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Popup Opacity"
                                color: Theme.textMain

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            Text {
                                text: Math.round(SettingsStore.popupOpacity * 100) + "%"
                                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 11
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CustomSlider {
                            from: 0.5
                            to: 1
                            value: SettingsStore.popupOpacity
                            stepSize: 0.02
                            implicitWidth: 140
                            onValueChanged: SettingsStore.popupOpacity = value
                        }

                    }

                }

                // 2. Popup Corner Radius Slider
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 54
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Corner Radius"
                                color: Theme.textMain

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            Text {
                                text: SettingsStore.popupRadius + " px"
                                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 11
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CustomSlider {
                            from: 10
                            to: 28
                            value: SettingsStore.popupRadius
                            stepSize: 1
                            implicitWidth: 140
                            onValueChanged: SettingsStore.popupRadius = value
                        }

                    }

                }

                // 3. Popup Border Width Slider
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 54
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Border Width"
                                color: Theme.textMain

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            Text {
                                text: SettingsStore.popupBorderWidth + " px"
                                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 11
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        CustomSlider {
                            from: 0
                            to: 8
                            value: SettingsStore.popupBorderWidth
                            stepSize: 1
                            implicitWidth: 140
                            onValueChanged: SettingsStore.popupBorderWidth = value
                        }

                    }

                }

            }

            // -------------------------------------------------------------
            // 🎵 SECTION 2: MEDIA PLAYER POPUP SETTINGS
            // -------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    spacing: 8

                    Text {
                        text: "󰝚"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 15
                        }

                    }

                    Text {
                        text: "Media Player Popup"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                            bold: true
                        }

                    }

                }

                // 1. Cover Album Background Blur Toggle
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 54
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Frosted Album Art Background"
                                color: Theme.textMain

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            Text {
                                text: SettingsStore.mediaBlurBgEnabled ? "Enabled (Cover Art Blur)" : "Disabled (Dark Solid)"
                                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 11
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        StyledSwitch {
                            checked: SettingsStore.mediaBlurBgEnabled
                            onCheckedChanged: SettingsStore.mediaBlurBgEnabled = checked
                        }

                    }

                }

                // 2. Media Player Layout Style Selector
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Popup Layout Style"
                                color: Theme.textMain

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            Text {
                                text: (SettingsStore.mediaPlayerStyle === "minimalist") ? "Minimalist (Compact 340x155)" : "Classic (Full 310x485)"
                                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 11
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 6

                            // Classic Option Pill
                            StyledButton {
                                text: "Classic"
                                implicitWidth: 70
                                implicitHeight: 32
                                selected: SettingsStore.mediaPlayerStyle !== "minimalist"
                                onClicked: SettingsStore.mediaPlayerStyle = "classic"
                            }

                            // Minimalist Option Pill
                            StyledButton {
                                text: "Minimalist"
                                implicitWidth: 80
                                implicitHeight: 32
                                selected: SettingsStore.mediaPlayerStyle === "minimalist"
                                onClicked: SettingsStore.mediaPlayerStyle = "minimalist"
                            }

                        }

                    }

                }

                // 3. Global Button Theme Style Selector
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 64
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        spacing: 12

                        ColumnLayout {
                            spacing: 2

                            Text {
                                text: "Global Button Style"
                                color: Theme.textMain

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            Text {
                                text: (SettingsStore.buttonStyle === "solid") ? "Solid Fill (Material 3)" : "Translucent Outlined (Glass)"
                                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 11
                                }

                            }

                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        RowLayout {
                            spacing: 6

                            StyledButton {
                                text: "Solid"
                                buttonStyle: "solid"
                                implicitWidth: 65
                                implicitHeight: 32
                                selected: SettingsStore.buttonStyle === "solid"
                                onClicked: SettingsStore.buttonStyle = "solid"
                            }

                            StyledButton {
                                text: "Glass"
                                buttonStyle: "translucent"
                                implicitWidth: 65
                                implicitHeight: 32
                                selected: SettingsStore.buttonStyle === "translucent"
                                onClicked: SettingsStore.buttonStyle = "translucent"
                            }

                        }

                    }

                }

            }

        }

    }

    // 🎚️ CUSTOM STYLED SLIDER
    component CustomSlider: Slider {
        id: sliderRoot

        implicitWidth: 140
        implicitHeight: 24

        background: Rectangle {
            x: sliderRoot.leftPadding
            y: sliderRoot.topPadding + sliderRoot.availableHeight / 2 - height / 2
            implicitWidth: 140
            implicitHeight: 6
            width: sliderRoot.availableWidth
            height: implicitHeight
            radius: 3
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)

            Rectangle {
                width: sliderRoot.visualPosition * parent.width
                height: parent.height
                color: Theme.accent
                radius: 3
            }

        }

        handle: Rectangle {
            x: sliderRoot.leftPadding + sliderRoot.visualPosition * (sliderRoot.availableWidth - width)
            y: sliderRoot.topPadding + sliderRoot.availableHeight / 2 - height / 2
            implicitWidth: 16
            implicitHeight: 16
            radius: 8
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.95)
        }

    }

}
