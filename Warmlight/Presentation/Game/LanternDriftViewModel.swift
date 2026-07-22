import Foundation

@MainActor
@Observable
final class LanternDriftViewModel {
    private(set) var progress: LanternDriftProgress = .empty
    private(set) var collected: [EmotionColor] = []
    private(set) var sessionCompleted = false

    private let loadProgress: LoadLanternProgressUseCase
    private let completeSession: CompleteLanternDriftUseCase

    init(dependencies: AppDependencies) {
        loadProgress = dependencies.loadLanternProgress
        completeSession = dependencies.completeLanternDrift
    }

    func load() async {
        progress = await loadProgress.execute()
    }

    func collect(_ emotion: EmotionColor) {
        guard !sessionCompleted else { return }
        collected.append(emotion)
    }

    func finish() async {
        guard !sessionCompleted else { return }
        progress = await completeSession.execute(
            session: LanternDriftSession(
                memoriesCollected: collected.count,
                emotionSeeds: collected
            )
        )
        sessionCompleted = true
    }

    func restart() {
        collected = []
        sessionCompleted = false
    }
}
