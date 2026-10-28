extends Node
## Scene utama. Semua layar (splash, menu, level, rapor) dipasang sebagai anak node ini oleh autoload Game.


func _ready() -> void:
	Game.boot(self)
