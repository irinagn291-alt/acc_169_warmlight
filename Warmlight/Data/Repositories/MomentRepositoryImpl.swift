import Foundation
import SwiftData

/// `MomentRepository` backed by a SwiftData `ModelContext`.
@MainActor
final class MomentRepositoryImpl: MomentRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ moment: Moment) async throws {
        let model = MomentMapper.toModel(moment)
        modelContext.insert(model)
        try modelContext.save()
    }

    func fetchAll() async throws -> [Moment] {
        let descriptor = FetchDescriptor<MomentModel>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        return try modelContext.fetch(descriptor).map(MomentMapper.toDomain)
    }

    func delete(_ moment: Moment) async throws {
        let targetID = moment.id
        let descriptor = FetchDescriptor<MomentModel>(
            predicate: #Predicate { $0.id == targetID }
        )
        guard let model = try modelContext.fetch(descriptor).first else { return }
        modelContext.delete(model)
        try modelContext.save()
    }

    func deleteAll() async throws {
        let models = try modelContext.fetch(FetchDescriptor<MomentModel>())
        for model in models {
            modelContext.delete(model)
        }
        try modelContext.save()
    }
}
