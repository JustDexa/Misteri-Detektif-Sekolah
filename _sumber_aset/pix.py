"""Tiny pixel-art toolkit: palette, bitmap font, shape + outline helpers."""
import numpy as np
from PIL import Image
from PIL import Image

# ENDESGA 32 palette (lospec.com/palette-list/endesga-32)
HEX = dict(
    rust='be4a2f', clay='d77643', cream='ead4aa', tan='e4a672', brown='b86f50',
    brown_d='733e39', choc='3e2731', red_d='a22633', red='e43b44', orange='f77622',
    gold='feae34', yellow='fee761', green='63c74d', green_m='3e8948', green_d='265c42',
    teal_d='193c3e', blue_d='124e89', blue='0099db', cyan='2ce8f5', white='ffffff',
    grey_l='c0cbdc', grey='8b9bb4', grey_d='5a6988', navy_l='3a4466', navy='262b44',
    black='181425', hot='ff0044', purple='68386c', magenta='b55088', pink='f6757a',
    skin_l='e8b796', skin='c28569')
P = {k: tuple(int(v[i:i + 2], 16) for i in (0, 2, 4)) + (255,) for k, v in HEX.items()}
T = (0, 0, 0, 0)

# ---------------------------------------------------------------- font 5x7
_G = {
'A': ".###.|#...#|#...#|#####|#...#|#...#|#...#",
'B': "####.|#...#|#...#|####.|#...#|#...#|####.",
'C': ".###.|#...#|#....|#....|#....|#...#|.###.",
'D': "####.|#...#|#...#|#...#|#...#|#...#|####.",
'E': "#####|#....|#....|####.|#....|#....|#####",
'F': "#####|#....|#....|####.|#....|#....|#....",
'G': ".###.|#...#|#....|#.###|#...#|#...#|.####",
'H': "#...#|#...#|#...#|#####|#...#|#...#|#...#",
'I': "###|.#.|.#.|.#.|.#.|.#.|###",
'J': "..###|...#.|...#.|...#.|#..#.|#..#.|.##..",
'K': "#...#|#..#.|#.#..|##...|#.#..|#..#.|#...#",
'L': "#....|#....|#....|#....|#....|#....|#####",
'M': "#...#|##.##|#.#.#|#.#.#|#...#|#...#|#...#",
'N': "#...#|#...#|##..#|#.#.#|#..##|#...#|#...#",
'O': ".###.|#...#|#...#|#...#|#...#|#...#|.###.",
'P': "####.|#...#|#...#|####.|#....|#....|#....",
'Q': ".###.|#...#|#...#|#...#|#.#.#|#..#.|.##.#",
'R': "####.|#...#|#...#|####.|#.#..|#..#.|#...#",
'S': ".####|#....|#....|.###.|....#|....#|####.",
'T': "#####|..#..|..#..|..#..|..#..|..#..|..#..",
'U': "#...#|#...#|#...#|#...#|#...#|#...#|.###.",
'V': "#...#|#...#|#...#|#...#|#...#|.#.#.|..#..",
'W': "#...#|#...#|#...#|#.#.#|#.#.#|#.#.#|.#.#.",
'X': "#...#|#...#|.#.#.|..#..|.#.#.|#...#|#...#",
'Y': "#...#|#...#|.#.#.|..#..|..#..|..#..|..#..",
'Z': "#####|....#|...#.|..#..|.#...|#....|#####",
'0': ".###.|#...#|#..##|#.#.#|##..#|#...#|.###.",
'1': ".#.|##.|.#.|.#.|.#.|.#.|###",
'2': ".###.|#...#|....#|...#.|..#..|.#...|#####",
'3': "####.|....#|....#|.###.|....#|....#|####.",
'4': "...#.|..##.|.#.#.|#..#.|#####|...#.|...#.",
'5': "#####|#....|####.|....#|....#|#...#|.###.",
'6': ".###.|#....|#....|####.|#...#|#...#|.###.",
'7': "#####|....#|...#.|..#..|.#...|.#...|.#...",
'8': ".###.|#...#|#...#|.###.|#...#|#...#|.###.",
'9': ".###.|#...#|#...#|.####|....#|....#|.###.",
' ': "...|...|...|...|...|...|...",
'.': ".|.|.|.|.|.|#",
',': "..|..|..|..|..|.#|#.",
':': ".|.|#|.|.|#|.",
'-': "...|...|...|###|...|...|...",
'!': "#|#|#|#|#|.|#",
'?': ".###.|#...#|....#|...#.|..#..|.....|..#..",
"'": "#|#|.|.|.|.|.",
'/': "....#|...#.|...#.|..#..|.#...|.#...|#....",
'(': ".#|#.|#.|#.|#.|#.|.#",
')': "#.|.#|.#|.#|.#|.#|#.",
'&': ".##..|#..#.|#.#..|.#...|#.#.#|#..#.|.##.#",
'+': ".....|..#..|..#..|#####|..#..|..#..|.....",
'·': ".|.|.|#|.|.|.",
'—': ".....|.....|.....|#####|.....|.....|.....",
'>': "#...|.#..|..#.|...#|..#.|.#..|#...",
'<': "...#|..#.|.#..|#...|.#..|..#.|...#",
'[': "##|#.|#.|#.|#.|#.|##",
']': "##|.#|.#|.#|.#|.#|##",
'%': "##..#|##.#.|...#.|..#..|.#...|.#.##|#..##",
}
GLYPH = {k: np.array([[c == '#' for c in row] for row in v.split('|')]) for k, v in _G.items()}


def text_mask(s, scale=1, spacing=1):
    s = s.upper()
    glyphs = [GLYPH.get(ch, GLYPH['?']) for ch in s]
    w = sum(g.shape[1] + spacing for g in glyphs) - spacing
    m = np.zeros((7, max(w, 1)), bool)
    x = 0
    for g in glyphs:
        m[:, x:x + g.shape[1]] |= g
        x += g.shape[1] + spacing
    if scale > 1:
        m = m.repeat(scale, 0).repeat(scale, 1)
    return m


def text_w(s, scale=1, spacing=1):
    return text_mask(s, scale, spacing).shape[1]


# ---------------------------------------------------------------- canvas
class Canvas:
    def __init__(self, w, h, fill=T):
        self.a = np.zeros((h, w, 4), np.uint8)
        self.a[:] = fill
        self.w, self.h = w, h

    def px(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.a[y, x] = c

    def rect(self, x, y, w, h, c):
        x0, y0, x1, y1 = max(x, 0), max(y, 0), min(x + w, self.w), min(y + h, self.h)
        if x1 > x0 and y1 > y0:
            self.a[y0:y1, x0:x1] = c

    def hline(self, x0, x1, y, c):
        self.rect(min(x0, x1), y, abs(x1 - x0) + 1, 1, c)

    def vline(self, x, y0, y1, c):
        self.rect(x, min(y0, y1), 1, abs(y1 - y0) + 1, c)

    def border(self, x, y, w, h, c):
        self.hline(x, x + w - 1, y, c); self.hline(x, x + w - 1, y + h - 1, c)
        self.vline(x, y, y + h - 1, c); self.vline(x + w - 1, y, y + h - 1, c)

    def line(self, x0, y0, x1, y1, c, thick=1):
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx + dy
        while True:
            self.rect(x0 - thick // 2, y0 - thick // 2, thick, thick, c)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy: err += dy; x0 += sx
            if e2 <= dx: err += dx; y0 += sy

    def ellipse(self, cx, cy, rx, ry, c):
        ys, xs = np.ogrid[:self.h, :self.w]
        m = ((xs - cx) / (rx + .5)) ** 2 + ((ys - cy) / (ry + .5)) ** 2 <= 1
        self.a[m] = c

    def mask_fill(self, m, x, y, c):
        h, w = m.shape
        for yy in range(h):
            for xx in range(w):
                if m[yy, xx]:
                    self.px(x + xx, y + yy, c)

    def text(self, s, x, y, c, scale=1, spacing=1, shadow=None):
        m = text_mask(s, scale, spacing)
        if shadow is not None:
            self.mask_fill(m, x, y + scale, shadow)
        self.mask_fill(m, x, y, c)
        return m.shape[1]

    def text_c(self, s, cx, y, c, scale=1, spacing=1, shadow=None):
        return self.text(s, cx - text_w(s, scale, spacing) // 2, y, c, scale, spacing, shadow)

    def paste(self, other, x, y):
        """alpha-over paste (binary alpha)"""
        oa = other.a if isinstance(other, Canvas) else other
        h, w = oa.shape[:2]
        for yy in range(h):
            ty = y + yy
            if not 0 <= ty < self.h: continue
            row = oa[yy]
            for xx in range(w):
                tx = x + xx
                if 0 <= tx < self.w and row[xx, 3] > 0:
                    self.a[ty, tx] = row[xx]

    def filled(self):
        return self.a[:, :, 3] > 0

    def outline(self, c=P['black'], diag=False):
        """add 1px outline around all opaque pixels"""
        m = self.filled()
        o = np.zeros_like(m)
        o[1:] |= m[:-1]; o[:-1] |= m[1:]; o[:, 1:] |= m[:, :-1]; o[:, :-1] |= m[:, 1:]
        if diag:
            o[1:, 1:] |= m[:-1, :-1]; o[:-1, :-1] |= m[1:, 1:]
            o[1:, :-1] |= m[:-1, 1:]; o[:-1, 1:] |= m[1:, :-1]
        o &= ~m
        self.a[o] = c
        return self

    def dither_rect(self, x, y, w, h, c, phase=0):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if (xx + yy + phase) % 2 == 0:
                    self.px(xx, yy, c)

    def img(self):
        return Image.fromarray(self.a, 'RGBA')

    def save(self, path, scale=1):
        im = self.img()
        if scale > 1:
            im = im.resize((self.w * scale, self.h * scale), Image.NEAREST)
        im.save(path)


def dilate(m, r=1, diag=True):
    out = m.copy()
    for _ in range(r):
        o = out.copy()
        o[1:] |= out[:-1]; o[:-1] |= out[1:]; o[:, 1:] |= out[:, :-1]; o[:, :-1] |= out[:, 1:]
        if diag:
            o[1:, 1:] |= out[:-1, :-1]; o[:-1, :-1] |= out[1:, 1:]
            o[1:, :-1] |= out[:-1, 1:]; o[:-1, 1:] |= out[1:, :-1]
        out = o
    return out


def fancy_text(s, scale=2, bands=('yellow', 'gold', 'orange'), outline='black', ow=2,
               depth=3, depth_c='brown_d', hi='white', spacing=1):
    """Chunky title text: gradient bands, top highlight, 3D extrusion, thick outline."""
    m = text_mask(s, scale, spacing)
    pad = ow + depth + 1
    H, W = m.shape[0] + pad * 2, m.shape[1] + pad * 2
    M = np.zeros((H, W), bool)
    M[pad:pad + m.shape[0], pad:pad + m.shape[1]] = m
    ext = M.copy()
    for d in range(1, depth + 1):
        ext[d:] |= M[:-d]
    cv = Canvas(W, H)
    cv.a[dilate(ext, ow)] = P[outline]
    cv.a[ext & ~M] = P[depth_c]
    rows = np.where(M.any(1))[0]
    top, bot = rows.min(), rows.max()
    for y in range(top, bot + 1):
        t = (y - top) / max(1, bot - top + 1)
        c = P[bands[min(int(t * len(bands)), len(bands) - 1)]]
        cv.a[y][M[y]] = c
    # highlight: pixels whose upper neighbour is empty
    up = np.zeros_like(M); up[1:] = M[:-1]
    cv.a[M & ~up] = P[hi]
    # crop to content
    ys, xs = np.where(cv.filled())
    return crop(cv, xs.min(), ys.min(), xs.max(), ys.max())


def crop(cv, x0, y0, x1, y1):
    n = Canvas(x1 - x0 + 1, y1 - y0 + 1)
    n.a[:] = cv.a[y0:y1 + 1, x0:x1 + 1]
    return n


def from_ascii(rows, key):
    h, w = len(rows), max(len(r) for r in rows)
    cv = Canvas(w, h)
    for y, r in enumerate(rows):
        for x, ch in enumerate(r):
            if ch in key and key[ch] is not None:
                cv.a[y, x] = P[key[ch]] if isinstance(key[ch], str) else key[ch]
    return cv
