extends Node
## Uji otomatis (tidak dipakai saat bermain biasa). Jalankan:
##   godot --headless --path . -- --autotest --skenario=ideal
##   godot --headless --path . -- --autotest --skenario=campur
## Bot memainkan keempat level sampai Rapor lalu mencocokkan skor dengan hasil yang diharapkan.

var skenario := "ideal"
var gagal := []
var shots := ""


func snap(nama: String) -> void:
	if shots == "":
		return
	await get_tree().create_timer(0.4).timeout
	await RenderingServer.frame_post_draw
	var img := get_viewport().get_texture().get_image()
	img.resize(img.get_width() * 3, img.get_height() * 3, Image.INTERPOLATE_NEAREST)
	img.save_png(shots + "/" + nama + ".png")
	print("  [snap] ", nama)


func hold_talk(lv, id: String, nama: String, wait := 1.6) -> void:
	await _idle(lv)
	Game.hold_dialog = true
	lv.interact(id)
	await get_tree().create_timer(wait).timeout
	await snap(nama)
	Game.hold_dialog = false
	await _idle(lv)


func _ready() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--skenario="):
			skenario = a.split("=")[1]
		if a.begins_with("--shots="):
			shots = a.split("=")[1]
	print("=== AUTOTEST skenario: ", skenario)
	_run()


func _frames(n := 3) -> void:
	for i in n:
		await get_tree().physics_frame


func _idle(lv) -> void:
	await _frames(3)
	while is_instance_valid(lv) and (lv.lock > 0 or Game.busy):
		await get_tree().process_frame


func _level(i: int):
	while true:
		await get_tree().process_frame
		var c = Game.current
		if c != null and is_instance_valid(c) and not Game.busy and "lock" in c and c.MAP != "" and Game.level_index == i:
			await _idle(c)
			print("--- Level ", i + 1, " (", c.MAP, ")")
			return c


func talk(lv, id: String) -> void:
	await _idle(lv)
	print("  bicara/periksa: ", id)
	await lv.interact(id)
	await _idle(lv)


func last(lv, id: String) -> void:
	await _idle(lv)
	print("  ambil (akhir level): ", id)
	lv.interact(id)


func zone(lv, zid: String) -> void:
	await _idle(lv)
	print("  masuk zona: ", zid)
	var r: Rect2 = lv.zones[zid]
	lv.player.position = r.get_center()
	await _frames(4)
	await _idle(lv)


## Jalan sungguhan (input arah) mendekati NPC sampai ikon interaksi muncul, lalu tekan E.
func walk_and_press(lv, nid: String) -> void:
	await _idle(lv)
	var goal: Vector2 = lv.npcs[nid].position + Vector2(0, 10)
	var t0 := Time.get_ticks_msec()
	while Time.get_ticks_msec() - t0 < 8000:
		if lv.target != null and lv.target["id"] == nid:
			break
		var d: Vector2 = goal - lv.player.position
		lv.player.auto_dir = d.normalized() if d.length() > 2 else Vector2.ZERO
		await get_tree().physics_frame
	lv.player.auto_dir = Vector2.ZERO
	if lv.target == null or lv.target["id"] != nid:
		gagal.append("tidak bisa mendekati " + nid)
		return
	print("  berjalan ke ", nid, " OK (ikon interaksi muncul) dalam %.1f dtk" % ((Time.get_ticks_msec() - t0) / 1000.0))
	await snap("01b_dekat_" + nid)
	Game.hold_dialog = true
	var ev := InputEventAction.new()
	ev.action = "interaksi"
	ev.pressed = true
	Input.parse_input_event(ev)
	await _frames(4)
	if not lv.dialog.active:
		gagal.append("tombol E tidak membuka dialog " + nid)
	Game.hold_dialog = false
	await _idle(lv)


## gaya: "sektor" = GRID + perbesar tiap sektor dan periksa semua bendanya, urut A-B-C-D
##       "rapi"   = tanpa GRID, tapi periksa per sektor sampai tuntas, urut A-B-C-D
##       "acak"   = tanpa GRID, lompat-lompat antar sektor
func tkp(lv, door: String, gaya: String) -> void:
	await _idle(lv)
	print("  masuk TKP lewat ", door, " gaya=", gaya)
	lv.interact(door)
	var t = null
	while t == null:
		await get_tree().process_frame
		if lv.tkp_layer.get_child_count() > 0:
			t = lv.tkp_layer.get_child(0)
	await _frames(3)
	if gaya == "acak":
		var putaran := [3, 0, 2, 1]
		var ptr := [0, 0, 0, 0]
		var i := 0
		while is_instance_valid(t) and not t.done and i < 200:
			var s: int = putaran[i % 4]
			var ids: Array = t.ids_in_sector(s)
			if not ids.is_empty():
				t.auto_click(ids[ptr[s] % ids.size()])
				ptr[s] += 1
			i += 1
			await _frames(2)
		return
	if gaya == "sektor":
		t.auto_grid(true)
	for s in 4:
		if not is_instance_valid(t) or t.done:
			break
		if gaya == "sektor":
			t.zoom_in(s)
			await get_tree().create_timer(0.35).timeout
			if s == 0:
				await snap("06b_tkp_perbesar_" + door)
		for uid in t.ids_in_sector(s):
			if not is_instance_valid(t) or t.done:
				break
			t.auto_click(uid)
			await _frames(2)
		if gaya == "sektor" and is_instance_valid(t) and not t.done:
			t.zoom_out()
			await get_tree().create_timer(0.25).timeout
			if s == 0:
				await snap("06_tkp_" + door)


func _run() -> void:
	Game.PROFIL_PATH = "user://profil_autotest.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.PROFIL_PATH))
	Game.ganti_pemain("Bot " + skenario)
	for i in 4:
		if Game.level_terbuka(i) != (i == 0):
			gagal.append("kunci level salah di awal (level %d)" % (i + 1))
	Game.mulai_level(0)
	var ideal := skenario == "ideal"
	# ---------------- LEVEL 1
	var lv = await _level(0)
	await snap("01_level1_hud")
	await talk(lv, "lemari_piala")
	await walk_and_press(lv, "bu_rina")
	if ideal:
		lv._on_book_btn()
		await _frames(5)
		await snap("02_buku_kasus")
		lv.overlay_layer.get_child(lv.overlay_layer.get_child_count() - 1)._tutup()
		await _frames(3)
	await talk(lv, "dodi")
	await hold_talk(lv, "nisa", "03_dialog_nisa")
	await talk(lv, "pak_joko")
	if not ideal:
		await zone(lv, "kantin")
	await zone(lv, "gudang")
	await talk(lv, "item_jejak")
	await last(lv, "item_sapu")
	# ---------------- LEVEL 2
	lv = await _level(1)
	var cf := ConfigFile.new()
	cf.load(Game.PROFIL_PATH)
	if cf.get_value("progres", "selesai", []) != [0] or not Game.level_terbuka(1) or Game.level_terbuka(2):
		gagal.append("progres level 1 tidak tersimpan / kunci salah")
	if cf.get_value("profil", "nama", "") != "Bot " + skenario:
		gagal.append("nama tidak tersimpan")
	print("  progres tersimpan: selesai=", cf.get_value("progres", "selesai", []), " riwayat=", cf.get_value("progres", "riwayat", []).size())
	await snap("04_level2_taman")
	await talk(lv, "pak_harun")
	await talk(lv, "bu_wati")
	if ideal:
		await zone(lv, "parkir")
		await talk(lv, "mas_parkir")
		await zone(lv, "air_mancur")
		await talk(lv, "item_daftar")
	await zone(lv, "gazebo")
	await talk(lv, "bima")
	await last(lv, "item_selang")
	# ---------------- LEVEL 3
	lv = await _level(2)
	await talk(lv, "bu_sri")
	await snap("05_level3_pasar")
	if not ideal:
		await talk(lv, "pedagang_buah")
		await talk(lv, "ibu_pembeli")
		await talk(lv, "anak_pedagang")
	await talk(lv, "tari")
	await tkp(lv, "kios_ikan_pintu", "sektor" if ideal else "rapi")
	# ---------------- LEVEL 4
	lv = await _level(3)
	await snap("07_level4_museum")
	if ideal:
		lv._open_pause()
		await snap("08_jeda")
		lv._close_pause(lv.overlay_layer.get_child(lv.overlay_layer.get_child_count() - 1))
		await _frames(3)
	await talk(lv, "pak_hadi")
	await talk(lv, "arga")
	if not ideal:
		await zone(lv, "suvenir")
	await zone(lv, "pos_satpam")
	await talk(lv, "satpam")
	if ideal:
		await zone(lv, "fosil")
		await zone(lv, "batik")
		await tkp(lv, "gudang_museum_pintu", "sektor")
	else:
		await tkp(lv, "gudang_museum_pintu", "acak")
	# ---------------- ENDING -> RAPOR
	if shots != "":
		while not (Game.current != null and is_instance_valid(Game.current) and Game.current.get_script().resource_path.ends_with("ending.gd")):
			await get_tree().process_frame
		var en = Game.current
		while en.stage != "poster":
			await get_tree().process_frame
		Game.hold_dialog = true
		await get_tree().create_timer(0.6).timeout
		await snap("09_ending_poster")
		Game.hold_dialog = false
		while en.stage != "klub":
			await get_tree().process_frame
		Game.hold_dialog = true
		await get_tree().create_timer(1.0).timeout
		await snap("10_ending_klub")
		Game.hold_dialog = false
	while not (Game.current != null and is_instance_valid(Game.current) and Game.current.get_script().resource_path.ends_with("rapor.gd")):
		await get_tree().process_frame
	await get_tree().create_timer(2.0).timeout
	await snap("11_rapor_" + skenario)
	_cek()
	if skenario == "campur" and gagal.is_empty():
		# ---- ulangi Level 1 dengan cara ideal: hasil L1 lama harus diganti
		print("--- Ulang Level 1 (cara ideal)")
		Game.mulai_level(0)
		var l1 = await _level(0)
		await talk(l1, "bu_rina")
		await talk(l1, "nisa")
		await talk(l1, "pak_joko")
		await zone(l1, "gudang")
		await last(l1, "item_sapu")
		await _level(1)
		print("  abstraksi setelah ulang L1: %d/%d (harusnya 1/2)" % [Game.skor["abstraksi"], Game.peluang["abstraksi"]])
		if Game.skor["abstraksi"] != 1 or Game.peluang["abstraksi"] != 2:
			gagal.append("ulang level tidak mengganti hasil lama")
	if gagal.is_empty():
		print("=== AUTOTEST LULUS (", skenario, ")")
		get_tree().quit(0)
	else:
		print("=== AUTOTEST GAGAL: ", gagal)
		get_tree().quit(1)


func _cek() -> void:
	print("=== HASIL")
	for p in Game.PILAR:
		print("  %-12s %d/%d" % [p, Game.skor[p], Game.peluang[p]])
	var pb := Game.persentase_bulat()
	print("  persentase: ", pb, "  dominan: ", Game.dominan())
	print("  bukti: ", Game.inventory.size(), " -> ", Game.inventory)
	var expect := {}
	if skenario == "ideal":
		expect = {"dekomposisi": [2, 2], "pola": [2, 2], "abstraksi": [2, 2], "algoritma": [2, 2]}
	else:
		expect = {"dekomposisi": [1, 2], "pola": [1, 2], "abstraksi": [0, 2], "algoritma": [0, 2]}
	for p in expect:
		if Game.skor[p] != expect[p][0] or Game.peluang[p] != expect[p][1]:
			gagal.append("%s: dapat %d/%d, harusnya %d/%d" % [p, Game.skor[p], Game.peluang[p], expect[p][0], expect[p][1]])
	var total := 0
	for p in Game.PILAR:
		total += pb[p]
	if total != 100:
		gagal.append("total persen = %d" % total)
	if not FileAccess.file_exists("user://hasil_rapor.csv"):
		gagal.append("CSV tidak tersimpan")
	else:
		print("  CSV: ", Game.last_saved_path)
