extends Node2D
## Dasar semua level top-down: peta, tabrakan, pemain, NPC, interaksi, zona, HUD, dan ALAT UKUR pilar CT.
## Level turunan (level1.gd ... level4.gd) mengisi MAP/BGM/teks dan meng-override:
##   _mulai()                      -> dipanggil setelah kartu judul level
##   _on_interact(id, kind)        -> saat pemain menekan E di dekat NPC / benda
##   _on_zone_enter(id)            -> saat pemain memasuki zona

const UI = preload("res://scripts/ui_kit.gd")
const FX = preload("res://scripts/fx.gd")
var args := {}
var AMBIENT := ""        # partikel suasana: "daun" / "debu" / "sinar" (diisi level turunan)
var sudah_disapa := {}
var book_btn: TextureButton

# ---- diisi level turunan di _init()
var MAP := ""
var BGM := ""
var KARTU := ""
var ZONE_NAMA := {}
var INSPEK := {}

# ---- dunia
var world: Node2D
var entities: Node2D
var player: CharacterBody2D
var cam: Camera2D
var npcs := {}
var items := {}
var interactables := []
var zones := {}
var in_zones := {}
var target = null
var icon: Sprite2D
var arrow: Sprite2D
var arrow_target := ""
var flags := {}
var lock := 0
var objective := ""
var _t := 0.0

# ---- HUD
var hud: CanvasLayer
var banner: NinePatchRect
var banner_lbl: Label
var toast: Label
var _toast_t := 0.0
var mini_dot: ColorRect
var dialog
var overlay_layer: CanvasLayer
var tkp_layer: CanvasLayer

# ---- pengukuran
var m_first := {}
var m_seq := {}
var m_npc := {}


func _ready() -> void:
	_build_world()
	_build_hud()
	if AMBIENT != "":
		var amb := FX.ambient(cam, AMBIENT)
		amb.position = Vector2.ZERO
	_dekor()
	Game.play_bgm(BGM)
	_start()


# ================================================================ BUILD (membaca node dari scene levelN.tscn)
## Struktur scene yang dibaca:
##   Peta (Sprite2D)             gambar lantai/dasar
##   Tabrakan (StaticBody2D)     kotak-kotak tembok & perabot
##   Zona (Node2D)               Area2D per zona; nama node = id zona
##   Benda (Node2D)              Area2D per benda; metadata "kind" = inspect / door / item, "item" = id bukti
##   Entities (Node2D, Y Sort)   NPC: Node2D bernama id NPC berisi "Sprite" (Sprite2D) dan "Badan" (StaticBody2D)
##   SpawnPemain (Marker2D)      posisi awal pemain (kaki)
##   Atas (Sprite2D)             atap/pohon yang tampil di atas pemain
func _build_world() -> void:
	world = self
	entities = $Entities
	var peta: Sprite2D = $Peta
	var W: float = peta.texture.get_width()
	var H: float = peta.texture.get_height()
	# batas peta
	var body := StaticBody2D.new()
	body.name = "BatasPeta"
	add_child(body)
	for r in [Rect2(-16, -16, W + 32, 16), Rect2(-16, H, W + 32, 16), Rect2(-16, 0, 16, H), Rect2(W, 0, 16, H)]:
		_rect_shape(body, r)
	# zona
	for a in $Zona.get_children():
		zones[String(a.name)] = _area_rect(a)
	# NPC
	for n in entities.get_children():
		if not n.has_node("Sprite"):
			continue
		var nid := String(n.name)
		n.set_meta("phase", randf() * 2.0)
		npcs[nid] = n
		var p: Vector2 = n.position
		interactables.append({"id": nid, "kind": "npc", "rect": Rect2(p.x - 8, p.y - 9, 16, 11),
			"anchor": Vector2(p.x, p.y - 31), "active": true})
	# benda
	for a in $Benda.get_children():
		var oid := String(a.name)
		var rect := _area_rect(a)
		var kind: String = a.get_meta("kind", "inspect")
		var it := {"id": oid, "kind": kind, "rect": rect, "anchor": Vector2(rect.get_center().x, rect.position.y - 2), "active": kind != "item"}
		if kind == "item":
			if a.has_node("Ikon"):
				a.get_node("Ikon").queue_free()
			var item_id: String = a.get_meta("item", "")
			var node := Node2D.new()
			node.position = rect.position + Vector2(8, 15)
			var glow := Sprite2D.new()
			glow.texture = load(UI.UI + "kilau_bukti.png")
			glow.scale = Vector2(0.5, 0.5)
			glow.position = Vector2(0, -7)
			glow.modulate = Color(1, 1, 1, 0.5)
			node.add_child(glow)
			var spr := Sprite2D.new()
			spr.texture = load("res://assets/items/%s.png" % item_id)
			spr.position = Vector2(0, -8)
			node.add_child(spr)
			node.set_meta("spr", spr)
			node.set_meta("glow", glow)
			node.visible = false
			entities.add_child(node)
			items[oid] = node
			it["item"] = item_id
			it["anchor"] = rect.position + Vector2(8, -14)
		interactables.append(it)
	# pemain
	player = load("res://scripts/player.gd").new()
	player.name = "Pemain"
	player.level = self
	player.position = $SpawnPemain.position
	player.facing = 3
	entities.add_child(player)
	cam = Camera2D.new()
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(W)
	cam.limit_bottom = int(H)
	cam.offset = Vector2(0, -10)
	player.add_child(cam)
	cam.make_current()
	# ikon interaksi & panah tutorial
	icon = Sprite2D.new()
	icon.texture = load(UI.UI + "ikon_interaksi.png")
	icon.hframes = 2
	icon.z_index = 60
	icon.visible = false
	add_child(icon)
	arrow = Sprite2D.new()
	arrow.texture = load(UI.UI + "panah.png")
	arrow.hframes = 2
	arrow.z_index = 61
	arrow.visible = false
	add_child(arrow)


## Kotak dunia dari Area2D + CollisionShape2D (RectangleShape2D) di dalamnya.
func _area_rect(a: Node2D) -> Rect2:
	for c in a.get_children():
		if c is CollisionShape2D and c.shape is RectangleShape2D:
			var sz: Vector2 = c.shape.size
			var center: Vector2 = a.position + c.position
			return Rect2(center - sz / 2.0, sz)
	return Rect2(a.position, Vector2(16, 16))


func _rect_shape(body: Node, r: Rect2) -> void:
	var cs := CollisionShape2D.new()
	var sh := RectangleShape2D.new()
	sh.size = r.size
	cs.shape = sh
	cs.position = r.get_center()
	body.add_child(cs)


func _build_hud() -> void:
	hud = CanvasLayer.new()
	hud.layer = 5
	add_child(hud)
	banner = UI.nine(hud, UI.UI + "banner.png", 4, Vector2(4, 4), Vector2(100, 15))
	banner_lbl = UI.label(banner, "", Vector2(6, 3), Color.WHITE)
	banner.visible = false
	book_btn = UI.tex_button(hud, UI.UI + "tombol_buku_normal.png", UI.UI + "tombol_buku_hover.png", Vector2(294, 4), _on_book_btn)
	book_btn.pivot_offset = Vector2(11, 11)
	UI.rect(hud, UI.UI + "minimap_bingkai.png", Vector2(254, 138))
	var mini := UI.rect(hud, "res://assets/maps/%s_mini.png" % MAP, Vector2(256, 140))
	mini.modulate = Color(1, 1, 1, 0.9)
	mini_dot = ColorRect.new()
	mini_dot.color = Color("ff0044")
	mini_dot.size = Vector2(2, 2)
	mini_dot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(mini_dot)
	var hint_txt := "E: bicara/periksa   TAB: buku   ESC: jeda"
	var hb := UI.nine(hud, UI.UI + "banner.png", 4, Vector2(2, 166), Vector2(Game.font.get_string_size(hint_txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x + 10, 13))
	hb.modulate = Color(1, 1, 1, 0.85)
	UI.label(hb, hint_txt, Vector2(5, 1), Color("c0cbdc"))
	toast = UI.label(hud, "", Vector2(60, 22), UI.C_GOLD, 200, HORIZONTAL_ALIGNMENT_CENTER, UI.C_BLACK)
	toast.modulate.a = 0.0
	tkp_layer = CanvasLayer.new()
	tkp_layer.layer = 8
	add_child(tkp_layer)
	var dl := CanvasLayer.new()
	dl.layer = 10
	add_child(dl)
	dialog = load("res://scripts/dialog.gd").new()
	dl.add_child(dialog)
	overlay_layer = CanvasLayer.new()
	overlay_layer.layer = 12
	add_child(overlay_layer)


# ================================================================ FLOW
func _start() -> void:
	lock += 1
	if KARTU != "":
		var card := UI.rect(overlay_layer, UI.MENU + KARTU, Vector2(40, -64))
		var tw := create_tween()
		tw.tween_property(card, "position:y", 52.0, 0.45).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tw.tween_interval(1.5)
		tw.tween_property(card, "position:y", -70.0, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		Game.sfx("sfx_bel" if Game.level_index == 0 else "sfx_pintu")
		await tw.finished
		card.queue_free()
	lock -= 1
	await _mulai()


func can_move() -> bool:
	return lock == 0 and not Game.busy


func set_objective(t: String) -> void:
	objective = t
	banner.visible = true
	banner_lbl.text = "Tujuan: " + t
	var w := Game.font.get_string_size(banner_lbl.text, HORIZONTAL_ALIGNMENT_LEFT, -1, 9).x
	banner.size = Vector2(w + 12, 15)
	banner.position = Vector2(4, 4)
	FX.slide_in(banner, Vector2(-(w + 30), 0), 0.0, 0.45)
	Game.sfx("sfx_pop")


var speaker: Node2D = null


func say(lines: Array) -> void:
	lock += 1
	_atur_posisi_dialog()
	await dialog.say(lines)
	lock -= 1


## Kotak dialog dipindah ke atas layar bila pemain / NPC lawan bicara ada di bagian bawah layar,
## supaya karakter yang sedang berinteraksi tidak tertutup.
func _atur_posisi_dialog() -> void:
	var pts := [player.get_global_transform_with_canvas().origin]
	if speaker != null and is_instance_valid(speaker):
		pts.append(speaker.get_global_transform_with_canvas().origin)
	var tertutup_bawah := false
	var tertutup_atas := false
	for p in pts:
		if p.y > 112.0:
			tertutup_bawah = true
		if p.y - 26.0 < 62.0:
			tertutup_atas = true
	dialog.set_top(tertutup_bawah and not tertutup_atas)


func show_toast(t: String, dur := 2.0) -> void:
	toast.text = t
	toast.modulate.a = 1.0
	toast.position = Vector2(60, 12)
	var tw := create_tween()
	tw.tween_property(toast, "position:y", 22.0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_toast_t = dur


func tunjuk(nid: String) -> void:
	arrow_target = nid
	arrow.visible = nid != ""


func reveal(oid: String) -> void:
	if items.has(oid):
		items[oid].visible = true
	for it in interactables:
		if it["id"] == oid:
			it["active"] = true


## Ambil barang di peta. Mengembalikan id barang.
func ambil(oid: String) -> String:
	var item := ""
	for it in interactables:
		if it["id"] == oid:
			it["active"] = false
			item = it.get("item", "")
	if items.has(oid):
		var node: Node2D = items[oid]
		if node.visible and item != "":
			_terbang_ke_buku(item, node)
		node.visible = false
	if item != "":
		Game.add_item(item)
		Game.sfx("sfx_ambil")
		FX.hop(player.sprite, 3)
		show_toast("Bukti baru: " + Game.ITEMS[item][0] + "!", 2.5)
	return item


## Ikon barang terbang dari peta ke tombol Buku Catatan.
func _terbang_ke_buku(item: String, node: Node2D) -> void:
	var start := node.get_global_transform_with_canvas().origin + Vector2(-8, -16)
	FX.sparkle(self, node.position + Vector2(0, -8), 14)
	var ic := TextureRect.new()
	ic.texture = load("res://assets/items/%s.png" % item)
	ic.position = start
	ic.pivot_offset = Vector2(8, 8)
	ic.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(ic)
	var tw := ic.create_tween()
	tw.tween_property(ic, "position", start + Vector2(0, -14), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tw.tween_property(ic, "position", Vector2(297, 7), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(ic, "scale", Vector2(0.5, 0.5), 0.45)
	tw.tween_callback(ic.queue_free)
	tw.tween_callback(FX.pulse.bind(book_btn, 1.3, 0.3))
	tw.tween_callback(Game.sfx.bind("sfx_pop"))


func inspek(id: String) -> void:
	if INSPEK.has(id):
		await say([["", INSPEK[id]]])


func buka_tkp(id: String) -> bool:
	lock += 1
	await Game.iris_close(player.get_global_transform_with_canvas().origin + Vector2(0, -12), 0.4)
	var t = load("res://scripts/tkp.gd").new()
	t.setup(id)
	tkp_layer.add_child(t)
	hud.visible = false
	await Game.iris_open(0.4)
	var lengkap = await t.selesai
	hud.visible = true
	Game.play_bgm(BGM)
	await Game.iris_open(0.4)
	lock -= 1
	return lengkap


func selesai_level() -> void:
	lock += 100
	await get_tree().create_timer(0.3).timeout
	Game.sfx("sfx_level_selesai")
	Game.sfx("sfx_konfeti")
	FX.confetti(overlay_layer, Vector2(100, 120), 60)
	FX.confetti(overlay_layer, Vector2(220, 120), 60)
	var st := UI.rect(overlay_layer, "res://assets/rapor/stempel.png", Vector2(118, 70))
	st.pivot_offset = Vector2(42, 15)
	st.scale = Vector2(3, 3)
	st.modulate.a = 0.0
	var tw := create_tween()
	tw.tween_property(st, "scale", Vector2(1, 1), 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tw.parallel().tween_property(st, "modulate:a", 1.0, 0.2)
	tw.tween_callback(Game.sfx.bind("sfx_stempel"))
	tw.tween_callback(_goyang_kamera)
	tw.tween_interval(1.6)
	await tw.finished
	Game.level_selesai()


func _goyang_kamera() -> void:
	var tw := create_tween()
	for i in 6:
		tw.tween_property(cam, "offset", Vector2(randf_range(-3, 3), -10 + randf_range(-3, 3)), 0.04)
	tw.tween_property(cam, "offset", Vector2(0, -10), 0.05)


# ================================================================ LOOP
func _process(delta: float) -> void:
	_t += delta
	for nid in npcs:
		var n: Node2D = npcs[nid]
		var s: Sprite2D = n.get_node("Sprite")
		s.frame = int((_t + n.get_meta("phase")) / 0.7) % 2
	for oid in items:
		var node: Node2D = items[oid]
		if node.visible:
			node.get_meta("spr").position.y = -8 + roundf(sin(_t * 3.0) * 1.5)
			node.get_meta("glow").rotation = _t
	if _toast_t > 0.0:
		_toast_t -= delta
		if _toast_t < 0.5:
			toast.modulate.a = maxf(_toast_t / 0.5, 0.0)
	arrow.visible = arrow_target != "" and not (target != null and target["id"] == arrow_target)
	if arrow.visible and npcs.has(arrow_target):
		arrow.position = npcs[arrow_target].position + Vector2(0, -36 + roundf(sin(_t * 5.0) * 2))
		arrow.frame = int(_t * 3) % 2
	var feet := player.global_position
	mini_dot.position = Vector2(256, 140) + feet * 0.125 - Vector2(1, 1)
	target = _find_target() if can_move() else null
	icon.visible = target != null
	if target:
		icon.position = target["anchor"] + Vector2(0, roundf(sin(_t * 4.0)))
		icon.frame = int(_t * 2) % 2


func _physics_process(_delta: float) -> void:
	var feet := player.global_position
	for zid in zones:
		var inside: bool = zones[zid].has_point(feet)
		var was: bool = in_zones.get(zid, false)
		if inside and not was:
			in_zones[zid] = true
			_zone_task(zid)
		elif not inside and was:
			in_zones[zid] = false


func _find_target():
	var best = null
	var bd := 14.0
	var feet := player.global_position
	for it in interactables:
		if not it["active"]:
			continue
		var r: Rect2 = it["rect"]
		var cp := Vector2(clampf(feet.x, r.position.x, r.end.x), clampf(feet.y, r.position.y, r.end.y))
		var d := cp.distance_to(feet)
		if d < bd:
			bd = d
			best = it
	return best


func _unhandled_input(event: InputEvent) -> void:
	if not can_move():
		return
	if event.is_action_pressed("interaksi") and target != null:
		get_viewport().set_input_as_handled()
		interact(target["id"])
	elif event.is_action_pressed("buku"):
		get_viewport().set_input_as_handled()
		_on_book_btn()
	elif event.is_action_pressed("jeda"):
		get_viewport().set_input_as_handled()
		_open_pause()


func interact(id: String) -> void:
	var it = null
	for x in interactables:
		if x["id"] == id:
			it = x
	if it == null:
		return
	lock += 1
	Game.sfx("sfx_interaksi")
	speaker = npcs.get(id, null)
	if it["kind"] == "npc":
		_cek_npc(id)
		var npc: Node2D = npcs[id]
		FX.hop(npc.get_node("Sprite"), 3)
		if not sudah_disapa.has(id):
			sudah_disapa[id] = true
			FX.emote(self, npc.position + Vector2(0, -34), "seru", 0.7)
			Game.sfx("sfx_hop")
	await _on_interact(id, it["kind"])
	speaker = null
	lock -= 1


func _zone_task(zid: String) -> void:
	if ZONE_NAMA.has(zid):
		show_toast(ZONE_NAMA[zid], 1.6)
	kunjungi(zid)
	await _on_zone_enter(zid)


# ================================================================ PENGUKURAN PILAR CT
## ABSTRAKSI: setelah dialog berisi 1 info penting + info basa-basi, lokasi PERTAMA yang dimasuki (di antara kandidat).
func ukur_lokasi_pertama(pilar: String, kandidat: Array, benar: String, konteks: String) -> void:
	m_first = {"pilar": pilar, "kandidat": kandidat, "benar": benar, "konteks": konteks}


## ALGORITMA: urutan kunjungan pertama ke lokasi-lokasi pada instruksi. Lokasi lain diabaikan (disaring).
func ukur_urutan(pilar: String, urutan: Array, konteks: String) -> void:
	m_seq = {"pilar": pilar, "urutan": urutan, "visited": [], "konteks": konteks}


## POLA: NPC PERTAMA yang diajak bicara setelah kasus diberikan (kecuali pemberi kasus).
func ukur_npc_pertama(pilar: String, benar: String, kecuali: Array, konteks: String) -> void:
	m_npc = {"pilar": pilar, "benar": benar, "kecuali": kecuali, "konteks": konteks}


func kunjungi(id: String) -> void:
	if not m_first.is_empty() and id in m_first["kandidat"]:
		Game.catat(m_first["pilar"], id == m_first["benar"], "%s: lokasi pertama = %s" % [m_first["konteks"], id])
		m_first = {}
	if not m_seq.is_empty() and id in m_seq["urutan"] and not id in m_seq["visited"]:
		m_seq["visited"].append(id)
		var n: int = m_seq["visited"].size()
		var urut: Array = m_seq["urutan"]
		var sesuai: bool = m_seq["visited"] == urut.slice(0, n)
		if not sesuai or n == urut.size():
			Game.catat(m_seq["pilar"], sesuai and n == urut.size(), "%s: urutan = %s" % [m_seq["konteks"], "-".join(m_seq["visited"])])
			m_seq = {}


func _cek_npc(id: String) -> void:
	if m_npc.is_empty() or id in m_npc["kecuali"]:
		return
	var meta = load("res://assets/chars/npc.json").data
	Game.catat(m_npc["pilar"], id == m_npc["benar"], "%s: NPC pertama = %s (ciri %s)" % [m_npc["konteks"], id, meta.get(id, {}).get("ciri", "?")])
	m_npc = {}


# ================================================================ PANELS
func _on_book_btn() -> void:
	if not can_move():
		return
	lock += 1
	var nb = load("res://scripts/notebook.gd").new()
	nb.objective = objective
	overlay_layer.add_child(nb)
	FX.pulse(book_btn, 1.2, 0.2)
	await nb.ditutup
	lock -= 1


func _open_pause() -> void:
	lock += 1
	var root := Control.new()
	root.size = Vector2(320, 180)
	overlay_layer.add_child(root)
	UI.dim(root)
	var p := Control.new()
	p.position = Vector2(80, 30)
	root.add_child(p)
	UI.rect(p, UI.MENU + "ui_g_panel_jeda.png", Vector2.ZERO)
	FX.drop_in(p)
	UI.button(p, "lanjut", Vector2(24, 32), _close_pause.bind(root))
	UI.button(p, "opsi_jeda", Vector2(24, 58), _pause_opsi.bind(root))
	UI.button(p, "menu_utama", Vector2(24, 84), _pause_menu)
	root.set_meta("pause", true)
	Game.sfx("sfx_buku")


func _close_pause(root: Control) -> void:
	if is_instance_valid(root):
		root.queue_free()
		lock -= 1


func _pause_opsi(root: Control) -> void:
	root.visible = false
	var o = load("res://scripts/options_panel.gd").new()
	overlay_layer.add_child(o)
	await o.ditutup
	if is_instance_valid(root):
		root.visible = true


func _pause_menu() -> void:
	Game.goto_menu()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("jeda"):
		for c in overlay_layer.get_children():
			if c.has_meta("pause") and c.visible:
				get_viewport().set_input_as_handled()
				_close_pause(c)
				return


# ================================================================ VIRTUAL
func _mulai() -> void:
	pass


## Dekorasi bergerak khusus level (mis. air mancur). Di-override level turunan.
func _dekor() -> void:
	pass


func _on_interact(id: String, _kind: String) -> void:
	await inspek(id)


func _on_zone_enter(_id: String) -> void:
	pass
