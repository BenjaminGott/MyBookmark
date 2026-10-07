"""Monte la vidéo de présentation (Play Store, site) à partir des captures.

Paysage 1920 × 1080, 30 images par seconde, environ 30 secondes, avec la
musique originale de music.py.
Même univers que les visuels de compose.py : fond vert, ruban jaune de
marque-page, téléphone. Le téléphone reste à l'écran et ses écrans défilent
comme sous le doigt ; le texte change à côté.

    flutter test tool/screenshots/capture_test.dart
    python3 tool/screenshots/video.py --lang en|fr

Écrit build/screenshots/video/mybookmark-<langue>.mp4 et .webm, et l'affiche
(poster-<langue>.webp). Demande ffmpeg.
"""

import math
import subprocess
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.path.insert(0, str(Path(__file__).resolve().parent))
from compose import (  # noqa: E402
    GREEN, GREEN_DARK, GREEN_LIGHT, RAW, ROOT, YELLOW, material_font, phone)
import music  # noqa: E402

W, H = 1920, 1080
FPS = 30
OUT = ROOT / 'build' / 'screenshots' / 'video'

TEXT = {
    'en': {
        'name': 'MyBookmark',
        'tagline': 'Your reading journal, on your phone',
        'scenes': [
            ('1-library', 'Your whole library',
             'Three shelves: To read, Reading, Read. Sort, filter, find.'),
            ('2-book', 'Track every page',
             'Progress, dates, ratings and reviews for every read.'),
            ('3-search', 'Find any book in seconds',
             'Open Library and Apple Books, covers included.'),
            ('4-share', 'Share your progress',
             "A card in your book's colours, ready for Instagram."),
            ('5-settings', 'Bring your Goodreads library',
             'Import it in one tap. And the app speaks 6 languages.'),
        ],
        'values': ['No account', 'No ads', 'No tracking'],
        'promise': 'Your books stay on your phone.',
        'cta': 'Available on Google Play',
        'by': 'by libergot',
    },
    'fr': {
        'name': 'Mon marque-page',
        'tagline': 'Votre carnet de lecture, dans votre poche',
        'scenes': [
            ('1-library', 'Toute votre bibliothèque',
             'Trois étagères : À lire, En cours, Lu. Triez, filtrez, retrouvez.'),
            ('2-book', 'Suivez chaque page',
             'Progression, dates, notes et avis pour chaque lecture.'),
            ('3-search', 'Trouvez un livre en un instant',
             'Open Library et Apple Books, couvertures comprises.'),
            ('4-share', 'Partagez votre progression',
             'Une carte aux couleurs du livre, prête pour Instagram.'),
            ('5-settings', 'Importez votre Goodreads',
             "En un geste. Et l'app parle 6 langues."),
        ],
        'values': ['Sans compte', 'Sans pub', 'Sans pistage'],
        'promise': 'Vos livres restent sur votre téléphone.',
        'cta': 'Disponible sur Google Play',
        'by': 'par libergot',
    },
}

# Le découpage dans le temps, en secondes.
INTRO = 3.0
SCENE = 4.6
OUTRO = 4.4
SWIPE = 0.55  # durée du glissement d'un écran à l'autre


def ease(t):
    """Départ vif, arrivée douce."""
    t = max(0.0, min(1.0, t))
    return 1 - (1 - t) ** 3


def font(weight, size):
    return ImageFont.truetype(material_font(f'Roboto-{weight}.ttf'), size)


def wrap(text, fnt, width):
    words, lines, line = text.split(), [], ''
    for word in words:
        trial = f'{line} {word}'.strip()
        if fnt.getlength(trial) <= width:
            line = trial
        else:
            lines.append(line)
            line = word
    lines.append(line)
    return lines


def text_block(lines_spec, width, center=False):
    """Un bloc de texte transparent : [(texte, police, couleur, espace après)]."""
    rendered = []
    height = 0
    for text, fnt, color, gap in lines_spec:
        for line in wrap(text, fnt, width):
            box = fnt.getbbox('Hg')
            rendered.append((height, line, fnt, color))
            height += box[3] - box[1] + int(fnt.size * 0.28)
        height += gap
    img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    for y, line, fnt, color in rendered:
        x = (width - fnt.getlength(line)) / 2 if center else 0
        draw.text((x, y), line, font=fnt, fill=color)
    return img


def faded(layer, alpha):
    if alpha >= 1:
        return layer
    out = layer.copy()
    out.putalpha(layer.getchannel('A').point(lambda v: int(v * alpha)))
    return out


def background_strip():
    """Fond plus large que l'image : on y fait glisser la caméra, lentement."""
    width = W + 600
    img = Image.new('RGB', (width, H), GREEN)
    draw = ImageDraw.Draw(img)
    for y in range(H):
        t = y / H
        draw.line((0, y, width, y), fill=tuple(
            round(GREEN[i] * (1 - t) + GREEN_DARK[i] * t) for i in range(3)))

    halos = Image.new('RGBA', (width, H), (0, 0, 0, 0))
    hd = ImageDraw.Draw(halos)
    for cx, cy, r in [(300, 180, 380), (1500, 900, 460), (2300, 260, 340)]:
        hd.ellipse((cx - r, cy - r, cx + r, cy + r), fill=GREEN_LIGHT + (140,))
    halos = halos.filter(ImageFilter.GaussianBlur(110))
    img.paste(halos, (0, 0), halos)

    ribbon = Image.new('RGBA', (width, H), (0, 0, 0, 0))
    rd = ImageDraw.Draw(ribbon)
    top, bottom = [], []
    for x in range(-40, width + 40, 8):
        # Tout en bas, sous les textes.
        y = 985 + 50 * math.sin(x / width * math.tau * 1.2 + 0.4)
        top.append((x, y - 38))
        bottom.append((x, y + 38))
    rd.polygon(top + bottom[::-1], fill=YELLOW + (255,))
    mid = [((a[0] + b[0]) / 2, (a[1] + b[1]) / 2) for a, b in zip(top, bottom)]
    rd.line(mid, fill=(248, 214, 130, 255), width=6)
    img.paste(ribbon, (0, 0), ribbon)
    return img


class Phone:
    """Le téléphone, dont l'écran peut glisser d'une capture à l'autre."""

    def __init__(self, screens, width):
        self.width = width
        # Le cadre complet de chaque écran, et le masque de la vitre.
        self.frames = {name: phone(img, width) for name, img in screens.items()}
        sample = next(iter(self.frames.values()))
        self.size = sample.size
        bezel = round(width * 0.028)
        self.bezel = bezel
        inner = (width - 2 * bezel, sample.height - 2 * bezel)
        radius = round(width * 0.12) - bezel
        self.glass = Image.new('L', inner, 0)
        ImageDraw.Draw(self.glass).rounded_rectangle(
            (0, 0, inner[0] - 1, inner[1] - 1), radius=radius, fill=255)
        self.inner = inner
        shadow = Image.new('RGBA', (self.size[0] + 160, self.size[1] + 160),
                           (0, 0, 0, 0))
        ImageDraw.Draw(shadow).rounded_rectangle(
            (100, 120, self.size[0] + 60, self.size[1] + 70),
            radius=round(width * 0.12), fill=(0, 0, 0, 130))
        self.shadow = shadow.filter(ImageFilter.GaussianBlur(36))

    def render(self, current, following=None, progress=0.0):
        """Le téléphone sur `current`, ou glissant vers `following`."""
        if following is None or progress <= 0:
            return self.frames[current]
        if progress >= 1:
            return self.frames[following]
        body = self.frames[current].copy()
        b = self.bezel
        a = self.frames[current].crop((b, b, b + self.inner[0], b + self.inner[1]))
        n = self.frames[following].crop((b, b, b + self.inner[0], b + self.inner[1]))
        shift = round(self.inner[0] * ease(progress))
        screen = Image.new('RGBA', self.inner)
        screen.paste(a, (-shift, 0))
        screen.paste(n, (self.inner[0] - shift, 0))
        body.paste(screen, (b, b), self.glass)
        return body


def share_card(lang):
    """La carte de partage, découpée dans la capture, coins compris."""
    img = Image.open(RAW / f'{lang}-4-share.png').convert('RGB')
    bg = img.getpixel((20, 1000))
    px = img.load()
    xs, ys = [], []  # le cadre de la carte : tout ce qui n'est pas le fond
    for y in range(300, 1600):
        for x in range(0, img.width, 2):
            r, g, b = px[x, y]
            if abs(r - bg[0]) + abs(g - bg[1]) + abs(b - bg[2]) > 30:
                xs.append(x)
                ys.append(y)
    # Deux pixels de marge en moins : le liseré lissé contre le fond.
    box = (min(xs) + 2, min(ys) + 2, max(xs), max(ys) - 1)
    card = img.crop(box).convert('RGBA')
    # Un rectangle aux coins arrondis comme ceux de la carte (26 points dans
    # l'app, à l'échelle de l'aperçu), dessiné en grand pour un bord lisse.
    radius = 26 * 3 * card.width / 1080
    big = Image.new('L', (card.width * 4, card.height * 4), 0)
    ImageDraw.Draw(big).rounded_rectangle(
        (0, 0, big.width - 1, big.height - 1), radius=radius * 4, fill=255)
    alpha = big.resize(card.size, Image.LANCZOS)
    card.putalpha(alpha)
    return card


def render(lang, preview=None):
    spec = TEXT[lang]
    scenes = spec['scenes']
    screens = {name: Image.open(RAW / f'{lang}-{name}.png')
               for name, _, _ in scenes}
    device = Phone(screens, 470)
    strip = background_strip()
    icon = Image.open(ROOT / 'branding' / 'play-store-icon-512.png').convert('RGBA')
    icon_mask = Image.new('L', icon.size, 0)
    ImageDraw.Draw(icon_mask).rounded_rectangle(
        (0, 0, icon.width - 1, icon.height - 1), radius=110, fill=255)
    icon.putalpha(icon_mask)

    white = (255, 255, 255, 255)
    soft = (214, 232, 226, 255)
    yellow = YELLOW + (255,)
    text_w = 720
    captions = [
        text_block([
            (f'0{i + 1}', font('Bold', 34), yellow, 10),
            (title, font('Bold', 76), white, 18),
            (sub, font('Regular', 38), soft, 0),
        ], text_w)
        for i, (_, title, sub) in enumerate(scenes)
    ]
    intro_text = text_block([
        (spec['name'], font('Bold', 96), white, 12),
        (spec['tagline'], font('Regular', 42), soft, 0),
    ], 1400, center=True)
    outro_values = text_block([
        ('  ·  '.join(spec['values']), font('Bold', 64), white, 18),
        (spec['promise'], font('Regular', 42), soft, 0),
    ], 1600, center=True)
    cta = text_block([
        (spec['cta'], font('Bold', 44), yellow, 6),
        (spec['by'], font('Regular', 32), soft, 0),
    ], 1000, center=True)
    card = share_card(lang)
    card = card.resize((560, round(560 * card.height / card.width)),
                       Image.LANCZOS)

    phone_x = 1210
    phone_y = (H - device.size[1]) // 2
    text_x = 150
    total = INTRO + SCENE * len(scenes) + OUTRO
    frame_count = round(total * FPS)

    def frame(index):
        t = index / FPS
        # Caméra : le fond glisse de 600 px sur toute la vidéo.
        cam = round(600 * t / total)
        img = strip.crop((cam, 0, cam + W, H)).convert('RGBA')

        if t < INTRO:
            k = t / INTRO
            size = round(260 * (0.7 + 0.3 * ease(k * 2.2)))
            ic = faded(icon.resize((size, size), Image.LANCZOS), ease(k * 3))
            img.alpha_composite(ic, ((W - size) // 2, 250 + (260 - size) // 2))
            tx = faded(intro_text, ease((k - 0.15) * 3))
            img.alpha_composite(tx, ((W - intro_text.width) // 2,
                                     590 + round(30 * (1 - ease((k - 0.15) * 3)))))
            # L'intro s'efface juste avant la première scène.
            if k > 0.85:
                fade = (k - 0.85) / 0.15
                img = Image.blend(img, strip.crop((cam, 0, cam + W, H)).convert('RGBA'), fade)
            return img

        if t < INTRO + SCENE * len(scenes):
            local = t - INTRO
            index_scene = int(local // SCENE)
            s = local - index_scene * SCENE
            name = scenes[index_scene][0]

            # Le téléphone monte à l'écran au début, puis ne bouge plus ; à la
            # fin de chaque scène, son écran glisse vers le suivant.
            rise = ease(local / 0.8)
            y = phone_y + round((1 - rise) * (H - phone_y))
            # Et redescend à la fin de la dernière scène.
            if index_scene + 1 == len(scenes):
                y += round(ease((s - (SCENE - 0.6)) / 0.6) * (H - phone_y))
            following = None
            progress = 0.0
            if s > SCENE - SWIPE and index_scene + 1 < len(scenes):
                following = scenes[index_scene + 1][0]
                progress = (s - (SCENE - SWIPE)) / SWIPE
            img.alpha_composite(device.shadow, (phone_x - 100, y - 100))
            img.alpha_composite(device.render(name, following, progress),
                                (phone_x, y))

            # Le texte entre par le bas et sort par le haut.
            appear = ease((s - 0.15) / 0.6)
            leave = ease((s - (SCENE - 0.5)) / 0.45) if index_scene + 1 < len(scenes) else ease((s - (SCENE - 0.45)) / 0.45)
            caption = captions[index_scene]
            alpha = appear * (1 - leave)
            dy = round(40 * (1 - appear) - 40 * leave)
            img.alpha_composite(faded(caption, alpha),
                                (text_x, (H - caption.height) // 2 + dy))

            # La carte de partage sort du téléphone.
            if name == '4-share':
                pop = ease((s - 0.9) / 0.7) * (1 - leave)
                if pop > 0:
                    scale = 0.75 + 0.25 * pop
                    c = card.resize((round(card.width * scale),
                                     round(card.height * scale)), Image.BILINEAR)
                    cx = phone_x - 230 + round(60 * (1 - pop))
                    cy = 610 - c.height // 2
                    shadow = Image.new('RGBA', (c.width + 80, c.height + 80), (0, 0, 0, 0))
                    ImageDraw.Draw(shadow).rounded_rectangle(
                        (40, 50, c.width + 40, c.height + 50), radius=60,
                        fill=(0, 0, 0, round(110 * pop)))
                    img.alpha_composite(shadow.filter(ImageFilter.GaussianBlur(24)),
                                        (cx - 40, cy - 40))
                    img.alpha_composite(faded(c, pop), (cx, cy))

            return img

        s = t - INTRO - SCENE * len(scenes)
        k = s / OUTRO
        size = 180
        ic = faded(icon.resize((size, size), Image.LANCZOS), ease(k * 4))
        img.alpha_composite(ic, ((W - size) // 2, 150))
        vals = faded(outro_values, ease((k - 0.08) * 4))
        img.alpha_composite(vals, ((W - outro_values.width) // 2, 390))
        c = faded(cta, ease((k - 0.3) * 4))
        img.alpha_composite(c, ((W - cta.width) // 2, 640))
        return img

    OUT.mkdir(parents=True, exist_ok=True)
    if preview:
        for second in preview:
            frame(round(second * FPS)).convert('RGB').save(
                OUT / f'preview-{lang}-{second:05.2f}.png')
        return

    total_seconds = frame_count / FPS
    soundtrack = OUT / 'music.wav'
    music.write(music.compose(total_seconds), soundtrack)

    mp4 = OUT / f'mybookmark-{lang}.mp4'
    silent = OUT / f'silent-{lang}.mp4'
    encoder = subprocess.Popen(
        ['ffmpeg', '-y', '-loglevel', 'error', '-f', 'rawvideo',
         '-pix_fmt', 'rgb24', '-s', f'{W}x{H}', '-r', str(FPS), '-i', '-',
         '-c:v', 'libx264', '-preset', 'slow', '-crf', '20',
         '-pix_fmt', 'yuv420p', str(silent)],
        stdin=subprocess.PIPE)
    poster_at = round((INTRO + SCENE * 0.6) * FPS)
    for index in range(frame_count):
        image = frame(index).convert('RGB')
        if index == poster_at:
            image.save(OUT / f'poster-{lang}.webp', quality=82, method=6)
        encoder.stdin.write(image.tobytes())
    encoder.stdin.close()
    encoder.wait()

    # La musique est ajoutée sans réencoder l'image.
    subprocess.run(
        ['ffmpeg', '-y', '-loglevel', 'error', '-i', str(silent),
         '-i', str(soundtrack), '-map', '0:v', '-map', '1:a', '-c:v', 'copy',
         '-c:a', 'aac', '-b:a', '160k', '-shortest', '-movflags', '+faststart',
         str(mp4)], check=True)
    silent.unlink()

    subprocess.run(
        ['ffmpeg', '-y', '-loglevel', 'error', '-i', str(mp4),
         '-c:v', 'libvpx-vp9', '-b:v', '0', '-crf', '36', '-row-mt', '1',
         '-c:a', 'libopus', '-b:a', '128k',
         str(OUT / f'mybookmark-{lang}.webm')], check=True)
    print(f'{lang} : {mp4} ({frame_count / FPS:.1f} s)')


if __name__ == '__main__':
    args = sys.argv[1:]
    langs = [args[args.index('--lang') + 1]] if '--lang' in args else ['en', 'fr']
    # --preview 1.5,8,20 : quelques images fixes au lieu de la vidéo.
    seconds = None
    if '--preview' in args:
        seconds = [float(v) for v in args[args.index('--preview') + 1].split(',')]
    for language in langs:
        render(language, seconds)
