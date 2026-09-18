import SwiftUI

struct ExportView: View {
    @ObservedObject var wordStore: WordStore
    @State private var selectedCategory: WordCategory = .cities
    @State private var showingShareSheet = false
    @State private var exportURL: URL?

    var body: some View {
        List {
            Section {
                Picker("分类", selection: $selectedCategory) {
                    ForEach(WordCategory.allCases, id: \.self) { category in
                        Text(category.rawValue).tag(category)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                Text("选择词库分类")
            }

            Section {
                wordCountSection
            } header: {
                Text("词条数量")
            }

            Section {
                Button {
                    exportPlist()
                } label: {
                    Label("导出 plist 文件", systemImage: "doc.badge.arrow.up")
                }
                .disabled(wordCount == 0)

                Button {
                    exportJSON()
                } label: {
                    Label("导出 JSON 文件", systemImage: "doc.text")
                }
                .disabled(wordCount == 0)
            } header: {
                Text("导出操作")
            }

            Section {
                instructionSection
            } header: {
                Text("iOS 导入说明")
            }
        }
        .navigationTitle("导出")
        .sheet(isPresented: $showingShareSheet) {
            if let url = exportURL {
                ShareSheet(items: [url])
            }
        }
    }

    private var wordCount: Int {
        wordStore.words(for: selectedCategory).count
    }

    private var wordCountSection: some View {
        HStack {
            Text(selectedCategory.rawValue)
            Spacer()
            Text("\(wordCount) 个词条")
                .foregroundColor(.secondary)
        }
    }

    private var instructionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            InstructionStep(number: 1, text: "点击上方「导出 plist 文件」按钮")
            InstructionStep(number: 2, text: "在分享菜单中选择「存储到文件」")
            InstructionStep(number: 3, text: "打开「设置」>「通用」>「键盘」>「键盘」")
            InstructionStep(number: 4, text: "点击「自定义短语」或「文本替换」")
            InstructionStep(number: 5, text: "点击右上角「+」号，选择「导入短语…」")
            InstructionStep(number: 6, text: "选择导出的 plist 文件完成导入")
        }
        .padding(.vertical, 8)
    }

    private func exportPlist() {
        if let url = wordStore.generatePlist(category: selectedCategory) {
            exportURL = url
            showingShareSheet = true
        }
    }

    private func exportJSON() {
        if let url = wordStore.exportToJSON() {
            exportURL = url
            showingShareSheet = true
        }
    }
}

// MARK: - Instruction Step

struct InstructionStep: View {
    let number: Int
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("\(number)")
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 24, height: 24)
                .background(Color.accentColor)
                .clipShape(Circle())

            Text(text)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}
