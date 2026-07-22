import SwiftUI

/// Horizontal row of emotion-color chips, shared by the moment-creation
/// form and the onboarding "first moment" page.
struct EmotionPickerView: View {
    @Binding var selection: EmotionColor

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("What color is this light?")
                .font(.caption)
                .foregroundStyle(AppColor.text.opacity(0.7))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(EmotionColor.allCases) { emotion in
                        chip(for: emotion)
                    }
                }
            }
        }
    }

    private func chip(for emotion: EmotionColor) -> some View {
        let isSelected = emotion == selection
        return Button {
            selection = emotion
        } label: {
            HStack(spacing: 6) {
                Image(systemName: emotion.symbolName)
                Text(emotion.displayName)
            }
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? AppColor.background : AppColor.text)
            .background(isSelected ? emotion.color : AppColor.surface)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    @Previewable @State var emotion: EmotionColor = .joy
    EmotionPickerView(selection: $emotion)
        .padding()
        .background(AppColor.background)
}
