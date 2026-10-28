extends Control
## Rapor Detektif: distribusi persentase 4 pilar CT (diagram lingkaran + batang) dan profil gaya berpikir.
## Persentase bersifat RELATIF: menunjukkan pilar yang paling menonjol pada pemain, bukan nilai benar/salah.

const UI = preload("res://scripts/ui_kit.gd")
const FX = preload("res://scripts/fx.gd")
var args := {}
var pr := {}
var pb := {}
var prog := 0.0
var chart: Control
var pct_labels := {}
var bars := {}

const PIE_C := Vector2(80, 92)
const PIE_R := 40.0


func _ready() -> void:
	size = Vector2(320, 180)
	UI.rect(self, "res://assets/rapor/rapor_bg.png", Vector2.ZERO)
	pr = Game.persentase()
	pb = Game.persentase_bulat()
	var dom := Game.dominan()
	UI.label(self, "RAPOR DETEKTIF", Vector2(9, 12), Color.WHITE, 302, HORIZONTAL_ALIGNMENT_CENTER, UI.C_RED_D)
	UI.label(self, "Detektif: " + Game.player_name, Vector2(14, 34), UI.C_CHOC, 132, HORIZONTAL_ALIGNMENT_CENTER)
	chart = Control.new()
	chart.size = size
	chart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chart.draw.connect(_draw_chart)
	add_child(chart)
	# ---- kolom kanan: profil
	var lenc := dom if dom != "seimbang" else "pola"
	var badge := UI.rect(self, "res://assets/rapor/lencana_%s.png" % lenc, Vector2(158, 33))
	if dom == "seimbang":
		badge.modulate = Color(1, 1, 1, 1)
	UI.label(self, "Gaya berpikirmu:", Vector2(202, 36), Color("8b9bb4"), 106)
	UI.label(self, Game.PROFIL[dom][0], Vector2(202, 47), UI.C_RUST, 106)
	var y := 79.0
	for row in UI.wrap(Game.PROFIL[dom][1], 148, Game.font).slice(0, 4):
		UI.label(self, row, Vector2(158, y), UI.C_CHOC)
		y += 10
	var ry := maxf(116.0, y + 3)
	for p in Game.PILAR:
		var sq := ColorRect.new()
		sq.color = Game.PILAR_WARNA[p]
		sq.size = Vector2(7, 7)
		sq.position = Vector2(158, ry + 1)
		add_child(sq)
		UI.label(self, Game.PILAR_NAMA[p], Vector2(168, ry - 1), UI.C_CHOC)
		var back := ColorRect.new()
		back.color = Color("e4a672")
		back.size = Vector2(26, 5)
		back.position = Vector2(252, ry + 2)
		add_child(back)
		var bar := ColorRect.new()
		bar.color = Game.PILAR_WARNA[p]
		bar.size = Vector2(0, 5)
		bar.position = Vector2(252, ry + 2)
		add_child(bar)
		bars[p] = bar
		pct_labels[p] = UI.label(self, "0%", Vector2(280, ry - 1), UI.C_CHOC, 26, HORIZONTAL_ALIGNMENT_RIGHT)
		ry += 10
	UI.label(self, "*Bukan nilai benar/salah.", Vector2(158, minf(ry + 1, 162)), Color("8b9bb4"), 150)
	# ---- tombol
	UI.button(self, "main_lagi", Vector2(14, 148), _main_lagi)
	UI.button(self, "menu", Vector2(90, 148), _menu)
	if not args.get("lihat", false):
		var path := Game.simpan_hasil()
		UI.label(self, "Hasil tersimpan" if path != "" else "", Vector2(14, 137), Color("3e8948"), 132, HORIZONTAL_ALIGNMENT_CENTER)
	Game.play_bgm("bgm_ending")
	# ---- animasi masuk berurutan
	var k := 0
	for c in get_children():
		if c == chart or c.get_index() == 0:
			continue
		if c == badge:
			continue
		FX.pop_in(c, 0.1 + k * 0.035, 0.25, 6.0)
		k += 1
	badge.pivot_offset = Vector2(20, 22)
	badge.scale = Vector2.ZERO
	var tb := create_tween()
	tb.tween_interval(0.9)
	tb.tween_property(badge, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tb.tween_callback(FX.sparkle.bind(self, Vector2(178, 55), 18))
	tb.tween_callback(Game.sfx.bind("sfx_pop"))
	if not args.get("lihat", false):
		FX.confetti_rain(self, 320.0, 50, 3.5)
	var tw := create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(Game.sfx.bind("sfx_rapor"))
	tw.tween_method(_set_prog, 0.0, 1.0, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _set_prog(v: float) -> void:
	prog = v
	for p in Game.PILAR:
		bars[p].size.x = roundf(26.0 * pr[p] / 100.0 * v)
		pct_labels[p].text = "%d%%" % roundi(pb[p] * v)
	chart.queue_redraw()


func _draw_chart() -> void:
	chart.draw_circle(PIE_C + Vector2(0, 2), PIE_R + 1, Color("733e39"))
	chart.draw_circle(PIE_C, PIE_R + 1, Color("181425"))
	chart.draw_circle(PIE_C, PIE_R, Color("c0cbdc"))
	var a0 := -PI / 2.0
	for p in Game.PILAR:
		var span: float = pr[p] / 100.0 * TAU * prog
		if span <= 0.001:
			continue
		var pts := PackedVector2Array([PIE_C])
		var steps := maxi(2, int(span / 0.06))
		for i in steps + 1:
			var a := a0 + span * i / steps
			pts.append(PIE_C + Vector2(cos(a), sin(a)) * PIE_R)
		chart.draw_colored_polygon(pts, Game.PILAR_WARNA[p])
		chart.draw_line(PIE_C, PIE_C + Vector2(cos(a0), sin(a0)) * PIE_R, Color("181425"), 1.0)
		a0 += span
	chart.draw_circle(PIE_C, 13, Color("181425"))
	chart.draw_circle(PIE_C, 12, Color("ead4aa"))
	chart.draw_string(Game.font, PIE_C + Vector2(-12, 3), "CT", HORIZONTAL_ALIGNMENT_CENTER, 24, 9, Color("3e2731"))


func _main_lagi() -> void:
	Game.goto_level_select()


func _menu() -> void:
	Game.goto_menu()
