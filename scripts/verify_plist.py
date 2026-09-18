#!/usr/bin/env python3
"""Sanity-check the plists produced by the other two scripts.

Every entry must carry both a `phrase` and a `shortcut`. iOS greys out its Save
button when the shortcut is empty, so one such entry would quietly ruin the whole
import. Duplicate shortcuts are reported but do not fail the build — the city
list is large enough that collisions are expected.
"""

import os
import plistlib
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
FILES = ('cities.plist', 'contacts_sample.plist')


def main() -> int:
    failed = False

    for name in FILES:
        path = os.path.join(ROOT, name)
        if not os.path.exists(path):
            print(f'{name}: MISSING')
            failed = True
            continue

        with open(path, 'rb') as f:
            items = plistlib.load(f)

        bad = [
            i for i in items
            if not str(i.get('phrase', '')).strip() or not str(i.get('shortcut', '')).strip()
        ]
        dupes = len(items) - len({i['shortcut'] for i in items})
        print(f'{name}: {len(items)} entries, {len(bad)} invalid, {dupes} duplicate shortcuts')

        if bad or not items:
            failed = True

    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
