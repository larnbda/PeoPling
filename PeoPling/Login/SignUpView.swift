import SwiftUI
import FirebaseFirestore

struct SignUpView: View {
    @Environment(\.dismiss) var dismiss

    @State private var userId = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var nickname = ""
    @State private var message = ""
    @State private var showAlert = false

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("회원가입")
                    .font(.largeTitle).bold()

                Group {
                    TextField("사용자 ID", text: $userId)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    SecureField("비밀번호", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    SecureField("비밀번호 확인", text: $confirmPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextField("닉네임", text: $nickname)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }

                Button("가입하기") {
                    signUp()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text(message))
            }
        }
    }

    func signUp() {
        guard !userId.isEmpty, !password.isEmpty, !nickname.isEmpty else {
            message = "모든 필드를 입력하세요."
            showAlert = true
            return
        }

        guard password == confirmPassword else {
            message = "비밀번호가 일치하지 않습니다."
            showAlert = true
            return
        }

        let db = Firestore.firestore()

        // 중복 ID 확인
        db.collection("users").whereField("userId", isEqualTo: userId).getDocuments { snapshot, error in
            if let error = error {
                message = "오류: \(error.localizedDescription)"
                showAlert = true
                return
            }

            if let documents = snapshot?.documents, !documents.isEmpty {
                message = "이미 사용 중인 ID입니다."
                showAlert = true
                return
            }

            let userData: [String: Any] = [
                "userId": userId,
                "password": password, // 해시 적용은 추후
                "nickname": nickname,
                "createdAt": Timestamp()
            ]

            db.collection("users").addDocument(data: userData) { error in
                if let error = error {
                    message = "회원가입 실패: \(error.localizedDescription)"
                } else {
                    message = "회원가입 완료!"
                    dismiss() // 로그인 화면으로 돌아가기
                }
                showAlert = true
            }
        }
    }
}
