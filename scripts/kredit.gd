extends Control
## Layar kredit. Ubah teks di CREDIT_LINES (misalnya nama dosen) sesuai kebutuhan.

const UI = preload("res://scripts/ui_kit.gd")
const CREDIT_LINES := [
	["h", "MISTERI DETEKTIF SEKOLAH"],
	["t", "GAME EDUKASI COMPUTATIONAL THINKING"],
	["s", ""],
	["h2", "DIBUAT OLEH"],
	["t", "AFRIDYA DEXA WAHNUGRAH   K3524020"],
	["t", "ESTU SETYOADI GALIH RAMDANI   K3524050"],
	["s", ""],
	["h2", "DOSEN PENGAMPU"],
	["t", "Febri Liantoni, S.ST., M.Kom"],
	["s", ""],
	["t", "PTIK - FKIP - UNIVERSITAS SEBELAS MARET"],
	["t", "2026 - DIBUAT DENGAN GODOT ENGINE"],
]
var args := {}


func _ready() -> void:
	size = Vector2(320, 180)
	UI.rect(self, UI.MENU + "mnu_g_kredit_bg.png", Vector2.ZERO)
	var y := 46
	for l in CREDIT_LINES:
		if l[0] == "s":
			y += 10
			continue
		var c: Color = {"h": UI.C_RED_D, "h2": UI.C_RUST, "t": UI.C_CHOC}[l[0]]
		var lb := UI.label(self, l[1], Vector2(46, y - 1), c, 240, HORIZONTAL_ALIGNMENT_CENTER)
		preload("res://scripts/fx.gd").pop_in(lb, 0.2 + (y - 46) * 0.012, 0.3, 5.0)
		y += 10
	var kb := UI.button(self, "kembali", Vector2(12, 11), _kembali)
	preload("res://scripts/fx.gd").slide_in(kb, Vector2(-80, 0), 0.1)


func _kembali() -> void:
	Game.goto_menu()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jeda"):
		_kembali()
