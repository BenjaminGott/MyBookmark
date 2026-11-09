"""Génère les icônes Android et l'icône du Play Store à partir du logo.

Le logo d'origine est un livre-hibou jaune posé sur un fond vert uni. Le dessin
est détaché du fond (couleurs conservées, bords adoucis), puis reposé sur le
même vert : c'est ce qui donne une icône nette et bien centrée à toutes les
tailles, quel que soit le masque du lanceur.

    pip install pillow numpy
    python3 tool/generate_icons.py
"""

from pathlib import Path

import numpy as np
from PIL import Image, ImageDraw

ROOT = Path(__file__).resolve().parent.parent
SOURCE = ROOT / 'branding' / 'logo-source.jpg'
RES = ROOT / 'android' / 'app' / 'src' / 'main' / 'res'
COLORS = RES / 'values' / 'colors.xml'
ASSET = ROOT / 'assets' / 'logo.png'

DENSITIES = {'mdpi': 1, 'hdpi': 1.5, 'xhdpi': 2, 'xxhdpi': 3, 'xxxhdpi': 4}


def background_color(rgb: np.ndarray) -> tuple:
    """Le vert du fond, lu sur les bords de l'image."""
    border = np.concatenate([rgb[0], rgb[-1], rgb[:, 0], rgb[:, -1]])
    return tuple(int(v) for v in np.median(border, axis=0))


def extract_logo(rgb: np.ndarray, background: tuple) -> Image.Image:
    """Le dessin seul, en RGBA, recadré au carré autour du livre."""
    distance = np.abs(rgb - np.array(background, dtype=float)).sum(axis=2)
    # Sous 30, c'est le fond et ses artefacts JPEG ; au-delà de 90, le dessin.
    alpha = np.clip((distance - 30) / 60, 0, 1)

    # Sur les bords adoucis, on retire la part de vert mêlée à la couleur.
    safe = np.maximum(alpha, 1e-3)[..., None]
    color = (rgb - (1 - safe) * np.array(background)) / safe
    color = np.clip(color, 0, 255)

    ys, xs = np.where(alpha > 0.5)
    cx, cy = (xs.min() + xs.max()) / 2, (ys.min() + ys.max()) / 2
    half = max(xs.max() - xs.min(), ys.max() - ys.min()) / 2 + 4
    box = tuple(int(round(v)) for v in (cx - half, cy - half, cx + half, cy + half))

    layer = np.zeros((*alpha.shape, 4), dtype=np.uint8)
    layer[..., :3] = color.round().astype(np.uint8)
    layer[..., 3] = (alpha * 255).round().astype(np.uint8)
    return Image.fromarray(layer, 'RGBA').crop(box)


def place(logo: Image.Image, size: int, ratio: float, background=None,
          disc=None, color=None) -> Image.Image:
    """Centre le logo sur un carré de `size`, à `ratio` de sa largeur."""
    canvas = Image.new('RGBA', (size, size), background or (0, 0, 0, 0))
    side = round(size * ratio)
    if disc is not None:
        # Fond rond pour les anciens lanceurs, qui n'appliquent aucun masque.
        big = Image.new('L', (size * 4, size * 4), 0)
        ImageDraw.Draw(big).ellipse((4, 4, size * 4 - 4, size * 4 - 4), fill=255)
        fill = Image.new('RGBA', (size, size), disc)
        canvas.paste(fill, (0, 0), big.resize((size, size), Image.LANCZOS))
    scaled = logo.resize((side, side), Image.LANCZOS)
    if color is not None:
        tinted = Image.new('RGBA', scaled.size, color)
        tinted.putalpha(scaled.getchannel('A'))
        scaled = tinted
    offset = (size - side) // 2
    canvas.alpha_composite(scaled, (offset, offset))
    return canvas


def write_background_color(background: tuple) -> None:
    hex_color = '#{:02X}{:02X}{:02X}'.format(*background)
    COLORS.write_text(
        '<?xml version="1.0" encoding="utf-8"?>\n'
        '<resources>\n'
        '    <!-- Le vert du logo, derrière l\'icône adaptative. -->\n'
        f'    <color name="ic_launcher_background">{hex_color}</color>\n'
        '</resources>\n',
        encoding='utf-8',
    )


def main() -> None:
    rgb = np.asarray(Image.open(SOURCE).convert('RGB')).astype(float)
    background = background_color(rgb)
    logo = extract_logo(rgb, background)
    solid = background + (255,)

    for name, scale in DENSITIES.items():
        folder = RES / f'mipmap-{name}'
        folder.mkdir(parents=True, exist_ok=True)
        # Icône classique (avant Android 8) : 48 dp, le logo sur un disque vert.
        place(logo, round(48 * scale), 0.66, disc=solid).save(
            folder / 'ic_launcher.png')
        # Icône adaptative : 108 dp, dont seuls les 66 dp du centre sont sûrs
        # d'être visibles quel que soit le masque du lanceur.
        place(logo, round(108 * scale), 0.50).save(
            folder / 'ic_launcher_foreground.png')
        # Icône thématique d'Android 13 : une silhouette que le système colore.
        place(logo, round(108 * scale), 0.50, color=(0, 0, 0, 255)).save(
            folder / 'ic_launcher_monochrome.png')

    write_background_color(background)

    # Le logo seul, sur fond transparent, pour l'en-tête de l'application.
    ASSET.parent.mkdir(parents=True, exist_ok=True)
    place(logo, 192, 1.0).save(ASSET)

    # Icône du Play Store : 512 × 512, fond plein, Google arrondit lui-même.
    place(logo, 512, 0.78, background=solid).convert('RGB').save(
        ROOT / 'branding' / 'play-store-icon-512.png')


if __name__ == '__main__':
    main()
