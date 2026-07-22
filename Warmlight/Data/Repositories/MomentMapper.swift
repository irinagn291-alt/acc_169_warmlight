import Foundation

/// Pure mapping helpers between the SwiftData model and the domain entity.
enum MomentMapper {
    static func toDomain(_ model: MomentModel) -> Moment {
        Moment(
            id: model.id,
            text: model.text,
            emotion: EmotionColor(rawValue: model.emotionRawValue) ?? .calm,
            photoFileName: model.photoFileName,
            voiceNoteFileName: model.voiceNoteFileName,
            createdAt: model.createdAt
        )
    }

    static func toModel(_ moment: Moment) -> MomentModel {
        MomentModel(
            id: moment.id,
            text: moment.text,
            emotionRawValue: moment.emotion.rawValue,
            photoFileName: moment.photoFileName,
            voiceNoteFileName: moment.voiceNoteFileName,
            createdAt: moment.createdAt
        )
    }
}
