import SwiftUI
import Contacts

struct ContentView: View {
    @StateObject private var wordStore = WordStore()
    @StateObject private var contactsManager = ContactsManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            CityListView(wordStore: wordStore)
                .tabItem {
                    Label("城市", systemImage: "building.2")
                }
                .tag(0)

            ContactListView(wordStore: wordStore, contactsManager: contactsManager)
                .tabItem {
                    Label("通讯录", systemImage: "person.crop.rectangle")
                }
                .tag(1)

            CustomWordsView(wordStore: wordStore)
                .tabItem {
                    Label("自定义", systemImage: "text.badge.plus")
                }
                .tag(2)

            ExportView(wordStore: wordStore)
                .tabItem {
                    Label("导出", systemImage: "square.and.arrow.up")
                }
                .tag(3)
        }
        .navigationTitle("词库助手")
        .task {
            // Auto load data on launch
            wordStore.loadAll()

            // Auto request contacts permission
            await contactsManager.autoRequestAndImport()
        }
        .onReceive(NotificationCenter.default.publisher(for: .contactsImported)) { notification in
            if let contacts = notification.object as? [WordEntry] {
                // Replace contacts with imported ones
                wordStore.contacts = contacts
                wordStore.saveContacts()
            }
        }
    }
}

#Preview {
    ContentView()
}
