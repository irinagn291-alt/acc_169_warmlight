@preconcurrency import AVFoundation
import Foundation

/// Thin, observable wrapper around `AVAudioRecorder` / `AVAudioPlayer` for
/// the optional voice note attached to a moment. Recordings are written to
/// a temporary file and only persisted (as `Data`) once the moment is saved.
@Observable
@MainActor
final class AudioRecorderService: NSObject {
    private(set) var isRecording = false
    private(set) var isPlaying = false
    private(set) var recordedFileURL: URL?

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    func requestPermission() async -> Bool {
        await AVAudioApplication.requestRecordPermission()
    }

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default)
            try session.setActive(true)

            let url = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("m4a")

            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44_100,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
            ]

            let newRecorder = try AVAudioRecorder(url: url, settings: settings)
            newRecorder.delegate = self
            newRecorder.record()

            recorder = newRecorder
            recordedFileURL = url
            isRecording = true
        } catch {
            isRecording = false
        }
    }

    func stopRecording() {
        recorder?.stop()
        isRecording = false
    }

    func discardRecording() {
        stopRecording()
        if let recordedFileURL {
            try? FileManager.default.removeItem(at: recordedFileURL)
        }
        recordedFileURL = nil
    }

    func playRecording() {
        guard let recordedFileURL else { return }
        do {
            let newPlayer = try AVAudioPlayer(contentsOf: recordedFileURL)
            newPlayer.delegate = self
            newPlayer.play()
            player = newPlayer
            isPlaying = true
        } catch {
            isPlaying = false
        }
    }

    func stopPlayback() {
        player?.stop()
        isPlaying = false
    }

    func recordedData() -> Data? {
        guard let recordedFileURL else { return nil }
        return try? Data(contentsOf: recordedFileURL)
    }
}

extension AudioRecorderService: AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak self] in
            self?.isPlaying = false
        }
    }
}
