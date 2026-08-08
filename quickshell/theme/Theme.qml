pragma Singleton
import QtQuick
import Quickshell

Item {
    id: themeRoot

    // 🔤 FONTS & TYPOGRAPHY
    FontLoader {
        id: googleSansFont
        source: Quickshell.configDir + "/assets/fonts/GoogleSans-Regular.ttf"
    }
    readonly property string fontMain: googleSansFont.name
    readonly property string fontMono: "JetBrainsMono Nerd Font"

    // 🎨 COLOR PALETTE (Dynamic Pywal Theme)
    property color bgDark: "#1e1e2e"
    property color textMain: "#cdd6f4"
    property color accent: "#89b4fa"
    property color secondary: "#585b70"
}