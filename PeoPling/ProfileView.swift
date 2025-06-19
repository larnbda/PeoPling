import SwiftUI
import FirebaseFirestore

struct ProfileView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var newNickname: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 상단 로고
                PeoplingHeader()

                Text("프로필")
                    .font(.largeTitle)
                    .bold()

                HStack {
                    Text("닉네임:")
                    Text(authVM.currentNickname ?? "불러오는 중")
                        .fontWeight(.semibold)
                }

                TextField("새 닉네임", text: $newNickname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)

                Button("닉네임 변경") {
                    updateNickname()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)

                Button("로그아웃") {
                    authVM.logout()
                }
                .foregroundColor(.red)
                .padding(.top, 30)

                Spacer()
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text(alertMessage))
            }
            .navigationBarHidden(true)
        }
    }

    func updateNickname() {
        guard let uid = authVM.currentUserId else { return }
        guard !newNickname.trimmingCharacters(in: .whitespaces).isEmpty else {
            alertMessage = "닉네임을 입력해주세요."
            showAlert = true
            return
        }

        let db = Firestore.firestore()
        db.collection("users").document(uid).updateData([
            "nickname": newNickname
        ]) { error in
            if let error = error {
                alertMessage = "오류: \(error.localizedDescription)"
            } else {
                authVM.currentNickname = newNickname
                alertMessage = "닉네임이 변경되었습니다."
                newNickname = ""
            }
            showAlert = true
        }
    }
}
