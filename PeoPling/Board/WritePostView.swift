import SwiftUI
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct WritePostView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authVM: AuthViewModel

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var isUploading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("제목", text: $title)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                TextEditor(text: $content)
                    .frame(height: 200)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))

                // 📷 이미지 선택 미리보기
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                        .cornerRadius(10)
                }

                PhotosPicker(selection: $selectedItem, matching: .images) {
                    HStack {
                        Image(systemName: "photo")
                        Text("이미지 선택")
                    }
                }
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            selectedImage = uiImage
                        }
                    }
                }

                Button("등록") {
                    uploadPost()
                }
                .disabled(title.isEmpty || content.isEmpty || isUploading)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)

                Spacer()
            }
            .padding()
            .navigationTitle("게시글 작성")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }

    // 🧩 업로드 함수
    func uploadPost() {
        isUploading = true
        let db = Firestore.firestore()
        let postsRef = db.collection("posts").document()
        let postId = postsRef.documentID

        if let image = selectedImage {
            uploadImage(image, postId: postId) { imageURL in
                savePost(to: postsRef, imageURL: imageURL)
            }
        } else {
            savePost(to: postsRef, imageURL: nil)
        }
    }

    // 📦 이미지 Storage 업로드
    func uploadImage(_ image: UIImage, postId: String, completion: @escaping (String?) -> Void) {
        guard let data = image.jpegData(compressionQuality: 0.6) else {
            completion(nil)
            return
        }

        let storageRef = Storage.storage().reference()
        let imageRef = storageRef.child("postImages/\(postId).jpg")

        imageRef.putData(data, metadata: nil) { _, error in
            if error != nil {
                completion(nil)
                return
            }

            imageRef.downloadURL { url, _ in
                completion(url?.absoluteString)
            }
        }
    }

    // 📝 Firestore에 게시글 저장
    func savePost(to ref: DocumentReference, imageURL: String?) {
        let postData: [String: Any] = [
            "title": title,
            "content": content,
            "authorId": authVM.currentUserId ?? "unknown",
            "nickname": authVM.currentNickname ?? "익명",
            "createdAt": Timestamp(),
            "imageURL": imageURL ?? ""
        ]

        ref.setData(postData) { error in
            isUploading = false
            if error == nil {
                dismiss()
            }
        }
    }
}
