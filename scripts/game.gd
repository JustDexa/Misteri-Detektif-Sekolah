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
const PROFIL := {
	"dekomposisi": ["Si Pemecah Masalah", "Kamu suka memecah masalah besar menjadi bagian-bagian kecil, lalu menyelesaikannya satu per satu."],
	"pola": ["Si Pengamat Pola", "Kamu jeli melihat kesamaan yang berulang, lalu memakainya untuk menebak langkah berikutnya."],
	"abstraksi": ["Si Fokus", "Kamu pandai menyaring informasi: yang penting kamu ambil, yang tidak penting kamu abaikan."],
	"algoritma": ["Si Sistematis", "Kamu teliti mengikuti langkah demi langkah dengan urutan yang tepat."],
	"seimbang": ["Detektif Serba Bisa", "Semua cara berpikirmu muncul seimbang. Kamu bisa memakai cara berbeda untuk masalah berbeda."],
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
var skor := {}
var peluang := {}
var riwayat := []
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
	save_profil()
	if level_index < LEVELS.size() - 1:
		mulai_level(level_index + 1)
	else:
		change("res://scripts/ending.gd")


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
	tkp_state = {}
	_hitung()


func save_profil() -> void:
	var cf := ConfigFile.new()
	cf.set_value("profil", "nama", player_name)
	cf.set_value("progres", "selesai", level_done)
	cf.set_value("progres", "riwayat", riwayat)
	cf.set_value("progres", "bukti", inventory)
	cf.set_value("progres", "durasi", durasi)
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
	riwayat = []
	inventory = []
	level_done = []
	tkp_state = {}
	level_index = 0
	grid_tutorial_seen = false
	start_ms = Time.get_ticks_msec()


## Catat satu kesempatan pengukuran. Satu aksi hanya untuk satu pilar.
func catat(pilar: String, berhasil: bool, detail := "") -> void:
	riwayat.append({
		"level": level_index + 1,
		"pilar": pilar,
		"berhasil": berhasil,
		"detail": detail,
		"detik": int((Time.get_ticks_msec() - level_start_ms) / 1000.0),
	})
	_hitung()
	print("[CT] level %d | %s | %s | %s" % [level_index + 1, pilar, "BERHASIL" if berhasil else "tidak", detail])


## Hitung ulang skor & kesempatan dari riwayat.
func _hitung() -> void:
	for p in PILAR:
		skor[p] = 0
		peluang[p] = 0
	for r in riwayat:
		peluang[r["pilar"]] += 1
		if r["berhasil"]:
			skor[r["pilar"]] += 1


## Rasio keberhasilan per pilar (skor/peluang), lalu dinormalisasi menjadi distribusi 100%.
func persentase() -> Dictionary:
	var rasio := {}
	var total := 0.0
	for p in PILAR:
		rasio[p] = (float(skor[p]) / peluang[p]) if peluang[p] > 0 else 0.0
		total += rasio[p]
	var hasil := {}
	for p in PILAR:
		hasil[p] = (rasio[p] / total * 100.0) if total > 0.0 else 25.0
	return hasil


## Persentase dibulatkan ke bilangan bulat yang jumlahnya tepat 100 (metode sisa terbesar).
func persentase_bulat() -> Dictionary:
	var pr := persentase()
	var hasil := {}
	var sisa := []
	var jumlah := 0
	for p in PILAR:
		var f: float = pr[p]
		hasil[p] = int(floor(f))
		jumlah += hasil[p]
		sisa.append([f - floor(f), p])
	sisa.sort_custom(func(a, b): return a[0] > b[0])
	var i := 0
	while jumlah < 100 and i < sisa.size():
		hasil[sisa[i][1]] += 1
		jumlah += 1
		i += 1
	return hasil


func dominan() -> String:
	var pr := persentase()
	var best := ""
	var best_v := -1.0
	var seri := 0
	for p in PILAR:
		if pr[p] > best_v + 0.01:
			best_v = pr[p]
			best = p
			seri = 1
		elif absf(pr[p] - best_v) <= 0.01:
			seri += 1
	if seri >= 3:
		return "seimbang"
	return best


func simpan_hasil() -> String:
	var path := "user://hasil_rapor.csv"
	var baru := not FileAccess.file_exists(path)
	var f: FileAccess
	if baru:
		f = FileAccess.open(path, FileAccess.WRITE)
	else:
		f = FileAccess.open(path, FileAccess.READ_WRITE)
	if f == null:
		return ""
	f.seek_end()
	if baru:
		var head := ["waktu", "nama", "durasi_menit"]
		for p in PILAR:
			head.append(p + "_berhasil")
			head.append(p + "_kesempatan")
		for p in PILAR:
			head.append("persen_" + p)
		head.append("gaya_dominan")
		head.append("rincian")
		f.store_line(";".join(head))
	var pr := persentase_bulat()
	var total_detik := 0
	for k in durasi:
		total_detik += int(durasi[k])
	var row := [Time.get_datetime_string_from_system(false, true), player_name.replace(";", ","),
		"%.1f" % (total_detik / 60.0)]
	for p in PILAR:
		row.append(str(skor[p]))
		row.append(str(peluang[p]))
	for p in PILAR:
		row.append(str(pr[p]))
	row.append(PROFIL[dominan()][0])
	var rinci := []
	for r in riwayat:
		rinci.append("L%d %s=%s (%s)" % [r["level"], r["pilar"], "1" if r["berhasil"] else "0", str(r["detail"]).replace(";", ",")])
	row.append(" | ".join(rinci))
	f.store_line(";".join(row))
	f.close()
	last_saved_path = ProjectSettings.globalize_path(path)
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
