import Foundation
import SwiftUI

@MainActor
class WordStore: ObservableObject {
    @Published var cities: [WordEntry] = []
    @Published var contacts: [WordEntry] = []
    @Published var customWords: [WordEntry] = []

    private let contactsKey = "WordVault.Contacts"
    private let customWordsKey = "WordVault.CustomWords"

    // MARK: - Load Methods

    func loadCities() {
        guard let url = Bundle.main.url(forResource: "cities", withExtension: "json") else {
            print("cities.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            // cities.json is an array of strings, convert to WordEntry
            if let cityNames = try? JSONDecoder().decode([String].self, from: data) {
                cities = cityNames.map { name in
                    WordEntry(phrase: name, shortcut: "", category: .cities)
                }
            } else {
                // Fallback: try decoding as WordEntry array
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                cities = try decoder.decode([WordEntry].self, from: data)
            }
        } catch {
            print("Error loading cities: \(error)")
        }
    }

    func loadContacts() {
        guard let data = UserDefaults.standard.data(forKey: contactsKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            contacts = try decoder.decode([WordEntry].self, from: data)
        } catch {
            print("Error loading contacts: \(error)")
        }
    }

    func loadCustomWords() {
        guard let data = UserDefaults.standard.data(forKey: customWordsKey) else {
            return
        }

        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            customWords = try decoder.decode([WordEntry].self, from: data)
        } catch {
            print("Error loading custom words: \(error)")
        }
    }

    func loadAll() {
        loadCities()
        loadContacts()
        loadCustomWords()
    }

    // MARK: - Save Methods

    func saveContacts() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(contacts)
            UserDefaults.standard.set(data, forKey: contactsKey)
        } catch {
            print("Error saving contacts: \(error)")
        }
    }

    func saveCustomWords() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(customWords)
            UserDefaults.standard.set(data, forKey: customWordsKey)
        } catch {
            print("Error saving custom words: \(error)")
        }
    }

    // MARK: - Plist Generation

    func generatePlist(category: WordCategory? = nil) -> URL? {
        let words: [WordEntry]
        if let category = category {
            switch category {
            case .cities:
                words = cities
            case .contacts:
                words = contacts
            case .custom:
                words = customWords
            }
        } else {
            words = allWords
        }

        guard let data = PlistGenerator.generatePlist(from: words) else {
            return nil
        }

        let fileName = category?.rawValue ?? "WordVault"
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(fileName).plist")

        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error writing plist: \(error)")
            return nil
        }
    }

    // MARK: - JSON Import/Export

    func exportToJSON() -> URL? {
        let exportData = AllWordsExport(
            cities: cities,
            contacts: contacts,
            customWords: customWords
        )

        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(exportData)

            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("WordVault_Export.json")

            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Error exporting JSON: \(error)")
            return nil
        }
    }

    func importFromJSON(url: URL) {
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let importData = try decoder.decode(AllWordsExport.self, from: data)

            cities = importData.cities
            contacts = importData.contacts
            customWords = importData.customWords

            saveContacts()
            saveCustomWords()
        } catch {
            print("Error importing JSON: \(error)")
        }
    }

    // MARK: - Word Management

    func addWord(_ word: WordEntry) {
        switch word.category {
        case .cities:
            if !cities.contains(where: { $0.phrase == word.phrase }) {
                cities.append(word)
            }
        case .contacts:
            if !contacts.contains(where: { $0.phrase == word.phrase }) {
                contacts.append(word)
                saveContacts()
            }
        case .custom:
            if !customWords.contains(where: { $0.phrase == word.phrase }) {
                customWords.append(word)
                saveCustomWords()
            }
        }
    }

    func removeWord(_ word: WordEntry) {
        switch word.category {
        case .cities:
            cities.removeAll { $0.id == word.id }
        case .contacts:
            contacts.removeAll { $0.id == word.id }
            saveContacts()
        case .custom:
            customWords.removeAll { $0.id == word.id }
            saveCustomWords()
        }
    }

    func removeWords(at offsets: IndexSet, from category: WordCategory) {
        switch category {
        case .cities:
            cities.remove(atOffsets: offsets)
        case .contacts:
            contacts.remove(atOffsets: offsets)
            saveContacts()
        case .custom:
            customWords.remove(atOffsets: offsets)
            saveCustomWords()
        }
    }

    // MARK: - Computed Properties

    var allWords: [WordEntry] {
        cities + contacts + customWords
    }

    func words(for category: WordCategory) -> [WordEntry] {
        switch category {
        case .cities:
            return cities
        case .contacts:
            return contacts
        case .custom:
            return customWords
        }
    }
}

// MARK: - Export Helper

private struct AllWordsExport: Codable {
    let cities: [WordEntry]
    let contacts: [WordEntry]
    let customWords: [WordEntry]
}
