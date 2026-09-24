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
 'moby-dick':  ('MOBY-DICK', 'HERMAN MELVILLE', (22, 54, 92), (236, 226, 204), 'waves'),
 'odyssey':    ('THE\nODYSSEY', 'HOMER', (176, 74, 44), (246, 229, 197), 'sun'),
 'pride':      ('Pride and\nPrejudice', 'JANE AUSTEN', (231, 214, 196), (94, 52, 70), 'frame'),
 'frankenstein': ('FRANKEN-\nSTEIN', 'MARY SHELLEY', (38, 44, 40), (170, 214, 120), 'bolt'),
 'dracula':    ('DRACULA', 'BRAM STOKER', (110, 18, 30), (240, 222, 210), 'moon'),
 'jane-eyre':  ('Jane Eyre', 'CHARLOTTE BRONTË', (58, 84, 72), (238, 228, 206), 'arch'),
 'gatsby':     ('THE GREAT\nGATSBY', 'F. SCOTT FITZGERALD', (16, 30, 58), (230, 190, 90), 'deco'),
 'little-women': ('Little\nWomen', 'LOUISA MAY ALCOTT', (240, 206, 196), (120, 58, 70), 'dots'),
 'emma':       ('Emma', 'JANE AUSTEN', (200, 222, 214), (40, 86, 80), 'dots'),
 'persuasion': ('Persuasion', 'JANE AUSTEN', (46, 62, 96), (232, 214, 170), 'waves'),
 'sense':      ('Sense and\nSensibility', 'JANE AUSTEN', (244, 228, 200), (150, 70, 40), 'arch'),
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
    elif kind == 'dots':
        for row in range(5):
            for col in range(6):
                d.ellipse((60 + col * 95, 520 + row * 70, 90 + col * 95, 550 + row * 70), fill=fg)

OUT.mkdir(parents=True, exist_ok=True)
for key, (title, author, bg, fg, kind) in BOOKS.items():
    im = Image.new('RGB', (W, H), bg)
    d = ImageDraw.Draw(im)
    motif(d, kind, fg, bg)
    size = 72 if len(title.replace('\n', '')) < 12 else 60
    f = ImageFont.truetype(SERIF_B, size)
    y = 150
    for line in title.split('\n'):
        w = d.textlength(line, font=f)
        d.text(((W - w) / 2, y), line, font=f, fill=fg)
        y += size * 1.15
    fa = ImageFont.truetype(SANS, 28)
    w = d.textlength(author, font=fa)
    d.text(((W - w) / 2, y + 30), author, font=fa, fill=fg)
    im.save(OUT / f'{key}.png')
