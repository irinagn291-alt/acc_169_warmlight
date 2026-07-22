import Foundation

@MainActor
final class LivingGardenUseCase {
    private let moments: MomentRepository
    private let progress: LanternProgressRepository
    private let calendar: Calendar

    init(
        moments: MomentRepository,
        progress: LanternProgressRepository,
        calendar: Calendar = .current
    ) {
        self.moments = moments
        self.progress = progress
        self.calendar = calendar
    }

    func execute(referenceDate: Date = .now) async throws -> LivingGardenSummary {
        let all = try await moments.fetchAll()
        let drift = await progress.load()
        let distribution = EmotionColor.allCases.compactMap { emotion in
            let count = all.count { $0.emotion == emotion }
            return count == 0 ? nil : EmotionDistribution(emotion: emotion, count: count)
        }
        let days = Set(all.map { calendar.startOfDay(for: $0.createdAt) })

        return LivingGardenSummary(
            moments: all,
            emotionDistribution: distribution,
            activeDays: days.count,
            gentleStreakDays: streak(in: days, referenceDate: referenceDate),
            photoCount: all.count(where: \.hasPhoto),
            voiceCount: all.count(where: \.hasVoiceNote),
            resurfacedMemories: min(all.count, drift.sessions),
            openedCapsules: all.count { $0.createdAt < referenceDate.addingTimeInterval(-30 * 86_400) },
            driftProgress: drift
        )
    }

    private func streak(in days: Set<Date>, referenceDate: Date) -> Int {
        var date = calendar.startOfDay(for: referenceDate)
        if !days.contains(date), let yesterday = calendar.date(byAdding: .day, value: -1, to: date) {
            date = yesterday
        }
        var count = 0
        while days.contains(date) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: date) else { break }
            date = previous
        }
        return count
    }
}
