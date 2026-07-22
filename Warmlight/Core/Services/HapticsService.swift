import UIKit

/// Stateless haptics helper. The only "singleton-like" shared service in
/// the app — created once by `AppDependencies` and handed out everywhere.
@MainActor
struct HapticsService: Sendable {
    /// The warm pulse felt when a freshly saved card glows into the feed.
    func warmGlow() {
        let impact = UIImpactFeedbackGenerator(style: .soft)
        impact.prepare()
        impact.impactOccurred()

        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }

    func lightTap() {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.prepare()
        impact.impactOccurred()
    }
}
