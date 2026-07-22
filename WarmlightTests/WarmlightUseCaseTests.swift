import XCTest
@testable import Warmlight

@MainActor
final class WarmlightUseCaseTests: XCTestCase {
    func testCompleteDriftGivenTwoSeedsWhenFinishingThenPersistsProgress() async {
        let repository = LanternProgressRepositoryStub()
        let useCase = CompleteLanternDriftUseCase(repository: repository)

        let result = await useCase.execute(
            session: LanternDriftSession(memoriesCollected: 2, emotionSeeds: [.joy, .calm])
        )

        XCTAssertEqual(result.sessions, 1)
        XCTAssertEqual(result.memoriesCollected, 2)
        XCTAssertEqual(result.emotionSeeds["joy"], 1)
        let persisted = await repository.load()
        XCTAssertEqual(persisted, result)
    }

    @MainActor
    func testMomentRepositoryGivenInMemoryStoreWhenSavingThenFetchesMoment() async throws {
        let container = PreviewSupport.container
        let repository = MomentRepositoryImpl(modelContext: container.mainContext)
        let moment = Moment(text: "A warm test", emotion: .hope)

        try await repository.save(moment)
        let fetched = try await repository.fetchAll()

        XCTAssertTrue(fetched.contains(where: { $0.id == moment.id }))
        try await repository.deleteAll()
    }
}

private actor LanternProgressRepositoryStub: LanternProgressRepository {
    private var progress = LanternDriftProgress.empty

    func load() -> LanternDriftProgress {
        progress
    }

    func save(_ progress: LanternDriftProgress) {
        self.progress = progress
    }
}
