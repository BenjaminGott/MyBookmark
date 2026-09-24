"""Compose les visuels « façon Play Store » à partir des captures brutes.

Une seule grande fresque (fond vert, ruban jaune de marque-page qui court d'un
bout à l'autre) est dessinée, les téléphones y sont posés, puis elle est
découpée en panneaux 9:16 : mis côte à côte, ils se prolongent l'un l'autre.

    python3 tool/screenshots/compose.py <dossier de sortie> [--lang en]

Écrit panel-1.webp … panel-4.webp (720 × 1280) dans le dossier de sortie, et
la fresque entière en PNG dans build/screenshots/.
"""

import math
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
RAW = ROOT / 'build' / 'screenshots' / 'raw'

GREEN = (19, 84, 80)
GREEN_DARK = (11, 58, 55)
GREEN_LIGHT = (29, 107, 102)
YELLOW = (242, 192, 79)
PAPER = (244, 246, 242)
INK = (23, 34, 31)

PANEL_W, PANEL_H = 1080, 1920

SCREENS = ['1-library', '2-book', '3-search', '4-share']

CAPTIONS = {
    'en': [
        'Your whole library,\non three shelves',
        'Track every page\nyou read',
        'Find any book\nin seconds',
        'Share your progress\nin style',
    ],
    'fr': [
        'Toute votre\nbibliothèque',
        'Suivez chaque\npage lue',
        'Trouvez un livre\nen un instant',
        'Partagez votre\nprogression',
    ],
}


def material_font(name):
    """Une police Roboto du SDK Flutter."""
    import shutil
    flutter = shutil.which('flutter')
    candidates = []
    if flutter:
        candidates.append(Path(flutter).resolve().parent / 'cache')
    candidates += list(Path('/').glob('tmp/**/flutter/bin/cache'))
    for cache in candidates:
        path = cache / 'artifacts' / 'material_fonts' / name
        if path.exists():
            return str(path)
    return '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'


def background(width, height):
    """Le fond continu : dégradé vert, halos, et le ruban de marque-page."""
    img = Image.new('RGB', (width, height), GREEN)
    draw = ImageDraw.Draw(img)

    # Dégradé vertical, plus sombre en bas.
    for y in range(height):
        t = y / height
        color = tuple(
            round(GREEN[i] * (1 - t) + GREEN_DARK[i] * t) for i in range(3)
        )
        draw.line((0, y, width, y), fill=color)

    # Halos clairs, posés à cheval sur les jonctions des panneaux.
    halos = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halos)
    for cx, cy, r in [
        (PANEL_W * 1.0, 520, 420),
        (PANEL_W * 2.05, 1500, 520),
        (PANEL_W * 3.0, 380, 360),
        (PANEL_W * 0.15, 1650, 380),
        (PANEL_W * 3.9, 1700, 420),
    ]:
        hd.ellipse((cx - r, cy - r, cx + r, cy + r), fill=GREEN_LIGHT + (150,))
    img.paste(halos.filter(ImageFilter.GaussianBlur(90)), (0, 0), halos.filter(
        ImageFilter.GaussianBlur(90)))

    # Le ruban : une bande jaune ondulée qui traverse toute la fresque, avec
    # son bout en queue d'aronde, comme le signet d'un livre.
    ribbon = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ribbon)
    thickness = 120
    top, bottom = [], []
    for x in range(-40, width - 160, 8):
        y = 1180 + 330 * math.sin(x / width * math.tau * 1.5 + 0.6)
        top.append((x, y - thickness / 2))
        bottom.append((x, y + thickness / 2))
    end_x = width - 160
    end_y = 1180 + 330 * math.sin(end_x / width * math.tau * 1.5 + 0.6)
    tail = [
        (end_x + 150, end_y - thickness / 2),
        (end_x + 70, end_y),
        (end_x + 150, end_y + thickness / 2),
    ]
    rd.polygon(top + tail + bottom[::-1], fill=YELLOW + (255,))
    # Un filet plus clair au milieu, pour le relief du tissu.
    mid = [((a[0] + b[0]) / 2, (a[1] + b[1]) / 2) for a, b in zip(top, bottom)]
    rd.line(mid, fill=(248, 214, 130, 255), width=10)
    img.paste(ribbon, (0, 0), ribbon)
    return img


def status_bar(screen, scale):
    """Heure et icônes sur la bande laissée libre en haut de la capture."""
    draw = ImageDraw.Draw(screen)
    h = round(24 * scale)
    font = ImageFont.truetype(material_font('Roboto-Medium.ttf'), round(14 * scale))
    draw.text((round(20 * scale), h / 2), '9:41', font=font, fill=INK, anchor='lm')
    right = screen.width - round(20 * scale)
    # Batterie.
    bw, bh = round(22 * scale), round(11 * scale)
    by = h / 2 - bh / 2
    draw.rounded_rectangle((right - bw, by, right, by + bh), radius=3, outline=INK,
                           width=max(2, round(scale)))
    draw.rectangle((right - bw + 4, by + 4, right - 8, by + bh - 4), fill=INK)
    # Réseau.
    x = right - bw - round(12 * scale)
    for i in range(4):
        bar_h = round((4 + i * 3) * scale)
        draw.rectangle((x - (3 - i) * round(5 * scale) - round(3 * scale), h / 2 + bh / 2 - bar_h,
                        x - (3 - i) * round(5 * scale), h / 2 + bh / 2), fill=INK)


def phone(screenshot, width):
    """La capture dans un téléphone aux bords arrondis, avec son ombre."""
    bezel = round(width * 0.028)
    screen_w = width - 2 * bezel
    scale = screen_w / screenshot.width
    screen = screenshot.convert('RGB').resize(
        (screen_w, round(screenshot.height * scale)), Image.LANCZOS)
    status_bar(screen, screen_w / 360)

    body_h = screen.height + 2 * bezel
    radius = round(width * 0.12)
    body = Image.new('RGBA', (width, body_h), (0, 0, 0, 0))
    bd = ImageDraw.Draw(body)
    bd.rounded_rectangle((0, 0, width - 1, body_h - 1), radius=radius, fill=(14, 22, 20, 255))
    bd.rounded_rectangle((3, 3, width - 4, body_h - 4), radius=radius - 3,
                         outline=(60, 72, 68, 255), width=3)

    mask = Image.new('L', screen.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, screen.width - 1, screen.height - 1), radius=radius - bezel, fill=255)
    body.paste(screen, (bezel, bezel), mask)

    # Caméra en poinçon.
    cx, cy, cr = width / 2, bezel + round(12 * screen_w / 360), round(5 * screen_w / 360)
    bd.ellipse((cx - cr, cy - cr, cx + cr, cy + cr), fill=(8, 12, 11, 255))
    return body


def compose(out_dir, lang):
    count = len(SCREENS)
    fresco = background(PANEL_W * count, PANEL_H).convert('RGBA')
    title_font = ImageFont.truetype(material_font('Roboto-Bold.ttf'), 86)

    phone_w = 760
    for index, (name, caption) in enumerate(zip(SCREENS, CAPTIONS[lang])):
        left = index * PANEL_W
        device = phone(Image.open(RAW / f'{lang}-{name}.png'), phone_w)
        x = left + (PANEL_W - phone_w) // 2
        y = 520

        shadow = Image.new('RGBA', fresco.size, (0, 0, 0, 0))
        ImageDraw.Draw(shadow).rounded_rectangle(
            (x + 20, y + 50, x + phone_w - 20, y + device.height + 40),
            radius=90, fill=(0, 0, 0, 120))
        fresco.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(40)))
        fresco.alpha_composite(device, (x, y))

        draw = ImageDraw.Draw(fresco)
        draw.multiline_text(
            (left + PANEL_W / 2, 250), caption, font=title_font,
            fill=(255, 255, 255), anchor='mm', align='center', spacing=18)

    fresco = fresco.convert('RGB')
    build = ROOT / 'build' / 'screenshots'
    fresco.save(build / f'fresco-{lang}.png')

    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    for index in range(count):
        panel = fresco.crop((index * PANEL_W, 0, (index + 1) * PANEL_W, PANEL_H))
        panel.resize((720, 1280), Image.LANCZOS).save(
            out / f'panel-{index + 1}.webp', quality=86, method=6)


if __name__ == '__main__':
    args = sys.argv[1:]
    language = 'en'
    if '--lang' in args:
        i = args.index('--lang')
        language = args[i + 1]
        del args[i:i + 2]
    compose(args[0] if args else ROOT / 'build' / 'screenshots' / 'panels', language)
