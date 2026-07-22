import PhotosUI
import SwiftUI
import UIKit

/// Form for capturing a new moment: text, emotion, optional photo and
/// optional voice note.
struct AddMomentView: View {
    let dependencies: AppDependencies
    let onSave: (String, EmotionColor, Data?, Data?) async -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var text = ""
    @State private var emotion: EmotionColor = .gratitude
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    @State private var recorder = AudioRecorderService()
    @State private var isSaving = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("What warmed you today?", text: $text, axis: .vertical)
                        .lineLimit(3...6)
                }
                .listRowBackground(AppColor.surface)

                Section {
                    EmotionPickerView(selection: $emotion)
                }
                .listRowBackground(AppColor.surface)

                Section("Photo") {
                    photoPicker
                }
                .listRowBackground(AppColor.surface)

                Section("Voice note") {
                    voiceRecorderControls
                }
                .listRowBackground(AppColor.surface)
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle("New Moment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save moment") {
                        Task { await save() }
                    }
                    .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
        }
        .tint(AppColor.accent)
    }

    private var photoPicker: some View {
        let photoButtonTitle = photoData == nil ? "Add photo" : "Replace photo"
        return VStack(alignment: .leading, spacing: 12) {
            if let photoData, let image = UIImage(data: photoData) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            PhotosPicker(
                selection: $photoItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Label(photoButtonTitle, systemImage: "photo")
            }
            .onChange(of: photoItem) { _, newItem in
                Task { await loadPhoto(from: newItem) }
            }

            if photoData != nil {
                Button("Remove photo", role: .destructive) {
                    photoData = nil
                    photoItem = nil
                }
            }
        }
    }

    private var voiceRecorderControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            if recorder.isRecording {
                Label("Recording…", systemImage: "waveform")
                    .foregroundStyle(AppColor.primary)
                Button("Stop recording") {
                    recorder.stopRecording()
                }
            } else if recorder.recordedFileURL != nil {
                HStack {
                    Button {
                        recorder.isPlaying ? recorder.stopPlayback() : recorder.playRecording()
                    } label: {
                        Label(
                            recorder.isPlaying ? "Stop" : "Listen",
                            systemImage: recorder.isPlaying ? "stop.fill" : "play.fill"
                        )
                    }
                    Spacer()
                    Button("Delete", role: .destructive) {
                        recorder.discardRecording()
                    }
                }
            } else {
                Button {
                    Task { await startRecording() }
                } label: {
                    Label("Record voice note", systemImage: "mic.fill")
                }
            }
        }
    }

    private func startRecording() async {
        guard await recorder.requestPermission() else { return }
        recorder.startRecording()
    }

    private func loadPhoto(from item: PhotosPickerItem?) async {
        guard let item else { return }
        photoData = try? await item.loadTransferable(type: Data.self)
    }

    private func save() async {
        isSaving = true
        defer { isSaving = false }
        let voiceData = recorder.recordedData()
        await onSave(text, emotion, photoData, voiceData)
        dismiss()
    }
}

#Preview {
    AddMomentView(dependencies: PreviewSupport.dependencies) { _, _, _, _ in }
}
