import SwiftUI

struct CityListView: View {
    @ObservedObject var wordStore: WordStore
    @State private var searchText = ""
    @State private var showingExportSheet = false
    @State private var exportURL: URL?

    var filteredCities: [WordEntry] {
        if searchText.isEmpty {
            return wordStore.cities
        }
        return wordStore.cities.filter { city in
            city.phrase.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        List {
            Section {
                ForEach(filteredCities) { city in
                    CityRowView(city: city)
                }
            } header: {
                HStack {
                    Text("城市列表")
                    Spacer()
                    Text("\(wordStore.cities.count) 个")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .searchable(text: $searchText, prompt: "搜索城市")
        .navigationTitle("城市")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    exportCities()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
                .disabled(wordStore.cities.isEmpty)
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    private func exportCities() {
        if let url = wordStore.generatePlist(category: .cities) {
            exportURL = url
            showingExportSheet = true
        }
    }
}

// MARK: - City Row View

struct CityRowView: View {
    let city: WordEntry

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(city.phrase)
                    .font(.body)
            }

            Spacer()

            Text(city.dateAdded, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
