import "../../../../services"
import "../../../../theme"
import "../../../../widgets"
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
            width: scrollArea.availableWidth
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
                            pixelSize: 16
                        }

                    }

                    Text {
                        text: "Button Theme & Fill Style"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                            bold: true
                        }

                    }

                }

                // 1. Button Style Selector Card
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
                                text: "Active Fill Style"
                                color: Theme.textMain

                                font {
                                    family: Theme.fontMain
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            Text {
                                text: (SettingsStore.buttonStyle === "solid") ? "Solid Fill (Material 3 / Android)" : "Translucent Outlined (Glass / Catppuccin)"
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
                            pixelSize: 16
                        }

                    }

                    Text {
                        text: "Interactive Live Preview"
                        color: Theme.accent

                        font {
                            family: Theme.fontMain
                            pixelSize: 14
                            bold: true
                        }

                    }

                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 110
                    radius: 12
                    color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                    border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 10

                        Text {
                            text: "Sample Button States (Current Style: " + SettingsStore.buttonStyle.toUpperCase() + ")"
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)

                            font {
                                family: Theme.fontMain
                                pixelSize: 11
                                bold: true
                            }

                        }

                        RowLayout {
                            spacing: 12

                            StyledButton {
                                text: "Selected"
                                implicitWidth: 90
                                implicitHeight: 32
                                selected: true
                            }

                            StyledButton {
                                text: "Unselected"
                                implicitWidth: 95
                                implicitHeight: 32
                                selected: false
                            }

                            StyledButton {
                                text: "With Icon"
                                iconText: "󰄬"
                                implicitWidth: 100
                                implicitHeight: 32
                                selected: true
                            }

                        }

                    }

                }

            }

        }

    }

}
