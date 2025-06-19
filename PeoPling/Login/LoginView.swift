import SwiftUI
import FirebaseFirestore

struct LoginView: View {
    @EnvironmentObject var authVM: AuthViewModel

    @State private var userId = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSignUp = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Text("로그인")
                .font(.largeTitle)
                .bold()

            TextField("사용자 ID", text: $userId)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("비밀번호", text: $password)
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(8)

            Button("로그인") {
                authVM.login(userId: userId, password: password) { message in
                    alertMessage = message
                    showAlert = true
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button(action: {
                showSignUp = true
            }) {
                Text("회원이 아니신가요?")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .underline()
            }
            .padding(.top, 10)

            Spacer()
        }
        .padding()
        .sheet(isPresented: $showSignUp) {
            SignUpView()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertMessage))
        }
    }
}
