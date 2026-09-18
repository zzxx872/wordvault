#!/usr/bin/env python3
"""Generate cities plist file for iOS Text Replacement"""

import json

# Read cities from JSON file
with open('WordVault/cities.json', 'r', encoding='utf-8') as f:
    cities = json.load(f)

# Generate plist
plist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
'''

for city in cities:
    city_esc = city.replace('&', '&amp;').replace('<', '&lt;').replace('>', '&gt;')
    city_esc = city_esc.replace('"', '&quot;').replace("'", '&apos;')
    plist += f'''    <dict>
        <key>phrase</key>
        <string>{city_esc}</string>
        <key>shortcut</key>
        <string></string>
    </dict>
'''

plist += '''</array>
</plist>
'''

with open('cities.plist', 'w', encoding='utf-8') as f:
    f.write(plist)

print(f'Generated cities.plist with {len(cities)} cities')
