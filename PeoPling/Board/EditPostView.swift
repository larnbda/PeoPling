import SwiftUI
import FirebaseFirestore

struct EditPostView: View {
    @Environment(\.dismiss) var dismiss

    let post: Post
    @State private var title: String
    @State private var content: String

    init(post: Post) {
        self.post = post
        _title = State(initialValue: post.title)
        _content = State(initialValue: post.content)
    }

    var body: some View {
        VStack(spacing: 20) {
            TextField("제목", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextEditor(text: $content)
                .frame(height: 200)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

            Button("수정 완료") {
                updatePost()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            Spacer()
        }
        .padding()
        .navigationTitle("게시글 수정")
        .navigationBarTitleDisplayMode(.inline)
    }

    func updatePost() {
        let db = Firestore.firestore()
        db.collection("posts").document(post.id).updateData([
            "title": title,
            "content": content
        ]) { error in
            if error == nil {
                dismiss()
            }
        }
    }
}

