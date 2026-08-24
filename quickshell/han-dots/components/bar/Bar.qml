import "../../services"
import "./barStyle"
import QtQuick
import Quickshell

// 🏛️ STATUS BAR — Entry Point (Scope, bukan PanelWindow)
// Memilih antara BarStyleUnified (1 PanelWindow) atau BarStyleIslands (3 PanelWindow terpisah).
// Setiap style punya Wayland surface sendiri sehingga Niri bisa menerapkan blur per-surface.
Scope {
    id: barRoot

    required property var screen

    // Style 1: Unified Bar — 1 permukaan Wayland, blur menutup seluruh bar
    BarStyleUnified {
        screen: barRoot.screen
        visible: SettingsStore.barStyle !== "islands"
    }

    // Style 2: 3 Floating Islands — 3 permukaan Wayland terpisah, blur menempel per-island
    BarStyleIslands {
        screen: barRoot.screen
        islandsVisible: SettingsStore.barStyle === "islands"
    }

}
