import SwiftUI

/// The soft, warm glow shadow used behind moment cards and CTAs.
private struct WarmGlowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.55), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.25), radius: radius * 2, x: 0, y: 6)
    }
}

extension View {
    func warmGlow(color: Color = AppColor.primary, radius: CGFloat = 14) -> some View {
        modifier(WarmGlowModifier(color: color, radius: radius))
    }
}
