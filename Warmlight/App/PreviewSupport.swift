import Foundation
import SwiftData

/// In-memory `AppDependencies` factory used only by `#Preview` blocks.
@MainActor
enum PreviewSupport {
    static let container: ModelContainer = {
        let schema = Schema(AppSchema.allModels)
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: schema, configurations: [configuration]) else {
            fatalError("Could not create preview ModelContainer")
        }
        return container
    }()

    static let dependencies = AppDependencies(modelContext: container.mainContext)
}
