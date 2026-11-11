extends Control
## Rapor Detektif: distribusi persentase 4 pilar CT (diagram lingkaran + batang) dan profil gaya berpikir.
## Persentase bersifat RELATIF: menunjukkan pilar yang paling menonjol pada pemain, bukan nilai benar/salah.
##
## Tata letak (320x180). Latar rapor_bg.png: bingkai x 8..311, judul y 7..28, garis tengah x 150.
##   Kolom kiri  (x 12..146): nama, diagram lingkaran, keterangan, tombol.
##   Kolom kanan (x 156..306): lencana + gaya, deskripsi (maks. 4 baris), 4 batang persentase.
## Tombol LIHAT BUKTI (atau TAB) membuka halaman Bukti: per pilar, apa yang dilakukan pemain dan poin yang didapat.

const UI = preload("res://scripts/ui_kit.gd")
const FX = preload("res://scripts/fx.gd")
var args := {}
var pr := {}
var pb := {}
var prog := 0.0
var chart: Control
var pct_labels := {}
var bars := {}
var halaman_bukti: Control
var pilar_bukti := "dekomposisi"
var tab_ikon := {}
const DILIHAT := {
	"dekomposisi": "Dilihat dari: caramu memeriksa ruangan yang berantakan.",
	"pola": "Dilihat dari: siapa yang pertama kamu tanyai.",
	"abstraksi": "Dilihat dari: tempat pertama yang kamu datangi.",
	"algoritma": "Dilihat dari: urutan tempat yang kamu datangi.",
}

const KIRI_X := 12.0
const KIRI_W := 134.0
const KANAN_X := 156.0
const KANAN_W := 150.0
const PIE_C := Vector2(79, 80)
const PIE_R := 34.0
const BAR_W := 28.0


func _ready() -> void:
	size = Vector2(320, 180)
	UI.rect(self, "res://assets/rapor/rapor_bg.png", Vector2.ZERO)
	pr = Game.persentase()
	pb = Game.persentase_bulat()
	var gaya := Game.dominan()
	if gaya == "belum":
		# belum ada pilar yang muncul: lingkaran dibiarkan kosong (bukan dibagi rata 25%)
		for p in Game.PILAR:
			pr[p] = 0.0
			pb[p] = 0
	var profil: Array = Game.profil_teks(gaya)
	UI.label(self, "RAPOR DETEKTIF", Vector2(9, 13), Color.WHITE, 302, HORIZONTAL_ALIGNMENT_CENTER, UI.C_RED_D)
	# ---- kolom kiri
	var det := "Detektif: " + Game.player_name
	if Game.font.get_string_size(det, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x > KIRI_W:
		det = Game.player_name   # nama panjang: tanpa awalan supaya tidak menabrak garis tengah
	UI.label(self, det, Vector2(KIRI_X, 33), UI.C_CHOC, KIRI_W, HORIZONTAL_ALIGNMENT_CENTER)
	chart = Control.new()
	chart.size = size
	chart.mouse_filter = Control.MOUSE_FILTER_IGNORE
	chart.draw.connect(_draw_chart)
	add_child(chart)
	if not args.get("lihat", false) and Game.simpan_hasil() != "":
		UI.label(self, "Tersimpan", Vector2(250, 13), Color("ead4aa"), 56, HORIZONTAL_ALIGNMENT_RIGHT)
	_tombol_teks(self, "LIHAT BUKTI", Vector2(KIRI_X + 17, 118), 100, _buka_bukti)
	UI.label(self, "*Bukan nilai benar/salah.", Vector2(KIRI_X, 135), Color("8b9bb4"), KIRI_W, HORIZONTAL_ALIGNMENT_CENTER)
	UI.button(self, "main_lagi", Vector2(13, 147), _main_lagi)
	UI.button(self, "menu", Vector2(89, 147), _menu)
	# ---- kolom kanan: lencana + gaya
	var lencana := _lencana(gaya)
	UI.label(self, "Gaya berpikirmu:", Vector2(202, 33), Color("8b9bb4"), 104)
	var judul: String = profil[0]
	var baris := [judul]
	if " & " in judul:   # dua pilar sama kuat: satu nama per baris
		var bagian := judul.split(" & ")
		baris = [bagian[0], "& " + bagian[1]]
	var jy := 44.0 if baris.size() > 1 else 49.0
	for b in baris:
		UI.label(self, b, Vector2(202, jy), UI.C_RUST)
		jy += 11
	# ---- deskripsi (maks. 4 baris)
	var y := 79.0
	for row in UI.wrap(profil[1], KANAN_W, Game.font).slice(0, 4):
		UI.label(self, row, Vector2(KANAN_X, y), UI.C_CHOC)
		y += 10
	# ---- batang persentase (selalu di tempat yang sama, tidak bergeser mengikuti panjang deskripsi)
	var ry := 123.0
	for p in Game.PILAR:
		var puncak: bool = p in Game.pilar_gaya(gaya)
		var sq := ColorRect.new()
		sq.color = Game.PILAR_WARNA[p]
		sq.size = Vector2(7, 7)
		sq.position = Vector2(KANAN_X, ry + 1)
		add_child(sq)
		UI.label(self, Game.PILAR_NAMA[p], Vector2(KANAN_X + 10, ry - 1), UI.C_RUST if puncak else UI.C_CHOC)
		var back := ColorRect.new()
		back.color = Color("e4a672")
		back.size = Vector2(BAR_W, 5)
		back.position = Vector2(251, ry + 2)
		add_child(back)
		var bar := ColorRect.new()
		bar.color = Game.PILAR_WARNA[p]
		bar.size = Vector2(0, 5)
		bar.position = Vector2(251, ry + 2)
		add_child(bar)
		bars[p] = bar
		pct_labels[p] = UI.label(self, "0%", Vector2(282, ry - 1), UI.C_CHOC, 24, HORIZONTAL_ALIGNMENT_RIGHT)
		ry += 10
	Game.play_bgm("bgm_ending")
	# ---- animasi masuk berurutan
	var k := 0
	for c in get_children():
		if c == chart or c.get_index() == 0 or c in lencana:
			continue
		FX.pop_in(c, 0.1 + k * 0.03, 0.25, 6.0)
		k += 1
	for i in lencana.size():
		var b: TextureRect = lencana[i]
		b.pivot_offset = b.texture.get_size() / 2.0
		b.scale = Vector2.ZERO
		var tb := create_tween()
		tb.tween_interval(0.9 + i * 0.12)
		tb.tween_property(b, "scale", Vector2.ONE, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tb.tween_callback(Game.sfx.bind("sfx_pop"))
		if i == 0:
			tb.tween_callback(FX.sparkle.bind(self, Vector2(176, 55), 18))
	if not args.get("lihat", false):
		FX.confetti_rain(self, 320.0, 50, 3.5)
	var tw := create_tween()
	tw.tween_interval(0.4)
	tw.tween_callback(Game.sfx.bind("sfx_rapor"))
	tw.tween_method(_set_prog, 0.0, 1.0, 1.4).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


## Lencana di kotak 40x44 pada (156, 33):
##   satu pilar -> lencana besar; dua pilar -> dua ikon berdampingan; seimbang/belum -> empat ikon 2x2.
func _lencana(gaya: String) -> Array:
	var out := []
	var ps := Game.pilar_gaya(gaya)
	if ps.size() == 1:
		out.append(UI.rect(self, "res://assets/rapor/lencana_%s.png" % ps[0], Vector2(KANAN_X, 33)))
	elif ps.size() == 2:
		for i in 2:
			out.append(UI.rect(self, "res://assets/rapor/ikon_%s.png" % ps[i], Vector2(KANAN_X + i * 21, 45)))
	else:
		for i in 4:
			var ic := UI.rect(self, "res://assets/rapor/ikon_%s.png" % Game.PILAR[i], Vector2(KANAN_X + (i % 2) * 21, 34 + (i / 2) * 21))
			if gaya == "belum":
				ic.modulate = Color(0.75, 0.72, 0.7, 0.55)
			out.append(ic)
	return out


## Tombol teks sederhana (kotak gelap berbingkai emas) untuk tombol yang tidak punya gambar sendiri.
func _tombol_teks(parent: Control, teks: String, pos: Vector2, w: float, cb: Callable) -> NinePatchRect:
	var k := UI.nine(parent, UI.UI + "kotak_gelap.png", 4, pos, Vector2(w, 17), 5)
	k.mouse_filter = Control.MOUSE_FILTER_STOP
	k.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	var lb := UI.label(k, teks, Vector2(0, 4), Color("fee761"), w, HORIZONTAL_ALIGNMENT_CENTER)
	k.mouse_entered.connect(func():
		Game.sfx("sfx_hover")
		lb.add_theme_color_override("font_color", Color.WHITE)
		FX.lift(k, true))
	k.mouse_exited.connect(func():
		lb.add_theme_color_override("font_color", Color("fee761"))
		FX.lift(k, false))
	k.gui_input.connect(func(e: InputEvent):
		if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
			Game.sfx("sfx_klik")
			cb.call())
	return k


# ================================================================ halaman Bukti
func _buka_bukti() -> void:
	if halaman_bukti:
		return
	halaman_bukti = Control.new()
	halaman_bukti.size = size
	halaman_bukti.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(halaman_bukti)
	var bg := ColorRect.new()
	bg.color = Color("ead4aa")
	bg.position = Vector2(10, 29)
	bg.size = Vector2(300, 143)
	halaman_bukti.add_child(bg)
	UI.button(halaman_bukti, "kembali", Vector2(13, 33), _tutup_bukti)
	tab_ikon = {}
	for i in Game.PILAR.size():
		var p: String = Game.PILAR[i]
		var ic := UI.rect(halaman_bukti, "res://assets/rapor/ikon_%s.png" % p, Vector2(212 + i * 24, 33))
		ic.mouse_filter = Control.MOUSE_FILTER_STOP
		ic.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		ic.pivot_offset = Vector2(10, 10)
		ic.gui_input.connect(func(e: InputEvent):
			if e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT:
				_pilih_pilar(p))
		tab_ikon[p] = ic
	var isi := Control.new()
	isi.name = "Isi"
	halaman_bukti.add_child(isi)
	Game.sfx("sfx_buku")
	FX.pop_in(halaman_bukti, 0.0, 0.2, 4.0)
	# mulai dari pilar yang paling menonjol
	var ps := Game.pilar_gaya(Game.dominan())
	_pilih_pilar(ps[0] if not ps.is_empty() else "dekomposisi", true)


func _tutup_bukti() -> void:
	if halaman_bukti:
		halaman_bukti.queue_free()
		halaman_bukti = null
		Game.sfx("sfx_buku")


func _pilih_pilar(p: String, awal := false) -> void:
	pilar_bukti = p
	if not awal:
		Game.sfx("sfx_klik")
	for q in tab_ikon:
		tab_ikon[q].modulate = Color(1, 1, 1) if q == p else Color(1, 1, 1, 0.4)
		tab_ikon[q].scale = Vector2(1.15, 1.15) if q == p else Vector2.ONE
	var isi: Control = halaman_bukti.get_node("Isi")
	for c in isi.get_children():
		c.queue_free()
	UI.label(isi, Game.PILAR_NAMA[p], Vector2(84, 32), Game.PILAR_WARNA[p].darkened(0.15))
	UI.label(isi, "Poin: %s dari %s" % [_angka(Game.poin[p]), _angka(Game.bobot[p])], Vector2(84, 43), UI.C_CHOC)
	UI.label(isi, DILIHAT[p], Vector2(14, 56), Color("8b9bb4"), 292)
	var garis := ColorRect.new()
	garis.color = Color("e4a672")
	garis.position = Vector2(14, 68)
	garis.size = Vector2(292, 1)
	isi.add_child(garis)
	var y := 71.0
	var ada := false
	for r in Game.riwayat:
		if r["pilar"] != p:
			continue
		ada = true
		y = _baris_bukti(isi, r, y) + 3.0
	if not ada:
		UI.label(isi, "Belum ada bukti untuk pilar ini.", Vector2(14, y), UI.C_CHOC)
	isi.modulate.a = 0.0
	create_tween().tween_property(isi, "modulate:a", 1.0, 0.15)


## Satu bukti. Kolom kiri: tanda level dan poin di bawahnya. Kolom kanan: kalimat, lalu alasan pemain bila ada.
## Mengembalikan y berikutnya.
func _baris_bukti(isi: Control, r: Dictionary, y: float) -> float:
	const TEKS_X := 44.0
	const TEKS_W := 262.0
	var y0 := y
	var rapat: bool = r.get("jenis", "perilaku") == "rapat"
	UI.label(isi, "Akhir" if rapat else "Lv %d" % int(r["level"]), Vector2(14, y), Color("8b9bb4"))
	var nilai: float = Game.nilai_catatan(r) * Game.bobot_catatan(r)
	var warna := Color("3e8948") if nilai >= 1.0 else (Color("be4a2f") if nilai > 0.0 else Color("8b9bb4"))
	UI.label(isi, "+" + _angka(nilai), Vector2(14, y + 10), warna)
	var kalimat: String = r.get("teks", "")
	if kalimat == "":
		kalimat = str(r.get("detail", ""))   # catatan dari versi lama
	for row in UI.wrap(kalimat, TEKS_W, Game.font).slice(0, 3):
		UI.label(isi, row, Vector2(TEKS_X, y), UI.C_CHOC)
		y += 10
	var alasan: String = r.get("alasan_teks", "")
	if alasan != "":
		var catatan := "Alasanmu: " + alasan
		if r["berhasil"] and not r.get("alasan", "") in Game.ALASAN_MENGUATKAN:
			catatan += " (dihitung separuh)"
		for row in UI.wrap(catatan, TEKS_W, Game.font).slice(0, 2):
			UI.label(isi, row, Vector2(TEKS_X, y), Color("8b9bb4"))
			y += 10
	return maxf(y, y0 + 20.0)


## 2.0 -> "2", 2.5 -> "2,5"
func _angka(v: float) -> String:
	if is_equal_approx(v, roundf(v)):
		return str(int(roundf(v)))
	return ("%.1f" % v).replace(".", ",")


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("buku"):
		get_viewport().set_input_as_handled()
		if halaman_bukti:
			_tutup_bukti()
		else:
			_buka_bukti()
	elif halaman_bukti and event.is_action_pressed("jeda"):
		get_viewport().set_input_as_handled()
		_tutup_bukti()
	elif halaman_bukti and (event.is_action_pressed("gerak_kiri") or event.is_action_pressed("gerak_kanan")):
		get_viewport().set_input_as_handled()
		var i := Game.PILAR.find(pilar_bukti) + (1 if event.is_action_pressed("gerak_kanan") else -1)
		_pilih_pilar(Game.PILAR[wrapi(i, 0, Game.PILAR.size())])


func _set_prog(v: float) -> void:
	prog = v
	for p in Game.PILAR:
		bars[p].size.x = roundf(BAR_W * pr[p] / 100.0 * v)
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
	chart.draw_circle(PIE_C, 12, Color("181425"))
	chart.draw_circle(PIE_C, 11, Color("ead4aa"))
	chart.draw_string(Game.font, PIE_C + Vector2(-12, 3), "CT", HORIZONTAL_ALIGNMENT_CENTER, 24, 9, Color("3e2731"))


func _main_lagi() -> void:
	Game.goto_level_select()


func _menu() -> void:
	Game.goto_menu()
