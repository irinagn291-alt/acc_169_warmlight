import Foundation

/// Backs the Settings screen: appearance, evening notifications, export
/// and reset.
@MainActor
@Observable
final class SettingsViewModel {
    var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: Self.appearanceKey) }
    }

    var eveningPromptEnabled: Bool {
        didSet { handleEveningPromptToggle() }
    }

    var eveningPromptTime: Date {
        didSet {
            UserDefaults.standard.set(eveningPromptTime, forKey: Self.promptTimeKey)
            if eveningPromptEnabled {
                Task { await scheduleEveningPrompt() }
            }
        }
    }

    private(set) var availableYears: [Int] = []
    var selectedCollageYear: Int?
    var isExporting = false
    var statusMessage: String?
    var isShowingResetConfirmation = false

    private let dependencies: AppDependencies

    private static let appearanceKey = "warmlight.appearanceMode"
    private static let promptEnabledKey = "warmlight.eveningPromptEnabled"
    private static let promptTimeKey = "warmlight.eveningPromptTime"

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies

        let storedAppearance = UserDefaults.standard.string(forKey: Self.appearanceKey)
        appearanceMode = AppearanceMode(rawValue: storedAppearance ?? "") ?? .system

        eveningPromptEnabled = UserDefaults.standard.bool(forKey: Self.promptEnabledKey)

        if let storedTime = UserDefaults.standard.object(forKey: Self.promptTimeKey) as? Date {
            eveningPromptTime = storedTime
        } else {
            eveningPromptTime = Calendar.current.date(
                bySettingHour: 20, minute: 0, second: 0, of: .now
            ) ?? .now
        }
    }

    func loadAvailableYears() async {
        availableYears = (try? await dependencies.lightOfTheYear.availableYears()) ?? []
        if selectedCollageYear == nil {
            selectedCollageYear = availableYears.first
        }
    }

    func momentsForCollage() async -> [Moment] {
        guard let year = selectedCollageYear else { return [] }
        return (try? await dependencies.lightOfTheYear.execute(year: year)) ?? []
    }

    func resetAllData() async {
        do {
            for moment in try await dependencies.fetchMoments.execute() {
                try await dependencies.deleteMoment.execute(moment)
            }
            statusMessage = "All moments were deleted."
        } catch {
            statusMessage = "The data could not be deleted."
        }
    }

    private func handleEveningPromptToggle() {
        UserDefaults.standard.set(eveningPromptEnabled, forKey: Self.promptEnabledKey)
        Task {
            if eveningPromptEnabled {
                let granted = await dependencies.notificationService.requestAuthorization()
                if granted {
                    await scheduleEveningPrompt()
                } else {
                    eveningPromptEnabled = false
                    statusMessage = "Allow notifications in iOS Settings to receive evening prompts."
                }
            } else {
                dependencies.notificationService.cancelEveningPrompt()
            }
        }
    }

    private func scheduleEveningPrompt() async {
        let components = Calendar.current.dateComponents([.hour, .minute], from: eveningPromptTime)
        await dependencies.notificationService.scheduleEveningPrompt(
            hour: components.hour ?? 20,
            minute: components.minute ?? 0
        )
    }
}
