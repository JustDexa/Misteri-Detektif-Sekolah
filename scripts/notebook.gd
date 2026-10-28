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


func _render_kasus() -> void:
	var lx := 16.0
	UI.label(page, "KASUS UTAMA", Vector2(lx, 16), UI.C_RUST)
	UI.label(page, "Alat kebersihan hilang!", Vector2(lx, 27), UI.C_CHOC, 120)
	UI.label(page, "Detektif: " + Game.player_name, Vector2(lx, 38), UI.C_CHOC, 120)
	var info: Array = Game.LEVEL_INFO[Game.level_index]
	UI.label(page, "Lokasi: " + info[0], Vector2(lx, 49), UI.C_CHOC, 120)
	UI.label(page, "Tujuan sekarang:", Vector2(lx, 66), UI.C_RUST)
	var y := 77.0
	for row in UI.wrap(objective, 118, Game.font):
		UI.label(page, row, Vector2(lx, y), UI.C_CHOC)
		y += 11
	UI.label(page, "Tanyai orang dan periksa benda.", Vector2(lx, 132), Color("8b9bb4"), 118)
	var rx := 152.0
	UI.label(page, "KASUS KECIL", Vector2(rx, 16), UI.C_RUST)
	for i in Game.LEVEL_INFO.size():
		var st := "Belum dimulai"
		var col := Color("8b9bb4")
		if i in Game.level_done:
			st = "Selesai"
			col = Color("3e8948")
		elif i == Game.level_index:
			st = "Sedang diselidiki"
			col = UI.C_RUST
		var yy := 30.0 + i * 25
		UI.label(page, "%d. %s" % [i + 1, Game.LEVEL_INFO[i][1]], Vector2(rx, yy), UI.C_CHOC)
		UI.label(page, "   " + st, Vector2(rx, yy + 11), col)
	UI.label(page, "Bukti terkumpul: %d / %d" % [Game.inventory.size(), Game.ITEM_URUTAN.size()], Vector2(rx, 134), UI.C_CHOC)


func _render_bukti() -> void:
	UI.label(page, "BARANG BUKTI", Vector2(16, 14), UI.C_RUST)
	var i := 0
	for id in Game.ITEM_URUTAN:
		var has := Game.has_item(id)
		var b := TextureButton.new()
		b.texture_normal = load(UI.UI + ("slot_isi.png" if has else "slot_kosong.png"))
		b.position = Vector2(18 + (i % 4) * 29, 28 + (i / 4) * 29)
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
	UI.label(page, "Arahkan kursor ke bukti untuk membaca.", Vector2(16, 132), Color("8b9bb4"), 118)
	detail = Control.new()
	page.add_child(detail)
	if Game.inventory.size() > 0:
		_show_detail(Game.inventory[Game.inventory.size() - 1])
	else:
		UI.label(detail, "Belum ada bukti. Terus selidiki!", Vector2(152, 60), UI.C_CHOC, 118, HORIZONTAL_ALIGNMENT_CENTER)


func _show_detail(id: String) -> void:
	for c in detail.get_children():
		c.queue_free()
	var ic := TextureRect.new()
	ic.texture = load("res://assets/items/%s.png" % id)
	ic.position = Vector2(195, 18)
	ic.scale = Vector2(2, 2)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	detail.add_child(ic)
	var info: Array = Game.ITEMS[id]
	UI.label(detail, info[0], Vector2(150, 56), UI.C_RUST, 122, HORIZONTAL_ALIGNMENT_CENTER)
	var y := 70.0
	for row in UI.wrap(info[1], 118, Game.font):
		UI.label(detail, row, Vector2(152, y), UI.C_CHOC)
		y += 11


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
