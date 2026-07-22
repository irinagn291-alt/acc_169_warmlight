import Foundation
import UserNotifications

/// Schedules the gentle evening prompt entirely through local notifications
/// — `UNUserNotificationCenter` only, never push or any third-party SDK.
@MainActor
final class NotificationService {
    private static let eveningPromptIdentifier = "warmlight.evening.prompt"
    private let center = UNUserNotificationCenter.current()

    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleEveningPrompt(hour: Int, minute: Int) async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.eveningPromptIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "Warmlight"
        content.body = "What warmed you today?"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: Self.eveningPromptIdentifier,
            content: content,
            trigger: trigger
        )
        try? await center.add(request)
    }

    func cancelEveningPrompt() {
        center.removePendingNotificationRequests(withIdentifiers: [Self.eveningPromptIdentifier])
    }
}
