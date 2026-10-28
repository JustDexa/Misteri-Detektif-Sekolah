# Misteri Detektif Sekolah — Project Godot

Game pembelajaran interaktif berbasis investigasi kasus untuk menganalisis kecenderungan pola pikir
Computational Thinking (Dekomposisi, Pengenalan Pola, Abstraksi, Algoritma).

Afridya Dexa Wahnugrah (K3524020) · Estu Setyoadi Galih Ramdani (K3524050)
PTIK · FKIP · Universitas Sebelas Maret · 2026

---

## 1. Cara menjalankan

1. Unduh **Godot 4.3 atau lebih baru** (versi *Standard*, bukan .NET) dari godotengine.org.
2. Buka Godot → **Import** → pilih file `project.godot` di folder ini → **Import & Edit**.
3. Tunggu sebentar saat Godot meng-import semua gambar dan suara (hanya pertama kali).
4. Tekan **F5** (atau tombol ▶ di kanan atas) untuk bermain.

Kalau memakai Godot 4.4/4.5, Godot akan menawarkan konversi project. Pilih **Convert/OK**.

## 2. Kontrol

| Tombol | Fungsi |
|---|---|
| W A S D / panah | Berjalan |
| E / Spasi / Enter | Bicara, periksa benda, lanjutkan dialog |
| TAB / B | Buka/tutup Buku Catatan Detektif |
| ESC | Jeda (di TKP: keluar dari TKP) |
| Mouse | Tombol menu, klik benda di TKP, tombol GRID |

## 3. Alur permainan

Splash → Menu (saat pertama kali dibuka, pemain langsung diminta mengisi nama) → **MAIN** → **Pilih Level**
→ **Level 1 Sekolah** (sekaligus tutorial) → **Level 2 Taman Kota** → **Level 3 Pasar Rakyat** → **Level 4 Museum Kota**
→ Ending (poster tersusun, Klub Peduli Lingkungan) → **Rapor Detektif**.

- **Nama & progres tersimpan** di `user://profil.cfg`. Saat game dibuka lagi, nama dan level yang sudah selesai tetap ada.
- **Pilih Level**: level berikutnya terkunci (ikon gembok) sampai level sebelumnya selesai. Selesai satu level,
  game langsung lanjut ke level berikutnya. Level yang sudah selesai boleh diulang; hasil pengukuran level itu
  diganti dengan hasil terbaru. Tombol **RAPOR** aktif setelah keempat level selesai.
- **GANTI** (di bawah menu utama): untuk pemain baru, misalnya siswa berikutnya di komputer lab. Progres dimulai
  lagi dari Level 1; hasil pemain sebelumnya tetap ada di CSV.
- Kotak dialog otomatis pindah ke **atas layar** bila pemain atau lawan bicara berada di bagian bawah layar.

Tidak ada Game Over dan tidak ada pemberitahuan benar/salah. Apa pun pilihan pemain, cerita tetap berlanjut.

## 4. Pengukuran 4 pilar CT (diam-diam)

Setiap pilar punya **2 kesempatan**, dan satu aksi hanya dinilai untuk satu pilar.

| Level | Pilar | Momen | BERHASIL bila |
|---|---|---|---|
| 1 Sekolah | Abstraksi | Cerita panjang Pak Joko (1 info penting: gudang belakang; basa-basi: kucing di parkiran, nasi kuning di kantin) | Lokasi **pertama** yang dimasuki setelah dialog = Gudang Belakang (bukan Parkiran/Kantin) |
| 2 Taman | Algoritma | Instruksi Bu Wati: Mas Parkir → air mancur → gazebo (gazebo sengaja paling dekat) | Urutan kunjungan pertama ke 3 lokasi itu sesuai instruksi (lokasi lain diabaikan) |
| 3 Pasar | Pengenalan Pola | Setelah Bu Sri memberi kasus | NPC **pertama** yang diajak bicara = Tari (berkacamata) |
| 3 Pasar | Dekomposisi | TKP kios ikan: 24 benda kecil berantakan (6 per sektor), 3 bukti tersamar. GRID membagi layar jadi sektor A–D; klik sektor untuk memperbesarnya | Pemain **memecah ruangan dan menuntaskannya satu per satu**: (1) urutan sektor yang diperiksa tidak pernah kembali ke sektor yang sudah ditinggalkan, dan (2) setiap sektor yang ditinggalkan sudah diperiksa minimal separuh bendanya. Berlaku dengan atau tanpa GRID |
| 4 Museum | Pengenalan Pola | Setelah Pak Hadi memberi kasus | NPC pertama = Kak Arga (berkacamata) |
| 4 Museum | Abstraksi | Cerita Kak Arga (penting: pos satpam; basa-basi: suvenir, kafe) | Lokasi pertama = Pos Satpam |
| 4 Museum | Algoritma | Instruksi Pak Satpam: ruang fosil → ruang batik → gudang | Urutan sesuai instruksi |
| 4 Museum | Dekomposisi | TKP gudang museum (aturan sama) | Sama seperti TKP pertama |

Catatan Dekomposisi: pemain yang langsung menebak bukti tanpa memeriksa sektornya (mis. 3–4 klik acak) dinilai belum
berhasil, karena masalahnya tidak dipecah. Pemain yang rapi per sektor tanpa menekan GRID tetap dinilai berhasil.
Rincian (urutan sektor, jumlah benda diperiksa per sektor, GRID dipakai/tidak, sektor yang diperbesar) tercatat di CSV.

Level 1 dan 2 juga menjadi **fase belajar pola**: orang yang tahu petunjuk selalu berkacamata (Nisa, Bima),
tetapi pola belum dinilai di sana.

### Rumus Rapor
```
rasio_pilar  = berhasil / kesempatan
persen_pilar = rasio_pilar / (jumlah rasio keempat pilar) × 100%
```
Persentase dibulatkan sehingga jumlahnya tepat 100%. Kalau semua rasio 0, setiap pilar diberi 25%.
**Persentase bersifat relatif**: "40% Abstraksi" berarti Abstraksi paling menonjol pada pemain itu
dibanding pilar lainnya, *bukan* kemampuan abstraksinya 40%.

## 5. Hasil tersimpan otomatis (untuk laporan)

Setiap kali Rapor tampil, satu baris ditambahkan ke file CSV (pemisah `;`, bisa dibuka di Excel):

- Windows: `%APPDATA%\Godot\app_userdata\Misteri Detektif Sekolah\hasil_rapor.csv`
- macOS: `~/Library/Application Support/Godot/app_userdata/Misteri Detektif Sekolah/hasil_rapor.csv`
- Linux: `~/.local/share/godot/app_userdata/Misteri Detektif Sekolah/hasil_rapor.csv`

Kolom CSV: waktu, nama, durasi, berhasil/kesempatan per pilar, persen per pilar, gaya dominan, dan rincian setiap
kejadian (contoh: `L1 abstraksi=0 (Cerita Pak Joko: lokasi pertama = kantin)`).

Di Godot: menu **Project → Open User Data Folder** langsung membuka folder ini.

## 6. Hal yang perlu dilengkapi / sering diubah

| Ingin mengubah | Buka file |
|---|---|
| Nama dosen di layar Kredit | `scripts/kredit.gd` (ganti `[NAMA DOSEN]`) |
| Logo kampus di splash | Taruh file PNG di `assets/menu/logo_kampus.png` (otomatis tampil) |
| Dialog & alur tiap level | `scripts/level1.gd` … `scripts/level4.gd` |
| Posisi NPC, zona, benda, titik awal pemain | Buka `scenes/level1.tscn` … `level4.tscn` di editor, lalu geser node-nya |
| Nama/keterangan barang bukti, teks Rapor | `scripts/game.gd` (`ITEMS`, `PROFIL`) |
| Aturan penilaian | `scripts/level_base.gd` (bagian PENGUKURAN) dan `scripts/tkp.gd` (Dekomposisi) |

## 7. Struktur folder

```
project.godot         pengaturan (320x180, diperbesar 4x, font pixel, autoload Game)
scenes/main.tscn      scene utama (menu, rapor, dll. dibuat lewat kode)
scenes/level1-4.tscn  scene tiap level (lihat bagian 7a)
scripts/
  game.gd             autoload: alur, skor 4 pilar, audio, simpan CSV
  level_base.gd       dasar level: peta, pemain, NPC, interaksi, zona, HUD, alat ukur
  level1-4.gd         isi tiap level (dialog & pengukuran)
  tkp.gd              TKP sudut pandang pertama + Mode GRID
  dialog.gd, notebook.gd, menu.gd, options_panel.gd, splash.gd, kredit.gd, ending.gd, rapor.gd
  autotest.gd         uji otomatis (bot)
assets/               semua gambar (pixel art, palet ENDESGA 32), peta + data JSON, musik & SFX (WAV), font
```

## 7a. Isi scene level (`scenes/levelN.tscn`)

```
Level1Sekolah (Node2D, skrip level1.gd)
├─ Peta          Sprite2D      gambar lantai/dasar peta
├─ Tabrakan      StaticBody2D  kotak-kotak tembok & perabot (CollisionShape2D)
├─ Zona          Node2D        Area2D per zona (kuning). Nama node = id zona, mis. "gudang", "parkir"
├─ Benda         Node2D        Area2D per benda (biru). Metadata: kind = inspect / door / item, item = id bukti
├─ Entities      Node2D (Y Sort)
│   └─ bu_rina   Node2D        satu NPC = node bernama id NPC, berisi "Sprite" (Sprite2D) dan "Badan" (StaticBody2D)
├─ SpawnPemain   Marker2D      posisi awal pemain (posisi kaki)
└─ Atas          Sprite2D      atap & pohon yang tampil di atas pemain
```
- **Menggeser** NPC, zona, benda, atau titik awal pemain cukup dilakukan di editor (posisi node = posisi kaki NPC).
  Ukuran zona/benda diubah lewat `Bentuk` (CollisionShape2D) di dalamnya.
- **Nama node jangan diganti**, karena dialog dan pengukuran di `levelN.gd` memakai nama itu (mis. `"pak_joko"`, `"gudang"`).
- Mengubah ukuran zona pengukuran (mis. `gudang`, `parkir`) ikut mengubah kapan pemain dianggap "sampai"; uji lagi setelahnya.

## 8. Uji otomatis (opsional)

Bot memainkan game dari awal sampai Rapor dan mencocokkan skornya (memakai profil uji terpisah,
jadi profil pemain asli tidak tersentuh):
```
godot --headless --path . -- --autotest --skenario=ideal
godot --headless --path . -- --autotest --skenario=campur
```
Untuk mencoba satu level langsung: `godot --path . -- --level=3`

## 9. Export ke .exe (Windows)

Menu **Project → Export → Add… → Windows Desktop**. Jika diminta, unduh *Export Templates*
(Editor → Manage Export Templates). Lalu klik **Export Project**.

Semua gambar, peta, musik, dan efek suara dibuat khusus untuk project ini, jadi bebas dipakai dan dimodifikasi.
