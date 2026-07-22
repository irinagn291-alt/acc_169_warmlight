import Foundation
import SwiftData

/// Lightweight dependency-injection container. Built once by `RootView`
/// and passed down — no global singletons besides the stateless
/// `HapticsService`.
@MainActor
final class AppDependencies {
    let haptics: HapticsService
    let notificationService: NotificationService
    private let mediaStorage: MediaStorageRepository

    let saveMoment: SaveMomentUseCase
    let fetchMoments: FetchMomentsUseCase
    let deleteMoment: DeleteMomentUseCase
    let rayFromThePast: RayFromThePastUseCase
    let weekOfWarmth: WeekOfWarmthUseCase
    let lightOfTheYear: LightOfTheYearUseCase
    let livingGarden: LivingGardenUseCase
    let loadLanternProgress: LoadLanternProgressUseCase
    let completeLanternDrift: CompleteLanternDriftUseCase

    init(modelContext: ModelContext) {
        let momentRepository = MomentRepositoryImpl(modelContext: modelContext)
        let mediaStorageRepository = MediaStorageRepositoryImpl()
        let lanternRepository = LanternProgressRepositoryImpl()

        haptics = HapticsService()
        notificationService = NotificationService()
        mediaStorage = mediaStorageRepository

        saveMoment = SaveMomentUseCase(moments: momentRepository, media: mediaStorageRepository)
        fetchMoments = FetchMomentsUseCase(moments: momentRepository)
        deleteMoment = DeleteMomentUseCase(moments: momentRepository, media: mediaStorageRepository)
        rayFromThePast = RayFromThePastUseCase(moments: momentRepository)
        weekOfWarmth = WeekOfWarmthUseCase(moments: momentRepository)
        lightOfTheYear = LightOfTheYearUseCase(moments: momentRepository)
        livingGarden = LivingGardenUseCase(moments: momentRepository, progress: lanternRepository)
        loadLanternProgress = LoadLanternProgressUseCase(repository: lanternRepository)
        completeLanternDrift = CompleteLanternDriftUseCase(repository: lanternRepository)
    }

    func mediaFileURL(fileName: String, kind: MediaKind) -> URL {
        mediaStorage.fileURL(fileName: fileName, kind: kind)
    }

    func loadMediaData(fileName: String, kind: MediaKind) async -> Data? {
        try? await mediaStorage.load(fileName: fileName, kind: kind)
    }
}
