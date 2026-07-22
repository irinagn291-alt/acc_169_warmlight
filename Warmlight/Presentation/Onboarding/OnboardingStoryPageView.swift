import SwiftUI

/// A single full-bleed "emotional-story" onboarding screen (pages 1-3).
struct OnboardingStoryPageView: View {
    let page: OnboardingPage
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [AppColor.primary, AppColor.secondary, AppColor.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 160, height: 160)
                    .warmGlow(color: AppColor.primary, radius: 28)

                Image(systemName: page.symbolName)
                    .font(.system(size: 56, weight: .light))
                    .foregroundStyle(AppColor.text)
            }

            Text(page.title)
                .font(.system(.title, design: .serif).weight(.semibold))
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.text)
                .padding(.horizontal, 32)

            Spacer()

            Button(page.ctaTitle, action: onContinue)
                .buttonStyle(WarmPrimaryButtonStyle())
                .padding(.horizontal, 32)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background)
    }
}

#Preview {
    OnboardingStoryPageView(page: OnboardingPage.storyPages[0], onContinue: {})
}
