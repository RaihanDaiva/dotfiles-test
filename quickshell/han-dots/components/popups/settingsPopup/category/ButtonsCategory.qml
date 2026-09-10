import "../../../../services"
import "../../../../theme"
import "../../../../widgets"
import "../../../../widgets/settings"
import "../../../../widgets/styledButton"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🔘 BUTTONS CATEGORY PAGE — Isian settings untuk kustomisasi Button Style
Item {
    id: buttonsPage

    anchors.fill: parent

    ScrollView {
        id: scrollArea

        anchors.fill: parent
        clip: true

        ColumnLayout {
            width: scrollArea.availableWidth - 12
            spacing: 18

            // -------------------------------------------------------------
            // 🔘 SECTION 1: BUTTON THEME & FILL STYLE
            // -------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    spacing: 8

                    Text {
                        text: "󰓠"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 18
                        }

                    }

                    Text {
                        text: "Button Theme & Fill Style"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 16
                            bold: true
                        }

                    }

                }

                // 1. Button Style Selector Card
                SettingCard {
                    title: "Active Fill Style"
                    subtitle: (SettingsStore.buttonStyle === "solid") ? "Solid Fill (Material 3 / Android)" : "Translucent Outlined (Glass / Catppuccin)"

                    StyledButton {
                        text: "Solid"
                        buttonStyle: "solid"
                        implicitWidth: 75
                        implicitHeight: 36
                        selected: SettingsStore.buttonStyle === "solid"
                        onClicked: SettingsStore.buttonStyle = "solid"
                    }

                    StyledButton {
                        text: "Glass"
                        buttonStyle: "translucent"
                        implicitWidth: 75
                        implicitHeight: 36
                        selected: SettingsStore.buttonStyle === "translucent"
                        onClicked: SettingsStore.buttonStyle = "translucent"
                    }

                }

                // 2. Button Corner Radius Slider Card
                SettingCard {
                    title: "Button Corner Radius"
                    subtitle: "Corner curvature (" + Math.round(SettingsStore.buttonRadius) + "px)"

                    CustomSlider {
                        implicitWidth: 160
                        from: 2
                        to: 20
                        stepSize: 1
                        value: SettingsStore.buttonRadius
                        onValueChanged: SettingsStore.buttonRadius = Math.round(value)
                    }

                }

            }

            // -------------------------------------------------------------
            // 👁️ SECTION 2: LIVE PREVIEW SHOWCASE
            // -------------------------------------------------------------
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 10

                RowLayout {
                    spacing: 8

                    Text {
                        text: "󰈈"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 18
                        }

                    }

                    Text {
                        text: "Interactive Live Preview"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 16
                            bold: true
                        }

                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 125
                    radius: 14
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            text: "Sample Button States (Current Style: " + SettingsStore.buttonStyle.toUpperCase() + ", Radius: " + SettingsStore.buttonRadius + "px)"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)

                            font {
                                family: Theme.fontMain
                                pixelSize: 12
                                bold: true
                            }

                        }

                        RowLayout {
                            spacing: 12

                            StyledButton {
                                text: "Selected"
                                implicitWidth: 100
                                implicitHeight: 36
                                selected: true
                            }

                            StyledButton {
                                text: "Unselected"
                                implicitWidth: 100
                                implicitHeight: 36
                                selected: false
                            }

                            StyledButton {
                                text: "With Icon"
                                iconText: "󰄬"
                                implicitWidth: 115
                                implicitHeight: 36
                                selected: true
                            }

                        }

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
