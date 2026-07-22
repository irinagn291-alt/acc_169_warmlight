import Foundation

struct LanternDriftProgress: Codable, Equatable, Sendable {
    var sessions: Int
    var memoriesCollected: Int
    var emotionSeeds: [String: Int]
    var lastPlayedAt: Date?

    static let empty = LanternDriftProgress(
        sessions: 0,
        memoriesCollected: 0,
        emotionSeeds: [:],
        lastPlayedAt: nil
    )
}

struct LanternDriftSession: Equatable, Sendable {
    let memoriesCollected: Int
    let emotionSeeds: [EmotionColor]
}

struct LivingGardenSummary: Sendable {
    let moments: [Moment]
    let emotionDistribution: [EmotionDistribution]
    let activeDays: Int
    let gentleStreakDays: Int
    let photoCount: Int
    let voiceCount: Int
    let resurfacedMemories: Int
    let openedCapsules: Int
    let driftProgress: LanternDriftProgress
}
