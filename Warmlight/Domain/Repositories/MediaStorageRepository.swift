import Foundation

/// The kind of locally-stored media a `Moment` can reference.
enum MediaKind: Sendable {
    case photo
    case voiceNote
}

/// Persists raw media bytes (photos, voice notes) as files inside the
/// app's own Documents directory and resolves them back by file name.
///
/// Nothing ever leaves local storage — no external storage, no network.
protocol MediaStorageRepository: Sendable {
    func save(data: Data, kind: MediaKind, fileExtension: String) async throws -> String
    func load(fileName: String, kind: MediaKind) async throws -> Data?
    func delete(fileName: String, kind: MediaKind) async throws
    func fileURL(fileName: String, kind: MediaKind) -> URL
}
