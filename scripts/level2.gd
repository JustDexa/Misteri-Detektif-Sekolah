extends "res://scripts/level_base.gd"
## LEVEL 2 — TAMAN KOTA. Kasus: selang penyiram hilang.
## Diukur: ALGORITMA (instruksi Bu Wati: parkiran -> air mancur -> gazebo; gazebo sengaja paling dekat).
## Fase belajar POLA kedua: yang tahu letak selang adalah NPC berkacamata (Bima) — belum dinilai.


func _init() -> void:
	AMBIENT = "daun"
	MAP = "taman"
	BGM = "bgm_taman"
	KARTU = "ui_g_kartu_level_2_taman.png"
	ZONE_NAMA = {"parkir": "Parkiran", "air_mancur": "Air Mancur", "gazebo": "Gazebo"}
	INSPEK = {
		"air_mancur": "Air mancur Taman Kota. Airnya jernih dan sejuk.",
	}


func _mulai() -> void:
	await say([["", "Sore hari di Taman Kota. Pak Harun, petugas taman, tampak kebingungan."]])
	set_objective("Temui Pak Harun, petugas taman")


func _on_interact(id: String, _kind: String) -> void:
	var mulai: bool = flags.get("mulai", false)
	var rute: bool = flags.get("rute", false)
	match id:
		"pak_harun":
			if not mulai:
				await say([
					["pak_harun", "Oh, kamu detektif yang menemukan sapu sekolah itu, ya? Bu Rina sudah cerita."],
					["pak_harun", "Selang penyiram taman hilang! Padahal tanaman harus disiram sore ini."],
					["pak_harun", "Bu Wati yang berjualan es di dekat gerbang sudah di sini dari pagi. Mungkin dia melihat sesuatu."],
				])
				flags["mulai"] = true
				set_objective("Tanya Bu Wati, penjual es")
			elif flags.get("selang", false):
				await say([["pak_harun", "Terima kasih, Detektif! Tanaman taman bisa disiram lagi."]])
			else:
				await say([["pak_harun", "Bu Wati penjual es ada di dekat gerbang. Coba tanya dia, ya."]])
		"bu_wati":
			if not mulai:
				await say([["bu_wati", "Es-nya segar, Dik! Eh, kamu dicari Pak Harun, tuh."]])
			elif not rute:
				# ---- INSTRUKSI ALGORITMA
				await say([
					["bu_wati", "Selang hijau? Ibu nggak lihat sendiri, Dik. Dari tadi Ibu sibuk melayani pembeli."],
					["bu_wati", "Tapi coba begini: tanya dulu Mas Parkir di parkiran, lalu periksa air mancur, setelah itu baru ke gazebo."],
					["bu_wati", "Ingat ya urutannya: Mas Parkir dulu, lalu air mancur, baru gazebo!"],
				])
				flags["rute"] = true
				set_objective("Ikuti saran Bu Wati")
				ukur_urutan("algoritma", ["parkir", "air_mancur", "gazebo"], "Rute Bu Wati")
				reveal("item_daftar")
			else:
				await say([["bu_wati", "Mas Parkir dulu, lalu air mancur, baru gazebo. Semangat, Dik!"]])
		"mas_parkir":
			if rute:
				await say([["mas_parkir", "Selang hijau? Iya, tadi ada anak lewat membawa gulungan selang ke arah air mancur."]])
			else:
				await say([["mas_parkir", "Parkir di sini aman, Dik. Ada perlu apa?"]])
		"anak_layangan":
			await say([["anak_layangan", "Lihat, layanganku paling tinggi! Selang? Aku dari tadi lihat ke langit terus, hehe."]])
		"bima":
			if not rute:
				await say([
					["bima", "Halo! Aku lagi baca buku di gazebo. Ada apa?"],
					["bima", "Selang? Hmm, coba tanya Bu Wati dulu. Dia tahu siapa saja yang lewat sini."],
				])
			elif not flags.get("bima", false):
				await say([
					["bima", "Eh, Detektif! Selang hijau, ya?"],
					["bima", "Aku lihat tadi ditaruh di belakang gazebo, dekat pagar."],
				])
				flags["bima"] = true
				reveal("item_selang")
				reveal("item_poster2")
				set_objective("Ambil selang di belakang gazebo")
			else:
				await say([["bima", "Selangnya di belakang gazebo, dekat pagar."]])
		"item_daftar":
			ambil("item_daftar")
			await say([["", "Selembar daftar alat: \"Sapu - sudah. Selang - sudah. Ember - belum. Kemoceng - belum.\" Milik siapa ini?"]])
		"item_poster2":
			ambil("item_poster2")
			await say([["", "Sobekan poster lagi! Warnanya sama dengan sobekan dari sekolah."]])
		"item_selang":
			ambil("item_selang")
			if not Game.has_item("poster2"):
				ambil("item_poster2")
			flags["selang"] = true
			await say([
				["pemain:senang", "Selang penyiram ketemu!"],
				["", "Di dekatnya ada sobekan poster lagi. Warnanya sama dengan sobekan dari sekolah."],
				["pemain", "Sapu dan selang sama-sama hilang... Apa ini perbuatan orang yang sama?"],
			])
			await selesai_level()
		_:
			await inspek(id)

func _dekor() -> void:
	FX.fountain(self, Vector2(232, 37))
