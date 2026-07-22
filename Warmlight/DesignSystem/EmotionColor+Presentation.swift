import SwiftUI

/// Maps each domain `EmotionColor` to an actual on-screen color, keeping
/// the domain layer itself free of `SwiftUI`.
extension EmotionColor {
    var color: Color {
        switch self {
        case .joy: return AppColor.accent
        case .gratitude: return AppColor.primary
        case .love: return Color(hex: "#FF5C7A")
        case .calm: return AppColor.secondary
        case .pride: return Color(hex: "#FFB877")
        case .hope: return Color(hex: "#FFE08A")
        }
    }

    var symbolName: String {
        switch self {
        case .joy: return "sun.max.fill"
        case .gratitude: return "hands.sparkles.fill"
        case .love: return "heart.fill"
        case .calm: return "leaf.fill"
        case .pride: return "star.fill"
        case .hope: return "sparkles"
        }
    }
}
