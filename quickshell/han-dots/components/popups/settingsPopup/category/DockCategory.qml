import "../../../../services"
import "../../../../theme"
import "../../../../widgets"
import "../../../../widgets/settings"
import "../../../../widgets/styledButton"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// ⛵ DOCK CATEGORY PAGE — Isian settings untuk kustomisasi Application Dock
Item {
    id: dockPage

    anchors.fill: parent

    ScrollView {
        id: scrollArea

        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: scrollArea.availableWidth
            spacing: 18

            // -------------------------------------------------------------
            // ⛵ SECTION 1: DOCK TOGGLE & SETTINGS
            // -------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    spacing: 8

                    Text {
                        text: "󰀻"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 15
                        }

                    }

                    Text {
                        text: "Application Dock Settings"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                            bold: true
                        }

                    }

                }

                // 1. Enable Application Dock Toggle Card
                SettingCard {
                    title: "Enable Application Dock"
                    subtitle: SettingsStore.dockEnabled ? "Enabled (Bottom Center Dock)" : "Disabled (Hidden)"

                    StyledSwitch {
                        checked: SettingsStore.dockEnabled
                        onCheckedChanged: SettingsStore.dockEnabled = checked
                    }

                }

                // 2. Dock Behavior Mode Selection Card
                SettingCard {
                    title: "Dock Behavior Mode"
                    subtitle: SettingsStore.dockMode === "always_visible" ? "Always Visible (Reserves Screen Area)" : (SettingsStore.dockMode === "auto_hide" ? "Auto Hide (Hover to Reveal Overlay)" : "Floating Overlay (Always Above Windows)")

                    RowLayout {
                        spacing: 6

                        StyledButton {
                            text: "Always Visible"
                            selected: SettingsStore.dockMode === "always_visible"
                            onClicked: SettingsStore.dockMode = "always_visible"
                        }

                        StyledButton {
                            text: "Auto Hide"
                            selected: SettingsStore.dockMode === "auto_hide"
                            onClicked: SettingsStore.dockMode = "auto_hide"
                        }

                        StyledButton {
                            text: "Overlay"
                            selected: SettingsStore.dockMode === "overlay"
                            onClicked: SettingsStore.dockMode = "overlay"
                        }

                    }

                }

                // 3. Dock Blur Effect Toggle Card
                SettingCard {
                    title: "Frosted Glass Blur Effect"
                    subtitle: SettingsStore.dockBlurEnabled ? "Enabled (Frosted Glass Blur)" : "Disabled (Dark Solid)"

                    StyledSwitch {
                        checked: SettingsStore.dockBlurEnabled
                        onCheckedChanged: SettingsStore.dockBlurEnabled = checked
                    }

                }

            }

        }

    }

}
