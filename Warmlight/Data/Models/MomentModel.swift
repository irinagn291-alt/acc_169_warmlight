import Foundation
import SwiftData

/// SwiftData mirror of the `Moment` domain entity.
///
/// Photos / voice notes are *not* stored here — only the file name of the
/// blob saved under the app's Documents directory by `MediaStorageRepository`.
@Model
final class MomentModel {
    @Attribute(.unique) var id: UUID
    var text: String
    var emotionRawValue: String
    var photoFileName: String?
    var voiceNoteFileName: String?
    var createdAt: Date

    init(
        id: UUID,
        text: String,
        emotionRawValue: String,
        photoFileName: String?,
        voiceNoteFileName: String?,
        createdAt: Date
    ) {
        self.id = id
        self.text = text
        self.emotionRawValue = emotionRawValue
        self.photoFileName = photoFileName
        self.voiceNoteFileName = voiceNoteFileName
        self.createdAt = createdAt
    }
}
