extends Control
## Panel Opsi: volume musik, volume efek suara, layar penuh. Dipakai di menu utama dan menu jeda.

const UI = preload("res://scripts/ui_kit.gd")
signal ditutup


class PixelSlider extends Control:
	signal changed(v: float)
	var value := 0.5
	var _drag := false
	var _track: Texture2D
	var _fill: Texture2D
	var _knob: Texture2D
	var _knob_h: Texture2D
	var _hover := false

	func _init(v: float) -> void:
		value = v
		_track = load("res://assets/menu/ui_g_slider_track.png")
		_fill = load("res://assets/menu/ui_g_slider_isi.png")
		_knob = load("res://assets/menu/ui_g_slider_knob_normal.png")
		_knob_h = load("res://assets/menu/ui_g_slider_knob_hover.png")
		size = Vector2(96, 14)
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		mouse_entered.connect(_set_hover.bind(true))
		mouse_exited.connect(_set_hover.bind(false))

	func _set_hover(h: bool) -> void:
		_hover = h
		queue_redraw()

	func _draw() -> void:
		draw_texture(_track, Vector2(0, 3))
		var w := int(96 * value)
		if w > 0:
			draw_texture_rect_region(_fill, Rect2(0, 3, w, 8), Rect2(0, 0, w, 8))
		draw_texture(_knob_h if (_hover or _drag) else _knob, Vector2(clampf(w - 5, -2, 88), 0))

	func _gui_input(event: InputEvent) -> void:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			_drag = event.pressed
			if event.pressed:
				_set_from(event.position.x)
		elif event is InputEventMouseMotion and _drag:
			_set_from(event.position.x)

	func _set_from(x: float) -> void:
		value = clampf(x / 96.0, 0.0, 1.0)
		changed.emit(value)
		queue_redraw()


func _ready() -> void:
	size = Vector2(320, 180)
	UI.dim(self)
	var p := Control.new()
	p.position = Vector2(60, 30)
	add_child(p)
	UI.rect(p, UI.MENU + "ui_g_panel_opsi.png", Vector2.ZERO)
	preload("res://scripts/fx.gd").drop_in(p)
	Game.sfx("sfx_pop")
	var s1 := PixelSlider.new(Game.vol_music)
	s1.position = Vector2(90, 30)
	p.add_child(s1)
	s1.changed.connect(_on_music)
	var s2 := PixelSlider.new(Game.vol_sfx)
	s2.position = Vector2(90, 54)
	p.add_child(s2)
	s2.changed.connect(_on_sfx)
	var tg := TextureButton.new()
	tg.toggle_mode = true
	tg.texture_normal = load(UI.MENU + "ui_g_toggle_mati.png")
	tg.texture_pressed = load(UI.MENU + "ui_g_toggle_nyala.png")
	tg.position = Vector2(158, 79)
	tg.focus_mode = Control.FOCUS_NONE
	tg.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	tg.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	tg.toggled.connect(_on_fullscreen)
	p.add_child(tg)
	var x := TextureButton.new()
	x.texture_normal = load(UI.MENU + "ui_g_btn_tutup_normal.png")
	x.texture_hover = load(UI.MENU + "ui_g_btn_tutup_hover.png")
	x.texture_pressed = load(UI.MENU + "ui_g_btn_tutup_pressed.png")
	x.position = Vector2(180, 6)
	x.focus_mode = Control.FOCUS_NONE
	x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	x.pressed.connect(_tutup)
	p.add_child(x)
	UI.label(p, "Tekan ESC untuk menutup", Vector2(0, 100), UI.C_TAN, 200, HORIZONTAL_ALIGNMENT_CENTER)


func _on_music(v: float) -> void:
	Game.vol_music = v
	Game.set_volumes()


func _on_sfx(v: float) -> void:
	Game.vol_sfx = v
	Game.set_volumes()
	Game.sfx("sfx_klik")


func _on_fullscreen(on: bool) -> void:
	Game.sfx("sfx_klik")
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on else DisplayServer.WINDOW_MODE_WINDOWED)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jeda"):
		get_viewport().set_input_as_handled()
		_tutup()


func _tutup() -> void:
	Game.sfx("sfx_klik")
	Game.save_settings()
	ditutup.emit()
	queue_free()
