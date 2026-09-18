import SwiftUI
import Contacts

struct ContactListView: View {
    @ObservedObject var wordStore: WordStore
    @ObservedObject var contactsManager: ContactsManager
    @State private var searchText = ""
    @State private var showingImportAlert = false
    @State private var showingExportSheet = false
    @State private var showingSettingsAlert = false
    @State private var exportURL: URL?
    @State private var isImporting = false
    @State private var lastImportCount = 0

    var filteredContacts: [WordEntry] {
        if searchText.isEmpty {
            return wordStore.contacts
        }
        return wordStore.contacts.filter { contact in
            contact.phrase.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            // Auto Import Section
            Section {
                Toggle(isOn: $contactsManager.isAutoImportEnabled) {
                    Label("自动导入通讯录", systemImage: "arrow.triangle.2.circlepath")
                }

                if contactsManager.isAutoImportEnabled {
                    HStack {
                        Text("自动导入状态")
                        Spacer()
                        statusBadge
                    }

                    if contactsManager.authorizationStatus == .denied {
                        Button {
                            showingSettingsAlert = true
                        } label: {
                            Label("前往设置开启权限", systemImage: "gear")
                        }
                    }
                }
            } header: {
                Text("自动导入")
            } footer: {
                Text("开启后，应用启动时自动请求通讯录权限并导入联系人")
            }

            // Manual Import Section
            Section {
                if contactsManager.authorizationStatus == .denied {
                    Button {
                        showingSettingsAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("通讯录权限被拒绝，点击前往设置开启")
                        }
                    }
                } else if contactsManager.authorizationStatus == .notDetermined {
                    Button {
                        Task {
                            await requestAccessAndImport()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.plus")
                            Text("请求通讯录权限")
                        }
                    }
                } else {
                    Button {
                        Task {
                            await manualImportContacts()
                        }
                    } label: {
                        HStack {
                            if isImporting {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            } else {
                                Image(systemName: "arrow.down.circle")
                            }
                            Text("手动导入通讯录")
                        }
                    }
                    .disabled(isImporting)
                }
            } header: {
                Text("手动操作")
            }

            // Contact List Section
            Section {
                if wordStore.contacts.isEmpty {
                    Text("暂无联系人")
                        .foregroundColor(.secondary)
                        .italic()
                } else {
                    ForEach(filteredContacts) { contact in
                        ContactRowView(contact: contact)
                    }
                    .onDelete(perform: deleteContacts)
                }
            } header: {
                HStack {
                    Text("通讯录列表")
                    Spacer()
                    Text("\(wordStore.contacts.count) 个")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜索联系人")
        .navigationTitle("通讯录")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        exportContacts()
                    } label: {
                        Label("导出为 plist", systemImage: "square.and.arrow.up")
                    }
                    .disabled(wordStore.contacts.isEmpty)

                    Button {
                        exportAllToJSON()
                    } label: {
                        Label("导出为 JSON", systemImage: "doc.text")
                    }
                    .disabled(wordStore.contacts.isEmpty)

                    Divider()

                    Button(role: .destructive) {
                        clearAllContacts()
                    } label: {
                        Label("清空通讯录", systemImage: "trash")
                    }
                    .disabled(wordStore.contacts.isEmpty)
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .alert("导入完成", isPresented: $showingImportAlert) {
            Button("确定", role: .cancel) {}
        } message: {
            Text("已从通讯录导入 \(lastImportCount) 个联系人")
        }
        .alert("需要通讯录权限", isPresented: $showingSettingsAlert) {
            Button("前往设置") {
                contactsManager.openSettings()
            }
            Button("取消", role: .cancel) {}
        } message: {
            Text("请在「设置 > 隐私与安全性 > 通讯录」中开启本应用的通讯录访问权限")
        }
        .onAppear {
            contactsManager.updateAuthorizationStatus()
        }
    }

    @ViewBuilder
    private var statusBadge: some View {
        switch contactsManager.authorizationStatus {
        case .authorized:
            Label("已授权", systemImage: "checkmark.circle.fill")
                .font(.caption)
                .foregroundColor(.green)
        case .denied:
            Label("已拒绝", systemImage: "xmark.circle.fill")
                .font(.caption)
                .foregroundColor(.red)
        case .restricted:
            Label("受限制", systemImage: "exclamationmark.circle.fill")
                .font(.caption)
                .foregroundColor(.orange)
        case .notDetermined:
            Label("未请求", systemImage: "questionmark.circle.fill")
                .font(.caption)
                .foregroundColor(.gray)
        case .limited:
            Label("受限访问", systemImage: "exclamationmark.triangle.fill")
                .font(.caption)
                .foregroundColor(.yellow)
        @unknown default:
            Label("未知", systemImage: "questionmark.circle")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }

    private func requestAccessAndImport() async {
        let granted = await contactsManager.requestAccess()
        if granted {
            await manualImportContacts()
        }
    }

    private func manualImportContacts() async {
        isImporting = true
        let contacts = await contactsManager.fetchContacts()
        lastImportCount = contacts.count

        await MainActor.run {
            wordStore.contacts = contacts
            wordStore.saveContacts()
            isImporting = false
            showingImportAlert = true
        }
    }

    private func deleteContacts(at offsets: IndexSet) {
        wordStore.removeWords(at: offsets, from: .contacts)
    }

    private func exportContacts() {
        if let url = wordStore.generatePlist(category: .contacts) {
            exportURL = url
            showingExportSheet = true
        }
    }

    private func exportAllToJSON() {
        if let url = wordStore.exportToJSON() {
            exportURL = url
            showingExportSheet = true
        }
    }

    private func clearAllContacts() {
        wordStore.contacts = []
        wordStore.saveContacts()
    }
}

// MARK: - Contact Row View

struct ContactRowView: View {
    let contact: WordEntry

    var body: some View {
        HStack {
            Image(systemName: "person.fill")
                .foregroundColor(.blue)

            Text(contact.phrase)
                .font(.body)

            Spacer()
        }
        .padding(.vertical, 4)
    }
}
