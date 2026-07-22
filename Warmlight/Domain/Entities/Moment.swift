import Foundation

/// A single warm "card of light" — the core entity of Warmlight.
///
/// `photoFileName` / `voiceNoteFileName` are file references inside the
/// app's own Documents directory, never external storage or remote URLs.
struct Moment: Identifiable, Hashable, Sendable {
    let id: UUID
    var text: String
    var emotion: EmotionColor
    var photoFileName: String?
    var voiceNoteFileName: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        text: String,
        emotion: EmotionColor,
        photoFileName: String? = nil,
        voiceNoteFileName: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.text = text
        self.emotion = emotion
        self.photoFileName = photoFileName
        self.voiceNoteFileName = voiceNoteFileName
        self.createdAt = createdAt
    }

    var hasPhoto: Bool { photoFileName != nil }
    var hasVoiceNote: Bool { voiceNoteFileName != nil }
}
