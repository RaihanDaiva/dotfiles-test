import "../../../../services"
import "../../../../theme"
import "../../../../widgets"
import "../../../../widgets/settings"
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
                SettingCard {
                    title: "Popup Opacity"
                    subtitle: Math.round(SettingsStore.popupOpacity * 100) + "%"

                    CustomSlider {
                        implicitWidth: 140
                        from: 0.5
                        to: 1
                        stepSize: 0.02
                        value: SettingsStore.popupOpacity
                        onValueChanged: SettingsStore.popupOpacity = value
                    }

                }

                // 2. Popup Corner Radius Slider
                SettingCard {
                    title: "Corner Radius"
                    subtitle: SettingsStore.popupRadius + " px"

                    CustomSlider {
                        implicitWidth: 140
                        from: 10
                        to: 28
                        stepSize: 1
                        value: SettingsStore.popupRadius
                        onValueChanged: SettingsStore.popupRadius = value
                    }

                }

                // 3. Popup Border Width Slider
                SettingCard {
                    title: "Border Width"
                    subtitle: SettingsStore.popupBorderWidth + " px"

                    CustomSlider {
                        implicitWidth: 140
                        from: 0
                        to: 8
                        stepSize: 1
                        value: SettingsStore.popupBorderWidth
                        onValueChanged: SettingsStore.popupBorderWidth = value
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
                SettingCard {
                    title: "Frosted Album Art Background"
                    subtitle: SettingsStore.mediaBlurBgEnabled ? "Enabled (Cover Art Blur)" : "Disabled (Dark Solid)"

                    StyledSwitch {
                        checked: SettingsStore.mediaBlurBgEnabled
                        onCheckedChanged: SettingsStore.mediaBlurBgEnabled = checked
                    }

                }

                // 2. Media Player Layout Style Selector
                SettingCard {
                    title: "Popup Layout Style"
                    subtitle: (SettingsStore.mediaPlayerStyle === "minimalist") ? "Minimalist (Compact 340x155)" : "Classic (Full 310x485)"

                    StyledButton {
                        text: "Classic"
                        implicitWidth: 70
                        implicitHeight: 32
                        selected: SettingsStore.mediaPlayerStyle !== "minimalist"
                        onClicked: SettingsStore.mediaPlayerStyle = "classic"
                    }

                    StyledButton {
                        text: "Minimalist"
                        implicitWidth: 80
                        implicitHeight: 32
                        selected: SettingsStore.mediaPlayerStyle === "minimalist"
                        onClicked: SettingsStore.mediaPlayerStyle = "minimalist"
                    }

                }

            }

            // -------------------------------------------------------------
            // 🎛️ SECTION 3: QUICK SETTING POPUP SETTINGS
            // -------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    spacing: 8

                    Text {
                        text: "󰒓"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 15
                        }

                    }

                    Text {
                        text: "Quick Setting Popup"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                            bold: true
                        }

                    }

                }

                // 1. QuickSettings Pill Shape Selector
                SettingCard {
                    title: "QuickSettings Pill Shape"
                    subtitle: (SettingsStore.quickSettingsStyle === "macos") ? "MacOS Style (Capsule Rounded)" : "Android Style (Material 3 16px)"

                    StyledButton {
                        text: "Android"
                        implicitWidth: 70
                        implicitHeight: 32
                        selected: SettingsStore.quickSettingsStyle === "android"
                        onClicked: SettingsStore.quickSettingsStyle = "android"
                    }

                    StyledButton {
                        text: "MacOS"
                        implicitWidth: 70
                        implicitHeight: 32
                        selected: SettingsStore.quickSettingsStyle === "macos"
                        onClicked: SettingsStore.quickSettingsStyle = "macos"
                    }

                }

            }

        }

    }

}
