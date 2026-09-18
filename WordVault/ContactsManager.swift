import Foundation
import Contacts
import SwiftUI

class ContactsManager: ObservableObject {
    static let shared = ContactsManager()

    private let store = CNContactStore()

    @Published var authorizationStatus: CNAuthorizationStatus = .notDetermined
    @Published var isAutoImportEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isAutoImportEnabled, forKey: "ContactsManager.autoImport")
            if isAutoImportEnabled && authorizationStatus == .authorized {
                Task {
                    await autoImportContacts()
                }
            }
        }
    }

    private let autoImportKey = "ContactsManager.autoImport"
    private let lastImportKey = "ContactsManager.lastImport"

    private init() {
        self.isAutoImportEnabled = UserDefaults.standard.bool(forKey: autoImportKey)
        updateAuthorizationStatus()
    }

    // MARK: - Auto Permission & Import

    /// Auto request permission and import contacts if enabled
    func autoRequestAndImport() async -> Bool {
        updateAuthorizationStatus()

        if authorizationStatus == .authorized {
            // Already authorized, import if auto-import is enabled
            if isAutoImportEnabled {
                await autoImportContacts()
            }
            return true
        }

        // Request permission automatically
        let granted = await requestAccess()
        updateAuthorizationStatus()

        if granted && isAutoImportEnabled {
            await autoImportContacts()
        }

        return granted
    }

    /// Update cached authorization status
    func updateAuthorizationStatus() {
        authorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
    }

    /// Auto import contacts when permission is granted
    @MainActor
    func autoImportContacts() async {
        guard authorizationStatus == .authorized else { return }

        let contacts = await fetchContacts()
        if !contacts.isEmpty {
            // Store in UserDefaults via WordStore
            NotificationCenter.default.post(
                name: .contactsImported,
                object: contacts
            )
            UserDefaults.standard.set(Date(), forKey: lastImportKey)
        }
    }

    /// Check if auto-import should run (first launch or permission just granted)
    func shouldAutoImport() -> Bool {
        guard isAutoImportEnabled else { return false }
        guard authorizationStatus == .authorized else { return false }

        // Auto-import if never imported before
        if UserDefaults.standard.object(forKey: lastImportKey) == nil {
            return true
        }

        return false
    }

    // MARK: - Access Request

    func requestAccess() async -> Bool {
        do {
            let granted = try await store.requestAccess(for: .contacts)
            await MainActor.run {
                updateAuthorizationStatus()
            }
            return granted
        } catch {
            print("Error requesting contacts access: \(error)")
            return false
        }
    }

    // MARK: - Fetch Contacts

    func fetchContacts() async -> [WordEntry] {
        updateAuthorizationStatus()

        guard authorizationStatus == .authorized else {
            print("Contacts not authorized")
            return []
        }

        let keysToFetch: [CNKeyDescriptor] = [
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor
        ]

        var contactWords: [WordEntry] = []

        let request = CNContactFetchRequest(keysToFetch: keysToFetch)

        do {
            try store.enumerateContacts(with: request) { contact, _ in
                let fullName = [contact.familyName, contact.givenName]
                    .filter { !$0.isEmpty }
                    .joined()

                if !fullName.isEmpty {
                    // Add contact name as word entry
                    contactWords.append(WordEntry(
                        phrase: fullName,
                        shortcut: "",
                        category: .contacts
                    ))
                }
            }
        } catch {
            print("Error fetching contacts: \(error)")
        }

        return contactWords.sorted { $0.phrase < $1.phrase }
    }

    /// Fetch contact names only (simpler version)
    func fetchContactNames() async -> [String] {
        let contacts = await fetchContacts()
        return contacts.map { $0.phrase }
    }

    // MARK: - Permission UI Helpers

    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }

    var needsPermission: Bool {
        authorizationStatus == .denied || authorizationStatus == .restricted
    }

    var canRequestPermission: Bool {
        authorizationStatus == .notDetermined
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let contactsImported = Notification.Name("ContactsManager.contactsImported")
}
