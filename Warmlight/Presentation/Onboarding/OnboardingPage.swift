import Foundation

/// One of the four "emotional-story" onboarding screens.
struct OnboardingPage: Identifiable {
    let id: Int
    let title: String
    let symbolName: String
    let ctaTitle: String
}

extension OnboardingPage {
    static let storyPages: [OnboardingPage] = [
        OnboardingPage(id: 0, title: "Warm moments fade quickly", symbolName: "hourglass", ctaTitle: "Continue"),
        OnboardingPage(id: 1, title: "Keep moments of light", symbolName: "rectangle.stack.fill", ctaTitle: "I understand"),
        OnboardingPage(id: 2, title: "Return to them", symbolName: "sun.horizon.fill", ctaTitle: "Begin")
    ]
}
