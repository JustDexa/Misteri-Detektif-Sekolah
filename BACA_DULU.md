# Misteri Detektif Sekolah — Project Godot (v1.4)

Game pembelajaran interaktif berbasis investigasi kasus untuk menganalisis **kecenderungan pola pikir
Computational Thinking** (Dekomposisi, Pengenalan Pola, Abstraksi, Algoritma).

> Catatan istilah untuk laporan: yang diukur game ini adalah *kecenderungan pilar CT*, bukan "gaya belajar"
> (visual/auditori/kinestetik). Pakai istilah "kecenderungan Computational Thinking" atau "gaya berpikir".

Afridya Dexa Wahnugrah (K3524020) · Estu Setyoadi Galih Ramdani (K3524050)
PTIK · FKIP · Universitas Sebelas Maret · 2026

---

## 0. Yang berubah di v1.4

| Bagian | Perubahan |
|---|---|
| Gaya dominan | Dua pilar yang sama kuat sekarang tampil berdua ("Si Pengamat Pola & Si Fokus"). Dulu selalu dimenangkan pilar yang urutannya lebih awal, sehingga Algoritma paling jarang keluar. Pemain yang tidak memunculkan pilar apa pun tidak lagi diberi label "Serba Bisa". |
| Dekomposisi (TKP) | Dua jalur penilaian: **manual** dan **GRID**. Sektor yang buktinya sudah ditemukan dianggap selesai, jadi pemain yang rapi tetapi cepat tidak lagi dirugikan. |
| Pengenalan Pola | Pak Satpam tidak dihitung sebagai "NPC pertama". Tari dipindah supaya terlihat dari tempat Bu Sri. |
| Abstraksi | Kak Arga dipindah supaya ketiga lokasi kandidat kira-kira sama jauhnya. |
| Data penelitian | CSV menyimpan **percobaan pertama** terpisah dari hasil terbaru, dan semua angkanya bilangan bulat. |
| Partner | NPC baru, **Kiki**, menemani pemain, menanyakan alasan setelah tindakan dicatat, dan memimpin Rapat Detektif di akhir. |
| Tata letak | Potret dialog, Buku Catatan, Rapor, Pilih Level, popup nama, dan HUD TKP dirapikan (lihat bagian 9). |

## 1. Cara menjalankan

1. Unduh **Godot 4.3 atau lebih baru** (versi *Standard*, bukan .NET) dari godotengine.org. Project ini terakhir
   disimpan dengan Godot 4.7.
2. Buka Godot → **Import** → pilih file `project.godot` di folder ini → **Import & Edit**.
3. Tunggu sebentar saat Godot meng-import semua gambar dan suara (hanya pertama kali).
4. Tekan **F5** (atau tombol ▶ di kanan atas) untuk bermain.

## 2. Kontrol

| Tombol | Fungsi |
|---|---|
| W A S D / panah | Berjalan; memindahkan sorotan di daftar pilihan jawaban |
| E / Spasi / Enter | Bicara, periksa benda, lanjutkan dialog, memilih jawaban |
| 1 – 4 | Memilih jawaban langsung |
| TAB / B | Buka/tutup Buku Catatan Detektif |
| ESC | Jeda (di TKP: keluar dari TKP) |
| Mouse | Tombol menu, klik benda di TKP, tombol GRID, klik jawaban |

Menghadap ke arah Kiki lalu menekan **E** membuat Kiki mengulang tujuan saat ini.

## 3. Alur permainan

Splash → Menu (saat pertama kali dibuka, pemain langsung diminta mengisi nama) → **MAIN** → **Pilih Level**
→ **Level 1 Sekolah** (sekaligus tutorial) → **Level 2 Taman Kota** → **Level 3 Pasar Rakyat** → **Level 4 Museum Kota**
→ Ending (poster tersusun, Klub Peduli Lingkungan, Rapat Detektif) → **Rapor Detektif**.

- **Nama & progres tersimpan** di `user://profil.cfg`.
- **Pilih Level**: level berikutnya terkunci sampai level sebelumnya selesai. Level yang sudah selesai boleh diulang.
  Selesai mengulang, pemain kembali ke Pilih Level (tidak dipaksa mengulang level sesudahnya).
- **GANTI** (di bawah menu utama): untuk pemain baru, misalnya siswa berikutnya di komputer lab. Progres dimulai
  lagi dari Level 1; hasil pemain sebelumnya tetap ada di CSV.

Tidak ada Game Over dan tidak ada pemberitahuan benar/salah. Apa pun pilihan pemain, cerita tetap berlanjut.

## 4. Pengukuran 4 pilar CT

### 4a. Perilaku (diam-diam, 2 kesempatan per pilar, bobot 1)

Satu aksi hanya dinilai untuk satu pilar.

| Level | Pilar | Momen | BERHASIL bila |
|---|---|---|---|
| 1 Sekolah | Abstraksi | Cerita panjang Pak Joko (1 info penting: gudang belakang; basa-basi: kucing di parkiran, nasi kuning di kantin) | Lokasi **pertama** yang dimasuki setelah dialog = Gudang Belakang |
| 2 Taman | Algoritma | Instruksi Bu Wati: Mas Parkir → air mancur → gazebo (gazebo sengaja paling dekat) | Urutan kunjungan pertama ke 3 lokasi itu sesuai instruksi |
| 3 Pasar | Pengenalan Pola | Setelah Bu Sri memberi kasus | NPC **pertama** yang diajak bicara = Tari (berkacamata) |
| 3 Pasar | Dekomposisi | TKP kios ikan | Lihat 4b |
| 4 Museum | Pengenalan Pola | Setelah Pak Hadi memberi kasus | NPC pertama = Kak Arga (berkacamata). Pak Hadi dan Pak Satpam tidak dihitung |
| 4 Museum | Abstraksi | Cerita Kak Arga (penting: pos satpam; basa-basi: suvenir, kafe) | Lokasi pertama = Pos Satpam (masuk ke zonanya, atau berbicara dengan Pak Satpam) |
| 4 Museum | Algoritma | Instruksi Pak Satpam: ruang fosil → ruang batik → gudang | Urutan sesuai instruksi |
| 4 Museum | Dekomposisi | TKP gudang museum | Lihat 4b |

Level 1 dan 2 juga menjadi **fase belajar pola**: orang yang tahu petunjuk selalu berkacamata (Nisa, Bima),
tetapi pola belum dinilai di sana.

### 4b. Dekomposisi di TKP: dua jalur

TKP berisi 24 benda (6 per sektor) dan 3 bukti tersamar. Dinilai saat semua bukti ditemukan. **Salah satu jalur cukup.**

**Jalur manual** (dengan atau tanpa GRID): pemain menuntaskan ruangan bagian demi bagian.
1. *Runtut*: urutan sektor yang diperiksa tidak pernah kembali ke sektor yang sudah ditinggalkan.
2. *Tuntas*: setiap sektor yang ditinggalkan sudah selesai, yaitu buktinya sudah ditemukan di sana **atau** minimal
   separuh bendanya sudah diperiksa. Sektor yang tidak berisi bukti harus diperiksa minimal separuh.
3. *Cukup*: minimal 6 benda diperiksa. Kurang dari itu berarti menebak, bukan memecah.

**Jalur GRID**: pemain sendiri yang memecah ruangan dengan alat GRID.
1. Minimal 2 sektor diperbesar, dan urutan sektor yang diperbesar tidak kembali ke sektor lama.
2. Minimal 60% klik dilakukan saat sektor diperbesar.
3. Setiap sektor yang diperbesar benar-benar diperiksa (minimal 1 benda diklik saat diperbesar).

Sekadar menekan tombol GRID lalu mengeklik acak di tampilan penuh **tidak** dihitung.
Jalur yang terpenuhi (`grid` / `manual` / `tidak`) dicatat di kolom `jalur_tkp`.

Hasil simulasi 20.000 kali per gaya bermain pada tata letak benda yang sebenarnya:

| Gaya bermain | Aturan lama | Aturan baru |
|---|---|---|
| Per sektor, pindah begitu bukti sektor itu ketemu | ±45% berhasil | ±99% berhasil |
| Per sektor lewat GRID (perbesar satu per satu) | ±45% berhasil | 100% berhasil |
| Klik acak (dengan atau tanpa menekan GRID) | 0% | 0% |
| Langsung mengeklik 3 bukti saja | tidak berhasil | tidak berhasil |

### 4c. Partner: Kiki

Kiki mengikuti pemain dari belakang. Ia tidak punya tabrakan (tidak menghalangi jalan), tidak berkacamata
(kacamata adalah ciri pola yang diukur), dan tidak pernah memberi tahu jawaban.

**Alasan.** Setelah sebuah perilaku dicatat, Kiki bertanya "kenapa?" dengan 3–4 pilihan yang urutannya diacak.
Pertanyaan selalu muncul, baik pemain berhasil maupun tidak, dan Kiki selalu menjawab netral, supaya tidak
menjadi tanda benar/salah.

| Momen | Ditanya? | Alasan yang menguatkan |
|---|---|---|
| L1 Abstraksi | ya | `info` (menyebut info penting dari cerita) |
| L2 Algoritma | ya | `instruksi` (mengikuti urutan dari NPC) |
| L3 Pola, L3 Dekomposisi | **tidak** | — |
| L4 Pola | ya, sebelum NPC itu berbicara | `pola` (yang tahu petunjuk selalu berkacamata) |
| L4 Abstraksi, L4 Algoritma | ya | `info`, `instruksi` |
| L4 Dekomposisi | ya, setelah TKP selesai | `bagi` (dibagi jadi beberapa bagian) |

Di Level 3 Kiki sengaja tidak bertanya: pilihan "yang berkacamata" atau "kubagi jadi beberapa bagian" akan
mengajari strategi untuk pengukuran Pola dan Dekomposisi kedua di Level 4.

Alasan **tidak mengubah** kolom berhasil/tidak. Ia hanya mengoreksi nilai untuk Rapor:
perilaku berhasil dengan alasan lain (`dekat`, `asal`, `jelajah`, `searah`, `tampak`, `curiga`) dihitung
sebagai **kebetulan** dan bernilai 0,5.

**Ajakan jalan pintas.** Tepat setelah instruksi berurutan (L2 dan L4), Kiki berkata "langsung ke sana saja, yuk?",
lalu diam sampai pengukuran selesai. Pemain yang tetap mengikuti instruksi memberi bukti Algoritma yang lebih kuat.

**Rapat Detektif.** Di akhir cerita Kiki mengajukan 4 pertanyaan singkat, satu per pilar, bobot 0,5:
ciri yang sama pada pemberi petunjuk (Pola), info terpenting untuk laporan (Abstraksi), urutan kerja yang tepat
(Algoritma), dan cara menyelesaikan kasus besar (Dekomposisi). Letaknya di akhir supaya tidak memengaruhi
pengukuran perilaku mana pun.

**Minta diingatkan.** Menyapa Kiki hanya mengulang tujuan saat ini. Jumlahnya tercatat di `bantuan_partner`.

### 4d. Rumus Rapor

```
nilai perilaku = 1 (berhasil), 0,5 (berhasil tetapi alasannya kebetulan), 0 (tidak)
poin_pilar     = jumlah nilai perilaku + 0,5 × jawaban Rapat Detektif yang sesuai
bobot_pilar    = jumlah kesempatan perilaku + 0,5 (Rapat Detektif)          → biasanya 2,5
rasio_pilar    = poin_pilar / bobot_pilar
persen_pilar   = rasio_pilar / (jumlah rasio keempat pilar) × 100%
```

Persentase dibulatkan sehingga jumlahnya tepat 100%. **Persentase bersifat relatif**: "40% Abstraksi" berarti
Abstraksi paling menonjol pada pemain itu dibanding pilar lainnya, *bukan* kemampuan abstraksinya 40%.

Gaya dominan:

| Keadaan | Label |
|---|---|
| Satu pilar tertinggi | Si Pemecah Masalah / Si Pengamat Pola / Si Fokus / Si Sistematis |
| Dua pilar sama tinggi | Keduanya, mis. "Si Pengamat Pola & Si Fokus" |
| Tiga atau empat pilar sama tinggi | Detektif Serba Bisa |
| Tidak ada pilar yang muncul sama sekali | Detektif Penjelajah |

Rapor yang dilihat siswa memakai hasil **terbaru**. Untuk penelitian, pakai kolom percobaan pertama di CSV.

**Halaman Bukti.** Tombol **LIHAT BUKTI** (atau TAB) di Rapor membuka satu halaman per pilar (pindah lewat ikon
atau tombol kiri/kanan). Isinya: apa yang dilihat untuk pilar itu, setiap tindakan pemain dalam kalimat sederhana
(mis. "Setelah cerita Pak Joko, kamu pertama ke Kantin."), poin yang didapat dari tindakan itu (+1, +0.5, +0),
alasan yang dipilih pemain, dan total "Poin: 1.5 dari 2.5". Kalimatnya dibuat saat pengukuran dicatat
(`teks` pada `Game.catat`), jadi profil dari versi sebelumnya hanya menampilkan rincian teknisnya.

## 5. Hasil tersimpan otomatis (untuk laporan)

Setiap kali Rapor tampil, satu baris ditambahkan ke file CSV (pemisah `;`, bisa dibuka di Excel):

- Windows: `%APPDATA%\Godot\app_userdata\Misteri Detektif Sekolah\hasil_rapor.csv`
- macOS: `~/Library/Application Support/Godot/app_userdata/Misteri Detektif Sekolah/hasil_rapor.csv`
- Linux: `~/.local/share/godot/app_userdata/Misteri Detektif Sekolah/hasil_rapor.csv`

Di Godot: menu **Project → Open User Data Folder** langsung membuka folder ini.
File CSV dari v1.3 (kolomnya berbeda) otomatis diganti namanya menjadi `hasil_rapor_lama_<tanggal>.csv`, tidak dihapus.

| Kolom | Isi |
|---|---|
| `waktu`, `nama`, `durasi_detik` | Identitas baris |
| `percobaan_per_level` | Berapa kali tiap level dimulai, mis. `1|1|2|1` |
| `<pilar>_berhasil`, `<pilar>_kesempatan` | **Perilaku murni, percobaan pertama.** Inilah angka mentah untuk analisis |
| `<pilar>_kebetulan` | Berapa dari `_berhasil` yang alasannya bukan pilar itu |
| `<pilar>_rapat` | Jawaban Rapat Detektif: 1 sesuai, 0 tidak, kosong bila rapat dimatikan |
| `persen_<pilar>`, `gaya_dominan` | Hasil rumus Rapor dari percobaan pertama |
| `terbaru_<pilar>_berhasil/_kesempatan`, `gaya_dominan_terbaru` | Hasil setelah level diulang (sama dengan di atas bila tidak pernah mengulang) |
| `alasan` | Kode alasan per momen, mis. `L1.abstraksi=info | L4.pola=dekat` |
| `jalur_tkp` | `L3=grid | L4=manual` |
| `godaan_partner` | `ya` bila ajakan jalan pintas aktif |
| `bantuan_partner` | Berapa kali pemain menyapa Kiki per level |
| `rincian`, `rincian_terbaru` | Setiap kejadian secara lengkap |

Semua angka berupa bilangan bulat, jadi aman dibuka di Excel dengan pengaturan wilayah apa pun.
Nilai terkoreksi = `_berhasil` − 0,5 × `_kebetulan`.

"Percobaan pertama" berarti saat pemain **pertama kali mengalami** momen pengukuran itu. Catatannya langsung
ditulis ke `profil.cfg`, jadi tidak hilang walaupun pemain keluar di tengah level lalu mengulang.

## 6. Pengaturan penelitian

Di bagian atas `scripts/game.gd`:

| Variabel | Bawaan | Fungsi |
|---|---|---|
| `PARTNER_AKTIF` | true | Kiki ikut menemani. Bila false, game berjalan seperti tanpa partner |
| `TANYA_ALASAN` | true | Kiki menanyakan alasan |
| `GODAAN_PARTNER` | true | Ajakan jalan pintas setelah instruksi berurutan |
| `RAPAT_DETEKTIF` | true | 4 pertanyaan di akhir cerita |
| `BOBOT_RAPAT` | 0.5 | Bobot 1 jawaban rapat |
| `NILAI_KEBETULAN` | 0.5 | Nilai perilaku berhasil yang alasannya kebetulan |

### Keterbatasan yang perlu ditulis di laporan

- Setiap pilar hanya punya 2 kesempatan perilaku. Rapat Detektif dan koreksi alasan membuat hasil seri lebih
  jarang, tetapi tidak menggantikan jumlah kesempatan yang sedikit.
- Jawaban alasan dan Rapat Detektif adalah pilihan ganda, jadi bisa ditebak. Karena itu bobotnya separuh dan
  disimpan di kolom terpisah dari perilaku.
- Alasan Pola dan Dekomposisi hanya ditanyakan di kesempatan kedua (Level 4).
- Ajakan jalan pintas membuat Algoritma ikut mengukur keteguhan terhadap saran teman. Bila ingin Algoritma
  murni, set `GODAAN_PARTNER = false` untuk semua responden, atau bandingkan dua kelompok.
- Persentase Rapor bersifat relatif. Untuk statistik, pakai kolom `_berhasil/_kesempatan`.

## 7. Hal yang perlu dilengkapi / sering diubah

| Ingin mengubah | Buka file |
|---|---|
| Nama dosen di layar Kredit | `scripts/kredit.gd` |
| Logo kampus di splash | Taruh file PNG di `assets/menu/logo_kampus.png` (otomatis tampil) |
| Dialog & alur tiap level, pertanyaan alasan (`_alasan`) | `scripts/level1.gd` … `scripts/level4.gd` |
| Pertanyaan Rapat Detektif | `scripts/ending.gd` (`RAPAT`) |
| Posisi NPC, zona, benda, titik awal pemain | Buka `scenes/level1.tscn` … `level4.tscn` di editor, lalu geser node-nya |
| Nama/keterangan barang bukti, teks Rapor | `scripts/game.gd` (`ITEMS`, `PROFIL`, `PROFIL_SINGKAT`) |
| Aturan penilaian | `scripts/game.gd` (skor, gaya dominan, CSV), `scripts/level_base.gd` (bagian PENGUKURAN), `scripts/tkp.gd` (fungsi `nilai`) |
| Nama atau gambar partner | `assets/chars/npc.json` (`kiki`), `assets/chars/partner.png`, `por_kiki.png`, `por_kiki_senang.png` |

Bila menggeser NPC atau zona pengukuran, periksa lagi jaraknya. Patokan yang dipakai sekarang:

| Momen | Jarak jalan kaki dari titik awal |
|---|---|
| L1 Abstraksi (dari Pak Joko) | kantin ±97, parkiran ±106, **gudang ±122** |
| L3 Pola (dari Bu Sri) | Pak pedagang buah ±121, **Tari ±135**; NPC lain di luar layar |
| L4 Pola (dari Pak Hadi) | **Kak Arga ±37**, pemandu ±40, anak rombongan ±72 |
| L4 Abstraksi (dari Kak Arga) | **pos satpam ±89**, toko suvenir ±96, kafe ±96 |

## 8. Struktur folder

```
project.godot         pengaturan (320x180, diperbesar 4x, font pixel, autoload Game)
scenes/main.tscn      scene utama (menu, rapor, dll. dibuat lewat kode)
scenes/level1-4.tscn  scene tiap level
scripts/
  game.gd             autoload: alur, skor 4 pilar, gaya dominan, audio, simpan CSV, pengaturan penelitian
  level_base.gd       dasar level: peta, pemain, partner, NPC, interaksi, zona, HUD, alat ukur
  level1-4.gd         isi tiap level (dialog, pengukuran, pertanyaan alasan)
  partner.gd          Kiki: mengikuti jejak pemain
  tkp.gd              TKP sudut pandang pertama + Mode GRID + aturan Dekomposisi
  dialog.gd           kotak dialog + daftar pilihan jawaban
  ending.gd           ending + Rapat Detektif
  notebook.gd, menu.gd, options_panel.gd, splash.gd, kredit.gd, rapor.gd, level_select.gd, ui_kit.gd, fx.gd
  autotest.gd         uji otomatis (bot)
assets/               gambar (pixel art, palet ENDESGA 32), peta + data JSON, musik & SFX (WAV), font
```

Isi scene level (`scenes/levelN.tscn`):

```
Level1Sekolah (Node2D, skrip level1.gd)
├─ Peta          Sprite2D      gambar lantai/dasar peta
├─ Tabrakan      StaticBody2D  kotak-kotak tembok & perabot
├─ Zona          Node2D        Area2D per zona. Nama node = id zona, mis. "gudang", "parkir"
├─ Benda         Node2D        Area2D per benda. Metadata: kind = inspect / door / item, item = id bukti
├─ Entities      Node2D (Y Sort)
│   └─ bu_rina   Node2D        satu NPC = node bernama id NPC, berisi "Sprite" dan "Badan"
├─ SpawnPemain   Marker2D      posisi awal pemain (posisi kaki). Kiki muncul di sebelah kirinya
└─ Atas          Sprite2D      atap & pohon yang tampil di atas pemain
```

**Nama node jangan diganti**, karena dialog dan pengukuran di `levelN.gd` memakai nama itu.

## 9. Tata letak yang dirapikan di v1.4

| Layar | Masalah | Perbaikan |
|---|---|---|
| Dialog | Potret 48×48 melar jadi 56×56 dan keluar dari bingkai | Ukuran potret dikunci 48×48 |
| Dialog | Papan nama punya pita gelap di sisi kanan | Margin nine-patch dibetulkan |
| Buku Catatan | Teks tidak sejajar dengan garis buku, sebagian tercoret garis | Semua teks memakai grid baris 11 px yang sama dengan garis |
| Buku Catatan, Jeda | Tab dan panel bertumpuk dengan HUD | HUD disembunyikan saat buku atau jeda terbuka |
| Rapor | Deskripsi 4 baris menimpa daftar pilar; catatan kaki menempel bingkai | Dua kolom dengan posisi tetap; batang persentase tidak lagi bergeser |
| Rapor | "Serba Bisa" memakai lencana Pola | Empat ikon pilar; dua ikon untuk hasil seri; lencana besar untuk satu pilar |
| Pilih Level | "Pasar Rakyat" menabrak bingkai kartu | Nama panjang dipecah dua baris; status di baris yang sama pada semua kartu |
| Popup nama | Kursor membelah tulisan "Nama kamu"; isi panel menumpuk di atas | Rata kiri; isi dibagi rata |
| Menu | Papan nama dan tombol GANTI menempel di tepi bawah | Dinaikkan 2 px |
| TKP | Penghitung bukti dan label tombol menutupi benda, terutama saat sektor diperbesar | Penghitung pindah ke ruas atas yang kosong; label disembunyikan saat diperbesar; tombol SEMUA pindah ke samping tombol keluar |
| TKP | Pesan di bawah menutupi benda yang baru diklik | Pesan pindah ke atas bila benda yang diklik ada di bagian bawah |
| HUD level | Nama lokasi sulit dibaca di lantai terang | Diberi papan gelap |

Tambahan lain: bayangan di bawah kaki karakter, kartu level terangkat saat disorot, Kiki ikut melompat saat bukti
ditemukan.

## 10. Uji otomatis (opsional)

Bot memakai profil uji terpisah, jadi profil pemain asli tidak tersentuh.

```
godot --headless --path . -- --autotest --skenario=ideal     main sampai Rapor, semua pilar berhasil
godot --headless --path . -- --autotest --skenario=campur    hasil campuran + ulang Level 1 (percobaan pertama tidak tertimpa)
godot --headless --path . -- --autotest --skenario=aturan    aturan TKP dua jalur, hasil seri, pembulatan (tanpa bermain)
godot --headless --path . -- --autotest --skenario=tombol    keyboard, mouse, angka pada pilihan jawaban; Kiki mengikuti
```

Tambahkan `--tanpa-partner` pada `ideal`/`campur` untuk menguji game dengan partner dimatikan.
Untuk mencoba satu level langsung: `godot --path . -- --level=3`

## 11. Export ke .exe (Windows)

Menu **Project → Export → Add… → Windows Desktop**. Jika diminta, unduh *Export Templates*
(Editor → Manage Export Templates). Lalu klik **Export Project**.

Semua gambar, peta, musik, dan efek suara dibuat khusus untuk project ini, jadi bebas dipakai dan dimodifikasi.
