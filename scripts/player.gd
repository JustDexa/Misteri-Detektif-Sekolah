extends CharacterBody2D
## Detektif yang dikendalikan pemain. Gerak 4 arah (top-down). Titik asal = posisi kaki.

const SPEED := 72.0
var level: Node
var sprite: Sprite2D
var facing := 0   # 0 bawah, 1 kiri, 2 kanan, 3 atas
var _anim := 0.0
var _step_frame := -1
var auto_dir := Vector2.ZERO   # dipakai pengujian otomatis


func _ready() -> void:
	sprite = Sprite2D.new()
	sprite.texture = load("res://assets/chars/pemain.png")
	sprite.hframes = 4
	sprite.vframes = 4
	sprite.centered = false
	sprite.offset = Vector2(-8, -23)
	add_child(sprite)
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = Vector2(10, 6)
	cs.shape = sh
	cs.position = Vector2(0, -3)
	add_child(cs)
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING


func _physics_process(delta: float) -> void:
	var dir := Vector2.ZERO
	if level and level.can_move():
		dir = Input.get_vector("gerak_kiri", "gerak_kanan", "gerak_atas", "gerak_bawah")
		if auto_dir != Vector2.ZERO:
			dir = auto_dir
	if dir.length() > 0.1:
		if absf(dir.x) > absf(dir.y):
			facing = 2 if dir.x > 0 else 1
		else:
			facing = 0 if dir.y > 0 else 3
		velocity = dir.normalized() * SPEED
		_anim += delta * 8.0
		var f := int(_anim) % 4
		sprite.frame = facing * 4 + f
		if f != _step_frame and f % 2 == 1:
			Game.sfx("sfx_langkah", randf_range(0.9, 1.1))
			if level:
				preload("res://scripts/fx.gd").puff(level, position + Vector2(randf_range(-3, 3), -1))
		_step_frame = f
	else:
		velocity = Vector2.ZERO
		_anim = 0.0
		sprite.frame = facing * 4
	move_and_slide()
