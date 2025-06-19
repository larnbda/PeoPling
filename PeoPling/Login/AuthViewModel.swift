import Foundation
import FirebaseFirestore

class AuthViewModel: ObservableObject {
    @Published var isLoggedIn = false
    @Published var currentUserId: String?
    @Published var currentNickname: String?

    func login(userId: String, password: String, onError: @escaping (String) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { snapshot, error in
                if let error = error {
                    onError("오류: \(error.localizedDescription)")
                    return
                }

                guard let doc = snapshot?.documents.first,
                      let storedPw = doc["password"] as? String,
                      storedPw == password else {
                    onError("ID 또는 비밀번호가 올바르지 않습니다.")
                    return
                }

                DispatchQueue.main.async {
                    self.currentUserId = doc.documentID
                    self.currentNickname = doc["nickname"] as? String
                    self.isLoggedIn = true
                }
            }
    }

    func logout() {
        isLoggedIn = false
        currentUserId = nil
        currentNickname = nil
    }
}
