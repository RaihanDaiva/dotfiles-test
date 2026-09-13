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
            width: scrollArea.availableWidth - 12
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
                            pixelSize: 18
                        }

                    }

                    Text {
                        text: "Global Popup Settings"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 16
                            bold: true
                        }

                    }

                }

                // 1. Popup Style Selector (Original vs macOS)
                SettingCard {
                    title: "Popup Style"
                    subtitle: (SettingsStore.popupStyle === "macos") ? "macOS (Frameless Transparent)" : "Original (Crisp Rounded Border)"

                    StyledButton {
                        text: "Original"
                        implicitWidth: 80
                        implicitHeight: 36
                        selected: SettingsStore.popupStyle !== "macos"
                        onClicked: SettingsStore.popupStyle = "original"
                    }

                    StyledButton {
                        text: "macOS"
                        implicitWidth: 80
                        implicitHeight: 36
                        selected: SettingsStore.popupStyle === "macos"
                        onClicked: SettingsStore.popupStyle = "macos"
                    }

                }

                // 2. Enable Backdrop Blur Toggle
                SettingCard {
                    title: "Backdrop Blur"
                    subtitle: SettingsStore.enableBlur ? "Enabled (Frosted Wallpaper Blur)" : "Disabled (Dark Tint Only)"

                    StyledSwitch {
                        checked: SettingsStore.enableBlur
                        onCheckedChanged: SettingsStore.enableBlur = checked
                    }

                }

                // 3. Popup Opacity Slider
                SettingCard {
                    title: "Popup Opacity"
                    subtitle: Math.round(SettingsStore.popupOpacity * 100) + "%"

                    CustomSlider {
                        implicitWidth: 160
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
                        implicitWidth: 160
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
                        implicitWidth: 160
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
                            pixelSize: 18
                        }

                    }

                    Text {
                        text: "Media Player Popup"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 16
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
                        implicitWidth: 80
                        implicitHeight: 36
                        selected: SettingsStore.mediaPlayerStyle !== "minimalist"
                        onClicked: SettingsStore.mediaPlayerStyle = "classic"
                    }

                    StyledButton {
                        text: "Minimalist"
                        implicitWidth: 90
                        implicitHeight: 36
                        selected: SettingsStore.mediaPlayerStyle === "minimalist"
                        onClicked: SettingsStore.mediaPlayerStyle = "minimalist"
                    }

                }

            }

        }

        ScrollBar.vertical: StyledScrollBar {
            parent: scrollArea
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.rightMargin: 2
        }

    }

}
