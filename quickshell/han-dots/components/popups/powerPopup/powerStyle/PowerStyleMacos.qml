import "../../../../services"
import "../../../../theme"
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// 🔌 POWER OPTIONS STYLE: MACOS (Floating Glass Capsule Pills with Concentric Circular Badges)
Item {
    id: styleRoot

    property string userNameText: "User"
    property string uptimeText: "Uptime: -"

    signal shutdownClicked()
    signal rebootClicked()
    signal suspendClicked()
    signal lockClicked()
    signal logoutClicked()

    implicitWidth: 260
    implicitHeight: mainLayout.implicitHeight

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent
        spacing: 8

        // 🏷️ 1. TOP HEADER CAPSULES (Title & User Badge)
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            // Power Options Capsule
            Rectangle {
                implicitHeight: 32
                implicitWidth: headerRow.implicitWidth + 20
                radius: height / 2
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
                border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
                border.width: 1

                RowLayout {
                    id: headerRow

                    anchors.centerIn: parent
                    spacing: 7

                    Text {
                        text: "󰐥"
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 15
                        }

                    }

                    Text {
                        text: "Power Options"
                        color: Theme.textMain

                        font {
                            family: Theme.fontMain
                            pixelSize: 12
                            bold: true
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            // User Info Badge
            Rectangle {
                implicitHeight: 26
                implicitWidth: userRow.implicitWidth + 14
                radius: height / 2
                color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.04)
                border.color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                border.width: 1

                RowLayout {
                    id: userRow

                    anchors.centerIn: parent
                    spacing: 4

                    Text {
                        text: "󰀉"
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)

                        font {
                            family: Theme.fontMono
                            pixelSize: 12
                        }

                    }

                    Text {
                        text: styleRoot.userNameText
                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)

                        font {
                            family: Theme.fontMain
                            pixelSize: 11
                            bold: true
                        }

                    }

                }

            }

        }

        // 🔘 2. MACOS POWER ACTION PILLS
        Repeater {
            model: [{
                "id": "shutdown",
                "icon": "󰐥",
                "label": "Shut Down",
                "sub": "Power off system",
                "isDanger": true
            }, {
                "id": "reboot",
                "icon": "󰑐",
                "label": "Restart",
                "sub": "Reboot system",
                "isDanger": false
            }, {
                "id": "suspend",
                "icon": "󰤄",
                "label": "Sleep",
                "sub": "Suspend session",
                "isDanger": false
            }, {
                "id": "lock",
                "icon": "󰌾",
                "label": "Lock Screen",
                "sub": "Secure desktop",
                "isDanger": false
            }, {
                "id": "logout",
                "icon": "󰍃",
                "label": "Log Out",
                "sub": "End session",
                "isDanger": false
            }]

            delegate: Rectangle {
                id: actionCapsule

                property var itemData: modelData
                property bool isHovered: itemHover.hovered
                property bool isDanger: itemData.isDanger

                Layout.fillWidth: true
                implicitHeight: 46
                radius: height / 2
                color: {
                    if (isHovered)
                        return isDanger ? Qt.rgba(0.95, 0.55, 0.66, 0.18) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.16);

                    return Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06);
                }
                border.color: {
                    if (isHovered)
                        return isDanger ? "#f38ba8" : Theme.accent;

                    return Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1);
                }
                border.width: 1

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 14
                    spacing: 10

                    // ⭕ Left Concentric Circular Icon Disc
                    Rectangle {
                        implicitWidth: 32
                        implicitHeight: 32
                        radius: 16
                        Layout.alignment: Qt.AlignVCenter
                        color: {
                            if (actionCapsule.isHovered)
                                return actionCapsule.isDanger ? Qt.rgba(0.95, 0.55, 0.66, 0.28) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25);

                            return Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08);
                        }
                        border.color: {
                            if (actionCapsule.isHovered)
                                return actionCapsule.isDanger ? Qt.rgba(0.95, 0.55, 0.66, 0.5) : Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.5);

                            return "transparent";
                        }
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: itemData.icon
                            color: {
                                if (actionCapsule.isHovered)
                                    return actionCapsule.isDanger ? "#f38ba8" : Theme.accent;

                                return Theme.textMain;
                            }

                            font {
                                family: Theme.fontMono
                                pixelSize: 16
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                    // 📝 Center Text Column (Title & Subtitle)
                    ColumnLayout {
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignVCenter
                        spacing: 1

                        Text {
                            text: itemData.label
                            color: {
                                if (actionCapsule.isHovered)
                                    return actionCapsule.isDanger ? "#f38ba8" : Theme.accent;

                                return Theme.textMain;
                            }

                            font {
                                family: Theme.fontMain
                                pixelSize: 13
                                bold: true
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 150
                                }

                            }

                        }

                        Text {
                            text: itemData.sub
                            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5)

                            font {
                                family: Theme.fontMain
                                pixelSize: 10
                            }

                        }

                    }

                    // 󰅂 Right Subtle Chevron
                    Text {
                        text: "󰅂"
                        color: actionCapsule.isHovered ? (actionCapsule.isDanger ? "#f38ba8" : Theme.accent) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.35)

                        font {
                            family: Theme.fontMono
                            pixelSize: 13
                        }

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }

                        }

                    }

                }

                HoverHandler {
                    id: itemHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (itemData.id === "shutdown")
                            styleRoot.shutdownClicked();
                        else if (itemData.id === "reboot")
                            styleRoot.rebootClicked();
                        else if (itemData.id === "suspend")
                            styleRoot.suspendClicked();
                        else if (itemData.id === "lock")
                            styleRoot.lockClicked();
                        else if (itemData.id === "logout")
                            styleRoot.logoutClicked();
                    }
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }

                }

                Behavior on border.color {
                    ColorAnimation {
                        duration: 150
                    }

                }

            }

        }

    }

}
