extends Control
## Kotak dialog bawah layar dengan efek mengetik. Pakai:  await dialog.say([["nisa", "Halo!"], ["", "Teks narator"]])
## Pembicara: id NPC, "pemain", atau "" untuk narator. Tambahkan ":senang" untuk ekspresi senang.

const UI = preload("res://scripts/ui_kit.gd")
signal advanced
signal finished

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


func _ready() -> void:
	size = Vector2(320, 180)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	npc_meta = load("res://assets/chars/npc.json").data
	holder = Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(holder)
	box = UI.nine(holder, UI.UI + "kotak_dialog.png", 6, Vector2(2, 124), Vector2(316, 54))
	frame = UI.rect(holder, UI.UI + "bingkai_potret.png", Vector2(6, 118))
	por = UI.rect(holder, UI.UI + "bingkai_potret.png", Vector2(10, 122))
	plate = UI.nine(holder, UI.UI + "papan_nama.png", 4, Vector2(66, 116), Vector2(60, 14))
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


func say(lines: Array) -> void:
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
	for l in lines:
		var who: String = l[0]
		var pages := _pages(who, l[1])
		for pg in pages:
			_show(who, pg)
			await advanced
	visible = false
	active = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	finished.emit()


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
	next_icon.visible = true


func _input(event: InputEvent) -> void:
	if not active:
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
