import SwiftUI

struct MemoView: View {
    @StateObject private var memoStore = MemoStore()
    @State private var showNewMemo = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                //상단 로고
                PeoplingHeader()

                List {
                    ForEach(memoStore.memos) { memo in
                        NavigationLink(destination: EditMemoView(memo: memo, memoStore: memoStore)) {
                            VStack(alignment: .leading) {
                                Text(memo.content)
                                    .lineLimit(1)
                                Text(formattedDate(memo.updatedAt))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .onDelete { indexSet in
                        indexSet.forEach { i in
                            memoStore.deleteMemo(memoStore.memos[i])
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showNewMemo = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewMemo) {
                EditMemoView(memo: nil, memoStore: memoStore)
            }
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
