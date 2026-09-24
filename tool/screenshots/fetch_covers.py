"""Télécharge les vraies couvertures des livres de démonstration.

Cherche chaque livre dans Apple Books, comme le fait l'app, et garde les
premiers candidats dans build/screenshots/candidates/<livre>/1.png, 2.png…
Le candidat retenu (dernier nombre de BOOKS, choisi à l'œil pour écarter les
couvertures génériques) est copié dans build/screenshots/covers/<livre>.png.

    python3 tool/screenshots/fetch_covers.py [--candidates 4]

Une couverture fournie à la main dans tool/screenshots/covers/<livre>.* est
toujours prioritaire (par exemple une édition précise).
"""

import io
import json
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]
BUILD = ROOT / 'build' / 'screenshots'
MANUAL = Path(__file__).resolve().parent / 'covers'
USER_AGENT = 'MyBookmark/1.0 (application de lecture locale)'

# clé : (recherche, pays de la boutique Apple, candidat retenu)
BOOKS = {
    # Série anglaise.
    'knight-en': ('The Knight and the Moth Rachel Gillig', 'US', 1),
    'prince-en': ('The Little Prince Antoine de Saint-Exupery', 'US', 1),
    'pride': ('Pride and Prejudice Jane Austen', 'US', 2),
    'frankenstein': ('Frankenstein Mary Shelley', 'US', 1),
    'dracula': ('Dracula Bram Stoker', 'US', 2),
    'jane-eyre': ('Jane Eyre Charlotte Bronte', 'US', 2),
    'emma': ('Emma Jane Austen', 'US', 2),
    'sense': ('Sense and Sensibility Jane Austen', 'US', 2),
    'persuasion': ('Persuasion Jane Austen', 'US', 2),
    # Série française.
    'knight-fr': ('Le chevalier et la phalène Rachel Gillig', 'FR', 1),
    'prince-fr': ('Le Petit Prince Saint-Exupéry', 'FR', 1),
    'miserables': ('Les Misérables Victor Hugo', 'FR', 4),
    'monte-cristo': ('Le Comte de Monte-Cristo Alexandre Dumas', 'FR', 1),
    'bovary': ('Madame Bovary Flaubert', 'FR', 2),
    'mousquetaires': ('Les Trois Mousquetaires Alexandre Dumas', 'FR', 2),
    'notre-dame': ('Notre-Dame de Paris Victor Hugo', 'FR', 3),
    'contemplations': ('Les Contemplations Victor Hugo', 'FR', 2),
    'quatrevingt': ('Quatrevingt-treize Victor Hugo', 'FR', 2),
}


def get(url):
    """Télécharge, en patientant quand Apple limite les requêtes (403)."""
    request = urllib.request.Request(url, headers={'User-Agent': USER_AGENT})
    for attempt in range(5):
        try:
            with urllib.request.urlopen(request, timeout=30) as response:
                return response.read()
        except urllib.error.HTTPError as error:
            if error.code != 403 or attempt == 4:
                raise
            time.sleep(15 * (attempt + 1))


def search(term, country, limit):
    query = urllib.parse.urlencode({
        'term': term, 'media': 'ebook', 'country': country, 'limit': limit * 2,
    })
    data = json.loads(get(f'https://itunes.apple.com/search?{query}'))
    urls = []
    for result in data.get('results', []):
        artwork = result.get('artworkUrl100')
        if artwork:
            # Apple sert la même image en grand en changeant la taille demandée.
            urls.append(artwork.replace('100x100bb', '900x900bb'))
    return urls[:limit]


def main():
    limit = 4
    if '--candidates' in sys.argv:
        limit = int(sys.argv[sys.argv.index('--candidates') + 1])
    covers = BUILD / 'covers'
    covers.mkdir(parents=True, exist_ok=True)

    for key, (term, country, chosen) in BOOKS.items():
        manual = next(iter(sorted(MANUAL.glob(f'{key}.*'))), None)
        if manual is not None:
            Image.open(manual).convert('RGB').save(covers / f'{key}.png')
            print(f'{key}: couverture fournie à la main')
            continue

        # Les candidats déjà téléchargés sont gardés : l'ordre des résultats
        # d'Apple peut changer, le choix doit rester le même.
        folder = BUILD / 'candidates' / key
        if not any(folder.glob('*.png')):
            folder.mkdir(parents=True, exist_ok=True)
            for index, url in enumerate(search(term, country, limit), start=1):
                image = Image.open(io.BytesIO(get(url))).convert('RGB')
                image.save(folder / f'{index}.png')
            time.sleep(3)
        found = sorted(folder.glob('*.png'))
        if found:
            pick = folder / f'{chosen}.png'
            Image.open(pick if pick.exists() else found[0]).save(
                covers / f'{key}.png')
        print(f'{key}: {len(found)} candidat(s)')


if __name__ == '__main__':
    main()
