"""Top-down level maps (30x18 tiles of 16px) + geometry JSON."""
import json, random, math
from pix import *

TS = 16
GW, GH = 30, 18


class Map:
    def __init__(self, name, fill, wall_face='cream', wall_cap='brown_d', base_c='grey'):
        self.name = name
        self.g = [[fill] * GW for _ in range(GH)]
        self.base = Canvas(GW * TS, GH * TS)
        self.over = Canvas(GW * TS, GH * TS)
        self.col, self.zones, self.npcs, self.objects = [], {}, {}, {}
        self.spawn = (0, 0)
        self.wf, self.wc, self.wb = wall_face, wall_cap, base_c
        self.rnd = random.Random(hash(name) % 1000)
        self.labels = []

    # ---------- grid helpers (tile units)
    def fill(self, x0, y0, x1, y1, ch):
        for y in range(y0, y1 + 1):
            for x in range(x0, x1 + 1):
                self.g[y][x] = ch

    def at(self, x, y):
        if 0 <= x < GW and 0 <= y < GH:
            return self.g[y][x]
        return '#'

    # ---------- geometry (pixel units, from tile floats)
    def collide(self, x, y, w, h):
        self.col.append([int(x * TS), int(y * TS), int(w * TS), int(h * TS)])

    def zone(self, name, x, y, w, h):
        self.zones[name] = [int(x * TS), int(y * TS), int(w * TS), int(h * TS)]

    def npc(self, nid, x, y):
        self.npcs[nid] = [int(x * TS), int(y * TS)]

    def obj(self, oid, x, y, w=1, h=1, **kw):
        d = dict(rect=[int(x * TS), int(y * TS), int(w * TS), int(h * TS)])
        d.update(kw)
        self.objects[oid] = d

    # ---------- render
    def render_floor(self):
        for y in range(GH):
            for x in range(GW):
                ch = self.g[y][x]
                if ch not in '#fh':
                    FLOORS[ch](self, x * TS, y * TS, x, y)

    def render_walls(self):
        for y in range(GH):
            for x in range(GW):
                ch = self.g[y][x]
                if ch == '#':
                    self.wall_tile(x, y)
                elif ch == 'f':
                    self.fence_tile(x, y)
                elif ch == 'h':
                    self.hedge_tile(x, y)
        # merge colliders for solid tiles (row runs)
        for y in range(GH):
            x = 0
            while x < GW:
                if self.g[y][x] in '#fh':
                    x0 = x
                    while x < GW and self.g[y][x] in '#fh':
                        x += 1
                    self.col.append([x0 * TS, y * TS, (x - x0) * TS, TS])
                else:
                    x += 1

    def wall_tile(self, x, y):
        c = self.base
        px, py = x * TS, y * TS
        below = self.at(x, y + 1)
        if below != '#' and y + 1 < GH:
            # front face
            c.rect(px, py, TS, TS, P[self.wf])
            c.rect(px, py, TS, 3, P[self.wc])
            c.hline(px, px + 15, py + 3, P['black'])
            c.hline(px, px + 15, py + 4, P[Ld(self.wf)])
            c.rect(px, py + 12, TS, 4, P[self.wb])
            c.hline(px, px + 15, py + 12, P[Ld(self.wb)])
            c.hline(px, px + 15, py + 15, P['black'])
            if (x + y) % 3 == 0:
                c.px(px + 5, py + 8, P[Dk(self.wf)])
        else:
            c.rect(px, py, TS, TS, P[self.wc])
            # edges to floor
            if self.at(x - 1, y) not in '#': c.vline(px, py, py + 15, P['black'])
            if self.at(x + 1, y) not in '#': c.vline(px + 15, py, py + 15, P['black'])
            if self.at(x, y - 1) not in '#' and y > 0: c.hline(px, px + 15, py, P['black'])
            if (x * 7 + y * 3) % 5 == 0: c.px(px + 7, py + 7, P[Dk(self.wc)])

    def fence_tile(self, x, y):
        c = self.base
        px, py = x * TS, y * TS
        FLOORS['g'](self, px, py, x, y)
        c.rect(px, py + 8, TS, 8, P['rust'])
        for yy in range(py + 8, py + 16, 4):
            c.hline(px, px + 15, yy, P['brown_d'])
            off = 0 if (yy // 4) % 2 else 4
            for xx in range(px + off, px + 16, 8):
                c.vline(xx, yy, yy + 3, P['brown_d'])
        c.rect(px, py + 6, TS, 2, P['grey_l']); c.hline(px, px + 15, py + 6, P['white'])
        for xx in range(px + 2, px + 16, 5):
            c.vline(xx, py - 4 if y > 0 else py, py + 5, P['navy'])
            c.px(xx, py - 5 if y > 0 else py, P['gold'])
        c.hline(px, px + 15, py, P['navy'])

    def hedge_tile(self, x, y):
        c = self.base
        px, py = x * TS, y * TS
        c.rect(px, py, TS, TS, P['green_m'])
        r = random.Random(x * 31 + y * 17)
        for i in range(14):
            xx, yy = px + r.randrange(16), py + r.randrange(16)
            c.px(xx, yy, P['green'] if r.random() < .5 else P['green_d'])
        c.hline(px, px + 15, py + 15, P['green_d'])
        c.hline(px, px + 15, py, P['green'])
        if r.random() < .3:
            c.px(px + r.randrange(3, 13), py + r.randrange(3, 13), P[r.choice(['pink', 'yellow', 'white'])])

    def save(self, folder):
        self.base.save(f'{folder}/{self.name}_peta.png')
        self.over.save(f'{folder}/{self.name}_atas.png')
        data = dict(size=[GW * TS, GH * TS], spawn=[int(self.spawn[0] * TS), int(self.spawn[1] * TS)],
                    colliders=self.col, zones=self.zones, npcs=self.npcs, objects=self.objects)
        with open(f'{folder}/{self.name}.json', 'w') as f:
            json.dump(data, f, indent=1)


def Dk(c):
    from chars import SHADE
    return SHADE.get(c, c)


def Ld(c):
    from chars import LIGHT
    return LIGHT.get(c, c)


# ---------------------------------------------------------------- floors
def fl_grass(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['green_m'])
    r = random.Random(x * 131 + y * 71)
    for i in range(10):
        xx, yy = px + r.randrange(16), py + r.randrange(1, 16)
        c.px(xx, yy, P['green']); c.px(xx, yy - 1, P['green']) if r.random() < .5 else None
    for i in range(5):
        c.px(px + r.randrange(16), py + r.randrange(16), P['green_d'])
    if r.random() < .08:
        fx, fy = px + r.randrange(3, 13), py + r.randrange(3, 13)
        col = P[r.choice(['yellow', 'white', 'pink'])]
        for dx, dy in [(0, -1), (-1, 0), (1, 0), (0, 1)]:
            c.px(fx + dx, fy + dy, col)
        c.px(fx, fy, P['gold'])


def fl_paving(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['grey_l'])
    c.hline(px, px + 15, py + 7, P['grey']); c.hline(px, px + 15, py + 15, P['grey'])
    off = 0 if y % 2 == 0 else 4
    c.vline(px + off, py, py + 6, P['grey']); c.vline(px + off + 8, py + 8, py + 14, P['grey'])
    r = random.Random(x * 13 + y * 7)
    if r.random() < .3: c.px(px + r.randrange(16), py + r.randrange(16), P['white'])


def fl_keramik(m, px, py, x, y):
    c = m.base
    for yy in range(2):
        for xx in range(2):
            col = P['white'] if (x * 2 + xx + y * 2 + yy) % 2 == 0 else P['grey_l']
            c.rect(px + xx * 8, py + yy * 8, 8, 8, col)
    c.hline(px, px + 15, py, P['grey']) if False else None


def fl_wood(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['tan'])
    for yy in range(0, 16, 4):
        c.hline(px, px + 15, py + yy + 3, P['brown'])
        off = ((y * 4 + yy) * 5) % 16
        c.px(px + off, py + yy, P['brown']); c.px(px + off, py + yy + 1, P['brown']); c.px(px + off, py + yy + 2, P['brown'])
    c.px(px + 3, py + 1, P['cream'])


def fl_asphalt(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['grey_d'])
    r = random.Random(x * 17 + y * 29)
    for i in range(8):
        c.px(px + r.randrange(16), py + r.randrange(16), P['navy_l'] if r.random() < .6 else P['grey'])


def fl_dirt(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['clay'])
    r = random.Random(x * 19 + y * 23)
    for i in range(12):
        c.px(px + r.randrange(16), py + r.randrange(16), P['brown'] if r.random() < .6 else P['tan'])
    if r.random() < .3:
        xx, yy = px + r.randrange(2, 14), py + r.randrange(2, 14)
        c.rect(xx, yy, 2, 1, P['grey']); c.px(xx, yy - 1, P['grey_l'])


def fl_path(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['tan'])
    r = random.Random(x * 41 + y * 11)
    for i in range(10):
        c.px(px + r.randrange(16), py + r.randrange(16), P['cream'] if r.random() < .5 else P['brown'])
    # soft edges toward grass
    for dx, dy, edge in [(0, -1, 'top'), (0, 1, 'bot'), (-1, 0, 'l'), (1, 0, 'r')]:
        if m.at(x + dx, y + dy) == 'g':
            for i in range(16):
                if (i + x + y) % 3:
                    if edge == 'top': c.px(px + i, py, P['green_m'])
                    if edge == 'bot': c.px(px + i, py + 15, P['green_m'])
                    if edge == 'l': c.px(px, py + i, P['green_m'])
                    if edge == 'r': c.px(px + 15, py + i, P['green_m'])


def fl_semen(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['grey'])
    r = random.Random(x * 7 + y * 53)
    for i in range(9):
        c.px(px + r.randrange(16), py + r.randrange(16), P['grey_d'] if r.random() < .5 else P['grey_l'])
    if (x + y * 3) % 11 == 0:  # puddle
        c.ellipse(px + 8, py + 9, 5, 2, P['grey_d']); c.hline(px + 5, px + 8, py + 8, P['blue'])
    if x % 4 == 0:
        c.vline(px, py, py + 15, P['grey_d'])


def fl_marmer(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['cream'] if (x + y) % 2 == 0 else P['white'])
    r = random.Random(x * 3 + y * 91)
    xx, yy = px + r.randrange(16), py + r.randrange(16)
    for i in range(6):
        c.px(xx + i, yy + (i // 2), P['grey_l'])
    c.hline(px, px + 15, py + 15, P['grey_l']); c.vline(px + 15, py, py + 15, P['grey_l'])


def fl_karpet(m, px, py, x, y):
    c = m.base
    c.rect(px, py, TS, TS, P['red_d'])
    for dx, dy in [(0, -1), (0, 1), (-1, 0), (1, 0)]:
        if m.at(x + dx, y + dy) != 'c':
            if dy == -1: c.hline(px, px + 15, py + 1, P['gold'])
            if dy == 1: c.hline(px, px + 15, py + 14, P['gold'])
            if dx == -1: c.vline(px + 1, py, py + 15, P['gold'])
            if dx == 1: c.vline(px + 14, py, py + 15, P['gold'])
    if (x + y) % 2 == 0:
        c.px(px + 8, py + 8, P['red']); c.px(px + 7, py + 8, P['red']); c.px(px + 8, py + 7, P['red'])


def fl_platform(m, px, py, x, y):  # wooden deck
    c = m.base
    c.rect(px, py, TS, TS, P['brown'])
    for xx in range(0, 16, 4):
        c.vline(px + xx, py, py + 15, P['brown_d'])
    c.hline(px, px + 15, py + (x * 5 % 16), P['brown_d'])


FLOORS = {'g': fl_grass, 'p': fl_paving, 'k': fl_keramik, 'w': fl_wood, 'a': fl_asphalt, 't': fl_dirt,
          'j': fl_path, 's': fl_semen, 'm': fl_marmer, 'c': fl_karpet, 'd': fl_platform}


# ---------------------------------------------------------------- prop helpers (pixel coords)
def shadow(c, x, y, w, h=4):
    for yy in range(y, y + h):
        for xx in range(x, x + w):
            if (xx + yy) % 2 == 0: c.px(xx, yy, P['black'])


def tree(m, tx, ty, r=14):
    """tx,ty = trunk base in tiles"""
    x, y = int(tx * TS), int(ty * TS)
    b, o = m.base, m.over
    shadow(b, x - 10, y - 3, 22, 4)
    b.rect(x - 3, y - 14, 6, 14, P['brown_d']); b.vline(x - 3, y - 14, y - 1, P['choc']); b.vline(x + 2, y - 14, y - 1, P['brown'])
    lay = Canvas(o.w, o.h)
    for dx, dy, rr in [(0, -r - 16, r), (-r + 3, -r - 8, r - 3), (r - 3, -r - 8, r - 3)]:
        lay.ellipse(x + dx, y + dy, rr, rr - 1, P['green_m'])
    msk = lay.filled()
    ys, xs = np.where(msk)
    for yy, xx in zip(ys, xs):
        up = msk[yy - 3, xx] if yy >= 3 else False
        dn = msk[yy + 3, xx] if yy + 3 < o.h else False
        col = P['green_m'] if up else P['green']
        if not dn: col = P['green_d']
        o.px(xx, yy, col)
    lay2 = Canvas(o.w, o.h); lay2.a[msk] = (1, 1, 1, 255)
    lay2.outline(P['black'])
    o.a[(lay2.a[:, :, 0] == P['black'][0]) & (lay2.a[:, :, 3] > 0) & ~msk] = P['black']
    m.collide(tx - .3, ty - .6, .6, .6)


def bush(m, tx, ty, flowers=True):
    x, y = int(tx * TS), int(ty * TS)
    c = m.base
    lay = Canvas(c.w, c.h)
    lay.ellipse(x + 8, y + 9, 8, 6, P['green_m'])
    msk = lay.filled()
    ys, xs = np.where(msk)
    for yy, xx in zip(ys, xs):
        up = msk[yy - 2, xx]; dn = msk[yy + 2, xx] if yy + 2 < c.h else False
        c.px(xx, yy, P['green'] if not up else (P['green_d'] if not dn else P['green_m']))
    lay.outline(); c.a[(lay.a[:, :, 3] > 0) & ~msk] = P['black']
    if flowers:
        for dx, dy in [(4, 6), (10, 8), (7, 11)]:
            c.px(x + dx, y + dy, P['pink'])
    m.collide(tx, ty + .1, 1, .9)


def box(c, x, y, w, h, top, side, edge='black'):
    """3/4 box: top face then front face"""
    c.rect(x, y, w, h, P[edge])
    c.rect(x + 1, y + 1, w - 2, h - 2, P[top])
    return c


def table(m, tx, ty, tw, th, top='tan', side='brown', legs=True):
    x, y, w, h = int(tx * TS), int(ty * TS), int(tw * TS), int(th * TS)
    c = m.base
    shadow(c, x + 2, y + h, w - 2, 3)
    c.rect(x, y, w, h, P['black'])
    c.rect(x + 1, y + 1, w - 2, h - 6, P[top])
    c.hline(x + 1, x + w - 2, y + 1, P[Ld(top)])
    c.rect(x + 1, y + h - 5, w - 2, 4, P[side])
    c.hline(x + 1, x + w - 2, y + h - 5, P[Dk(side)])
    m.collide(tx, ty + .2, tw, th - .2)


def sign_wall(m, tx, ty, text, bg='brown_d', fg='cream'):
    """text plate drawn on wall face (tile coords of plate left/top)"""
    c = m.base
    w = text_w(text) + 6
    x, y = int(tx * TS) - w // 2, int(ty * TS)
    c.rect(x, y, w, 11, P['black']); c.rect(x + 1, y + 1, w - 2, 9, P[bg])
    c.text(text, x + 3, y + 2, P[fg])


def sign_post(m, tx, ty, text):
    c = m.base
    w = text_w(text) + 6
    x, y = int(tx * TS) - w // 2, int(ty * TS)
    c.rect(x + w // 2 - 1, y + 10, 3, 9, P['brown_d']); c.vline(x + w // 2 - 1, y + 10, y + 18, P['black'])
    c.rect(x, y, w, 12, P['black']); c.rect(x + 1, y + 1, w - 2, 10, P['brown'])
    c.hline(x + 1, x + w - 2, y + 1, P['tan'])
    c.text(text, x + 3, y + 3, P['cream'])
    m.collide(tx - .15, ty + .7, .3, .5)


def sprite_at(c, spr, x, y):
    c.paste(spr, x, y)
