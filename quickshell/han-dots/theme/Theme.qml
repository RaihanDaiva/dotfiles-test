pragma Singleton
import QtQuick
import Quickshell

// 🎨 THEME SINGLETON — Semua warna UI dipusatkan di sini.
//
// ARSITEKTUR:
//   • _darkXxx / _lightXxx = palette writable → PywalService update via applyPywalColors().
//   • bgDark / textMain / accent / secondary = READONLY → binding isDarkMode tidak
//     pernah bisa rusak karena tidak ada yang boleh menimpa secara imperatif.
//
// MENGAPA readonly pada active colors?
//   Di QML, assignment imperatif (Theme.bgDark = ...) akan MERUSAK binding
//   deklaratif secara PERMANEN. Dengan readonly, compiler QML akan menolak
//   assignment tersebut sehingga binding selalu hidup.

Item {
    id: themeRoot

    // ─── FONTS & TYPOGRAPHY ──────────────────────────────────────────────────
    FontLoader {
        id: googleSansFont
        source: Quickshell.configDir + "/assets/fonts/GoogleSans-Regular.ttf"
    }
    readonly property string fontMain: googleSansFont.name
    readonly property string fontMono: "JetBrainsMono Nerd Font"

    // ─── MODE STATE ──────────────────────────────────────────────────────────
    property bool isDarkMode: true

    // ─── DARK PALETTE (Catppuccin Mocha — fallback, diupdate PywalService) ────
    property color _darkBg:        "#1e1e2e"
    property color _darkText:      "#cdd6f4"
    property color _darkAccent:    "#89b4fa"
    property color _darkSecondary: "#6c7086"

    // ─── LIGHT PALETTE (Catppuccin Latte — fallback, diupdate PywalService) ──
    // Tidak lagi readonly — PywalService akan mengisinya dari color15/color0/color8.
    property color _lightBg:        "#e6e9ef"
    property color _lightText:      "#4c4f69"
    property color _lightAccent:    "#1e66f5"
    property color _lightSecondary: "#8c8fa1"

    // ─── ACTIVE COLORS (readonly → binding ini tidak bisa rusak secara imperatif) ─
    // Semua komponen UI menggunakan keempat properti ini.
    readonly property color bgDark:    isDarkMode ? _darkBg        : _lightBg
    readonly property color textMain:  isDarkMode ? _darkText      : _lightText
    readonly property color accent:    isDarkMode ? _darkAccent    : _lightAccent
    readonly property color secondary: isDarkMode ? _darkSecondary : _lightSecondary

    // ─── PUBLIC API ───────────────────────────────────────────────────────────

    // Dipanggil oleh PywalService dengan kedua palette sekaligus.
    // Dark  : bg/fg/acc/sec  → special.background / foreground / color4 / color3
    // Light : lightBg/Text/Acc/Sec → color15 / color0 / color4 / color8
    function applyPywalColors(
        darkBgVal, darkTextVal, darkAccentVal, darkSecondaryVal,
        lightBgVal, lightTextVal, lightAccentVal, lightSecondaryVal
    ) {
        _darkBg        = darkBgVal
        _darkText      = darkTextVal
        _darkAccent    = darkAccentVal
        _darkSecondary = darkSecondaryVal
        _lightBg       = lightBgVal
        _lightText     = lightTextVal
        _lightAccent   = lightAccentVal
        _lightSecondary = lightSecondaryVal
    }

    // Toggle mode dark/light dan sinkronisasi color-scheme aplikasi GTK.
    function toggleDarkMode() {
        isDarkMode = !isDarkMode
        var scheme = isDarkMode ? "prefer-dark" : "prefer-light"
        Quickshell.execDetached([
            "gsettings", "set",
            "org.gnome.desktop.interface",
            "color-scheme", scheme
        ])
    }
}