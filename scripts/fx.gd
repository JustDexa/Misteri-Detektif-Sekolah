extends RefCounted
## Efek & animasi bersama: muncul, geser masuk, goyang, lompat, konfeti, kilau, emote, partikel suasana.
## Pakai:  const FX = preload("res://scripts/fx.gd")   lalu   FX.pop_in(node)

const D := "res://assets/fx/"
const WARNA_KONFETI := ["fee761", "feae34", "e43b44", "f6757a", "2ce8f5", "0099db", "63c74d", "ffffff"]


## Muncul: memudar masuk sambil naik sedikit.
static func pop_in(n, delay := 0.0, dur := 0.3, dy := 8.0) -> void:
	var p = n.position
	if n is Control:
		n.set_meta("base_y", p.y)
	n.modulate.a = 0.0
	n.position = p + Vector2(0, dy)
	var tw: Tween = n.create_tween()
	tw.tween_interval(delay)
	tw.tween_property(n, "modulate:a", 1.0, dur)
	tw.parallel().tween_property(n, "position", p, dur).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Geser masuk dari posisi (posisi akhir + offset).
static func slide_in(n, offset: Vector2, delay := 0.0, dur := 0.45, trans := Tween.TRANS_BACK) -> void:
	var p = n.position
	n.position = p + offset
	if n is Control:
		n.set_meta("base_y", p.y)
	var tw: Tween = n.create_tween()
	tw.tween_interval(delay)
	tw.tween_property(n, "position", p, dur).set_trans(trans).set_ease(Tween.EASE_OUT)


## Panel muncul dari atas dengan pantulan (untuk jeda, opsi, popup).
static func drop_in(n, delay := 0.0) -> void:
	slide_in(n, Vector2(0, -150), delay, 0.5, Tween.TRANS_BACK)


## Goyang kiri-kanan (mis. level terkunci, benda pengecoh).
static func shake(n, strength := 3.0, dur := 0.3) -> void:
	if n.has_meta("shaking"):
		return
	n.set_meta("shaking", true)
	var p = n.position
	var tw: Tween = n.create_tween()
	var steps := 6
	for i in steps:
		var s: float = strength * (1.0 - float(i) / steps) * (1 if i % 2 == 0 else -1)
		tw.tween_property(n, "position", p + Vector2(roundf(s), 0), dur / steps)
	tw.tween_property(n, "position", p, 0.03)
	tw.tween_callback(n.remove_meta.bind("shaking"))


## Lompat kecil (NPC disapa, pemain mengambil barang).
static func hop(n: Node2D, h := 4.0) -> void:
	if n.has_meta("hopping"):
		return
	n.set_meta("hopping", true)
	var p := n.position
	var tw: Tween = n.create_tween()
	tw.tween_property(n, "position", p - Vector2(0, h), 0.09).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "position", p, 0.13).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tw.tween_callback(n.remove_meta.bind("hopping"))


## Denyut skala (untuk ikon kecil / angka penghitung). Hanya untuk node dengan pivot di tengah.
static func pulse(n, amount := 1.25, dur := 0.25) -> void:
	var tw: Tween = n.create_tween()
	tw.tween_property(n, "scale", Vector2(amount, amount), dur * 0.4).set_ease(Tween.EASE_OUT)
	tw.tween_property(n, "scale", Vector2.ONE, dur * 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Tombol naik 2 px saat disorot.
static func lift(b: Control, up: bool) -> void:
	if b.has_meta("shaking"):
		return
	if not b.has_meta("base_y"):
		b.set_meta("base_y", b.position.y)
	var by: float = b.get_meta("base_y")
	var tw := b.create_tween()
	tw.tween_property(b, "position:y", by - (2.0 if up else 0.0), 0.08)


# ================================================================ partikel
static func _particles(parent: Node, tex: String, amount: int) -> CPUParticles2D:
	var p := CPUParticles2D.new()
	p.texture = load(D + tex + ".png")
	p.amount = amount
	parent.add_child(p)
	return p


static func _free_later(p: Node, t: float) -> void:
	p.get_tree().create_timer(t).timeout.connect(p.queue_free)


## Konfeti meledak dari satu titik (posisi lokal parent).
static func confetti(parent: Node, pos: Vector2, amount := 70) -> void:
	var p := _particles(parent, "konfeti", amount)
	p.position = pos
	p.one_shot = true
	p.explosiveness = 0.95
	p.lifetime = 2.2
	p.direction = Vector2(0, -1)
	p.spread = 70.0
	p.initial_velocity_min = 70.0
	p.initial_velocity_max = 150.0
	p.gravity = Vector2(0, 160)
	p.damping_min = 20.0
	p.damping_max = 40.0
	p.angular_velocity_min = -300.0
	p.angular_velocity_max = 300.0
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([Color(WARNA_KONFETI[0]), Color(WARNA_KONFETI[1])])
	for i in range(2, WARNA_KONFETI.size()):
		g.add_point(float(i) / WARNA_KONFETI.size(), Color(WARNA_KONFETI[i]))
	p.color_initial_ramp = g
	p.z_index = 90
	p.emitting = true
	_free_later(p, 3.0)


## Hujan konfeti dari atas layar (ending / rapor).
static func confetti_rain(parent: Node, width := 320.0, amount := 60, dur := 4.0) -> CPUParticles2D:
	var p := _particles(parent, "konfeti", amount)
	p.position = Vector2(width / 2.0, -6)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(width / 2.0, 2)
	p.lifetime = 3.2
	p.direction = Vector2(0, 1)
	p.spread = 25.0
	p.initial_velocity_min = 25.0
	p.initial_velocity_max = 55.0
	p.gravity = Vector2(0, 18)
	p.angular_velocity_min = -200.0
	p.angular_velocity_max = 200.0
	var g := Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 1.0])
	g.colors = PackedColorArray([Color(WARNA_KONFETI[0]), Color(WARNA_KONFETI[4])])
	for i in range(1, WARNA_KONFETI.size()):
		g.add_point(float(i) / WARNA_KONFETI.size(), Color(WARNA_KONFETI[i]))
	p.color_initial_ramp = g
	p.z_index = 90
	p.emitting = true
	if dur > 0.0:
		var tw := p.create_tween()
		tw.tween_interval(dur)
		tw.tween_callback(p.set_emitting.bind(false))
		_free_later(p, dur + 3.5)
	return p


## Kilau bintang kecil yang memancar (barang ditemukan).
static func sparkle(parent: Node, pos: Vector2, amount := 12, color := Color("fee761")) -> void:
	var p := _particles(parent, "kilau", amount)
	p.position = pos
	p.one_shot = true
	p.explosiveness = 1.0
	p.lifetime = 0.6
	p.spread = 180.0
	p.initial_velocity_min = 30.0
	p.initial_velocity_max = 70.0
	p.damping_min = 60.0
	p.damping_max = 90.0
	p.gravity = Vector2.ZERO
	p.color = color
	var curve := Curve.new()
	curve.add_point(Vector2(0, 1))
	curve.add_point(Vector2(1, 0))
	p.scale_amount_curve = curve
	p.z_index = 95
	p.emitting = true
	_free_later(p, 1.2)


## Kepulan debu kecil (langkah kaki).
static func puff(parent: Node, pos: Vector2) -> void:
	var s := Sprite2D.new()
	s.texture = load(D + "asap.png")
	s.position = pos
	s.modulate = Color(1, 1, 1, 0.55)
	parent.add_child(s)
	var tw := s.create_tween()
	tw.tween_property(s, "position", pos + Vector2(randf_range(-3, 3), -4), 0.35)
	tw.parallel().tween_property(s, "modulate:a", 0.0, 0.35)
	tw.tween_callback(s.queue_free)


## Gelembung emote di atas kepala (seru / tanya / senang).
static func emote(parent: Node, pos: Vector2, jenis := "seru", dur := 0.9) -> void:
	var s := Sprite2D.new()
	s.texture = load(D + "emote_%s.png" % jenis)
	s.position = pos + Vector2(0, 6)
	s.modulate.a = 0.0
	s.z_index = 70
	parent.add_child(s)
	var tw := s.create_tween()
	tw.tween_property(s, "position", pos, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.parallel().tween_property(s, "modulate:a", 1.0, 0.12)
	tw.tween_interval(dur)
	tw.tween_property(s, "modulate:a", 0.0, 0.2)
	tw.tween_callback(s.queue_free)


## Partikel suasana yang terus menyala, mengikuti kamera (daun, debu, air).
static func ambient(parent: Node, jenis: String) -> CPUParticles2D:
	var p := _particles(parent, "daun" if jenis == "daun" else "debu", 14)
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(180, 100)
	p.preprocess = 6.0
	p.local_coords = false
	p.z_index = 40
	match jenis:
		"daun":
			p.amount = 10
			p.lifetime = 7.0
			p.direction = Vector2(-1, 1)
			p.spread = 20.0
			p.initial_velocity_min = 8.0
			p.initial_velocity_max = 16.0
			p.gravity = Vector2(0, 3)
			p.angular_velocity_min = -60.0
			p.angular_velocity_max = 60.0
			p.orbit_velocity_min = 0.0
		"debu":
			p.amount = 18
			p.lifetime = 8.0
			p.direction = Vector2(1, -0.3)
			p.spread = 60.0
			p.initial_velocity_min = 2.0
			p.initial_velocity_max = 6.0
			p.gravity = Vector2.ZERO
			p.color = Color(1, 0.97, 0.8, 0.45)
		"sinar":
			p.amount = 16
			p.lifetime = 6.0
			p.direction = Vector2(0, -1)
			p.spread = 40.0
			p.initial_velocity_min = 2.0
			p.initial_velocity_max = 5.0
			p.gravity = Vector2.ZERO
			p.color = Color(1, 0.95, 0.6, 0.4)
	p.emitting = true
	return p


## Percikan air terus-menerus (air mancur).
static func fountain(parent: Node, pos: Vector2) -> CPUParticles2D:
	var p := _particles(parent, "air", 24)
	p.position = pos
	p.lifetime = 0.9
	p.direction = Vector2(0, -1)
	p.spread = 35.0
	p.initial_velocity_min = 28.0
	p.initial_velocity_max = 40.0
	p.gravity = Vector2(0, 90)
	p.z_index = 12
	p.emitting = true
	return p
