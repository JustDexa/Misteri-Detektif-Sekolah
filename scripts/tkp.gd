extends Control
## TKP (Tempat Kejadian Perkara) sudut pandang pertama — v1.2
##
## Ruangan berisi 24 benda kecil yang berantakan (6 per sektor); 3 di antaranya barang bukti yang tersamar.
## Tombol GRID membagi layar menjadi 4 sektor (A, B, C, D). Saat GRID menyala, klik sebuah sektor untuk
## MEMPERBESARNYA sehingga benda lebih jelas dan mudah diperiksa. Tanpa GRID pemain tetap bisa mencari.
##
## PENILAIAN DEKOMPOSISI (berdasarkan perilaku, bukan pemakaian tombol), dinilai saat semua bukti ditemukan:
##   BERHASIL bila pemain memecah ruangan menjadi bagian-bagian dan menuntaskannya satu per satu:
##     1. RUNTUT : urutan sektor yang diperiksa tidak pernah kembali ke sektor yang sudah ditinggalkan, dan
##     2. TUNTAS : setiap sektor yang ditinggalkan sudah diperiksa minimal separuh bendanya.
##   Cara ini sama-sama dihitung, baik memakai GRID (memperbesar sektor) maupun tanpa GRID.
##   Pemakaian GRID tetap dicatat di rincian CSV.

const UI = preload("res://scripts/ui_kit.gd")
const FX = preload("res://scripts/fx.gd")
signal selesai(lengkap: bool)

const BG_SCALE := 2          # latar 160x90 digambar 2x di tampilan penuh
const TUNTAS_MIN := 0.5      # minimal separuh benda sektor diperiksa sebelum pindah
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
var msg: Label
var msg_box: NinePatchRect
var zoom_box: NinePatchRect
var zoom_lbl: Label
var semua_btn: TextureButton
var _msg_t := 0.0
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
	var top := UI.nine(self, UI.UI + "banner.png", 4, Vector2(280, 50), Vector2(38, 13))
	top.pivot_offset = Vector2(19, 6)
	counter = UI.label(top, "", Vector2(0, 1), UI.C_GOLD, 38, HORIZONTAL_ALIGNMENT_CENTER)
	UI.tex_button(self, UI.UI + "tombol_keluar_normal.png", UI.UI + "tombol_keluar_hover.png", Vector2(6, 4), _keluar)
	var kb := UI.nine(self, UI.UI + "banner.png", 4, Vector2(2, 35), Vector2(38, 13))
	UI.label(kb, "Keluar", Vector2(0, 1), Color.WHITE, 38, HORIZONTAL_ALIGNMENT_CENTER)
	grid_btn = UI.tex_button(self, UI.UI + "tombol_grid_mati.png", UI.UI + "tombol_grid_hover.png", Vector2(284, 4), _toggle_grid)
	var gb := UI.nine(self, UI.UI + "banner.png", 4, Vector2(280, 35), Vector2(38, 13))
	UI.label(gb, "Grid", Vector2(0, 1), Color.WHITE, 38, HORIZONTAL_ALIGNMENT_CENTER)
	zoom_box = UI.nine(self, UI.UI + "banner.png", 4, Vector2(124, 4), Vector2(72, 14))
	zoom_lbl = UI.label(zoom_box, "", Vector2(0, 2), Color("fee761"), 72, HORIZONTAL_ALIGNMENT_CENTER)
	zoom_box.visible = false
	semua_btn = UI.button(self, "semua", Vector2(132, 20), zoom_out)
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
	counter.text = "%d / %d" % [state["found"].size(), meta["found"].size()]


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
		FX.pulse(counter.get_parent(), 1.3, 0.3)
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
	var klik: Array = state["klik"]
	# urutan sektor (klik berurutan di sektor yang sama digabung)
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
	# benda unik yang diperiksa per sektor
	var diperiksa := [{}, {}, {}, {}]
	for k in klik:
		diperiksa[int(k[0])][k[2]] = true
	var tuntas := true
	for i in urutan.size() - 1:   # sektor terakhir tidak perlu (pemeriksaan berhenti saat bukti lengkap)
		var s: int = urutan[i]
		if diperiksa[s].size() < ceili(total_sector[s] * TUNTAS_MIN):
			tuntas = false
	var jalur := []
	for s in urutan:
		jalur.append(SEKTOR_NAMA[s])
	var cakupan := []
	for s in 4:
		cakupan.append("%s %d/%d" % [SEKTOR_NAMA[s], diperiksa[s].size(), total_sector[s]])
	var zoom_txt := ",".join(state["zoom"]) if not state["zoom"].is_empty() else "-"
	var detail := "TKP %s: urutan sektor %s (%s), diperiksa %s (%s), grid %s, sektor diperbesar %s, %d klik" % [
		tkp_id, "-".join(jalur), "runtut" if runtut else "bolak-balik", " ".join(cakupan),
		"tuntas" if tuntas else "belum tuntas", "dipakai" if state["grid_dipakai"] else "tidak dipakai", zoom_txt, klik.size()]
	Game.catat("dekomposisi", runtut and tuntas, detail)


# ================================================================ grid & perbesar sektor
func _toggle_grid() -> void:
	grid_on = not grid_on
	if grid_on:
		state["grid_dipakai"] = true
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
	zoom_lbl.text = "SEKTOR " + SEKTOR_NAMA[s]
	zoom_box.visible = true
	semua_btn.visible = true
	overlay.queue_redraw()


func zoom_out() -> void:
	if zoomed < 0:
		return
	zoomed = -1
	var tw := create_tween()
	tw.tween_property(stage, "scale", Vector2(1, 1), 0.2)
	tw.parallel().tween_property(stage, "position", Vector2.ZERO, 0.2)
	zoom_box.visible = false
	semua_btn.visible = false
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
	msg_box.position = Vector2(60, 176 - msg_box.size.y)
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
