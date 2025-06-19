import Foundation
import FirebaseFirestore

struct Comment: Identifiable {
    let id: String
    let authorId: String
    let nickname: String
    let content: String
    let createdAt: Date

    init?(from document: DocumentSnapshot) {
        guard let data = document.data(),
              let authorId = data["authorId"] as? String,
              let nickname = data["nickname"] as? String,
              let content = data["content"] as? String,
              let timestamp = data["createdAt"] as? Timestamp else {
            return nil
        }

        self.id = document.documentID
        self.authorId = authorId
        self.nickname = nickname
        self.content = content
        self.createdAt = timestamp.dateValue()
    }
}
