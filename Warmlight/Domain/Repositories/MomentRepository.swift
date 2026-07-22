import Foundation

/// Persistence abstraction for `Moment` entities.
///
/// Concrete implementations live in the Data layer; the domain layer
/// only depends on this protocol.
@MainActor
protocol MomentRepository {
    func save(_ moment: Moment) async throws
    func fetchAll() async throws -> [Moment]
    func delete(_ moment: Moment) async throws
    func deleteAll() async throws
}
