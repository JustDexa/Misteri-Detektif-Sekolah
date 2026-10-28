from maps import *


def outline_region(c, x, y, w, h):
    c.border(x, y, w, h, P['black'])


# ================================================================ small props
def motor(c, x, y, col='red'):
    c.rect(x + 2, y, 3, 22, P['black'])  # body line vertical (top-down)
    c.rect(x, y + 2, 7, 5, P['black']); c.rect(x + 1, y + 3, 5, 3, P['grey'])  # handlebar
    c.rect(x + 1, y + 7, 5, 11, P['black']); c.rect(x + 2, y + 8, 3, 9, P[col])
    c.px(x + 3, y + 9, P[Ld(col)])
    c.rect(x + 2, y + 18, 3, 5, P['black']); c.rect(x + 3, y + 19, 1, 3, P['grey_d'])
    c.rect(x + 2, y - 1, 3, 2, P['black']); c.px(x + 3, y, P['yellow'])


def sepeda(c, x, y):
    for wy in (y, y + 14):
        c.ellipse(x + 4, wy + 3, 2, 3, P['black']); c.px(x + 4, wy + 3, P['grey'])
    c.vline(x + 4, y + 5, y + 14, P['blue']); c.hline(x + 1, x + 7, y + 3, P['grey_d'])
    c.rect(x + 3, y + 9, 3, 3, P['choc'])


def kucing(c, x, y):
    rows = ["..K...K.", ".KOK.KOK", ".KOOOOOK", ".KOWOWOK", ".KOOOOOK..K", "..KOOOOKKOK",
            "..KOOWOOOOK", "..KOOOOOOK.", "...KKKKKK.."]
    key = {'K': 'black', 'O': 'orange', 'W': 'black'}
    for yy, r in enumerate(rows):
        for xx, ch in enumerate(r):
            if ch in key: c.px(x + xx, y + yy, P[key[ch]])
    c.px(x + 4, y + 3, P['cream']); c.px(x + 6, y + 3, P['cream'])
    c.px(x + 4, y + 6, P['white']); c.px(x + 5, y + 6, P['white'])


def pot(c, x, y, fl='pink'):
    c.rect(x + 3, y + 8, 10, 7, P['black']); c.rect(x + 4, y + 9, 8, 5, P['rust']); c.hline(x + 4, x + 11, y + 9, P['clay'])
    c.ellipse(x + 8, y + 5, 6, 5, P['black']); c.ellipse(x + 8, y + 5, 5, 4, P['green_m'])
    c.px(x + 6, y + 3, P['green']); c.px(x + 9, y + 2, P['green'])
    c.px(x + 5, y + 5, P[fl]); c.px(x + 10, y + 4, P[fl]); c.px(x + 8, y + 7, P[fl])


def trash(c, x, y, col='green_m'):
    c.rect(x + 3, y + 3, 10, 12, P['black']); c.rect(x + 4, y + 4, 8, 10, P[col])
    c.rect(x + 2, y + 2, 12, 3, P['black']); c.hline(x + 3, x + 12, y + 3, P[Ld(col)])
    c.vline(x + 6, y + 6, y + 12, P[Dk(col)]); c.vline(x + 9, y + 6, y + 12, P[Dk(col)])


def desk(c, x, y):
    # student desk + chair, top-down 3/4
    c.rect(x, y, 18, 10, P['black']); c.rect(x + 1, y + 1, 16, 5, P['tan']); c.rect(x + 1, y + 6, 16, 3, P['brown'])
    c.hline(x + 1, x + 16, y + 1, P['cream'])
    c.rect(x + 5, y + 10, 8, 6, P['black']); c.rect(x + 6, y + 11, 6, 3, P['navy_l']); c.hline(x + 6, x + 11, y + 14, P['navy'])
    c.rect(x + 3, y + 2, 4, 3, P['white']); c.px(x + 4, y + 3, P['grey'])  # book


def bench(c, x, y, w=32):
    c.rect(x, y, w, 7, P['black']); c.rect(x + 1, y + 1, w - 2, 3, P['brown']); c.hline(x + 1, x + w - 2, y + 1, P['tan'])
    c.rect(x + 1, y + 4, w - 2, 2, P['brown_d'])
    c.rect(x + 2, y + 7, 2, 3, P['black']); c.rect(x + w - 4, y + 7, 2, 3, P['black'])


def lamp(m, tx, ty):
    c, o = m.base, m.over
    x, y = int(tx * TS), int(ty * TS)
    shadow(c, x - 3, y - 1, 8, 2)
    c.rect(x - 1, y - 20, 3, 20, P['navy']); c.px(x, y - 19, P['grey_d'])
    o.rect(x - 4, y - 27, 9, 7, P['black']); o.rect(x - 3, y - 26, 7, 5, P['yellow']); o.px(x - 2, y - 25, P['white'])
    o.hline(x - 4, x + 4, y - 28, P['navy'])
    m.collide(tx - .15, ty - .3, .3, .3)


# ================================================================ LEVEL 1 — SEKOLAH
def level1():
    m = Map('sekolah', 'g', wall_face='cream', wall_cap='rust', base_c='grey')
    m.fill(0, 0, 29, 6, '#')
    m.fill(1, 1, 9, 5, 'w'); m.fill(11, 1, 18, 5, 'k'); m.fill(20, 1, 28, 5, 'k')
    m.fill(4, 6, 5, 6, 'w'); m.fill(13, 6, 16, 6, 'k'); m.fill(23, 6, 24, 6, 'k')
    m.fill(0, 7, 0, 17, 'f'); m.fill(29, 7, 29, 17, 'f'); m.fill(0, 17, 29, 17, 'f')
    m.fill(8, 7, 21, 16, 'p'); m.fill(1, 11, 7, 16, 'a'); m.fill(22, 11, 28, 16, 't')
    m.render_floor(); m.render_walls()
    c = m.base
    # --- gate (row 17 center)
    gx = 13 * TS
    c.rect(gx, 17 * TS, 64, 16, P['grey_d'])
    for xx in range(gx + 2, gx + 64, 4):
        c.vline(xx, 17 * TS - 6, 17 * TS + 15, P['navy']); c.px(xx, 17 * TS - 7, P['gold'])
    c.hline(gx, gx + 63, 17 * TS + 2, P['navy']); c.hline(gx, gx + 63, 17 * TS + 10, P['navy'])
    # --- Kelas A
    c.rect(3 * TS, 3, 5 * TS, 9, P['black']); c.rect(3 * TS + 1, 4, 5 * TS - 2, 7, P['green_d'])
    c.text("KELAS A", 3 * TS + 22, 5, P['white'])
    for i, (dx, dy) in enumerate([(2, 2.3), (4.6, 2.3), (7.2, 2.3), (2, 3.9), (4.6, 3.9), (7.2, 3.9)]):
        desk(c, int(dx * TS) - 2, int(dy * TS))
        m.collide(dx - .1, dy + .05, 1.1, .55)
    table(m, 1.2, 1.0, 1.6, .9, 'brown', 'brown_d')  # teacher desk
    # shelf right
    c.rect(9 * TS, 1 * TS, 14, 26, P['black']); c.rect(9 * TS + 1, TS + 1, 12, 24, P['brown'])
    for yy in (TS + 7, TS + 15):
        c.hline(9 * TS + 1, 9 * TS + 12, yy, P['brown_d'])
    for i, col in enumerate(['red', 'blue', 'green', 'gold', 'purple']):
        c.rect(9 * TS + 2 + i * 2, TS + 2, 2, 5, P[col]); c.rect(9 * TS + 2 + i * 2, TS + 9, 2, 5, P[['gold', 'red', 'blue', 'green', 'white'][i]])
    m.collide(9, 1, .9, 1.7)
    # --- Lorong / ruang tengah
    c.rect(11 * TS + 2, 1 * TS, 24, 22, P['black']); c.rect(11 * TS + 3, TS + 1, 22, 20, P['brown_d'])
    c.rect(11 * TS + 4, TS + 2, 20, 14, P['cyan']); c.dither_rect(11 * TS + 4, TS + 2, 20, 14, P['blue'])
    for i in range(3):
        c.rect(11 * TS + 6 + i * 6, TS + 6, 4, 6, P['gold']); c.rect(11 * TS + 7 + i * 6, TS + 12, 2, 3, P['orange'])
    m.collide(11, 1, 1.7, 1.3); m.obj('lemari_piala', 11, 1, 1.7, 1.5, kind='inspect')
    # bulletin board on top wall
    c.rect(14 * TS, 2, 40, 12, P['black']); c.rect(14 * TS + 1, 3, 38, 10, P['clay'])
    for i, col in enumerate(['white', 'yellow', 'pink', 'white']):
        c.rect(14 * TS + 3 + i * 9, 5, 7, 6, P[col]); c.px(14 * TS + 6 + i * 9, 5, P['red'])
    m.obj('papan_pengumuman', 14, 0, 2.5, 1.4, kind='inspect')
    pot(c, 17 * TS + 8, 1 * TS); m.collide(17.6, 1.4, .8, .6)
    pot(c, 11 * TS, 4 * TS, 'yellow'); m.collide(11.1, 4.4, .8, .6)
    # --- Kantin
    table(m, 20.6, 1.0, 5.2, 1.0, 'grey_l', 'grey')  # etalase
    for i in range(5):
        c.rect(int(20.8 * TS) + i * 16, TS + 2, 12, 6, P['cyan']); c.px(int(20.8 * TS) + i * 16 + 3, TS + 4, [P['orange'], P['yellow'], P['red'], P['green'], P['white']][i])
    m.obj('etalase', 20.6, 1.0, 5.2, 1.3, kind='inspect')
    sign_wall(m, 27, .1, "MENU", 'green_d', 'white')
    c.rect(26 * TS + 4, 1 * TS + 2, 36, 12, P['black']); c.rect(26 * TS + 5, TS + 3, 34, 10, P['green_d'])
    c.text("NASI", 26 * TS + 8, TS + 4, P['yellow'])
    for tx in (21.3, 25.3):
        table(m, tx, 3.0, 2.8, 1.0, 'cream', 'tan')
        bench(c, int(tx * TS), int(4.2 * TS), int(2.8 * TS))
        m.collide(tx, 4.2, 2.8, .45)
    sign_wall(m, 2.5, 6.3, "KELAS A")
    sign_wall(m, 20.5, 6.3, "KANTIN")
    sign_wall(m, 10, 6.3, "SD TUNAS BANGSA", 'green_d', 'yellow')
    # --- halaman
    fx, fy = int(11.5 * TS), int(9 * TS)
    c.rect(fx - 4, fy - 2, 9, 4, P['grey']); c.hline(fx - 4, fx + 4, fy - 2, P['grey_l'])
    c.rect(fx, fy - 40, 2, 38, P['grey_l'])
    m.over.rect(fx, fy - 70, 2, 30, P['grey_l'])
    for xx in range(16):
        dy = int(round(1.2 * math.sin(xx / 2.5)))
        for yy in range(10):
            m.over.px(fx + 2 + xx, fy - 70 + yy + dy, P['red'] if yy < 5 else P['white'])
    m.collide(11.2, 8.7, .6, .4); m.obj('tiang_bendera', 11.1, 8.4, .8, .7, kind='inspect')
    tree(m, 3, 9.7); tree(m, 26, 9.7)
    for bx in (19, 21):
        bush(m, bx + 3, 7)
    bench(c, int(17 * TS), int(15.9 * TS), 40); m.collide(17, 15.9, 2.5, .5)
    trash(c, 21 * TS, int(7.5 * TS), 'blue'); m.collide(21.1, 7.8, .8, .6)
    # --- parkiran
    for i in range(4):
        c.vline(int((1.5 + i * 1.5) * TS), 11 * TS + 4, 13 * TS, P['white'])
    for i, col in enumerate(['red', 'blue', 'grey_l']):
        motor(c, int((1.9 + i * 1.5) * TS), int(11.4 * TS), col)
    m.collide(1.8, 11.3, 4.4, 1.5); m.obj('motor', 1.8, 11.3, 4.4, 1.7, kind='inspect')
    sepeda(c, int(1.5 * TS), int(14.3 * TS)); sepeda(c, int(2.4 * TS), int(14.3 * TS))
    m.collide(1.3, 14.3, 1.4, 1.5)
    kucing(c, int(5.2 * TS), int(14.6 * TS)); m.obj('kucing', 5, 14.3, 1, 1, kind='inspect')
    sign_post(m, 7.3, 10.0, "PARKIR")
    # --- gudang belakang (shed)
    sx, sy, sw = 23 * TS, 11 * TS, 5 * TS
    c.rect(sx, sy, sw, 12, P['black'])
    for yy in range(sy + 1, sy + 11):
        c.hline(sx + 1, sx + sw - 2, yy, P['rust'] if (yy - sy) % 3 else P['red_d'])
    c.rect(sx, sy + 12, sw, 30, P['black']); c.rect(sx + 1, sy + 12, sw - 2, 29, P['grey'])
    for xx in range(sx + 4, sx + sw - 2, 6):
        c.vline(xx, sy + 13, sy + 40, P['grey_d'])
    dx0 = int(24.8 * TS)
    c.rect(dx0, sy + 18, 18, 24, P['black']); c.rect(dx0 + 1, sy + 19, 16, 23, P['brown_d'])
    c.vline(dx0 + 9, sy + 19, sy + 41, P['choc']); c.px(dx0 + 12, sy + 30, P['gold'])
    c.text("GUDANG", sx + 12, sy + 3, P['white'])
    m.collide(23, 11, 5, 2.6)
    m.obj('gudang_pintu', 24.7, 13.3, 1.3, 1.0, kind='door')
    trash(c, 27 * TS + 4, int(14.2 * TS), 'grey'); m.collide(27.3, 14.5, .8, .6)
    # item spawn points (appear via script)
    m.obj('item_sapu', 26.4, 14.4, 1, 1, kind='item', item='sapu')
    m.obj('item_poster1', 23.2, 14.6, 1, 1, kind='item', item='poster1')
    m.obj('item_jejak', 22.4, 13.2, 1, 1, kind='item', item='jejak')
    # --- NPC / zones
    m.spawn = (15, 16.4)
    m.npc('bu_rina', 13.4, 14.3)
    m.npc('pak_joko', 14.5, 9.6)
    m.npc('dodi', 9.3, 12.8)
    m.npc('nisa', 7.8, 5.6)
    m.zone('parkiran', 1, 11, 7, 6)
    m.zone('kantin', 20, 1, 9, 6)
    m.zone('gudang', 22, 11, 7, 6)
    return m


# ================================================================ LEVEL 2 — TAMAN
def fountain(m, tx, ty):
    c = m.base
    cx, cy = int(tx * TS), int(ty * TS)
    c.ellipse(cx, cy, 38, 26, P['black']); c.ellipse(cx, cy, 37, 25, P['grey_l'])
    c.ellipse(cx, cy + 1, 33, 21, P['black']); c.ellipse(cx, cy + 1, 32, 20, P['blue'])
    for i in range(30):
        a = i / 30 * 6.28
        c.px(cx + int(24 * math.cos(a)), cy + int(14 * math.sin(a)) + 1, P['cyan'])
    c.ellipse(cx, cy - 2, 10, 7, P['black']); c.ellipse(cx, cy - 2, 9, 6, P['grey_l'])
    c.ellipse(cx, cy - 3, 6, 4, P['cyan'])
    o = m.over
    o.rect(cx - 2, cy - 22, 5, 18, P['black']); o.rect(cx - 1, cy - 21, 3, 17, P['grey_l'])
    for dx in range(-8, 9, 2):
        o.px(cx + dx, cy - 22 + abs(dx) // 2, P['cyan'])
        o.px(cx + dx, cy - 21 + abs(dx) // 2 + (dx % 4 == 0), P['white'])
    o.ellipse(cx, cy - 24, 5, 3, P['white']); o.ellipse(cx, cy - 24, 3, 2, P['cyan'])
    m.collide(tx - 2.2, ty - 1.4, 4.4, 2.9)
    m.obj('air_mancur', tx - 2.4, ty - 1.6, 4.8, 3.3, kind='inspect')


def gazebo(m, tx, ty, tw=5, th=4):
    c, o = m.base, m.over
    x, y, w, h = int(tx * TS), int(ty * TS), int(tw * TS), int(th * TS)
    # posts
    for px_ in (x + 4, x + w - 7):
        for py_ in (y + 20, y + h - 6):
            c.rect(px_, py_ - 18, 3, 18, P['brown_d']); c.vline(px_, py_ - 18, py_, P['black'])
    # roof (over layer)
    for yy in range(0, 30):
        half = w // 2 + 6 - (29 - yy) * (w // 2 - 4) // 30
        o.hline(x + w // 2 - half, x + w // 2 + half, y - 8 + yy, P['rust'] if yy % 4 else P['red_d'])
    o.hline(x - 6, x + w + 5, y + 22, P['black']); o.hline(x - 6, x + w + 5, y + 21, P['brown_d'])
    o.rect(x + w // 2 - 3, y - 12, 6, 5, P['black']); o.rect(x + w // 2 - 2, y - 11, 4, 3, P['gold'])
    for yy in range(0, 30):
        half = w // 2 + 6 - (29 - yy) * (w // 2 - 4) // 30
        o.px(x + w // 2 - half, y - 8 + yy, P['black']); o.px(x + w // 2 + half, y - 8 + yy, P['black'])
    o.hline(x + w // 2 - 10, x + w // 2 + 10, y - 8, P['black'])
    # bench inside
    bench(c, x + 14, y + h - 22, w - 28)
    m.collide(tx + .2, ty + th - 1.1, .3, .3); m.collide(tx + tw - .45, ty + th - 1.1, .3, .3)
    m.collide(tx + .8, ty + th - 1.4, tw - 1.6, .5)


def pos_petugas(m, tx, ty):
    c = m.base
    x, y = int(tx * TS), int(ty * TS)
    c.rect(x, y, 40, 12, P['black'])
    for yy in range(y + 1, y + 11): c.hline(x + 1, x + 38, yy, P['green_m'] if (yy - y) % 3 else P['green_d'])
    c.rect(x + 2, y + 12, 36, 20, P['black']); c.rect(x + 3, y + 12, 34, 19, P['cream'])
    c.rect(x + 6, y + 15, 12, 8, P['blue']); c.px(x + 7, y + 16, P['cyan'])
    c.rect(x + 23, y + 16, 10, 15, P['brown'])
    c.text("POS", x + 10, y + 3, P['white'])
    m.collide(tx, ty, 2.5, 2)


def cart_es(c, x, y):
    c.rect(x, y + 4, 30, 16, P['black']); c.rect(x + 1, y + 5, 28, 10, P['cyan'])
    c.rect(x + 1, y + 15, 28, 4, P['blue_d'])
    c.rect(x + 3, y + 7, 24, 4, P['white']); c.text("ES", x + 10, y + 7, P['red'])
    c.rect(x + 2, y - 10, 2, 14, P['grey_d']); c.rect(x + 26, y - 10, 2, 14, P['grey_d'])
    c.rect(x - 2, y - 14, 34, 5, P['black']); c.rect(x - 1, y - 13, 32, 3, P['red'])
    for xx in range(x, x + 30, 6): c.rect(xx, y - 13, 3, 3, P['white'])
    c.ellipse(x + 5, y + 21, 3, 3, P['black']); c.ellipse(x + 25, y + 21, 3, 3, P['black'])


def level2():
    m = Map('taman', 'g', wall_face='green_m', wall_cap='green_d')
    m.fill(0, 0, 29, 0, 'h'); m.fill(0, 17, 29, 17, 'h'); m.fill(0, 0, 0, 17, 'h'); m.fill(29, 0, 29, 17, 'h')
    m.fill(1, 12, 28, 13, 'j'); m.fill(14, 1, 15, 16, 'j')
    m.fill(9, 1, 20, 6, 'j'); m.fill(10, 2, 19, 5, 'g')
    m.fill(1, 6, 6, 11, 'a'); m.fill(7, 8, 13, 9, 'j')
    m.fill(21, 6, 28, 11, 'd'); m.fill(16, 8, 20, 9, 'j')
    m.fill(14, 17, 15, 17, 'j')
    m.render_floor(); m.render_walls()
    c = m.base
    # entrance gate arch (bottom)
    gx = 14 * TS
    m.over.rect(gx - 6, 17 * TS - 30, 4, 34, P['brown_d']); m.over.rect(gx + 34, 17 * TS - 30, 4, 34, P['brown_d'])
    tw_ = text_w("TAMAN KOTA"); bw_ = tw_ + 10; bx_ = gx + 16 - bw_ // 2; by_ = 17 * TS - 38
    m.over.rect(bx_, by_, bw_, 13, P['black']); m.over.rect(bx_ + 1, by_ + 1, bw_ - 2, 11, P['brown'])
    m.over.hline(bx_ + 1, bx_ + bw_ - 2, by_ + 1, P['tan']); m.over.hline(bx_ + 1, bx_ + bw_ - 2, by_ + 11, P['brown_d'])
    m.over.text("TAMAN KOTA", bx_ + 5, by_ + 3, P['cream'])
    m.collide(14, 17, 2, 1)
    fountain(m, 14.5, 3.8)
    gazebo(m, 22, 6.6, 6, 4.8)
    pos_petugas(m, 6, 14.3)
    cart_es(c, int(19 * TS), int(14 * TS)); m.collide(18.8, 14.2, 2.1, 1.3)
    # parkir area
    for i in range(4):
        c.vline(int((1.5 + i * 1.5) * TS), 6 * TS + 2, 8 * TS, P['white'])
    for i, col in enumerate(['blue', 'red', 'green']):
        motor(c, int((1.9 + i * 1.5) * TS), int(6.3 * TS), col)
    m.collide(1.8, 6.1, 4.4, 1.6)
    c.rect(1 * TS, 10 * TS + 8, 6 * TS, 3, P['gold']); c.dither_rect(1 * TS, 10 * TS + 8, 6 * TS, 3, P['black'])
    sign_post(m, 5.6, 9.7, "PARKIR")
    sign_post(m, 23.5, 12.1, "GAZEBO")
    # trees & bushes
    for tx, ty in [(3, 3.8), (7, 2.8), (24, 3.5), (27.5, 5.2), (25, 16.3), (2.5, 16.2), (21, 3)]:
        tree(m, tx, ty)
    for bx, by in [(9, 7), (12, 10), (18, 10.5), (16.5, 6.5), (1, 12.0) if False else (8, 10.5)]:
        bush(m, bx, by)
    for x in (4, 11, 18, 26):
        bench(c, x * TS, int(11.1 * TS), 32); m.collide(x, 11.1, 2, .5)
    lamp(m, 13.4, 12.2); lamp(m, 16.6, 12.2); lamp(m, 8, 14)
    trash(c, 17 * TS, int(15.3 * TS)); m.collide(17.1, 15.6, .8, .6)
    # layangan on the ground? kite in the sky -> over layer near kid
    o = m.over
    kx, ky = int(9.5 * TS), int(1.2 * TS)
    for i in range(6):
        o.hline(kx - i, kx + i, ky + i, P['red'] if i < 3 else P['gold'])
    for i in range(6):
        o.hline(kx - (5 - i), kx + (5 - i), ky + 6 + i, P['gold'] if i < 3 else P['red'])
    o.line(kx, ky + 12, kx - 8, ky + 40, P['white'])
    # items
    m.obj('item_daftar', 16.8, 3.2, 1, 1, kind='item', item='daftar')
    m.obj('item_selang', 26.3, 11.2, 1, 1, kind='item', item='selang')
    m.obj('item_poster2', 21.4, 11.2, 1, 1, kind='item', item='poster2')
    m.spawn = (15, 16.6)
    m.npc('pak_harun', 9.6, 15.9)
    m.npc('bu_wati', 18.2, 15.4)
    m.npc('mas_parkir', 3.0, 9.6)
    m.npc('anak_layangan', 9.2, 4.2)
    m.npc('bima', 25.0, 9.9)
    m.zone('parkir', 1, 6, 6, 5)
    m.zone('air_mancur', 10, 1, 10, 5.4)
    m.zone('gazebo', 21, 6, 8, 5.6)
    return m


# ================================================================ LEVEL 3 — PASAR
def kios(m, tx, ty, tw, th, awning=('red', 'white'), goods='sayur', label=None):
    c, o = m.base, m.over
    x, y, w, h = int(tx * TS), int(ty * TS), int(tw * TS), int(th * TS)
    table(m, tx, ty + .4, tw, th - .4, 'tan', 'brown')
    r = random.Random(x + y)
    gcols = {'sayur': ['green', 'green_m', 'orange', 'red'], 'buah': ['yellow', 'orange', 'red', 'green'],
             'kelontong': ['white', 'blue', 'red', 'gold'], 'tahu': ['cream', 'yellow', 'white', 'tan'],
             'kain': ['purple', 'blue', 'red', 'gold']}[goods]
    for i in range(int(w / 7)):
        gx = x + 3 + i * 7
        c.ellipse(gx + 2, y + 10, 3, 2, P['black']); c.ellipse(gx + 2, y + 10, 2, 1, P[r.choice(gcols)])
        c.px(gx + 1, y + 9, P['white'])
    # awning on over layer
    o.rect(x - 2, y - 12, w + 4, 11, P['black'])
    for xx in range(x - 1, x + w + 1):
        col = P[awning[((xx - x) // 6) % 2]]
        o.vline(xx, y - 11, y - 3, col)
    for xx in range(x - 1, x + w + 1, 6):
        o.rect(xx, y - 3, 3, 2, P[awning[0]])
    if label:
        o.rect(x + w // 2 - text_w(label) // 2 - 2, y - 11, text_w(label) + 4, 9, P['black'])
        o.text(label, x + w // 2 - text_w(label) // 2, y - 10, P['yellow'])


def becak(c, x, y):
    c.ellipse(x + 6, y + 18, 5, 5, P['black']); c.ellipse(x + 26, y + 18, 5, 5, P['black'])
    c.ellipse(x + 6, y + 18, 3, 3, P['grey']); c.ellipse(x + 26, y + 18, 3, 3, P['grey'])
    c.rect(x, y, 22, 14, P['black']); c.rect(x + 1, y + 1, 20, 8, P['blue']); c.rect(x + 1, y + 9, 20, 4, P['red'])
    c.rect(x - 1, y - 6, 24, 7, P['black']); c.rect(x, y - 5, 22, 5, P['blue_d'])
    c.line(x + 22, y + 10, x + 30, y + 12, P['black'], 2)
    c.rect(x + 27, y + 4, 6, 3, P['black'])


def karung(c, x, y):
    c.ellipse(x + 6, y + 7, 6, 6, P['black']); c.ellipse(x + 6, y + 7, 5, 5, P['cream'])
    c.hline(x + 3, x + 9, y + 2, P['tan']); c.px(x + 6, y + 1, P['brown'])


def level3():
    m = Map('pasar', 's', wall_face='grey_l', wall_cap='navy_l', base_c='grey_d')
    m.fill(0, 0, 29, 0, '#'); m.fill(0, 17, 29, 17, '#'); m.fill(0, 0, 0, 17, '#'); m.fill(29, 0, 29, 17, '#')
    m.fill(1, 17, 3, 17, 's')
    m.render_floor(); m.render_walls()
    c = m.base
    m.collide(1, 17, 3, 1)
    # entrance mat
    c.rect(1 * TS, 17 * TS, 3 * TS, 16, P['grey_d']); c.dither_rect(1 * TS, 17 * TS, 3 * TS, 16, P['navy_l'])
    sign_wall(m, 19.6, .15, "PASAR RAKYAT", 'red_d', 'white')
    # top row stalls (rows 1..2)
    kios(m, 1.3, 1.2, 6, 1.8, ('green', 'white'), 'tahu', 'TAHU')
    kios(m, 9, 1.2, 8, 1.8, ('blue', 'white'), 'kelontong', 'KELONTONG')
    # kios ikan (building with door) top-right
    x, y = 22 * TS, 1 * TS
    c.rect(x, y - 2, 7 * TS, 40, P['black']); c.rect(x + 1, y - 1, 7 * TS - 2, 38, P['blue_d'])
    for xx in range(x + 3, x + 7 * TS - 3, 8):
        c.vline(xx, y + 10, y + 36, P['navy'])
    c.rect(x + 6, y + 1, 7 * TS - 12, 9, P['black']); c.rect(x + 7, y + 2, 7 * TS - 14, 7, P['white'])
    c.text("KIOS IKAN", x + 7 * TS // 2 - text_w("KIOS IKAN") // 2, y + 3, P['blue_d'])
    dxp = int(25 * TS)
    c.rect(dxp, y + 14, 32, 24, P['black']); c.rect(dxp + 1, y + 15, 30, 23, P['grey_d'])
    for yy in range(y + 16, y + 38, 3): c.hline(dxp + 1, dxp + 30, yy, P['grey'])
    m.collide(22, .9, 7, 1.5)
    m.obj('kios_ikan_pintu', 24.8, 2.3, 2.4, 1.1, kind='door')
    # middle block rows 6..8
    kios(m, 3, 6.4, 7, 1.8, ('orange', 'cream'), 'buah')
    kios(m, 12, 6.4, 6, 1.8, ('purple', 'white'), 'kain', 'KAIN')
    kios(m, 20.5, 6.4, 7, 1.8, ('red', 'white'), 'kelontong')
    # bottom block rows 12..13
    kios(m, 2.5, 11.6, 6, 1.8, ('green', 'cream'), 'sayur', 'SAYUR')
    kios(m, 10.5, 11.6, 6, 1.8, ('gold', 'white'), 'buah', 'BUAH')
    kios(m, 18.5, 11.6, 5, 1.8, ('blue', 'cream'), 'kelontong')
    becak(c, 25 * TS, 13 * TS); m.collide(24.9, 12.7, 2.2, 1.6)
    for kx, ky in [(8.2, 4.1), (17.5, 4.0), (1.2, 9.6), (27.8, 9.6), (24.2, 11.9), (17.2, 15.6)]:
        karung(c, int(kx * TS), int(ky * TS)); m.collide(kx, ky + .2, .8, .6)
    for tx, ty in [(10.6, 15.5), (27.5, 3.6)]:
        trash(c, int(tx * TS), int(ty * TS), 'green_m'); m.collide(tx + .1, ty + .3, .8, .6)
    m.spawn = (2.6, 16.4)
    m.npc('bu_sri', 5.2, 14.8)
    m.npc('pedagang_buah', 12.8, 14.6)
    m.npc('ibu_pembeli', 9.2, 10.5)
    m.npc('anak_pedagang', 21.0, 15.2)
    m.npc('tukang_becak', 27.6, 15.9)
    m.npc('tari', 16.2, 5.1)
    return m


# ================================================================ LEVEL 4 — MUSEUM
def vitrin(m, tx, ty, inner='gold'):
    c = m.base
    x, y = int(tx * TS), int(ty * TS)
    c.rect(x, y, 22, 22, P['black']); c.rect(x + 1, y + 12, 20, 9, P['brown_d']); c.hline(x + 1, x + 20, y + 12, P['brown'])
    c.rect(x + 1, y + 1, 20, 11, P['cyan']); c.dither_rect(x + 1, y + 1, 20, 11, P['white'])
    c.ellipse(x + 11, y + 8, 4, 3, P[inner]); c.px(x + 10, y + 7, P['white'])
    m.collide(tx, ty + .3, 1.4, 1.1)


def fossil(m, tx, ty):
    c, o = m.base, m.over
    x, y = int(tx * TS), int(ty * TS)
    c.rect(x - 4, y + 14, 72, 14, P['black']); c.rect(x - 3, y + 15, 70, 12, P['grey']); c.hline(x - 3, x + 66, y + 15, P['grey_l'])
    lay = Canvas(o.w, o.h)
    bone = P['cream']
    # spine: tail (left) -> neck (right)
    pts = [(x + i * 3, y + 4 - int(6 * math.sin(i / 22 * math.pi)) - (i // 14) * 0) for i in range(22)]
    for i, (px_, py_) in enumerate(pts):
        th = 2 if i < 6 else 3
        lay.rect(px_, py_, 3, th, bone)
    # neck + skull
    lay.line(x + 63, y - 1, x + 68, y - 10, bone, 3)
    lay.rect(x + 64, y - 16, 12, 7, bone); lay.rect(x + 72, y - 12, 6, 4, bone)
    lay.px(x + 69, y - 14, P['black'])
    for tth in range(4): lay.px(x + 71 + tth, y - 9, P['grey_l'])
    # ribs
    for i in range(6):
        rx = x + 30 + i * 5
        top_y = pts[min(21, (rx - x) // 3)][1] + 2
        lay.line(rx, top_y, rx - 2, top_y + 8 - abs(i - 2), bone, 1)
    # legs
    for lx in (x + 26, x + 52):
        ty_ = pts[(lx - x) // 3][1] + 2
        lay.line(lx, ty_, lx - 3, y + 9, bone, 2); lay.line(lx - 3, y + 9, lx, y + 15, bone, 2)
        lay.hline(lx - 1, lx + 3, y + 15, bone)
    lay.outline(P['black'])
    o.paste(lay, 0, 0)
    m.collide(tx - .25, ty + .85, 4.5, .9)
    m.obj('fosil', tx - .3, ty - .5, 4.6, 2.3, kind='inspect')


def batik_frame(m, tx, ty, col):
    c = m.base
    x, y = int(tx * TS), int(ty * TS)
    c.rect(x, y, 28, 26, P['black']); c.rect(x + 1, y + 1, 26, 24, P['brown_d'])
    c.rect(x + 3, y + 3, 22, 18, P[col])
    for yy in range(y + 4, y + 21, 3):
        for xx in range(x + 4, x + 25, 3):
            if (xx + yy) % 2: c.px(xx, yy, P['gold'])
            else: c.px(xx, yy, P[Dk(col)])
    c.rect(x + 3, y + 22, 3, 4, P['black']); c.rect(x + 22, y + 22, 3, 4, P['black'])
    m.collide(tx, ty + .8, 1.75, .8)


def rope(c, x0, x1, y):
    for x in range(x0, x1 + 1, 24):
        c.rect(x, y - 10, 3, 12, P['black']); c.rect(x + 1, y - 9, 1, 10, P['gold'])
    for x in range(x0, x1):
        yy = y - 7 + int(2 * math.sin((x - x0) / 24 * math.pi) ** 2)
        c.px(x, yy, P['red'])


def level4():
    m = Map('museum', 'm', wall_face='grey_l', wall_cap='navy_l', base_c='navy')
    g = m.fill
    g(0, 0, 29, 0, '#'); g(0, 17, 29, 17, '#'); g(0, 0, 0, 17, '#'); g(29, 0, 29, 17, '#')
    g(0, 7, 10, 7, '#'); g(10, 0, 10, 7, '#'); g(4, 7, 5, 7, 'm')
    g(11, 0, 18, 5, '#')
    g(19, 0, 19, 7, '#'); g(19, 7, 29, 7, '#'); g(24, 7, 25, 7, 'm')
    g(0, 10, 9, 10, '#'); g(9, 10, 9, 16, '#'); g(9, 13, 9, 14, 'm')
    g(20, 10, 29, 10, '#'); g(20, 10, 20, 16, '#'); g(20, 13, 20, 14, 'm')
    g(12, 12, 17, 16, 'c'); g(14, 8, 15, 11, 'c')
    m.render_floor(); m.render_walls()
    c = m.base
    # gudang door (on face of wall block row 5)
    dx0 = 14 * TS
    c.rect(dx0 - 2, 5 * TS - 4, 36, 20, P['black']); c.rect(dx0, 5 * TS - 2, 32, 18, P['brown_d'])
    c.vline(dx0 + 16, 5 * TS - 2, 5 * TS + 15, P['choc']); c.px(dx0 + 19, 5 * TS + 6, P['gold'])
    c.rect(dx0 + 4, 5 * TS - 12, 24, 9, P['black']); c.text("GUDANG", dx0 + 5, 5 * TS - 11, P['white']) if False else None
    sign_wall(m, 15, 4.25, "GUDANG", 'red_d', 'white')
    m.obj('gudang_museum_pintu', 13.8, 5.4, 2.4, 1.2, kind='door')
    sign_wall(m, 8.2, 7.3, "R. FOSIL", 'navy', 'yellow')
    sign_wall(m, 21.6, 7.3, "R. BATIK", 'navy', 'yellow')
    sign_wall(m, 4.5, 10.3, "SUVENIR", 'purple', 'white')
    sign_wall(m, 24.5, 10.3, "KAFE", 'brown_d', 'cream')
    sign_wall(m, 15, 17.3, "MUSEUM KOTA", 'navy', 'gold') if False else None
    # ruang fosil
    fossil(m, 2.5, 2.4)
    vitrin(m, 7.6, 1.2, 'grey_l'); vitrin(m, 7.6, 4.2, 'tan'); vitrin(m, 1.2, 4.8, 'brown')
    m.obj('vitrin_fosil', 7.5, 1.1, 1.6, 1.6, kind='inspect')
    # ruang batik
    for i, col in enumerate(['blue_d', 'rust', 'green_d', 'purple']):
        batik_frame(m, 20.6 + i * 2.1, 1.2, col)
    rope(c, int(20.4 * TS), int(28.5 * TS), int(3.5 * TS))
    m.collide(20.4, 3.0, 8.3, .3)
    m.obj('batik', 20.5, 1.1, 8.3, 2.3, kind='inspect')
    vitrin(m, 27.4, 5.0, 'gold')
    # pos satpam desk (hallway, left of gudang door)
    table(m, 11.3, 6.3, 2.2, 1.0, 'grey_l', 'grey_d')
    c.rect(int(11.6 * TS), int(6.4 * TS), 10, 6, P['black']); c.rect(int(11.6 * TS) + 1, int(6.4 * TS) + 1, 8, 4, P['blue'])
    sign_wall(m, 12.4, 5.5, "SATPAM", 'blue_d', 'white') if False else None
    m.obj('pos_satpam_meja', 11.3, 6.2, 2.2, 1.1, kind='inspect')
    # lobi
    table(m, 16.2, 14.4, 2.6, 1.0, 'brown', 'brown_d')  # resepsionis
    c.rect(int(16.5 * TS), int(14.5 * TS), 12, 5, P['white'])
    for tx, ty in [(10.3, 10.6), (18.7, 10.6), (10.3, 15.4), (18.7, 15.4)]:
        pot(c, int(tx * TS), int(ty * TS), 'yellow'); m.collide(tx + .1, ty + .4, .8, .6)
    # paintings on hallway/lobby walls
    for px_, col in [(2, 'blue'), (7, 'green_m'), (22, 'orange'), (27, 'purple')]:
        c.rect(px_ * TS, 10 * TS + 2, 24, 12, P['black']); c.rect(px_ * TS + 1, 10 * TS + 3, 22, 10, P['gold'])
        c.rect(px_ * TS + 3, 10 * TS + 5, 18, 6, P[col]) if False else None
    for px_, col in [(1.5, 'blue'), (26.5, 'purple')]:
        x = int(px_ * TS)
        c.rect(x, 7 * TS + 2, 22, 11, P['black']); c.rect(x + 1, 7 * TS + 3, 20, 9, P['gold'])
        c.rect(x + 3, 7 * TS + 4, 16, 7, P[col]); c.px(x + 8, 7 * TS + 6, P['yellow'])
    # suvenir shop
    for sy in (11.2, 14.0):
        table(m, 1.4, sy, 5.5, .9, 'purple', 'magenta')
        for i in range(7):
            c.rect(int(1.6 * TS) + i * 12, int(sy * TS) + 2, 6, 5, P[['yellow', 'red', 'cyan', 'white', 'green', 'orange', 'pink'][i]])
    m.obj('rak_suvenir', 1.4, 11.2, 5.5, 1.2, kind='inspect')
    # kafe
    for tx, ty in [(22, 11.6), (25.5, 11.6), (22, 14.4), (25.5, 14.4)]:
        x, y = int(tx * TS), int(ty * TS)
        c.ellipse(x + 10, y + 6, 9, 6, P['black']); c.ellipse(x + 10, y + 5, 8, 5, P['white']); c.ellipse(x + 10, y + 5, 2, 1, P['brown'])
        c.rect(x - 4, y + 3, 5, 7, P['black']); c.rect(x - 3, y + 4, 3, 5, P['red'])
        c.rect(x + 20, y + 3, 5, 7, P['black']); c.rect(x + 21, y + 4, 3, 5, P['red'])
        m.collide(tx - .2, ty + .1, 1.8, .7)
    table(m, 27.2, 11.2, 1.6, 2.4, 'brown', 'brown_d')
    m.obj('meja_kafe', 27.2, 11.2, 1.6, 2.5, kind='inspect')
    m.spawn = (15.0, 16.6)
    m.npc('pak_hadi', 16.8, 16.2)
    m.npc('pemandu', 12.4, 15.2)
    m.npc('anak_rombongan', 18.6, 13.0)
    m.npc('pengunjung', 23.8, 5.6)
    m.npc('satpam', 13.0, 7.9)
    m.npc('arga', 13.8, 12.3)
    m.zone('suvenir', 1, 11, 8, 6)
    m.zone('kafe', 21, 11, 8, 6)
    m.zone('pos_satpam', 11, 6, 3.5, 2.6)
    m.zone('fosil', 1, 1, 9, 6.6)
    m.zone('batik', 20, 1, 9, 6.6)
    return m


if __name__ == '__main__':
    import os
    SP = '/tmp/claude-0/-home-claude/53b496aa-d8b7-5145-a564-51ee87c74326/scratchpad/'
    os.makedirs('build/maps', exist_ok=True)
    for f in (level1, level2, level3, level4):
        mp = f(); mp.save('build/maps')
        prev = Canvas(480, 288); prev.paste(mp.base, 0, 0)
        from chars import NPCS, npc_sprite, player_frame
        for nid, (x, y) in mp.npcs.items():
            prev.paste(npc_sprite(NPCS[nid]), x - 8, y - 23)
        sx, sy = int(mp.spawn[0] * TS), int(mp.spawn[1] * TS)
        prev.paste(player_frame('up', 0), sx - 8, sy - 23)
        prev.paste(mp.over, 0, 0)
        prev.save(SP + mp.name + '.png', 2)
        # debug overlay
        dbg = Canvas(480, 288); dbg.paste(prev, 0, 0)
        for x, y, w, h in mp.col:
            dbg.border(x, y, w, h, P['hot'])
        for n, (x, y, w, h) in mp.zones.items():
            dbg.border(x, y, w, h, P['yellow']); dbg.text(n, x + 2, y + 2, P['yellow'])
        for n, o in mp.objects.items():
            x, y, w, h = o['rect']; dbg.border(x, y, w, h, P['cyan'])
        dbg.save(SP + mp.name + '_dbg.png', 2)
