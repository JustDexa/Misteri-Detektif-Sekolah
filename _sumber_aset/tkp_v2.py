"""TKP v2: lebih banyak benda (kecil & tersamar), koordinat layar penuh 320x180.
Benda ditampilkan 16px di tampilan penuh dan 32px saat sektor diperbesar."""
import json, os
from pix import *


def _o(c):
    c.outline(P['black']); return c


def d_botol():
    c = Canvas(16, 16)
    c.rect(6, 1, 4, 3, P['grey_l']); c.rect(5, 4, 6, 10, P['cyan']); c.rect(5, 8, 6, 3, P['white'])
    c.vline(10, 4, 13, P['blue']); c.px(6, 5, P['white']); return _o(c)


def d_kertas():
    c = Canvas(16, 16)
    c.ellipse(8, 8, 5, 4, P['white']); c.px(6, 7, P['grey_l']); c.px(9, 9, P['grey_l']); c.px(10, 6, P['grey'])
    c.line(4, 9, 7, 6, P['grey_l']); return _o(c)


def d_tali():
    c = Canvas(16, 16)
    for r, col in ((6, 'gold'), (4, 'orange'), (2, 'gold')):
        c.ellipse(8, 8, r, r - 1, P[col])
    c.ellipse(8, 8, 1, 1, T); c.line(13, 9, 15, 13, P['gold']); return _o(c)


def d_lap():
    c = Canvas(16, 16)
    c.rect(2, 5, 12, 8, P['grey']); c.rect(3, 6, 10, 2, P['grey_l'])
    c.px(5, 10, P['brown']); c.px(9, 11, P['brown']); c.px(11, 9, P['grey_d']); return _o(c)


NEW = dict(botol=d_botol, kertas=d_kertas, tali=d_tali, lap=d_lap)

# [jenis, x, y] koordinat kiri-atas pada layar 320x180. Sektor: A kiri-atas, B kanan-atas, C kiri-bawah, D kanan-bawah.
# HUD dihindari: tombol keluar (kiri atas), tombol grid + penghitung (kanan atas).
LAYOUT = {
    'kios_ikan': dict(found=['poster3', 'struk', 'ember'], objects=[
        # A — rak kiri
        ['koran', 52, 30], ['kaleng', 62, 50], ['poster3', 34, 62], ['botol', 70, 64], ['jaring', 118, 8], ['kertas', 100, 44],
        # B — kotak styrofoam putih (struk putih tersamar di antara kotak)
        ['kardus', 196, 34], ['kaleng', 176, 60], ['tali', 226, 56], ['struk', 258, 70], ['kertas', 214, 14], ['botol', 238, 30],
        # C — lantai kiri & meja kiri
        ['kardus', 10, 118], ['sandal', 42, 140], ['lap', 76, 118], ['koran', 108, 130], ['botol', 134, 108], ['tali', 24, 158],
        # D — meja kanan (ember biru tersamar di depan meja biru) & lantai kanan
        ['ember', 184, 100], ['sarung', 276, 140], ['jaring', 236, 122], ['sandal', 298, 112], ['kardus', 168, 128], ['kaleng', 264, 158],
    ]),
    'gudang_museum': dict(found=['kemoceng', 'poster4', 'catatan'], objects=[
        # A — rak kiri
        ['arsip', 16, 54], ['bingkai', 104, 30], ['kertas', 60, 72], ['botol', 128, 62], ['kain', 48, 22], ['tali', 84, 50],
        # B — rak kanan (kemoceng merah di antara kotak coklat)
        ['kemoceng', 240, 56], ['kain', 196, 28], ['arsip', 256, 72], ['kertas', 176, 46], ['lampu', 212, 72], ['botol', 260, 18],
        # C — lantai kiri (sobekan poster di antara kertas)
        ['poster4', 70, 136], ['kertas', 50, 120], ['karpet', 8, 150], ['lap', 118, 118], ['kardus', 24, 106], ['koran', 140, 132],
        # D — lantai kanan (catatan kuning dekat lampu kuning)
        ['catatan', 250, 138], ['lampu', 228, 124], ['tangga', 290, 118], ['kardus', 180, 140], ['kain', 300, 156], ['botol', 210, 112],
    ]),
}


def build(assets_dir):
    for k, fn in NEW.items():
        fn().save(os.path.join(assets_dir, 'items', f'x_{k}.png'))
    json.dump(LAYOUT, open(os.path.join(assets_dir, 'tkp', 'tkp.json'), 'w'), indent=1)
    # cek sebaran per sektor
    for t, d in LAYOUT.items():
        cnt = [0, 0, 0, 0]
        for typ, x, y in d['objects']:
            cx, cy = x + 8, y + 8
            cnt[(1 if cx >= 160 else 0) + (2 if cy >= 90 else 0)] += 1
        print(t, 'benda per sektor A/B/C/D =', cnt)


if __name__ == '__main__':
    build('game/assets')
