import QtQuick
import QtQuick.Layouts
import "../theme"

// 🎛️ REUSABLE CONTROL PILL WIDGET (Toggle Icon Left + Info Middle + Chevron Right)
Rectangle {
    id: pillRoot

    property string iconText: "󰤨"
    property string titleText: "Wi-Fi"
    property string subtitleText: "Off"
    property bool isActive: false
    property bool isExpanded: false

    signal toggleClicked()
    signal expandClicked()

    implicitWidth: 160
    implicitHeight: 52
    radius: 16
    color: isActive ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.12) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.06)
    border.color: isActive ? Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.3) : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.1)
    border.width: 1

    Behavior on color { ColorAnimation { duration: 200 } }
    Behavior on border.color { ColorAnimation { duration: 200 } }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 8
        anchors.rightMargin: 12
        spacing: 8

        // ⭕ 1. TOMBOL LINGKARAN IKON KIRI (QUICK TOGGLE ON / OFF)
        Rectangle {
            id: iconCircle
            implicitWidth: 36
            implicitHeight: 36
            radius: 18
            color: pillRoot.isActive ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.12)

            Behavior on color { ColorAnimation { duration: 200 } }

            Text {
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: 1
                text: pillRoot.iconText
                color: pillRoot.isActive ? Theme.bgDark : Theme.textMain
                font { family: Theme.fontMono; pixelSize: 17 }

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: pillRoot.toggleClicked()
            }
        }

        // 📝 2. TEKS JUDUL & STATUS SUBTITLE (BISA DIKLIK UNTUK EXPAND SUB-PANEL)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            Text {
                text: pillRoot.titleText
                color: Theme.textMain
                font { family: Theme.fontMain; pixelSize: 13; bold: true }
                elide: Text.ElideRight
                Layout.fillWidth: true
            }

            Text {
                text: pillRoot.subtitleText
                color: pillRoot.isActive ? Theme.accent : Theme.secondary
                font { family: Theme.fontMain; pixelSize: 11 }
                elide: Text.ElideRight
                Layout.fillWidth: true

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: pillRoot.expandClicked()
            }
        }

        // ❯ 3. TOMBOL CHEVRON DROPDOWN KANAN (∨ / ∧ UNTUK EXPAND SUB-PANEL)
        Item {
            implicitWidth: 20
            implicitHeight: 20

            Text {
                anchors.centerIn: parent
                text: "󰅂"
                color: pillRoot.isExpanded ? Theme.accent : Theme.secondary
                font { family: Theme.fontMono; pixelSize: 16 }

                Behavior on color { ColorAnimation { duration: 200 } }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: pillRoot.expandClicked()
            }
        }
    }
}
