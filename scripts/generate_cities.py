#!/usr/bin/env python3
"""Generate an iOS Text Replacement plist from WordVault/cities.json.

Every entry gets a non-empty shortcut derived from pinyin initials, because iOS
disables its Save button when the shortcut field is empty — an entry without a
shortcut is dead weight in the exported file.

The plist is written with `plistlib`, so escaping of `&`, `<`, `>` and quotes is
handled by the standard library instead of by hand. Paths are resolved relative
to the repository root, so the script runs from any working directory.
"""

import json
import os
import plistlib
import re

try:
    from pypinyin import Style, lazy_pinyin
except ImportError:
    raise SystemExit(
        'pypinyin is required: python3 -m pip install pypinyin\n'
        'Without it no shortcut can be derived, and entries with an empty '
        'shortcut are unusable on iOS.'
    )

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))


def initials(text: str) -> str:
    """Pinyin initials of `text`, e.g. 北京市 -> bjs."""
    parts = lazy_pinyin(text, style=Style.FIRST_LETTER, errors='default')
    return re.sub(r'[^a-z0-9]', '', ''.join(parts).lower())


def main() -> int:
    src = os.path.join(ROOT, 'WordVault', 'cities.json')
    with open(src, 'r', encoding='utf-8') as f:
        cities = json.load(f)

    entries = []
    skipped = []
    for city in cities:
        code = initials(city)
        if not code:
            skipped.append(city)
            continue
        entries.append({'phrase': city, 'shortcut': code})

    out = os.path.join(ROOT, 'cities.plist')
    with open(out, 'wb') as f:
        plistlib.dump(entries, f, fmt=plistlib.FMT_XML, sort_keys=True)

    print(f'Generated {out} with {len(entries)} cities')
    if skipped:
        print(f'Skipped {len(skipped)} cities with no derivable shortcut: {skipped[:10]}')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
