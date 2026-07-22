import Foundation

/// Stores photo / voice-note bytes as plain files inside subfolders of the
/// app's own Documents directory — never iCloud, never external storage.
final class MediaStorageRepositoryImpl: MediaStorageRepository, @unchecked Sendable {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
        createFoldersIfNeeded()
    }

    func save(data: Data, kind: MediaKind, fileExtension: String) async throws -> String {
        let fileName = "\(UUID().uuidString).\(fileExtension)"
        let url = fileURL(fileName: fileName, kind: kind)
        try data.write(to: url, options: .atomic)
        return fileName
    }

    func load(fileName: String, kind: MediaKind) async throws -> Data? {
        let url = fileURL(fileName: fileName, kind: kind)
        guard fileManager.fileExists(atPath: url.path) else { return nil }
        return try Data(contentsOf: url)
    }

    func delete(fileName: String, kind: MediaKind) async throws {
        let url = fileURL(fileName: fileName, kind: kind)
        guard fileManager.fileExists(atPath: url.path) else { return }
        try fileManager.removeItem(at: url)
    }

    nonisolated func fileURL(fileName: String, kind: MediaKind) -> URL {
        folderURL(for: kind).appendingPathComponent(fileName)
    }

    private nonisolated func folderURL(for kind: MediaKind) -> URL {
        let documents = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        switch kind {
        case .photo:
            return documents.appendingPathComponent("MomentPhotos", isDirectory: true)
        case .voiceNote:
            return documents.appendingPathComponent("MomentVoiceNotes", isDirectory: true)
        }
    }

    private func createFoldersIfNeeded() {
        for kind in [MediaKind.photo, MediaKind.voiceNote] {
            let url = folderURL(for: kind)
            if !fileManager.fileExists(atPath: url.path) {
                try? fileManager.createDirectory(at: url, withIntermediateDirectories: true)
            }
        }
    }
}
