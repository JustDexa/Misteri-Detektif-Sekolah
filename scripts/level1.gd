extends "res://scripts/level_base.gd"
## LEVEL 1 — SEKOLAH (termasuk prolog/tutorial). Kasus: sapu kelas hilang.
## Diukur: ABSTRAKSI (cerita panjang Pak Joko: 1 info penting = gudang belakang, 2 basa-basi = parkiran & kantin).
## Fase belajar POLA: yang tahu petunjuk adalah NPC berkacamata (Nisa) — belum dinilai.


func _init() -> void:
	AMBIENT = "debu"
	MAP = "sekolah"
	BGM = "bgm_sekolah"
	KARTU = "ui_g_kartu_level_1_sekolah.png"
	ZONE_NAMA = {"parkiran": "Parkiran", "kantin": "Kantin", "gudang": "Gudang Belakang"}
	INSPEK = {
		"lemari_piala": "Lemari piala sekolah. Ada piala Juara 1 Lomba Kebersihan tahun lalu!",
		"papan_pengumuman": "Papan pengumuman: \"Lomba Kebersihan Kelas, BESOK PAGI! Siapkan alat kebersihan masing-masing.\"",
		"etalase": "Etalase kantin. Hari ini ada nasi kuning, gorengan, dan es teh.",
		"tiang_bendera": "Tiang bendera. Sang Merah Putih berkibar gagah ditiup angin.",
		"motor": "Motor-motor guru terparkir rapi.",
		"kucing": "Meong! Seekor kucing oranye sedang tidur nyenyak.",
		"gudang_pintu": "Pintu gudang belakang. Terkunci rapat.",
	}


func _mulai() -> void:
	await say([
		["", "Pagi hari di SD Tunas Bangsa. Kamu dikenal sebagai detektif cilik paling teliti di sekolah."],
		["", "Gunakan tombol W A S D atau tombol panah untuk berjalan."],
		["", "Dekati seseorang atau benda sampai muncul ikon kaca pembesar, lalu tekan E (atau Spasi) untuk berbicara dan memeriksa."],
		["", "Tekan TAB untuk membuka Buku Catatan Detektif. Tekan ESC untuk jeda."],
		["", "Ayo mulai! Sapa Bu Rina, wali kelasmu."],
	])
	set_objective("Sapa Bu Rina, wali kelasmu")
	tunjuk("bu_rina")


func _on_interact(id: String, kind: String) -> void:
	var mulai: bool = flags.get("mulai", false)
	match id:
		"bu_rina":
			if not mulai:
				tunjuk("")
				await say([
					["bu_rina", "Selamat pagi, {nama}! Untung kamu datang."],
					["bu_rina", "Besok ada Lomba Kebersihan Kelas, tapi sapu kelas kita hilang!"],
					["bu_rina", "Padahal tadi pagi masih ada. Coba tanya-tanya teman dan warga sekolah, ya. Siapa tahu ada yang melihat."],
					["pemain", "Siap, Bu! Serahkan pada Detektif!"],
				])
				flags["mulai"] = true
				set_objective("Cari tahu siapa yang tahu soal sapu kelas")
			elif flags.get("sapu", false):
				await say([["bu_rina:senang", "Terima kasih, Detektif! Kelas kita siap ikut lomba besok."]])
			else:
				await say([["bu_rina", "Bagaimana, sudah ada petunjuk? Coba tanya teman-teman di kelas dan di halaman."]])
		"dodi":
			if not mulai:
				await say([["dodi", "Hai! Aku lagi nunggu bel masuk. Eh, Bu Rina tadi mencarimu, lho."]])
			else:
				await say([
					["dodi", "Sapu kelas? Wah, aku nggak lihat."],
					["dodi", "Tapi tadi pagi Nisa yang piket. Coba tanya dia di Kelas A."],
				])
		"nisa":
			if not mulai:
				await say([["nisa", "Halo! Aku lagi baca buku sebelum masuk kelas."]])
			elif not flags.get("nisa", false):
				await say([
					["nisa", "Sapu kelas? Hmm... waktu aku piket tadi pagi, sapunya masih ada di pojok kelas."],
					["nisa", "Tapi Pak Joko, penjaga sekolah, dari pagi sudah keliling sekolah. Pasti beliau melihat sesuatu!"],
					["nisa", "Pak Joko biasanya ada di halaman, dekat tiang bendera."],
				])
				flags["nisa"] = true
				set_objective("Tanya Pak Joko di halaman sekolah")
			else:
				await say([["nisa", "Semoga sapunya cepat ketemu, ya! Pak Joko ada di halaman."]])
		"pak_joko":
			if not mulai:
				await say([["pak_joko", "Pagi, Nak! Bapak lagi menyiram tanaman. Semangat belajarnya, ya!"]])
			elif not flags.get("nisa", false):
				await say([
					["pak_joko", "Sapu kelas? Waduh, Bapak lupa-lupa ingat..."],
					["pak_joko", "Coba tanya dulu anak yang piket tadi pagi. Nanti Bapak ingat-ingat lagi."],
				])
			elif not flags.get("joko", false):
				# ---- DIALOG ABSTRAKSI: 1 info penting di antara basa-basi (tanpa penekanan apa pun)
				await say([
					["pak_joko", "Oh, sapu kelas? Wah, Nak, pagi ini Bapak sibuk sekali."],
					["pak_joko", "Tadi Bapak lihat ada kucing oranye tidur di dekat motor di parkiran. Lucu sekali, sampai Bapak elus-elus."],
					["pak_joko", "Terus Ibu kantin bilang hari ini ada nasi kuning. Bapak jadi lapar terus dari tadi."],
					["pak_joko", "Oh iya, tadi pagi Bapak juga lihat ada anak membawa sapu ke arah gudang belakang."],
					["pak_joko", "Ngomong-ngomong, kucingnya mungkin masih di parkiran, lho. Nasi kuningnya juga masih banyak di kantin."],
				])
				flags["joko"] = true
				set_objective("Cari sapu kelas yang hilang")
				ukur_lokasi_pertama("abstraksi", ["parkiran", "kantin", "gudang"], "gudang", "Cerita Pak Joko")
			else:
				await say([["pak_joko", "Kucing oranye, nasi kuning, anak bawa sapu ke gudang belakang... Pagi yang ramai, Nak!"]])
		"item_sapu":
			ambil("item_sapu")
			if not Game.has_item("poster1"):
				ambil("item_poster1")
			flags["sapu"] = true
			await say([
				["pemain:senang", "Ketemu! Sapu kelas ada di sini."],
				["", "Di dekat sapu ada sobekan poster berwarna hijau. Kamu menyimpannya di Buku Catatan."],
				["pemain", "Siapa yang menaruh sapu di sini, ya? Sepertinya ini baru awal dari sebuah misteri..."],
			])
			await selesai_level()
		"item_poster1":
			ambil("item_poster1")
			await say([["", "Sobekan poster berwarna hijau. Sepertinya bagian dari poster yang lebih besar."]])
		"item_jejak":
			ambil("item_jejak")
			await say([["", "Jejak sepatu berlumpur. Ukurannya kecil, seperti sepatu anak-anak."]])
		_:
			await inspek(id)


func _on_zone_enter(id: String) -> void:
	if id == "gudang" and flags.get("joko", false) and not flags.get("lihat_gudang", false):
		flags["lihat_gudang"] = true
		reveal("item_sapu")
		reveal("item_poster1")
		reveal("item_jejak")
		await say([["pemain", "Hmm, ada sesuatu yang berkilau di dekat gudang. Ayo periksa!"]])
