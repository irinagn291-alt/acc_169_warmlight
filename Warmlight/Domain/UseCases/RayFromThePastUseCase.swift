import Foundation

/// "Ray from the Past": surfaces a random moment from earlier days so a
/// difficult day can be warmed by something already saved.
@MainActor
final class RayFromThePastUseCase {
    private let moments: MomentRepository

    init(moments: MomentRepository) {
        self.moments = moments
    }

    /// Returns a random moment that isn't the one currently excluded
    /// (typically "today"), preferring moments that are at least a day old.
    func execute(excluding excludedID: UUID? = nil, referenceDate: Date = .now) async throws -> Moment? {
        let all = try await moments.fetchAll().filter { $0.id != excludedID }
        guard !all.isEmpty else { return nil }

        let calendar = Calendar.current
        let pastMoments = all.filter { !calendar.isDate($0.createdAt, inSameDayAs: referenceDate) }

        return (pastMoments.isEmpty ? all : pastMoments).randomElement()
    }
}
