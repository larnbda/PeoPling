import SwiftUI
import FirebaseFirestore

struct BoardView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var posts: [Post] = []
    @State private var commentCounts: [String: Int] = [:]
    @State private var likeCounts: [String: Int] = [:]
    @State private var likedPostIds: Set<String> = []
    @State private var searchText: String = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                //상단 로고
                PeoplingHeader()

                // 🔍 검색창
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("제목 검색", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // 📋 게시글 리스트
                List(filteredPosts) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(post.title)
                                    .font(.headline)
                                if let url = post.imageURL, !url.isEmpty {
                                    Image(systemName: "photo.on.rectangle")
                                        .foregroundColor(.blue)
                                }
                            }

                            HStack {
                                Text(post.nickname)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(formattedDate(post.createdAt))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }

                            HStack(spacing: 12) {
                                HStack {
                                    Image(systemName: "heart")
                                        .foregroundColor(.gray)
                                    Text("\(likeCounts[post.id] ?? 0)")
                                        .font(.footnote)
                                }

                                HStack {
                                    Image(systemName: "bubble.right")
                                    Text("\(commentCounts[post.id] ?? 0)")
                                        .font(.footnote)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: WritePostView()) {
                        Text("글쓰기")
                            .fontWeight(.semibold)
                    }
                }
            }
            .onAppear {
                setupPostListener()
            }
        }
    }

    var filteredPosts: [Post] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return posts
        } else {
            return posts.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    func setupPostListener() {
        let db = Firestore.firestore()
        db.collection("posts")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else { return }
                var fetchedPosts: [Post] = []

                for doc in documents {
                    if let post = Post(from: doc) {
                        fetchedPosts.append(post)
                        fetchCommentCount(for: post)
                        fetchLikeCount(for: post)
                        fetchLikeStatus(for: post)
                    }
                }

                posts = fetchedPosts
            }
    }

    func fetchCommentCount(for post: Post) {
        let db = Firestore.firestore()
        db.collection("posts")
            .document(post.id)
            .collection("comments")
            .addSnapshotListener { snapshot, _ in
                commentCounts[post.id] = snapshot?.count ?? 0
            }
    }

    func fetchLikeCount(for post: Post) {
        let db = Firestore.firestore()
        db.collection("posts")
            .document(post.id)
            .collection("likes")
            .addSnapshotListener { snapshot, _ in
                likeCounts[post.id] = snapshot?.count ?? 0
            }
    }

    func fetchLikeStatus(for post: Post) {
        guard let uid = authVM.currentUserId else { return }
        let db = Firestore.firestore()
        db.collection("posts")
            .document(post.id)
            .collection("likes")
            .document(uid)
            .addSnapshotListener { doc, _ in
                if doc?.exists == true {
                    likedPostIds.insert(post.id)
                } else {
                    likedPostIds.remove(post.id)
                }
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
