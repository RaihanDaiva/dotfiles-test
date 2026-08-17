import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Qt5Compat.GraphicalEffects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import Quickshell.Services.Mpris
import "../widgets"
import "../widgets/bar/mediaPlayerWidget"
import "../theme"

// 🔐 NATIVE WAYLAND LOCKSCREEN WIDGET (With PAM Authentication & Large Clock)
Scope {
    id: lockscreenScope

    property bool isLocked: false
    property string username: "User"

    property string wallpaperPath: ""

    // 🎵 MPRIS MEDIA PLAYER HELPERS FOR LOCKSCREEN
    readonly property var lockActivePlayer: {
        var players = Mpris.players.values
        if (!players || players.length === 0) return null
        for (var i = 0; i < players.length; i++) {
            var p = players[i]
            if (p && p.isPlaying) return p
        }
        for (var j = 0; j < players.length; j++) {
            var p2 = players[j]
            if (p2 && p2.trackTitle && p2.trackTitle !== "") return p2
        }
        return players[0]
    }

    function getLockArtistName(p) {
        if (!p) return ""
        if (p.trackArtist && p.trackArtist !== "") return p.trackArtist
        if (p.trackAlbumArtist && p.trackAlbumArtist !== "") return p.trackAlbumArtist
        if (p.trackArtists && p.trackArtists.length > 0 && p.trackArtists[0] !== "") {
            return p.trackArtists.join(", ")
        }
        if (p.metadata) {
            var metaArtist = p.metadata["xesam:artist"] || p.metadata["xesam:albumArtist"]
            if (metaArtist) {
                return Array.isArray(metaArtist) ? metaArtist.join(", ") : metaArtist
            }
        }
        return "Unknown Artist"
    }

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

                // 🎨 2. TRANSLUCENT OVERLAY FOR CONTRAST (Constant dark overlay even in Light Mode)
                Rectangle {
                    id: overlayRect
                    anchors.fill: parent
                    color: Qt.rgba(Theme._darkBg.r, Theme._darkBg.g, Theme._darkBg.b, 0.65)
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
                            timeColor: Theme._darkText
                            dateColor: Qt.rgba(Theme._darkText.r, Theme._darkText.g, Theme._darkText.b, 0.7)
                        }

                        Item { Layout.preferredHeight: 14 }

                        // 🎵 2. MEDIA PLAYER CARD BELOW CLOCK (WITH FROSTED BLURRED ALBUM ART BACKGROUND)
                        Rectangle {
                            id: lockMediaCard
                            implicitWidth: lockMediaLayout.implicitWidth + 30
                            implicitHeight: 54
                            radius: 14
                            color: Qt.rgba(Theme._darkBg.r, Theme._darkBg.g, Theme._darkBg.b, 0.45)
                            border.color: Qt.rgba(Theme._darkText.r, Theme._darkText.g, Theme._darkText.b, 0.22)
                            border.width: 1
                            clip: true
                            visible: lockscreenScope.lockActivePlayer !== null && (lockscreenScope.lockActivePlayer.trackTitle !== "" || lockscreenScope.lockActivePlayer.isPlaying)
                            Layout.alignment: Qt.AlignLeft

                            // 🌫️ FROSTED BLURRED ALBUM ART CONTAINER (CLIPPED TO CARD RADIUS)
                            Item {
                                anchors.fill: parent
                                anchors.margins: 1

                                layer.enabled: true
                                layer.effect: OpacityMask {
                                    maskSource: Rectangle {
                                        width: lockMediaCard.width - 2
                                        height: lockMediaCard.height - 2
                                        radius: 13
                                    }
                                }

                                // Blurred Album Cover Image
                                Image {
                                    id: lockBlurCover
                                    anchors.fill: parent
                                    anchors.margins: -10
                                    source: (lockscreenScope.lockActivePlayer && lockscreenScope.lockActivePlayer.trackArtUrl) ? lockscreenScope.lockActivePlayer.trackArtUrl : ""
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    mipmap: true
                                    sourceSize: Qt.size(200, 200)
                                    visible: status === Image.Ready

                                    layer.enabled: true
                                    layer.effect: FastBlur {
                                        radius: 36
                                    }
                                }

                                // Dark Frosted Tint Overlay
                                Rectangle {
                                    anchors.fill: parent
                                    color: Qt.rgba(Theme._darkBg.r, Theme._darkBg.g, Theme._darkBg.b, lockBlurCover.visible ? 0.58 : 0.75)
                                }
                            }

                            RowLayout {
                                id: lockMediaLayout
                                anchors.centerIn: parent
                                spacing: 12

                                // 🖼️ Cover Album Image (SCALED UP 36x36)
                                Rectangle {
                                    implicitWidth: 36
                                    implicitHeight: 36
                                    radius: 8
                                    color: Theme.accent
                                    clip: true

                                    Image {
                                        id: lockCoverImage
                                        anchors.fill: parent
                                        source: (lockscreenScope.lockActivePlayer && lockscreenScope.lockActivePlayer.trackArtUrl) ? lockscreenScope.lockActivePlayer.trackArtUrl : ""
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        mipmap: true
                                        sourceSize: Qt.size(160, 160)
                                        visible: status === Image.Ready
                                    }

                                    Text {
                                        anchors.centerIn: parent
                                        text: "󰎈"
                                        color: Theme._darkBg
                                        font { family: Theme.fontMono; pixelSize: 16 }
                                        visible: lockCoverImage.status !== Image.Ready
                                    }
                                }

                                // 🎶 Marquee Text (Title & Artist) (SCALED UP WIDTH 160)
                                Item {
                                    implicitWidth: 120
                                    implicitHeight: lockTextColumn.implicitHeight
                                    Layout.preferredWidth: 120
                                    Layout.maximumWidth: 120

                                    ColumnLayout {
                                        id: lockTextColumn
                                        anchors.fill: parent
                                        spacing: 2

                                        MarqueeText {
                                            text: (lockscreenScope.lockActivePlayer && lockscreenScope.lockActivePlayer.trackTitle) ? lockscreenScope.lockActivePlayer.trackTitle : "No Media"
                                            textFont.family: Theme.fontMain
                                            textFont.pixelSize: 14
                                            textFont.bold: true
                                            textColor: Theme._darkText
                                            targetWidth: 120
                                            isPlaying: lockscreenScope.lockActivePlayer ? lockscreenScope.lockActivePlayer.isPlaying : false
                                        }

                                        MarqueeText {
                                            text: lockscreenScope.getLockArtistName(lockscreenScope.lockActivePlayer)
                                            textFont.family: Theme.fontMain
                                            textFont.pixelSize: 11
                                            textColor: Qt.rgba(Theme._darkText.r, Theme._darkText.g, Theme._darkText.b, 0.7)
                                            targetWidth: 120
                                            isPlaying: lockscreenScope.lockActivePlayer ? lockscreenScope.lockActivePlayer.isPlaying : false
                                        }
                                    }
                                }

                                // ⏯️ Control Buttons (Previous, Play/Pause, Next) (SCALED UP)
                                RowLayout {
                                    spacing: 1

                                    // Previous
                                    Item {
                                        implicitWidth: 28
                                        implicitHeight: 28

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰒮"
                                            color: Theme._darkText
                                            font { family: Theme.fontMono; pixelSize: 17 }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (lockscreenScope.lockActivePlayer && typeof lockscreenScope.lockActivePlayer.previous === "function") lockscreenScope.lockActivePlayer.previous()
                                        }
                                    }

                                    // Play / Pause
                                    Item {
                                        implicitWidth: 30
                                        implicitHeight: 28

                                        Text {
                                            anchors.centerIn: parent
                                            anchors.horizontalCenterOffset: (lockscreenScope.lockActivePlayer && lockscreenScope.lockActivePlayer.isPlaying) ? 0 : 1
                                            text: (lockscreenScope.lockActivePlayer && lockscreenScope.lockActivePlayer.isPlaying) ? "󰏤" : "󰐊"
                                            color: Theme._darkText
                                            font { family: Theme.fontMono; pixelSize: 20 }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                var p = lockscreenScope.lockActivePlayer
                                                if (p) {
                                                    if (typeof p.playPause === "function") p.playPause()
                                                    else if (typeof p.togglePlaying === "function") p.togglePlaying()
                                                    else p.isPlaying = !p.isPlaying
                                                }
                                            }
                                        }
                                    }

                                    // Next
                                    Item {
                                        implicitWidth: 28
                                        implicitHeight: 28

                                        Text {
                                            anchors.centerIn: parent
                                            text: "󰒭"
                                            color: Theme._darkText
                                            font { family: Theme.fontMono; pixelSize: 17 }
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: if (lockscreenScope.lockActivePlayer && typeof lockscreenScope.lockActivePlayer.next === "function") lockscreenScope.lockActivePlayer.next()
                                        }
                                    }
                                }
                            }
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

                        // 👤 2. USER AVATAR & USERNAME ABOVE PASSWORD FIELD
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 8

                            Item {
                                implicitWidth: 102
                                implicitHeight: 102
                                Layout.alignment: Qt.AlignHCenter

                                Image {
                                    id: lockAvatarImg
                                    anchors.fill: parent
                                    anchors.margins: 3
                                    fillMode: Image.PreserveAspectCrop
                                    smooth: true
                                    mipmap: true
                                    sourceSize: Qt.size(240, 240)
                                    visible: status === Image.Ready

                                    layer.enabled: true
                                    layer.effect: MultiEffect {
                                        maskEnabled: true
                                        maskSource: lockAvatarMask
                                    }

                                    readonly property var avatarPaths: [
                                        Quickshell.configDir + "/assets/image/avatar.png",
                                        Quickshell.configDir + "/assets/image/avatar.jpg",
                                        Quickshell.configDir + "/assets/image/avatar.jpeg",
                                        Quickshell.configDir + "/assets/image/profile.png",
                                        Quickshell.configDir + "/assets/image/user.png",
                                        "file://" + Quickshell.env("HOME") + "/.face",
                                        "file://" + Quickshell.env("HOME") + "/.face.icon"
                                    ]
                                    property int pathIndex: 0

                                    source: avatarPaths[0]

                                    onStatusChanged: {
                                        if (status === Image.Error) {
                                            if (pathIndex < avatarPaths.length - 1) {
                                                pathIndex++
                                                source = avatarPaths[pathIndex]
                                            }
                                        }
                                    }
                                }

                                Rectangle {
                                    id: lockAvatarMask
                                    anchors.fill: lockAvatarImg
                                    radius: width / 2
                                    visible: false
                                    layer.enabled: true
                                }

                                Rectangle {
                                    anchors.fill: parent
                                    radius: width / 2
                                    color: "transparent"
                                    border.color: Theme.accent
                                    border.width: 3
                                }

                                Text {
                                    anchors.centerIn: parent
                                    anchors.horizontalCenterOffset: 1
                                    text: "󰀉"
                                    color: Theme.accent
                                    font { family: Theme.fontMono; pixelSize: 34 }
                                    visible: lockAvatarImg.status !== Image.Ready
                                }
                            }

                            Text {
                                text: lockscreenScope.username
                                color: Theme._darkText
                                font { family: Theme.fontMain; pixelSize: 20; bold: true }
                                Layout.alignment: Qt.AlignHCenter
                            }
                        }

                        Item { Layout.preferredHeight: 8 }

                        // 🔑 3. UNDERLINE PASSWORD INPUT FIELD (CENTERED TEXT)
                        Item {
                            id: inputCard
                            Layout.fillWidth: true
                            implicitHeight: 46

                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 8
                                anchors.rightMargin: 8
                                spacing: 8

                                // Lock / Spinner Icon
                                Text {
                                    text: lockSurface.isAuthenticating ? "󰔟" : "󰌾"
                                    color: lockSurface.isError ? "#f38ba8" : (passInput.activeFocus ? Theme.accent : Qt.rgba(Theme._darkText.r, Theme._darkText.g, Theme._darkText.b, 0.5))
                                    font { family: Theme.fontMono; pixelSize: 18 }
                                }

                                // Password Text Input (CENTERED)
                                TextInput {
                                    id: passInput
                                    Layout.fillWidth: true
                                    echoMode: TextInput.Password
                                    color: Theme._darkText
                                    font { family: Theme.fontMain; pixelSize: 14 }
                                    verticalAlignment: TextInput.AlignVCenter
                                    horizontalAlignment: TextInput.AlignHCenter
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

                                    // Placeholder (CENTERED)
                                    Text {
                                        text: "Password..."
                                        color: Qt.rgba(Theme._darkText.r, Theme._darkText.g, Theme._darkText.b, 0.35)
                                        font: parent.font
                                        anchors.fill: parent
                                        verticalAlignment: TextInput.AlignVCenter
                                        horizontalAlignment: TextInput.AlignHCenter
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
