import "../../../../services"
import "../../../../theme"
import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell

Item {
    id: root

    property string userNameText: "User"
    property string batIcon: "󰁹"
    property int batCap: 100

    signal gearClicked()

    implicitWidth: 328
    implicitHeight: col.implicitHeight

    ColumnLayout {
        id: col

        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 10

            // 👤 CIRCULAR USER AVATAR IMAGE WITH HD MIPMAPPING & PERFECT INSET MASK
            Item {
                implicitWidth: 44
                implicitHeight: 44

                Image {
                    id: userAvatarImg

                    readonly property var avatarPaths: [Quickshell.configDir + "/assets/image/avatar.png", Quickshell.configDir + "/assets/image/avatar.jpg", Quickshell.configDir + "/assets/image/avatar.jpeg", Quickshell.configDir + "/assets/image/profile.png", Quickshell.configDir + "/assets/image/user.png", "file://" + Quickshell.env("HOME") + "/.face", "file://" + Quickshell.env("HOME") + "/.face.icon"]
                    property int pathIndex: 0

                    anchors.fill: parent
                    anchors.margins: 2
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    mipmap: true
                    sourceSize: Qt.size(160, 160)
                    visible: status === Image.Ready
                    layer.enabled: true
                    source: avatarPaths[0]
                    onStatusChanged: {
                        if (status === Image.Error) {
                            if (pathIndex < avatarPaths.length - 1) {
                                pathIndex++;
                                source = avatarPaths[pathIndex];
                            }
                        }
                    }

                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskSource: avatarMask
                    }

                }

                Rectangle {
                    id: avatarMask

                    anchors.fill: userAvatarImg
                    radius: width / 2
                    visible: false
                    layer.enabled: true
                }

                // ⭕ BORDER RING LINGKARAN (DILUAR GAMBAR)
                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: Theme.accent
                    border.width: 1.5
                }

                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: 1
                    text: "󰀉"
                    color: Theme.accent
                    visible: userAvatarImg.status !== Image.Ready

                    font {
                        family: Theme.fontMono
                        pixelSize: 22
                    }

                }

            }

            ColumnLayout {
                spacing: 1

                Text {
                    text: root.userNameText
                    color: Theme.textMain

                    font {
                        family: Theme.fontMain
                        pixelSize: 16
                        bold: true
                    }

                }

                RowLayout {
                    spacing: 4

                    Text {
                        text: root.batIcon
                        color: Theme.accent

                        font {
                            family: Theme.fontMono
                            pixelSize: 13
                        }

                    }

                    Text {
                        text: root.batCap + "%"
                        color: Theme.textMain

                        font {
                            family: Theme.fontMain
                            pixelSize: 12
                        }

                    }

                }

            }

            Item {
                Layout.fillWidth: true
            }

            // ⚙️ ELEMENTS CUSTOMIZER GEAR BUTTON
            Rectangle {
                implicitWidth: 32
                implicitHeight: 32
                radius: 16
                color: gearHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.08)
                border.color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3)
                border.width: 1

                Text {
                    anchors.centerIn: parent
                    text: "󰒓"
                    color: Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 16
                    }

                }

                HoverHandler {
                    id: gearHover
                }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.gearClicked()
                }

            }

        }

        // ➖ DIVIDER LINE (FIXED AT TOP)
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 1
            color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.15)
        }

    }

}
