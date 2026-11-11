extends Node
## Autoload "Game": alur permainan, sistem skor 4 pilar Computational Thinking, audio, dan penyimpanan hasil.

const LEVELS := [
	"res://scenes/level1.tscn",
	"res://scenes/level2.tscn",
	"res://scenes/level3.tscn",
	"res://scenes/level4.tscn",
]
## Barang bukti milik tiap level (dipakai saat level diulang).
const ITEM_LEVEL := {
	"sapu": 0, "jejak": 0, "poster1": 0,
	"selang": 1, "daftar": 1, "poster2": 1,
	"ember": 2, "struk": 2, "poster3": 2,
	"kemoceng": 3, "catatan": 3, "poster4": 3,
}
const TKP_LEVEL := {"kios_ikan": 2, "gudang_museum": 3}
const PILAR := ["dekomposisi", "pola", "abstraksi", "algoritma"]
const PILAR_NAMA := {
	"dekomposisi": "Dekomposisi",
	"pola": "Pengenalan Pola",
	"abstraksi": "Abstraksi",
	"algoritma": "Algoritma",
}
const PILAR_WARNA := {
	"dekomposisi": Color("0099db"),
	"pola": Color("feae34"),
	"abstraksi": Color("3e8948"),
	"algoritma": Color("e43b44"),
}
## ---------------------------------------------------------------- PENGATURAN PENELITIAN
## Ubah di sini bila ingin mematikan salah satu fitur partner (mis. untuk kelompok pembanding).
var PARTNER_AKTIF := true      # Kiki ikut menemani pemain
var TANYA_ALASAN := true       # Kiki menanyakan alasan SETELAH sebuah tindakan dicatat
var GODAAN_PARTNER := true     # Kiki mengajak mengambil jalan pintas tepat setelah instruksi berurutan (Algoritma)
var RAPAT_DETEKTIF := true     # 4 pertanyaan singkat di akhir cerita (1 per pilar)
const BOBOT_RAPAT := 0.5       # bobot 1 jawaban Rapat Detektif dibanding 1 perilaku (= 1.0)
const NILAI_KEBETULAN := 0.5   # perilaku berhasil tetapi alasannya "paling dekat / asal" hanya dihitung separuh
## Alasan yang MENGUATKAN perilaku (pemain memang memakai pilar itu). Alasan lain = kebetulan.
const ALASAN_MENGUATKAN := ["info", "instruksi", "pola", "bagi"]
const LEVEL_RAPAT := 5         # nomor "level" untuk catatan Rapat Detektif

const PROFIL := {
	"dekomposisi": ["Si Pemecah Masalah", "Kamu suka memecah masalah besar menjadi bagian-bagian kecil, lalu menyelesaikannya satu per satu."],
	"pola": ["Si Pengamat Pola", "Kamu jeli melihat kesamaan yang berulang, lalu memakainya untuk menebak langkah berikutnya."],
	"abstraksi": ["Si Fokus", "Kamu pandai menyaring informasi: yang penting kamu ambil, yang tidak penting kamu abaikan."],
	"algoritma": ["Si Sistematis", "Kamu teliti mengikuti langkah demi langkah dengan urutan yang tepat."],
	"seimbang": ["Detektif Serba Bisa", "Semua cara berpikirmu muncul seimbang. Kamu bisa memakai cara berbeda untuk masalah berbeda."],
	"belum": ["Detektif Penjelajah", "Gaya berpikirmu belum terlihat jelas. Yuk, selidiki sekali lagi dengan caramu sendiri!"],
}
## Dipakai bila DUA pilar sama kuat: "kamu <a>, dan <b>."
const PROFIL_SINGKAT := {
	"dekomposisi": "suka memecah masalah",
	"pola": "jeli melihat pola",
	"abstraksi": "pandai memilah yang penting",
	"algoritma": "teliti mengikuti urutan",
}
const ITEMS := {
	"sapu": ["Sapu Kelas", "Sapu ijuk milik kelas. Ditemukan di dekat gudang belakang sekolah."],
	"jejak": ["Jejak Sepatu", "Jejak sepatu berlumpur menuju gudang. Ukurannya kecil, seperti sepatu anak-anak."],
	"poster1": ["Sobekan Poster 1", "Potongan kiri atas sebuah poster berwarna hijau."],
	"selang": ["Selang Penyiram", "Selang hijau milik petugas Taman Kota. Ditemukan di belakang gazebo."],
	"daftar": ["Daftar Alat", "Sapu: sudah. Selang: sudah. Ember: belum. Kemoceng: belum. Daftar milik siapa ini?"],
	"poster2": ["Sobekan Poster 2", "Potongan kanan atas poster. Warnanya sama dengan sobekan pertama."],
	"ember": ["Ember Biru", "Ember jualan Bu Sri. Ditemukan di kios ikan yang berantakan."],
	"struk": ["Struk Belanja", "Struk pembelian 20 kantong sampah besar. Untuk apa kantong sebanyak itu?"],
	"poster3": ["Sobekan Poster 3", "Potongan kiri bawah poster. Ada gambar alat-alat kebersihan."],
	"kemoceng": ["Kemoceng", "Kemoceng bulu milik Museum Kota. Ditemukan di gudang museum."],
	"catatan": ["Catatan Rencana", "Catatan: 'Minggu pagi, kumpul di taman. Bawa sapu, selang, ember, kemoceng!'"],
	"poster4": ["Sobekan Poster 4", "Potongan kanan bawah poster. Sekarang posternya bisa disusun utuh!"],
}
const ITEM_URUTAN := ["sapu", "jejak", "poster1", "selang", "daftar", "poster2", "ember", "struk", "poster3", "kemoceng", "catatan", "poster4"]
const LEVEL_INFO := [
	["Sekolah", "Sapu kelas hilang"],
	["Taman Kota", "Selang taman hilang"],
	["Pasar Rakyat", "Ember Bu Sri hilang"],
	["Museum Kota", "Kemoceng hilang"],
]

var container: Node
var current: Node
var fader: ColorRect
var busy := false

var PROFIL_PATH := "user://profil.cfg"
const SETTING_PATH := "user://pengaturan.cfg"
var player_name := ""
var level_index := 0
var durasi := {}
var level_start_ms := 0
var skor := {}       # perilaku berhasil per pilar (bilangan bulat)
var peluang := {}    # kesempatan perilaku per pilar
var poin := {}       # nilai berbobot per pilar (perilaku dikoreksi alasan + Rapat Detektif)
var bobot := {}      # bobot total per pilar
var riwayat := []    # hasil TERBARU (inilah yang tampil di Rapor)
var pertama := {}    # momen -> catatan saat PERTAMA KALI pemain mengalami momen itu (untuk penelitian)
var percobaan := [0, 0, 0, 0]   # berapa kali tiap level dimulai
var bantuan := {}    # nomor level -> berapa kali pemain bertanya kepada partner
var auto_jawab := {} # uji otomatis: kunci pertanyaan -> kode jawaban
var inventory := []
var level_done := []
var start_ms := 0
var grid_tutorial_seen := false
var tkp_state := {}
var last_saved_path := ""

var font: Font
var theme_main: Theme
var music: AudioStreamPlayer
var sfx_players: Array = []
var _sfx_cache := {}
var bgm_name := ""
var vol_music := 0.7
var vol_sfx := 0.9
var autotest := false
var hold_dialog := false
var hold_tanya := false   # uji otomatis: tahan daftar pilihan di layar (untuk tangkapan layar)


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_setup_input()
	_setup_audio()
	font = load("res://assets/font/pixel.fnt")
	theme_main = Theme.new()
	theme_main.default_font = font
	theme_main.default_font_size = 9
	theme_main.set_constant("line_spacing", "Label", 0)
	get_tree().root.theme = theme_main
	ThemeDB.fallback_font = font
	ThemeDB.fallback_font_size = 9
	var dt := ThemeDB.get_default_theme()
	if dt:
		dt.default_font = font
		dt.default_font_size = 9
	_setup_cursor()
	reset_progress()
	_load_settings()
	load_profil()
	var fl := CanvasLayer.new()
	fl.layer = 100
	add_child(fl)
	fader = ColorRect.new()
	fader.color = Color(1, 1, 1, 1)
	fader.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fader.size = Vector2(320, 180)
	var mat := ShaderMaterial.new()
	mat.shader = load("res://assets/fx/transisi.gdshader")
	mat.set_shader_parameter("progress", 0.0)
	fader.material = mat
	fl.add_child(fader)


func boot(root: Node) -> void:
	container = root
	var args := OS.get_cmdline_user_args()
	autotest = "--autotest" in args
	if autotest:
		add_child(load("res://scripts/autotest.gd").new())
		return
	for a in args:
		if a.begins_with("--shot="):
			_screenshot_later(a.split("=")[1], args)
	for a in args:
		if a.begins_with("--iris="):   # dokumentasi: bekukan transisi pada progres tertentu
			_set_iris(float(a.split("=")[1]))
	for a in args:
		if a.begins_with("--level="):
			if player_name == "":
				player_name = "Detektif"
			level_index = clampi(int(a.split("=")[1]) - 1, 0, LEVELS.size() - 1)
			level_start_ms = Time.get_ticks_msec()
			_swap(LEVELS[level_index])
			return
		if a.begins_with("--screen="):
			_swap("res://scripts/%s.gd" % a.split("=")[1])
			return
	_swap("res://scripts/splash.gd")


## Untuk dokumentasi: simpan tangkapan layar lalu keluar.  -- --shot=/path/file.png --delay=3
func _screenshot_later(path: String, args: PackedStringArray) -> void:
	var delay := 3.0
	for a in args:
		if a.begins_with("--delay="):
			delay = float(a.split("=")[1])
	await get_tree().create_timer(delay).timeout
	var img := get_viewport().get_texture().get_image()
	img.resize(img.get_width() * 3, img.get_height() * 3, Image.INTERPOLATE_NEAREST)
	img.save_png(path)
	print("[shot] ", path)
	get_tree().quit()


# ---------------------------------------------------------------- scene switching
func change(path: String, args := {}) -> void:
	if busy:
		return
	busy = true
	await iris_close()
	_swap(path, args)
	await get_tree().process_frame
	await iris_open()
	busy = false


## Transisi lensa detektif: menutup menuju titik `center` (koordinat layar 320x180).
func iris_close(center := Vector2(160, 90), dur := 0.45) -> void:
	fader.mouse_filter = Control.MOUSE_FILTER_STOP
	fader.material.set_shader_parameter("center", center)
	sfx("sfx_transisi")
	var tw := create_tween()
	tw.tween_method(_set_iris, 0.0, 1.0, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished


func iris_open(dur := 0.45) -> void:
	fader.material.set_shader_parameter("center", Vector2(160, 90))
	var tw := create_tween()
	tw.tween_method(_set_iris, 1.0, 0.0, dur).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished
	fader.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _set_iris(v: float) -> void:
	fader.material.set_shader_parameter("progress", v)


func _swap(path: String, args := {}) -> void:
	if current and is_instance_valid(current):
		current.queue_free()
	Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	var res = load(path)
	var node = res.instantiate() if res is PackedScene else res.new()
	if "args" in node:
		node.args = args
	current = node
	container.add_child(node)


func goto_menu() -> void:
	change("res://scripts/menu.gd")


func goto_level_select() -> void:
	change("res://scripts/level_select.gd")


## Level bisa dimainkan bila level sebelumnya sudah selesai.
func level_terbuka(i: int) -> bool:
	return i == 0 or (i - 1) in level_done


func semua_selesai() -> bool:
	for i in LEVELS.size():
		if not i in level_done:
			return false
	return true


## Mulai (atau ulangi) satu level. Hasil lama level itu dihapus agar diganti hasil baru.
func mulai_level(i: int) -> void:
	load_profil()
	percobaan[i] = int(percobaan[i]) + 1
	bantuan[i + 1] = 0
	_simpan_bagian({"percobaan": percobaan})
	var baru := []
	for r in riwayat:
		if int(r["level"]) != i + 1:
			baru.append(r)
	riwayat = baru
	var inv := []
	for it in inventory:
		if ITEM_LEVEL.get(it, -1) != i:
			inv.append(it)
	inventory = inv
	for t in TKP_LEVEL:
		if TKP_LEVEL[t] == i:
			tkp_state.erase(t)
	_hitung()
	level_index = i
	level_start_ms = Time.get_ticks_msec()
	change(LEVELS[i])


func goto_level(i: int) -> void:
	mulai_level(i)


func level_selesai() -> void:
	durasi[level_index] = int((Time.get_ticks_msec() - level_start_ms) / 1000.0)
	if not level_index in level_done:
		level_done.append(level_index)
	var ulangan: bool = (level_index + 1) in level_done   # level berikutnya sudah pernah selesai = ini ulangan
	save_profil()
	if level_index >= LEVELS.size() - 1:
		change("res://scripts/ending.gd")
	elif ulangan:
		goto_level_select()   # mengulang satu level tidak memaksa mengulang level sesudahnya
	else:
		mulai_level(level_index + 1)


# ---------------------------------------------------------------- profil pemain (nama + progres)
func load_profil() -> void:
	var cf := ConfigFile.new()
	if cf.load(PROFIL_PATH) != OK:
		return
	player_name = cf.get_value("profil", "nama", "")
	level_done = cf.get_value("progres", "selesai", [])
	riwayat = cf.get_value("progres", "riwayat", [])
	inventory = cf.get_value("progres", "bukti", [])
	durasi = cf.get_value("progres", "durasi", {})
	pertama = cf.get_value("progres", "pertama", {})
	percobaan = cf.get_value("progres", "percobaan", [0, 0, 0, 0])
	bantuan = cf.get_value("progres", "bantuan", {})
	tkp_state = {}
	_hitung()


func save_profil() -> void:
	var cf := ConfigFile.new()
	cf.set_value("profil", "nama", player_name)
	cf.set_value("progres", "selesai", level_done)
	cf.set_value("progres", "riwayat", riwayat)
	cf.set_value("progres", "bukti", inventory)
	cf.set_value("progres", "durasi", durasi)
	cf.set_value("progres", "pertama", pertama)
	cf.set_value("progres", "percobaan", percobaan)
	cf.set_value("progres", "bantuan", bantuan)
	cf.save(PROFIL_PATH)


## Simpan sebagian data SEKARANG JUGA tanpa menyentuh progres lain di berkas. Dipakai untuk data penelitian
## (catatan pertama, jumlah percobaan) supaya tidak hilang bila pemain keluar di tengah level.
func _simpan_bagian(data: Dictionary) -> void:
	var cf := ConfigFile.new()
	cf.load(PROFIL_PATH)
	if not cf.has_section_key("profil", "nama"):
		cf.set_value("profil", "nama", player_name)
	for k in data:
		cf.set_value("progres", k, data[k])
	cf.save(PROFIL_PATH)


## Pemain baru (misalnya siswa berikutnya di komputer lab): nama baru, progres mulai dari awal.
func ganti_pemain(nama: String) -> void:
	nama = nama.strip_edges()
	reset_progress()
	player_name = nama if nama != "" else "Detektif"
	durasi = {}
	save_profil()


func _load_settings() -> void:
	var cf := ConfigFile.new()
	if cf.load(SETTING_PATH) == OK:
		vol_music = cf.get_value("audio", "musik", vol_music)
		vol_sfx = cf.get_value("audio", "sfx", vol_sfx)
		set_volumes()


func save_settings() -> void:
	var cf := ConfigFile.new()
	cf.set_value("audio", "musik", vol_music)
	cf.set_value("audio", "sfx", vol_sfx)
	cf.save(SETTING_PATH)


# ---------------------------------------------------------------- scoring (4 pilar CT)
func reset_progress() -> void:
	skor = {}
	peluang = {}
	for p in PILAR:
		skor[p] = 0
		peluang[p] = 0
		poin[p] = 0.0
		bobot[p] = 0.0
	riwayat = []
	pertama = {}
	percobaan = [0, 0, 0, 0]
	bantuan = {}
	inventory = []
	level_done = []
	tkp_state = {}
	level_index = 0
	grid_tutorial_seen = false
	start_ms = Time.get_ticks_msec()


## Catat satu kesempatan pengukuran PERILAKU. Satu aksi hanya untuk satu pilar.
## Mengembalikan pengenal momen ("L<level>.<pilar>") yang dipakai untuk menempelkan alasan pemain.
## teks = kalimat untuk siswa yang tampil di halaman "Bukti" pada Rapor (mis. "Kamu pertama ke Gudang Belakang.").
func catat(pilar: String, berhasil: bool, detail := "", info := {}, teks := "") -> String:
	var momen := "L%d.%s" % [level_index + 1, pilar]
	_tambah_catatan({
		"level": level_index + 1,
		"pilar": pilar,
		"berhasil": berhasil,
		"detail": detail,
		"detik": int((Time.get_ticks_msec() - level_start_ms) / 1000.0),
		"jenis": "perilaku",
		"momen": momen,
		"alasan": "",
		"info": info,
		"teks": teks,
		"percobaan": int(percobaan[level_index]),
	})
	print("[CT] level %d | %s | %s | %s" % [level_index + 1, pilar, "BERHASIL" if berhasil else "tidak", detail])
	return momen


## Catat satu jawaban Rapat Detektif (pertanyaan singkat di akhir cerita, bobot BOBOT_RAPAT).
func catat_rapat(pilar: String, benar: bool, detail := "", teks := "") -> void:
	_tambah_catatan({
		"level": LEVEL_RAPAT,
		"pilar": pilar,
		"berhasil": benar,
		"detail": detail,
		"detik": 0,
		"jenis": "rapat",
		"momen": "R." + pilar,
		"alasan": "",
		"info": {},
		"teks": teks,
		"percobaan": int(percobaan[LEVELS.size() - 1]),
	})
	print("[CT] rapat | %s | %s | %s" % [pilar, "BENAR" if benar else "tidak", detail])


func _tambah_catatan(r: Dictionary) -> void:
	riwayat.append(r)
	if not pertama.has(r["momen"]):
		pertama[r["momen"]] = r.duplicate(true)
		_simpan_bagian({"pertama": pertama})
	_hitung()


## Tempelkan alasan (jawaban pemain kepada partner) pada catatan perilaku terakhir untuk momen itu.
## Alasan TIDAK mengubah "berhasil"; ia hanya menguatkan atau mengoreksi nilainya (lihat nilai_catatan).
func catat_alasan(momen: String, kode: String, teks := "") -> void:
	for i in range(riwayat.size() - 1, -1, -1):
		var r: Dictionary = riwayat[i]
		if r.get("momen", "") != momen:
			continue
		r["alasan"] = kode
		r["alasan_teks"] = teks
		var f = pertama.get(momen)
		if f != null and int(f.get("percobaan", 0)) == int(r.get("percobaan", 0)) and f.get("alasan", "") == "":
			f["alasan"] = kode
			f["alasan_teks"] = teks
			_simpan_bagian({"pertama": pertama})
		break
	_hitung()
	print("[CT] alasan | %s | %s | %s" % [momen, kode, teks])


func hapus_catatan_level(nomor_level: int) -> void:
	var baru := []
	for r in riwayat:
		if int(r["level"]) != nomor_level:
			baru.append(r)
	riwayat = baru
	_hitung()


## Nilai satu catatan (0..1). Perilaku berhasil yang alasannya "paling dekat / asal" = kebetulan = separuh.
func nilai_catatan(r: Dictionary) -> float:
	if not r.get("berhasil", false):
		return 0.0
	if r.get("jenis", "perilaku") == "perilaku":
		var a: String = r.get("alasan", "")
		if a != "" and not a in ALASAN_MENGUATKAN:
			return NILAI_KEBETULAN
	return 1.0


func bobot_catatan(r: Dictionary) -> float:
	return BOBOT_RAPAT if r.get("jenis", "perilaku") == "rapat" else 1.0


## Ringkasan per pilar dari sebuah daftar catatan.
##   skor/peluang = perilaku murni; kebetulan = berapa dari "skor" yang alasannya bukan pilar itu
##   (paling dekat / asal); rapat = 1/0/-1 (tidak ada);
##   poin/bobot = nilai berbobot yang dipakai Rapor.
func ringkas(daftar: Array) -> Dictionary:
	var out := {}
	for p in PILAR:
		out[p] = {"skor": 0, "peluang": 0, "kebetulan": 0, "rapat": -1, "poin": 0.0, "bobot": 0.0}
	for r in daftar:
		var o: Dictionary = out[r["pilar"]]
		var w := bobot_catatan(r)
		var n := nilai_catatan(r)
		o["poin"] += n * w
		o["bobot"] += w
		if r.get("jenis", "perilaku") == "rapat":
			o["rapat"] = 1 if r["berhasil"] else 0
		else:
			o["peluang"] += 1
			if r["berhasil"]:
				o["skor"] += 1
				if n < 1.0:
					o["kebetulan"] += 1
	return out


## Catatan saat pemain PERTAMA KALI mengalami tiap momen (tidak tertimpa bila level diulang).
func catatan_pertama() -> Array:
	var out := []
	for r in riwayat:
		out.append(pertama.get(r.get("momen", ""), r))
	return out


## Hitung ulang skor & kesempatan dari riwayat terbaru.
func _hitung() -> void:
	var rk := ringkas(riwayat)
	for p in PILAR:
		skor[p] = rk[p]["skor"]
		peluang[p] = rk[p]["peluang"]
		poin[p] = rk[p]["poin"]
		bobot[p] = rk[p]["bobot"]


## Rasio per pilar (poin/bobot), lalu dinormalisasi menjadi distribusi 100%.
func persentase_dari(rk: Dictionary) -> Dictionary:
	var rasio := {}
	var total := 0.0
	for p in PILAR:
		rasio[p] = (float(rk[p]["poin"]) / rk[p]["bobot"]) if rk[p]["bobot"] > 0.0 else 0.0
		total += rasio[p]
	var hasil := {}
	for p in PILAR:
		hasil[p] = (rasio[p] / total * 100.0) if total > 0.0 else 25.0
	return hasil


func persentase() -> Dictionary:
	return persentase_dari(ringkas(riwayat))


## Persentase dibulatkan ke bilangan bulat yang jumlahnya tepat 100 (metode sisa terbesar).
func bulatkan(pr: Dictionary) -> Dictionary:
	var hasil := {}
	var sisa := []
	var jumlah := 0
	for i in PILAR.size():
		var p: String = PILAR[i]
		var f: float = pr[p]
		hasil[p] = int(floor(f + 0.0001))
		jumlah += hasil[p]
		sisa.append([f - hasil[p], -i, p])
	sisa.sort_custom(func(a, b): return a[0] > b[0] + 0.0001 or (absf(a[0] - b[0]) <= 0.0001 and a[1] > b[1]))
	var i := 0
	while jumlah < 100 and i < sisa.size():
		hasil[sisa[i][2]] += 1
		jumlah += 1
		i += 1
	return hasil


func persentase_bulat() -> Dictionary:
	return bulatkan(persentase())


## Gaya dominan dari sebuah ringkasan:
##   "belum"      = tidak ada satu pun pilar yang muncul
##   "<pilar>"    = satu pilar paling menonjol
##   "<a>+<b>"    = DUA pilar sama kuat (tidak lagi dimenangkan pilar yang urutannya lebih awal)
##   "seimbang"   = tiga atau empat pilar sama kuat
func gaya_dari(rk: Dictionary) -> String:
	var total := 0.0
	for p in PILAR:
		total += rk[p]["poin"]
	if total <= 0.0:
		return "belum"
	var pr := persentase_dari(rk)
	var best_v := -1.0
	for p in PILAR:
		best_v = maxf(best_v, pr[p])
	var puncak := []
	for p in PILAR:
		if absf(pr[p] - best_v) <= 0.01:
			puncak.append(p)
	if puncak.size() >= 3:
		return "seimbang"
	return "+".join(puncak)


func dominan() -> String:
	return gaya_dari(ringkas(riwayat))


## Pilar-pilar di dalam sebuah gaya ("pola+abstraksi" -> ["pola", "abstraksi"]). Kosong untuk seimbang/belum.
func pilar_gaya(gaya: String) -> Array:
	var out := []
	for p in gaya.split("+"):
		if p in PILAR:
			out.append(p)
	return out


## [judul, deskripsi] untuk sebuah gaya, termasuk gabungan dua pilar.
func profil_teks(gaya: String) -> Array:
	if PROFIL.has(gaya):
		return PROFIL[gaya]
	var ps := pilar_gaya(gaya)
	if ps.size() == 2:
		return [
			"%s & %s" % [PROFIL[ps[0]][0], PROFIL[ps[1]][0]],
			"Dua gayamu sama kuat: kamu %s, dan %s." % [PROFIL_SINGKAT[ps[0]], PROFIL_SINGKAT[ps[1]]],
		]
	return PROFIL["seimbang"]


# ---------------------------------------------------------------- CSV hasil (untuk laporan penelitian)
const CSV_PATH := "user://hasil_rapor.csv"


func _kepala_csv() -> Array:
	# Semua angka berupa bilangan bulat supaya aman dibuka di Excel dengan pengaturan wilayah apa pun.
	var head := ["waktu", "nama", "durasi_detik", "percobaan_per_level"]
	for p in PILAR:
		head.append(p + "_berhasil")
		head.append(p + "_kesempatan")
	for p in PILAR:
		head.append(p + "_kebetulan")
	for p in PILAR:
		head.append(p + "_rapat")
	for p in PILAR:
		head.append("persen_" + p)
	head.append("gaya_dominan")
	for p in PILAR:
		head.append("terbaru_" + p + "_berhasil")
		head.append("terbaru_" + p + "_kesempatan")
	head.append("gaya_dominan_terbaru")
	head.append_array(["alasan", "jalur_tkp", "godaan_partner", "bantuan_partner", "rincian", "rincian_terbaru"])
	return head


func _rinci(daftar: Array) -> String:
	var out := []
	for r in daftar:
		var nama := "Rapat" if int(r["level"]) == LEVEL_RAPAT else "L%d" % int(r["level"])
		var t := "%s %s=%s (%s)" % [nama, r["pilar"], "1" if r["berhasil"] else "0", str(r["detail"]).replace(";", ",")]
		if r.get("alasan", "") != "":
			t += " [alasan: %s]" % r["alasan"]
		out.append(t)
	return " | ".join(out)


## Tambah satu baris ke CSV. Kolom utama memakai PERCOBAAN PERTAMA; kolom "terbaru_*" memakai hasil terakhir.
func simpan_hasil() -> String:
	var head := ";".join(_kepala_csv())
	if FileAccess.file_exists(CSV_PATH):
		var lama := FileAccess.open(CSV_PATH, FileAccess.READ)
		var baris1 := lama.get_line() if lama else ""
		if lama:
			lama.close()
		if baris1 != head:
			# berkas dari versi game sebelumnya (kolomnya berbeda): arsipkan, jangan dicampur
			var cap := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")
			DirAccess.rename_absolute(ProjectSettings.globalize_path(CSV_PATH),
				ProjectSettings.globalize_path("user://hasil_rapor_lama_%s.csv" % cap))
	var baru := not FileAccess.file_exists(CSV_PATH)
	var f := FileAccess.open(CSV_PATH, FileAccess.WRITE if baru else FileAccess.READ_WRITE)
	if f == null:
		return ""
	f.seek_end()
	if baru:
		f.store_line(head)
	var awal := catatan_pertama()
	var rk1 := ringkas(awal)
	var rk2 := ringkas(riwayat)
	var pb := bulatkan(persentase_dari(rk1))
	var total_detik := 0
	for k in durasi:
		total_detik += int(durasi[k])
	var coba := []
	for n in percobaan:
		coba.append(str(int(n)))
	var row := [Time.get_datetime_string_from_system(false, true), player_name.replace(";", ","),
		str(total_detik), "|".join(coba)]
	for p in PILAR:
		row.append(str(rk1[p]["skor"]))
		row.append(str(rk1[p]["peluang"]))
	for p in PILAR:
		row.append(str(rk1[p]["kebetulan"]))
	for p in PILAR:
		row.append("" if rk1[p]["rapat"] < 0 else str(rk1[p]["rapat"]))
	for p in PILAR:
		row.append(str(pb[p]))
	row.append(profil_teks(gaya_dari(rk1))[0])
	for p in PILAR:
		row.append(str(rk2[p]["skor"]))
		row.append(str(rk2[p]["peluang"]))
	row.append(profil_teks(gaya_dari(rk2))[0])
	var alasan := []
	var jalur := []
	for r in awal:
		if r.get("alasan", "") != "":
			alasan.append("%s=%s" % [r["momen"], r["alasan"]])
		if r["pilar"] == "dekomposisi" and r.get("info", {}).has("jalur"):
			jalur.append("L%d=%s" % [int(r["level"]), r["info"]["jalur"]])
	row.append(" | ".join(alasan))
	row.append(" | ".join(jalur))
	row.append("ya" if (PARTNER_AKTIF and GODAAN_PARTNER) else "tidak")
	var bantu := []
	for i in LEVELS.size():
		bantu.append("L%d=%d" % [i + 1, int(bantuan.get(i + 1, 0))])
	row.append(" | ".join(bantu))
	row.append(_rinci(awal))
	row.append(_rinci(riwayat))
	f.store_line(";".join(row))
	f.close()
	last_saved_path = ProjectSettings.globalize_path(CSV_PATH)
	print("[CT] hasil disimpan ke ", last_saved_path)
	return last_saved_path


# ---------------------------------------------------------------- inventory
func add_item(id: String) -> void:
	if not id in inventory:
		inventory.append(id)


func has_item(id: String) -> bool:
	return id in inventory


# ---------------------------------------------------------------- audio
func _setup_audio() -> void:
	for bus in ["Music", "SFX"]:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var i := AudioServer.bus_count - 1
			AudioServer.set_bus_name(i, bus)
			AudioServer.set_bus_send(i, "Master")
	music = AudioStreamPlayer.new()
	music.bus = "Music"
	add_child(music)
	music.finished.connect(_on_music_finished)
	for i in 8:
		var p := AudioStreamPlayer.new()
		p.bus = "SFX"
		add_child(p)
		sfx_players.append(p)
	set_volumes()


func _on_music_finished() -> void:
	if bgm_name != "":
		music.play()


func set_volumes() -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(maxf(vol_music, 0.0001)))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(maxf(vol_sfx, 0.0001)))


func play_bgm(nama: String) -> void:
	if nama == bgm_name and music.playing:
		return
	bgm_name = nama
	var path := "res://assets/audio/%s.wav" % nama
	if not ResourceLoader.exists(path):
		return
	music.stream = load(path)
	music.play()


func stop_bgm() -> void:
	bgm_name = ""
	music.stop()


func sfx(nama: String, pitch := 1.0) -> void:
	var s = _sfx_cache.get(nama)
	if s == null:
		var path := "res://assets/audio/%s.wav" % nama
		if not ResourceLoader.exists(path):
			return
		s = load(path)
		_sfx_cache[nama] = s
	for p in sfx_players:
		if not p.playing:
			p.stream = s
			p.pitch_scale = pitch
			p.play()
			return
	sfx_players[0].stream = s
	sfx_players[0].play()


# ---------------------------------------------------------------- input & cursor
func _setup_input() -> void:
	_add_keys("gerak_kiri", [KEY_A, KEY_LEFT])
	_add_keys("gerak_kanan", [KEY_D, KEY_RIGHT])
	_add_keys("gerak_atas", [KEY_W, KEY_UP])
	_add_keys("gerak_bawah", [KEY_S, KEY_DOWN])
	_add_keys("interaksi", [KEY_E, KEY_SPACE, KEY_ENTER, KEY_KP_ENTER])
	_add_keys("buku", [KEY_TAB, KEY_B])
	_add_keys("jeda", [KEY_ESCAPE])


func _add_keys(action: String, keys: Array) -> void:
	if not InputMap.has_action(action):
		InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)


func _setup_cursor() -> void:
	_cursor("res://assets/menu/ui_g_kursor_normal.png", Input.CURSOR_ARROW, Vector2(0, 0))
	_cursor("res://assets/menu/ui_g_kursor_interaksi.png", Input.CURSOR_POINTING_HAND, Vector2(7, 7))


func _cursor(path: String, shape: int, hotspot: Vector2) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var tex: Texture2D = load(path)
	var img := tex.get_image()
	img.resize(img.get_width() * 3, img.get_height() * 3, Image.INTERPOLATE_NEAREST)
	Input.set_custom_mouse_cursor(ImageTexture.create_from_image(img), shape, hotspot * 3)
