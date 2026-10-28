from pix import *

# ================================================================ LOGO
def magnifier(r=9, handle=9, qmark=True):
    size = r * 2 + handle + 6
    cv = Canvas(size, size)
    cx = cy = r + 2
    # handle (diagonal to bottom-right)
    for i in range(handle):
        x, y = cx + r - 1 + i * 7 // 10, cy + r - 1 + i * 7 // 10
        cv.rect(x - 1, y - 1, 4, 4, P['brown_d'])
        cv.px(x - 1, y, P['brown']); cv.px(x, y - 1, P['brown'])
    cv.ellipse(cx, cy, r, r, P['gold'])
    cv.ellipse(cx, cy, r - 2, r - 2, P['cyan'])
    # rim shading (lower-right)
    for y in range(size):
        for x in range(size):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** .5
            if r - 2.5 < d <= r + .5 and (x - cx) + (y - cy) > 2:
                cv.px(x, y, P['orange'])
            if r - 2.5 < d <= r + .5 and (x - cx) + (y - cy) < -6:
                cv.px(x, y, P['yellow'])
            if d <= r - 2 and (x - cx) + (y - cy) > r - 3:
                cv.px(x, y, P['blue'])
    # glints
    for i in range(3):
        cv.px(cx - 4 + i, cy - 2 - i, P['white'])
    cv.px(cx - 3, cy + 1, P['white'])
    if qmark:
        q = text_mask('?', 1)
        cv.mask_fill(q, cx - 1, cy - 3, P['navy'])
    cv.outline(P['black'])
    return cv


def ribbon(label, scale=2):
    tm = text_mask(label, scale)
    tw, th = tm.shape[1], tm.shape[0]
    bw, bh = tw + 16, th + 8
    tail = 10
    W, H = bw + tail * 2, bh + 5
    cv = Canvas(W, H)
    # tails (behind, lower)
    for side in (0, 1):
        x0 = 0 if side == 0 else W - tail - 4
        cv.rect(x0, 5, tail + 4, bh - 2, P['red_d'])
        # notch
        for y in range(5, 5 + bh - 2):
            d = abs(y - (5 + (bh - 2) // 2))
            n = (bh - 2) // 2 - d
            if side == 0:
                cv.rect(x0, y, max(0, 4 - d // 2) if False else 0, 1, T)
                for k in range(max(0, 5 - d)):
                    cv.px(x0 + k, y, T)
            else:
                for k in range(max(0, 5 - d)):
                    cv.px(x0 + tail + 3 - k, y, T)
    # fold shadows
    cv.rect(tail, bh + 1, 4, 3, P['purple'])
    cv.rect(W - tail - 4, bh + 1, 4, 3, P['purple'])
    # front band
    cv.rect(tail, 0, bw, bh, P['red'])
    cv.hline(tail, tail + bw - 1, 1, P['pink'])
    cv.hline(tail, tail + bw - 1, bh - 2, P['red_d'])
    cv.hline(tail, tail + bw - 1, bh - 1, P['red_d'])
    for x in range(tail + 2, tail + bw - 2, 3):
        cv.px(x, 3, P['cream']) if False else None
    cv.hline(tail + 2, tail + bw - 3, 2, P['red'])
    cv.mask_fill(tm, tail + 8, 4 + scale, P['red_d'])
    cv.mask_fill(tm, tail + 8, 4, P['white'])
    cv.outline(P['black'])
    return cv


def logo():
    l1 = fancy_text("MISTERI", 2, bands=('white', 'grey_l'), depth=2, depth_c='grey_d')
    l2 = fancy_text("DETEKTIF", 3, bands=('yellow', 'gold', 'orange'), depth=4, depth_c='rust')
    rb = ribbon("SEKOLAH", 2)
    mg = magnifier(10, 10)
    W = max(l2.w, rb.w) + 34
    H = l1.h + l2.h + rb.h - 3
    cv = Canvas(W, H)
    cx = (W - 30) // 2
    cv.paste(l1, cx - l1.w // 2 - 6, 0)
    cv.paste(rb, cx - rb.w // 2, l1.h + l2.h - 6)
    cv.paste(l2, cx - l2.w // 2, l1.h - 1)
    cv.paste(mg, cx + l1.w // 2 - 2, -2)
    # sparkles
    for sx, sy in [(cx - l2.w // 2 + 2, l1.h + 2), (cx + l2.w // 2 - 6, l1.h + l2.h - 4)]:
        for dx, dy in [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)]:
            cv.px(sx + dx, sy + dy, P['white'])
        for dx, dy in [(2, 0), (-2, 0), (0, 2), (0, -2)]:
            cv.px(sx + dx, sy + dy, P['yellow'])
    ys, xs = np.where(cv.filled())
    cv = crop(cv, xs.min(), ys.min(), xs.max(), ys.max())
    # fill enclosed transparent holes (not reachable from the border) with outline colour
    from collections import deque
    m = cv.filled(); h, w = m.shape
    seen = np.zeros_like(m); q = deque()
    for x in range(w):
        for y in (0, h - 1):
            if not m[y, x]: q.append((y, x)); seen[y, x] = True
    for y in range(h):
        for x in (0, w - 1):
            if not m[y, x] and not seen[y, x]: q.append((y, x)); seen[y, x] = True
    while q:
        y, x = q.popleft()
        for dy, dx in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            ny, nx = y + dy, x + dx
            if 0 <= ny < h and 0 <= nx < w and not m[ny, nx] and not seen[ny, nx]:
                seen[ny, nx] = True; q.append((ny, nx))
    cv.a[~m & ~seen] = P['black']
    return cv


# ================================================================ PLAYER (menu pose)
def _layer():
    return Canvas(48, 64)


def player_pose(frame=0):
    b = frame  # upper-body bob
    out = Canvas(48, 64)

    # legs + shoes (no bob)
    L = _layer()
    for x0 in (19, 25):
        L.rect(x0, 50, 4, 8, P['navy_l'])
    L.vline(22, 50, 57, P['navy']); L.vline(25, 50, 57, P['navy'])
    L.rect(17, 58, 6, 3, P['choc']); L.rect(25, 58, 6, 3, P['choc'])
    L.hline(18, 21, 58, P['brown_d']); L.hline(26, 29, 58, P['brown_d'])
    L.hline(17, 22, 60, P['black']); L.hline(25, 30, 60, P['black'])
    L.outline(); out.paste(L, 0, 0)

    # hanging arm (viewer left)
    A = _layer()
    A.rect(12, 36 + b, 4, 11, P['tan'])
    A.vline(15, 36 + b, 46 + b, P['brown'])
    A.vline(12, 37 + b, 45 + b, P['cream'])
    A.hline(12, 15, 46 + b, P['cream'])
    A.rect(12, 47 + b, 4, 3, P['skin_l'])
    A.hline(12, 15, 49 + b, P['skin'])
    A.outline(); out.paste(A, 0, 0)

    # coat body
    C = _layer()
    for y in range(34, 52):
        t = (y - 34) / 17
        x0, x1 = 16 - round(t * 2), 31 + round(t * 2)
        yy = y + b if y < 51 else y + (b if b == 0 else 0)
        C.hline(x0, x1, y + b, P['tan'])
        C.px(x0, y + b, P['cream'])
        C.hline(x1 - 2, x1, y + b, P['brown'])
    # shirt V + tie
    for y in range(34, 45):
        half = max(0, 2 - (y - 34) // 4)
        C.hline(23 - half, 24 + half, y + b, P['white'])
    C.vline(23, 35 + b, 42 + b, P['red']); C.vline(24, 35 + b, 42 + b, P['red_d'])
    C.hline(23, 24, 35 + b, P['red_d'])
    C.px(23, 43 + b, P['red_d'])
    # lapels
    for i in range(5):
        C.px(21 - i // 2, 34 + i + b, P['cream']); C.px(26 + i // 2, 34 + i + b, P['brown'])
    # belt
    C.hline(16, 31, 45 + b, P['brown_d'])
    C.hline(15, 32, 46 + b, P['brown_d'])
    C.rect(22, 45 + b, 4, 2, P['gold'])
    C.px(23, 45 + b, P['yellow'])
    # coat split + pockets + buttons
    C.vline(24, 47 + b, 51 + b, P['brown'])
    C.hline(17, 20, 48 + b, P['brown']); C.hline(28, 31, 48 + b, P['brown_d'])
    C.px(21, 38 + b, P['choc']); C.px(21, 42 + b, P['choc'])
    C.outline(); out.paste(C, 0, 0)

    # head
    Hd = _layer()
    Hd.ellipse(24, 23 + b, 9, 9, P['skin_l'])
    Hd.rect(14, 22 + b, 2, 4, P['skin_l']); Hd.rect(32, 22 + b, 2, 4, P['skin_l'])  # ears
    Hd.px(14, 24 + b, P['skin']); Hd.px(33, 24 + b, P['skin'])
    # face shade right
    for y in range(15, 33):
        for x in range(29, 34):
            if Hd.a[y + b, x][3] and (x - 24) ** 2 / 81 + (y - 23) ** 2 / 81 > .55:
                Hd.px(x, y + b, P['skin'])
    Hd.hline(19, 29, 32 + b, P['skin'])
    # hair
    for x in range(15, 34):
        Hd.px(x, 15 + b, P['choc']); Hd.px(x, 16 + b, P['choc']); Hd.px(x, 17 + b, P['choc'])
        if x % 3 != 1: Hd.px(x, 18 + b, P['choc'])
        if x % 3 == 0 and 17 < x < 30: Hd.px(x, 19 + b, P['choc'])
    for y in range(18, 24):
        Hd.px(15, y + b, P['choc']); Hd.px(16, y + b, P['choc'] if y < 21 else P['skin_l'])
        Hd.px(32, y + b, P['choc']); Hd.px(31, y + b, P['choc'] if y < 21 else P['skin'])
    # eyebrows (determined)
    Hd.hline(18, 20, 21 + b, P['choc']); Hd.px(21, 22 + b, P['choc'])
    Hd.hline(27, 29, 21 + b, P['choc']); Hd.px(26, 22 + b, P['choc'])
    # eyes
    for ex in (19, 27):
        Hd.rect(ex, 23 + b, 2, 4, P['black'])
        Hd.px(ex, 23 + b, P['white'])
        Hd.px(ex + 1, 26 + b, P['navy_l'])
    # blush
    Hd.hline(17, 18, 28 + b, P['pink']); Hd.hline(29, 30, 28 + b, P['pink'])
    # smile
    Hd.px(22, 28 + b, P['brown_d']); Hd.hline(23, 25, 29 + b, P['brown_d']); Hd.px(26, 28 + b, P['brown_d'])
    Hd.px(24, 30 + b, P['red'])
    Hd.outline(); out.paste(Hd, 0, 0)

    # hat
    Ht = _layer()
    Ht.rect(16, 6 + b, 16, 8, P['brown'])
    Ht.px(16, 6 + b, T); Ht.px(31, 6 + b, T)
    Ht.hline(18, 29, 5 + b, P['brown'])
    Ht.rect(17, 7 + b, 2, 5, P['clay'])
    Ht.rect(29, 6 + b, 3, 7, P['brown_d'])
    Ht.hline(21, 26, 6 + b, P['brown_d'])  # crease
    Ht.rect(16, 11 + b, 16, 2, P['choc'])
    Ht.px(20, 11 + b, P['gold'])
    Ht.ellipse(24, 15 + b, 12, 2, P['brown_d'])
    Ht.hline(13, 35, 14 + b, P['brown'])
    Ht.hline(12, 36, 15 + b, P['brown_d'])
    Ht.outline(); out.paste(Ht, 0, 0)

    # raised arm holding magnifier
    Ar = _layer()
    Ar.line(32, 37 + b, 35, 44 + b, P['tan'], 3)
    Ar.line(36, 44 + b, 38, 37 + b, P['tan'], 3)
    Ar.px(33, 37 + b, P['tan'])
    Ar.px(37, 45 + b, P['brown']); Ar.px(38, 43 + b, P['brown']); Ar.px(38, 42 + b, P['brown'])
    Ar.px(34, 44 + b, P['brown'])
    Ar.hline(36, 39, 37 + b, P['cream'])
    Ar.outline(); out.paste(Ar, 0, 0)

    Mg = _layer()
    # handle
    Mg.line(37, 33 + b, 38, 29 + b, P['brown_d'], 2)
    Mg.px(37, 31 + b, P['brown'])
    cx, cy, r = 40, 22 + b, 6
    Mg.ellipse(cx, cy, r, r, P['gold'])
    Mg.ellipse(cx, cy, r - 2, r - 2, P['cyan'])
    for y in range(64):
        for x in range(48):
            d = ((x - cx) ** 2 + (y - cy) ** 2) ** .5
            if r - 2.5 < d <= r + .5 and (x - cx) + (y - cy) > 1:
                Mg.px(x, y, P['orange'])
            if d <= r - 2 and (x - cx) + (y - cy) > 2:
                Mg.px(x, y, P['blue'])
    Mg.px(cx - 2, cy - 1, P['white']); Mg.px(cx - 1, cy - 2, P['white'])
    Mg.outline(); out.paste(Mg, 0, 0)
    # hand in front of handle
    Hn = _layer()
    Hn.rect(36, 32 + b, 4, 4, P['skin_l'])
    Hn.hline(36, 39, 35 + b, P['skin'])
    Hn.px(39, 33 + b, P['skin'])
    Hn.outline(); out.paste(Hn, 0, 0)
    if frame == 1:
        sx, sy = 44, 16 + b
        for dx, dy in [(0, 0), (1, 0), (-1, 0), (0, 1), (0, -1)]:
            out.px(sx + dx, sy + dy, P['white'])
        for dx, dy in [(2, 0), (-2, 0), (0, 2), (0, -2)]:
            out.px(sx + dx, sy + dy, P['yellow'])
    return out


# ================================================================ BUTTONS
THEMES = {
    'kuning': dict(face='gold', hi='yellow', lip='orange', lip2='rust', text='choc', tshadow='clay',
                   hface='yellow', hhi='white', pface='orange', ptext='choc', arrow='rust'),
    'biru': dict(face='blue', hi='cyan', lip='blue_d', lip2='navy', text='white', tshadow='blue_d',
                 hface='blue', hhi='white', pface='blue_d', ptext='grey_l', arrow='yellow'),
    'merah': dict(face='red', hi='pink', lip='red_d', lip2='purple', text='white', tshadow='red_d',
                  hface='red', hhi='white', pface='red_d', ptext='pink', arrow='yellow'),
    'krem': dict(face='cream', hi='white', lip='tan', lip2='brown', text='choc', tshadow='tan',
                 hface='white', hhi='white', pface='tan', ptext='brown_d', arrow='red'),
}


def button(w, h, label, theme='biru', state='normal', scale=1):
    t = {k: P[v] for k, v in THEMES[theme].items()}
    cv = Canvas(w, h)
    y0 = 2 if state == 'pressed' else 0
    lip = 0 if state == 'pressed' else 3
    # body
    cv.rect(1, y0, w - 2, h - y0, P['black'])
    cv.rect(0, y0 + 1, w, h - y0 - 2, P['black'])
    face = t['face'] if state == 'normal' else (t['hface'] if state == 'hover' else t['pface'])
    fh = h - y0 - 2 - lip
    cv.rect(1, y0 + 1, w - 2, fh, face)
    if lip:
        cv.rect(1, y0 + 1 + fh, w - 2, lip - 1, t['lip'])
        cv.rect(1, y0 + fh + lip, w - 2, 1, t['lip2'])
        cv.px(1, y0 + fh + lip, P['black']); cv.px(w - 2, y0 + fh + lip, P['black'])
    # highlight
    hi = t['hhi'] if state == 'hover' else t['hi']
    if state != 'pressed':
        cv.hline(2, w - 3, y0 + 1, hi)
        cv.vline(1, y0 + 2, y0 + fh - 1, hi)
        cv.px(2, y0 + 2, P['white'])
    else:
        cv.hline(1, w - 2, y0 + 1, t['lip'])  # inner top shadow when pressed
    # label
    if label:
        tm = text_mask(label, scale)
        tx = (w - tm.shape[1]) // 2
        ty = y0 + 1 + (fh - tm.shape[0]) // 2 + (1 if state == 'pressed' else 0)
        tc = t['ptext'] if state == 'pressed' else t['text']
        if state != 'pressed':
            cv.mask_fill(tm, tx, ty + 1, t['tshadow'])
        cv.mask_fill(tm, tx, ty, tc)
        if state == 'hover':
            ay = y0 + 1 + fh // 2
            ah = 3 if fh >= 12 else 2
            for i in range(ah):
                cv.vline(tx - 7 + i, ay - (ah - 1 - i), ay + (ah - 1 - i), t['arrow'])
                cv.vline(tx + tm.shape[1] + 6 - i, ay - (ah - 1 - i), ay + (ah - 1 - i), t['arrow'])
    return cv


def close_button(state='normal'):
    cv = button(14, 14, '', 'merah', state)
    y0 = 2 if state == 'pressed' else 0
    c = P['pink'] if state == 'pressed' else P['white']
    for i in range(5):
        cv.px(4 + i, y0 + 2 + i, c); cv.px(8 - i, y0 + 2 + i, c)
        cv.px(5 + i, y0 + 2 + i, c); cv.px(9 - i, y0 + 2 + i, c)
    return cv
