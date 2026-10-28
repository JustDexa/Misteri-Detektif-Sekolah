extends Control
## Pilih Level: level berikutnya terkunci sampai level sebelumnya selesai.
## Level yang sudah selesai boleh diulang; hasil level itu diganti hasil terbaru.

const UI = preload("res://scripts/ui_kit.gd")
const FX = preload("res://scripts/fx.gd")
const MAPS := ["sekolah", "taman", "pasar", "museum"]
const POS := [Vector2(20, 38), Vector2(164, 38), Vector2(20, 104), Vector2(164, 104)]
var args := {}
var toast: Label
var cards := []
var _toast_t := 0.0


func _ready() -> void:
	size = Vector2(320, 180)
	Game.load_profil()
	UI.rect(self, UI.MENU + "mnu_g_bg_gabungan.png", Vector2.ZERO)
	UI.dim(self, 0.7).mouse_filter = Control.MOUSE_FILTER_IGNORE
	var title := UI.nine(self, UI.UI + "banner.png", 4, Vector2(110, 8), Vector2(100, 17))
	UI.label(title, "PILIH LEVEL", Vector2(0, 4), Color("fee761"), 100, HORIZONTAL_ALIGNMENT_CENTER)
	FX.drop_in(title)
	var kb := UI.button(self, "kembali", Vector2(8, 7), _kembali)
	FX.slide_in(kb, Vector2(-80, 0), 0.1)
	var rb := UI.button(self, "rapor", Vector2(256, 7), _rapor)
	FX.slide_in(rb, Vector2(80, 0), 0.1)
	rb.disabled = not Game.semua_selesai()
	if rb.disabled:
		rb.modulate = Color(1, 1, 1, 0.35)
	for i in 4:
		_card(i)
		FX.slide_in(cards[i], Vector2(0, 150), 0.15 + i * 0.09, 0.5)
	UI.label(self, "Detektif: " + Game.player_name, Vector2(0, 168), Color("c0cbdc"), 320, HORIZONTAL_ALIGNMENT_CENTER)
	toast = UI.label(self, "", Vector2(40, 28), Color("fee761"), 240, HORIZONTAL_ALIGNMENT_CENTER, UI.C_BLACK)
	Game.play_bgm("bgm_menu")


func _card(i: int) -> void:
	var buka := Game.level_terbuka(i)
	var selesai := i in Game.level_done
	var b := TextureButton.new()
	b.position = POS[i]
	b.focus_mode = Control.FOCUS_NONE
	if buka:
		b.texture_normal = load(UI.UI + "kartu_pilih_normal.png")
		b.texture_hover = load(UI.UI + "kartu_pilih_hover.png")
		b.texture_pressed = load(UI.UI + "kartu_pilih_hover.png")
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.mouse_entered.connect(func(): Game.sfx("sfx_hover"))
	else:
		b.texture_normal = load(UI.UI + "kartu_pilih_kunci.png")
	b.pressed.connect(_pilih.bind(i))
	add_child(b)
	cards.append(b)
	var thumb := UI.rect(b, "res://assets/maps/%s_mini.png" % MAPS[i], Vector2(7, 12))
	if not buka:
		thumb.modulate = Color(0.35, 0.35, 0.45)
		UI.rect(b, UI.UI + "ikon_gembok.png", Vector2(31, 23))
	UI.label(b, "LEVEL %d" % (i + 1), Vector2(71, 9), Color("feae34") if buka else Color("8b9bb4"))
	UI.label(b, Game.LEVEL_INFO[i][0], Vector2(71, 20), Color.WHITE if buka else Color("8b9bb4"))
	var st := "Siap main"
	var col := Color("c0cbdc")
	if selesai:
		st = "Selesai"
		col = Color("63c74d")
		UI.rect(b, UI.UI + "ikon_centang.png", Vector2(118, 6))
	elif not buka:
		st = "Terkunci"
		col = Color("8b9bb4")
	UI.label(b, st, Vector2(71, 34), col)
	if selesai:
		UI.label(b, "Bisa diulang", Vector2(71, 44), Color("8b9bb4"))


func _pilih(i: int) -> void:
	if not Game.level_terbuka(i):
		Game.sfx("sfx_terkunci")
		FX.shake(cards[i], 4.0, 0.35)
		toast.text = "Selesaikan Level %d dulu!" % i
		_toast_t = 2.0
		return
	Game.sfx("sfx_klik")
	FX.sparkle(self, cards[i].position + Vector2(70, 30), 16)
	Game.mulai_level(i)


func _process(delta: float) -> void:
	if _toast_t > 0.0:
		_toast_t -= delta
		toast.modulate.a = clampf(_toast_t / 0.5, 0.0, 1.0)


func _kembali() -> void:
	Game.goto_menu()


func _rapor() -> void:
	if Game.semua_selesai():
		Game.change("res://scripts/rapor.gd", {"lihat": true})


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jeda"):
		_kembali()
