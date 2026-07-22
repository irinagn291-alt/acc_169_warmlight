import Foundation

/// The emotional color tag attached to a `Moment`.
///
/// Kept free of any UI imports — `DesignSystem` maps each case to an
/// actual `Color` so the domain layer stays presentation-agnostic.
enum EmotionColor: String, CaseIterable, Codable, Identifiable, Sendable {
    case joy
    case gratitude
    case love
    case calm
    case pride
    case hope

    var id: String { rawValue }

    /// Russian display name matching the warm, supportive tone of the product.
    var displayName: String {
        switch self {
        case .joy: return "Joy"
        case .gratitude: return "Gratitude"
        case .love: return "Love"
        case .calm: return "Calm"
        case .pride: return "Pride"
        case .hope: return "Hope"
        }
    }
}
