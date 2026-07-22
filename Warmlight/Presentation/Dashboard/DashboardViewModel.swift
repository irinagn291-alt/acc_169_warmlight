import Foundation

@MainActor
@Observable
final class DashboardViewModel {
    private(set) var summary: LivingGardenSummary?
    private(set) var isLoading = false
    var errorMessage: String?

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            summary = try await dependencies.livingGarden.execute()
        } catch {
            errorMessage = "The garden could not be refreshed."
        }
    }
}
