"""Génère les icônes Android et l'icône du Play Store à partir du logo.

Le logo d'origine est un trait bleu canard sur un papier texturé. Le trait est
isolé en couche alpha (le grain du papier disparaît sous un seuil), puis posé
sur un fond uni : c'est ce qui donne une icône nette à toutes les tailles.

    pip install pillow numpy
    python3 tool/generate_icons.py
"""

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'branding' / 'logo-source.jpg'
RES = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'

INK = (28, 89, 108)  # Le bleu canard du logo.
PAPER = (248, 247, 242)  # Le fond, repris du papier sans son grain.

DENSITIES = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}


def extract_logo() -> Image.Image:
    """Le trait seul, en RGBA, recadré au carré autour du cercle."""
    rgb = np.asarray(Image.open(SOURCE).convert('RGB')).astype(float)
    lum = rgb.mean(axis=2)
    paper = np.median(lum)
    ink = lum[lum < 120].mean()
    # Le grain du papier varie de quelques niveaux : on l'ignore sous 8.
    alpha = np.clip((paper - lum - 8) / (paper - ink - 8), 0, 1)

    ys, xs = np.where(alpha > 0.5)
    cx, cy = (xs.min() + xs.max()) / 2, (ys.min() + ys.max()) / 2
    half = max(xs.max() - xs.min(), ys.max() - ys.min()) / 2 + 4
    box = tuple(int(round(v)) for v in (cx - half, cy - half, cx + half, cy + half))

    layer = np.zeros((*alpha.shape, 4), dtype=np.uint8)
    layer[..., :3] = INK
    layer[..., 3] = (alpha * 255).round().astype(np.uint8)
    return Image.fromarray(layer, 'RGBA').crop(box)


def place(logo: Image.Image, size: int, ratio: float, background=None,
          disc: bool = False, color=None) -> Image.Image:
    """Centre le logo sur un carré de `size`, à `ratio` de sa largeur."""
    canvas = Image.new('RGBA', (size, size), background or (0, 0, 0, 0))
    side = round(size * ratio)
    if disc:
        # Fond rond sous le cercle du logo, pour les anciens lanceurs.
        big = Image.new('L', (size * 4, size * 4), 0)
        inset = (size - side) * 2 + 4
        ImageDraw.Draw(big).ellipse(
            (inset, inset, size * 4 - inset, size * 4 - inset), fill=255)
        paper = Image.new('RGBA', (size, size), PAPER)
        canvas.paste(paper, (0, 0), big.resize((size, size), Image.LANCZOS))
    scaled = logo.resize((side, side), Image.LANCZOS)
    if color is not None:
        tinted = Image.new('RGBA', scaled.size, color)
        tinted.putalpha(scaled.getchannel('A'))
        scaled = tinted
    offset = (size - side) // 2
    canvas.alpha_composite(scaled, (offset, offset))
    return canvas


def main() -> None:
    logo = extract_logo()

    for name, scale in DENSITIES.items():
        folder = RES / f'mipmap-{name}'
        folder.mkdir(parents=True, exist_ok=True)
        # Icône classique (avant Android 8) : 48 dp, le logo sur un disque.
        place(logo, round(48 * scale), 0.94, disc=True).save(
            folder / 'ic_launcher.png')
        # Icône adaptative : 108 dp, dont seuls les 66 dp du centre sont sûrs
        # d'être visibles quel que soit le masque du lanceur.
        place(logo, round(108 * scale), 0.60).save(
            folder / 'ic_launcher_foreground.png')
        # Icône thématique d'Android 13 : une silhouette que le système colore.
        place(logo, round(108 * scale), 0.60, color=(0, 0, 0, 255)).save(
            folder / 'ic_launcher_monochrome.png')

    # Icône du Play Store : 512 × 512, fond plein, Google arrondit lui-même.
    place(logo, 512, 0.80, background=PAPER + (255,)).convert('RGB').save(
        ROOT / 'branding' / 'play-store-icon-512.png')


if __name__ == '__main__':
    main()
