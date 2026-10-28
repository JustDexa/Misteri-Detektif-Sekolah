"""Gameplay art: font, UI, items, TKP scenes, poster, ending, rapor."""
from pix import *
from chars import S as SH, Lt, NPCS, npc_sprite, portrait, PLAYER_P
from ui import magnifier, fancy_text, button
import random, math

# ================================================================ FONT (mixed case, 9px tall)
LOWER = {
'a': ".....|.....|.###.|....#|.####|#...#|.####|.....|.....",
'b': "#....|#....|####.|#...#|#...#|#...#|####.|.....|.....",
'c': ".....|.....|.###.|#....|#....|#....|.###.|.....|.....",
'd': "....#|....#|.####|#...#|#...#|#...#|.####|.....|.....",
'e': ".....|.....|.###.|#...#|#####|#....|.###.|.....|.....",
'f': "..##|.#..|####|.#..|.#..|.#..|.#..|....|....",
'g': ".....|.....|.####|#...#|#...#|#...#|.####|....#|.###.",
'h': "#....|#....|####.|#...#|#...#|#...#|#...#|.....|.....",
'i': "#|.|#|#|#|#|#|.|.",
'j': "..#|...|..#|..#|..#|..#|..#|#.#|.#.",
'k': "#...|#...|#..#|#.#.|##..|#.#.|#..#|....|....",
'l': "#.|#.|#.|#.|#.|#.|.#|..|..",
'm': ".....|.....|##.#.|#.#.#|#.#.#|#.#.#|#.#.#|.....|.....",
'n': ".....|.....|####.|#...#|#...#|#...#|#...#|.....|.....",
'o': ".....|.....|.###.|#...#|#...#|#...#|.###.|.....|.....",
'p': ".....|.....|####.|#...#|#...#|#...#|####.|#....|#....",
'q': ".....|.....|.####|#...#|#...#|#...#|.####|....#|....#",
'r': "....|....|#.##|##..|#...|#...|#...|....|....",
's': ".....|.....|.####|#....|.###.|....#|####.|.....|.....",
't': ".#..|.#..|####|.#..|.#..|.#..|..##|....|....",
'u': ".....|.....|#...#|#...#|#...#|#...#|.####|.....|.....",
'v': ".....|.....|#...#|#...#|#...#|.#.#.|..#..|.....|.....",
'w': ".....|.....|#...#|#...#|#.#.#|#.#.#|.#.#.|.....|.....",
'x': ".....|.....|#...#|.#.#.|..#..|.#.#.|#...#|.....|.....",
'y': ".....|.....|#...#|#...#|#...#|#...#|.####|....#|.###.",
'z': ".....|.....|#####|...#.|..#..|.#...|#####|.....|.....",
'"': "#.#|#.#|...|...|...|...|...",
';': ".|.|#|.|.|#|#",
'=': "....|....|####|....|####|....|....",
'*': ".....|#.#.#|.###.|#####|.###.|#.#.#|.....",
}


def export_font(folder):
    glyphs = {}
    for k, g in GLYPH.items():
        m = np.zeros((9, g.shape[1]), bool); m[:7] = g; glyphs[k] = m
    for k, v in LOWER.items():
        rows = v.split('|')
        m = np.zeros((9, len(rows[0])), bool)
        for y, r in enumerate(rows):
            for x, ch in enumerate(r): m[y, x] = ch == '#'
        glyphs[k] = m
    glyphs['…'] = glyphs['.'].copy()
    keys = sorted(glyphs, key=ord)
    cols, cw, ch = 16, 8, 10
    rows = (len(keys) + cols - 1) // cols
    img = Canvas(cols * cw, rows * ch)
    lines = []
    for i, k in enumerate(keys):
        g = glyphs[k]; x, y = (i % cols) * cw, (i // cols) * ch
        img.mask_fill(g, x, y, P['white'])
        adv = g.shape[1] + 1 if k != ' ' else 4
        lines.append(f'char id={ord(k)} x={x} y={y} width={g.shape[1]} height=9 xoffset=0 yoffset=0 xadvance={adv} page=0 chnl=15')
    img.save(f'{folder}/pixel.png')
    with open(f'{folder}/pixel.fnt', 'w') as f:
        f.write('info face="DetektifPixel" size=9 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1\n')
        f.write(f'common lineHeight=11 base=7 scaleW={img.w} scaleH={img.h} pages=1 packed=0\n')
        f.write('page id=0 file="pixel.png"\n')
        f.write(f'chars count={len(lines)}\n')
        f.write('\n'.join(lines) + '\n')


# ================================================================ UI
def frame9(w, h, face='cream', frame='brown_d', inner='tan'):
    cv = Canvas(w, h)
    cv.rect(1, 0, w - 2, h, P['black']); cv.rect(0, 1, w, h - 2, P['black'])
    cv.rect(1, 1, w - 2, h - 2, P[frame])
    cv.hline(2, w - 3, 1, P[Lt(frame)])
    cv.rect(3, 3, w - 6, h - 6, P['black'])
    cv.rect(4, 4, w - 8, h - 8, P[face])
    cv.hline(4, w - 5, h - 5, P[inner]); cv.vline(w - 5, 4, h - 5, P[inner])
    return cv


def ui_assets(folder):
    frame9(24, 24).save(f'{folder}/kotak_dialog.png')                       # 9-slice margin 6
    frame9(24, 24, 'navy', 'gold', 'navy_l').save(f'{folder}/kotak_gelap.png')
    frame9(16, 16, 'rust', 'choc', 'red_d').save(f'{folder}/papan_nama.png')  # margin 4
    frame9(56, 56, 'blue_d', 'brown_d', 'navy').save(f'{folder}/bingkai_potret.png')
    # next indicator (2 frames 8x8)
    sh = Canvas(16, 8)
    for f in range(2):
        for i in range(4):
            sh.vline(f * 8 + 2 + i, 1 + i + f, 7 - i + f - 1, P['rust'])
    sh.save(f'{folder}/lanjut.png')
    # interaction bubble (2 frames 16x18)
    sh = Canvas(32, 18)
    for f in range(2):
        b = Canvas(16, 18)
        b.rect(1, 0 + f, 14, 13, P['black']); b.rect(0, 1 + f, 16, 11, P['black'])
        b.rect(1, 1 + f, 14, 11, P['white'])
        b.rect(6, 13 + f, 4, 1, P['black']); b.rect(7, 14 + f, 2, 2, P['black']); b.rect(7, 13 + f, 2, 1, P['white'])
        mg = magnifier(3, 3, qmark=False)
        b.paste(mg, 3, 1 + f)
        sh.paste(b, f * 16, 0)
    sh.save(f'{folder}/ikon_interaksi.png')
    # HUD book button 22x22
    for st in ('normal', 'hover'):
        cv = Canvas(22, 22)
        cv.rect(1, 1, 20, 20, P['black']); cv.rect(2, 2, 18, 18, P['brown'] if st == 'normal' else P['clay'])
        cv.rect(4, 4, 14, 14, P['black']); cv.rect(5, 5, 6, 12, P['cream']); cv.rect(11, 5, 6, 12, P['white'])
        for yy in (7, 9, 11, 13): cv.hline(6, 9, yy, P['tan']); cv.hline(12, 15, yy, P['grey_l'])
        cv.vline(11, 5, 16, P['brown_d']); cv.rect(14, 3, 2, 6, P['red'])
        cv.save(f'{folder}/tombol_buku_{st}.png')
    # book panel 288x164
    W, H = 288, 164
    cv = Canvas(W, H)
    cv.rect(2, 4, W - 4, H - 4, P['black']); cv.rect(3, 5, W - 6, H - 6, P['brown_d'])
    cv.hline(4, W - 5, 6, P['brown'])
    for x in range(8, W - 8, 3): cv.px(x, 8, P['clay']); cv.px(x, H - 4, P['clay'])
    for side in (0, 1):
        x0 = 10 if side == 0 else W // 2 + 2
        cv.rect(x0 - 1, 11, W // 2 - 11, H - 20, P['black'])
        cv.rect(x0, 12, W // 2 - 13, H - 22, P['cream'])
        for yy in range(26, H - 12, 11): cv.hline(x0 + 4, x0 + W // 2 - 18, yy, P['tan'])
        cv.vline(x0 + (W // 2 - 14 if side == 0 else 0), 12, H - 11, P['tan'])
    cv.rect(W // 2 - 2, 10, 4, H - 18, P['choc'])
    cv.save(f'{folder}/buku_panel.png')
    # tabs 44x14
    for name, col in (('aktif', 'rust'), ('pasif', 'brown')):
        t = Canvas(44, 14)
        t.rect(1, 0, 42, 14, P['black']); t.rect(2, 1, 40, 13, P[col]); t.hline(2, 41, 1, P[Lt(col)])
        t.save(f'{folder}/tab_{name}.png')
    # evidence slot 24x24
    for name, col in (('kosong', 'tan'), ('isi', 'white')):
        t = Canvas(24, 24)
        t.rect(0, 0, 24, 24, P['brown']); t.rect(1, 1, 22, 22, P[col]); t.border(1, 1, 22, 22, P['brown_d'])
        if name == 'kosong':
            t.text('?', 10, 8, P['brown'])
        t.save(f'{folder}/slot_{name}.png')
    # TKP buttons 30x30
    for st in ('mati', 'nyala', 'hover'):
        b = Canvas(30, 30)
        face = {'mati': 'grey_d', 'nyala': 'green_m', 'hover': 'blue'}[st]
        b.rect(1, 0, 28, 30, P['black']); b.rect(0, 1, 30, 28, P['black'])
        b.rect(1, 1, 28, 26, P[face]); b.rect(1, 27, 28, 2, P[SH(face)])
        b.hline(2, 27, 1, P[Lt(face)])
        for i in range(3):
            b.vline(5 + i * 0, 5, 5, P['white'])
        b.border(6, 5, 18, 18, P['white']); b.vline(15, 5, 22, P['white']); b.hline(6, 23, 14, P['white'])
        b.text('A', 8, 7, P['yellow']) if False else None
        b.save(f'{folder}/tombol_grid_{st}.png')
    for st in ('normal', 'hover'):
        b = Canvas(30, 30)
        face = 'red' if st == 'normal' else 'pink'
        b.rect(1, 0, 28, 30, P['black']); b.rect(0, 1, 30, 28, P['black'])
        b.rect(1, 1, 28, 26, P[face]); b.rect(1, 27, 28, 2, P['red_d']); b.hline(2, 27, 1, P['white'])
        # arrow back
        for i in range(6):
            b.vline(8 + i, 14 - i, 14 + i, P['white'])
        b.rect(13, 12, 10, 5, P['white'])
        b.save(f'{folder}/tombol_keluar_{st}.png')
    # evidence popup star burst 40x40
    sb = Canvas(48, 48)
    for a in range(0, 360, 30):
        r = math.radians(a)
        sb.line(24, 24, 24 + int(22 * math.cos(r)), 24 + int(22 * math.sin(r)), P['yellow'], 2)
    sb.ellipse(24, 24, 14, 14, P['gold']); sb.ellipse(24, 24, 12, 12, P['yellow'])
    sb.save(f'{folder}/kilau_bukti.png')


# ================================================================ ITEMS (16x16 icons)
def _o(cv):
    cv.outline(P['black']); return cv


def it_sapu():
    c = Canvas(16, 16)
    c.line(13, 1, 7, 8, P['brown'], 2); c.px(12, 1, P['tan'])
    c.rect(5, 8, 4, 2, P['red'])
    for i in range(6):
        c.line(6 + (i > 2), 10, 1 + i, 14, P['gold'])
        c.line(7, 10, 3 + i, 14, P['gold'] if i % 2 else P['orange'])
    c.hline(1, 8, 14, P['orange'])
    return _o(c)


def it_jejak():
    c = Canvas(16, 16)
    for (x, y) in ((2, 7), (8, 1)):
        c.ellipse(x + 2, y + 2, 2, 3, P['brown_d']); c.rect(x + 1, y + 6, 3, 2, P['brown_d'])
        c.px(x + 1, y + 1, P['brown'])
    return _o(c)


def it_poster(n):
    c = Canvas(16, 16)
    c.rect(2, 2, 12, 12, P['cream'])
    # torn edges on inner sides
    jag = [0, 1, 0, 2, 1, 0, 1, 2, 0, 1, 0, 1]
    for i in range(12):
        if n in (1, 3): c.px(13 - jag[i] % 2, 2 + i, T)   # right edge torn
        else: c.px(2 + jag[i] % 2, 2 + i, T)             # left edge torn
        if n in (1, 2): c.px(2 + i, 13 - jag[(i + 3) % 12] % 2, T)
        else: c.px(2 + i, 2 + jag[(i + 5) % 12] % 2, T)
    col = {1: 'green', 2: 'blue', 3: 'gold', 4: 'red'}[n]
    c.rect(5, 5, 6, 3, P[col]); c.hline(5, 10, 9, P['green_d']); c.hline(5, 8, 11, P['green_d'])
    c.text(str(n), 11 if n in (2, 4) else 3, 3, P['rust']) if False else None
    return _o(c)


def it_selang():
    c = Canvas(16, 16)
    for r, col in ((6, 'green_m'), (4, 'green'), (2, 'green_m')):
        c.ellipse(7, 8, r, r - 1, P[col])
    c.ellipse(7, 8, 1, 1, T)
    c.rect(12, 3, 3, 3, P['gold']); c.line(12, 5, 10, 7, P['green_m'], 2)
    return _o(c)


def it_daftar():
    c = Canvas(16, 16)
    c.rect(3, 1, 10, 14, P['white']); c.rect(6, 0, 4, 2, P['grey'])
    for i, y in enumerate((4, 7, 10)):
        c.hline(7, 11, y, P['grey']); c.px(4, y, P['green_m']); c.px(5, y + 1, P['green_m']) if False else None
        c.px(4, y - 1, P['green']); c.px(5, y, P['green']); c.px(6, y - 2, P['green'])
    c.hline(4, 11, 13, P['blue_d'])
    return _o(c)


def it_ember():
    c = Canvas(16, 16)
    for y in range(5, 15):
        half = 5 + (y - 5) * 0 - (y - 5) // 4
        c.hline(8 - half, 7 + half, y, P['blue'])
        c.px(7 + half, y, P['blue_d'])
    c.ellipse(8, 5, 5, 1, P['cyan']); c.hline(4, 11, 5, P['blue_d'])
    c.line(3, 5, 5, 1, P['grey_d']); c.hline(5, 10, 1, P['grey_d']); c.line(10, 1, 12, 5, P['grey_d'])
    c.vline(5, 7, 12, P['cyan'])
    return _o(c)


def it_struk():
    c = Canvas(16, 16)
    c.rect(4, 1, 8, 13, P['white'])
    for x in range(4, 12, 2): c.px(x, 14, P['white'])
    for y in (3, 5, 7, 9): c.hline(5, 10, y, P['grey'])
    c.hline(5, 10, 11, P['navy'])
    return _o(c)


def it_kemoceng():
    c = Canvas(16, 16)
    c.line(3, 14, 8, 8, P['brown'], 2)
    for i, col in enumerate(['red', 'purple', 'gold', 'red', 'magenta', 'gold']):
        a = i / 6 * math.pi * 1.2 - .3
        c.line(9, 7, 9 + int(5 * math.cos(a)), 7 - int(5 * math.sin(a)) - 1, P[col], 2)
    c.ellipse(11, 4, 3, 3, P['red'])
    c.px(11, 3, P['pink']); c.px(12, 5, P['gold'])
    return _o(c)


def it_catatan():
    c = Canvas(16, 16)
    c.rect(2, 2, 12, 12, P['yellow']); c.vline(2, 2, 13, P['gold'])
    for y in (5, 8, 11): c.hline(4, 12, y, P['gold'])
    c.ellipse(10, 8, 2, 2, P['red']); c.ellipse(10, 8, 1, 1, P['yellow'])
    for x in range(3, 14, 3): c.px(x, 1, P['grey'])
    return _o(c)


# distractors
def d_kardus():
    c = Canvas(16, 16); c.rect(2, 5, 12, 10, P['tan']); c.rect(2, 5, 12, 3, P['brown'])
    c.vline(8, 5, 14, P['brown']); c.hline(2, 13, 5, P['cream']); c.rect(5, 10, 6, 2, P['cream']); return _o(c)
def d_koran():
    c = Canvas(16, 16); c.rect(2, 4, 12, 9, P['grey_l']); c.rect(3, 5, 5, 3, P['grey'])
    for y in (5, 7, 9, 11): c.hline(9, 12, y, P['grey'])
    c.hline(3, 7, 10, P['grey']); c.px(13, 4, P['white']); return _o(c)
def d_sandal():
    c = Canvas(16, 16)
    for x in (3, 9): c.ellipse(x + 2, 8, 2, 5, P['blue']); c.hline(x + 1, x + 3, 6, P['white'])
    return _o(c)
def d_kaleng():
    c = Canvas(16, 16); c.rect(5, 4, 7, 10, P['grey_l']); c.rect(5, 7, 7, 4, P['red'])
    c.hline(5, 11, 4, P['white']); c.vline(11, 4, 13, P['grey']); return _o(c)
def d_jaring():
    c = Canvas(16, 16)
    for i in range(0, 14, 3): c.line(1 + i, 1, 1 + i // 2 + 3, 14, P['green_d']); c.line(14 - i, 1, 12 - i // 2, 14, P['green_d'])
    c.hline(1, 14, 1, P['brown']); return _o(c)
def d_sarung():
    c = Canvas(16, 16); c.rect(4, 6, 7, 8, P['orange'])
    for x in (4, 6, 8): c.rect(x, 2, 2, 5, P['orange'])
    c.rect(11, 7, 2, 4, P['orange']); c.hline(4, 10, 13, P['rust']); return _o(c)
def d_arsip():
    c = Canvas(16, 16); c.rect(1, 4, 14, 11, P['brown']); c.rect(1, 4, 14, 2, P['brown_d'])
    c.rect(5, 8, 6, 4, P['white']); c.hline(6, 9, 10, P['grey']); return _o(c)
def d_bingkai():
    c = Canvas(16, 16); c.border(2, 2, 12, 12, P['gold']); c.border(3, 3, 10, 10, P['orange'])
    c.line(4, 4, 11, 11, P['grey_l']); c.px(13, 9, T); c.px(13, 10, T); c.rect(4, 5, 3, 3, P['navy_l']); return _o(c)
def d_kain():
    c = Canvas(16, 16); c.ellipse(8, 9, 6, 5, P['grey_l']); c.ellipse(8, 5, 3, 3, P['grey_l'])
    c.line(4, 13, 8, 6, P['grey']); c.line(11, 13, 9, 7, P['grey']); return _o(c)
def d_lampu():
    c = Canvas(16, 16); c.ellipse(8, 5, 5, 4, P['gold']); c.rect(3, 5, 11, 4, T)
    c.ellipse(8, 5, 5, 4, P['gold']); c.hline(3, 13, 7, P['orange'])
    c.rect(7, 8, 2, 5, P['grey_d']); c.rect(5, 13, 6, 2, P['grey_d']); return _o(c)
def d_tangga():
    c = Canvas(16, 24)
    c.line(3, 23, 6, 1, P['grey_l'], 2); c.line(12, 23, 9, 1, P['grey_l'], 2)
    for y in range(5, 22, 5): c.hline(5, 11, y, P['grey'])
    return _o(c)
def d_karpet():
    c = Canvas(24, 12); c.rect(2, 2, 20, 8, P['red_d']); c.ellipse(21, 6, 2, 4, P['red'])
    c.ellipse(21, 6, 1, 2, P['gold']); c.hline(2, 20, 4, P['gold']); c.hline(2, 20, 8, P['purple']); return _o(c)


ITEMS = dict(sapu=it_sapu, jejak=it_jejak, poster1=lambda: it_poster(1), poster2=lambda: it_poster(2),
             poster3=lambda: it_poster(3), poster4=lambda: it_poster(4), selang=it_selang, daftar=it_daftar,
             ember=it_ember, struk=it_struk, kemoceng=it_kemoceng, catatan=it_catatan)
DISTRACT = dict(kardus=d_kardus, koran=d_koran, sandal=d_sandal, kaleng=d_kaleng, jaring=d_jaring,
                sarung=d_sarung, arsip=d_arsip, bingkai=d_bingkai, kain=d_kain, lampu=d_lampu,
                tangga=d_tangga, karpet=d_karpet)


# ================================================================ TKP (160x90, shown at 2x)
def tkp_kios():
    c = Canvas(160, 90, P['white'])
    for y in range(0, 54):
        for x in range(160):
            if x % 8 == 0 or y % 8 == 0: c.px(x, y, P['blue'])
            elif (x // 8 + y // 8) % 2 == 0: c.px(x, y, P['cyan']) if (x + y) % 5 == 0 else None
    c.hline(0, 159, 53, P['blue_d']); c.hline(0, 159, 54, P['navy'])
    for y in range(55, 90):
        for x in range(160):
            c.px(x, y, P['grey'] if (x * 3 + y * 7) % 11 else P['grey_d'])
    for px_, py_, r in ((30, 82, 10), (120, 76, 8), (80, 86, 6)):
        c.ellipse(px_, py_, r, 2, P['grey_d']); c.hline(px_ - r + 2, px_, py_ - 1, P['blue'])
    # shelf left
    c.rect(2, 10, 40, 38, P['black']); c.rect(3, 11, 38, 36, P['brown'])
    for yy in (23, 35): c.rect(3, yy, 38, 2, P['brown_d'])
    for i in range(5):
        c.rect(6 + i * 7, 15, 5, 8, P['black']); c.rect(7 + i * 7, 16, 3, 6, P[['orange', 'green', 'red', 'gold', 'white'][i]])
    # counter
    c.rect(44, 36, 76, 28, P['black']); c.rect(45, 37, 74, 9, P['white']); c.dither_rect(45, 37, 74, 9, P['cyan'])
    c.rect(45, 46, 74, 17, P['blue_d']); c.hline(45, 118, 46, P['blue'])
    for i in range(5):
        fx = 50 + i * 13
        c.ellipse(fx + 4, 40, 5, 2, P['black']); c.ellipse(fx + 4, 40, 4, 1, P['grey_l'])
        c.px(fx + 7, 40, P['black']); c.px(fx - 1, 39, P['grey']); c.px(fx - 1, 41, P['grey'])
    c.rect(52, 52, 16, 6, P['navy']); c.text("IKAN", 53, 51, P['white']) if False else None
    # styrofoam boxes right
    for i, (bx, by) in enumerate(((124, 42), (138, 42), (130, 30), (126, 18))):
        c.rect(bx, by, 16, 12, P['black']); c.rect(bx + 1, by + 1, 14, 10, P['white']); c.hline(bx + 1, bx + 14, by + 3, P['grey_l'])
    # hanging scale & lamp
    c.vline(118, 0, 8, P['grey_d']); c.ellipse(118, 13, 5, 5, P['black']); c.ellipse(118, 13, 4, 4, P['white'])
    c.line(118, 13, 120, 10, P['red']); c.rect(112, 19, 12, 3, P['grey'])
    c.vline(80, 0, 4, P['black']); c.ellipse(80, 7, 4, 3, P['yellow']); c.rect(76, 4, 9, 2, P['navy'])
    return c


def tkp_gudang():
    c = Canvas(160, 90, P['grey_d'])
    for y in range(0, 56):
        for x in range(160):
            off = 0 if (y // 5) % 2 == 0 else 5
            if y % 5 == 0 or (x + off) % 10 == 0: c.px(x, y, P['navy_l'])
    c.rect(70, 4, 20, 14, P['black']); c.rect(71, 5, 18, 12, P['cyan']); c.vline(80, 5, 16, P['black']); c.hline(71, 88, 10, P['black'])
    for y in range(18, 90):   # light beam
        for x in range(60 + (y - 18) // 3, 100 - (y - 18) // 6):
            if (x + y) % 3 == 0 and c.a[y, x][:3].tolist() != list(P['black'][:3]): c.px(x, y, P['grey'])
    for y in range(56, 90):
        for x in range(160):
            c.px(x, y, P['brown'] if (y - 56) % 6 else P['brown_d'])
        if (y - 56) % 6 == 0:
            pass
    for x in range(0, 160, 23):
        for y in range(56, 90, 12): c.vline(x + (y // 12 % 2) * 11, y, y + 5, P['brown_d'])
    # metal shelves
    for sx in (2, 112):
        c.rect(sx, 8, 46, 48, P['black']); c.rect(sx + 1, 9, 44, 46, P['grey'])
        for yy in (22, 38, 53): c.rect(sx + 1, yy, 44, 2, P['grey_l'])
        c.rect(sx + 1, 9, 2, 46, P['grey_l']); c.rect(sx + 43, 9, 2, 46, P['grey_l'])
        for i in range(4):
            c.rect(sx + 5 + i * 10, 14, 8, 8, P['black']); c.rect(sx + 6 + i * 10, 15, 6, 7, P['tan'])
            c.rect(sx + 5 + i * 10, 30, 8, 8, P['black']); c.rect(sx + 6 + i * 10, 31, 6, 7, P['brown'])
    # covered statue silhouette
    c.ellipse(96, 50, 10, 16, P['black']); c.ellipse(96, 50, 9, 15, P['grey_l']); c.line(92, 40, 94, 64, P['grey'])
    return c


TKP = {
    'kios_ikan': dict(bg=tkp_kios, found=['ember', 'poster3', 'struk'],
                      objects=[('poster3', 50, 10), ('kaleng', 17, 28), ('jaring', 92, 2), ('koran', 98, 32),
                               ('kardus', 4, 60), ('sandal', 40, 72), ('struk', 62, 62),
                               ('ember', 98, 62), ('sarung', 138, 70)]),
    'gudang_museum': dict(bg=tkp_gudang, found=['kemoceng', 'poster4', 'catatan'],
                          objects=[('arsip', 10, 26), ('bingkai', 52, 16), ('kemoceng', 118, 22),
                                   ('kain', 128, 26), ('poster4', 28, 66), ('lampu', 60, 60),
                                   ('karpet', 4, 76), ('catatan', 108, 66), ('tangga', 140, 58)]),
}


# ================================================================ POSTER "AKSI BERSIH KOTA" (128x160)
def poster():
    c = Canvas(128, 160, P['cream'])
    c.rect(0, 0, 128, 160, P['black']); c.rect(2, 2, 124, 156, P['cream'])
    c.rect(6, 6, 116, 40, P['green_m']); c.rect(6, 6, 116, 4, P['green'])
    t1 = fancy_text("AKSI", 2, bands=('white', 'grey_l'), ow=1, depth=1, depth_c='green_d')
    c.paste(t1, 64 - t1.w // 2, 10)
    c.text_c("BERSIH KOTA", 64, 32, P['yellow'], shadow=P['green_d'])
    # city + sun illustration
    c.rect(6, 50, 116, 60, P['cyan'])
    c.ellipse(96, 66, 9, 9, P['yellow'])
    for i, (bx, bh) in enumerate(((10, 30), (24, 44), (40, 24), (70, 36), (88, 20), (104, 32))):
        c.rect(bx, 110 - bh, 14, bh, P['blue_d']); c.rect(bx + 1, 111 - bh, 12, bh - 1, P['blue'])
        for wy in range(114 - bh, 108, 5):
            c.px(bx + 4, wy, P['yellow']); c.px(bx + 9, wy, P['cyan'])
    c.rect(6, 100, 116, 10, P['green_m'])
    # tools icons row
    for i, fn in enumerate((it_sapu, it_selang, it_ember, it_kemoceng)):
        ic = fn(); big = Canvas(32, 32)
        big.a = ic.a.repeat(2, 0).repeat(2, 1)
        c.paste(big, 6 + i * 29, 112) if False else c.paste(ic, 14 + i * 28, 114)
    c.text_c("MINGGU PAGI", 64, 136, P['rust'])
    c.text_c("KLUB LINGKUNGAN", 64, 146, P["green_d"])
    c.border(4, 4, 120, 152, P['green_d'])
    return c


# ================================================================ ENDING (320x180)
def ending():
    c = Canvas(320, 180, P['cyan'])
    for y in range(0, 60): c.hline(0, 319, y, P['blue'])
    for y in range(60, 66):
        for x in range(320):
            if (x + y) % 2 == 0: c.px(x, y, P['blue'])
    for y in range(120, 180): c.hline(0, 319, y, P['green_m'])
    for i in range(300):
        c.px(random.Random(i).randrange(320), 120 + random.Random(i * 7).randrange(60), P['green'])
    # distant city
    for bx, bh in ((0, 40), (22, 56), (48, 34), (230, 50), (258, 30), (282, 60)):
        c.rect(bx, 120 - bh, 24, bh, P['blue_d'])
        for wy in range(124 - bh, 116, 6):
            for wx in range(bx + 4, bx + 20, 6): c.px(wx, wy, P['yellow'])
    # banner between poles
    c.rect(70, 30, 4, 90, P['brown_d']); c.rect(246, 30, 4, 90, P['brown_d'])
    ps = poster()
    small = Canvas(128, 160); small.a = ps.a
    # banner cloth
    c.rect(74, 34, 172, 26, P['black']); c.rect(75, 35, 170, 24, P['green_m']); c.hline(75, 244, 35, P['green'])
    t = fancy_text("AKSI BERSIH KOTA", 1, bands=('white',), ow=1, depth=1, depth_c='green_d')
    c.paste(t, 160 - t.w // 2, 41)
    # characters at 3x
    order = ['nisa', 'bima', None, 'tari', 'arga']
    xs = [78, 118, 150, 190, 222]
    for nid, x in zip(order, xs):
        spr = npc_sprite(NPCS[nid]) if nid else None
        if nid is None:
            from chars import player_frame
            spr = player_frame('down', 0)
        big = Canvas(48, 72); big.a = spr.a.repeat(3, 0).repeat(3, 1)
        for sx in range(x + 6, x + 42):
            if (sx) % 2 == 0: c.px(sx, 170, P['green_d']); c.px(sx, 171, P['green_d'])
        c.paste(big, x, 100)
    # tools on the grass
    for i, fn in enumerate((it_sapu, it_selang, it_ember, it_kemoceng)):
        ic = fn(); big = Canvas(32, 32); big.a = ic.a.repeat(2, 0).repeat(2, 1)
        c.paste(big, [18, 44, 262, 286][i], 140)
    # confetti
    r = random.Random(4)
    for i in range(70):
        c.px(r.randrange(320), r.randrange(100), P[r.choice(['yellow', 'red', 'white', 'pink', 'gold'])])
    return c


# ================================================================ RAPOR
PILAR = {'dekomposisi': 'blue', 'pola': 'gold', 'abstraksi': 'green_m', 'algoritma': 'red'}


def ikon_pilar(name):
    c = Canvas(20, 20)
    col = PILAR[name]
    c.ellipse(9, 9, 9, 9, P['black']); c.ellipse(9, 9, 8, 8, P[col]); c.ellipse(8, 8, 6, 6, P[Lt(col)]) if False else None
    w = P['white']
    if name == 'dekomposisi':
        for (x, y) in ((4, 4), (10, 4), (4, 10), (10, 10)): c.rect(x, y, 5, 5, w)
    elif name == 'pola':
        for i, x in enumerate((3, 8, 13)):
            c.rect(x, 12 - i * 3, 3, 3 + i * 3, w)
    elif name == 'abstraksi':
        c.ellipse(9, 8, 5, 5, w); c.ellipse(9, 8, 3, 3, P[col]); c.line(12, 11, 15, 15, w, 2)
    else:
        c.rect(3, 4, 5, 3, w); c.rect(11, 8, 5, 3, w); c.rect(3, 12, 5, 3, w)
        c.line(8, 5, 12, 8, w); c.line(12, 11, 8, 13, w)
    return c


def lencana(name):
    c = Canvas(40, 44)
    col = PILAR[name]
    c.rect(8, 30, 8, 14, P['red']); c.rect(24, 30, 8, 14, P['red_d'])
    for x in (8, 24):
        c.px(x + 3, 43, T); c.px(x + 4, 43, T); c.px(x + 4, 42, T)
    c.ellipse(20, 20, 18, 18, P['black']); c.ellipse(20, 20, 17, 17, P['gold'])
    c.ellipse(20, 20, 14, 14, P['orange']); c.ellipse(20, 20, 13, 13, P[col])
    for a in range(0, 360, 20):
        r = math.radians(a); c.px(20 + int(16 * math.cos(r)), 20 + int(16 * math.sin(r)), P['yellow'])
    ic = ikon_pilar(name)
    big = Canvas(40, 40); big.a[:] = 0
    sub = ic.a[1:19, 1:19]
    c.paste(Canvas(1, 1), 0, 0)
    tmp = Canvas(18, 18); tmp.a = sub.copy()
    c.paste(tmp, 11, 11)
    return c


def rapor_bg():
    c = Canvas(320, 180, P['brown_d'])
    for y in range(180):
        for x in range(0, 320, 1):
            if (y * 3 + x // 40) % 9 == 0: c.px(x, y, P['choc'])
    c.rect(8, 6, 304, 168, P['black']); c.rect(9, 7, 302, 166, P['cream'])
    c.rect(9, 7, 302, 22, P['rust']); c.hline(9, 310, 7, P['clay']); c.hline(9, 310, 28, P['red_d'])
    for x in range(14, 306, 8): c.px(x, 172, P['tan'])
    c.vline(150, 34, 166, P['tan'])
    # paper clip + stamp spot
    return c


def stempel():
    c = Canvas(84, 30)
    c.border(1, 1, 82, 28, P['red']); c.border(3, 3, 78, 24, P['red'])
    c.text_c("KASUS", 42, 6, P['red']); c.text_c("SELESAI", 42, 16, P['red'])
    for i in range(40):
        r = random.Random(i)
        c.px(r.randrange(84), r.randrange(30), T)
    return c
