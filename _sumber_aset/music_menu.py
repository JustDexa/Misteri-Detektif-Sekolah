"""BGM menu utama v2 — komposisi tulis-tangan (bukan acak).
Nuansa: detektif misterius tapi ceria. D Dorian, 116 BPM, swing ringan.
Struktur: Intro (4 bar) - A (8) - B (8) - A' (8)  = 28 bar (~58 detik), bisa di-loop."""
import numpy as np
from audio import SR, osc, env, midi, write

BPM = 116
STEP = 60 / BPM / 4          # satu not 1/16
BAR = STEP * 16
SWING = 0.18                 # geser not 1/16 ganjil (swing)

R = None
D4, E4, F4, G4, A4, Bb4, B4 = 62, 64, 65, 67, 69, 70, 71
C5, Cs5, D5, E5, F5, G5, Gs5, A5, Bb5, B5 = 72, 73, 74, 76, 77, 79, 80, 81, 82, 83
C6, Cs6, D6, E6 = 84, 85, 86, 88

# akor per bar: (nama, nada akor)
CH = {
    'Dm': [50, 53, 57, 60], 'G': [43, 47, 50, 53], 'Bb': [46, 50, 53, 57], 'C': [48, 52, 55, 59],
    'A': [45, 49, 52, 55], 'Am': [45, 48, 52, 55], 'E': [40, 44, 47, 50],
}
PROG_A = ['Dm', 'G', 'Dm', 'G', 'Bb', 'C', 'Dm', 'A']
PROG_B = ['Bb', 'C', 'Am', 'Dm', 'Bb', 'C', 'E', 'A']
PROG_A2 = ['Dm', 'G', 'Dm', 'G', 'Bb', 'C', 'A', 'Dm']

MEL_A = [
    [(A4, 2), (D5, 2), (F5, 2), (A5, 4), (G5, 2), (F5, 2), (E5, 2)],
    [(D5, 4), (B4, 2), (D5, 2), (G5, 6), (R, 2)],
    [(A4, 2), (D5, 2), (F5, 2), (A5, 2), (C6, 4), (A5, 2), (F5, 2)],
    [(G5, 6), (F5, 2), (E5, 2), (D5, 2), (R, 4)],
    [(F5, 2), (D5, 2), (Bb4, 2), (D5, 2), (F5, 4), (G5, 2), (F5, 2)],
    [(E5, 2), (C5, 2), (G4, 2), (C5, 2), (E5, 4), (G5, 4)],
    [(A5, 4), (F5, 2), (D5, 2), (E5, 2), (F5, 2), (E5, 2), (D5, 2)],
    [(Cs5, 4), (E5, 2), (A4, 2), (Cs5, 4), (R, 4)],
]
MEL_B = [
    [(D6, 6), (C6, 2), (Bb5, 4), (A5, 4)],
    [(G5, 6), (A5, 2), (G5, 4), (E5, 4)],
    [(A5, 6), (C6, 2), (E6, 4), (C6, 4)],
    [(D6, 8), (A5, 4), (F5, 4)],
    [(Bb5, 4), (A5, 2), (G5, 2), (F5, 4), (D5, 4)],
    [(E5, 4), (G5, 2), (C6, 2), (E5, 4), (G5, 4)],
    [(Gs5, 4), (B5, 4), (D6, 4), (B5, 4)],
    [(Cs6, 8), (R, 4), (E5, 2), (A5, 2)],
]
MEL_A2 = MEL_A[:6] + [
    [(A5, 4), (G5, 2), (F5, 2), (E5, 4), (Cs5, 4)],
    [(D5, 8), (A4, 4), (D5, 4)],
]


def t16(i):
    """waktu (detik) not ke-i 1/16 dalam bar, dengan swing"""
    return i * STEP + (SWING * STEP if i % 2 == 1 else 0)


def compose():
    bars = 4 + 8 + 8 + 8
    mix = np.zeros(int(bars * BAR * SR) + SR)

    def put(sig, t):
        s = int(t * SR)
        e = min(len(mix), s + len(sig))
        mix[s:e] += sig[:e - s]

    def lead(n, t, dur, vol=0.26):
        nn = int(dur * SR)
        tt = np.arange(nn) / SR
        vib = 1 + 0.006 * np.sin(2 * np.pi * 5.5 * tt) * np.clip((tt - 0.12) * 6, 0, 1)
        ph = np.cumsum(midi(n) * vib) / SR % 1.0
        sig = np.where(ph < 0.25, 1.0, -1.0) * env(nn, .004, .07, .6, .04) * vol
        sig += np.where((ph * 1.003) % 1 < 0.5, 1.0, -1.0) * env(nn, .004, .07, .6, .04) * vol * 0.25
        put(sig, t)
        put(sig * 0.28, t + STEP * 3)          # gema (delay 3/16)

    def bass(n, t, dur, vol=0.34):
        nn = int(dur * SR)
        put(osc('tri', midi(n), nn) * env(nn, .002, .05, .75, .03) * vol, t)

    def arp(ch, t0, vol=0.09):
        notes = [ch[1] + 12, ch[2] + 12, ch[3] + 12, ch[2] + 12]
        for i in range(16):
            if i % 2 == 0:
                n = notes[(i // 2) % 4]
                nn = int(STEP * SR * 0.8)
                put(osc('pulse', midi(n), nn, .125) * env(nn, .001, .03, .3, .01) * vol, t0 + t16(i))

    def pad(ch, t0, vol=0.045):
        nn = int(BAR * SR)
        for n in ch[1:]:
            put(osc('sine', midi(n + 12), nn) * env(nn, .2, .4, .6, .4) * vol, t0)

    def kick(t, vol=0.55):
        nn = int(.13 * SR)
        f = np.linspace(140, 42, nn)
        put(np.sin(2 * np.pi * np.cumsum(f) / SR) * np.linspace(1, 0, nn) ** 2 * vol, t)

    def snare(t, vol=0.22):
        nn = int(.11 * SR)
        put(osc('noise', 7000, nn) * np.linspace(1, 0, nn) ** 2.5 * vol, t)

    def hat(t, vol=0.07, ln=.025):
        nn = int(ln * SR)
        put(osc('noise', 12000, nn) * np.linspace(1, 0, nn) * vol, t)

    def tick(t, hi=True, vol=0.16):  # bunyi jam / woodblock
        nn = int(.035 * SR)
        put(osc('sine', 1900 if hi else 1450, nn) * np.linspace(1, 0, nn) ** 3 * vol, t)

    def section(prog, mel, b0, drums=True, ticks=False, use_pad=False):
        for bi, cname in enumerate(prog):
            t0 = (b0 + bi) * BAR
            ch = CH[cname]
            root = ch[0]
            walk = [root, root + 7, root + 12, root + 7] if bi % 2 == 0 else [root, root + 3 if cname in ('Dm', 'Am') else root + 4, root + 7, root + 10]
            for q in range(4):
                bass(walk[q] - 12 if walk[q] > 55 else walk[q], t0 + t16(q * 4), STEP * 3.6)
            arp(ch, t0)
            if use_pad:
                pad(ch, t0)
            if drums:
                for i in range(16):
                    if i in (0, 8):
                        kick(t0 + t16(i))
                    if i in (4, 12):
                        snare(t0 + t16(i))
                    if i % 2 == 0:
                        hat(t0 + t16(i), 0.08 if i % 4 == 2 else 0.05)
                if bi % 4 == 3:
                    for i in (13, 14, 15):
                        snare(t0 + t16(i), 0.12)
            if ticks:
                for i in range(0, 16, 4):
                    tick(t0 + t16(i), i % 8 == 0)
            if mel is not None:
                pos = 0
                for n, d in mel[bi]:
                    if n is not None:
                        lead(n, t0 + t16(pos), STEP * d * 0.92)
                    pos += d

    # Intro: jam berdetak + bass + arpeggio, drum masuk di bar 3
    for bi in range(4):
        t0 = bi * BAR
        ch = CH['Dm' if bi % 2 == 0 else 'G']
        for q in range(4):
            bass([ch[0], ch[0] + 7, ch[0] + 12, ch[0] + 7][q], t0 + t16(q * 4), STEP * 3.6)
        for i in range(0, 16, 4):
            tick(t0 + t16(i), i % 8 == 0)
        if bi >= 1:
            arp(ch, t0, 0.07)
        if bi >= 2:
            for i in range(16):
                if i % 2 == 0:
                    hat(t0 + t16(i), 0.05)
                if i in (0, 8):
                    kick(t0 + t16(i), 0.4)
    # pickup ke bagian A
    for k, n in enumerate([D5, E5, F5, G5]):
        lead(n, 3 * BAR + t16(12 + k), STEP * 0.9, 0.18)
    section(PROG_A, MEL_A, 4, ticks=True)
    section(PROG_B, MEL_B, 12, use_pad=True)
    section(PROG_A2, MEL_A2, 20, ticks=True)
    mix = mix[:int(bars * BAR * SR)]
    # fade kecil di ujung agar loop halus
    f = int(0.05 * SR)
    mix[-f:] *= np.linspace(1, 0, f)
    mix /= max(1e-6, np.abs(mix).max()) * 1.05
    return mix


if __name__ == '__main__':
    import sys
    out = sys.argv[1] if len(sys.argv) > 1 else 'game/assets/audio/bgm_menu.wav'
    m = compose()
    write(out, m, .78)
    print(out, round(len(m) / SR, 1), 'detik')
