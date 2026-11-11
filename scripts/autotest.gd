extends Node
## Uji otomatis (tidak dipakai saat bermain biasa). Jalankan:
##   godot --headless --path . -- --autotest --skenario=ideal
##   godot --headless --path . -- --autotest --skenario=campur
##   godot --headless --path . -- --autotest --skenario=aturan
##   godot --headless --path . -- --autotest --skenario=tombol
## "ideal"/"campur": bot memainkan keempat level sampai Rapor lalu mencocokkan skor dengan hasil yang diharapkan.
## "aturan": menguji aturan penilaian secara langsung (TKP dua jalur, seri dua pilar, pembulatan) tanpa bermain.
## "tombol": menguji masukan sungguhan (keyboard & mouse) pada daftar pilihan jawaban dan pada partner.

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
		if a == "--tanpa-partner":   # memastikan game tetap berjalan bila partner dimatikan
			Game.PARTNER_AKTIF = false
	print("=== AUTOTEST skenario: ", skenario)
	if skenario == "aturan":
		_uji_aturan()
	elif skenario == "tombol":
		_uji_tombol()
	else:
		_run()


## Tahan pertanyaan partner di layar, potret, lalu lanjutkan.
func snap_tanya(dlg, nama: String) -> void:
	if shots == "":
		Game.hold_tanya = false
		return
	var t0 := Time.get_ticks_msec()
	while not dlg._memilih and Time.get_ticks_msec() - t0 < 6000:
		await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout
	await snap(nama)
	Game.hold_tanya = false


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
		if gaya == "sektor" and s == 2 and is_instance_valid(t) and not t.done:
			await snap("06c_tkp_pesan_atas_" + door)
		if gaya == "sektor" and is_instance_valid(t) and not t.done:
			t.zoom_out()
			await get_tree().create_timer(0.25).timeout
			if s == 0:
				await snap("06_tkp_" + door)


func _run() -> void:
	Game.PROFIL_PATH = "user://profil_autotest.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.PROFIL_PATH))
	Game.ganti_pemain("Bot " + skenario)
	if skenario == "campur":
		# Kak Arga dipilih "karena paling dekat" (kebetulan -> separuh), dan satu jawaban rapat meleset
		Game.auto_jawab = {"L4.pola": "dekat", "R.pola": "topi"}
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
	if ideal and shots != "":
		Game.hold_tanya = true
		lv.player.position = lv.zones["gudang"].get_center()
		await snap_tanya(lv.dialog, "03b_tanya_alasan")
		await _idle(lv)
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
	if ideal and shots != "":
		lv._on_book_btn()
		await _frames(5)
		var nb = lv.overlay_layer.get_child(lv.overlay_layer.get_child_count() - 1)
		nb._set_tab("bukti")
		await snap("02b_buku_bukti")
		nb._tutup()
		await _frames(3)
		await hold_talk(lv, "kiki", "04b_sapa_partner")
	await talk(lv, "pak_harun")
	await talk(lv, "bu_wati")
	if ideal:
		await zone(lv, "parkir")
		await snap("04c_nama_lokasi")
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
	if not ideal:
		# Pak Satpam tidak dihitung sebagai "NPC pertama": pengukuran Pola harus tetap menunggu
		await talk(lv, "satpam")
		if lv.m_npc.is_empty():
			gagal.append("Pak Satpam ikut dihitung sebagai NPC pertama")
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
		Game.hold_tanya = true
		Game.hold_dialog = false
		await snap_tanya(en.dialog, "10b_rapat_detektif")
	while not (Game.current != null and is_instance_valid(Game.current) and Game.current.get_script().resource_path.ends_with("rapor.gd")):
		await get_tree().process_frame
	await get_tree().create_timer(2.0).timeout
	await snap("11_rapor_" + skenario)
	# halaman Bukti: setiap catatan punya kalimat untuk siswa, dan poin per pilar cocok dengan Rapor
	var rp = Game.current
	rp._buka_bukti()
	await get_tree().create_timer(0.4).timeout
	for p in Game.PILAR:
		rp._pilih_pilar(p)
		await get_tree().create_timer(0.3).timeout
		await snap("12_bukti_%s_%s" % [skenario, p])
	for r in Game.riwayat:
		if str(r.get("teks", "")) == "":
			gagal.append("catatan tanpa kalimat bukti: %s" % r.get("momen", "?"))
	rp._tutup_bukti()
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
		# level 2 sudah pernah selesai, jadi setelah ulangan pemain kembali ke layar Pilih Level
		while not (Game.current != null and is_instance_valid(Game.current) and Game.current.get_script().resource_path.ends_with("level_select.gd")):
			await get_tree().process_frame
		print("  abstraksi setelah ulang L1: %d/%d (harusnya 1/2)" % [Game.skor["abstraksi"], Game.peluang["abstraksi"]])
		if Game.skor["abstraksi"] != 1 or Game.peluang["abstraksi"] != 2:
			gagal.append("ulang level tidak mengganti hasil lama")
		# data penelitian: percobaan PERTAMA tidak boleh ikut tertimpa
		var awal: Dictionary = Game.ringkas(Game.catatan_pertama())
		print("  abstraksi percobaan pertama: %d/%d (harusnya tetap 0/2), percobaan per level: %s" % [awal["abstraksi"]["skor"], awal["abstraksi"]["peluang"], str(Game.percobaan)])
		if int(Game.percobaan[1]) != 1:
			gagal.append("mengulang level 1 ikut menghitung percobaan level 2")
		if awal["abstraksi"]["skor"] != 0 or awal["abstraksi"]["peluang"] != 2:
			gagal.append("percobaan pertama tertimpa oleh ulangan")
		if int(Game.percobaan[0]) != 2:
			gagal.append("jumlah percobaan level 1 = %s, harusnya 2" % str(Game.percobaan[0]))
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
	# nilai berbobot (perilaku dikoreksi alasan + Rapat Detektif) dan gaya dominan
	var bobot_harap := 2.5 if Game.PARTNER_AKTIF and Game.RAPAT_DETEKTIF else 2.0
	var poin_harap := {"dekomposisi": bobot_harap, "pola": bobot_harap, "abstraksi": bobot_harap, "algoritma": bobot_harap}
	var gaya_harap := "seimbang"
	if skenario == "campur" and not Game.PARTNER_AKTIF:
		poin_harap = {"dekomposisi": 1.0, "pola": 1.0, "abstraksi": 0.0, "algoritma": 0.0}
		gaya_harap = "dekomposisi+pola"
	elif skenario == "campur":
		# dekomposisi 1 + rapat 0.5 | pola: Arga "paling dekat" = 0.5, rapat meleset | lainnya hanya rapat
		poin_harap = {"dekomposisi": 1.5, "pola": 0.5, "abstraksi": 0.5, "algoritma": 0.5}
		gaya_harap = "dekomposisi"
	for p in poin_harap:
		print("  %-12s poin %.1f / bobot %.1f" % [p, Game.poin[p], Game.bobot[p]])
		if absf(Game.poin[p] - poin_harap[p]) > 0.001 or absf(Game.bobot[p] - bobot_harap) > 0.001:
			gagal.append("%s: poin %.1f/%.1f, harusnya %.1f/%.1f" % [p, Game.poin[p], Game.bobot[p], poin_harap[p], bobot_harap])
	if Game.dominan() != gaya_harap:
		gagal.append("gaya dominan %s, harusnya %s" % [Game.dominan(), gaya_harap])
	if not FileAccess.file_exists("user://hasil_rapor.csv"):
		gagal.append("CSV tidak tersimpan")
	else:
		print("  CSV: ", Game.last_saved_path)


# ================================================================ uji aturan penilaian (tanpa bermain)
func _klik(daftar: Array) -> Array:
	# daftar = [[sektor, jumlah benda, "penuh"/"perbesar"], ...] -> klik benda unik berurutan
	var out := []
	var n := 0
	for d in daftar:
		for i in int(d[1]):
			out.append([int(d[0]), d[2], "b%d" % n])
			n += 1
	return out


func _cek_tkp(nama: String, klik: Array, zoom: Array, grid: bool, harap: String) -> void:
	var tkp = load("res://scripts/tkp.gd")
	var h: Dictionary = tkp.nilai(klik, zoom, grid, [6, 6, 6, 6], [true, true, false, true])
	var ok: bool = h["jalur"] == harap
	print("  [%s] %-52s -> %s" % ["OK" if ok else "SALAH", nama, h["jalur"]])
	if not ok:
		gagal.append("TKP %s: jalur %s, harusnya %s (%s)" % [nama, h["jalur"], harap, h["detail"]])


func _catatan(rasio: Dictionary) -> Array:
	# rasio = {pilar: jumlah berhasil dari 2 kesempatan perilaku}
	var out := []
	for p in Game.PILAR:
		for i in 2:
			out.append({"level": 1, "pilar": p, "berhasil": i < int(rasio.get(p, 0)), "jenis": "perilaku", "momen": "x", "alasan": "", "detail": ""})
	return out


func _cek_gaya(nama: String, rasio: Dictionary, harap: String) -> void:
	var g: String = Game.gaya_dari(Game.ringkas(_catatan(rasio)))
	var ok := g == harap
	print("  [%s] %-52s -> %s (%s)" % ["OK" if ok else "SALAH", nama, g, Game.profil_teks(g)[0]])
	if not ok:
		gagal.append("gaya %s: %s, harusnya %s" % [nama, g, harap])


func _uji_aturan() -> void:
	print("--- TKP (bukti ada di sektor A, B, D; sektor C kosong)")
	var P := "penuh"
	var Z := "perbesar"
	_cek_tkp("langsung klik 3 bukti (menebak)", _klik([[0, 1, P], [1, 1, P], [3, 1, P]]), [], false, "tidak")
	_cek_tkp("per sektor, pindah begitu bukti ketemu", _klik([[0, 2, P], [1, 1, P], [2, 3, P], [3, 2, P]]), [], false, "manual")
	_cek_tkp("per sektor, semua benda diperiksa", _klik([[0, 6, P], [1, 6, P], [2, 6, P], [3, 1, P]]), [], false, "manual")
	_cek_tkp("sektor kosong ditinggal setelah 1 benda", _klik([[0, 3, P], [2, 1, P], [1, 3, P], [3, 2, P]]), [], false, "tidak")
	_cek_tkp("bolak-balik antar sektor", _klik([[0, 3, P], [1, 3, P], [0, 2, P], [3, 3, P]]), [], false, "tidak")
	_cek_tkp("GRID: perbesar A, B, D lalu periksa di dalamnya", _klik([[0, 1, Z], [1, 1, Z], [3, 1, Z]]), ["A", "B", "D"], true, "grid")
	_cek_tkp("GRID: perbesar tiap sektor, periksa semua", _klik([[0, 6, Z], [1, 6, Z], [2, 6, Z], [3, 1, Z]]), ["A", "B", "C", "D"], true, "grid")
	_cek_tkp("GRID ditekan saja, klik acak di tampilan penuh", _klik([[3, 1, P], [0, 1, P], [2, 1, P], [1, 1, P], [3, 1, P], [0, 1, P], [1, 1, P]]), [], true, "tidak")
	_cek_tkp("GRID: kembali ke sektor yang sudah ditinggal", _klik([[0, 2, Z], [1, 2, Z], [0, 2, Z], [3, 2, Z]]), ["A", "B", "A", "D"], true, "tidak")
	_cek_tkp("GRID: ada sektor diperbesar tanpa diperiksa", _klik([[0, 1, Z], [1, 1, Z], [3, 1, Z]]), ["A", "C", "B", "D"], true, "tidak")
	_cek_tkp("GRID sekali, sisanya rapi di tampilan penuh", _klik([[0, 3, Z], [1, 3, P], [2, 3, P], [3, 2, P]]), ["A"], true, "manual")
	print("--- Gaya dominan")
	_cek_gaya("semua 0/2", {}, "belum")
	_cek_gaya("semua 2/2", {"dekomposisi": 2, "pola": 2, "abstraksi": 2, "algoritma": 2}, "seimbang")
	_cek_gaya("tiga pilar seri", {"dekomposisi": 1, "pola": 1, "abstraksi": 1}, "seimbang")
	_cek_gaya("pola & abstraksi seri", {"pola": 2, "abstraksi": 2}, "pola+abstraksi")
	_cek_gaya("abstraksi & algoritma seri", {"abstraksi": 1, "algoritma": 1}, "abstraksi+algoritma")
	_cek_gaya("dekomposisi & algoritma seri", {"dekomposisi": 2, "algoritma": 2, "pola": 1}, "dekomposisi+algoritma")
	_cek_gaya("algoritma sendiri", {"algoritma": 2, "pola": 1}, "algoritma")
	print("--- Pembulatan persentase (81 kombinasi)")
	var hitung := {}
	for a in 3:
		for b in 3:
			for c in 3:
				for d in 3:
					var rk: Dictionary = Game.ringkas(_catatan({"dekomposisi": a, "pola": b, "abstraksi": c, "algoritma": d}))
					var pb: Dictionary = Game.bulatkan(Game.persentase_dari(rk))
					var total := 0
					for p in Game.PILAR:
						total += pb[p]
					if total != 100:
						gagal.append("total persen %d untuk %d%d%d%d" % [total, a, b, c, d])
					var g: String = Game.gaya_dari(rk)
					for p in Game.pilar_gaya(g):
						hitung[p] = hitung.get(p, 0) + 1
	print("  berapa kali tiap pilar menjadi (salah satu) gaya dominan: ", hitung)
	var nilai_set := {}
	for p in Game.PILAR:
		nilai_set[hitung.get(p, 0)] = true
	if nilai_set.size() != 1:
		gagal.append("gaya dominan masih berat sebelah: %s" % str(hitung))
	print("--- Alasan mengoreksi nilai")
	var r := {"pilar": "abstraksi", "berhasil": true, "jenis": "perilaku", "alasan": "dekat"}
	if Game.nilai_catatan(r) != Game.NILAI_KEBETULAN:
		gagal.append("alasan 'dekat' tidak mengoreksi nilai")
	r["alasan"] = "info"
	if Game.nilai_catatan(r) != 1.0:
		gagal.append("alasan 'info' seharusnya nilai penuh")
	r["alasan"] = ""
	if Game.nilai_catatan(r) != 1.0:
		gagal.append("tanpa alasan seharusnya nilai penuh")
	r["berhasil"] = false
	r["alasan"] = "info"
	if Game.nilai_catatan(r) != 0.0:
		gagal.append("perilaku tidak berhasil seharusnya 0 apa pun alasannya")
	if gagal.is_empty():
		print("=== AUTOTEST LULUS (aturan)")
		get_tree().quit(0)
	else:
		print("=== AUTOTEST GAGAL: ", gagal)
		get_tree().quit(1)


# ================================================================ uji masukan sungguhan
func _aksi(nama: String) -> void:
	var ev := InputEventAction.new()
	ev.action = nama
	ev.pressed = true
	Input.parse_input_event(ev)
	await _frames(2)
	var up := InputEventAction.new()
	up.action = nama
	up.pressed = false
	Input.parse_input_event(up)
	await _frames(2)


func _tunggu_pilihan(dlg) -> void:
	var t0 := Time.get_ticks_msec()
	while not dlg._memilih and Time.get_ticks_msec() - t0 < 5000:
		await get_tree().process_frame
	await get_tree().create_timer(0.4).timeout   # lewati jeda anti-salah-tekan


func _uji_tombol() -> void:
	Game.PROFIL_PATH = "user://profil_autotest.cfg"
	DirAccess.remove_absolute(ProjectSettings.globalize_path(Game.PROFIL_PATH))
	Game.ganti_pemain("Bot tombol")
	Game.mulai_level(0)
	var lv = await _level(0)
	var opsi := [["a", "Jawaban A"], ["b", "Jawaban B"], ["c", "Jawaban C"]]
	Game.autotest = false   # dialog tidak lagi maju sendiri: semua harus lewat masukan
	# ---- 1. keyboard: turun satu kali lalu E -> pilihan kedua yang tampil
	var hasil := {"kode": ""}
	var jalan := func(): hasil["kode"] = await lv.tanya_partner("uji1", "Uji keyboard?", opsi)
	jalan.call()
	await _tunggu_pilihan(lv.dialog)
	var kedua: String = lv.dialog._opsi[1]["label"].text
	await _aksi("gerak_bawah")
	await _aksi("interaksi")
	await _frames(4)
	print("  keyboard: tampil ke-2 = %s, terpilih = %s" % [kedua, hasil["kode"]])
	if hasil["kode"] == "" or not kedua.ends_with(hasil["kode"].to_upper()):
		gagal.append("pilihan lewat keyboard salah: %s vs %s" % [kedua, hasil["kode"]])
	# ---- 2. mouse: sorot lalu klik pilihan ketiga
	hasil["kode"] = ""
	var jalan2 := func(): hasil["kode"] = await lv.tanya_partner("uji2", "Uji mouse?", opsi)
	jalan2.call()
	await _tunggu_pilihan(lv.dialog)
	var ketiga: String = lv.dialog._opsi[2]["label"].text
	var pos: Vector2 = lv.dialog._opsi[2]["kotak"].get_global_rect().get_center()
	var mv := InputEventMouseMotion.new()
	mv.position = pos
	mv.global_position = pos
	Input.parse_input_event(mv)
	await _frames(3)
	if lv.dialog._pilih != 2:
		gagal.append("sorotan mouse tidak pindah ke pilihan ketiga")
	var mb := InputEventMouseButton.new()
	mb.position = pos
	mb.global_position = pos
	mb.button_index = MOUSE_BUTTON_LEFT
	mb.pressed = true
	Input.parse_input_event(mb)
	await _frames(4)
	print("  mouse   : tampil ke-3 = %s, terpilih = %s" % [ketiga, hasil["kode"]])
	if hasil["kode"] == "" or not ketiga.ends_with(hasil["kode"].to_upper()):
		gagal.append("pilihan lewat mouse salah: %s vs %s" % [ketiga, hasil["kode"]])
	# ---- 3. angka 1 -> pilihan pertama
	hasil["kode"] = ""
	var jalan3 := func(): hasil["kode"] = await lv.tanya_partner("uji3", "Uji angka?", opsi)
	jalan3.call()
	await _tunggu_pilihan(lv.dialog)
	var pertama: String = lv.dialog._opsi[0]["label"].text
	var k := InputEventKey.new()
	k.physical_keycode = KEY_1
	k.keycode = KEY_1
	k.pressed = true
	Input.parse_input_event(k)
	await _frames(4)
	print("  angka   : tampil ke-1 = %s, terpilih = %s" % [pertama, hasil["kode"]])
	if hasil["kode"] == "" or not pertama.ends_with(hasil["kode"].to_upper()):
		gagal.append("pilihan lewat angka salah: %s vs %s" % [pertama, hasil["kode"]])
	await _idle(lv)
	# ---- 4. partner mengikuti saat pemain berjalan sungguhan, dan tidak menghalangi
	var awal_pemain: Vector2 = lv.player.position
	var awal_partner: Vector2 = lv.partner.position
	lv.player.auto_dir = Vector2.UP
	for i in 70:
		await get_tree().physics_frame
	lv.player.auto_dir = Vector2.ZERO
	await _frames(30)
	var jalan_pemain: float = lv.player.position.distance_to(awal_pemain)
	var jarak: float = lv.partner.position.distance_to(lv.player.position)
	print("  partner : pemain berjalan %.0f px, partner berpindah %.0f px, jarak sekarang %.0f px" % [jalan_pemain, lv.partner.position.distance_to(awal_partner), jarak])
	if jalan_pemain < 40.0:
		gagal.append("pemain tidak bisa berjalan (terhalang?)")
	if jarak > 24.0 or jarak < 6.0:
		gagal.append("partner tidak mengikuti dengan jarak wajar (%.0f px)" % jarak)
	# ---- 5. berbalik menghadap partner -> ikon interaksi muncul pada partner, E = minta diingatkan tujuan
	lv.player.auto_dir = Vector2.DOWN
	for i in 3:
		await get_tree().physics_frame
	lv.player.auto_dir = Vector2.ZERO
	await _frames(6)
	var sasaran = lv.target
	print("  partner : sasaran interaksi saat menghadap partner = ", "-" if sasaran == null else sasaran["id"])
	if sasaran == null or sasaran["id"] != "kiki":
		gagal.append("partner tidak bisa disapa saat pemain menghadapnya")
	else:
		Game.autotest = true
		await _aksi("interaksi")
		await _idle(lv)
		if int(Game.bantuan.get(1, 0)) != 1:
			gagal.append("sapaan ke partner tidak tercatat (bantuan=%s)" % str(Game.bantuan))
	Game.autotest = true
	if gagal.is_empty():
		print("=== AUTOTEST LULUS (tombol)")
		get_tree().quit(0)
	else:
		print("=== AUTOTEST GAGAL: ", gagal)
		get_tree().quit(1)
