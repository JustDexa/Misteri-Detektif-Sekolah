extends Control
## Kotak dialog bawah layar dengan efek mengetik. Pakai:  await dialog.say([["nisa", "Halo!"], ["", "Teks narator"]])
## Pembicara: id NPC, "pemain", atau "" untuk narator. Tambahkan ":senang" untuk ekspresi senang.
## Pertanyaan dengan pilihan:  var i: int = await dialog.tanya("kiki", "Kenapa?", ["Jawaban A", "Jawaban B"])

const UI = preload("res://scripts/ui_kit.gd")
signal advanced
signal finished
signal dipilih(indeks: int)

const TEXT_W := 242.0
const TEXT_W_NARATOR := 292.0
const MAX_LINES := 3
const SPEED := 45.0

var npc_meta := {}
var holder: Control
var box: NinePatchRect
var frame: TextureRect
var por: TextureRect
var plate: NinePatchRect
var name_lbl: Label
var text_lbl: Label
var next_icon: TextureRect
var active := false
var typing := false
var _vis := 0.0
var _total := 0
var _t := 0.0
var _blip := 0
var _last_who := "-"
var _open_tw: Tween
var _top := false
# ---- pilihan jawaban
# Kotak pilihan memakai bingkai 4 px di atas dan bawah, jadi tinggi minimum = 4 + 9 (teks) + 4 = 17.
const OPSI_T := 17.0      # tinggi satu pilihan
const OPSI_JARAK := 1.0
var _opsi := []           # [{"kotak": NinePatchRect, "label": Label}]
var _pilih := 0
var _memilih := false
var _bertanya := false    # sedang menampilkan pertanyaan (ikon "lanjut" disembunyikan)
var _kursor: Label
var _redup: ColorRect
var _opsi_ms := 0         # kapan pilihan muncul (mencegah tekanan tombol sebelumnya ikut memilih)


func _ready() -> void:
	size = Vector2(320, 180)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	npc_meta = load("res://assets/chars/npc.json").data
	_redup = ColorRect.new()
	_redup.color = Color(0.094, 0.078, 0.145, 0.0)
	_redup.size = size
	_redup.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_redup)
	holder = Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder)
	box = UI.nine(holder, UI.UI + "kotak_dialog.png", 6, Vector2(2, 124), Vector2(316, 54))
	frame = UI.rect(holder, UI.UI + "bingkai_potret.png", Vector2(6, 118))
	por = TextureRect.new()
	por.position = Vector2(10, 122)
	por.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(por)
	plate = UI.nine(holder, UI.UI + "papan_nama.png", 4, Vector2(66, 116), Vector2(60, 14), 5)
	name_lbl = UI.label(plate, "", Vector2(5, 2), Color.WHITE)
	text_lbl = UI.label(holder, "", Vector2(68, 133), UI.C_CHOC)
	next_icon = TextureRect.new()
	next_icon.texture = UI.atlas(UI.UI + "lanjut.png", 0, 8, 8)
	next_icon.position = Vector2(305, 165)
	next_icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.add_child(next_icon)
	visible = false


## Pindahkan kotak dialog ke atas layar (dipakai di ending agar karakter tetap terlihat).
func set_top(on: bool) -> void:
	if _open_tw and _open_tw.is_valid():
		_open_tw.kill()
	_top = on
	holder.position.y = -116 if on else 0


func _buka() -> void:
	active = true
	visible = true
	mouse_filter = Control.MOUSE_FILTER_STOP
	_last_who = "-"
	# animasi muncul: meluncur dari tepi layar sambil memudar masuk
	var base_y := -116.0 if _top else 0.0
	holder.modulate.a = 0.0
	holder.position.y = base_y + (14.0 if base_y == 0.0 else -14.0)
	if _open_tw and _open_tw.is_valid():
		_open_tw.kill()
	_open_tw = create_tween()
	_open_tw.tween_property(holder, "position:y", base_y, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_open_tw.parallel().tween_property(holder, "modulate:a", 1.0, 0.14)


func _tutup() -> void:
	visible = false
	active = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	finished.emit()


func say(lines: Array) -> void:
	_buka()
	for l in lines:
		var who: String = l[0]
		var pages := _pages(who, l[1])
		for pg in pages:
			_show(who, pg)
			await advanced
	_tutup()


## Tampilkan pertanyaan lalu daftar pilihan. Mengembalikan indeks pilihan.
## Pilih dengan W/S atau panah lalu E, dengan angka 1-4, atau klik langsung.
## auto = indeks yang dipilih saat uji otomatis.
func tanya(who: String, text: String, opsi: Array, auto := 0) -> int:
	_bertanya = true
	_buka()
	var pages := _pages(who, text)
	for i in pages.size() - 1:
		_show(who, pages[i])
		await advanced
	_show(who, pages[pages.size() - 1])
	while typing:
		await get_tree().process_frame
	next_icon.visible = false
	create_tween().tween_property(_redup, "color:a", 0.35, 0.15)
	_buat_opsi(opsi)
	_memilih = true
	var hasil := clampi(auto, 0, opsi.size() - 1)
	if Game.autotest:
		_set_pilih(hasil)
		await get_tree().process_frame
		while Game.hold_dialog or Game.hold_tanya:
			await get_tree().process_frame
	else:
		hasil = await dipilih
	_memilih = false
	for o in _opsi:
		o["kotak"].queue_free()
	_opsi = []
	if _kursor:
		_kursor.queue_free()
		_kursor = null
	_redup.color.a = 0.0
	_bertanya = false
	_tutup()
	return hasil


func _buat_opsi(opsi: Array) -> void:
	var w := 120.0
	for t in opsi:
		w = maxf(w, Game.font.get_string_size(str(t), HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 24.0)
	w = minf(w, 312.0)
	var n := opsi.size()
	var tinggi := n * (OPSI_T + OPSI_JARAK)
	# di atas kotak dialog; bila kotak dialog sedang di atas layar, daftar pilihan diletakkan di bawahnya
	var y0 := (182.0 if _top else 114.0 - tinggi)
	var x0 := 318.0 - w
	for i in n:
		var k := UI.nine(holder, UI.UI + "kotak_krem.png", 4, Vector2(x0, y0 + i * (OPSI_T + OPSI_JARAK)), Vector2(w, OPSI_T), 5)
		var lb := UI.label(k, str(opsi[i]), Vector2(15, 4), UI.C_CHOC)
		_opsi.append({"kotak": k, "label": lb})
		k.modulate.a = 0.0
		var tw := k.create_tween()
		tw.tween_interval(i * 0.05)
		tw.tween_property(k, "modulate:a", 1.0, 0.12)
	_kursor = UI.label(holder, ">", Vector2.ZERO, Color("fee761"))
	_opsi_ms = Time.get_ticks_msec()
	_set_pilih(0)
	Game.sfx("sfx_pop")


## Pilihan yang disorot: kotak gelap berbingkai emas + tanda ">" (pilihan lain tetap krem).
func _set_pilih(i: int) -> void:
	if _opsi.is_empty():
		return
	_pilih = wrapi(i, 0, _opsi.size())
	for j in _opsi.size():
		var aktif := j == _pilih
		_opsi[j]["kotak"].texture = load(UI.UI + ("kotak_gelap.png" if aktif else "kotak_krem.png"))
		_opsi[j]["label"].add_theme_color_override("font_color", Color("fee761") if aktif else UI.C_CHOC)
	var k: Control = _opsi[_pilih]["kotak"]
	_kursor.position = k.position + Vector2(7, 4)


func _opsi_di(p: Vector2) -> int:
	for j in _opsi.size():
		if _opsi[j]["kotak"].get_global_rect().has_point(p):
			return j
	return -1


func _input_pilihan(event: InputEvent) -> void:
	if event.is_action_pressed("gerak_atas"):
		get_viewport().set_input_as_handled()
		_set_pilih(_pilih - 1)
		Game.sfx("sfx_hover")
	elif event.is_action_pressed("gerak_bawah"):
		get_viewport().set_input_as_handled()
		_set_pilih(_pilih + 1)
		Game.sfx("sfx_hover")
	elif event.is_action_pressed("interaksi"):
		get_viewport().set_input_as_handled()
		_konfirmasi(_pilih)
	elif event is InputEventKey and event.pressed and not event.echo:
		var angka: int = event.physical_keycode - KEY_1
		if angka >= 0 and angka < _opsi.size():
			get_viewport().set_input_as_handled()
			_konfirmasi(angka)
	elif event is InputEventMouseMotion:
		# sorot pilihan di bawah kursor
		var h := _opsi_di(event.position)
		if h >= 0 and h != _pilih:
			_set_pilih(h)
			Game.sfx("sfx_hover")
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		var j := _opsi_di(event.position)
		if j >= 0:
			_konfirmasi(j)


func _konfirmasi(i: int) -> void:
	if not _memilih or Time.get_ticks_msec() - _opsi_ms < 300:
		return
	_memilih = false
	_set_pilih(i)
	Game.sfx("sfx_klik")
	dipilih.emit(i)


func _pages(who: String, text: String) -> Array:
	var w := TEXT_W_NARATOR if who == "" else TEXT_W
	var rows := UI.wrap(text.replace("{nama}", Game.player_name), w, Game.font)
	var out := []
	var i := 0
	while i < rows.size():
		out.append("\n".join(rows.slice(i, i + MAX_LINES)))
		i += MAX_LINES
	return out


func _show(who: String, text: String) -> void:
	var expr := ""
	if ":" in who:
		var parts := who.split(":")
		who = parts[0]
		expr = parts[1]
	var narator := who == ""
	frame.visible = not narator
	por.visible = not narator
	plate.visible = not narator
	if narator:
		text_lbl.position = Vector2(14, 133)
		text_lbl.add_theme_color_override("font_color", Color("3a4466"))
	else:
		text_lbl.position = Vector2(68, 133)
		text_lbl.add_theme_color_override("font_color", UI.C_CHOC)
		var nm := ""
		var pfile := ""
		if who == "pemain":
			nm = Game.player_name
			pfile = "por_pemain"
		else:
			nm = npc_meta.get(who, {}).get("name", who)
			pfile = "por_" + who
		if expr != "":
			pfile += "_" + expr
		var path := "res://assets/chars/%s.png" % pfile
		if not ResourceLoader.exists(path):
			path = "res://assets/chars/por_%s.png" % ("pemain" if who == "pemain" else who)
		por.texture = load(path)
		por.size = Vector2(48, 48)
		name_lbl.text = nm
		plate.size = Vector2(Game.font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 11, 14)
	# potret & papan nama melompat kecil saat pembicara berganti
	if who != _last_who and not narator:
		por.position.y = 117
		plate.position.y = 112
		var tp := create_tween()
		tp.tween_property(por, "position:y", 122.0, 0.22).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		tp.parallel().tween_property(plate, "position:y", 116.0, 0.22).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_last_who = who
	text_lbl.text = text
	text_lbl.size = Vector2(300, 36)
	_total = text.length()
	_vis = 0.0
	text_lbl.visible_characters = 0
	typing = true
	next_icon.visible = false


func _process(delta: float) -> void:
	if not active:
		return
	_t += delta
	if Game.autotest and not Game.hold_dialog:
		_finish_typing()
		advanced.emit()
		return
	if _memilih:
		if _kursor and not _opsi.is_empty():
			_kursor.position.x = _opsi[_pilih]["kotak"].position.x + 7 + (int(_t * 3.0) % 2)
		return
	if typing:
		var before := int(_vis)
		_vis += delta * SPEED
		var now := int(_vis)
		if now != before:
			_blip += 1
			if _blip % 3 == 0 and now <= _total and now > 0 and text_lbl.text[now - 1] != " ":
				Game.sfx("sfx_ketik", randf_range(0.95, 1.08))
		text_lbl.visible_characters = now
		if now >= _total:
			_finish_typing()
	else:
		next_icon.texture = UI.atlas(UI.UI + "lanjut.png", int(_t * 3.0) % 2, 8, 8)


func _finish_typing() -> void:
	typing = false
	text_lbl.visible_characters = -1
	next_icon.visible = not _bertanya


func _input(event: InputEvent) -> void:
	if not active:
		return
	if _memilih:
		_input_pilihan(event)
		return
	if not _opsi.is_empty():
		return
	var press: bool = event.is_action_pressed("interaksi") or (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT)
	if not press:
		return
	get_viewport().set_input_as_handled()
	if typing:
		_finish_typing()
	else:
		Game.sfx("sfx_lanjut")
		advanced.emit()


## Untuk pengujian otomatis: lewati semua baris yang sedang tampil.
func skip_all() -> void:
	if active:
		_finish_typing()
		advanced.emit()
