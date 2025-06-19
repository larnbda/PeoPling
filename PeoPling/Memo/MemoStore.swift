import Foundation

class MemoStore: ObservableObject {
    @Published var memos: [Memo] = []

    private let fileName = "memos.json"

    init() {
        loadMemos()
    }



    func addMemo(content: String) {
        let newMemo = Memo(content: content)
        memos.insert(newMemo, at: 0)
        saveMemos()
    }

    func updateMemo(_ memo: Memo, newContent: String) {
        if let index = memos.firstIndex(of: memo) {
            memos[index].content = newContent
            memos[index].updatedAt = Date()
            saveMemos()
        }
    }

    func deleteMemo(_ memo: Memo) {
        memos.removeAll { $0.id == memo.id }
        saveMemos()
    }



    private func getFileURL() -> URL {
        let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDir.appendingPathComponent(fileName)
    }

    func saveMemos() {
        let url = getFileURL()
        do {
            let data = try JSONEncoder().encode(memos)
            try data.write(to: url)
        } catch {
            print("💥 메모 저장 실패: \(error)")
        }
    }

    func loadMemos() {
        let url = getFileURL()
        do {
            let data = try Data(contentsOf: url)
            memos = try JSONDecoder().decode([Memo].self, from: data)
        } catch {
            memos = []  // 없으면 빈 배열로 시작
        }
    }
}
