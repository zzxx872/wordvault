import Foundation

class PlistGenerator {
    static func generatePlist(from words: [WordEntry]) -> Data? {
        var plistContent = """
        <?xml version="1.0" encoding="UTF-8"?>
        <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
        <plist version="1.0">
        <array>

        """

        for word in words {
            let phrase = escapeXML(word.phrase)
            let shortcut = escapeXML(word.shortcut)
            plistContent += """
                <dict>
                    <key>phrase</key>
                    <string>\(phrase)</string>
                    <key>shortcut</key>
                    <string>\(shortcut)</string>
                </dict>

            """
        }

        plistContent += """
        </array>
        </plist>
        """

        return plistContent.data(using: .utf8)
    }

    // MARK: - XML Escape

    private static func escapeXML(_ string: String) -> String {
        var result = string
        result = result.replacingOccurrences(of: "&", with: "&amp;")
        result = result.replacingOccurrences(of: "<", with: "&lt;")
        result = result.replacingOccurrences(of: ">", with: "&gt;")
        result = result.replacingOccurrences(of: "\"", with: "&quot;")
        result = result.replacingOccurrences(of: "'", with: "&apos;")
        return result
    }
}
