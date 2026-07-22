import Foundation

@MainActor
final class LoadLanternProgressUseCase {
    private let repository: LanternProgressRepository

    init(repository: LanternProgressRepository) {
        self.repository = repository
    }

    func execute() async -> LanternDriftProgress {
        await repository.load()
    }
}

@MainActor
final class CompleteLanternDriftUseCase {
    private let repository: LanternProgressRepository

    init(repository: LanternProgressRepository) {
        self.repository = repository
    }

    func execute(session: LanternDriftSession, date: Date = .now) async -> LanternDriftProgress {
        var progress = await repository.load()
        progress.sessions += 1
        progress.memoriesCollected += session.memoriesCollected
        progress.lastPlayedAt = date
        for emotion in session.emotionSeeds {
            progress.emotionSeeds[emotion.rawValue, default: 0] += 1
        }
        await repository.save(progress)
        return progress
    }
}
