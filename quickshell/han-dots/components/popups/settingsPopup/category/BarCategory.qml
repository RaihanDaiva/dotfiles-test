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
            width: scrollArea.availableWidth
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
                            pixelSize: 15
                        }

                    }

                    Text {
                        text: "Status Bar Appearance"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                            bold: true
                        }

                    }

                }

                // 1. Bar Opacity Slider Card
                SettingCard {
                    title: "Bar Opacity"
                    subtitle: Math.round(SettingsStore.barOpacity * 100) + "%"

                    CustomSlider {
                        implicitWidth: 140
                        from: 0.1
                        to: 1
                        stepSize: 0.02
                        value: SettingsStore.barOpacity
                        onValueChanged: SettingsStore.barOpacity = value
                    }

                }

                // 2. Bar Blur Effect Toggle Card
                SettingCard {
                    title: "Frosted Glass Blur Effect"
                    subtitle: SettingsStore.barBlurEnabled ? "Enabled (Frosted Glass Blur)" : "Disabled (Dark Solid)"

                    StyledSwitch {
                        checked: SettingsStore.barBlurEnabled
                        onCheckedChanged: SettingsStore.barBlurEnabled = checked
                    }

                }

                // 3. Bar Layout Style Selection Card
                SettingCard {
                    title: "Bar Layout Style"
                    subtitle: SettingsStore.barStyle === "islands" ? "3 Floating Islands (Separate Cards)" : "Unified Bar (Single Spanning Bar)"

                    RowLayout {
                        spacing: 6

                        StyledButton {
                            text: "Unified Bar"
                            selected: SettingsStore.barStyle === "unified"
                            onClicked: SettingsStore.barStyle = "unified"
                        }

                        StyledButton {
                            text: "3 Floating Islands"
                            selected: SettingsStore.barStyle === "islands"
                            onClicked: SettingsStore.barStyle = "islands"
                        }

                    }

                }

            }

        }

    }

}
