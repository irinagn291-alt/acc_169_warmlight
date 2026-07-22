import SwiftData
import SwiftUI

/// Switches between onboarding and the main tab flow, building
/// `AppDependencies` once the model context becomes available.
struct RootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("warmlight.appearanceMode") private var appearanceModeRaw = AppearanceMode.system.rawValue
    @Environment(\.modelContext) private var modelContext
    @State private var dependencies: AppDependencies?

    var body: some View {
        content
            .tint(AppColor.accent)
            .preferredColorScheme(AppearanceMode(rawValue: appearanceModeRaw)?.colorScheme)
            .task {
                if dependencies == nil {
                    dependencies = AppDependencies(modelContext: modelContext)
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if let dependencies {
            if hasCompletedOnboarding {
                MainTabView(dependencies: dependencies)
            } else {
                OnboardingView(
                    dependencies: dependencies,
                    onFinish: { hasCompletedOnboarding = true }
                )
                .adaptiveReadableWidth(640)
            }
        } else {
            ZStack {
                AppColor.background.ignoresSafeArea()
                ProgressView().tint(AppColor.accent)
            }
        }
    }
}

#Preview {
    RootView()
        .modelContainer(PreviewSupport.container)
}
