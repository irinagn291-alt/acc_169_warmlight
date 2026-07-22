import Foundation

/// Gathers every moment from a given year, oldest first, for the
/// "light of the year" collage export.
@MainActor
final class LightOfTheYearUseCase {
    private let moments: MomentRepository
    private let calendar = Calendar.current

    init(moments: MomentRepository) {
        self.moments = moments
    }

    func execute(year: Int) async throws -> [Moment] {
        let all = try await moments.fetchAll()
        return all
            .filter { calendar.component(.year, from: $0.createdAt) == year }
            .sorted { $0.createdAt < $1.createdAt }
    }

    /// Years for which at least one moment exists, most recent first.
    func availableYears() async throws -> [Int] {
        let all = try await moments.fetchAll()
        let years = Set(all.map { calendar.component(.year, from: $0.createdAt) })
        return years.sorted(by: >)
    }
}
