import Foundation

/// Fetches all moments, newest first — the feed shown in the carousel.
@MainActor
final class FetchMomentsUseCase {
    private let moments: MomentRepository

    init(moments: MomentRepository) {
        self.moments = moments
    }

    func execute() async throws -> [Moment] {
        try await moments.fetchAll().sorted { $0.createdAt > $1.createdAt }
    }
}
