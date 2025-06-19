import Foundation
import FirebaseFirestore

struct Post: Identifiable {
    let id: String
    let title: String
    let content: String
    let authorId: String
    let nickname: String
    let createdAt: Date
    let imageURL: String?

    //좋아요 관련 필드
    var likeCount: Int = 0
    var isLikedByMe: Bool = false

    init?(from document: DocumentSnapshot) {
        guard let data = document.data(),
              let title = data["title"] as? String,
              let content = data["content"] as? String,
              let authorId = data["authorId"] as? String,
              let nickname = data["nickname"] as? String,
              let timestamp = data["createdAt"] as? Timestamp else {
            return nil
        }

        self.id = document.documentID
        self.title = title
        self.content = content
        self.authorId = authorId
        self.nickname = nickname
        self.createdAt = timestamp.dateValue()
        self.imageURL = data["imageURL"] as? String
    }
}
