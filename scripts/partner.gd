extends Node2D
## Partner detektif (Kiki). Mengikuti jejak langkah pemain dari belakang.
## Tidak punya tabrakan, jadi tidak pernah menghalangi jalan atau mengubah rute pemain.
## Aturan desain: Kiki TIDAK berkacamata (kacamata adalah ciri pola yang diukur) dan tidak pernah
## memberi tahu jawaban; ia hanya bertanya SETELAH sebuah tindakan dicatat.

const JARAK := 15          # jarak ikut (jumlah titik jejak, kira-kira piksel)
const SPEED := 84.0        # sedikit lebih cepat dari pemain supaya bisa menyusul
var pemain: Node2D
var sprite: Sprite2D
var facing := 0            # 0 bawah, 1 kiri, 2 kanan, 3 atas
var _jejak: Array[Vector2] = []
var _anim := 0.0
var _diam := 0.0


func setup(p: Node2D) -> void:
	pemain = p
	position = p.position + Vector2(-13, 1)


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/chars/partner.png")
	sprite.hframes = 4
	sprite.vframes = 4
	sprite.centered = false
	sprite.offset = Vector2(-8, -23)
	add_child(sprite)
	facing = 2
	sprite.frame = facing * 4


func _physics_process(delta: float) -> void:
	if pemain == null or not is_instance_valid(pemain):
		return
	var pp := pemain.position
	if position.distance_to(pp) > 90.0:
		# pemain berpindah jauh sekaligus (mis. uji otomatis): langsung menyusul
		_jejak.clear()
		position = pp + Vector2(-13, 1)
	if _jejak.is_empty() or _jejak[_jejak.size() - 1].distance_to(pp) >= 1.0:
		_jejak.append(pp)
	var bergerak := false
	var sisa := SPEED * delta
	while _jejak.size() > JARAK and sisa > 0.0:
		var t: Vector2 = _jejak[0]
		var d := t - position
		var jarak := d.length()
		if jarak <= sisa:
			position = t
			sisa -= jarak
			_jejak.pop_front()
		else:
			position += d / jarak * sisa
			sisa = 0.0
		if jarak > 0.01:
			bergerak = true
			if absf(d.x) > absf(d.y):
				facing = 2 if d.x > 0 else 1
			else:
				facing = 0 if d.y > 0 else 3
	if bergerak:
		_diam = 0.0
		_anim += delta * 8.0
		sprite.frame = facing * 4 + int(_anim) % 4
	else:
		_anim = 0.0
		_diam += delta
		if _diam > 0.25:
			hadap(pp)
		sprite.frame = facing * 4


## Menghadap ke sebuah titik (dipakai saat berhenti dan saat berbicara).
func hadap(titik: Vector2) -> void:
	var d := titik - position
	if d.length() < 2.0:
		return
	if absf(d.x) > absf(d.y):
		facing = 2 if d.x > 0 else 1
	else:
		facing = 0 if d.y > 0 else 3
	sprite.frame = facing * 4
