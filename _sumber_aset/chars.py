"""Character sprites (16x24) and portraits (48x48) from parameter sets."""
from pix import *

SHADE = {'white': 'grey_l', 'grey_l': 'grey', 'grey': 'grey_d', 'grey_d': 'navy_l', 'navy_l': 'navy',
         'navy': 'black', 'red': 'red_d', 'red_d': 'purple', 'blue': 'blue_d', 'blue_d': 'navy',
         'cyan': 'blue', 'green': 'green_m', 'green_m': 'green_d', 'green_d': 'teal_d', 'yellow': 'gold',
         'gold': 'orange', 'orange': 'rust', 'rust': 'brown_d', 'tan': 'brown', 'cream': 'tan',
         'brown': 'brown_d', 'brown_d': 'choc', 'choc': 'black', 'pink': 'magenta', 'magenta': 'purple',
         'purple': 'navy', 'clay': 'rust', 'skin_l': 'skin', 'skin': 'brown', 'teal_d': 'black',
         'black': 'black'}
LIGHT = {v: k for k, v in SHADE.items()}
LIGHT.update({'blue': 'cyan', 'green_m': 'green', 'red': 'pink', 'gold': 'yellow', 'navy_l': 'grey_d',
              'brown': 'tan', 'tan': 'cream', 'skin': 'skin_l', 'grey': 'grey_l', 'orange': 'gold'})


def S(c): return SHADE.get(c, c)
def Lt(c): return LIGHT.get(c, c)


# ---------------------------------------------------------------- NPC DEFINITIONS
# keys: kid, skin, hair (color), style (short/long/bun/bald/spiky/pony), top, bottom, bottom_type
# (pants/skirt/longskirt), acc: list of accessories
NPCS = {
    # Level 1 - Sekolah
    'bu_rina':  dict(name='Bu Rina', kid=False, skin='skin_l', hair='choc', style='short', top='teal_d',
                     bottom='navy_l', btype='longskirt', acc=['kerudung'], kcol='blue', batik=True),
    'pak_joko': dict(name='Pak Joko', kid=False, skin='skin', hair='grey', style='short', top='grey_d',
                     bottom='navy_l', btype='pants', acc=['topi', 'kumis'], hatcol='green_m'),
    'dodi':     dict(name='Dodi', kid=True, skin='skin', hair='black', style='spiky', top='white',
                     bottom='red', btype='pants', acc=['tas']),
    'nisa':     dict(name='Nisa', kid=True, skin='skin_l', hair='choc', style='long', top='white',
                     bottom='red', btype='skirt', acc=['kacamata']),
    # Level 2 - Taman
    'pak_harun': dict(name='Pak Harun', kid=False, skin='brown', hair='black', style='short', top='green_m',
                      bottom='brown_d', btype='pants', acc=['caping', 'kumis']),
    'bu_wati':  dict(name='Bu Wati', kid=False, skin='skin', hair='black', style='bun', top='magenta',
                     bottom='purple', btype='longskirt', acc=['celemek']),
    'mas_parkir': dict(name='Mas Parkir', kid=False, skin='skin', hair='black', style='spiky', top='navy_l',
                       bottom='navy', btype='pants', acc=['rompi']),
    'anak_layangan': dict(name='Rara', kid=True, skin='skin', hair='choc', style='pigtail', top='gold',
                          bottom='blue_d', btype='skirt', acc=['kuncir']),
    'bima':     dict(name='Bima', kid=True, skin='skin', hair='black', style='short', top='blue',
                     bottom='navy_l', btype='pants', acc=['kacamata']),
    # Level 3 - Pasar
    'bu_sri':   dict(name='Bu Sri', kid=False, skin='skin', hair='choc', style='short', top='rust',
                     bottom='brown_d', btype='longskirt', acc=['kerudung'], kcol='green_m', batik=True),
    'pedagang_buah': dict(name='Pak Darto', kid=False, skin='brown', hair='grey', style='short', top='blue_d',
                          bottom='choc', btype='pants', acc=['topi', 'kumis'], hatcol='red'),
    'ibu_pembeli': dict(name='Bu Lastri', kid=False, skin='skin_l', hair='choc', style='bun', top='pink',
                        bottom='navy_l', btype='longskirt', acc=['tas']),
    'anak_pedagang': dict(name='Ayu', kid=True, skin='brown', hair='black', style='pigtail', top='green',
                          bottom='brown_d', btype='skirt', acc=['kuncir']),
    'tukang_becak': dict(name='Pak Min', kid=False, skin='brown', hair='black', style='short', top='white',
                         bottom='navy_l', btype='pants', acc=['handuk', 'kumis'], singlet=True),
    'tari':     dict(name='Tari', kid=True, skin='skin', hair='choc', style='pony', top='orange',
                     bottom='navy_l', btype='skirt', acc=['kacamata']),
    # Level 4 - Museum
    'pak_hadi': dict(name='Pak Hadi', kid=False, skin='skin_l', hair='grey_l', style='bald', top='navy',
                     bottom='navy', btype='pants', acc=['jas', 'kumis']),
    'pemandu':  dict(name='Kak Wulan', kid=False, skin='skin', hair='choc', style='long', top='red_d',
                     bottom='navy_l', btype='pants', acc=['topi'], hatcol='gold'),
    'pengunjung': dict(name='Bu Ratna', kid=False, skin='skin', hair='black', style='bun', top='teal_d',
                       bottom='grey_d', btype='longskirt', acc=['tas'], tascol='red'),
    'anak_rombongan': dict(name='Sinta', kid=True, skin='skin_l', hair='black', style='pigtail', top='white',
                           bottom='blue_d', btype='skirt', acc=['kuncir']),
    'satpam':   dict(name='Pak Satpam', kid=False, skin='brown', hair='black', style='short', top='grey_d',
                     bottom='navy', btype='pants', acc=['satpam', 'kumis']),
    'arga':     dict(name='Kak Arga', kid=False, skin='skin', hair='black', style='spiky', top='green_m',
                     bottom='navy_l', btype='pants', acc=['kacamata'], teen=True),
}


# ---------------------------------------------------------------- SPRITE (front, 16x24)
def geom(p):
    if p.get('kid'):
        return dict(H0=3, T0=13, T1=17, L0=18)
    if p.get('teen'):
        return dict(H0=2, T0=12, T1=17, L0=18)
    return dict(H0=1, T0=11, T1=16, L0=17)


def npc_sprite(p, frame=0):
    """front-facing idle. frame 1 = breathing (upper body 1px down) + blink"""
    g = geom(p)
    H0, T0, T1, L0 = g['H0'], g['T0'], g['T1'], g['L0']
    cv = Canvas(16, 24)
    b = 1 if frame == 1 else 0
    top, bot = p['top'], p['bottom']
    acc = p.get('acc', [])
    skin = p['skin']
    # ---- legs / bottom
    shoe = 'choc' if p.get('kid') else 'black'
    if p['btype'] == 'pants':
        cv.rect(4, L0, 8, 1, P[bot])
        cv.rect(5, L0, 2, 22 - L0, P[bot]); cv.rect(9, L0, 2, 22 - L0, P[bot])
        cv.vline(6, L0 + 1, 21, P[S(bot)]); cv.vline(10, L0 + 1, 21, P[S(bot)])
    elif p['btype'] == 'skirt':
        cv.rect(4, L0, 8, 2, P[bot]); cv.hline(4, 11, L0 + 1, P[S(bot)])
        cv.rect(5, L0 + 2, 2, 20 - L0 - 2 + 1, P[skin]); cv.rect(9, L0 + 2, 2, 20 - L0 - 2 + 1, P[skin])
        cv.hline(5, 6, 21, P['white']); cv.hline(9, 10, 21, P['white'])
    else:  # longskirt
        cv.rect(4, L0, 8, 22 - L0, P[bot])
        cv.rect(3, 20, 10, 2, P[bot])
        cv.vline(8, L0 + 1, 21, P[S(bot)]); cv.hline(3, 12, 21, P[S(bot)])
    cv.hline(5, 6, 22, P[shoe]); cv.hline(9, 10, 22, P[shoe])
    if p['btype'] == 'longskirt':
        cv.hline(4, 6, 22, P[shoe]); cv.hline(9, 11, 22, P[shoe])

    # ---- torso
    y0 = T0 + b
    tcol = top
    cv.rect(4, y0, 8, T1 - T0 + 1 - b, P[tcol])
    cv.vline(11, y0, T1, P[S(tcol)])
    cv.hline(4, 11, T1, P[S(tcol)])
    if p.get('batik'):
        for yy in range(y0 + 1, T1):
            for xx in range(5, 11):
                if (xx + yy * 2) % 4 == 0: cv.px(xx, yy, P['gold'])
    if p.get('singlet'):
        cv.rect(3, y0, 1, T1 - y0, P[skin]); cv.rect(12, y0, 1, T1 - y0, P[skin])
    # sleeves + hands
    sleeve = skin if p.get('singlet') else tcol
    cv.rect(3, y0, 1, T1 - y0, P[sleeve]); cv.rect(12, y0, 1, T1 - y0, P[S(sleeve)])
    cv.px(3, T1, P[skin]); cv.px(12, T1, P[S(skin)])
    # school uniform detail: collar + name tag
    if tcol == 'white' and p.get('kid'):
        cv.px(6, y0, P['grey_l']); cv.px(9, y0, P['grey_l'])
        cv.px(10, y0 + 2, P['blue']) if False else None
        cv.vline(7, y0 + 1, T1 - 1, P['grey_l'])
    # accessories on torso
    if 'celemek' in acc:
        cv.rect(5, y0 + 1, 6, T1 - y0 + 3, P['white'])
        cv.hline(5, 10, T1 + 2, P['grey_l'])
        cv.px(5, y0, P['white']); cv.px(10, y0, P['white'])
        cv.px(7, y0 + 3, P['grey_l']); cv.px(8, y0 + 3, P['grey_l'])
    if 'rompi' in acc:
        cv.rect(4, y0, 3, T1 - y0 + 1, P['orange']); cv.rect(9, y0, 3, T1 - y0 + 1, P['orange'])
        cv.hline(4, 6, y0 + 2, P['yellow']); cv.hline(9, 11, y0 + 2, P['yellow'])
        cv.vline(11, y0, T1, P['rust'])
    if 'jas' in acc:
        cv.rect(7, y0, 2, 3, P['white']); cv.px(7, y0 + 1, P['red']); cv.px(8, y0 + 1, P['red_d'])
        cv.px(7, y0 + 2, P['red'])
        cv.px(6, y0, P['navy_l']); cv.px(9, y0, P['navy_l'])
    if 'satpam' in acc:
        cv.px(5, y0 + 1, P['gold']); cv.px(10, y0 + 1, P['navy'])
        cv.hline(4, 11, T1 - 1, P['black']); cv.px(7, T1 - 1, P['gold'])
    if 'handuk' in acc:
        cv.hline(4, 11, y0, P['white']); cv.px(5, y0 + 1, P['white']); cv.px(5, y0 + 2, P['grey_l'])
        cv.px(10, y0 + 1, P['white'])
    if 'tas' in acc:
        tc = p.get('tascol', 'red')
        for i in range(T1 - y0 + 1):
            cv.px(4 + i * 7 // max(1, T1 - y0), y0 + i, P['red_d'])
        cv.rect(12, T1 - 2, 2, 3, P[tc]); cv.px(13, T1, P[S(tc)])
    # ---- head
    hy = H0 + b
    cv.rect(3, hy, 10, 10, P[skin])
    for x, y in [(3, hy), (12, hy), (3, hy + 9), (12, hy + 9)]:
        cv.px(x, y, T)
    cv.vline(12, hy + 1, hy + 8, P[S(skin)])
    cv.hline(4, 11, hy + 9, P[S(skin)])
    hair = p['hair']
    st = p['style']
    kerudung = 'kerudung' in acc
    # back hair (long)
    if st == 'long' and not kerudung:
        cv.rect(2, hy + 3, 2, 9, P[hair]); cv.rect(12, hy + 3, 2, 9, P[S(hair)])
    if not kerudung:
        if st == 'bald':
            cv.hline(4, 11, hy, P[skin]); cv.rect(3, hy + 2, 1, 4, P[hair]); cv.rect(12, hy + 2, 1, 4, P[hair])
            cv.px(5, hy + 1, P[Lt(skin)])
        else:
            cv.rect(3, hy, 10, 3, P[hair]); cv.px(3, hy, T); cv.px(12, hy, T)
            cv.hline(4, 11, hy - 1 if st in ('spiky', 'bun') else hy, P[hair])
            cv.rect(3, hy + 3, 1, 3, P[hair]); cv.rect(12, hy + 3, 1, 3, P[S(hair)])
            if st == 'spiky':
                for x in (4, 7, 10): cv.px(x, hy - 2, P[hair])
                cv.px(5, hy + 3, P[hair]); cv.px(9, hy + 3, P[hair])
            elif st in ('long', 'pony', 'pigtail'):
                cv.hline(4, 6, hy + 3, P[hair]); cv.px(9, hy + 3, P[hair]); cv.px(10, hy + 3, P[hair])
            else:
                cv.px(4, hy + 3, P[hair]); cv.px(5, hy + 3, P[hair])
            cv.px(5, hy + 1, P[Lt(hair)]); cv.px(6, hy + 1, P[Lt(hair)])
            if st == 'bun':
                cv.rect(6, hy - 3, 4, 2, P[hair]); cv.px(7, hy - 3, P[Lt(hair)])
            if st == 'pony':
                cv.rect(13, hy + 2, 2, 5, P[hair]); cv.px(13, hy + 2, P['red'])
    if 'kuncir' in acc or st == 'pigtail':
        cv.rect(1, hy + 3, 2, 4, P[hair]); cv.rect(13, hy + 3, 2, 4, P[hair])
        cv.px(2, hy + 3, P['pink']); cv.px(13, hy + 3, P['pink'])
    if kerudung:
        k = p.get('kcol', 'blue')
        cv.rect(2, hy - 1, 12, 12, P[k])
        for x, y in [(2, hy - 1), (13, hy - 1)]: cv.px(x, y, T)
        cv.rect(4, hy + 3, 8, 6, P[skin]); cv.vline(11, hy + 3, hy + 8, P[S(skin)])
        cv.hline(5, 10, hy + 9, P[skin])
        cv.rect(3, T0 + b, 10, 2, P[k]); cv.hline(3, 12, T0 + b + 2, P[S(k)])
        cv.vline(13, hy, hy + 10, P[S(k)])
        cv.hline(4, 11, hy + 2, P[S(k)])
    # face
    ey = hy + 5
    blink = frame == 1
    if 'kacamata' in acc:
        for ex in (4, 9):
            cv.border(ex, ey - 1, 3, 3, P['black'])
            cv.px(ex + 1, ey, P['cyan'] if not blink else P['black'])
        cv.hline(7, 8, ey, P['black'])
    else:
        for ex in (5, 10):
            if blink:
                cv.px(ex, ey + 1, P['black'])
            else:
                cv.vline(ex, ey, ey + 1, P['black'])
    if 'kumis' in acc:
        cv.hline(6, 9, hy + 7, P[hair if hair not in ('grey_l',) else 'grey'])
    else:
        cv.hline(7, 8, hy + 8, P[S(skin)])
    if p.get('kid'):
        cv.px(4, hy + 7, P['pink']); cv.px(11, hy + 7, P['pink'])
    # hats
    if 'topi' in acc:
        hc = p.get('hatcol', 'red')
        cv.rect(3, hy - 2, 10, 3, P[hc]); cv.px(3, hy - 2, T); cv.px(12, hy - 2, T)
        cv.hline(2, 13, hy + 1, P[S(hc)])
        cv.px(6, hy - 1, P[Lt(hc)])
    if 'caping' in acc:
        cv.hline(1, 14, hy + 1, P['tan']); cv.hline(2, 13, hy, P['cream'])
        cv.hline(4, 11, hy - 1, P['cream']); cv.hline(6, 9, hy - 2, P['tan'])
        cv.hline(2, 13, hy + 2, P['brown'])
        for x in (4, 8, 11): cv.px(x, hy, P['tan'])
    if 'satpam' in acc:
        cv.rect(3, hy - 2, 10, 3, P['navy']); cv.px(3, hy - 2, T); cv.px(12, hy - 2, T)
        cv.hline(3, 12, hy + 1, P['black']); cv.px(7, hy - 1, P['gold']); cv.px(8, hy - 1, P['gold'])
    cv.outline(P['black'])
    return cv


# ---------------------------------------------------------------- PLAYER (4 directions x 4 frames)
PL = dict(skin='skin_l', hair='choc', coat='tan', pants='navy_l', hat='brown')


def player_frame(direction, f):
    cv = Canvas(16, 24)
    H0, T0, T1, L0 = 3, 13, 17, 18
    step = [0, 1, 0, -1][f]  # leg phase
    skin, coat, pants, hat = PL['skin'], PL['coat'], PL['pants'], PL['hat']
    bob = 1 if f in (1, 3) else 0
    if direction in ('down', 'up'):
        # legs
        ll = 21 - (1 if step == 1 else 0); rl = 21 - (1 if step == -1 else 0)
        cv.rect(5, L0, 2, ll - L0 + 1, P[pants]); cv.rect(9, L0, 2, rl - L0 + 1, P[pants])
        cv.hline(5, 6, ll + 1, P['choc']); cv.hline(9, 10, rl + 1, P['choc'])
        # coat
        y0 = T0 - bob
        cv.rect(4, y0, 8, L0 - y0 + 1, P[coat])
        cv.vline(11, y0, L0, P[S(coat)]); cv.hline(4, 11, L0, P[S(coat)])
        cv.hline(4, 11, T1 - 1, P['brown_d'])  # belt
        # arms swing
        la = 1 if step == -1 else 0; ra = 1 if step == 1 else 0
        cv.rect(3, y0, 1, 4 + la, P[coat]); cv.px(3, y0 + 4 + la, P[skin])
        cv.rect(12, y0, 1, 4 + ra, P[S(coat)]); cv.px(12, y0 + 4 + ra, P[S(skin)])
        hy = H0 - bob
        if direction == 'down':
            cv.rect(6, y0, 4, 3, P['white']); cv.vline(7, y0 + 1, y0 + 3, P['red']); cv.vline(8, y0 + 1, y0 + 2, P['red_d'])
            cv.px(5, y0, P['cream']); cv.px(10, y0, P['brown'])
            cv.px(7, T1 - 1, P['gold'])
            cv.rect(3, hy, 10, 10, P[skin])
            for x, y in [(3, hy), (12, hy), (3, hy + 9), (12, hy + 9)]: cv.px(x, y, T)
            cv.vline(12, hy + 1, hy + 8, P[S(skin)])
            cv.rect(3, hy + 2, 10, 2, P[PL['hair']]); cv.px(3, hy + 4, P[PL['hair']]); cv.px(12, hy + 4, P[PL['hair']])
            cv.px(5, hy + 4, P[PL['hair']])
            cv.vline(5, hy + 5, hy + 6, P['black']); cv.vline(10, hy + 5, hy + 6, P['black'])
            cv.px(4, hy + 7, P['pink']); cv.px(11, hy + 7, P['pink'])
            cv.hline(7, 8, hy + 8, P['brown_d'])
        else:
            cv.vline(7, y0 + 1, L0 - 1, P[S(coat)])
            cv.rect(3, hy, 10, 10, P[PL['hair']])
            for x, y in [(3, hy), (12, hy), (3, hy + 9), (12, hy + 9)]: cv.px(x, y, T)
            cv.hline(4, 11, hy + 9, P[skin]); cv.px(5, hy + 4, P[Lt(PL['hair'])])
            cv.px(3, hy + 5, P[skin]); cv.px(12, hy + 5, P[skin])
        # hat (fedora)
        cv.rect(4, hy - 2, 8, 4, P[hat]); cv.px(4, hy - 2, T); cv.px(11, hy - 2, T)
        cv.hline(4, 11, hy, P['choc'])
        cv.hline(2, 13, hy + 1, P['brown_d'])
        cv.px(5, hy - 1, P['clay'])
    else:  # right (left is mirror)
        ft = 22
        if step == 0:
            cv.rect(6, L0, 4, 4, P[pants]); cv.vline(7, L0 + 1, 21, P[S(pants)])
            cv.hline(6, 10, ft, P['choc'])
        else:
            back, front = (5, 9)
            cv.rect(back, L0, 2, 4, P[S(pants)]); cv.rect(front, L0, 2, 4, P[pants])
            cv.rect(7, L0, 2, 1, P[pants])
            cv.hline(back - 1, back + 1, ft, P['choc']); cv.hline(front, front + 2, ft, P['choc'])
        y0 = T0 - bob
        cv.rect(5, y0, 6, L0 - y0 + 1, P[coat])
        cv.vline(5, y0, L0, P[S(coat)]); cv.hline(5, 10, L0, P[S(coat)])
        cv.hline(5, 10, T1 - 1, P['brown_d'])
        cv.px(10, y0, P['white']); cv.px(10, y0 + 1, P['red'])
        ax = {0: 7, 1: 9, 2: 7, 3: 5}[f]
        cv.rect(ax, y0 + 1, 2, 3, P[S(coat)] if f != 1 else P[coat]); cv.px(ax + (1 if f == 1 else 0), y0 + 4, P[skin])
        hy = H0 - bob
        cv.rect(4, hy, 9, 10, P[skin])
        for x, y in [(4, hy), (12, hy), (4, hy + 9), (12, hy + 9)]: cv.px(x, y, T)
        cv.rect(4, hy + 2, 5, 5, P[PL['hair']]); cv.rect(9, hy + 2, 4, 2, P[PL['hair']])
        cv.px(8, hy + 4, P[skin]); cv.px(7, hy + 5, P['skin'])  # ear
        cv.vline(11, hy + 5, hy + 6, P['black'])
        cv.px(13, hy + 6, P[skin])
        cv.px(11, hy + 7, P['pink'])
        cv.hline(10, 11, hy + 8, P['brown_d'])
        cv.rect(4, hy - 2, 8, 4, P[hat]); cv.px(4, hy - 2, T); cv.px(11, hy - 2, T)
        cv.hline(4, 11, hy, P['choc'])
        cv.hline(3, 14, hy + 1, P['brown_d'])
        cv.px(6, hy - 1, P['clay'])
    cv.outline(P['black'])
    return cv


def player_sheet():
    """rows: down, left, right, up ; cols: 4 walk frames (frame 0 = idle)"""
    sheet = Canvas(64, 96)
    for r, d in enumerate(['down', 'left', 'right', 'up']):
        for f in range(4):
            if d == 'left':
                fr = player_frame('right', f)
                fr.a = fr.a[:, ::-1].copy()
            else:
                fr = player_frame(d, f)
            sheet.paste(fr, f * 16, r * 24)
    return sheet


# ---------------------------------------------------------------- PORTRAIT 48x48
def portrait(p, expr='normal', player=False):
    cv = Canvas(48, 48)
    acc = p.get('acc', [])
    skin = p['skin']; hair = p['hair']; st = p['style']; top = p['top']
    kid = p.get('kid')
    ker = 'kerudung' in acc
    # long back hair
    if st == 'long' and not ker:
        cv.rect(10, 14, 28, 30, P[S(hair)])
    # shoulders / clothes
    cv.ellipse(24, 50, 20, 11, P[top])
    for y in range(40, 48):
        for x in range(48):
            if cv.a[y, x][3] and x > 33: cv.px(x, y, P[S(top)])
    if p.get('batik'):
        for y in range(40, 48):
            for x in range(6, 42):
                if cv.a[y, x][3] and (x + y * 2) % 5 == 0: cv.px(x, y, P['gold'])
    if p.get('singlet'):
        cv.ellipse(24, 50, 20, 11, P[skin]); cv.rect(15, 40, 18, 8, P['white'])
    # neck
    cv.rect(20, 32, 8, 8, P[S(skin)])
    # collars / accessories on body
    if top == 'white' and kid:
        for i in range(5): cv.hline(19 - i, 20, 39 + i, P['grey_l']); cv.hline(27, 28 + i, 39 + i, P['grey_l'])
        cv.rect(30, 42, 6, 2, P['blue_d'])  # name badge
    if player:
        cv.ellipse(24, 50, 20, 11, P['tan'])
        for y in range(40, 48):
            for x in range(48):
                if cv.a[y, x][3] and x > 33: cv.px(x, y, P['brown'])
        cv.rect(20, 38, 8, 10, P['white'])
        cv.rect(23, 40, 2, 8, P['red']); cv.vline(24, 40, 47, P['red_d'])
        for i in range(6):
            cv.px(19 - i // 2, 38 + i, P['cream']); cv.px(28 + i // 2, 38 + i, P['brown'])
    if 'celemek' in acc:
        cv.rect(16, 40, 16, 8, P['white']); cv.hline(16, 31, 40, P['grey_l'])
        cv.line(16, 40, 19, 34, P['white']); cv.line(31, 40, 28, 34, P['white'])
    if 'rompi' in acc:
        cv.rect(8, 40, 10, 8, P['orange']); cv.rect(30, 40, 10, 8, P['orange'])
        cv.hline(8, 17, 44, P['yellow']); cv.hline(30, 39, 44, P['yellow'])
    if 'jas' in acc:
        cv.rect(20, 38, 8, 10, P['white'])
        cv.rect(23, 39, 2, 9, P['red']); cv.px(24, 39, P['red_d'])
        for i in range(8):
            cv.px(19 - i // 2, 38 + i, P['navy_l']); cv.px(28 + i // 2, 38 + i, P['navy_l'])
    if 'satpam' in acc:
        cv.rect(32, 42, 5, 4, P['gold']); cv.px(33, 43, P['yellow'])
        cv.rect(11, 42, 5, 3, P['navy'])
        for i in range(6): cv.px(19 - i // 2, 38 + i, P['grey']); cv.px(28 + i // 2, 38 + i, P['grey'])
    if 'handuk' in acc:
        cv.rect(14, 37, 20, 4, P['white']); cv.hline(14, 33, 40, P['grey_l'])
        cv.rect(15, 41, 4, 7, P['white']); cv.vline(18, 41, 47, P['grey_l'])
    if 'tas' in acc:
        cv.line(10, 38, 36, 47, P['red_d'], 2)
    if st == 'pony' and not ker:
        cv.rect(36, 14, 5, 14, P[hair]); cv.px(37, 14, P['red']); cv.px(38, 14, P['red'])
    if ('kuncir' in acc or st == 'pigtail') and not ker:
        cv.ellipse(8, 22, 4, 7, P[hair]); cv.ellipse(40, 22, 4, 7, P[hair])
        cv.rect(9, 15, 3, 2, P['pink']); cv.rect(36, 15, 3, 2, P['pink'])
    if ker:
        k = p.get('kcol', 'blue')
        cv.ellipse(24, 22, 16, 17, P[k])
        cv.rect(8, 30, 32, 12, P[k])
        cv.ellipse(24, 42, 18, 6, P[k])
        for y in range(4, 46):
            for x in range(30, 42):
                if cv.a[y, x][3] and cv.a[y, x][:3].tolist() == list(P[k][:3]) and x > 34:
                    cv.px(x, y, P[S(k)])
    # head
    hy = 8 if not kid else 10
    cv.ellipse(24, hy + 13, 12, 13 if not kid else 12, P[skin])
    cv.rect(11, hy + 12, 3, 6, P[skin]); cv.rect(34, hy + 12, 3, 6, P[skin])  # ears
    cv.px(12, hy + 14, P[S(skin)]); cv.px(35, hy + 14, P[S(skin)])
    for y in range(48):
        for x in range(28, 37):
            if cv.a[y, x][:3].tolist() == list(P[skin][:3]) and (x - 24) ** 2 / 144 + (y - hy - 13) ** 2 / 169 > .6:
                cv.px(x, y, P[S(skin)])
    if ker:
        k = p.get('kcol', 'blue')
        # re-cover top of head + sides, leaving face oval
        for y in range(0, 48):
            for x in range(48):
                inside_hood = ((x - 24) / 16.5) ** 2 + ((y - 22) / 17.5) ** 2 <= 1
                face = ((x - 24) / 10.5) ** 2 + ((y - hy - 15) / 11) ** 2 <= 1
                if inside_hood and not face:
                    cv.px(x, y, P[k] if x < 33 else P[S(k)])
        cv.hline(16, 31, hy + 4, P[Lt(k)])
    # hair (front)
    if not ker:
        if st == 'bald':
            cv.rect(10, hy + 9, 4, 8, P[hair]); cv.rect(34, hy + 9, 4, 8, P[hair])
            cv.px(19, hy + 3, P[Lt(skin)]); cv.px(20, hy + 2, P[Lt(skin)])
        else:
            for y in range(hy - 2, hy + 9):
                for x in range(10, 39):
                    if ((x - 24) / 14) ** 2 + ((y - hy - 8) / 10) ** 2 <= 1 and y < hy + 7:
                        cv.px(x, y, P[hair])
            # fringe
            if st == 'spiky':
                for i, x in enumerate(range(12, 37, 4)):
                    cv.line(x, hy - 3 - (i % 2) * 2, x + 2, hy + 1, P[hair], 2)
                for x in range(13, 36, 5):
                    cv.vline(x, hy + 6, hy + 8, P[hair])
            elif st in ('long', 'pony', 'pigtail'):
                cv.rect(12, hy + 6, 11, 3, P[hair]); cv.rect(27, hy + 6, 9, 2, P[hair])
                cv.rect(10, hy + 6, 3, 14, P[hair]); cv.rect(35, hy + 6, 3, 14, P[hair])
            elif st == 'bun':
                cv.ellipse(24, hy - 4, 6, 4, P[hair])
                cv.rect(11, hy + 6, 4, 8, P[hair]); cv.rect(33, hy + 6, 4, 8, P[hair])
            else:
                cv.rect(12, hy + 6, 8, 2, P[hair]); cv.rect(11, hy + 6, 3, 6, P[hair]); cv.rect(34, hy + 6, 3, 6, P[hair])
            # shine
            cv.hline(16, 21, hy + 1, P[Lt(hair)]); cv.hline(15, 18, hy + 2, P[Lt(hair)])
    # eyes
    ey = hy + 13
    brow = hair if hair not in ('grey_l',) else 'grey'
    if ker: brow = 'choc'
    cv.hline(16, 20, ey - 3, P[brow]); cv.hline(28, 32, ey - 3, P[brow])
    if expr == 'senang':
        for ex in (17, 29):
            cv.hline(ex, ex + 2, ey + 1, P['black']); cv.px(ex - 1, ey + 2, P['black']); cv.px(ex + 3, ey + 2, P['black'])
    else:
        for ex in (17, 29):
            cv.rect(ex, ey, 3, 4, P['black']); cv.px(ex, ey, P['white']); cv.px(ex + 2, ey + 3, P['navy_l'])
    if 'kacamata' in acc:
        for ex in (14, 26):
            cv.border(ex, ey - 2, 8, 7, P['black'])
            cv.px(ex + 1, ey - 1, P['white']); cv.px(ex + 2, ey - 1, P['cyan'])
        cv.hline(22, 25, ey, P['black'])
        cv.hline(11, 13, ey - 1, P['black']); cv.hline(34, 36, ey - 1, P['black'])
    # nose / mouth / blush
    cv.px(24, ey + 5, P[S(skin)]); cv.px(25, ey + 6, P[S(skin)])
    if kid or player:
        cv.rect(14, ey + 6, 3, 2, P['pink']); cv.rect(31, ey + 6, 3, 2, P['pink'])
    my = ey + 9
    if 'kumis' in acc:
        mc = hair if hair not in ('grey_l',) else 'grey'
        cv.rect(19, my - 2, 10, 2, P[mc]); cv.px(19, my - 1, T[:3] + (0,)) if False else None
    if expr == 'senang':
        cv.hline(20, 28, my, P['black']); cv.rect(21, my + 1, 7, 2, P['red_d']); cv.hline(22, 26, my + 2, P['red'])
        cv.px(20, my - 1, P['black']); cv.px(28, my - 1, P['black'])
    else:
        cv.hline(22, 26, my, P['brown_d']); cv.px(21, my - 1, P['brown_d']); cv.px(27, my - 1, P['brown_d'])
    # hats
    if 'topi' in acc:
        hc = p.get('hatcol', 'red')
        for y in range(hy - 7, hy + 6):
            for x in range(48):
                if ((x - 24) / 13.5) ** 2 + ((y - hy - 5) / 11) ** 2 <= 1 and y <= hy + 4:
                    cv.px(x, y, P[hc] if x < 32 else P[S(hc)])
        cv.rect(8, hy + 4, 32, 3, P[S(hc)]); cv.hline(8, 39, hy + 4, P[hc])
        cv.rect(16, hy - 4, 5, 2, P[Lt(hc)])
        cv.rect(22, hy - 7, 4, 2, P[S(hc)])
    if 'caping' in acc:
        for y in range(hy - 8, hy + 5):
            half = (y - hy + 8) * 23 // 12
            cv.hline(24 - half, 24 + half, y, P['cream'] if (y % 3) else P['tan'])
        cv.hline(1, 46, hy + 5, P['brown'])
    if 'satpam' in acc:
        cv.rect(11, hy - 4, 26, 8, P['navy']); cv.rect(8, hy + 3, 32, 3, P['black'])
        cv.rect(22, hy - 2, 4, 4, P['gold']); cv.px(23, hy - 1, P['yellow'])
    if player:
        cv.rect(11, hy - 6, 26, 10, P['brown']); cv.rect(11, hy + 1, 26, 3, P['choc'])
        cv.rect(4, hy + 4, 40, 3, P['brown_d']); cv.hline(4, 43, hy + 4, P['brown'])
        cv.rect(14, hy - 4, 3, 5, P['clay']); cv.rect(21, hy - 6, 6, 2, P['brown_d'])
        cv.px(13, hy + 2, P['gold'])
    cv.outline(P['black'])
    return cv


PLAYER_P = dict(name='Detektif', kid=True, skin='skin_l', hair='choc', style='short', top='tan', acc=[])
