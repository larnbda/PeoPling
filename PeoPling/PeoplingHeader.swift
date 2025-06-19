import SwiftUI

struct PeoplingHeader: View {
    var body: some View {
        HStack {
            Image("peoplingLogo")
                .resizable()
                .scaledToFill()
                .frame(height: 60)
                .padding(.leading, 16)

            Spacer()
        }
        .padding(.top, 16)
    }
}
