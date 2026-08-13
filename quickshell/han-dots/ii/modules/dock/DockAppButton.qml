import qs.services
import qs.modules.common
import qs.modules.common.functions
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

DockButton {
    id: root

    property var appToplevel 
    property var appListRoot
    
    property int lastFocused: -1
    // Ukuran Icon (Logo aplikasi)
    property real iconSize: 26 
    
    property bool isSeparator: appToplevel.appId === "SEPARATOR"
    property var desktopEntry: DesktopEntries.heuristicLookup(appToplevel.appId)
    
    // Cek status aktif
    property bool appIsActive: appToplevel.toplevels && appToplevel.toplevels.find(t => (t.activated == true)) !== undefined

    enabled: !isSeparator
    implicitWidth: isSeparator ? 1 : implicitHeight - topInset - bottomInset

    // --- [LOGIKA BACKGROUND SIMETRIS (DIPERBAIKI)] ---
    background: Item {
        // 1. WADAH TETAP (Container Fix)
        // Kita buat wadah tak terlihat yang ukurannya SELALU TETAP
        // sebesar ukuran maksimal (Active = 48).
        // Ini menjamin titik tengah referensi tidak pernah bergeser.
        implicitWidth: 48
        implicitHeight: 48
        anchors.centerIn: parent

        Image {
            id: hotbarImage
            // 2. Gambar di dalam wadah
            // Gambar ini diletakkan persis di tengah wadah tetap tadi.
            anchors.centerIn: parent

            // LOGIKA UKURAN DINAMIS:
            // Jika Aktif -> 48 (Mengisi penuh wadah)
            // Jika Tidak -> 40 (Lebih kecil, tapi posisinya tetap di tengah wadah 48 tadi)
            width: root.appIsActive ? 48 : 40
            height: root.appIsActive ? 48 : 40
            
            // LOGIKA GAMBAR:
            source: root.appIsActive 
                    ? "/home/han/Pictures/Hotbar_selector.png" 
                    : "/home/han/Pictures/Hotbar_Unselect.png"
            
            smooth: false
            fillMode: Image.Stretch

            // ANIMASI LEBIH MULUS (Ala Game)
            // Menggunakan 'OutBack' memberikan sedikit efek membal saat membesar
            Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
            Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutBack } }
        }
    }
    // -----------------------------------------------------

    Loader {
        active: isSeparator
        anchors.fill: parent
        sourceComponent: DockSeparator {}
    }

    Loader {
        anchors.fill: parent
        active: appToplevel.toplevels.length > 0
        sourceComponent: MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.NoButton
            onEntered: {
                appListRoot.lastHoveredButton = root
                appListRoot.buttonHovered = true
                lastFocused = appToplevel.toplevels.length - 1
            }
            onExited: {
                if (appListRoot.lastHoveredButton === root) {
                    appListRoot.buttonHovered = false
                }
            }
        }
    }

    onClicked: {
        if (appToplevel.toplevels.length === 0) {
            root.desktopEntry?.execute();
            return;
        }
        lastFocused = (lastFocused + 1) % appToplevel.toplevels.length
        appToplevel.toplevels[lastFocused].activate()
    }

    middleClickAction: () => {
        root.desktopEntry?.execute();
    }

    altAction: () => {
        if (Config.options.dock.pinnedApps.indexOf(appToplevel.appId) !== -1) {
            Config.options.dock.pinnedApps = Config.options.dock.pinnedApps.filter(id => id !== appToplevel.appId)
        } else {
            Config.options.dock.pinnedApps = Config.options.dock.pinnedApps.concat([appToplevel.appId])
        }
    }

    contentItem: Loader {
        active: !isSeparator
        sourceComponent: Item {
            // Konten (Ikon) juga diposisikan di tengah parent (tombol)
            anchors.centerIn: parent

            Loader {
                id: iconImageLoader
                anchors.centerIn: parent
                active: !root.isSeparator
                sourceComponent: IconImage {
                    source: Quickshell.iconPath(AppSearch.guessIcon(appToplevel.appId), "image-missing")
                    implicitSize: root.iconSize
                }
            }

            // Indikator titik (Opsional)
            // RowLayout {
            //     spacing: 3
            //     anchors {
            //         top: iconImageLoader.bottom
            //         topMargin: 2
            //         horizontalCenter: parent.horizontalCenter
            //     }
            //     Repeater {
            //         model: Math.min(appToplevel.toplevels.length, 3)
            //         delegate: Rectangle {
            //             width: 4; height: 4; radius: 2
            //             color: "#FFFFFF" 
            //             opacity: 0.8
            //             visible: !appIsActive 
            //         }
            //     }
            // }
        }
    }
}