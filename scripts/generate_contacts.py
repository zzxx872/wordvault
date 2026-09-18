#!/usr/bin/env python3
"""Generate sample contacts plist file for iOS Text Replacement"""

contacts = ["张三", "李四", "王五", "赵六", "钱七", "孙八", "周九", "吴十",
            "刘十一", "陈十二", "杨十三", "黄十四", "周十五", "吴十六"]

plist = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<array>
'''

for name in contacts:
    plist += f'''    <dict>
        <key>phrase</key>
        <string>{name}</string>
        <key>shortcut</key>
        <string></string>
    </dict>
'''

plist += '''</array>
</plist>
'''

with open('contacts_sample.plist', 'w', encoding='utf-8') as f:
    f.write(plist)

print(f'Generated contacts_sample.plist with {len(contacts)} sample contacts')
