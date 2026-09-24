"""Couvertures de démonstration pour les captures d'écran.

Des classiques du domaine public, avec des couvertures inventées : aucune
édition réelle n'est reproduite. Écrit dans build/screenshots/covers/.

    python3 tool/screenshots/covers.py
"""
from PIL import Image, ImageDraw, ImageFont
import math
from pathlib import Path

SERIF_B = '/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf'
SANS = '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf'
W, H = 600, 900

BOOKS = {
 # Mis en avant, dans chaque langue.
 'knight-en':  ('THE KNIGHT\nAND THE MOTH', 'RACHEL GILLIG', (28, 30, 46), (214, 196, 148), 'moth'),
 'knight-fr':  ('LE CHEVALIER\nET LA PHALÈNE', 'RACHEL GILLIG', (28, 30, 46), (214, 196, 148), 'moth'),
 'prince-en':  ('THE LITTLE\nPRINCE', 'ANTOINE DE SAINT-EXUPÉRY', (22, 54, 92), (242, 214, 120), 'planet'),
 'prince-fr':  ('LE PETIT\nPRINCE', 'ANTOINE DE SAINT-EXUPÉRY', (22, 54, 92), (242, 214, 120), 'planet'),
 # Classiques anglais.
 'pride':      ('Pride and\nPrejudice', 'JANE AUSTEN', (231, 214, 196), (94, 52, 70), 'frame'),
 'frankenstein': ('FRANKEN-\nSTEIN', 'MARY SHELLEY', (38, 44, 40), (170, 214, 120), 'bolt'),
 'dracula':    ('DRACULA', 'BRAM STOKER', (110, 18, 30), (240, 222, 210), 'moon'),
 'jane-eyre':  ('Jane Eyre', 'CHARLOTTE BRONTË', (58, 84, 72), (238, 228, 206), 'arch'),
 'gatsby':     ('THE GREAT\nGATSBY', 'F. SCOTT FITZGERALD', (16, 30, 58), (230, 190, 90), 'deco'),
 'little-women': ('Little\nWomen', 'LOUISA MAY ALCOTT', (240, 206, 196), (120, 58, 70), 'dots'),
 'emma':       ('Emma', 'JANE AUSTEN', (200, 222, 214), (40, 86, 80), 'dots'),
 'persuasion': ('Persuasion', 'JANE AUSTEN', (46, 62, 96), (232, 214, 170), 'waves'),
 'sense':      ('Sense and\nSensibility', 'JANE AUSTEN', (244, 228, 200), (150, 70, 40), 'arch'),
 # Classiques français.
 'miserables': ('LES\nMISÉRABLES', 'VICTOR HUGO', (120, 28, 32), (240, 226, 206), 'bolt'),
 'monte-cristo': ('LE COMTE DE\nMONTE-CRISTO', 'ALEXANDRE DUMAS', (18, 40, 60), (226, 196, 120), 'waves'),
 'bovary':     ('Madame\nBovary', 'GUSTAVE FLAUBERT', (236, 214, 218), (112, 44, 70), 'frame'),
 'vingt-mille': ('VINGT MILLE\nLIEUES SOUS\nLES MERS', 'JULES VERNE', (14, 70, 86), (196, 232, 226), 'dots'),
 'mousquetaires': ('LES TROIS\nMOUSQUETAIRES', 'ALEXANDRE DUMAS', (150, 40, 30), (244, 214, 150), 'sun'),
 'notre-dame': ('NOTRE-DAME\nDE PARIS', 'VICTOR HUGO', (58, 52, 70), (226, 216, 196), 'arch'),
 'contemplations': ('Les\nContemplations', 'VICTOR HUGO', (226, 232, 216), (54, 84, 60), 'dots'),
 'quatrevingt': ('QUATRE-\nVINGT-TREIZE', 'VICTOR HUGO', (96, 24, 28), (236, 206, 160), 'deco'),
 'homme-rit':  ('L\'HOMME\nQUI RIT', 'VICTOR HUGO', (34, 34, 38), (220, 170, 90), 'moon'),
}

OUT = Path(__file__).resolve().parents[2] / 'build' / 'screenshots' / 'covers'

def motif(d, kind, fg, bg):
    if kind == 'waves':
        for i in range(7):
            y = 560 + i * 34
            pts = [(x, y + 14 * math.sin(x / 45 + i)) for x in range(0, W + 10, 10)]
            d.line(pts, fill=fg, width=5)
    elif kind == 'sun':
        d.ellipse((180, 470, 420, 710), fill=fg)
        for a in range(0, 360, 20):
            r = math.radians(a)
            d.line((300 + 140 * math.cos(r), 590 + 140 * math.sin(r), 300 + 200 * math.cos(r), 590 + 200 * math.sin(r)), fill=fg, width=6)
    elif kind == 'frame':
        d.rectangle((40, 40, W - 40, H - 40), outline=fg, width=4)
        d.rectangle((56, 56, W - 56, H - 56), outline=fg, width=2)
        d.ellipse((230, 560, 370, 700), outline=fg, width=4)
    elif kind == 'bolt':
        d.polygon([(330, 480), (240, 650), (300, 650), (260, 800), (380, 600), (315, 600), (360, 480)], fill=fg)
    elif kind == 'moon':
        d.ellipse((330, 420, 520, 610), fill=fg)
        d.ellipse((300, 400, 480, 580), fill=bg)
        for x in range(0, W, 70):
            d.polygon([(x, H), (x + 35, 700 - (x % 3) * 40), (x + 70, H)], fill=(60, 8, 16))
    elif kind == 'arch':
        d.rounded_rectangle((170, 470, 430, 820), radius=130, outline=fg, width=6)
        d.line((300, 470, 300, 820), fill=fg, width=3)
    elif kind == 'deco':
        for i in range(9):
            d.line((300, 560, i * 75, H), fill=fg, width=3)
        d.ellipse((250, 510, 350, 610), fill=fg)
    elif kind == 'moth':
        # Une épée pointe en bas, et une phalène posée dessus, ailes ouvertes.
        d.polygon([(292, 540), (308, 540), (300, 880)], fill=fg)
        d.rectangle((296, 450, 304, 540), fill=fg)
        d.rounded_rectangle((236, 522, 364, 536), radius=7, fill=fg)
        d.ellipse((288, 438, 312, 462), fill=fg)

        def wing(cx, cy, rx, ry, angle):
            a = math.radians(angle)
            pts = []
            for t in range(0, 360, 6):
                u = math.radians(t)
                x, y = rx * math.cos(u), ry * math.sin(u)
                pts.append((cx + x * math.cos(a) - y * math.sin(a),
                            cy + x * math.sin(a) + y * math.cos(a)))
            return pts

        for side in (-1, 1):
            d.polygon(wing(300 + side * 105, 610, 118, 62, side * -28), fill=fg)
            d.polygon(wing(300 + side * 72, 690, 72, 42, side * 32), fill=fg)
            # Un œil sur chaque grande aile.
            d.ellipse((300 + side * 118 - 18, 596, 300 + side * 118 + 18, 632),
                      fill=bg)
            # Antennes.
            d.line([(300, 600), (300 + side * 22, 560), (300 + side * 40, 548)],
                   fill=fg, width=4)
        d.ellipse((286, 590, 314, 730), fill=fg, outline=bg, width=4)
    elif kind == 'planet':
        # Une petite planète sous un ciel étoilé.
        d.ellipse((190, 620, 410, 840), fill=fg)
        for x, y in [(90, 480), (500, 520), (160, 560), (440, 440), (520, 700),
                     (70, 700), (360, 500)]:
            d.ellipse((x - 6, y - 6, x + 6, y + 6), fill=fg)
        d.line((300, 620, 300, 560), fill=fg, width=5)
        d.ellipse((288, 540, 312, 564), fill=fg)
    elif kind == 'dots':
        for row in range(5):
            for col in range(6):
                d.ellipse((60 + col * 95, 520 + row * 70, 90 + col * 95, 550 + row * 70), fill=fg)

OUT.mkdir(parents=True, exist_ok=True)
for key, (title, author, bg, fg, kind) in BOOKS.items():
    im = Image.new('RGB', (W, H), bg)
    d = ImageDraw.Draw(im)
    motif(d, kind, fg, bg)
    size = 72
    while True:
        f = ImageFont.truetype(SERIF_B, size)
        if max(d.textlength(line, font=f) for line in title.split('\n')) <= 520:
            break
        size -= 2
    y = 150
    for line in title.split('\n'):
        w = d.textlength(line, font=f)
        d.text(((W - w) / 2, y), line, font=f, fill=fg)
        y += size * 1.15
    fa = ImageFont.truetype(SANS, 28)
    w = d.textlength(author, font=fa)
    d.text(((W - w) / 2, y + 30), author, font=fa, fill=fg)
    im.save(OUT / f'{key}.png')
