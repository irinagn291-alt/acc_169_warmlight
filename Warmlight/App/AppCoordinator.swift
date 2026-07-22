import SwiftUI

@MainActor
@Observable
final class AppCoordinator {
    enum Tab: Hashable {
        case moments
        case garden
        case drift
        case settings
    }

    var selectedTab: Tab = .moments
}

@MainActor
@Observable
final class GameCoordinator {
    var isShowingRitual = true

    func begin() {
        isShowingRitual = false
    }

    func returnToRitual() {
        isShowingRitual = true
    }
}
