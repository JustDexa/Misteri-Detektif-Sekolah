extends "res://scripts/level_base.gd"
## LEVEL 3 — PASAR RAKYAT. Kasus: ember Bu Sri hilang.
## Diukur: POLA uji 1 (NPC pertama yang didatangi setelah kasus: benar bila Tari, NPC berkacamata)
##         DEKOMPOSISI 1 (TKP kios ikan, Mode Grid).

const PENGECOH := {
	"pedagang_buah": "Ember? Wah, Bapak dari tadi sibuk menimbang jeruk. Nggak lihat, Dik.",
	"ibu_pembeli": "Ibu baru datang mau beli bawang. Ember biru? Nggak tahu, Dik.",
	"anak_pedagang": "Aku bantu ibuku jualan dari subuh. Ember biru? Nggak lihat, tuh.",
	"tukang_becak": "Becak Bapak siap antar ke mana saja! Ember? Bapak nggak perhatikan, Dik.",
}


func _init() -> void:
	AMBIENT = "debu"
	MAP = "pasar"
	BGM = "bgm_pasar"
	KARTU = "ui_g_kartu_level_3_pasar.png"
	ZONE_NAMA = {}
	INSPEK = {}


func _mulai() -> void:
	await say([["", "Pagi yang ramai di Pasar Rakyat. Bu Sri, pedagang sayur, melambaikan tangan ke arahmu."]])
	set_objective("Temui Bu Sri, pedagang sayur")


func _on_interact(id: String, _kind: String) -> void:
	var mulai: bool = flags.get("mulai", false)
	if PENGECOH.has(id):
		var lines := [[id, PENGECOH[id]]]
		if mulai and not flags.get("tari", false):
			var ditanya: Array = flags.get("ditanya", [])
			if not id in ditanya:
				ditanya.append(id)
			flags["ditanya"] = ditanya
			if ditanya.size() >= 3:
				lines.append([id, "Hmm, tadi ada anak perempuan dekat kios kain. Mungkin dia tahu sesuatu."])
		elif not mulai:
			lines = [[id, "Selamat pagi! Pasar sedang ramai, ya."]]
		await say(lines)
		return
	match id:
		"bu_sri":
			if not mulai:
				await say([
					["bu_sri", "Aduh, Dik Detektif! Ember biru Ibu hilang!"],
					["bu_sri", "Padahal ember itu untuk mencuci sayur. Pasar seramai ini, pasti ada yang melihat."],
					["bu_sri", "Coba tanya orang-orang di pasar, ya."],
				])
				flags["mulai"] = true
				set_objective("Cari orang yang melihat ember Bu Sri")
				ukur_npc_pertama("pola", "tari", ["bu_sri"], "Pasar")
			elif flags.get("ember", false):
				await say([["bu_sri:senang", "Ember Ibu kembali! Terima kasih, Detektif!"]])
			else:
				await say([["bu_sri", "Coba tanya orang-orang di pasar, ya. Pasti ada yang melihat."]])
		"tari":
			if not mulai:
				await say([["tari", "Halo! Aku lagi belanja titipan ibuku."]])
			elif not flags.get("tari", false):
				await say([
					["tari", "Ember biru? Aku lihat! Tadi dibawa masuk ke kios ikan di pojok kanan atas."],
					["tari", "Tapi hati-hati, di dalam berantakan sekali. Kamu harus teliti mencarinya!"],
				])
				flags["tari"] = true
				set_objective("Periksa kios ikan di pojok kanan atas")
			else:
				await say([["tari", "Kios ikan ada di pojok kanan atas pasar."]])
		"kios_ikan_pintu":
			if not flags.get("tari", false):
				await say([["", "Kios ikan. Pintunya setengah terbuka. Kamu belum punya alasan untuk masuk."]])
				return
			await _masuk_tkp()
		_:
			await inspek(id)


func _masuk_tkp() -> void:
	if not Game.grid_tutorial_seen:
		Game.grid_tutorial_seen = true
		await say([
			["", "Kamu akan memeriksa tempat kejadian dari dekat. Tempatnya berantakan, banyak benda kecil. Klik benda untuk memeriksanya."],
			["", "Di pojok kanan atas ada tombol GRID. Tombol itu membagi layar menjadi 4 sektor: A, B, C, dan D. Saat GRID menyala, klik sebuah sektor untuk memperbesarnya."],
			["", "Tombol GRID boleh dipakai, boleh juga tidak. Cari dengan caramu sendiri!"],
		])
	var lengkap: bool = await buka_tkp("kios_ikan")
	if lengkap:
		flags["ember"] = true
		await say([
			["pemain:senang", "Ember biru Bu Sri ketemu!"],
			["", "Ada juga sobekan poster ketiga dan struk pembelian 20 kantong sampah."],
			["pemain", "Sapu, selang, ember, kantong sampah... Sepertinya ada yang sedang menyiapkan sesuatu."],
		])
		await selesai_level()
	else:
		await say([["", "Kamu keluar dari kios ikan. Bukti yang sudah ditemukan tetap tersimpan."]])
