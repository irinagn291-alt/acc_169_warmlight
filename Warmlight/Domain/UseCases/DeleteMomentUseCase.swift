import Foundation

/// Deletes a moment together with any local media files it referenced.
@MainActor
final class DeleteMomentUseCase {
    private let moments: MomentRepository
    private let media: MediaStorageRepository

    init(moments: MomentRepository, media: MediaStorageRepository) {
        self.moments = moments
        self.media = media
    }

    func execute(_ moment: Moment) async throws {
        if let photoFileName = moment.photoFileName {
            try await media.delete(fileName: photoFileName, kind: .photo)
        }
        if let voiceNoteFileName = moment.voiceNoteFileName {
            try await media.delete(fileName: voiceNoteFileName, kind: .voiceNote)
        }
        try await moments.delete(moment)
    }
}
