import Foundation

/// One day's worth of warmth — used to plot "moments per day".
struct DayWarmth: Identifiable, Sendable {
    let id = UUID()
    let date: Date
    let count: Int
}

/// How many moments were tagged with a given emotion in the period.
struct EmotionDistribution: Identifiable, Sendable {
    let id = UUID()
    let emotion: EmotionColor
    let count: Int
}

/// Light analytics summary for the Dashboard's "week of warmth" view.
struct WeekOfWarmthSummary: Sendable {
    let dailyCounts: [DayWarmth]
    let emotionDistribution: [EmotionDistribution]
    let totalMoments: Int
    let currentStreakDays: Int
}

/// Builds the "week of warmth" analytics: a 7-day moment count and an
/// emotion-color breakdown over the same window.
@MainActor
final class WeekOfWarmthUseCase {
    private let moments: MomentRepository
    private let calendar = Calendar.current

    init(moments: MomentRepository) {
        self.moments = moments
    }

    func execute(referenceDate: Date = .now) async throws -> WeekOfWarmthSummary {
        let all = try await moments.fetchAll()
        let today = calendar.startOfDay(for: referenceDate)

        let last7Days: [Date] = (0..<7).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)
        }.reversed()

        let dailyCounts = last7Days.map { day -> DayWarmth in
            let count = all.filter { calendar.isDate($0.createdAt, inSameDayAs: day) }.count
            return DayWarmth(date: day, count: count)
        }

        let windowStart = last7Days.first ?? today
        let recentMoments = all.filter { $0.createdAt >= windowStart }
        let distribution = EmotionColor.allCases.compactMap { emotion -> EmotionDistribution? in
            let count = recentMoments.filter { $0.emotion == emotion }.count
            guard count > 0 else { return nil }
            return EmotionDistribution(emotion: emotion, count: count)
        }

        return WeekOfWarmthSummary(
            dailyCounts: dailyCounts,
            emotionDistribution: distribution,
            totalMoments: all.count,
            currentStreakDays: currentStreak(in: all, today: today)
        )
    }

    private func currentStreak(in moments: [Moment], today: Date) -> Int {
        var streak = 0
        var day = today
        while moments.contains(where: { calendar.isDate($0.createdAt, inSameDayAs: day) }) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return streak
    }
}
