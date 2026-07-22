import Foundation

/// Drives the 4-screen onboarding flow, including saving the very first
/// moment the user writes on the last screen.
@MainActor
@Observable
final class OnboardingViewModel {
    var pageIndex = 0
    var firstMomentText = ""
    var firstMomentEmotion: EmotionColor = .gratitude
    private(set) var isSaving = false
    var errorMessage: String?

    private let dependencies: AppDependencies

    let lastPageCTA = "Seal the light"

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    var isOnLastPage: Bool { pageIndex == 3 }

    func advance() {
        guard pageIndex < 3 else { return }
        pageIndex += 1
    }

    func saveFirstMoment() async -> Bool {
        let trimmed = firstMomentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Write a few words to hold this moment."
            return false
        }

        isSaving = true
        defer { isSaving = false }
        do {
            _ = try await dependencies.saveMoment.execute(
                text: trimmed,
                emotion: firstMomentEmotion,
                photoData: nil,
                voiceNoteData: nil
            )
            dependencies.haptics.warmGlow()
            return true
        } catch {
            errorMessage = "The moment could not be saved. Please try again."
            return false
        }
    }
}
