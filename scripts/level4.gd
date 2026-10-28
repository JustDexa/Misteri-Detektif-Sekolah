extends "res://scripts/level_base.gd"
## LEVEL 4 — MUSEUM KOTA (klimaks). Kasus: kemoceng museum hilang.
## Diukur berurutan, satu aksi satu pilar:
##   1. POLA uji 2     : NPC pertama setelah kasus (benar bila Kak Arga, berkacamata)
##   2. ABSTRAKSI      : setelah cerita Kak Arga, lokasi pertama di antara suvenir / kafe / pos satpam
##   3. ALGORITMA      : instruksi Pak Satpam ruang fosil -> ruang batik -> gudang
##   4. DEKOMPOSISI 2  : TKP gudang museum

const PENGECOH := {
	"pemandu": "Selamat datang! Rombongan saya sedang melihat koleksi. Kemoceng? Kakak nggak tahu, maaf ya.",
	"pengunjung": "Batik di sini indah sekali. Kemoceng? Ibu nggak lihat, Nak.",
	"anak_rombongan": "Aku lagi study tour! Tadi aku lihat fosil dinosaurus, besar sekali! Kemoceng? Nggak tahu, deh.",
}


func _init() -> void:
	AMBIENT = "sinar"
	MAP = "museum"
	BGM = "bgm_museum"
	KARTU = "ui_g_kartu_level_4_museum.png"
	ZONE_NAMA = {"suvenir": "Toko Suvenir", "kafe": "Kafe Museum", "pos_satpam": "Pos Satpam", "fosil": "Ruang Fosil", "batik": "Ruang Batik"}
	INSPEK = {
		"fosil": "Kerangka fosil dinosaurus. Besar dan mengagumkan!",
		"vitrin_fosil": "Vitrin berisi batu-batuan purba. Kacanya sedikit berdebu.",
		"batik": "Koleksi kain batik dari berbagai daerah di Indonesia.",
		"rak_suvenir": "Rak suvenir: gantungan kunci, pin, dan miniatur fosil.",
		"meja_kafe": "Meja kafe museum. Wangi roti bakar tercium.",
		"pos_satpam_meja": "Meja pos satpam. Ada layar kamera pengawas.",
	}


func _mulai() -> void:
	await say([["", "Museum Kota, siang hari. Pak Hadi, kurator museum, sudah menunggumu di lobi."]])
	set_objective("Temui Pak Hadi di lobi museum")


func _on_interact(id: String, _kind: String) -> void:
	var mulai: bool = flags.get("mulai", false)
	var arga: bool = flags.get("arga", false)
	var rute: bool = flags.get("rute", false)
	if PENGECOH.has(id):
		var lines := [[id, PENGECOH[id]]]
		if not mulai:
			lines = [[id, "Halo! Selamat menikmati museum, ya."]]
		elif not arga:
			var ditanya: Array = flags.get("ditanya", [])
			if not id in ditanya:
				ditanya.append(id)
			flags["ditanya"] = ditanya
			if ditanya.size() >= 3:
				lines.append([id, "Oh iya, tadi ada kakak yang sering membantu di museum. Dia ada di lobi."])
		await say(lines)
		return
	match id:
		"pak_hadi":
			if not mulai:
				await say([
					["pak_hadi", "Selamat datang, Detektif. Saya Pak Hadi, kurator museum ini."],
					["pak_hadi", "Kemoceng untuk membersihkan vitrin hilang! Sore ini rombongan sekolah akan datang."],
					["pak_hadi", "Silakan tanya pengunjung dan petugas di sini. Saya yakin ada yang tahu."],
				])
				flags["mulai"] = true
				set_objective("Cari orang yang tahu soal kemoceng")
				ukur_npc_pertama("pola", "arga", ["pak_hadi"], "Museum")
			elif flags.get("kemoceng", false):
				await say([["pak_hadi", "Luar biasa, Detektif!"]])
			else:
				await say([["pak_hadi", "Silakan tanya pengunjung dan petugas museum, ya."]])
		"arga":
			if not mulai:
				await say([["arga", "Halo! Aku Arga. Lagi lihat-lihat museum."]])
			elif not arga:
				# ---- DIALOG ABSTRAKSI: 1 info penting (pos satpam) di antara basa-basi (suvenir, kafe)
				await say([
					["arga", "Wah, kamu detektif yang terkenal itu, ya? Aku Arga, sering membantu di museum ini."],
					["arga", "Tadi aku mampir ke toko suvenir. Ada gantungan kunci dinosaurus, lucu sekali!"],
					["arga", "Kafe museum juga baru buka. Wangi roti bakarnya sampai ke lobi."],
					["arga", "Soal kemoceng... Pak Satpam yang memegang kunci gudang. Coba tanya beliau di pos satpam dekat pintu gudang."],
					["arga", "Oh iya, gantungan kunci di toko suvenir tinggal sedikit, lho. Kafenya juga ramai siang ini."],
				])
				flags["arga"] = true
				set_objective("Cari kemoceng yang hilang")
				ukur_lokasi_pertama("abstraksi", ["suvenir", "kafe", "pos_satpam"], "pos_satpam", "Cerita Kak Arga")
			else:
				await say([["arga", "Suvenir, kafe, Pak Satpam di pos satpam... Museum ini seru, kan?"]])
		"satpam":
			if not arga:
				await say([["satpam", "Selamat siang, Dik. Bapak sedang berjaga. Kemoceng? Coba tanya pengunjung lain dulu, ya."]])
			elif not rute:
				# ---- INSTRUKSI ALGORITMA
				await say([
					["satpam", "Kemoceng? Mungkin ada di gudang. Pintunya tidak Bapak kunci, kok."],
					["satpam", "Tapi sebelum ke gudang, tolong cek dulu ruang fosil, lalu ruang batik. Tadi Bapak lihat ada jejak debu di sana."],
					["satpam", "Ingat: ruang fosil dulu, lalu ruang batik, baru gudang."],
				])
				flags["rute"] = true
				set_objective("Ikuti petunjuk Pak Satpam")
				ukur_urutan("algoritma", ["fosil", "batik", "gudang"], "Rute Pak Satpam")
			else:
				await say([["satpam", "Ruang fosil dulu, lalu ruang batik, baru gudang."]])
		"gudang_museum_pintu":
			if not rute:
				await say([["", "Pintu gudang. Tertulis: \"Khusus petugas.\" Sebaiknya kamu bertanya kepada petugas dulu."]])
				return
			kunjungi("gudang")
			await _masuk_tkp()
		_:
			await inspek(id)


func _on_zone_enter(id: String) -> void:
	if not flags.get("rute", false):
		return
	if id == "fosil" and not flags.get("lihat_fosil", false):
		flags["lihat_fosil"] = true
		await say([["", "Di ruang fosil ada jejak sepatu berdebu yang mengarah keluar ruangan."]])
	elif id == "batik" and not flags.get("lihat_batik", false):
		flags["lihat_batik"] = true
		await say([["", "Di ruang batik ada bekas kain lap dan jejak debu menuju lorong."]])


func _masuk_tkp() -> void:
	if not Game.grid_tutorial_seen:
		Game.grid_tutorial_seen = true
		await say([
			["", "Klik benda untuk memeriksanya. Tombol GRID membagi layar menjadi 4 sektor: A, B, C, dan D. Saat GRID menyala, klik sebuah sektor untuk memperbesarnya."],
			["", "Tombol GRID boleh dipakai, boleh juga tidak. Cari dengan caramu sendiri!"],
		])
	var lengkap: bool = await buka_tkp("gudang_museum")
	if lengkap:
		flags["kemoceng"] = true
		await say([
			["pemain:senang", "Kemoceng museum ketemu! Dan ini sobekan poster yang terakhir!"],
			["", "Ada juga catatan: \"Minggu pagi, kumpul di taman. Bawa sapu, selang, ember, kemoceng!\""],
			["pemain", "Sekarang semua petunjuk sudah lengkap. Saatnya menyusun poster!"],
		])
		await selesai_level()
	else:
		await say([["", "Kamu keluar dari gudang. Bukti yang sudah ditemukan tetap tersimpan."]])
