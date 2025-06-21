import SwiftUI
import FirebaseFirestore
import FirebaseStorage

struct PostDetailView: View {
    let post: Post
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var comments: [Comment] = []
    @State private var newComment: String = ""
    @State private var isLoading = true
    @State private var showDeleteAlert = false

    // 좋아요 상태
    @State private var isLiked = false
    @State private var likeCount = 0

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text(post.title)
                            .font(.title)
                            .bold()

                        HStack {
                            Text("작성자: \(post.nickname)")
                            Spacer()
                            Text(formattedDate(post.createdAt))
                                .font(.footnote)
                                .foregroundColor(.gray)
                        }

                        Divider()

                        Text(post.content)
                            .font(.body)

                        if let imageURL = post.imageURL, !imageURL.isEmpty {
                            AsyncImage(url: URL(string: imageURL)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxHeight: 300)
                            .cornerRadius(8)
                        }

                        // 좋아요 버튼
                        HStack {
                            Button(action: {
                                toggleLike()
                            }) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")
                                    .foregroundColor(isLiked ? .red : .gray)
                            }
                            Text("\(likeCount)")
                        }

                        Divider()

                        Text("댓글")
                            .font(.headline)

                        if isLoading {
                            ProgressView()
                        } else if comments.isEmpty {
                            Text("아직 댓글이 없습니다.")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(comments) { comment in
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text(comment.nickname)
                                            .fontWeight(.semibold)
                                        Spacer()
                                        Text(formattedDate(comment.createdAt))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Text(comment.content)

                                    if comment.authorId == authVM.currentUserId {
                                        Button(role: .destructive) {
                                            deleteComment(comment)
                                        } label: {
                                            Text("삭제")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                    }
                                }
                                .padding(.vertical, 6)
                                Divider()
                            }
                        }
                    }
                    .padding()
                }

                HStack {
                    TextField("댓글을 입력하세요", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("등록") {
                        addComment()
                    }
                    .disabled(newComment.trimmingCharacters(in: .whitespaces).isEmpty)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("게시글")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") {
                        dismiss()
                    }
                }

                if post.authorId == authVM.currentUserId {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(role: .destructive) {
                            showDeleteAlert = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }
            }
            .alert("정말 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                Button("삭제", role: .destructive) {
                    deletePost()
                }
                Button("취소", role: .cancel) {}
            }
            .onAppear {
                loadComments()
                fetchLikeStatus()
                fetchLikeCount()
            }
        }
    }

    func loadComments() {
        isLoading = true
        Firestore.firestore()
            .collection("posts")
            .document(post.id)
            .collection("comments")
            .order(by: "createdAt")
            .getDocuments { snapshot, error in
                if let documents = snapshot?.documents {
                    comments = documents.compactMap { Comment(from: $0) }
                } else {
                    comments = []
                }
                isLoading = false
            }
    }

    func addComment() {
        let commentData: [String: Any] = [
            "authorId": authVM.currentUserId ?? "unknown",
            "nickname": authVM.currentNickname ?? "익명",
            "content": newComment,
            "createdAt": Timestamp()
        ]

        Firestore.firestore()
            .collection("posts")
            .document(post.id)
            .collection("comments")
            .addDocument(data: commentData) { error in
                if error == nil {
                    newComment = ""
                    loadComments()
                }
            }
    }

    func deleteComment(_ comment: Comment) {
        Firestore.firestore()
            .collection("posts")
            .document(post.id)
            .collection("comments")
            .document(comment.id)
            .delete { _ in
                loadComments()
            }
    }

    func deletePost() {
        let db = Firestore.firestore()
        if let imageURL = post.imageURL, !imageURL.isEmpty {
            let storageRef = Storage.storage().reference(forURL: imageURL)
            storageRef.delete { error in
                if let error = error {
                    print("❗️이미지 삭제 실패: \(error.localizedDescription)")
                }
            }
        }
        db.collection("posts").document(post.id).delete { error in
            if error == nil {
                dismiss()
            }
        }
    }

    func toggleLike() {
        guard let uid = authVM.currentUserId else { return }
        let ref = Firestore.firestore().collection("posts").document(post.id).collection("likes").document(uid)

        if isLiked {
            ref.delete()
        } else {
            ref.setData([:]) // 좋아요 추가
        }
    }

    func fetchLikeStatus() {
        guard let uid = authVM.currentUserId else { return }
        let ref = Firestore.firestore().collection("posts").document(post.id).collection("likes").document(uid)
        ref.addSnapshotListener { doc, _ in
            isLiked = doc?.exists == true
        }
    }

    func fetchLikeCount() {
        let ref = Firestore.firestore().collection("posts").document(post.id).collection("likes")
        ref.addSnapshotListener { snap, _ in
            likeCount = snap?.count ?? 0
        }
    }

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
