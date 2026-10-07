"""Compose la musique de la vidéo : un morceau original, calculé note à note.

Rien n'est échantillonné ni emprunté : pas de droits à vérifier pour YouTube
ou le Play Store. Piano électrique doux, arpèges, basse et petite rythmique,
à 96 battements par minute : une mesure dure 2,5 s, douze mesures font la
vidéo. Les accords suivent les scènes : intro calme, rythmique pendant les
écrans, dernier accord qui résonne sur « Disponible sur Google Play ».

    python3 tool/screenshots/music.py [durée en secondes]

Écrit build/screenshots/video/music.wav (44,1 kHz, stéréo).
"""

import sys
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / 'build' / 'screenshots' / 'video' / 'music.wav'

RATE = 44100
BPM = 96
BEAT = 60 / BPM
BAR = 4 * BEAT

# Do majeur : Do7M – La m7 – Fa7M – Sol6, trois fois.
CHORDS = [
    (48, [60, 64, 67, 71]),  # Do7M
    (45, [57, 60, 64, 67]),  # La m7
    (41, [57, 60, 64, 65]),  # Fa7M
    (43, [59, 62, 64, 67]),  # Sol6
]


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


def tone(freq, length, partials, decay, attack=0.006, detune=0.0):
    """Une note : quelques harmoniques, attaque courte, extinction lente."""
    t = np.arange(int(length * RATE)) / RATE
    wave_ = np.zeros_like(t)
    for number, gain in partials:
        f = freq * number * (1 + detune)
        wave_ += gain * np.sin(2 * np.pi * f * t)
    envelope = np.minimum(1, t / attack) * np.exp(-t / decay)
    return wave_ * envelope


def place(track, sound, start, gain=1.0, pan=0.0):
    """Pose un son mono dans la piste stéréo, à `start` secondes."""
    i = int(start * RATE)
    end = min(len(track), i + len(sound))
    if end <= i:
        return
    left = np.cos((pan + 1) * np.pi / 4)
    right = np.sin((pan + 1) * np.pi / 4)
    track[i:end, 0] += sound[:end - i] * gain * left
    track[i:end, 1] += sound[:end - i] * gain * right


def comb(x, delay, feedback):
    """Filtre en peigne, calculé bloc par bloc (un bloc = un retard)."""
    y = np.copy(x)
    for start in range(delay, len(x), delay):
        end = min(len(x), start + delay)
        y[start:end] += feedback * y[start - delay:end - delay]
    return y


def allpass(x, delay, gain):
    y = np.zeros_like(x)
    padded = np.concatenate([np.zeros(delay), x])
    for start in range(0, len(x), delay):
        end = min(len(x), start + delay)
        past = y[start - delay:end - delay] if start >= delay else 0
        y[start:end] = (-gain * x[start:end] + padded[start:end] + gain * past)
    return y


def reverb(x):
    """Une petite salle (Schroeder) : quatre peignes, deux passe-tout."""
    wet = sum(comb(x, d, 0.78) for d in (1557, 1617, 1491, 1422)) / 4
    for d in (225, 556):
        wet = allpass(wet, d, 0.5)
    return wet


def compose(duration):
    rng = np.random.default_rng(7)
    track = np.zeros((int((duration + 1) * RATE), 2))
    # Le dernier accord tombe sur la fin (douze mesures pour 30 s) et résonne
    # sur ce qui reste.
    bars = int(duration // BAR)

    for bar in range(bars):
        start = bar * BAR
        bass, notes = CHORDS[bar % len(CHORDS)]
        last = bar == bars - 1
        intro = bar < 1
        full = 1 <= bar < bars - 1

        # Piano électrique : l'accord sur le premier temps, rappelé au
        # troisième, plus doucement. Le dernier résonne jusqu'au bout.
        ring = 5.0 if last else 2.2
        for k, note in enumerate(notes):
            voice = tone(hz(note), ring + 0.5,
                         [(1, 1.0), (2, 0.28), (3, 0.08), (4, 0.03)],
                         decay=1.6 if last else 1.1, detune=0.0015 * (k - 1.5))
            place(track, voice, start + 0.012 * k, 0.16, pan=-0.3 + 0.2 * k)
            if not last:
                place(track, voice[:int(1.4 * RATE)], start + 2 * BEAT,
                      0.08, pan=0.3 - 0.2 * k)

        # Basse ronde.
        bass_note = tone(hz(bass), BAR, [(1, 1.0), (2, 0.25)], decay=0.9,
                         attack=0.01)
        place(track, bass_note, start, 0.0 if intro else 0.22)
        if full:
            place(track, bass_note[:int(1.0 * RATE)], start + 2.5 * BEAT, 0.13)

        # Arpèges en croches, une octave au-dessus, de gauche à droite.
        if not intro and not last:
            pattern = [0, 1, 2, 3, 2, 1, 3, 2]
            for step, index in enumerate(pattern):
                note = notes[index] + 12
                pluck = tone(hz(note), 0.6, [(1, 1.0), (2, 0.15), (3, 0.05)],
                             decay=0.22, attack=0.003)
                place(track, pluck, start + step * BEAT / 2, 0.07,
                      pan=-0.5 if step % 2 == 0 else 0.5)

        # Rythmique discrète : grosse caisse sur 1 et 3, claquement léger sur
        # 2 et 4, charleston sur les contretemps.
        if full:
            for beat in range(4):
                at = start + beat * BEAT
                if beat in (0, 2):
                    t = np.arange(int(0.35 * RATE)) / RATE
                    sweep = 2 * np.pi * np.cumsum(45 + 80 * np.exp(-t / 0.04)) / RATE
                    kick = np.sin(sweep) * np.exp(-t / 0.12)
                    place(track, kick, at, 0.30)
                else:
                    snap = rng.standard_normal(int(0.12 * RATE))
                    snap = np.diff(snap, prepend=0) * np.exp(
                        -np.arange(len(snap)) / RATE / 0.03)
                    place(track, snap, at, 0.035)
                hat = np.diff(rng.standard_normal(int(0.05 * RATE)), prepend=0)
                hat *= np.exp(-np.arange(len(hat)) / RATE / 0.012)
                place(track, hat, at + BEAT / 2, 0.02, pan=0.35)

    # Un peu de salle, puis entrée et sortie en fondu.
    for channel in range(2):
        track[:, channel] += 0.35 * reverb(track[:, channel])
    track = track[:int(duration * RATE)]
    n = len(track)
    fade_in = np.minimum(1, np.arange(n) / (0.8 * RATE))
    fade_out = np.minimum(1, (n - np.arange(n)) / (2.0 * RATE))
    track *= (fade_in * fade_out)[:, None]
    track *= 0.89 / np.max(np.abs(track))  # environ −1 dB au plus fort
    return track


def write(track, path):
    path.parent.mkdir(parents=True, exist_ok=True)
    data = (np.clip(track, -1, 1) * 32767).astype('<i2')
    with wave.open(str(path), 'wb') as out:
        out.setnchannels(2)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(data.tobytes())


if __name__ == '__main__':
    length = float(sys.argv[1]) if len(sys.argv) > 1 else 30.4
    write(compose(length), OUT)
    print(f'{OUT} ({length:.1f} s)')
