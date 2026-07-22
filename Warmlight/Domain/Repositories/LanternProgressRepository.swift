protocol LanternProgressRepository: Sendable {
    func load() async -> LanternDriftProgress
    func save(_ progress: LanternDriftProgress) async
}
