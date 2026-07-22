import SwiftUI

/// Page 4 of onboarding — "Your first moment today": a small form so the
/// very first warm moment is captured before the user ever sees the feed.
struct FirstMomentPageView: View {
    @Bindable var viewModel: OnboardingViewModel
    let onFinish: () -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Your first moment today")
                    .font(.system(.title, design: .serif).weight(.semibold))
                    .foregroundStyle(AppColor.text)
                    .padding(.top, 24)

                Text("What warmed you today? A tiny detail is enough.")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.text.opacity(0.75))

                TextField(
                    "For example: morning coffee in the sunlight…",
                    text: $viewModel.firstMomentText,
                    axis: .vertical
                )
                .lineLimit(3...6)
                .padding(16)
                .background(AppColor.surface)
                .foregroundStyle(AppColor.text)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))

                EmotionPickerView(selection: $viewModel.firstMomentEmotion)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(AppColor.primary)
                }

                Spacer(minLength: 12)

                Button {
                    Task {
                        if await viewModel.saveFirstMoment() {
                            onFinish()
                        }
                    }
                } label: {
                    if viewModel.isSaving {
                        ProgressView().tint(AppColor.background)
                    } else {
                        Text(viewModel.lastPageCTA)
                    }
                }
                .buttonStyle(WarmPrimaryButtonStyle())
                .disabled(viewModel.isSaving)

                Text("Warmlight is not a substitute for professional care.")
                    .font(.caption2)
                    .foregroundStyle(AppColor.text.opacity(0.5))
                    .padding(.bottom, 24)
            }
            .padding(.horizontal, 28)
        }
        .background(AppColor.background)
    }
}

#Preview {
    FirstMomentPageView(
        viewModel: OnboardingViewModel(dependencies: PreviewSupport.dependencies),
        onFinish: {}
    )
}
