import Foundation

/// Drives the main carousel: the moments feed, adding new moments, and
/// surfacing a "ray from the past" recall.
@MainActor
@Observable
final class MomentsViewModel {
    private(set) var moments: [Moment] = []
    private(set) var isLoading = false
    var errorMessage: String?
    var recalledMoment: Moment?

    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            moments = try await dependencies.fetchMoments.execute()
        } catch {
            errorMessage = "Moments could not be loaded."
        }
    }

    func addMoment(text: String, emotion: EmotionColor, photoData: Data?, voiceNoteData: Data?) async {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        do {
            let moment = try await dependencies.saveMoment.execute(
                text: trimmed,
                emotion: emotion,
                photoData: photoData,
                voiceNoteData: voiceNoteData
            )
            moments.insert(moment, at: 0)
            dependencies.haptics.warmGlow()
        } catch {
            errorMessage = "The moment could not be saved."
        }
    }

    func delete(_ moment: Moment) async {
        do {
            try await dependencies.deleteMoment.execute(moment)
            moments.removeAll { $0.id == moment.id }
        } catch {
            errorMessage = "The moment could not be deleted."
        }
    }

    func requestRayFromThePast() async {
        do {
            recalledMoment = try await dependencies.rayFromThePast.execute()
            if recalledMoment != nil {
                dependencies.haptics.lightTap()
            }
        } catch {
            recalledMoment = nil
        }
    }
}
