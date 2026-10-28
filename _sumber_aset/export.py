import os, shutil
from PIL import Image
from pix import *
import bg
from ui import logo, player_pose, button, close_button
from ui2 import *

OUT = 'Aset_Menu_Misteri_Detektif'
shutil.rmtree(OUT, ignore_errors=True)
D = lambda *p: os.path.join(OUT, *p)
for d in ['background', 'logo', 'karakter', 'tombol', 'tombol/template', 'panel', 'layar', 'kartu_level',
          'kursor', 'ikon', 'font', '_preview']:
    os.makedirs(D(d), exist_ok=True)

files = []
def save(cv, *path):
    p = D(*path); cv.save(p); files.append(p)

# ---- background
sky, bld, fg = bg.sky(), bg.building(), bg.foreground()
save(sky, 'background', 'mnu_g_bg_langit.png')
save(bld, 'background', 'mnu_g_bg_gedung.png')
save(fg, 'background', 'mnu_g_bg_gerbang.png')
full = Canvas(320, 180); full.paste(sky, 0, 0); full.paste(bld, 0, 0); full.paste(fg, 0, 0)
save(full, 'background', 'mnu_g_bg_gabungan.png')

# ---- logo
lg = logo(); save(lg, 'logo', 'mnu_g_logo.png')

# ---- player pose
f0, f1 = player_pose(0), player_pose(1)
sheet = Canvas(96, 64); sheet.paste(f0, 0, 0); sheet.paste(f1, 48, 0)
save(sheet, 'karakter', 'mnu_g_pemain_pose_sheet.png')
save(f0, 'karakter', 'mnu_g_pemain_pose_f1.png'); save(f1, 'karakter', 'mnu_g_pemain_pose_f2.png')

# ---- buttons
BTN = [('main', 'MAIN', 'kuning', 72, 26, 2), ('opsi', 'OPSI', 'biru', 56, 20, 1),
       ('kredit', 'KREDIT', 'biru', 56, 20, 1), ('keluar', 'KELUAR', 'merah', 56, 20, 1),
       ('kembali', '< KEMBALI', 'krem', 64, 20, 1),
       ('lanjut', 'LANJUT', 'kuning', 112, 20, 1), ('opsi_jeda', 'OPSI', 'biru', 112, 20, 1),
       ('menu_utama', 'MENU UTAMA', 'merah', 112, 20, 1),
       ('main_lagi', 'MAIN LAGI', 'kuning', 72, 20, 1)]
for key, lab, th, w, h, sc in BTN:
    for st in ('normal', 'hover', 'pressed'):
        save(button(w, h, lab, th, st, sc), 'tombol', f'ui_g_btn_{key}_{st}.png')
for st in ('normal', 'hover', 'pressed'):
    save(close_button(st), 'tombol', f'ui_g_btn_tutup_{st}.png')
    for th in ('kuning', 'biru', 'merah', 'krem'):
        save(button(56, 20, '', th, st), 'tombol', 'template', f'ui_g_btn_kosong_{th}_{st}.png')

# ---- panels & controls
save(panel_opsi(), 'panel', 'ui_g_panel_opsi.png')
save(panel_jeda(), 'panel', 'ui_g_panel_jeda.png')
save(panel(200, 120, ''), 'panel', 'ui_g_panel_kosong.png')
save(slider_track(), 'panel', 'ui_g_slider_track.png')
save(slider_fill(), 'panel', 'ui_g_slider_isi.png')
save(slider_knob('normal'), 'panel', 'ui_g_slider_knob_normal.png')
save(slider_knob('hover'), 'panel', 'ui_g_slider_knob_hover.png')
save(toggle(False), 'panel', 'ui_g_toggle_mati.png')
save(toggle(True), 'panel', 'ui_g_toggle_nyala.png')

# ---- screens
save(splash(), 'layar', 'mnu_g_splash.png')
save(kredit_bg(), 'layar', 'mnu_g_kredit_bg.png')
save(kredit_full(), 'layar', 'mnu_g_kredit.png')
save(loading_bg(), 'layar', 'ui_g_loading_bg.png')
save(loading_icon_sheet(), 'layar', 'ui_g_loading_ikon_sheet.png')

# ---- level cards
save(kartu_level(), 'kartu_level', 'ui_g_kartu_level.png')
for n, nm in [(1, 'SEKOLAH'), (2, 'TAMAN'), (3, 'PASAR'), (4, 'MUSEUM')]:
    save(kartu_filled(n, nm), 'kartu_level', f'ui_g_kartu_level_{n}_{nm.lower()}.png')

# ---- cursors
save(cursor_normal(), 'kursor', 'ui_g_kursor_normal.png')
save(cursor_interaksi(), 'kursor', 'ui_g_kursor_interaksi.png')

# ---- icon
ic = app_icon()
save(ic, 'ikon', 'ui_g_icon_64.png')
big = ic.img().resize((256, 256), Image.NEAREST); big.save(D('ikon', 'ui_g_icon_256.png')); files.append(D('ikon', 'ui_g_icon_256.png'))
big.save(D('ikon', 'icon.ico'), sizes=[(16, 16), (32, 32), (48, 48), (64, 64), (128, 128), (256, 256)])
files.append(D('ikon', 'icon.ico'))

# ---- bitmap font (BMFont text format, Godot 4 imports .fnt)
chars = sorted(GLYPH.keys(), key=ord)
cols, cw, chh = 16, 8, 9
rows = (len(chars) + cols - 1) // cols
fimg = Canvas(cols * cw, rows * chh)
entries = []
for i, ch in enumerate(chars):
    g = GLYPH[ch]; x, y = (i % cols) * cw, (i // cols) * chh
    fimg.mask_fill(g, x, y, P['white'])
    adv = g.shape[1] + 1
    if ch == ' ': adv = 4
    entries.append((ord(ch), x, y, g.shape[1], 7, adv))
    if ch.isalpha() and ch.isupper():
        entries.append((ord(ch.lower()), x, y, g.shape[1], 7, adv))
fimg.save(D('font', 'font_detektif.png'))
with open(D('font', 'font_detektif.fnt'), 'w') as f:
    f.write('info face="DetektifPixel" size=8 bold=0 italic=0 charset="" unicode=1 stretchH=100 smooth=0 aa=1 padding=0,0,0,0 spacing=1,1\n')
    f.write(f'common lineHeight=10 base=7 scaleW={fimg.w} scaleH={fimg.h} pages=1 packed=0\n')
    f.write('page id=0 file="font_detektif.png"\n')
    f.write(f'chars count={len(entries)}\n')
    for cid, x, y, w, h, adv in entries:
        f.write(f'char id={cid} x={x} y={y} width={w} height={h} xoffset=0 yoffset=0 xadvance={adv} page=0 chnl=15\n')
files += [D('font', 'font_detektif.png'), D('font', 'font_detektif.fnt')]

# ================================================================ previews
def menu_frame(t=0, hover=None, bob=0):
    c = Canvas(320, 180)
    shift = t % 320
    s2 = Canvas(320, 180); s2.a[:] = np.roll(sky.a, -shift, axis=1)
    c.paste(s2, 0, 0); c.paste(bld, 0, 0); c.paste(fg, 0, 0)
    c.paste(lg, 160 - lg.w // 2, 6)
    c.paste(player_pose(bob), 14, 114)
    c.paste(button(72, 26, 'MAIN', 'kuning', 'hover' if hover == 0 else 'normal', 2), 124, 110)
    x = 160 - (56 * 3 + 12) // 2
    for i, (lab, th) in enumerate([('OPSI', 'biru'), ('KREDIT', 'biru'), ('KELUAR', 'merah')]):
        c.paste(button(56, 20, lab, th, 'hover' if hover == i + 1 else 'normal'), x + i * 62, 142)
    return c

mock = menu_frame(0, 0)
mock.save(D('_preview', 'mockup_main_menu_1280x720.png'), 4)
frames = []
for i in range(48):
    fr = menu_frame(i // 2, hover=(i // 12) % 4, bob=(i // 6) % 2)
    frames.append(fr.img().resize((640, 360), Image.NEAREST).convert('P', palette=Image.ADAPTIVE))
frames[0].save(D('_preview', 'animasi_main_menu.gif'), save_all=True, append_images=frames[1:], duration=90, loop=0)

# pause + options mockups over dimmed menu
def dim(c):
    d = Canvas(320, 180); d.a[:] = c.a
    for y in range(180):
        for x in range(320):
            if (x + y) % 2 == 0: d.a[y, x] = P['black']
    return d
m2 = dim(menu_frame()); m2.paste(opsi_preview(), 60, 30); m2.save(D('_preview', 'mockup_opsi_1280x720.png'), 4)
m3 = dim(menu_frame()); m3.paste(jeda_preview(), 80, 30); m3.save(D('_preview', 'mockup_jeda_1280x720.png'), 4)
m4 = kredit_full(); m4.paste(button(64, 20, '< KEMBALI', 'krem', 'normal'), 12, 11); m4.save(D('_preview', 'mockup_kredit_1280x720.png'), 4)
m5 = loading_bg(); m5.paste(crop(loading_icon_sheet(), 0, 0, 23, 23), 218, 148); m5.save(D('_preview', 'mockup_loading_1280x720.png'), 4)

# contact sheet of every asset
from PIL import ImageDraw
items = [(f, Image.open(f)) for f in files if f.endswith('.png') and '_preview' not in f and 'template' not in f
         and 'font' not in f and '256' not in f]
sc = 2; pad = 8; colw = 660
x = y = pad; rowh = 0
placed = []
for f, im in items:
    w, h = im.width * sc, im.height * sc
    if x + w > colw: x = pad; y += rowh + pad + 10; rowh = 0
    placed.append((f, im, x, y)); x += w + pad; rowh = max(rowh, h)
H = y + rowh + pad + 10
sheet = Image.new('RGBA', (colw, H), (58, 68, 102, 255))
dr = ImageDraw.Draw(sheet)
for f, im, x, y in placed:
    # checker behind transparent assets
    sheet.paste(im.resize((im.width * sc, im.height * sc), Image.NEAREST), (x, y + 10), im.resize((im.width * sc, im.height * sc), Image.NEAREST))
    dr.text((x, y), os.path.basename(f)[:34], fill=(234, 212, 170, 255))
sheet.save(D('_preview', 'lembar_semua_aset.png'))
print(len(files), 'files')
