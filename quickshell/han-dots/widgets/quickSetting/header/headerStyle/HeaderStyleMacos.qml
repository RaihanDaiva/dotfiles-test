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
    implicitHeight: 36

    RowLayout {
        anchors.fill: parent
        spacing: 8

        // 👤 USER PROFILE CAPSULE (AVATAR + NAME COMBINED)
        Rectangle {
            id: profileCapsule

            implicitHeight: 36
            implicitWidth: nameText.implicitWidth + 54
            radius: height / 2
            color: profileHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.14) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
            border.color: profileHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.24) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
            border.width: 1

            HoverHandler {
                id: profileHover
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 4
                anchors.rightMargin: 14
                spacing: 8

                // 👤 CIRCULAR USER AVATAR (28x28 CONCENTRIC INSET)
                Item {
                    implicitWidth: 28
                    implicitHeight: 28

                    Image {
                        id: userAvatarImg

                        readonly property var avatarPaths: [Quickshell.configDir + "/assets/image/avatar.png", Quickshell.configDir + "/assets/image/avatar.jpg", Quickshell.configDir + "/assets/image/avatar.jpeg", Quickshell.configDir + "/assets/image/profile.png", Quickshell.configDir + "/assets/image/user.png", "file://" + Quickshell.env("HOME") + "/.face", "file://" + Quickshell.env("HOME") + "/.face.icon"]
                        property int pathIndex: 0

                        anchors.fill: parent
                        anchors.margins: 1
                        fillMode: Image.PreserveAspectCrop
                        smooth: true
                        mipmap: true
                        sourceSize: Qt.size(120, 120)
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
                            pixelSize: 15
                        }

                    }

                }

                // 🏷️ USER NAME
                Text {
                    id: nameText

                    text: root.userNameText
                    color: Theme.textMain
                    elide: Text.ElideRight

                    font {
                        family: Theme.fontMain
                        pixelSize: 13
                        bold: true
                    }

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

        // 🔋 BATTERY CAPSULE BADGE
        Rectangle {
            id: batBadge

            implicitHeight: 36
            implicitWidth: batRow.implicitWidth + 22
            radius: height / 2
            color: batHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.14) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
            border.color: batHover.hovered ? Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.24) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
            border.width: 1

            HoverHandler {
                id: batHover
            }

            RowLayout {
                id: batRow

                anchors.centerIn: parent
                spacing: 5

                Text {
                    text: root.batIcon
                    color: Theme.accent

                    font {
                        family: Theme.fontMono
                        pixelSize: 14
                    }

                }

                Text {
                    text: root.batCap + "%"
                    color: Theme.textMain

                    font {
                        family: Theme.fontMain
                        pixelSize: 12
                        bold: true
                    }

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

        Item {
            Layout.fillWidth: true
        }

        // ⚙️ ELEMENTS CUSTOMIZER GEAR BUTTON
        Rectangle {
            id: gearBtn

            implicitWidth: 36
            implicitHeight: 36
            radius: 18
            color: gearHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.25) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
            border.color: gearHover.hovered ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.4) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
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
