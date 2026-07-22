import SwiftUI
import UIKit

/// Appearance, evening notifications, "light of the year" export and
/// about / reset.
struct SettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    @State private var exportedCollageURL: URL?
    @State private var isRenderingCollage = false

    var body: some View {
        NavigationStack {
            Form {
                appearanceSection
                notificationsSection
                exportSection
                aboutSection
            }
            .scrollContentBackground(.hidden)
            .background(AppColor.background)
            .navigationTitle("Settings")
            .task { await viewModel.loadAvailableYears() }
            .alert(
                "Delete all moments?",
                isPresented: $viewModel.isShowingResetConfirmation
            ) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task { await viewModel.resetAllData() }
                }
            } message: {
                Text("This cannot be undone. Every light card and media file will be removed from this device.")
            }
            .alert(
                "Warmlight",
                isPresented: Binding(
                    get: { viewModel.statusMessage != nil },
                    set: { if !$0 { viewModel.statusMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.statusMessage ?? "")
            }
        }
        .tint(AppColor.accent)
    }

    private var appearanceSection: some View {
        Section("Appearance") {
            Picker("Theme", selection: $viewModel.appearanceMode) {
                ForEach(AppearanceMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .listRowBackground(AppColor.surface)
    }

    private var notificationsSection: some View {
        Section("Evening prompts") {
            Toggle("Remind me in the evening", isOn: $viewModel.eveningPromptEnabled)
            if viewModel.eveningPromptEnabled {
                DatePicker(
                    "Time",
                    selection: $viewModel.eveningPromptTime,
                    displayedComponents: .hourAndMinute
                )
            }
            Text("“What warmed you today?”")
                .font(.caption)
                .foregroundStyle(AppColor.text.opacity(0.6))
        }
        .listRowBackground(AppColor.surface)
    }

    private var exportSection: some View {
        Section("Light of the Year") {
            if viewModel.availableYears.isEmpty {
                Text("Save a few moments to grow your yearly collage.")
                    .font(.subheadline)
                    .foregroundStyle(AppColor.text.opacity(0.6))
            } else {
                Picker("Year", selection: $viewModel.selectedCollageYear) {
                    ForEach(viewModel.availableYears, id: \.self) { year in
                        Text(String(year)).tag(Optional(year))
                    }
                }

                Button {
                    Task { await renderCollage() }
                } label: {
                    if isRenderingCollage {
                        ProgressView()
                    } else {
                        Label("Create collage", systemImage: "square.grid.3x3.fill")
                    }
                }

                if let exportedCollageURL {
                    ShareLink(item: exportedCollageURL, preview: SharePreview("Light of the Year")) {
                        Label("Share collage", systemImage: "square.and.arrow.up")
                    }
                }
            }
        }
        .listRowBackground(AppColor.surface)
    }

    private var aboutSection: some View {
        Section("About") {
            Text("Warmlight holds the warm moments of your day. Photos and voice notes remain on your device and are never uploaded.")
                .font(.footnote)
                .foregroundStyle(AppColor.text.opacity(0.7))

            Text("Warmlight is not a substitute for therapy or professional care. If you are struggling, please reach out to a qualified professional.")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(AppColor.primary)

            Button("Delete all data", role: .destructive) {
                viewModel.isShowingResetConfirmation = true
            }
        }
        .listRowBackground(AppColor.surface)
    }

    @MainActor
    private func renderCollage() async {
        isRenderingCollage = true
        defer { isRenderingCollage = false }

        let moments = await viewModel.momentsForCollage()
        guard let year = viewModel.selectedCollageYear, !moments.isEmpty else { return }

        let collage = LightOfYearCollageView(year: year, moments: moments)
        let renderer = ImageRenderer(content: collage)
        renderer.scale = UIScreen.main.scale

        guard let uiImage = renderer.uiImage, let data = uiImage.pngData() else { return }

        let url = FileManager.default.temporaryDirectory.appendingPathComponent("warmlight-\(year).png")
        do {
            try data.write(to: url, options: .atomic)
            exportedCollageURL = url
        } catch {
            exportedCollageURL = nil
        }
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel(dependencies: PreviewSupport.dependencies))
}
