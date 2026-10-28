extends Control
## Layar pembuka. Taruh logo kampus di res://assets/menu/logo_kampus.png agar muncul di lingkaran tengah.

const UI = preload("res://scripts/ui_kit.gd")
var args := {}
var _t := 0.0
var _done := false


func _ready() -> void:
	size = Vector2(320, 180)
	UI.rect(self, UI.MENU + "mnu_g_splash.png", Vector2.ZERO)
	var logo_path := "res://assets/menu/logo_kampus.png"
	if ResourceLoader.exists(logo_path):
		var r := TextureRect.new()
		r.texture = load(logo_path)
		r.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		r.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		r.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
		r.position = Vector2(132, 30)
		r.size = Vector2(56, 56)
		add_child(r)
	Game.stop_bgm()
	var fx = preload("res://scripts/fx.gd")
	get_tree().create_timer(0.5).timeout.connect(fx.sparkle.bind(self, Vector2(160, 58), 20, Color("fee761")))
	get_tree().create_timer(1.4).timeout.connect(fx.sparkle.bind(self, Vector2(160, 58), 14, Color("2ce8f5")))


func _process(delta: float) -> void:
	_t += delta
	if _t > 2.8:
		_lanjut()


func _input(event: InputEvent) -> void:
	if _t > 0.4 and (event is InputEventMouseButton and event.pressed or event.is_action_pressed("interaksi")):
		_lanjut()


func _lanjut() -> void:
	if _done:
		return
	_done = true
	Game.goto_menu()
