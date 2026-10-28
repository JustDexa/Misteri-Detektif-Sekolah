"""Build every asset straight into the Godot project folder game/assets."""
import os, shutil, json
from pix import *
import chars, art2, levels, audio

G = 'game'
A = os.path.join(G, 'assets')
SUB = ['menu', 'chars', 'maps', 'items', 'tkp', 'ui', 'rapor', 'ending', 'audio', 'font']
for s in SUB:
    os.makedirs(os.path.join(A, s), exist_ok=True)
J = lambda *p: os.path.join(A, *p)

# ---------------------------------------------------------------- menu (copy from menu asset pack)
MENU = 'Aset_Menu_Misteri_Detektif'
for root, _, files in os.walk(MENU):
    if '_preview' in root or 'template' in root or 'font' in root:
        continue
    for f in files:
        if f.endswith('.png'):
            shutil.copy(os.path.join(root, f), J('menu', f))
shutil.copy(os.path.join(MENU, 'ikon', 'ui_g_icon_256.png'), os.path.join(G, 'icon.png'))

# ---------------------------------------------------------------- characters
chars.player_sheet().save(J('chars', 'pemain.png'))
for nid, p in chars.NPCS.items():
    sh = Canvas(32, 24)
    sh.paste(chars.npc_sprite(p, 0), 0, 0); sh.paste(chars.npc_sprite(p, 1), 16, 0)
    sh.save(J('chars', f'npc_{nid}.png'))
    chars.portrait(p).save(J('chars', f'por_{nid}.png'))
    chars.portrait(p, 'senang').save(J('chars', f'por_{nid}_senang.png'))
chars.portrait(chars.PLAYER_P, player=True).save(J('chars', 'por_pemain.png'))
chars.portrait(chars.PLAYER_P, 'senang', player=True).save(J('chars', 'por_pemain_senang.png'))
npc_meta = {nid: dict(name=p['name'], ciri=('kacamata' if 'kacamata' in p['acc'] else
                                            'topi' if ('topi' in p['acc'] or 'caping' in p['acc']) else
                                            'tas' if 'tas' in p['acc'] else
                                            'kuncir' if 'kuncir' in p['acc'] else
                                            'kerudung' if 'kerudung' in p['acc'] else 'lain'))
            for nid, p in chars.NPCS.items()}
json.dump(npc_meta, open(J('chars', 'npc.json'), 'w'), indent=1)

# ---------------------------------------------------------------- maps
for f in (levels.level1, levels.level2, levels.level3, levels.level4):
    m = f(); m.save(J('maps'))
    mini = m.base.img().resize((60, 36), Image.BOX)
    mini.save(J('maps', f'{m.name}_mini.png'))

# ---------------------------------------------------------------- items
for k, fn in art2.ITEMS.items():
    fn().save(J('items', f'{k}.png'))
for k, fn in art2.DISTRACT.items():
    fn().save(J('items', f'x_{k}.png'))

# ---------------------------------------------------------------- tkp
tkp_meta = {}
for k, d in art2.TKP.items():
    d['bg']().save(J('tkp', f'{k}.png'))
    tkp_meta[k] = dict(found=d['found'], objects=[[o, x, y] for o, x, y in d['objects']])
json.dump(tkp_meta, open(J('tkp', 'tkp.json'), 'w'), indent=1)

# ---------------------------------------------------------------- ui
art2.ui_assets(J('ui'))
# tutorial arrow (2 frames 12x10)
ar = Canvas(24, 10)
for f in range(2):
    for i in range(5):
        ar.hline(f * 12 + 1 + i, f * 12 + 10 - i, 1 + i + f * 2, P['yellow'])
ar.outline(P['black'])
ar.save(J('ui', 'panah.png'))
# banner for objective (9-slice 16x16, margin 4)
bn = Canvas(16, 16)
bn.rect(1, 0, 14, 16, P['black']); bn.rect(0, 1, 16, 14, P['black']); bn.rect(1, 1, 14, 14, P['navy'])
bn.hline(1, 14, 1, P['navy_l']); bn.vline(1, 2, 13, P['gold'])
bn.save(J('ui', 'banner.png'))
# minimap frame 64x40
mf = Canvas(64, 40)
mf.rect(0, 0, 64, 40, P['black']); mf.rect(1, 1, 62, 38, P['brown_d']); mf.rect(2, 2, 60, 36, T)
mf.save(J('ui', 'minimap_bingkai.png'))
# toast panel
frame = art2.frame9(16, 16, 'cream', 'rust', 'tan'); frame.save(J('ui', 'kotak_krem.png'))

# ---------------------------------------------------------------- rapor + ending
art2.rapor_bg().save(J('rapor', 'rapor_bg.png'))
art2.stempel().save(J('rapor', 'stempel.png'))
for k in art2.PILAR:
    art2.ikon_pilar(k).save(J('rapor', f'ikon_{k}.png'))
    art2.lencana(k).save(J('rapor', f'lencana_{k}.png'))
art2.ending().save(J('ending', 'ending.png'))
ps = art2.poster(); ps.save(J('ending', 'poster.png'))
for i, (x, y) in enumerate([(0, 0), (64, 0), (0, 80), (64, 80)]):
    crop(ps, x, y, x + 63, y + 79).save(J('ending', f'poster_{i + 1}.png'))

# ---------------------------------------------------------------- font + audio
art2.export_font(J('font'))
if not os.path.exists(J('audio', 'bgm_menu.wav')) or os.environ.get('AUDIO'):
    audio.build(J('audio'))
print('assets ok')

# extra buttons used in-game
from ui import button as _btn
for key, lab, th, w, h in [('menu', 'MENU', 'merah', 56, 20), ('mulai', 'MULAI', 'kuning', 72, 20)]:
    for st in ('normal', 'hover', 'pressed'):
        _btn(w, h, lab, th, st).save(J('menu', f'ui_g_btn_{key}_{st}.png'))

# ---- revisi v1.1: tombol kecil, kartu pilih level, ikon gembok & centang
for key, lab, th, w, h in [('ganti', 'GANTI', 'krem', 40, 15), ('simpan', 'SIMPAN', 'kuning', 72, 20),
                           ('rapor', 'RAPOR', 'biru', 56, 20)]:
    for st in ('normal', 'hover', 'pressed'):
        _btn(w, h, lab, th, st).save(J('menu', f'ui_g_btn_{key}_{st}.png'))
for name, face, edge, hi in [('normal', 'navy', 'gold', 'navy_l'), ('hover', 'navy_l', 'yellow', 'grey_d'),
                             ('kunci', 'black', 'grey_d', 'navy')]:
    c = Canvas(140, 60)
    c.rect(1, 0, 138, 60, P['black']); c.rect(0, 1, 140, 58, P['black'])
    c.rect(1, 1, 138, 58, P[edge]); c.rect(3, 3, 134, 54, P['black']); c.rect(4, 4, 132, 52, P[face])
    c.hline(4, 135, 4, P[hi])
    c.rect(5, 10, 64, 40, P['black'])
    c.save(J('ui', f'kartu_pilih_{name}.png'))
g = Canvas(14, 16)
g.rect(3, 1, 8, 2, P['grey_l']); g.rect(2, 2, 2, 6, P['grey_l']); g.rect(10, 2, 2, 6, P['grey_l'])
g.rect(1, 7, 12, 8, P['gold']); g.hline(1, 12, 7, P['yellow']); g.hline(1, 12, 14, P['orange'])
g.rect(6, 9, 2, 4, P['choc'])
g.outline(P['black']); g.save(J('ui', 'ikon_gembok.png'))
ck = Canvas(14, 14)
ck.ellipse(7, 7, 6, 6, P['green_m'])
for x, y in [(3, 7), (4, 8), (5, 9), (6, 10), (7, 9), (8, 8), (9, 7), (10, 6), (11, 5)]:
    ck.px(x, y, P['white']); ck.px(x, y - 1, P['white'])
ck.outline(P['black']); ck.save(J('ui', 'ikon_centang.png'))
print('revisi ok')

# ---- revisi v1.2: TKP lebih padat + tombol "SEMUA" (kembali dari sektor yang diperbesar)
import tkp_v2
tkp_v2.build(A)
for st in ('normal', 'hover', 'pressed'):
    _btn(56, 20, 'SEMUA', 'biru', st).save(J('menu', f'ui_g_btn_semua_{st}.png'))

# ---- revisi v1.3: musik menu baru (komposisi tulis-tangan) + aset efek & transisi
import music_menu, fx_assets
audio.write(J('audio', 'bgm_menu.wav'), music_menu.compose(), .78)
fx_assets.build(A)
