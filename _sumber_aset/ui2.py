from pix import *
from ui import button, magnifier, fancy_text, logo
import random, math


# ================================================================ PANEL (case-file style)
def panel(w, h, title):
    cv = Canvas(w, h)
    cv.rect(1, 0, w - 2, h, P['black']); cv.rect(0, 1, w, h - 2, P['black'])
    # leather frame
    cv.rect(1, 1, w - 2, h - 2, P['brown_d'])
    cv.hline(2, w - 3, 1, P['brown'])
    cv.vline(1, 2, h - 3, P['brown'])
    cv.hline(2, w - 3, h - 2, P['choc'])
    # stitching
    for x in range(4, w - 4, 3):
        cv.px(x, 3, P['clay']); cv.px(x, h - 4, P['clay'])
    for y in range(5, h - 4, 3):
        cv.px(3, y, P['clay']); cv.px(w - 4, y, P['clay'])
    # paper
    px0, py0, pw, ph = 6, 6, w - 12, h - 12
    cv.rect(px0 - 1, py0 - 1, pw + 2, ph + 2, P['choc'])
    cv.rect(px0, py0, pw, ph, P['cream'])
    cv.hline(px0, px0 + pw - 1, py0 + ph - 1, P['tan'])
    cv.vline(px0 + pw - 1, py0, py0 + ph - 1, P['tan'])
    # header
    hh = 15
    cv.rect(px0, py0, pw, hh, P['rust'])
    cv.hline(px0, px0 + pw - 1, py0, P['clay'])
    cv.hline(px0, px0 + pw - 1, py0 + hh - 1, P['red_d'])
    cv.hline(px0, px0 + pw - 1, py0 + hh, P['choc'])
    cv.hline(px0, px0 + pw - 1, py0 + hh + 1, P['tan'])
    if title:
        cv.text_c(title, w // 2, py0 + 4, P['white'], shadow=P['red_d'])
    # corner rivets
    for x, y in [(3, 3), (w - 5, 3), (3, h - 5), (w - 5, h - 5)]:
        cv.rect(x, y, 2, 2, P['gold']); cv.px(x, y, P['yellow']); cv.px(x + 1, y + 1, P['orange'])
    # paper clip (top-left)
    clip = ["..KKKK..", ".KGGGGK.", "KG.KK.GK", "KG.KG.GK", "KG.KG.GK", "KG.KG.GK", "KG.KG.GK",
            "KG.GK.GK", "KG....GK", ".KGGGGK.", "..KKKK.."]
    for y, row in enumerate(clip):
        for x, ch in enumerate(row):
            if ch == 'K': cv.px(12 + x, 1 + y, P['navy'])
            if ch == 'G': cv.px(12 + x, 1 + y, P['grey_l'])
    return cv


ICONS = {
    'musik': ["...KK", "..K.K", "..K.K", "..K..", "KKK..", "KKK..", ".K..."],
    'suara': ["..K...", ".KK..K", "KKK.K.", "KKK.K.", "KKK.K.", ".KK..K", "..K..."],
    'layar': ["KKKKKKK", "K.....K", "K.....K", "K.....K", "KKKKKKK", "...K...", ".KKKKK."],
}


def icon(cv, name, x, y, c):
    for yy, row in enumerate(ICONS[name]):
        for xx, ch in enumerate(row):
            if ch == 'K': cv.px(x + xx, y + yy, c)


def slider_track(w=96):
    cv = Canvas(w, 8)
    cv.rect(1, 0, w - 2, 8, P['black']); cv.rect(0, 1, w, 6, P['black'])
    cv.rect(1, 1, w - 2, 6, P['navy'])
    cv.hline(1, w - 2, 1, P['black'])
    cv.hline(2, w - 3, 6, P['navy_l'])
    return cv


def slider_fill(w=96):
    cv = Canvas(w, 8)
    cv.rect(1, 1, w - 2, 6, P['gold'])
    cv.hline(1, w - 2, 1, P['yellow'])
    cv.hline(1, w - 2, 6, P['orange'])
    for x in range(3, w - 2, 4):
        cv.px(x, 3, P['yellow'])
    return cv


def slider_knob(state='normal'):
    cv = Canvas(10, 14)
    face = P['cream'] if state == 'normal' else P['yellow']
    cv.rect(1, 0, 8, 14, P['black']); cv.rect(0, 1, 10, 12, P['black'])
    cv.rect(1, 1, 8, 12, face)
    cv.hline(2, 7, 1, P['white'])
    cv.rect(1, 10, 8, 2, P['tan'] if state == 'normal' else P['gold'])
    cv.hline(1, 8, 12, P['brown'] if state == 'normal' else P['orange'])
    for y in (4, 6, 8):
        cv.hline(3, 6, y, P['brown'] if state == 'normal' else P['orange'])
    return cv


def toggle(on=False):
    cv = Canvas(28, 14)
    cv.rect(1, 0, 26, 14, P['black']); cv.rect(0, 1, 28, 12, P['black'])
    cv.rect(1, 1, 26, 12, P['green_m'] if on else P['grey_d'])
    cv.hline(1, 26, 1, P['green_d'] if on else P['navy_l'])
    kx = 15 if on else 1
    cv.rect(kx, 1, 12, 12, P['black'])
    cv.rect(kx + 1, 2, 10, 10, P['cream'])
    cv.hline(kx + 2, kx + 9, 2, P['white'])
    cv.hline(kx + 1, kx + 10, 11, P['tan'])
    if on:  # check mark on track
        for i, (dx, dy) in enumerate([(4, 7), (5, 8), (6, 9), (7, 8), (8, 7), (9, 6), (10, 5)]):
            cv.px(dx - 1, dy - 1, P['white'])
    else:
        for i in range(4):
            cv.px(18 + i, 5 + i, P['grey_l']); cv.px(21 - i, 5 + i, P['grey_l'])
    return cv


def panel_opsi():
    cv = panel(200, 120, "OPSI")
    rows = [('musik', 'MUSIK', 34), ('suara', 'EFEK SUARA', 58), ('layar', 'LAYAR PENUH', 82)]
    for ic, lab, y in rows:
        icon(cv, ic, 16, y, P['rust'])
        cv.text(lab, 27, y, P['choc'])
        # dotted leader
        for x in range(27 + text_w(lab) + 4, 84, 3):
            cv.px(x, y + 6, P['tan'])
    return cv


def opsi_preview():
    cv = panel_opsi()
    for y, v in [(33, .7), (57, .45)]:
        cv.paste(slider_track(), 90, y)
        f = slider_fill(); fw = int(96 * v)
        f.a[:, fw:] = 0
        cv.paste(f, 90, y)
        cv.paste(slider_knob('hover' if y == 57 else 'normal'), 90 + fw - 5, y - 3)
    cv.paste(toggle(True), 158, 79)
    from ui import close_button
    cv.paste(close_button(), 180, 6)
    return cv


# ================================================================ PAUSE PANEL
def panel_jeda():
    cv = panel(160, 120, "JEDA")
    # footprints motif at bottom corners
    for (x, y) in [(14, 104), (20, 99), (140, 104), (146, 99)]:
        cv.rect(x, y, 3, 4, P['tan']); cv.rect(x, y - 2, 3, 1, P['tan'])
    return cv


def jeda_preview():
    cv = panel_jeda()
    cv.paste(button(112, 20, 'LANJUT', 'kuning', 'hover'), 24, 32)
    cv.paste(button(112, 20, 'OPSI', 'biru', 'normal'), 24, 58)
    cv.paste(button(112, 20, 'MENU UTAMA', 'merah', 'normal'), 24, 84)
    return cv


# ================================================================ CREDITS
def cork_board():
    W, H = 320, 180
    cv = Canvas(W, H, P['clay'])
    rnd = random.Random(11)
    for i in range(2600):
        x, y = rnd.randrange(W), rnd.randrange(H)
        cv.px(x, y, P[rnd.choice(['brown', 'brown', 'tan', 'rust'])])
    # wood frame
    fw = 7
    for i in range(fw):
        c = P['brown_d'] if i not in (1, fw - 2) else P['brown']
        if i == 0 or i == fw - 1: c = P['black'] if i == 0 else P['choc']
        cv.border(i, i, W - 2 * i, H - 2 * i, c)
    for x in range(10, W - 10, 13):
        cv.px(x, 3, P['choc']); cv.px(x + 4, H - 4, P['choc'])
    # inner shadow on cork
    cv.hline(fw, W - fw - 1, fw, P['brown_d']); cv.vline(fw, fw, H - fw - 1, P['brown_d'])
    return cv


def pin(cv, x, y, c='red'):
    cv.ellipse(x, y, 2, 2, P['black'])
    cv.rect(x - 1, y - 1, 3, 3, P[c])
    cv.px(x - 1, y - 1, P['white'])
    cv.px(x + 2, y + 3, P['brown_d'])


def paper(cv, x, y, w, h, lines=True):
    cv.rect(x + 2, y + 2, w, h, P['brown_d'])  # drop shadow
    cv.rect(x, y, w, h, P['cream'])
    cv.border(x - 1, y - 1, w + 2, h + 2, P['choc']) if False else None
    if lines:
        for yy in range(y + 16, y + h - 3, 10):
            cv.hline(x + 4, x + w - 5, yy, P['tan'])
        cv.vline(x + 12, y, y + h - 1, P['pink'])
    cv.hline(x, x + w - 1, y + h - 1, P['tan'])


def kredit_bg():
    cv = cork_board()
    # header card
    paper(cv, 110, 10, 100, 22, lines=False)
    k = fancy_text("KREDIT", 2, bands=('red', 'red_d'), outline='choc', ow=1, depth=1, depth_c='purple', hi='pink')
    cv.paste(k, 160 - k.w // 2, 13)
    pin(cv, 116, 15); pin(cv, 203, 15)
    # main sheet
    paper(cv, 34, 38, 252, 130)
    # tape pieces
    for tx in (30, 272):
        cv.rect(tx, 34, 18, 8, P['grey_l'])
        cv.dither_rect(tx, 34, 18, 8, P['white'])
    # red string + pins decor on cork edges
    pin(cv, 18, 60, 'blue'); pin(cv, 18, 150, 'gold'); pin(cv, 302, 60, 'gold'); pin(cv, 302, 150, 'blue')
    cv.line(18, 62, 18, 148, P['red'])
    cv.line(302, 62, 302, 148, P['red'])
    # tiny evidence photos on the cork
    for (x, y) in [(12, 90), (294, 90)]:
        cv.rect(x - 1, y - 1, 16, 20, P['black']); cv.rect(x, y, 14, 18, P['white'])
        cv.rect(x + 2, y + 2, 10, 10, P['navy_l'])
        cv.text('?', x + 4, y + 3, P['yellow'])
    return cv


CREDIT_LINES = [
    ('h', 'MISTERI DETEKTIF SEKOLAH'),
    ('t', 'GAME EDUKASI COMPUTATIONAL THINKING'),
    ('s', ''),
    ('h2', 'DIBUAT OLEH'),
    ('t', 'AFRIDYA DEXA WAHNUGRAH   K3524020'),
    ('t', 'ESTU SETYOADI GALIH RAMDANI   K3524050'),
    ('s', ''),
    ('h2', 'DOSEN PENGAMPU'),
    ('t', '[NAMA DOSEN]'),
    ('s', ''),
    ('t', 'PTIK · FKIP · UNIVERSITAS SEBELAS MARET'),
    ('t', '2026 · DIBUAT DENGAN GODOT ENGINE'),
]


def kredit_full():
    cv = kredit_bg()
    y = 46
    for kind, s in CREDIT_LINES:
        if kind == 's':
            y += 10; continue
        c = {'h': P['red_d'], 'h2': P['rust'], 't': P['choc']}[kind]
        cv.text_c(s, 166, y, c)
        y += 10
    return cv


# ================================================================ SPLASH
def dark_bg(W=320, H=180, seed=5):
    cv = Canvas(W, H, P['navy'])
    for y in range(H):
        e = min(y, H - 1 - y)
        for x in range(W):
            if e < 8 or (e < 14 and (x + y) % 2 == 0) or (e < 20 and x % 2 == 0 and y % 2 == 0):
                cv.px(x, y, P['black'])
    rnd = random.Random(seed)
    for i in range(40):
        x, y = rnd.randrange(W), rnd.randrange(H)
        cv.px(x, y, P['navy_l'])
    return cv


def splash():
    cv = dark_bg()
    cx, cy = 160, 58
    # glow ring where the official campus logo sits
    for y in range(180):
        for x in range(320):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** .5
            if 30 < d <= 34 and (x + y) % 2 == 0: cv.px(x, y, P['navy_l'])
            if 34 < d <= 38 and (x + y) % 4 == 0: cv.px(x, y, P['navy_l'])
    cv.text_c("PENDIDIKAN TEKNIK INFORMATIKA DAN KOMPUTER", 160, 102, P['white'])
    cv.text_c("FKIP · UNIVERSITAS SEBELAS MARET", 160, 112, P['grey'])
    cv.hline(130, 190, 126, P['navy_l'])
    cv.px(160, 126, P['gold'])
    cv.text_c("MEMPERSEMBAHKAN", 160, 134, P['gold'])
    cv.text_c("AFRIDYA DEXA W  &  ESTU SETYOADI G", 160, 148, P['grey_l'])
    return cv


# ================================================================ LOADING
def loading_bg():
    cv = dark_bg(seed=9)
    # footprint trail (detective motif)
    def foot(x, y, c, flip):
        cv.ellipse(x + 2, y + 2, 2, 3, c)
        cv.rect(x + 1, y + 7, 3, 3, c)
        cv.px(x + 1, y + 7, T[:3] + (0,)) if False else None
        for tx in range(4):
            cv.px(x + tx + (0 if flip else 1), y - 2 + (1 if tx in (0, 3) else 0), c)
    steps = [(24 + i * 20, 140 - int(14 * math.sin(i / 2.2)) - (i % 2) * 7) for i in range(11)]
    for i, (x, y) in enumerate(steps):
        c = P['navy_l'] if i < 7 else P['grey_d']
        foot(x, y, c, i % 2)
    cv.text("MEMUAT", 246, 156, P['white'], shadow=P['navy_l'])
    return cv


def loading_icon_sheet():
    sheet = Canvas(24 * 4, 24)
    for f in range(4):
        a = f * math.pi / 2
        fr = Canvas(24, 24)
        m = magnifier(5, 5, qmark=False)
        ox = int(round(3 * math.cos(a))) + 3
        oy = int(round(3 * math.sin(a))) + 3
        fr.paste(m, ox, oy)
        # sparkle on alternate frames
        sx, sy = (19, 4) if f % 2 == 0 else (4, 19)
        for dx, dy in [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)]:
            fr.px(sx + dx, sy + dy, P['yellow'] if (dx or dy) else P['white'])
        sheet.paste(fr, f * 24, 0)
    return sheet


# ================================================================ LEVEL CARD
def kartu_level():
    W, H = 240, 60
    cv = Canvas(W, H)
    # ribbon tails
    for side in (0, 1):
        x0 = 2 if side == 0 else W - 36
        cv.rect(x0, 26, 34, 24, P['red_d'])
        cv.hline(x0, x0 + 33, 27, P['red'])
        for y in range(26, 50):
            d = abs(y - 38)
            for k in range(max(0, 8 - d)):
                cv.px(x0 + k if side == 0 else x0 + 33 - k, y, T)
    cv.rect(26, 46, 10, 6, P['purple']); cv.rect(W - 36, 46, 10, 6, P['purple'])
    # main band
    bx, by, bw, bh = 24, 16, 192, 36
    cv.rect(bx, by, bw, bh, P['navy'])
    cv.border(bx + 2, by + 2, bw - 4, bh - 4, P['gold'])
    cv.border(bx + 3, by + 3, bw - 6, bh - 6, P['orange'])
    cv.hline(bx, bx + bw - 1, by, P['navy_l'])
    for x, y in [(bx + 5, by + 5), (bx + bw - 7, by + 5), (bx + 5, by + bh - 7), (bx + bw - 7, by + bh - 7)]:
        cv.rect(x, y, 2, 2, P['yellow'])
    # top plate
    px_, py_, pw, ph = 84, 4, 72, 16
    cv.rect(px_, py_, pw, ph, P['gold'])
    cv.hline(px_, px_ + pw - 1, py_, P['yellow'])
    cv.hline(px_, px_ + pw - 1, py_ + ph - 1, P['orange'])
    cv.vline(px_, py_, py_ + ph - 1, P['yellow'])
    cv.vline(px_ + pw - 1, py_, py_ + ph - 1, P['orange'])
    cv.outline(P['black'])
    return cv


def kartu_filled(n, name):
    cv = kartu_level()
    cv.text_c(f"LEVEL {n}", 120, 8, P['choc'], shadow=P['orange'])
    t = fancy_text(name, 2, bands=('white', 'grey_l'), ow=1, depth=1, depth_c='navy_l', hi='white')
    cv.paste(t, 120 - t.w // 2, 29)
    return cv


# ================================================================ CURSORS
CUR = ["K...............", "KK..............", "KWK.............", "KWWK............",
       "KWWWK...........", "KWWWWK..........", "KWWWWWK.........", "KWWWWWWK........",
       "KWWWWWWWK.......", "KWWWWWWGGK......", "KWWWGGKKKKK.....", "KWWGKGGK........",
       "KWGK.KGGK.......", "KGK..KGGK.......", "KK....KGGK......", "K.....KKK......."]


def cursor_normal():
    cv = Canvas(16, 16)
    for y, row in enumerate(CUR):
        for x, ch in enumerate(row):
            if ch == 'K': cv.px(x, y, P['black'])
            if ch == 'W': cv.px(x, y, P['white'])
            if ch == 'G': cv.px(x, y, P['grey_l'])
    return cv


def cursor_interaksi():
    cv = Canvas(16, 16)
    m = magnifier(5, 4, qmark=False)
    cv.paste(m, 0, 0)
    return cv


# ================================================================ APP ICON
def app_icon():
    S = 64
    cv = Canvas(S, S)
    # rounded square
    r = 8
    for y in range(S):
        for x in range(S):
            cx = min(max(x, r), S - 1 - r); cy = min(max(y, r), S - 1 - r)
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                c = P['blue'] if y > 20 else P['blue_d']
                if 18 <= y <= 22 and (x + y) % 2 == 0: c = P['blue_d']
                cv.px(x, y, c)
    # school silhouette
    for y in range(34, 44):
        half = (y - 34) * 3 // 2 + 4
        cv.hline(32 - half, 32 + half, y, P['rust'])
    cv.hline(28, 36, 34, P['clay'])
    cv.rect(14, 44, 36, 14, P['cream'])
    cv.rect(14, 56, 36, 2, P['grey'])
    for wx in (17, 23, 37, 43):
        cv.rect(wx, 47, 4, 5, P['blue_d']); cv.px(wx, 47, P['cyan'])
    cv.rect(29, 48, 6, 8, P['brown'])
    # grass strip
    for y in range(57, 64):
        for x in range(S):
            if cv.a[y, x][3]:
                cv.px(x, y, P['green_m'] if y > 58 else P['green'])
    # big magnifier
    m = magnifier(12, 11)
    cv.paste(m, 22, 4)
    # outline rounded square
    out = Canvas(S, S)
    out.paste(cv, 0, 0)
    mask = out.filled()
    edge = mask & ~(np.roll(mask, 1, 0) & np.roll(mask, -1, 0) & np.roll(mask, 1, 1) & np.roll(mask, -1, 1))
    out.a[edge] = P['black']
    return out
