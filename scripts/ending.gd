extends Control
## Ending: sobekan poster disusun, Klub Peduli Lingkungan muncul, lalu menuju Rapor Detektif.

const UI = preload("res://scripts/ui_kit.gd")
const FX = preload("res://scripts/fx.gd")
signal ditekan
var args := {}
var dialog
var ending_img: TextureRect
var hint: Label
var _wait := false
var stage := ""
var _t := 0.0


func _ready() -> void:
	size = Vector2(320, 180)
	var bg := ColorRect.new()
	bg.color = Color("262b44")
	bg.size = size
	add_child(bg)
	for i in 60:
		var star := ColorRect.new()
		star.color = Color("3a4466")
		star.size = Vector2(1, 1)
		star.position = Vector2(randi() % 320, randi() % 180)
		add_child(star)
	ending_img = UI.rect(self, "res://assets/ending/ending.png", Vector2.ZERO)
	ending_img.modulate.a = 0.0
	hint = UI.label(self, "Tekan E untuk lanjut", Vector2(170, 166), Color("c0cbdc"), 140, HORIZONTAL_ALIGNMENT_CENTER)
	hint.visible = false
	dialog = load("res://scripts/dialog.gd").new()
	add_child(dialog)
	Game.play_bgm("bgm_ending")
	_run()


func _run() -> void:
	await get_tree().create_timer(0.6).timeout
	await dialog.say([
		["", "Semua alat kebersihan sudah ditemukan. Tapi siapa yang mengambilnya, dan untuk apa?"],
		["", "Kamu mengeluarkan keempat sobekan poster dari Buku Catatan, lalu mencoba menyusunnya..."],
	])
	# ---- susun poster
	var starts := [Vector2(-70, -90), Vector2(330, -90), Vector2(-70, 190), Vector2(330, 190)]
	var pieces := []
	for i in 4:
		var p := UI.rect(self, "res://assets/ending/poster_%d.png" % (i + 1), starts[i])
		pieces.append(p)
	move_child(dialog, get_child_count() - 1)
	for i in 4:
		var tw := create_tween()
		tw.tween_property(pieces[i], "position", Vector2(20 + (i % 2) * 64, 10 + (i / 2) * 80), 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		Game.sfx("sfx_bukti")
		await tw.finished
		await get_tree().create_timer(0.15).timeout
	Game.sfx("sfx_poster")
	var flash := ColorRect.new()
	flash.color = Color(1, 1, 1, 0.9)
	flash.size = size
	add_child(flash)
	var tf := create_tween()
	tf.tween_property(flash, "color:a", 0.0, 0.5)
	var t1 := UI.label(self, "Poster tersusun utuh!", Vector2(160, 30), Color("fee761"), 150, HORIZONTAL_ALIGNMENT_CENTER, UI.C_BLACK)
	var t2 := UI.label(self, "AKSI BERSIH KOTA", Vector2(160, 56), Color.WHITE, 150, HORIZONTAL_ALIGNMENT_CENTER, UI.C_BLACK)
	var t3 := UI.label(self, "Minggu pagi di Taman Kota\nbersama Klub Lingkungan", Vector2(160, 72), Color("c0cbdc"), 150, HORIZONTAL_ALIGNMENT_CENTER)
	var t4 := UI.label(self, "Jadi... yang meminjam semua alat itu adalah Klub Lingkungan?", Vector2(164, 104), Color("2ce8f5"), 142, HORIZONTAL_ALIGNMENT_CENTER)
	stage = "poster"
	await _tunggu_tekan()
	# ---- pengungkapan
	var tw2 := create_tween()
	tw2.tween_property(ending_img, "modulate:a", 1.0, 0.8)
	for n in [t1, t2, t3, t4]:
		tw2.parallel().tween_property(n, "modulate:a", 0.0, 0.4)
	for p in pieces:
		tw2.parallel().tween_property(p, "modulate:a", 0.0, 0.6)
	await tw2.finished
	dialog.set_top(true)
	FX.confetti_rain(self, 320.0, 45, 0.0)
	stage = "klub"
	await dialog.say([
		["nisa", "Maaf ya, Detektif! Kami yang meminjam alat-alat itu."],
		["bima", "Kami anggota Klub Peduli Lingkungan. Kami sedang menyiapkan Aksi Bersih Kota hari Minggu."],
		["tari", "Kami ingin membuat kejutan... tapi kami lupa minta izin dulu. Itu salah kami."],
		["arga", "Semua alat sudah kami kembalikan ke pemiliknya, dan kami sudah minta maaf."],
		["arga:senang", "Kamu jeli sekali bisa menemukan semuanya. Mau ikut Aksi Bersih Kota bersama kami?"],
		["pemain:senang", "Tentu saja! Kasus ditutup!"],
	])
	var dimr := ColorRect.new()
	dimr.color = Color(0.094, 0.078, 0.145, 0.0)
	dimr.size = size
	add_child(dimr)
	create_tween().tween_property(dimr, "color:a", 0.55, 0.3)
	var st := UI.rect(self, "res://assets/rapor/stempel.png", Vector2(118, 75))
	st.pivot_offset = Vector2(42, 15)
	st.scale = Vector2(3, 3)
	st.modulate.a = 0.0
	var ts := create_tween()
	ts.tween_property(st, "scale", Vector2(2, 2), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	ts.parallel().tween_property(st, "modulate:a", 1.0, 0.2)
	ts.tween_callback(Game.sfx.bind("sfx_stempel"))
	ts.tween_callback(FX.confetti.bind(self, Vector2(160, 100), 90))
	ts.tween_callback(Game.sfx.bind("sfx_konfeti"))
	ts.tween_interval(1.8)
	await ts.finished
	Game.change("res://scripts/rapor.gd")


func _tunggu_tekan() -> void:
	if Game.autotest:
		await get_tree().create_timer(0.2).timeout
		while Game.hold_dialog:
			await get_tree().process_frame
		return
	_wait = true
	hint.visible = true
	await ditekan
	hint.visible = false


func _process(delta: float) -> void:
	_t += delta
	if hint.visible:
		hint.modulate.a = 0.5 + 0.5 * sin(_t * 4.0)


func _input(event: InputEvent) -> void:
	if _wait and (event.is_action_pressed("interaksi") or (event is InputEventMouseButton and event.pressed)):
		_wait = false
		get_viewport().set_input_as_handled()
		ditekan.emit()
