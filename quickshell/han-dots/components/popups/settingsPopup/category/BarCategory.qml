import "../../../../services"
import "../../../../theme"
import "../../../../widgets"
import "../../../../widgets/settings"
import "../../../../widgets/styledButton"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🏛️ BAR CATEGORY PAGE — Isian settings untuk kustomisasi Status Bar
Item {
    id: barPage

    anchors.fill: parent

    ScrollView {
        id: scrollArea

        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: scrollArea.availableWidth - 12
            spacing: 18

            // -------------------------------------------------------------
            // 🏛️ SECTION 1: STATUS BAR APPEARANCE & BLUR
            // -------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    spacing: 8

                    Text {
                        text: "󰈹"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 18
                        }

                    }

                    Text {
                        text: "Status Bar Appearance"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 16
                            bold: true
                        }

                    }

                }

                // 1. Bar Rectangle Background Toggle Card
                SettingCard {
                    title: "Bar Rectangle Background"
                    subtitle: SettingsStore.barBgEnabled ? "Enabled (Visible Background Card)" : "Disabled (No Background Card & Blur Disabled)"

                    StyledSwitch {
                        checked: SettingsStore.barBgEnabled
                        onCheckedChanged: SettingsStore.barBgEnabled = checked
                    }

                }

                // 2. Bar Layout Style Selection Card (Disabled when barBgEnabled is false)
                SettingCard {
                    title: "Bar Layout Style"
                    subtitle: !SettingsStore.barBgEnabled ? "Disabled (Defaulted to Unified Bar)" : (SettingsStore.barStyle === "islands" ? "3 Floating Islands (Separate Cards)" : "Unified Bar (Single Spanning Bar)")

                    RowLayout {
                        spacing: 8
                        enabled: SettingsStore.barBgEnabled
                        opacity: SettingsStore.barBgEnabled ? 1 : 0.45

                        StyledButton {
                            text: "Unified Bar"
                            implicitHeight: 36
                            selected: SettingsStore.barStyle === "unified"
                            onClicked: SettingsStore.barStyle = "unified"
                        }

                        StyledButton {
                            text: "3 Floating Islands"
                            implicitHeight: 36
                            selected: SettingsStore.barStyle === "islands"
                            onClicked: SettingsStore.barStyle = "islands"
                        }

                    }

                }

                // 3. Bar Opacity Slider Card
                SettingCard {
                    title: "Bar Opacity"
                    subtitle: Math.round(SettingsStore.barOpacity * 100) + "%"

                    CustomSlider {
                        implicitWidth: 160
                        enabled: SettingsStore.barBgEnabled
                        opacity: SettingsStore.barBgEnabled ? 1 : 0.45
                        from: 0.1
                        to: 1
                        stepSize: 0.02
                        value: SettingsStore.barOpacity
                        onValueChanged: SettingsStore.barOpacity = value
                    }

                }

                // 4. Bar Blur Effect Toggle Card
                SettingCard {
                    title: "Frosted Glass Blur Effect"
                    subtitle: !SettingsStore.barBgEnabled ? "Disabled (Background Card Disabled)" : (SettingsStore.barBlurEnabled ? "Enabled (Frosted Glass Blur)" : "Disabled (Dark Solid)")

                    StyledSwitch {
                        enabled: SettingsStore.barBgEnabled
                        opacity: SettingsStore.barBgEnabled ? 1 : 0.45
                        checked: SettingsStore.barBlurEnabled
                        onCheckedChanged: SettingsStore.barBlurEnabled = checked
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
