extends Control
## Menu utama: latar parallax, logo, pose detektif, tombol MAIN / OPSI / KREDIT / KELUAR.
## Saat pertama kali dibuka (belum ada nama tersimpan), pemain langsung diminta mengisi nama.

const UI = preload("res://scripts/ui_kit.gd")
const FX = preload("res://scripts/fx.gd")
var args := {}
var logo_bob := false
var birds := []
var _bird_t := 2.0
var _spark_t := 1.5
var sky1: TextureRect
var sky2: TextureRect
var logo: TextureRect
var pose: TextureRect
var _scroll := 0.0
var _t := 0.0
var _frame := 0
var popup: Control
var name_edit: LineEdit
var name_plate: NinePatchRect
var name_lbl: Label


func _ready() -> void:
	size = Vector2(320, 180)
	Game.load_profil()
	sky1 = UI.rect(self, UI.MENU + "mnu_g_bg_langit.png", Vector2.ZERO)
	sky2 = UI.rect(self, UI.MENU + "mnu_g_bg_langit.png", Vector2(320, 0))
	UI.rect(self, UI.MENU + "mnu_g_bg_gedung.png", Vector2.ZERO)
	UI.rect(self, UI.MENU + "mnu_g_bg_gerbang.png", Vector2.ZERO)
	logo = UI.rect(self, UI.MENU + "mnu_g_logo.png", Vector2(91, 6))
	pose = TextureRect.new()
	pose.texture = UI.atlas(UI.MENU + "mnu_g_pemain_pose_sheet.png", 0, 48, 64)
	pose.position = Vector2(14, 114)
	pose.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(pose)
	var b_main := UI.button(self, "main", Vector2(124, 110), _on_main)
	var b_opsi := UI.button(self, "opsi", Vector2(70, 142), _on_opsi)
	var b_kredit := UI.button(self, "kredit", Vector2(132, 142), _on_kredit)
	var b_keluar := UI.button(self, "keluar", Vector2(194, 142), _on_keluar)
	UI.label(self, "v1.3", Vector2(262, 169), Color(1, 1, 1, 0.6), 54, HORIZONTAL_ALIGNMENT_RIGHT)
	# papan nama pemain + tombol ganti
	name_plate = UI.nine(self, UI.UI + "banner.png", 4, Vector2(0, 165), Vector2(80, 15))
	name_lbl = UI.label(name_plate, "", Vector2(6, 3), Color.WHITE)
	UI.button(self, "ganti", Vector2(0, 165), _on_ganti)
	_update_nama()
	# ---- animasi masuk
	FX.slide_in(logo, Vector2(0, -95), 0.05, 0.8, Tween.TRANS_BOUNCE)
	FX.slide_in(pose, Vector2(-70, 0), 0.35, 0.5)
	FX.slide_in(b_main, Vector2(0, 90), 0.5, 0.5)
	FX.slide_in(b_opsi, Vector2(0, 70), 0.62, 0.45)
	FX.slide_in(b_kredit, Vector2(0, 70), 0.7, 0.45)
	FX.slide_in(b_keluar, Vector2(0, 70), 0.78, 0.45)
	FX.pop_in(name_plate, 0.95)
	for c in get_children():
		if c is TextureButton and c.texture_normal.resource_path.ends_with("ganti_normal.png"):
			FX.pop_in(c, 1.0)
	get_tree().create_timer(0.9).timeout.connect(func(): logo_bob = true)
	var leaves := FX.ambient(self, "daun")
	leaves.amount = 5
	leaves.position = Vector2(160, 70)
	Game.play_bgm("bgm_menu")
	if Game.player_name == "" or "--popup" in OS.get_cmdline_user_args():
		_buka_popup_nama(true)
	if "--opsi" in OS.get_cmdline_user_args():
		_on_opsi()


func _update_nama() -> void:
	var t := "Detektif: " + (Game.player_name if Game.player_name != "" else "-")
	name_lbl.text = t
	var w := Game.font.get_string_size(t, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 12
	name_plate.size = Vector2(w, 15)
	var x0 := roundf((320 - (w + 42)) / 2.0)
	name_plate.position = Vector2(x0, 165)
	for c in get_children():
		if c is TextureButton and c.texture_normal.resource_path.ends_with("ganti_normal.png"):
			c.position = Vector2(x0 + w + 2, 165)
			c.set_meta("base_y", 165.0)


func _process(delta: float) -> void:
	_t += delta
	_scroll = fmod(_scroll + delta * 4.0, 320.0)
	sky1.position.x = -roundf(_scroll)
	sky2.position.x = 320 - roundf(_scroll)
	if logo_bob:
		logo.position.y = 6 + roundf(sin(_t * 2.0) * 1.5)
	# kilau sesekali di logo
	_spark_t -= delta
	if _spark_t <= 0.0:
		_spark_t = randf_range(1.2, 2.4)
		FX.sparkle(self, logo.position + Vector2(randf_range(8, 130), randf_range(6, 60)), 6)
	# burung terbang melintas
	_bird_t -= delta
	if _bird_t <= 0.0:
		_bird_t = randf_range(6.0, 11.0)
		_spawn_birds()
	for b in birds:
		if is_instance_valid(b):
			b.frame = int((_t + b.get_meta("ph")) * 6.0) % 2
	birds = birds.filter(func(b): return is_instance_valid(b))
	var f := int(_t / 0.45) % 2
	if f != _frame:
		_frame = f
		pose.texture = UI.atlas(UI.MENU + "mnu_g_pemain_pose_sheet.png", f, 48, 64)


func _spawn_birds() -> void:
	var y0 := randf_range(14, 50)
	var n := randi_range(1, 3)
	for i in n:
		var b := Sprite2D.new()
		b.texture = load("res://assets/fx/burung.png")
		b.hframes = 2
		b.position = Vector2(-12 - i * 10, y0 + i * 5)
		b.set_meta("ph", randf())
		add_child(b)
		move_child(b, 2)   # di belakang gedung & logo
		var tw := b.create_tween()
		tw.tween_property(b, "position", Vector2(340 - i * 10, y0 + i * 5 - randf_range(4, 14)), randf_range(9, 12))
		tw.tween_callback(b.queue_free)
		birds.append(b)


func _on_main() -> void:
	if popup:
		return
	if Game.player_name == "":
		_buka_popup_nama(true)
		return
	Game.goto_level_select()


func _on_ganti() -> void:
	if popup:
		return
	_buka_popup_nama(false)


## wajib = true saat pertama kali (tidak bisa ditutup sebelum nama diisi).
func _buka_popup_nama(wajib: bool) -> void:
	popup = Control.new()
	popup.size = Vector2(320, 180)
	add_child(popup)
	UI.dim(popup)
	var p := Control.new()
	p.position = Vector2(60, 30)
	popup.add_child(p)
	UI.rect(p, UI.MENU + "ui_g_panel_kosong.png", Vector2.ZERO)
	FX.drop_in(p)
	Game.sfx("sfx_pop")
	UI.label(p, "NAMA DETEKTIF" if wajib else "GANTI PEMAIN", Vector2(0, 10), Color.WHITE, 200, HORIZONTAL_ALIGNMENT_CENTER, UI.C_RED_D)
	var info := "Halo! Tulis namamu dulu, ya." if wajib else "Pemain baru mulai dari Level 1."
	UI.label(p, info, Vector2(14, 28), UI.C_CHOC, 172, HORIZONTAL_ALIGNMENT_CENTER)
	name_edit = LineEdit.new()
	name_edit.position = Vector2(30, 46)
	name_edit.size = Vector2(140, 18)
	name_edit.max_length = 18
	name_edit.placeholder_text = "Nama kamu"
	name_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("ffffff")
	sb.border_color = Color("3e2731")
	sb.set_border_width_all(1)
	sb.content_margin_left = 4
	sb.content_margin_right = 4
	sb.content_margin_top = 3
	sb.content_margin_bottom = 2
	name_edit.add_theme_stylebox_override("normal", sb)
	name_edit.add_theme_stylebox_override("focus", sb)
	name_edit.add_theme_color_override("font_color", UI.C_CHOC)
	name_edit.add_theme_color_override("font_placeholder_color", UI.C_GREY)
	name_edit.add_theme_color_override("caret_color", UI.C_RUST)
	name_edit.text_submitted.connect(_on_submit)
	p.add_child(name_edit)
	name_edit.grab_focus()
	UI.button(p, "simpan", Vector2(64, 74), _simpan_nama)
	popup.set_meta("wajib", wajib)
	if not wajib:
		var x := TextureButton.new()
		x.texture_normal = load(UI.MENU + "ui_g_btn_tutup_normal.png")
		x.texture_hover = load(UI.MENU + "ui_g_btn_tutup_hover.png")
		x.texture_pressed = load(UI.MENU + "ui_g_btn_tutup_pressed.png")
		x.position = Vector2(180, 6)
		x.focus_mode = Control.FOCUS_NONE
		x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		x.pressed.connect(_tutup_popup)
		p.add_child(x)


func _on_submit(_t2: String) -> void:
	_simpan_nama()


func _simpan_nama() -> void:
	if name_edit == null:
		return
	var n := name_edit.text.strip_edges()
	if n == "":
		Game.sfx("sfx_terkunci")
		name_edit.placeholder_text = "Nama belum diisi!"
		return
	Game.ganti_pemain(n)
	Game.sfx("sfx_level_selesai")
	_update_nama()
	_tutup_popup()


func _tutup_popup() -> void:
	if popup:
		popup.queue_free()
		popup = null
		name_edit = null


func _on_opsi() -> void:
	var o = load("res://scripts/options_panel.gd").new()
	add_child(o)


func _on_kredit() -> void:
	Game.change("res://scripts/kredit.gd")


func _on_keluar() -> void:
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if popup and event.is_action_pressed("jeda") and not popup.get_meta("wajib", false):
		get_viewport().set_input_as_handled()
		Game.sfx("sfx_klik")
		_tutup_popup()
