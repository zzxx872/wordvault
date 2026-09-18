#!/usr/bin/env python3
"""Generate a sample contacts plist for iOS Text Replacement.

This is demo/smoke-test data for CI, not a real address book. As with
generate_cities.py, every entry needs a non-empty shortcut to be usable.
"""

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

CONTACTS = [
    "张三", "李四", "王五", "赵六", "钱七", "孙八", "周九", "吴十",
    "刘十一", "陈十二", "杨十三", "黄十四", "周十五", "吴十六",
]


def initials(text: str) -> str:
    parts = lazy_pinyin(text, style=Style.FIRST_LETTER, errors='default')
    return re.sub(r'[^a-z0-9]', '', ''.join(parts).lower())


def main() -> int:
    entries = [
        {'phrase': name, 'shortcut': initials(name)}
        for name in CONTACTS
    ]
    entries = [e for e in entries if e['shortcut']]

    out = os.path.join(ROOT, 'contacts_sample.plist')
    with open(out, 'wb') as f:
        plistlib.dump(entries, f, fmt=plistlib.FMT_XML, sort_keys=True)

    print(f'Generated {out} with {len(entries)} sample contacts')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
