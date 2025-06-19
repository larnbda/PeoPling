import SwiftUI

struct EditMemoView: View {
    @Environment(\.dismiss) var dismiss

    var memo: Memo?
    @ObservedObject var memoStore: MemoStore

    @State private var content: String = ""

    var body: some View {
        NavigationView {
            VStack {
                TextEditor(text: $content)
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.3)))
                    .navigationTitle(memo == nil ? "새 메모" : "메모 수정")
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("저장") {
                                saveMemo()
                            }
                        }
                        ToolbarItem(placement: .cancellationAction) {
                            Button("취소") {
                                dismiss()
                            }
                        }
                    }
            }
            .padding()
            .onAppear {
                if let memo = memo {
                    content = memo.content
                }
            }
        }
    }

    func saveMemo() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            dismiss()
            return
        }

        if let memo = memo {
            memoStore.updateMemo(memo, newContent: trimmed)
        } else {
            memoStore.addMemo(content: trimmed)
        }
        dismiss()
    }
}
