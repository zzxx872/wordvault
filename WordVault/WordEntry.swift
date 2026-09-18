import Foundation

struct WordEntry: Identifiable, Codable, Hashable {
    var id = UUID()
    var phrase: String  // the word
    var shortcut: String = ""  // trigger (usually empty for dictionary words)
    var category: WordCategory
    var dateAdded: Date = Date()
}

enum WordCategory: String, Codable, CaseIterable {
    case cities = "城市"
    case contacts = "通讯录"
    case custom = "自定义"
}
