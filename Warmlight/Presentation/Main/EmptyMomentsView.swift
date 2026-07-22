import SwiftUI

/// Shown when the feed has no moments yet — exact spec copy.
struct EmptyMomentsView: View {
    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 44, weight: .light))
                .foregroundStyle(AppColor.text.opacity(0.4))

            Text("The garden is quiet. Save your first warm moment and light the path.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.text.opacity(0.75))
                .padding(.horizontal, 40)
        }
    }
}

#Preview {
    EmptyMomentsView()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
}
