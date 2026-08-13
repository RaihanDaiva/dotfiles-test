import QtQuick
import QtQuick.Layouts
import qs.modules.common
import qs.modules.common.widgets

RippleButton {
    // Layout properties (bawaan End4)
    // Pastikan tombolnya kotak (persegi) agar gambar tidak gepeng
    // Hapus radius (buat 0) karena Minecraft pixel-art bersudut tajam
    // --- [BAGIAN MODIFIKASI: BACKGROUND GAMBAR] ---
    // --- [BAGIAN MODIFIKASI: BACKGROUND GAMBAR] ---
    // 1. Hapus atau Komentari baris ini:
    // anchors.fill: parent
    // 2. Atur posisi agar tetap di tengah tombol
    // 3. ATUR UKURAN MANUAL DI SINI
    // Anda bisa menggunakan angka pasti (misal 48) atau rasio dari parent
    // Opsi lain: Mengikuti tinggi tombol tapi dikurangi padding (agar ada gap)
    // width: parent.width - 4
    // height: parent.height - 4
    // Wajib false agar pixel tetap tajam (kotak-kotak)
    // Stretch agar gambar pas di ukuran yang Anda tentukan di atas
    // ----------------------------------------------
    // (Opsional) Penyesuaian konten agar ikon tidak terlalu mepet ke pinggir frame
    // contentItem (Ikon) biasanya sudah diatur di file induk atau DockApps,
    // tapi background di atas sudah cukup untuk memberikan tampilan frame.

    id: root

    Layout.fillHeight: true
    Layout.topMargin: Appearance.sizes.elevationMargin - Appearance.sizes.hyprlandGapsOut
    implicitWidth: implicitHeight - topInset - bottomInset
    padding: 5
    buttonRadius: 0

    // background: Image {
    //     anchors.centerIn: parent
    //     width: 48
    //     height: 48
    //     source: "/home/han/Pictures/Hotbar_selector.png"
    //     smooth: false
    //     fillMode: Image.Stretch
    // }

}
