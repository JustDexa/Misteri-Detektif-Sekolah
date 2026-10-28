"""Chiptune BGM + SFX synthesizer -> 16-bit mono WAV (22050 Hz)."""
import numpy as np, wave, random, os

SR = 22050
NOTE = {'C': 0, 'C#': 1, 'D': 2, 'D#': 3, 'E': 4, 'F': 5, 'F#': 6, 'G': 7, 'G#': 8, 'A': 9, 'A#': 10, 'B': 11}


def midi(n):
    return 440.0 * 2 ** ((n - 69) / 12)


def osc(kind, f, n, duty=.5, t0=0):
    t = (np.arange(n) + t0) / SR
    if kind == 'pulse':
        ph = (t * f) % 1.0
        return np.where(ph < duty, 1.0, -1.0)
    if kind == 'tri':
        ph = (t * f) % 1.0
        return 4 * np.abs(ph - .5) - 1
    if kind == 'sine':
        return np.sin(2 * np.pi * f * t)
    if kind == 'noise':
        r = np.random.RandomState(int(f) % 9999)
        # sample-and-hold noise for chip feel
        step = max(1, int(SR / max(f, 1)))
        v = r.uniform(-1, 1, n // step + 2)
        return np.repeat(v, step)[:n]


def env(n, a=.005, d=.08, s=.6, r=.05):
    e = np.ones(n) * s
    A, D, R = int(a * SR), int(d * SR), int(r * SR)
    A = min(A, n); e[:A] = np.linspace(0, 1, A) if A else e[:A]
    D2 = min(D, n - A)
    if D2 > 0: e[A:A + D2] = np.linspace(1, s, D2)
    R2 = min(R, n)
    if R2 > 0: e[n - R2:] *= np.linspace(1, 0, R2)
    return e


def write(path, x, vol=.9):
    x = np.clip(x, -1, 1)
    x = (x * vol * 32767).astype(np.int16)
    with wave.open(path, 'wb') as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR); w.writeframes(x.tobytes())


# ================================================================ SONG GENERATOR
SCALES = {'major': [0, 2, 4, 5, 7, 9, 11], 'minor': [0, 2, 3, 5, 7, 8, 10], 'dorian': [0, 2, 3, 5, 7, 9, 10],
          'penta': [0, 2, 4, 7, 9], 'pelog': [0, 1, 3, 7, 8]}


def chord_notes(root, quality):
    return [root, root + (4 if quality == 'M' else 3), root + 7]


def song(bpm, key, prog, scale='major', seed=1, lead='pulse', duty=.25, drums='pop', bars_rep=2,
         lead_oct=72, swing=0.0, arp=True, bass='walk', vol=(0.28, 0.32, 0.16, 0.12), density=.7):
    rnd = random.Random(seed)
    spb = 60 / bpm
    step = spb / 4  # 16th
    nbars = len(prog) * bars_rep
    total = int(nbars * 16 * step * SR)
    mix = np.zeros(total + SR)
    k = NOTE[key]
    sc = SCALES[scale]

    def put(sig, start):
        s = int(start * SR)
        mix[s:s + len(sig)] += sig[:max(0, len(mix) - s)]

    # motif: rhythm (16 steps x 2 bars) + contour
    def make_motif():
        rhythm = []
        for i in range(32):
            on = rnd.random() < (density if i % 2 == 0 else density * .35)
            if i % 8 == 0: on = True
            rhythm.append(on)
        contour = [rnd.choice([-2, -1, -1, 0, 1, 1, 2, 3, -3]) for _ in range(32)]
        return rhythm, contour
    motifA, motifB = make_motif(), make_motif()
    sections = ['A', 'A', 'B', 'A']
    bar = 0
    deg = 2
    for rep in range(bars_rep):
        for pi in range(0, len(prog), 2):
            sec = sections[(pi // 2) % 4]
            rhythm, contour = motifA if sec == 'A' else motifB
            for half in range(2):
                ci = pi + half
                if ci >= len(prog): break
                root_name, q = prog[ci]
                root = k + NOTE[root_name] if root_name in NOTE else k
                ch = chord_notes(48 + (root % 12), q)
                t_bar = (rep * len(prog) + ci) * 16 * step
                # bass
                for b in range(4):
                    if bass == 'walk':
                        n = ch[[0, 2, 1, 2][b]] - 12
                    elif bass == 'root8':
                        n = ch[0] - 12
                    else:
                        n = ch[0] - 12 if b % 2 == 0 else ch[2] - 12
                    for sub in ((0, .9),) if bass != 'root8' else ((0, .45), (.5, .45)):
                        dur = spb * sub[1]
                        nn = int(dur * SR)
                        sig = osc('tri', midi(n), nn) * env(nn, .002, .05, .8, .03) * vol[1]
                        put(sig, t_bar + b * spb + sub[0] * spb)
                # arpeggio / chords
                if arp:
                    for s16 in range(16):
                        if s16 % 2 == 0:
                            n = ch[(s16 // 2) % 3] + 12
                            nn = int(step * SR * .9)
                            sig = osc('pulse', midi(n), nn, .125) * env(nn, .001, .03, .3, .01) * vol[2]
                            put(sig, t_bar + s16 * step)
                else:
                    nn = int(16 * step * SR * .95)
                    for n in ch:
                        sig = osc('sine', midi(n + 12), nn) * env(nn, .05, .3, .5, .3) * vol[2] * .7
                        put(sig, t_bar)
                # lead
                for s16 in range(16):
                    idx = half * 16 + s16
                    if not rhythm[idx]: continue
                    deg = max(0, min(len(sc) * 2 - 1, deg + contour[idx]))
                    n = lead_oct - 12 + k % 12 + sc[deg % len(sc)] + 12 * (deg // len(sc))
                    # snap strong beats to chord tones
                    if s16 % 4 == 0:
                        cands = [c + 12 * o for c in ch for o in (1, 2)]
                        n = min(cands, key=lambda c: abs(c - n))
                    ln = 1
                    while idx + ln < 32 and not rhythm[idx + ln] and ln < 4: ln += 1
                    dur = step * ln * .92
                    nn = int(dur * SR)
                    sw = swing * step if s16 % 2 == 1 else 0
                    sig = osc(lead, midi(n), nn, duty) * env(nn, .004, .06, .55, .03) * vol[0]
                    # vibrato-ish second voice detune
                    sig += osc(lead, midi(n) * 1.004, nn, duty) * env(nn, .004, .06, .55, .03) * vol[0] * .35
                    put(sig, t_bar + s16 * step + sw)
                # drums
                for s16 in range(16):
                    t = t_bar + s16 * step
                    if drums == 'none': continue
                    kick = s16 in (0, 8) if drums != 'soft' else s16 == 0
                    snare = s16 in (4, 12) and drums in ('pop', 'march')
                    hat = s16 % 2 == 0 if drums in ('pop', 'soft') else s16 % 4 == 2
                    if drums == 'march': kick = s16 in (0, 6, 8)
                    if kick:
                        nn = int(.12 * SR)
                        f = np.linspace(150, 40, nn)
                        sig = np.sin(2 * np.pi * np.cumsum(f) / SR) * np.linspace(1, 0, nn) ** 2 * vol[3] * 2.2
                        put(sig, t)
                    if snare:
                        nn = int(.1 * SR)
                        sig = osc('noise', 6000, nn) * np.linspace(1, 0, nn) ** 2 * vol[3] * 1.3
                        put(sig, t)
                    if hat:
                        nn = int(.03 * SR)
                        sig = osc('noise', 11000, nn) * np.linspace(1, 0, nn) * vol[3] * .5
                        put(sig, t)
    mix = mix[:total]
    mix /= max(1e-6, np.abs(mix).max()) * 1.05
    return mix


SONGS = {
    'bgm_menu': dict(bpm=112, key='C', prog=[('C', 'M'), ('A', 'm'), ('F', 'M'), ('G', 'M')] * 2, seed=11,
                     duty=.25, drums='pop', bars_rep=2),
    'bgm_sekolah': dict(bpm=120, key='F', prog=[('F', 'M'), ('D', 'm'), ('A#', 'M'), ('C', 'M'), ('F', 'M'), ('A', 'm'), ('A#', 'M'), ('C', 'M')],
                        seed=23, duty=.5, drums='pop', bars_rep=2, scale='major'),
    'bgm_taman': dict(bpm=96, key='G', prog=[('G', 'M'), ('E', 'm'), ('C', 'M'), ('D', 'M')] * 2, seed=37,
                      duty=.125, drums='soft', bars_rep=2, scale='penta', density=.55),
    'bgm_pasar': dict(bpm=126, key='D', prog=[('D', 'm'), ('D', 'm'), ('A#', 'M'), ('A', 'M')] * 2, seed=41,
                      duty=.25, drums='march', bars_rep=2, scale='pelog', bass='root8', density=.75),
    'bgm_museum': dict(bpm=80, key='A', prog=[('A', 'm'), ('F', 'M'), ('C', 'M'), ('E', 'm')] * 2, seed=53,
                       lead='tri', drums='soft', bars_rep=2, scale='minor', arp=False, density=.45),
    'bgm_tkp': dict(bpm=100, key='E', prog=[('E', 'm'), ('C', 'M'), ('E', 'm'), ('B', 'm')] * 2, seed=61,
                    duty=.125, drums='soft', bars_rep=2, scale='dorian', bass='pump', density=.4),
    'bgm_ending': dict(bpm=108, key='D', prog=[('D', 'M'), ('A', 'M'), ('B', 'm'), ('G', 'M')] * 2, seed=71,
                       duty=.5, drums='pop', bars_rep=2, scale='major'),
}


# ================================================================ SFX
def tone_seq(notes, dur=.07, kind='pulse', duty=.5, gap=0.0, vol=.6):
    out = []
    for n in notes:
        nn = int(dur * SR)
        out.append(osc(kind, midi(n), nn, duty) * env(nn, .002, .02, .7, .02) * vol)
        if gap: out.append(np.zeros(int(gap * SR)))
    return np.concatenate(out)


def sweep(f0, f1, dur, kind='pulse', duty=.5, vol=.5):
    nn = int(dur * SR)
    f = np.geomspace(f0, f1, nn)
    ph = np.cumsum(f) / SR % 1
    if kind == 'pulse': s = np.where(ph < duty, 1., -1.)
    elif kind == 'tri': s = 4 * np.abs(ph - .5) - 1
    else: s = np.sin(2 * np.pi * ph)
    return s * env(nn, .002, .05, .7, .05) * vol


def noise_burst(dur, f=8000, vol=.5, curve=2):
    nn = int(dur * SR)
    return osc('noise', f, nn) * np.linspace(1, 0, nn) ** curve * vol


SFX = {
    'sfx_klik': lambda: tone_seq([84], .04, duty=.25),
    'sfx_hover': lambda: tone_seq([91], .025, duty=.125, vol=.35),
    'sfx_ketik': lambda: tone_seq([79], .018, duty=.25, vol=.25),
    'sfx_lanjut': lambda: tone_seq([76, 83], .035, duty=.25, vol=.4),
    'sfx_interaksi': lambda: tone_seq([88, 93], .05, 'tri', vol=.6),
    'sfx_ambil': lambda: tone_seq([72, 76, 79, 84], .06, duty=.25),
    'sfx_bukti': lambda: np.concatenate([noise_burst(.06, 3000, .3), tone_seq([79, 84, 88, 91], .055, duty=.5, vol=.5)]),
    'sfx_buku': lambda: noise_burst(.12, 2500, .45, 1.2) + np.pad(noise_burst(.08, 4000, .25), (int(.04 * SR), 0))[:int(.12 * SR)],
    'sfx_langkah': lambda: noise_burst(.035, 1800, .25, 3),
    'sfx_pintu': lambda: np.concatenate([sweep(200, 120, .08, 'tri', vol=.6), noise_burst(.06, 900, .4)]),
    'sfx_terkunci': lambda: tone_seq([52, 52], .05, 'pulse', .5, .03, .45),
    'sfx_tkp': lambda: sweep(300, 1400, .25, 'sine', vol=.4) + noise_burst(.25, 5000, .12, 1),
    'sfx_grid_on': lambda: tone_seq([72, 79], .05, duty=.125),
    'sfx_grid_off': lambda: tone_seq([79, 72], .05, duty=.125),
    'sfx_pengecoh': lambda: tone_seq([67], .05, 'tri', vol=.5),
    'sfx_sektor': lambda: tone_seq([76], .04, 'tri', vol=.45),
    'sfx_level_selesai': lambda: tone_seq([72, 76, 79, 84, 79, 84, 88], .09, duty=.25),
    'sfx_poster': lambda: tone_seq([67, 71, 74, 79, 83, 86], .07, 'tri', vol=.7),
    'sfx_stempel': lambda: np.concatenate([np.sin(2 * np.pi * np.cumsum(np.linspace(180, 50, int(.15 * SR))) / SR) * np.linspace(1, 0, int(.15 * SR)) * .9]),
    'sfx_rapor': lambda: sweep(300, 900, .5, 'pulse', .25, .35),
    'sfx_bel': lambda: tone_seq([84, 79, 84, 79], .15, 'sine', vol=.6),
}


def build(folder):
    os.makedirs(folder, exist_ok=True)
    for name, spec in SONGS.items():
        write(f'{folder}/{name}.wav', song(**spec), .75)
    for name, fn in SFX.items():
        write(f'{folder}/{name}.wav', fn(), .8)


if __name__ == '__main__':
    import time
    t = time.time()
    build('build/audio')
    print('done', time.time() - t)
