import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import "../widgets"
import "../theme"

// 🔐 NATIVE WAYLAND LOCKSCREEN WIDGET (With PAM Authentication & Large Clock)
Scope {
    id: lockscreenScope

    property bool isLocked: false
    property string username: "User"

    property string wallpaperPath: ""

    // 🖼️ DETECT CURRENT WALLPAPER ON BOOT / LOCK
    Process {
        id: bgDetectProc
        command: ["readlink", "-f", Quickshell.env("HOME") + "/.cache/current_wallpaper.jpg"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var path = this.text.trim()
                if (path !== "") lockscreenScope.wallpaperPath = path
            }
        }
    }

    onIsLockedChanged: {
        if (isLocked) {
            bgDetectProc.running = false
            bgDetectProc.running = true
        }
    }

    // 👤 FETCH USERNAME ON STARTUP
    Process {
        id: userProc
        command: ["whoami"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                var u = this.text.trim()
                if (u !== "") lockscreenScope.username = u
            }
        }
    }

    // 🔒 WAYLAND SESSION LOCK (ext-session-lock-v1)
    WlSessionLock {
        id: sessionLock
        locked: lockscreenScope.isLocked

        WlSessionLockSurface {
            id: lockSurface
            color: "transparent"

            // ═══════════════════════════════════════════════
            // 🔑 PAM & STATE — Semua di dalam surface sendiri
            // ═══════════════════════════════════════════════
            property bool isAuthenticating: false
            property bool isError: false
            property string currentPassword: ""

            PamContext {
                id: pamContext

                onPamMessage: {
                    if (responseRequired) {
                        respond(lockSurface.currentPassword)
                    }
                }

                onCompleted: result => {
                    lockSurface.isAuthenticating = false
                    if (result === PamResult.Success) {
                        lockSurface.currentPassword = ""
                        lockSurface.isError = false
                        lockSurface.triggerUnlock()
                    } else {
                        lockSurface.currentPassword = ""
                        lockSurface.isError = true
                        passInput.forceActiveFocus()
                    }
                }
            }

            function triggerUnlock() {
                overlayFadeOutAnim.restart()
            }

            function submitPassword() {
                if (currentPassword === "" || isAuthenticating) return
                isError = false
                isAuthenticating = true
                pamContext.start()
            }

            // Reset state saat lockscreen baru aktif
            onVisibleChanged: {
                if (visible) {
                    isAuthenticating = false
                    isError = false
                    currentPassword = ""
                    focusTimer.start()
                }
            }

            Timer {
                id: focusTimer
                interval: 150
                repeat: false
                onTriggered: passInput.forceActiveFocus()
            }

            // ═══════════════════════════════════════════════
            // 🎨 FULLSCREEN UI — FocusScope untuk keyboard
            // ═══════════════════════════════════════════════
            FocusScope {
                anchors.fill: parent
                focus: true

                // Tangkap semua key event di level paling atas
                // sebagai fallback kalau TextInput kehilangan fokus
                Keys.onPressed: event => {
                    if (!passInput.activeFocus) {
                        passInput.forceActiveFocus()
                    }

                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        lockSurface.submitPassword()
                        event.accepted = true
                    } else if (event.key === Qt.Key_Backspace) {
                        if (lockSurface.currentPassword.length > 0) {
                            lockSurface.currentPassword = lockSurface.currentPassword.slice(0, -1)
                        }
                        event.accepted = true
                    } else if (event.key === Qt.Key_Escape) {
                        lockSurface.currentPassword = ""
                        lockSurface.isError = false
                        event.accepted = true
                    }
                }

                // 🖼️ 1. INSTANT CURRENT WALLPAPER BACKGROUND IMAGE
                Image {
                    id: wallpaperImg
                    anchors.fill: parent
                    source: "file://" + Quickshell.env("HOME") + "/.cache/current_wallpaper.jpg"
                    fillMode: Image.PreserveAspectCrop
                    smooth: true
                    cache: true
                }

                // 🎨 2. TRANSLUCENT OVERLAY FOR CONTRAST (Guaranteed Fade-in & Fade-out Animation)
                Rectangle {
                    id: overlayRect
                    anchors.fill: parent
                    color: Qt.rgba(Theme.bgDark.r, Theme.bgDark.g, Theme.bgDark.b, 0.65)
                    opacity: 0.0

                    // 🔹 Fade In Animation (Saat Layar Dikunci)
                    NumberAnimation {
                        id: overlayFadeAnim
                        target: overlayRect
                        property: "opacity"
                        from: 0.0
                        to: 1.0
                        duration: 400
                        easing.type: Easing.OutCubic
                    }

                    // 🔹 Fade Out Animation (Saat Layar Dibuka / Password Benar)
                    NumberAnimation {
                        id: overlayFadeOutAnim
                        target: overlayRect
                        property: "opacity"
                        from: 1.0
                        to: 0.0
                        duration: 400
                        easing.type: Easing.InCubic
                        onFinished: {
                            lockscreenScope.isLocked = false
                        }
                    }

                    Connections {
                        target: lockscreenScope
                        function onIsLockedChanged() {
                            if (lockscreenScope.isLocked) {
                                overlayRect.opacity = 0.0
                                overlayFadeAnim.restart()
                            } else {
                                overlayRect.opacity = 0.0
                            }
                        }
                    }

                    Component.onCompleted: {
                        if (lockscreenScope.isLocked) {
                            overlayRect.opacity = 0.0
                            overlayFadeAnim.restart()
                        }
                    }

                    // Klik di mana saja → refocus ke passInput
                    MouseArea {
                        anchors.fill: parent
                        onClicked: passInput.forceActiveFocus()
                    }

                    ColumnLayout {

                        anchors {
                            fill: parent
                            topMargin: 100
                            leftMargin: 80
                        }
                        
                        // 🕒 1. LARGE DIGITAL CLOCK & DATE
                        LargeClock {
                            Layout.alignment: Qt.AlignLeft
                            timePixelSize: 100
                            datePixelSize: 30
                            timeColor: Theme.textMain
                            dateColor: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.7)
                        }

                        Item {
                            Layout.fillHeight: true
                        }
                    }


                    // 📦 CENTERED CONTENT COLUMN
                    ColumnLayout {
                        // anchors.centerIn: parent
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            bottom: parent.bottom
                            bottomMargin: 80
                        }
                        spacing: 10
                        width: 190


                        Item { Layout.preferredHeight: 12 }

                        // 👤 2. USER AVATAR & USERNAME
                        // ColumnLayout {
                        //     Layout.alignment: Qt.AlignHCenter
                        //     spacing: 8

                        //     Rectangle {
                        //         implicitWidth: 64
                        //         implicitHeight: 64
                        //         radius: 32
                        //         color: Qt.rgba(Theme.accent.r, Theme.accent.g, Theme.accent.b, 0.15)
                        //         border.color: Theme.accent
                        //         border.width: 2
                        //         Layout.alignment: Qt.AlignHCenter

                        //         Text {
                        //             anchors.centerIn: parent
                        //             text: "󰀉"
                        //             color: Theme.accent
                        //             font { family: Theme.fontMono; pixelSize: 32 }
                        //         }
                        //     }

                        //     Text {
                        //         text: lockscreenScope.username
                        //         color: Theme.textMain
                        //         font { family: Theme.fontMain; pixelSize: 16; bold: true }
                        //         Layout.alignment: Qt.AlignHCenter
                        //     }
                        // }

                        // 🔑 3. UNDERLINE PASSWORD INPUT FIELD
                        Item {
                            id: inputCard
                            Layout.fillWidth: true
                            implicitHeight: 46

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 4
                                anchors.rightMargin: 4
                                spacing: 10

                                // Lock / Spinner Icon
                                Text {
                                    text: lockSurface.isAuthenticating ? "󰔟" : "󰌾"
                                    color: lockSurface.isError ? "#f38ba8" : (passInput.activeFocus ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5))
                                    font { family: Theme.fontMono; pixelSize: 18 }
                                }

                                // Password Text Input
                                TextInput {
                                    id: passInput
                                    Layout.fillWidth: true
                                    echoMode: TextInput.Password
                                    color: Theme.textMain
                                    font { family: Theme.fontMain; pixelSize: 14 }
                                    verticalAlignment: TextInput.AlignVCenter
                                    focus: true

                                    // Sync teks input → property surface
                                    onTextChanged: {
                                        lockSurface.currentPassword = text
                                        if (lockSurface.isError) lockSurface.isError = false
                                    }

                                    // Handler Enter (semua bentuk)
                                    onAccepted: lockSurface.submitPassword()

                                    Keys.onReturnPressed: event => {
                                        lockSurface.submitPassword()
                                        event.accepted = true
                                    }

                                    Keys.onEnterPressed: event => {
                                        lockSurface.submitPassword()
                                        event.accepted = true
                                    }

                                    // Placeholder
                                    Text {
                                        text: "Password..."
                                        color: Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.35)
                                        font: parent.font
                                        anchors.fill: parent
                                        verticalAlignment: TextInput.AlignVCenter
                                        visible: passInput.text === ""
                                    }
                                }

                                // Submit Button Icon
                                // Text {
                                //     text: "󰍂"
                                //     color: submitHover.hovered ? Theme.accent : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.5)
                                //     font { family: Theme.fontMono; pixelSize: 18 }

                                //     HoverHandler { id: submitHover }

                                //     MouseArea {
                                //         anchors.fill: parent
                                //         cursorShape: Qt.PointingHandCursor
                                //         onClicked: lockSurface.submitPassword()
                                //     }
                                // }
                            }

                            // ➖ BOTTOM UNDERLINE LINE
                            Rectangle {
                                anchors.left: parent.left
                                anchors.right: parent.right
                                anchors.bottom: parent.bottom
                                height: passInput.activeFocus || lockSurface.isError ? 2 : 1
                                color: lockSurface.isError
                                    ? "#f38ba8"
                                    : (passInput.activeFocus
                                        ? Theme.accent
                                        : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.3))

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on height { NumberAnimation { duration: 150 } }
                            }
                        }

                        // ⚠️ 4. STATUS MESSAGE (Fixed Height Reserved Slot - Prevents Layout Shifting)
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: 24

                            Text {
                                // anchors.centerIn: parent
                                anchors.left: parent.left
                                text: lockSurface.isAuthenticating
                                    ? "Authenticating..."
                                    : (lockSurface.isError ? "Incorrect password. Try again." : "")
                                color: lockSurface.isError
                                    ? "#f38ba8"
                                    : Qt.rgba(Theme.textMain.r, Theme.textMain.g, Theme.textMain.b, 0.6)
                                font { family: Theme.fontMain; pixelSize: 12; bold: lockSurface.isError }
                                opacity: text !== "" ? 1.0 : 0.0

                                Behavior on opacity { NumberAnimation { duration: 150 } }
                            }
                        }
                    }
                }
            }
        }
    }

    // 📡 IPC HANDLER
    IpcHandler {
        target: "lockscreen"

        function toggle() {
            lockscreenScope.isLocked = !lockscreenScope.isLocked
        }

        function lock() {
            lockscreenScope.isLocked = true
        }

        function unlock() {
            lockscreenScope.isLocked = false
        }
    }
}
