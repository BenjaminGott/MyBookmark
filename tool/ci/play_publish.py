"""Publie sur une piste du Play Store une version déjà envoyée, sans rien
recompiler : utile quand l'envoi est passé mais que la publication a été
refusée (pays manquants, autorisation, examen…).

    PLAY_SERVICE_ACCOUNT_JSON='{…}' python3 tool/ci/play_publish.py \
        --track production [--version-code 407275] [--name 1.5.0] \
        [--status completed]

Sans --version-code, prend la dernière version envoyée (le plus grand numéro).
Demande `google-auth` et `requests` (pip install google-auth requests).
"""

import argparse
import json
import os
import sys

from google.auth.transport.requests import AuthorizedSession
from google.oauth2 import service_account

PACKAGE = 'com.libergot.mybookmark'
API = ('https://androidpublisher.googleapis.com/androidpublisher/v3/'
       f'applications/{PACKAGE}')
SCOPE = 'https://www.googleapis.com/auth/androidpublisher'


def call(session, method, path, **kwargs):
    response = session.request(method, API + path, **kwargs)
    if not response.ok:
        try:
            message = response.json()['error']['message']
        except (ValueError, KeyError):
            message = response.text
        sys.exit(f'::error::{method} {path} : {message}')
    return response.json() if response.content else {}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--track', default='production')
    parser.add_argument('--version-code', type=int)
    parser.add_argument('--name')
    parser.add_argument('--status', default='completed')
    args = parser.parse_args()

    info = json.loads(os.environ['PLAY_SERVICE_ACCOUNT_JSON'])
    credentials = service_account.Credentials.from_service_account_info(
        info, scopes=[SCOPE])
    session = AuthorizedSession(credentials)

    edit = call(session, 'POST', '/edits', json={})['id']
    bundles = call(session, 'GET', f'/edits/{edit}/bundles').get('bundles', [])
    known = sorted(bundle['versionCode'] for bundle in bundles)
    if not known:
        sys.exit("::error::Aucune version envoyée sur le Play Store.")

    code = args.version_code or known[-1]
    if code not in known:
        sys.exit(f'::error::Version {code} inconnue. Dernières : '
                 f'{", ".join(map(str, known[-5:]))}')

    release = {'versionCodes': [str(code)], 'status': args.status}
    if args.name:
        release['name'] = args.name
    call(session, 'PUT', f'/edits/{edit}/tracks/{args.track}',
         json={'track': args.track, 'releases': [release]})
    call(session, 'POST', f'/edits/{edit}:commit')
    print(f'Version {code} publiée sur la piste « {args.track} » '
          f'({args.status}).')


if __name__ == '__main__':
    main()
