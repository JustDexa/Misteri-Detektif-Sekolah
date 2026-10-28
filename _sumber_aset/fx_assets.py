"""Aset efek visual (partikel, emote, burung) + shader transisi + SFX tambahan."""
import os
import numpy as np
from pix import *
import audio


def build(A):
    d = os.path.join(A, 'fx')
    os.makedirs(d, exist_ok=True)
    # partikel putih (diwarnai lewat CPUParticles2D)
    c = Canvas(3, 2, P['white']); c.save(f'{d}/konfeti.png')
    c = Canvas(2, 2, P['white']); c.save(f'{d}/debu.png')
    c = Canvas(2, 3); c.rect(0, 0, 2, 3, P['cyan']); c.px(0, 0, P['white']); c.save(f'{d}/air.png')
    c = Canvas(7, 7)
    for i in range(7):
        c.px(3, i, P['white']); c.px(i, 3, P['white'])
    c.px(2, 2, P['yellow']); c.px(4, 4, P['yellow']); c.px(2, 4, P['yellow']); c.px(4, 2, P['yellow'])
    c.save(f'{d}/kilau.png')
    c = Canvas(6, 5)
    c.rect(1, 1, 4, 3, P['green']); c.px(0, 2, P['green_m']); c.px(5, 2, P['green_m'])
    c.hline(1, 4, 3, P['green_m']); c.px(2, 0, P['green']); c.px(3, 4, P['green_d'])
    c.save(f'{d}/daun.png')
    c = Canvas(6, 6); c.ellipse(3, 3, 2, 2, P['white']); c.px(1, 1, P['grey_l'])
    c.save(f'{d}/asap.png')
    # burung terbang 2 frame (8x6 per frame)
    b = Canvas(16, 6)
    for f, rows in enumerate([["K......K", ".K....K.", "..KKKK..", "...KK..."],
                              ["........", "........", "KKKKKKKK", ".K.KK.K."]]):
        for y, r in enumerate(rows):
            for x, ch in enumerate(r):
                if ch == 'K':
                    b.px(f * 8 + x, y + 1, P['navy'])
    b.save(f'{d}/burung.png')
    # emote: tanda seru & tanya (gelembung 11x13)
    for name, ch, col in [('seru', '!', 'red'), ('tanya', '?', 'blue_d'), ('senang', '+', 'green_m')]:
        e = Canvas(11, 13)
        e.rect(1, 0, 9, 10, P['black']); e.rect(0, 1, 11, 8, P['black'])
        e.rect(1, 1, 9, 8, P['white'])
        e.rect(4, 10, 3, 1, P['black']); e.px(5, 11, P['black']); e.px(5, 10, P['white'])
        if ch == '+':  # hati kecil
            for x, y in [(3, 3), (4, 3), (6, 3), (7, 3), (2, 4), (3, 4), (4, 4), (5, 4), (6, 4), (7, 4), (8, 4),
                         (3, 5), (4, 5), (5, 5), (6, 5), (7, 5), (4, 6), (5, 6), (6, 6), (5, 7)]:
                e.px(x, y, P['red'])
        else:
            e.mask_fill(GLYPH[ch], 5 - GLYPH[ch].shape[1] // 2, 1, P[col])
        e.save(f'{d}/emote_{name}.png')
    # shader transisi "lensa detektif"
    open(f'{d}/transisi.gdshader', 'w').write('''shader_type canvas_item;
// Transisi lensa detektif: lingkaran pixel bergaris emas yang menutup (progress 0 -> 1) lalu membuka.
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform vec2 center = vec2(160.0, 90.0);
uniform vec4 fill_color : source_color = vec4(0.094, 0.078, 0.145, 1.0);
uniform vec4 ring_color : source_color = vec4(0.996, 0.682, 0.204, 1.0);
uniform vec4 ring_dark : source_color = vec4(0.969, 0.463, 0.133, 1.0);

void fragment() {
	vec2 p = floor(UV * vec2(320.0, 180.0) / 2.0) * 2.0 + 1.0;
	float r = (1.0 - progress) * 200.0;
	float d = distance(p, center);
	if (d < r - 6.0) {
		COLOR = vec4(0.0);
	} else if (d < r - 4.0) {
		COLOR = vec4(0.094, 0.078, 0.145, 1.0);
	} else if (d < r - 2.0) {
		COLOR = ring_color;
	} else if (d < r) {
		COLOR = ring_dark;
	} else {
		COLOR = fill_color;
	}
}
''')
    # SFX tambahan
    ad = os.path.join(A, 'audio')
    sr = audio.SR
    n = int(.42 * sr)
    t = np.linspace(0, 1, n)
    noise = audio.osc('noise', 9000, n)
    whoosh = noise * np.sin(np.pi * t) ** 2 * 0.5 + audio.sweep(220, 660, .42, 'sine', vol=.18)
    audio.write(f'{ad}/sfx_transisi.wav', whoosh, .7)
    audio.write(f'{ad}/sfx_pop.wav', audio.sweep(500, 1300, .07, 'tri', vol=.6), .7)
    conf = np.concatenate([audio.noise_burst(.05, 6000, .5), audio.tone_seq([84, 88, 91, 96], .05, duty=.25, vol=.5)])
    audio.write(f'{ad}/sfx_konfeti.wav', conf, .7)
    audio.write(f'{ad}/sfx_hop.wav', audio.sweep(300, 600, .06, 'pulse', .25, .4), .6)
    print('fx ok')


if __name__ == '__main__':
    build('game/assets')
