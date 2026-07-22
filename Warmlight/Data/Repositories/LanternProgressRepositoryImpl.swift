import Foundation

actor LanternProgressRepositoryImpl: LanternProgressRepository {
    private let defaults: UserDefaults
    private let key = "warmlight.lanternDriftProgress"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> LanternDriftProgress {
        guard
            let data = defaults.data(forKey: key),
            let progress = try? JSONDecoder().decode(LanternDriftProgress.self, from: data)
        else {
            return .empty
        }
        return progress
    }

    func save(_ progress: LanternDriftProgress) {
        guard let data = try? JSONEncoder().encode(progress) else { return }
        defaults.set(data, forKey: key)
    }
}
