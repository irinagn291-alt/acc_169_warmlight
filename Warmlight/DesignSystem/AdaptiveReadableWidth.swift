import SwiftUI

/// Centers primary content on iPad / regular width without stretching phone layouts.
struct AdaptiveReadableWidth: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var maxWidth: CGFloat = 720

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: horizontalSizeClass == .regular ? maxWidth : .infinity)
            .frame(maxWidth: .infinity)
    }
}

extension View {
    func adaptiveReadableWidth(_ maxWidth: CGFloat = 720) -> some View {
        modifier(AdaptiveReadableWidth(maxWidth: maxWidth))
    }
}
