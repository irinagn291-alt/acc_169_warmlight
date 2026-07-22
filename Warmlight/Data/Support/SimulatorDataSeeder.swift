import Foundation
import SwiftData

@MainActor
enum SimulatorDataSeeder {
    static let version = 1
    private static let versionKey = "warmlight.simulatorSeedVersion"

    static func seedIfNeeded(modelContext: ModelContext) {
        #if targetEnvironment(simulator)
        guard UserDefaults.standard.integer(forKey: versionKey) < version else { return }
        apply(modelContext: modelContext)
        UserDefaults.standard.set(version, forKey: versionKey)
        #endif
    }

    #if targetEnvironment(simulator)
    private static func apply(modelContext: ModelContext) {
        let moments = (try? modelContext.fetch(FetchDescriptor<MomentModel>())) ?? []
        guard moments.isEmpty else { return }

        let samples: [(Int, EmotionColor, String)] = [
            (0, .joy, "Sunlight through the kitchen window while coffee cooled."),
            (1, .gratitude, "A short voice note from a friend that arrived at the right time."),
            (2, .calm, "Evening walk with no podcast — just leaves and quiet streets."),
            (3, .love, "Shared dinner leftovers and an unplanned long conversation."),
            (4, .pride, "Finished a hard task before noon and closed the laptop early."),
            (5, .hope, "Booked a tiny weekend trip for next month."),
            (7, .gratitude, "Neighbor returned a borrowed book with a handwritten thank-you."),
            (10, .joy, "Unexpected playlist that made the commute feel lighter.")
        ]

        for sample in samples {
            let date = Calendar.current.date(byAdding: .day, value: -sample.0, to: .now) ?? .now
            modelContext.insert(MomentModel(
                id: UUID(),
                text: sample.2,
                emotionRawValue: sample.1.rawValue,
                photoFileName: nil,
                voiceNoteFileName: nil,
                createdAt: date
            ))
        }
        try? modelContext.save()
    }
    #endif
}
