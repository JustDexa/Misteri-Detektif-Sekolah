extends Control
## TKP (Tempat Kejadian Perkara) sudut pandang pertama — v1.4
##
## Ruangan berisi 24 benda kecil yang berantakan (6 per sektor); 3 di antaranya barang bukti yang tersamar.
## Tombol GRID membagi layar menjadi 4 sektor (A, B, C, D). Saat GRID menyala, klik sebuah sektor untuk
## MEMPERBESARNYA sehingga benda lebih jelas dan mudah diperiksa. Tanpa GRID pemain tetap bisa mencari.
##
## PENILAIAN DEKOMPOSISI, dinilai saat semua bukti ditemukan. Ada DUA jalur; salah satu cukup:
##
##   JALUR MANUAL (tanpa atau dengan GRID) — pemain menuntaskan ruangan bagian demi bagian:
##     1. RUNTUT : urutan sektor yang diperiksa tidak pernah kembali ke sektor yang sudah ditinggalkan,
##     2. TUNTAS : setiap sektor yang ditinggalkan sudah SELESAI, yaitu buktinya sudah ditemukan di sana
##                 ATAU minimal separuh bendanya sudah diperiksa (sektor tanpa bukti harus diperiksa separuh),
##     3. CUKUP  : minimal MIN_PERIKSA benda diperiksa. Kurang dari itu berarti menebak, bukan memecah.
##
##   JALUR GRID — pemain sendiri yang memecah ruangan dengan alat GRID:
##     1. minimal 2 sektor diperbesar, dan urutan sektor yang diperbesar tidak kembali ke sektor lama,
##     2. minimal PORSI_ZOOM dari semua klik dilakukan saat sektor diperbesar,
##     3. setiap sektor yang diperbesar benar-benar diperiksa (minimal 1 benda diklik saat diperbesar).
##   Sekadar menekan tombol GRID lalu mengeklik acak di tampilan penuh TIDAK dihitung.
##
## Jalur yang terpenuhi ("grid" / "manual" / "tidak") dicatat di rincian dan kolom jalur_tkp pada CSV.

const UI = preload("res://scripts/ui_kit.gd")
const FX = preload("res://scripts/fx.gd")
signal selesai(lengkap: bool)

const BG_SCALE := 2          # latar 160x90 digambar 2x di tampilan penuh
const TUNTAS_MIN := 0.5      # minimal separuh benda sektor diperiksa sebelum pindah (sektor tanpa bukti)
const MIN_PERIKSA := 6       # minimal benda diperiksa agar bisa dinilai "memecah" (seperempat ruangan)
const PORSI_ZOOM := 0.6      # jalur GRID: porsi klik yang dilakukan saat sektor diperbesar
const PENGECOH := {
	"kardus": "Hanya kardus kosong.",
	"koran": "Koran bekas minggu lalu.",
	"sandal": "Sandal jepit. Bukan ini.",
	"kaleng": "Kaleng bekas cat.",
	"jaring": "Jaring ikan yang sudah robek.",
	"sarung": "Sarung tangan karet milik penjual ikan.",
	"arsip": "Kotak arsip berisi kertas lama.",
	"bingkai": "Bingkai foto yang retak.",
	"kain": "Kain penutup patung.",
	"lampu": "Lampu meja yang sudah rusak.",
	"tangga": "Tangga lipat dari besi.",
	"karpet": "Gulungan karpet merah.",
	"botol": "Botol plastik kosong.",
	"kertas": "Kertas remuk berisi coretan.",
	"tali": "Gulungan tali rafia.",
	"lap": "Kain lap yang kotor.",
}
const SEKTOR_NAMA := ["A", "B", "C", "D"]
const SEKTOR_ASAL := [Vector2(0, 0), Vector2(160, 0), Vector2(0, 90), Vector2(160, 90)]

var tkp_id := ""
var meta := {}
var state := {}   # disimpan di Game.tkp_state agar tetap ada bila pemain keluar-masuk
var grid_on := false
var zoomed := -1
var stage: Control
var grid_btn: TextureButton
var overlay: Control
var hover_sector := -1
var counter: Label
var info_box: NinePatchRect   # papan tengah atas: jumlah bukti (+ nama sektor saat diperbesar)
var lbl_keluar: NinePatchRect
var lbl_grid: NinePatchRect
var msg: Label
var msg_box: NinePatchRect
var semua_btn: TextureButton
var _msg_t := 0.0
var _msg_atas := false    # pesan tampil di atas bila benda yang diperiksa ada di bagian bawah layar
var objects := {}       # uid -> TextureButton (yang masih ada)
var obj_type := {}      # uid -> jenis
var obj_sector := {}    # uid -> sektor
var total_sector := [0, 0, 0, 0]
var done := false


func setup(id: String) -> void:
	tkp_id = id


func _ready() -> void:
	size = Vector2(320, 180)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true
	meta = load("res://assets/tkp/tkp.json").data[tkp_id]
	if not Game.tkp_state.has(tkp_id):
		Game.tkp_state[tkp_id] = {"klik": [], "found": [], "zoom": [], "grid_dipakai": false}
	state = Game.tkp_state[tkp_id]
	# ---- panggung (bisa diperbesar per sektor)
	stage = Control.new()
	stage.size = size
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(stage)
	var bg := TextureRect.new()
	bg.texture = load("res://assets/tkp/%s.png" % tkp_id)
	bg.scale = Vector2(BG_SCALE, BG_SCALE)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(bg)
	var hit := Control.new()
	hit.size = size
	hit.mouse_filter = Control.MOUSE_FILTER_STOP
	hit.gui_input.connect(_on_bg_input)
	stage.add_child(hit)
	var idx := 0
	for o in meta["objects"]:
		var typ: String = o[0]
		var uid := "%s_%d" % [typ, idx]
		idx += 1
		var path := "res://assets/items/%s.png" % typ
		if not ResourceLoader.exists(path):
			path = "res://assets/items/x_%s.png" % typ
		var tex: Texture2D = load(path)
		var pos := Vector2(o[1], o[2])
		var sec := _sector_of(pos + tex.get_size() / 2.0)
		total_sector[sec] += 1
		obj_type[uid] = typ
		obj_sector[uid] = sec
		if typ in state["found"]:
			continue
		var b := TextureButton.new()
		b.texture_normal = tex
		b.position = pos
		b.focus_mode = Control.FOCUS_NONE
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.mouse_entered.connect(_obj_hover.bind(b, true))
		b.mouse_exited.connect(_obj_hover.bind(b, false))
		b.pressed.connect(_on_click.bind(uid))
		stage.add_child(b)
		objects[uid] = b
	overlay = Control.new()
	overlay.size = size
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.draw.connect(_draw_grid)
	add_child(overlay)
	# ---- HUD
	# Papan jumlah bukti ada di tengah atas (bukan di pojok) supaya tidak menutupi benda.
	# Saat sektor diperbesar, tulisan "Keluar"/"Grid" disembunyikan agar benda di pojok tetap terlihat.
	info_box = UI.nine(self, UI.UI + "banner.png", 4, Vector2(125, 4), Vector2(70, 14))
	counter = UI.label(info_box, "", Vector2(0, 2), UI.C_GOLD, 70, HORIZONTAL_ALIGNMENT_CENTER)
	UI.tex_button(self, UI.UI + "tombol_keluar_normal.png", UI.UI + "tombol_keluar_hover.png", Vector2(6, 4), _keluar)
	lbl_keluar = UI.nine(self, UI.UI + "banner.png", 4, Vector2(0, 35), Vector2(42, 13))
	UI.label(lbl_keluar, "Keluar", Vector2(1, 1), Color.WHITE, 41, HORIZONTAL_ALIGNMENT_CENTER)
	grid_btn = UI.tex_button(self, UI.UI + "tombol_grid_mati.png", UI.UI + "tombol_grid_hover.png", Vector2(284, 4), _toggle_grid)
	lbl_grid = UI.nine(self, UI.UI + "banner.png", 4, Vector2(280, 35), Vector2(38, 13))
	UI.label(lbl_grid, "Grid", Vector2(0, 1), Color.WHITE, 38, HORIZONTAL_ALIGNMENT_CENTER)
	semua_btn = UI.button(self, "semua", Vector2(40, 9), zoom_out)
	semua_btn.visible = false
	msg_box = UI.nine(self, UI.UI + "kotak_dialog.png", 6, Vector2(60, 150), Vector2(200, 24))
	msg = UI.label(msg_box, "", Vector2(6, 6), UI.C_CHOC, 188, HORIZONTAL_ALIGNMENT_CENTER)
	msg_box.visible = false
	_update_counter()
	_say(_target_text(), 4.0)
	Game.play_bgm("bgm_tkp")
	Game.sfx("sfx_tkp")


func _target_text() -> String:
	var names := []
	for f in meta["found"]:
		names.append(Game.ITEMS[f][0].to_lower())
	return "Cari: " + ", ".join(names)


func _update_counter() -> void:
	var t := "Bukti %d / %d" % [state["found"].size(), meta["found"].size()]
	if zoomed >= 0:
		t = "SEKTOR %s   %d / %d" % [SEKTOR_NAMA[zoomed], state["found"].size(), meta["found"].size()]
	var w: float = Game.font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 16.0
	info_box.size = Vector2(w, 14)
	# tampilan penuh: mulai x 138, satu-satunya ruas atas yang kosong di kedua TKP (tidak menutupi benda);
	# saat diperbesar: di tengah
	info_box.position = Vector2(roundf(160.0 - w / 2.0) if zoomed >= 0 else 138.0, 4)
	info_box.pivot_offset = Vector2(w / 2.0, 7)
	counter.size = Vector2(w, 11)
	counter.text = t
	counter.add_theme_color_override("font_color", Color("fee761") if zoomed >= 0 else UI.C_GOLD)


func _sector_of(p: Vector2) -> int:
	return (1 if p.x >= 160 else 0) + (2 if p.y >= 90 else 0)


func _obj_hover(b: TextureButton, on: bool) -> void:
	b.position.y += -1 if on else 1
	if on:
		Game.sfx("sfx_hover")


# ================================================================ periksa benda
func _on_click(uid: String) -> void:
	if done or not objects.has(uid):
		return
	var b: TextureButton = objects[uid]
	var typ: String = obj_type[uid]
	_msg_atas = b.get_global_rect().get_center().y > 112.0
	state["klik"].append([obj_sector[uid], "perbesar" if zoomed >= 0 else "penuh", uid])
	if typ in meta["found"]:
		Game.sfx("sfx_bukti")
		state["found"].append(typ)
		Game.add_item(typ)
		objects.erase(uid)
		var tw := create_tween()
		tw.tween_property(b, "position:y", b.position.y - 10, 0.35)
		tw.parallel().tween_property(b, "modulate:a", 0.0, 0.35)
		tw.tween_callback(b.queue_free)
		_say("Bukti ditemukan: %s!" % Game.ITEMS[typ][0])
		FX.sparkle(stage, b.position + b.texture_normal.get_size() / 2.0, 14)
		_update_counter()
		FX.pulse(info_box, 1.3, 0.3)
		if state["found"].size() >= meta["found"].size():
			done = true
			Game.sfx("sfx_konfeti")
			FX.confetti(self, Vector2(160, 120), 50)
			await get_tree().create_timer(1.4).timeout
			_nilai_dekomposisi()
			await Game.iris_close(Vector2(160, 90), 0.4)
			selesai.emit(true)
			queue_free()
	else:
		Game.sfx("sfx_pengecoh")
		b.modulate = Color(0.75, 0.75, 0.8)   # tanda sudah diperiksa
		FX.shake(b, 2.0, 0.25)
		_say(PENGECOH.get(typ, "Tidak ada yang menarik."))


func _nilai_dekomposisi() -> void:
	var h := nilai(state["klik"], state["zoom"], state["grid_dipakai"], total_sector, _sektor_bukti())
	state["hasil"] = h
	var tempat: String = {"kios_ikan": "Kios ikan", "gudang_museum": "Gudang museum"}.get(tkp_id, tkp_id)
	Game.catat("dekomposisi", h["berhasil"], "TKP %s: %s" % [tkp_id, h["detail"]], {"jalur": h["jalur"]}, tempat + ": " + h["teks"])


## Sektor mana saja yang berisi barang bukti.
func _sektor_bukti() -> Array:
	var ada := [false, false, false, false]
	for uid in obj_type:
		if obj_type[uid] in meta["found"]:
			ada[obj_sector[uid]] = true
	return ada


## Aturan penilaian (fungsi murni, mudah diuji).
##   klik  = [[sektor, "penuh"/"perbesar", uid], ...]   zoom = ["A", "B", ...] urutan sektor yang diperbesar
static func nilai(klik: Array, zoom: Array, grid_dipakai: bool, total: Array, ada_bukti: Array) -> Dictionary:
	# ---- urutan sektor (klik berurutan di sektor yang sama digabung)
	var urutan := []
	for k in klik:
		if urutan.is_empty() or urutan.back() != int(k[0]):
			urutan.append(int(k[0]))
	var runtut := true
	var seen := {}
	for s in urutan:
		if seen.has(s):
			runtut = false
		seen[s] = true
	# ---- benda unik yang diperiksa per sektor
	var diperiksa := [{}, {}, {}, {}]
	var semua := {}
	for k in klik:
		diperiksa[int(k[0])][k[2]] = true
		semua[k[2]] = true
	var tuntas := true
	for i in urutan.size() - 1:   # sektor terakhir tidak perlu (pemeriksaan berhenti saat bukti lengkap)
		var s: int = urutan[i]
		var separuh: bool = diperiksa[s].size() >= ceili(total[s] * TUNTAS_MIN)
		if not (ada_bukti[s] or separuh):
			tuntas = false
	var cukup := semua.size() >= MIN_PERIKSA
	var manual := runtut and tuntas and cukup
	# ---- jalur GRID
	var n_zoom := 0
	var zoom_diklik := {}
	for k in klik:
		if k[1] == "perbesar":
			n_zoom += 1
			zoom_diklik[SEKTOR_NAMA[int(k[0])]] = true
	var porsi := float(n_zoom) / maxi(klik.size(), 1)
	var zurut := []
	for z in zoom:
		if zurut.is_empty() or zurut.back() != z:
			zurut.append(z)
	var z_runtut := true
	var z_seen := {}
	var z_semua_diperiksa := true
	for z in zurut:
		if z_seen.has(z):
			z_runtut = false
		z_seen[z] = true
		if not zoom_diklik.has(z):
			z_semua_diperiksa = false
	var grid := grid_dipakai and z_seen.size() >= 2 and z_runtut and z_semua_diperiksa and porsi >= PORSI_ZOOM
	var jalur := "grid" if grid else ("manual" if manual else "tidak")
	# ---- rincian untuk CSV
	var jalur_txt := []
	for s in urutan:
		jalur_txt.append(SEKTOR_NAMA[s])
	var cakupan := []
	for s in 4:
		cakupan.append("%s %d/%d" % [SEKTOR_NAMA[s], diperiksa[s].size(), total[s]])
	var detail := "jalur %s, urutan sektor %s (%s), diperiksa %s (%s, %s), grid %s, diperbesar %s, %d%% klik saat diperbesar, %d klik" % [
		jalur, "-".join(jalur_txt), "runtut" if runtut else "bolak-balik", " ".join(cakupan),
		"tuntas" if tuntas else "belum tuntas", "cukup" if cukup else "terlalu sedikit",
		"dipakai" if grid_dipakai else "tidak dipakai", ",".join(zurut) if not zurut.is_empty() else "-",
		roundi(porsi * 100.0), klik.size()]
	# kalimat untuk siswa (halaman Bukti di Rapor)
	var sektor_txt := ", ".join(jalur_txt)
	var teks := ""
	if grid:
		teks = "kamu memperbesar sektor %s dengan GRID dan memeriksanya satu per satu." % ", ".join(zurut)
	elif manual:
		teks = "kamu memeriksa sektor %s satu per satu sampai selesai." % sektor_txt
	elif not runtut:
		teks = "kamu berpindah-pindah antarsektor (%s)." % sektor_txt
	elif not cukup:
		teks = "kamu menemukan bukti setelah memeriksa %d benda saja." % semua.size()
	else:
		teks = "kamu pindah sektor sebelum sektor itu selesai diperiksa (%s)." % sektor_txt
	return {"berhasil": grid or manual, "jalur": jalur, "teks": teks, "manual": manual, "grid": grid, "runtut": runtut,
		"tuntas": tuntas, "cukup": cukup, "porsi_zoom": porsi, "detail": detail}


# ================================================================ grid & perbesar sektor
func _toggle_grid() -> void:
	grid_on = not grid_on
	if grid_on:
		state["grid_dipakai"] = true
		_msg_atas = false
		_say("Klik salah satu sektor untuk memperbesarnya.", 2.5)
	elif zoomed >= 0:
		zoom_out()
	Game.sfx("sfx_grid_on" if grid_on else "sfx_grid_off")
	grid_btn.texture_normal = load(UI.UI + ("tombol_grid_nyala.png" if grid_on else "tombol_grid_mati.png"))
	overlay.queue_redraw()


func _on_bg_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT and zoomed >= 0:
			zoom_out()
		elif event.button_index == MOUSE_BUTTON_LEFT and grid_on and zoomed < 0:
			zoom_in(_sector_of(event.position))


func zoom_in(s: int) -> void:
	if done or zoomed >= 0:
		return
	zoomed = s
	state["zoom"].append(SEKTOR_NAMA[s])
	msg_box.visible = false
	_msg_t = 0.0
	Game.sfx("sfx_sektor")
	var tw := create_tween()
	tw.tween_property(stage, "scale", Vector2(2, 2), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(stage, "position", -SEKTOR_ASAL[s] * 2.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	lbl_keluar.visible = false
	lbl_grid.visible = false
	semua_btn.visible = true
	_update_counter()
	overlay.queue_redraw()


func zoom_out() -> void:
	if zoomed < 0:
		return
	zoomed = -1
	var tw := create_tween()
	tw.tween_property(stage, "scale", Vector2(1, 1), 0.2)
	tw.parallel().tween_property(stage, "position", Vector2.ZERO, 0.2)
	lbl_keluar.visible = true
	lbl_grid.visible = true
	semua_btn.visible = false
	_update_counter()
	overlay.queue_redraw()


func _draw_grid() -> void:
	if not grid_on or zoomed >= 0:
		return
	if hover_sector >= 0:
		overlay.draw_rect(Rect2(SEKTOR_ASAL[hover_sector], Vector2(160, 90)), Color(1, 1, 1, 0.12))
	var yel := Color("fee761")
	var blk := Color("181425")
	overlay.draw_rect(Rect2(158, 0, 4, 180), blk)
	overlay.draw_rect(Rect2(0, 88, 320, 4), blk)
	overlay.draw_rect(Rect2(159, 0, 2, 180), yel)
	overlay.draw_rect(Rect2(0, 89, 320, 2), yel)
	for i in 4:
		var p := Vector2(144 if i % 2 == 0 else 164, 74 if i < 2 else 94)
		overlay.draw_rect(Rect2(p - Vector2(1, 1), Vector2(14, 13)), blk)
		overlay.draw_rect(Rect2(p, Vector2(12, 11)), yel)
		overlay.draw_string(Game.font, p + Vector2(4, 8), SEKTOR_NAMA[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 9, blk)


func _process(delta: float) -> void:
	if grid_on and zoomed < 0:
		var s := _sector_of(get_local_mouse_position())
		if s != hover_sector:
			hover_sector = s
			overlay.queue_redraw()
	if _msg_t > 0.0:
		_msg_t -= delta
		if _msg_t <= 0.0:
			msg_box.visible = false


func _say(t: String, dur := 2.2) -> void:
	var rows := UI.wrap(t, 186, Game.font)
	msg.text = "\n".join(rows)
	msg_box.size = Vector2(200, 14 + rows.size() * 11)
	msg_box.position = Vector2(60, (34.0 if zoomed >= 0 else 22.0) if _msg_atas else 176 - msg_box.size.y)
	msg_box.visible = true
	_msg_t = dur


func _keluar() -> void:
	if done:
		return
	done = true
	await Game.iris_close(Vector2(21, 19), 0.4)
	selesai.emit(false)
	queue_free()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jeda"):
		get_viewport().set_input_as_handled()
		if zoomed >= 0:
			zoom_out()
		else:
			_keluar()


# ================================================================ untuk pengujian otomatis
func auto_click(uid: String) -> void:
	_on_click(uid)


func auto_grid(on: bool) -> void:
	if grid_on != on:
		_toggle_grid()


## id benda yang masih ada di sebuah sektor, urut seperti di tkp.json
func ids_in_sector(s: int) -> Array:
	var out := []
	for uid in objects:
		if obj_sector[uid] == s:
			out.append(uid)
	return out
