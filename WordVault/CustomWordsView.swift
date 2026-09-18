import SwiftUI

struct CustomWordsView: View {
    @ObservedObject var wordStore: WordStore
    @State private var searchText = ""
    @State private var showingAddSheet = false
    @State private var showingExportSheet = false
    @State private var showingImportPicker = false
    @State private var exportURL: URL?
    @State private var newWordPhrase = ""
    @State private var newWordShortcut = ""

    var filteredWords: [WordEntry] {
        if searchText.isEmpty {
            return wordStore.customWords
        }
        return wordStore.customWords.filter { word in
            word.phrase.localizedCaseInsensitiveContains(searchText) ||
            word.shortcut.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(filteredWords) { word in
                    CustomWordRowView(word: word)
                }
                .onDelete(perform: deleteWords)
            } header: {
                HStack {
                    Text("自定义词库")
                    Spacer()
                    Text("\(wordStore.customWords.count) 个")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜索词条")
        .navigationTitle("自定义")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    showingImportPicker = true
                } label: {
                    Image(systemName: "square.and.arrow.down")
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("添加词条", systemImage: "plus")
                    }

                    Button {
                        exportCustomWords()
                    } label: {
                        Label("导出为 plist", systemImage: "square.and.arrow.up")
                    }
                    .disabled(wordStore.customWords.isEmpty)

                    Button {
                        exportAllToJSON()
                    } label: {
                        Label("导出为 JSON", systemImage: "doc.text")
                    }
                    .disabled(wordStore.customWords.isEmpty)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddSheet) {
            AddWordSheet(
                phrase: $newWordPhrase,
                shortcut: $newWordShortcut,
                onSave: addWord
            )
        }
        .sheet(isPresented: $showingExportSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
        .fileImporter(
            isPresented: $showingImportPicker,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleJSONImport(result)
        }
    }

    private func addWord() {
        guard !newWordPhrase.isEmpty else { return }

        let entry = WordEntry(
            phrase: newWordPhrase,
            shortcut: newWordShortcut,
            category: .custom
        )
        wordStore.addWord(entry)

        newWordPhrase = ""
        newWordShortcut = ""
        showingAddSheet = false
    }

    private func deleteWords(at offsets: IndexSet) {
        wordStore.removeWords(at: offsets, from: .custom)
    }

    private func exportCustomWords() {
        if let url = wordStore.generatePlist(category: .custom) {
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

    private func handleJSONImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            if url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                wordStore.importFromJSON(url: url)
            }
        case .failure(let error):
            print("Import error: \(error)")
        }
    }
}

// MARK: - Custom Word Row View

struct CustomWordRowView: View {
    let word: WordEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(word.phrase)
                    .font(.body)

                if !word.shortcut.isEmpty {
                    Text("快捷: \(word.shortcut)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text(word.dateAdded, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add Word Sheet

struct AddWordSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var phrase: String
    @Binding var shortcut: String
    let onSave: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("词条内容", text: $phrase)
                        .autocorrectionDisabled()
                } header: {
                    Text("词条")
                } footer: {
                    Text("输入你想要添加到词库的词条")
                }

                Section {
                    TextField("快捷短语（可选）", text: $shortcut)
                        .autocorrectionDisabled()
                } header: {
                    Text("快捷方式")
                } footer: {
                    Text("输入一个简短的快捷短语来触发这个词条")
                }
            }
            .navigationTitle("添加词条")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        onSave()
                    }
                    .disabled(phrase.isEmpty)
                }
            }
        }
    }
}
