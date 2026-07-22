import Foundation

/// Saves a new `Moment`, persisting any attached photo / voice note bytes
/// to local file storage first and wiring up the resulting file names.
@MainActor
final class SaveMomentUseCase {
    private let moments: MomentRepository
    private let media: MediaStorageRepository

    init(moments: MomentRepository, media: MediaStorageRepository) {
        self.moments = moments
        self.media = media
    }

    func execute(
        text: String,
        emotion: EmotionColor,
        photoData: Data?,
        voiceNoteData: Data?
    ) async throws -> Moment {
        var photoFileName: String?
        if let photoData {
            photoFileName = try await media.save(data: photoData, kind: .photo, fileExtension: "jpg")
        }

        var voiceNoteFileName: String?
        if let voiceNoteData {
            voiceNoteFileName = try await media.save(data: voiceNoteData, kind: .voiceNote, fileExtension: "m4a")
        }

        let moment = Moment(
            text: text,
            emotion: emotion,
            photoFileName: photoFileName,
            voiceNoteFileName: voiceNoteFileName
        )
        try await moments.save(moment)
        return moment
    }
}
