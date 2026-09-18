#!/usr/bin/env python3
"""
Generate iOS Text Replacement plist from cities.json
"""

import json
import os

def escape_xml(s):
    """Escape special XML characters"""
    s = s.replace('&', '&amp;')
    s = s.replace('<', '&lt;')
    s = s.replace('>', '&gt;')
    s = s.replace('"', '&quot;')
    s = s.replace("'", '&apos;')
    return s

def main():
    # Read cities
    cities_path = os.path.join(os.path.dirname(__file__), '..', 'WordVault', 'cities.json')
    with open(cities_path, 'r', encoding='utf-8') as f:
        cities = json.load(f)

    # Generate plist
    plist_content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
'''

    for city in cities:
        city_esc = escape_xml(city)
        plist_content += f'''    <dict>
        <key>phrase</key>
        <string>{city_esc}</string>
        <key>shortcut</key>
        <string></string>
    </dict>
'''

    plist_content += '''</array>
</plist>
'''

    # Write plist
    output_path = os.path.join(os.path.dirname(__file__), '..', 'cities.plist')
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(plist_content)

    print(f"Generated {output_path} with {len(cities)} cities")

if __name__ == '__main__':
    main()
