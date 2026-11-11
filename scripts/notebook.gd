extends Control
## Buku Catatan Detektif: tab KASUS (tujuan & kemajuan) dan tab BUKTI (barang bukti terkumpul).
## Catatan desain: buku TIDAK menyimpan isi dialog, agar penyaringan informasi tetap dilakukan pemain (Abstraksi).

const UI = preload("res://scripts/ui_kit.gd")
signal ditutup

var objective := ""
var tab := "kasus"
var page: Control
var tab_k: TextureRect
var tab_b: TextureRect
var detail: Control
var _opened_ms := 0


func _ready() -> void:
	size = Vector2(320, 180)
	_opened_ms = Time.get_ticks_msec()
	UI.dim(self, 0.6)
	var root := Control.new()
	root.position = Vector2(16, 12)
	add_child(root)
	tab_k = _tab(root, "KASUS", Vector2(20, -10), "kasus")
	tab_b = _tab(root, "BUKTI", Vector2(66, -10), "bukti")
	UI.rect(root, UI.UI + "buku_panel.png", Vector2.ZERO)
	preload("res://scripts/fx.gd").slide_in(root, Vector2(0, 170), 0.0, 0.35)
	page = Control.new()
	root.add_child(page)
	var x := TextureButton.new()
	x.texture_normal = load(UI.MENU + "ui_g_btn_tutup_normal.png")
	x.texture_hover = load(UI.MENU + "ui_g_btn_tutup_hover.png")
	x.texture_pressed = load(UI.MENU + "ui_g_btn_tutup_pressed.png")
	x.position = Vector2(272, 2)
	x.focus_mode = Control.FOCUS_NONE
	x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	x.pressed.connect(_tutup)
	root.add_child(x)
	Game.sfx("sfx_buku")
	_render()


func _tab(parent: Control, text: String, pos: Vector2, id: String) -> TextureRect:
	var t := TextureRect.new()
	t.position = pos
	t.mouse_filter = Control.MOUSE_FILTER_STOP
	t.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	t.gui_input.connect(_on_tab_input.bind(id))
	parent.add_child(t)
	UI.label(t, text, Vector2(0, 2), Color.WHITE, 44, HORIZONTAL_ALIGNMENT_CENTER, UI.C_RED_D)
	return t


func _on_tab_input(event: InputEvent, id: String) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_set_tab(id)


func _set_tab(id: String) -> void:
	if id == tab:
		return
	tab = id
	Game.sfx("sfx_buku")
	_render()
	page.modulate.a = 0.0
	create_tween().tween_property(page, "modulate:a", 1.0, 0.18)


func _render() -> void:
	for c in page.get_children():
		c.queue_free()
	tab_k.texture = load(UI.UI + ("tab_aktif.png" if tab == "kasus" else "tab_pasif.png"))
	tab_b.texture = load(UI.UI + ("tab_aktif.png" if tab == "bukti" else "tab_pasif.png"))
	if tab == "kasus":
		_render_kasus()
	else:
		_render_bukti()


## Teks ditaruh tepat di atas garis buku. Garis pada buku_panel.png ada di y = 26, 37, 48, ... (jarak 11),
## jadi baris ke-n ditulis pada y = BARIS_Y0 + n * 11.
const BARIS_Y0 := 17.0
const BARIS_T := 11.0
const KIRI_X := 14.0
const KANAN_X := 150.0
const HAL_W := 120.0


func _baris(n: int) -> float:
	return BARIS_Y0 + n * BARIS_T


func _render_kasus() -> void:
	UI.label(page, "KASUS UTAMA", Vector2(KIRI_X, _baris(0)), UI.C_RUST)
	UI.label(page, "Alat kebersihan hilang!", Vector2(KIRI_X, _baris(1)), UI.C_CHOC)
	var det := "Detektif: " + Game.player_name
	if Game.font.get_string_size(det, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x > HAL_W:
		det = Game.player_name   # nama panjang: tanpa awalan supaya tidak keluar halaman
	UI.label(page, det, Vector2(KIRI_X, _baris(2)), UI.C_CHOC)
	var info: Array = Game.LEVEL_INFO[Game.level_index]
	UI.label(page, "Lokasi: " + info[0], Vector2(KIRI_X, _baris(3)), UI.C_CHOC)
	UI.label(page, "Tujuan sekarang:", Vector2(KIRI_X, _baris(5)), UI.C_RUST)
	var n := 6
	for row in UI.wrap(objective if objective != "" else "-", HAL_W, Game.font).slice(0, 3):
		UI.label(page, row, Vector2(KIRI_X, _baris(n)), UI.C_CHOC)
		n += 1
	n = 10
	for row in UI.wrap("Tanyai orang dan periksa benda.", HAL_W, Game.font):
		UI.label(page, row, Vector2(KIRI_X, _baris(n)), Color("8b9bb4"))
		n += 1
	UI.label(page, "KASUS KECIL", Vector2(KANAN_X, _baris(0)), UI.C_RUST)
	for i in Game.LEVEL_INFO.size():
		var st := "Belum dimulai"
		var col := Color("8b9bb4")
		if i in Game.level_done:
			st = "Selesai"
			col = Color("3e8948")
		elif i == Game.level_index:
			st = "Sedang diselidiki"
			col = UI.C_RUST
		UI.label(page, "%d. %s" % [i + 1, Game.LEVEL_INFO[i][1]], Vector2(KANAN_X, _baris(1 + i * 2)), UI.C_CHOC)
		UI.label(page, st, Vector2(KANAN_X + 12, _baris(2 + i * 2)), col)
	UI.label(page, "Bukti terkumpul: %d / %d" % [Game.inventory.size(), Game.ITEM_URUTAN.size()], Vector2(KANAN_X, _baris(10)), UI.C_CHOC)


func _render_bukti() -> void:
	UI.label(page, "BARANG BUKTI", Vector2(KIRI_X, _baris(0)), UI.C_RUST)
	var i := 0
	for id in Game.ITEM_URUTAN:
		var has := Game.has_item(id)
		var b := TextureButton.new()
		b.texture_normal = load(UI.UI + ("slot_isi.png" if has else "slot_kosong.png"))
		b.position = Vector2(17 + (i % 4) * 29, 31 + (i / 4) * 29)
		b.focus_mode = Control.FOCUS_NONE
		if has:
			b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
			var ic := TextureRect.new()
			ic.texture = load("res://assets/items/%s.png" % id)
			ic.position = Vector2(4, 4)
			ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
			b.add_child(ic)
			b.mouse_entered.connect(_show_detail.bind(id))
			b.pressed.connect(_show_detail.bind(id))
		page.add_child(b)
		i += 1
	var n := 10
	for row in UI.wrap("Arahkan kursor ke bukti untuk membaca.", HAL_W, Game.font):
		UI.label(page, row, Vector2(KIRI_X, _baris(n)), Color("8b9bb4"))
		n += 1
	detail = Control.new()
	page.add_child(detail)
	if Game.inventory.size() > 0:
		_show_detail(Game.inventory[Game.inventory.size() - 1])
	else:
		n = 4
		for row in UI.wrap("Belum ada bukti. Terus selidiki!", HAL_W, Game.font):
			UI.label(detail, row, Vector2(KANAN_X, _baris(n)), UI.C_CHOC, HAL_W, HORIZONTAL_ALIGNMENT_CENTER)
			n += 1


func _show_detail(id: String) -> void:
	for c in detail.get_children():
		c.queue_free()
	var ic := TextureRect.new()
	ic.texture = load("res://assets/items/%s.png" % id)
	ic.position = Vector2(KANAN_X + HAL_W / 2.0 - 16, 19)
	ic.scale = Vector2(2, 2)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail.add_child(ic)
	var info: Array = Game.ITEMS[id]
	UI.label(detail, info[0], Vector2(KANAN_X, _baris(4)), UI.C_RUST, HAL_W, HORIZONTAL_ALIGNMENT_CENTER)
	var n := 5
	for row in UI.wrap(info[1], HAL_W, Game.font).slice(0, 7):
		UI.label(detail, row, Vector2(KANAN_X, _baris(n)), UI.C_CHOC)
		n += 1


func _input(event: InputEvent) -> void:
	if Time.get_ticks_msec() - _opened_ms < 150:
		return
	if event.is_action_pressed("buku") or event.is_action_pressed("jeda"):
		get_viewport().set_input_as_handled()
		_tutup()
	elif event.is_action_pressed("gerak_kiri"):
		_set_tab("kasus")
	elif event.is_action_pressed("gerak_kanan"):
		_set_tab("bukti")


func _tutup() -> void:
	Game.sfx("sfx_buku")
	ditutup.emit()
	queue_free()
