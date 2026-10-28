from pix import *
import random

W, H = 320, 180


def sky():
    cv = Canvas(W, H)
    # banded sky with ordered-dither transitions
    bands = [(0, 'blue_d'), (22, 'blue'), (96, 'cyan')]
    for y in range(H):
        cv.hline(0, W - 1, y, P['blue'])
    cv.rect(0, 0, W, 22, P['blue_d'])
    cv.rect(0, 96, W, H - 96, P['cyan'])
    # transitions (25/50/75%)
    def trans(y0, c):
        pats = [lambda x, y: x % 4 == 0 and y % 2 == 0,
                lambda x, y: (x + y) % 2 == 0,
                lambda x, y: not (x % 4 == 2 and y % 2 == 1)]
        for i, f in enumerate(pats):
            for y in range(y0 + i * 2, y0 + i * 2 + 2):
                for x in range(W):
                    if f(x, y):
                        cv.px(x, y, P[c])
    trans(22 - 6, 'blue_d') if False else None
    # blue_d -> blue (draw blue_d fading downward)
    for i, f in enumerate([lambda x, y: not (x % 4 == 2 and y % 2 == 1),
                           lambda x, y: (x + y) % 2 == 0,
                           lambda x, y: x % 4 == 0 and y % 2 == 0]):
        for y in range(22 + i * 2, 24 + i * 2):
            for x in range(W):
                if f(x, y): cv.px(x, y, P['blue_d'])
    trans(88, 'cyan')

    # sun
    cx, cy = 262, 34
    for x in range(W):
        for y in range(70):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** .5
            if 15 < d <= 19 and (x + y) % 2 == 0:
                cv.px(x, y, P['cyan'])
    cv.ellipse(cx, cy, 13, 13, P['yellow'])
    cv.ellipse(cx - 2, cy - 2, 9, 9, P['white'])
    cv.ellipse(cx - 1, cy - 1, 9, 9, P['yellow'])
    for x in range(cx - 13, cx + 14):
        for y in range(cy - 13, cy + 14):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** .5
            if 11.2 < d <= 13.5 and y > cy - 2 and cv.a[y, x][:3].tolist() == list(P['yellow'][:3]):
                cv.px(x, y, P['gold'])

    # clouds (horizontally seamless)
    def cloud(x0, y0, parts):
        lay = Canvas(W, H)
        for dx, dy, rx, ry in parts:
            for off in (-W, 0, W):
                lay.ellipse(x0 + dx + off, y0 + dy, rx, ry, P['white'])
        m = lay.filled()
        base = y0 + max(dy + ry for _, dy, _, ry in parts)
        for y in range(H):
            for x in range(W):
                if m[y, x]:
                    if y >= base - 2:
                        cv.px(x, y, P['grey_l'])
                    elif y >= base - 4 and (x + y) % 2 == 0:
                        cv.px(x, y, P['grey_l'])
                    else:
                        cv.px(x, y, P['white'])
        # flat bottom cut
        for x in range(W):
            if m[base - 1, x] if base - 1 < H else False:
                pass
    cloud(40, 30, [(0, 6, 16, 6), (14, 0, 12, 9), (30, 5, 14, 7), (-14, 8, 9, 4)])
    cloud(150, 16, [(0, 4, 12, 4), (10, 0, 9, 6), (22, 3, 10, 5)])
    cloud(210, 62, [(0, 5, 14, 5), (12, 0, 10, 8), (26, 4, 12, 6), (40, 7, 8, 3)])
    cloud(300, 44, [(0, 4, 10, 4), (9, 0, 8, 6), (19, 3, 9, 4)])
    cloud(100, 76, [(0, 3, 10, 3), (8, 0, 7, 5), (17, 3, 8, 3)])

    # birds
    for bx, by in [(118, 44), (127, 40), (134, 47)]:
        for dx, dy in [(-2, -1), (-1, 0), (1, 0), (2, -1), (0, 1)]:
            cv.px(bx + dx, by + dy, P['navy_l'])

    # distant hills (seamless)
    rnd = random.Random(3)
    import math
    for x in range(W):
        t = x / W * 2 * math.pi
        h1 = 112 + 7 * math.sin(t * 2 + .5) + 4 * math.sin(t * 5 + 1.3)
        h2 = 122 + 5 * math.sin(t * 3 + 2) + 3 * math.sin(t * 7)
        for y in range(int(h1), H):
            cv.px(x, y, P['green_m'] if y > h1 + 1 else P['green'])
        for y in range(int(h1) - 1, int(h1)):
            if x % 2 == 0: cv.px(x, y, P['green_m'])
        for y in range(int(h2), H):
            cv.px(x, y, P['green_d'] if y > h2 + 1 else P['green_m'])
    # far tree clumps on hills
    for tx in range(6, W, 23):
        ty = 122 + 5 * math.sin(tx / W * 2 * math.pi * 3 + 2) + 3 * math.sin(tx / W * 2 * math.pi * 7) - 3
        cv.ellipse(tx, int(ty), 4, 3, P['green_d'])
        cv.px(tx - 1, int(ty) - 2, P['green_m']); cv.px(tx, int(ty) - 3, P['green_m'])
    return cv


def window(cv, x, y, w=12, h=14):
    cv.rect(x - 1, y - 1, w + 2, h + 2, P['choc'])
    cv.rect(x, y, w, h, P['blue'])
    cv.rect(x, y + h // 2, w, h - h // 2, P['blue_d'])
    # reflection diagonal
    for i in range(4):
        cv.px(x + 1 + i, y + 4 - i, P['cyan'])
        cv.px(x + 2 + i, y + 4 - i, P['cyan'])
    cv.px(x + 1, y + 1, P['white'])
    cv.vline(x + w // 2, y, y + h - 1, P['brown_d'])
    cv.hline(x, x + w - 1, y + h // 2 - 1, P['brown_d'])
    cv.hline(x - 1, x + w, y + h + 1, P['grey_l'])  # sill
    cv.hline(x - 1, x + w, y + h + 2, P['grey'])


def building():
    cv = Canvas(W, H)
    G = 132  # ground line
    L, R = 26, 294
    # ---- wings
    cv.rect(L, 72, R - L, G - 72, P['cream'])
    # upper-floor shadow under roof eave
    cv.rect(L, 72, R - L, 2, P['tan'])
    # floor ledge
    cv.rect(L - 2, 100, R - L + 4, 3, P['clay'])
    cv.rect(L - 2, 103, R - L + 4, 1, P['brown_d'])
    cv.rect(L, 104, R - L, 2, P['tan'])
    # plinth
    cv.rect(L, G - 5, R - L, 5, P['grey'])
    cv.hline(L, R - 1, G - 5, P['grey_l'])
    for x in range(L, R, 8):
        cv.vline(x, G - 4, G - 1, P['grey_d'])
    # windows
    for x in list(range(L + 8, 118, 20)) + list(range(206, R - 12, 20)):
        window(cv, x, 79, 12, 14)
        window(cv, x, 108, 12, 12)
    # vertical pillars between ground windows
    for x in list(range(L + 3, 120, 20)) + list(range(201, R - 6, 20)):
        cv.rect(x, 106, 2, G - 111, P['grey_l'])
        cv.vline(x + 2, 106, G - 6, P['tan'])
    # ---- main roof (hip roof)
    top, eave = 56, 72
    for y in range(top, eave):
        k = (y - top)
        x0, x1 = L - 6 + (eave - y) // 1 * 0 + 12 - k * 12 // (eave - top) , R + 6 - 12 + k * 12 // (eave - top)
        cv.hline(x0, x1, y, P['rust'])
        if (y - top) % 3 == 2:
            cv.hline(x0, x1, y, P['red_d'])
    for x in range(L - 6, R + 7):
        pass
    cv.hline(L + 6, R - 6, top, P['clay'])
    cv.rect(L - 7, eave, R - L + 14, 2, P['brown_d'])
    # tile verticals
    for y in range(top + 1, eave):
        for x in range(L, R, 6):
            xx = x + ((y - top) // 3 % 2) * 3
            if (y - top) % 3 != 2 and cv.a[y, xx][:3].tolist() == list(P['rust'][:3]):
                cv.px(xx, y, P['red_d'])
    # ---- central gable section
    cx0, cx1 = 118, 202
    cv.rect(cx0, 64, cx1 - cx0, G - 64, P['white'])
    cv.rect(cx0, 64, 3, G - 64, P['grey_l'])
    cv.rect(cx1 - 3, 64, 3, G - 64, P['grey_l'])
    # gable roof triangle
    peak_y, base_y = 30, 64
    mid = (cx0 + cx1) // 2
    for y in range(peak_y, base_y + 1):
        half = (y - peak_y) * (cx1 - cx0 + 16) // 2 // (base_y - peak_y)
        cv.hline(mid - half, mid + half, y, P['rust'])
        if (y - peak_y) % 3 == 2:
            cv.hline(mid - half, mid + half, y, P['red_d'])
    # gable face (inner triangle)
    for y in range(peak_y + 8, base_y + 1):
        half = (y - peak_y - 8) * (cx1 - cx0 - 16) // 2 // (base_y - peak_y - 8)
        cv.hline(mid - half, mid + half, y, P['cream'])
    for y in range(peak_y + 8, base_y + 1):
        half = (y - peak_y - 8) * (cx1 - cx0 - 16) // 2 // (base_y - peak_y - 8)
        cv.px(mid - half, y, P['tan']); cv.px(mid + half, y, P['tan'])
    cv.rect(cx0 - 8, base_y, cx1 - cx0 + 16, 3, P['brown_d'])
    cv.hline(cx0 - 8, cx1 + 7, base_y, P['brown'])
    # clock
    cv.ellipse(mid, 50, 6, 6, P['choc'])
    cv.ellipse(mid, 50, 5, 5, P['white'])
    cv.vline(mid, 46, 50, P['black']); cv.hline(mid, mid + 3, 50, P['black'])
    cv.px(mid, 45, P['red'])
    # name board
    bx, by, bw, bh = mid - 38, 72, 76, 21
    cv.rect(bx - 1, by - 1, bw + 2, bh + 2, P['black'])
    cv.rect(bx, by, bw, bh, P['green_d'])
    cv.border(bx + 1, by + 1, bw - 2, bh - 2, P['green_m'])
    cv.text_c("TUNAS", mid, by + 3, P['yellow'], shadow=P['teal_d'])
    cv.text_c("BANGSA", mid, by + 11, P['yellow'], shadow=P['teal_d'])
    for sx in (bx + 8, bx + bw - 9):
        for dx, dy in [(0, -2), (-2, 0), (-1, 0), (0, 0), (1, 0), (2, 0), (0, -1), (-1, 1), (1, 1), (-1, 2), (1, 2), (0, 1)]:
            cv.px(sx + dx, by + 10 + dy, P['white'])
    # central ledge
    cv.rect(cx0 - 2, 100, cx1 - cx0 + 4, 3, P['clay'])
    cv.rect(cx0 - 2, 103, cx1 - cx0 + 4, 1, P['brown_d'])
    # canopy over door
    cv.rect(mid - 22, 104, 44, 3, P['rust'])
    cv.hline(mid - 22, mid + 21, 104, P['clay'])
    cv.rect(mid - 22, 107, 44, 1, P['brown_d'])
    # side windows on central section upper
    # door
    dx0, dw = mid - 14, 28
    cv.rect(dx0 - 2, 108, dw + 4, G - 108, P['choc'])
    cv.rect(dx0, 110, dw, G - 110, P['brown'])
    cv.vline(mid, 110, G - 1, P['choc'])
    for x0 in (dx0 + 3, mid + 3):
        cv.border(x0, 113, 8, 7, P['brown_d'])
        cv.border(x0, 122, 8, 7, P['brown_d'])
        cv.rect(x0 + 1, 114, 6, 5, P['blue'])
        cv.px(x0 + 1, 114, P['cyan'])
    cv.px(mid - 2, 121, P['gold']); cv.px(mid + 2, 121, P['gold'])
    # central side pillars ground floor
    for x in (cx0 + 6, cx1 - 12):
        cv.rect(x, 108, 6, G - 113, P['grey_l'])
        cv.vline(x + 5, 108, G - 6, P['grey'])
        cv.rect(x - 1, 107, 8, 2, P['white'])
    # steps
    cv.rect(mid - 20, G - 3, 40, 3, P['grey_l'])
    cv.hline(mid - 20, mid + 19, G - 3, P['white'])
    cv.rect(mid - 24, G - 1, 48, 1, P['grey'])
    # plinth central
    cv.rect(cx0, G - 5, cx1 - cx0, 2, P['grey'])

    # ---- flagpole
    fx = 64
    cv.rect(fx - 3, G - 3, 7, 3, P['grey'])
    cv.hline(fx - 3, fx + 3, G - 3, P['grey_l'])
    cv.vline(fx, 18, G - 3, P['grey_l'])
    cv.vline(fx + 1, 18, G - 3, P['grey'])
    cv.px(fx, 17, P['gold']); cv.px(fx + 1, 17, P['gold'])
    # waving flag
    import math
    for x in range(0, 20):
        dy = int(round(1.5 * math.sin(x / 3.2)))
        for y in range(0, 12):
            c = P['red'] if y < 6 else P['white']
            if y == 5: c = P['red_d'] if x % 5 == 3 else P['red']
            if y == 11: c = P['grey_l']
            cv.px(fx + 2 + x, 19 + y + dy, c)
    # ---- trees at sides
    def tree(x, base, r):
        cv.rect(x - 2, base - r - 6, 5, r + 6, P['brown_d'])
        cv.vline(x - 2, base - r - 6, base - 1, P['choc'])
        blobs = [(0, -r * 2 - 2, r + 2), (-r, -r * 2 + 3, r), (r, -r * 2 + 3, r), (0, -r * 2 + 6, r + 1)]
        lay = Canvas(W, H)
        for dx, dy, rr in blobs:
            lay.ellipse(x + dx, base + dy, rr, rr - 1, P['green_m'])
        m = lay.filled()
        for y in range(H):
            for xx in range(W):
                if m[y, xx]:
                    up = m[y - 3, xx] if y >= 3 else False
                    dn = m[y + 3, xx] if y + 3 < H else False
                    c = P['green_m']
                    if not up: c = P['green']
                    elif not dn: c = P['green_d']
                    cv.px(xx, y, c)
        for dx, dy in [(-3, -r * 2 - 4), (4, -r * 2 + 1), (-r - 1, -r * 2 + 2), (r - 2, -r * 2 + 4)]:
            cv.px(x + dx, base + dy, P['yellow'] if (dx + dy) % 2 else P['green'])
    tree(14, G, 12)
    tree(306, G, 12)
    cv.outline(P['black'])
    return cv


def foreground():
    cv = Canvas(W, H)
    import math
    rnd = random.Random(7)
    top = 130
    # grass
    cv.rect(0, top, W, H - top, P['green_m'])
    cv.hline(0, W - 1, top, P['green'])
    for i in range(420):
        x, y = rnd.randrange(W), rnd.randrange(top + 2, H)
        cv.px(x, y, P['green'] if rnd.random() < .5 else P['green_d'])
        if rnd.random() < .3: cv.px(x, y - 1, P['green'])
    # path (perspective) from door to viewer
    mid = 160
    for y in range(top, H):
        t = (y - top) / (H - top)
        half = int(18 + t * 62)
        cv.hline(mid - half, mid + half, y, P['grey_l'])
        cv.px(mid - half - 1, y, P['grey']); cv.px(mid + half + 1, y, P['grey'])
    # tile lines on path
    yy, step = top + 3, 3
    while yy < H:
        t = (yy - top) / (H - top)
        half = int(18 + t * 62)
        cv.hline(mid - half, mid + half, yy, P['grey'])
        step = max(3, int(3 + t * 9)); yy += step
    for k in range(-4, 5):
        for y in range(top, H):
            t = (y - top) / (H - top)
            half = 18 + t * 62
            x = int(mid + k / 4.5 * half)
            cv.px(x, y, P['grey'])
    # front sidewalk strip
    cv.rect(0, 168, W, 12, P['grey'])
    cv.hline(0, W - 1, 168, P['grey_l'])
    for x in range(0, W, 16):
        cv.vline(x, 169, 179, P['grey_d'])
    cv.rect(0, 177, W, 3, P['grey_d'])
    # ---- fence: brick wall + iron bars
    wall_top, wall_bot = 150, 166
    gl, gr = 96, 224  # gate opening edges (pillar inner edge)
    def wall(x0, x1):
        cv.rect(x0, wall_top, x1 - x0, wall_bot - wall_top, P['rust'])
        for y in range(wall_top, wall_bot, 4):
            cv.hline(x0, x1 - 1, y, P['brown_d'])
            off = 0 if (y // 4) % 2 else 4
            for x in range(x0 + off, x1, 8):
                cv.vline(x, y, y + 3, P['brown_d'])
        cv.rect(x0 - 1, wall_top - 3, x1 - x0 + 2, 3, P['grey_l'])
        cv.hline(x0 - 1, x1, wall_top - 3, P['white'])
        cv.hline(x0 - 1, x1, wall_top - 1, P['grey'])
        cv.hline(x0, x1 - 1, wall_bot, P['choc'])
        # bars
        for x in range(x0 + 3, x1 - 1, 6):
            cv.vline(x, 124, wall_top - 4, P['navy'])
            cv.px(x, 122, P['gold']); cv.px(x - 1, 123, P['gold']); cv.px(x + 1, 123, P['gold']); cv.px(x, 123, P['gold'])
        cv.hline(x0, x1 - 1, 128, P['navy'])
        cv.hline(x0, x1 - 1, 141, P['navy'])
    wall(0, gl - 14)
    wall(gr + 14, W)
    # ---- pillars
    def pillar(x):
        pw = 14
        cv.rect(x, 116, pw, wall_bot - 116, P['cream'])
        cv.rect(x + pw - 3, 116, 3, wall_bot - 116, P['tan'])
        cv.rect(x, 116, 2, wall_bot - 116, P['white'])
        for y in range(122, wall_bot, 6):
            cv.hline(x, x + pw - 1, y, P['tan'])
        # cap
        cv.rect(x - 2, 112, pw + 4, 4, P['grey_l'])
        cv.hline(x - 2, x + pw + 1, 112, P['white'])
        cv.hline(x - 2, x + pw + 1, 115, P['grey'])
        # lamp
        cv.rect(x + 5, 108, 4, 4, P['navy'])
        cv.ellipse(x + 6, 103, 4, 5, P['yellow'])
        cv.px(x + 5, 101, P['white']); cv.px(x + 5, 102, P['white'])
        cv.hline(x + 3, x + 10, 97, P['navy']); cv.rect(x + 5, 96, 4, 1, P['navy'])
        cv.rect(x - 1, wall_bot - 2, pw + 2, 2, P['grey'])
    pillar(gl - 14)
    pillar(gr)
    # ---- open gate panels (seen swung inward, foreshortened)
    def gate(xh, direction):
        # hinge at pillar edge, panel goes back (up) and inward
        length = 22
        for i in range(0, length + 1, 4):
            x = xh + direction * i
            ytop = 124 + i // 3
            ybot = wall_bot - 2 - i // 2
            cv.vline(x, ytop, ybot, P['navy'])
            cv.px(x, ytop - 1, P['gold'])
        x1 = xh + direction * length
        cv.line(xh, 124, x1, 124 + length // 3, P['navy'])
        cv.line(xh, 136, x1, 136 + length // 6, P['navy'])
        cv.line(xh, wall_bot - 2, x1, wall_bot - 2 - length // 2, P['navy'])
    gate(gl + 1, 1)
    gate(gr - 2, -1)
    # ---- bushes along wall
    def bush(x, y, r):
        lay = Canvas(W, H)
        lay.ellipse(x, y, r, r - 2, P['green_m'])
        lay.ellipse(x - r + 2, y + 2, r - 2, r - 4, P['green_m'])
        lay.ellipse(x + r - 2, y + 2, r - 2, r - 4, P['green_m'])
        m = lay.filled()
        for yy in range(H):
            for xx in range(W):
                if m[yy, xx]:
                    up = m[yy - 2, xx] if yy >= 2 else False
                    dn = m[yy + 2, xx] if yy + 2 < H else False
                    c = P['green_m'] if up else P['green']
                    if not dn: c = P['green_d']
                    cv.px(xx, yy, c)
        for dx, dy, c in [(-2, -2, 'pink'), (3, 0, 'yellow'), (-r + 3, 2, 'white'), (r - 3, 1, 'pink')]:
            cv.px(x + dx, y + dy, P[c])
    for bx in (10, 36, 62):
        bush(bx, 162, 9)
    for bx in (258, 284, 310):
        bush(bx, 162, 9)
    # flower pots beside path
    for px_ in (104, 212):
        cv.rect(px_, 158, 8, 7, P['rust'])
        cv.hline(px_ - 1, px_ + 8, 158, P['clay'])
        cv.ellipse(px_ + 3, 154, 5, 4, P['green_m'])
        cv.px(px_ + 1, 152, P['red']); cv.px(px_ + 5, 151, P['yellow']); cv.px(px_ + 3, 154, P['red'])
    # outline only the upright objects (not ground): outline whole then remove at ground
    return cv


if __name__ == '__main__':
    s, b, f = sky(), building(), foreground()
    s.save('menu_assets/mnu_g_bg_langit.png')
    b.save('menu_assets/mnu_g_bg_gedung.png')
    f.save('menu_assets/mnu_g_bg_gerbang.png')
    comp = Canvas(W, H)
    comp.paste(s, 0, 0); comp.paste(b, 0, 0); comp.paste(f, 0, 0)
    comp.save('/tmp/claude-0/-home-claude/53b496aa-d8b7-5145-a564-51ee87c74326/scratchpad/bg_comp.png', 3)
