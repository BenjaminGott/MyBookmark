"""Compose les visuels « façon Play Store » à partir des captures brutes.

Une seule grande fresque (fond vert, ruban jaune de marque-page qui court d'un
bout à l'autre) est dessinée, les téléphones y sont posés, puis elle est
découpée en panneaux 9:16 : mis côte à côte, ils se prolongent l'un l'autre.

    python3 tool/screenshots/compose.py <dossier de sortie> [--lang en] [--store]

Écrit panel-1.webp … panel-4.webp (720 × 1280, les quatre premiers écrans) dans
le dossier de sortie, et
la fresque entière en PNG dans build/screenshots/. Avec --store, écrit plutôt
les fichiers de la fiche Play Store : screenshot-1.png … (1080 × 1920) et
feature-graphic.png (1024 × 500), sans transparence comme Google l'exige.
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

SCREENS = ['1-library', '2-book', '3-search', '4-share', '5-story']

# Le site n'en montre que quatre ; la fiche Play Store a aussi la story.
SITE_SCREENS = 4

CAPTIONS = {
    'en': [
        'Your whole library,\non three shelves',
        'Track every page\nyou read',
        'Find any book\nin seconds',
        'Share your progress\nin style',
        'Post it straight to\nyour Instagram story',
    ],
    'fr': [
        'Toute votre\nbibliothèque',
        'Suivez chaque\npage lue',
        'Trouvez un livre\nen un instant',
        'Partagez votre\nprogression',
        'Publiez-la direct\nen story Instagram',
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


def status_bar(screen, scale, color=INK):
    """Heure et icônes sur la bande laissée libre en haut de la capture."""
    draw = ImageDraw.Draw(screen)
    h = round(24 * scale)
    font = ImageFont.truetype(material_font('Roboto-Medium.ttf'), round(14 * scale))
    draw.text((round(20 * scale), h / 2), '9:41', font=font, fill=color, anchor='lm')
    right = screen.width - round(20 * scale)
    # Batterie.
    bw, bh = round(22 * scale), round(11 * scale)
    by = h / 2 - bh / 2
    draw.rounded_rectangle((right - bw, by, right, by + bh), radius=3, outline=color,
                           width=max(2, round(scale)))
    draw.rectangle((right - bw + 4, by + 4, right - 8, by + bh - 4), fill=color)
    # Réseau.
    x = right - bw - round(12 * scale)
    for i in range(4):
        bar_h = round((4 + i * 3) * scale)
        draw.rectangle((x - (3 - i) * round(5 * scale) - round(3 * scale), h / 2 + bh / 2 - bar_h,
                        x - (3 - i) * round(5 * scale), h / 2 + bh / 2), fill=color)


def phone(screenshot, width, light_status=False):
    """La capture dans un téléphone aux bords arrondis, avec son ombre."""
    bezel = round(width * 0.028)
    screen_w = width - 2 * bezel
    scale = screen_w / screenshot.width
    screen = screenshot.convert('RGB').resize(
        (screen_w, round(screenshot.height * scale)), Image.LANCZOS)
    status_bar(screen, screen_w / 360,
               (255, 255, 255) if light_status else INK)

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


STORY_TEXT = {
    'en': ('Your story', 'now', 'Send message'),
    'fr': ('Votre story', "à l'instant", 'Envoyer un message'),
}


def story_screen(lang, pop=1.0):
    """Une story telle qu'Instagram la montre après « Story » dans l'app.

    Le fond reprend les deux couleurs que l'app transmet (haut et bas de la
    carte), la carte est posée en sticker. L'habillage (barres de progression,
    avatar, champ de réponse) est générique, sans logo. `pop` fait apparaître
    le sticker (0 : absent, 1 : en place), pour la vidéo.
    """
    import json
    colors = json.loads((RAW / f'{lang}-6-card.json').read_text())
    top = tuple(int(colors['top'][i:i + 2], 16) for i in (1, 3, 5))
    bottom = tuple(int(colors['bottom'][i:i + 2], 16) for i in (1, 3, 5))
    w, h = 1080, 2340
    img = Image.new('RGB', (w, h))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        draw.line((0, y, w, y), fill=tuple(
            round(top[i] * (1 - t) + bottom[i] * t) for i in range(3)))
    img = img.convert('RGBA')
    over = Image.new('RGBA', (w, h), (0, 0, 0, 0))
    od = ImageDraw.Draw(over)

    # Barres de progression : une story vue, celle-ci en cours, une à venir.
    margin, gap, y0 = 24, 12, 96
    seg = (w - 2 * margin - 2 * gap) / 3
    for i, fill in enumerate((1.0, 0.45, 0.0)):
        x0 = margin + i * (seg + gap)
        od.rounded_rectangle((x0, y0, x0 + seg, y0 + 8), radius=4,
                             fill=(255, 255, 255, 90))
        if fill:
            od.rounded_rectangle((x0, y0, x0 + seg * fill, y0 + 8), radius=4,
                                 fill=(255, 255, 255, 255))

    # Avatar (l'icône de l'app) et nom.
    name, when, reply = STORY_TEXT[lang]
    icon = Image.open(ROOT / 'branding' / 'play-store-icon-512.png').convert('RGBA')
    icon = icon.resize((104, 104), Image.LANCZOS)
    mask = Image.new('L', (104, 104), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, 103, 103), fill=255)
    od.ellipse((34, 134, 34 + 116, 134 + 116), outline=(255, 255, 255, 255), width=4)
    over.paste(icon, (40, 140), mask)
    bold = ImageFont.truetype(material_font('Roboto-Bold.ttf'), 42)
    regular = ImageFont.truetype(material_font('Roboto-Regular.ttf'), 40)
    od.text((176, 192), name, font=bold, fill=(255, 255, 255, 255), anchor='lm')
    od.text((176 + bold.getlength(name) + 22, 192), when, font=regular,
            fill=(255, 255, 255, 200), anchor='lm')

    # Champ de réponse en bas.
    od.rounded_rectangle((40, 2150, w - 40, 2270), radius=60,
                         outline=(255, 255, 255, 230), width=4)
    od.text((100, 2210), reply, font=regular, fill=(255, 255, 255, 230),
            anchor='lm')
    img.alpha_composite(over)

    # Le sticker : la carte, un peu penchée, avec son ombre.
    if pop > 0:
        card = Image.open(RAW / f'{lang}-6-card.png').convert('RGBA')
        width = round(920 * (0.6 + 0.4 * pop))
        card = card.resize((width, round(width * card.height / card.width)),
                           Image.LANCZOS)
        card = card.rotate(4, resample=Image.BICUBIC, expand=True)
        if pop < 1:
            card.putalpha(card.getchannel('A').point(lambda v: int(v * pop)))
        shadow = Image.new('RGBA', (card.width + 160, card.height + 160),
                           (0, 0, 0, 0))
        shadow.paste((0, 0, 0, round(120 * pop)), (80, 110),
                     card.getchannel('A'))
        shadow = shadow.filter(ImageFilter.GaussianBlur(30))
        cx, cy = w // 2, 1080
        img.alpha_composite(shadow, (cx - shadow.width // 2,
                                     cy - shadow.height // 2))
        img.alpha_composite(card, (cx - card.width // 2, cy - card.height // 2))
    return img.convert('RGB')


TAGLINES = {
    'en': ('MyBookmark', 'Your reading journal, on your phone'),
    'fr': ('Mon marque-page', 'Votre carnet de lecture, dans votre poche'),
}


def feature_graphic(lang):
    """L'image de présentation du Play Store : 1024 × 500."""
    width, height = 1024, 500
    img = Image.new('RGB', (width, height), GREEN)
    draw = ImageDraw.Draw(img)
    for x in range(width):
        t = x / width
        color = tuple(round(GREEN[i] * (1 - t) + GREEN_DARK[i] * t) for i in range(3))
        draw.line((x, 0, x, height), fill=color)

    # Le ruban, en diagonale douce, avec sa queue d'aronde.
    ribbon = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ribbon)
    top, bottom = [], []
    for x in range(-20, width - 90, 6):
        y = 380 + 60 * math.sin(x / width * math.tau + 1.2)
        top.append((x, y - 26))
        bottom.append((x, y + 26))
    ex = width - 90
    ey = 380 + 60 * math.sin(ex / width * math.tau + 1.2)
    tail = [(ex + 70, ey - 26), (ex + 34, ey), (ex + 70, ey + 26)]
    rd.polygon(top + tail + bottom[::-1], fill=YELLOW + (255,))
    img.paste(ribbon, (0, 0), ribbon)

    icon = Image.open(ROOT / 'branding' / 'play-store-icon-512.png').convert('RGB')
    icon = icon.resize((220, 220), Image.LANCZOS)
    mask = Image.new('L', icon.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, 219, 219), radius=48, fill=255)
    img.paste(icon, (90, 110), mask)

    name, tagline = TAGLINES[lang]
    draw = ImageDraw.Draw(img)
    draw.text((360, 200), name, font=ImageFont.truetype(
        material_font('Roboto-Bold.ttf'), 72), fill=(255, 255, 255), anchor='ls')
    draw.text((362, 262), tagline, font=ImageFont.truetype(
        material_font('Roboto-Regular.ttf'), 32), fill=(226, 238, 234), anchor='ls')
    return img


def compose(out_dir, lang, store=False):
    screens = SCREENS if store else SCREENS[:SITE_SCREENS]
    count = len(screens)
    fresco = background(PANEL_W * count, PANEL_H).convert('RGBA')
    title_font = ImageFont.truetype(material_font('Roboto-Bold.ttf'), 86)

    phone_w = 760
    for index, (name, caption) in enumerate(zip(screens, CAPTIONS[lang])):
        left = index * PANEL_W
        if name == '5-story':
            device = phone(story_screen(lang), phone_w, light_status=True)
        else:
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
        if store:
            panel.save(out / f'screenshot-{index + 1}.png', optimize=True)
        else:
            panel.resize((720, 1280), Image.LANCZOS).save(
                out / f'panel-{index + 1}.webp', quality=86, method=6)
    if store:
        feature_graphic(lang).save(out / 'feature-graphic.png', optimize=True)


if __name__ == '__main__':
    args = sys.argv[1:]
    language = 'en'
    store = '--store' in args
    if store:
        args.remove('--store')
    if '--lang' in args:
        i = args.index('--lang')
        language = args[i + 1]
        del args[i:i + 2]
    compose(args[0] if args else ROOT / 'build' / 'screenshots' / 'panels',
            language, store)
