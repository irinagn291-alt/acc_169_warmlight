import SwiftUI

/// Root tab container shown once onboarding is complete: moments,
/// week-of-warmth dashboard and settings.
struct MainTabView: View {
    let dependencies: AppDependencies

    @State private var momentsViewModel: MomentsViewModel
    @State private var dashboardViewModel: DashboardViewModel
    @State private var settingsViewModel: SettingsViewModel
    @State private var coordinator = AppCoordinator()

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _momentsViewModel = State(initialValue: MomentsViewModel(dependencies: dependencies))
        _dashboardViewModel = State(initialValue: DashboardViewModel(dependencies: dependencies))
        _settingsViewModel = State(initialValue: SettingsViewModel(dependencies: dependencies))
    }

    var body: some View {
        TabView(selection: $coordinator.selectedTab) {
            MainCarouselView(viewModel: momentsViewModel, dependencies: dependencies)
                .tabItem { Label("Moments", systemImage: "sparkles") }
                .tag(AppCoordinator.Tab.moments)

            DashboardView(viewModel: dashboardViewModel)
                .tabItem { Label("Garden", systemImage: "leaf.fill") }
                .tag(AppCoordinator.Tab.garden)

            LanternDriftView(dependencies: dependencies)
                .tabItem { Label("Drift", systemImage: "paperplane.fill") }
                .tag(AppCoordinator.Tab.drift)

            SettingsView(viewModel: settingsViewModel)
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                .tag(AppCoordinator.Tab.settings)
        }
        .tint(AppColor.accent)
    }
}

#Preview {
    MainTabView(dependencies: PreviewSupport.dependencies)
}
