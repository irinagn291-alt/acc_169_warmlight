import SwiftUI

struct DashboardView: View {
    @Bindable var viewModel: DashboardViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                LivingGardenBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        if let summary = viewModel.summary {
                            garden(summary)
                            gentleStats(summary)
                            mediaMix(summary)
                        } else if viewModel.isLoading {
                            ProgressView().tint(AppColor.accent)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 80)
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Living Garden")
        }
        .task { await viewModel.load() }
    }

    private func garden(_ summary: LivingGardenSummary) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Your warmth is growing")
                .font(.system(.title2, design: .serif).weight(.semibold))
            Text(summary.moments.isEmpty ? "Save a moment or take a lantern drift to plant the first light." : "Every bloom is a memory. Clusters reveal the feelings that return across your seasons.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.7))
            ZStack {
                ForEach(Array(summary.emotionDistribution.enumerated()), id: \.element.id) { index, item in
                    let angle = Double(index) * 2.4
                    Circle()
                        .fill(item.emotion.color.opacity(0.85))
                        .frame(width: CGFloat(38 + min(item.count, 8) * 6))
                        .overlay(Image(systemName: "leaf.fill").foregroundStyle(.white.opacity(0.65)))
                        .offset(x: cos(angle) * CGFloat(42 + index * 12), y: sin(angle) * CGFloat(36 + index * 9))
                        .shadow(color: item.emotion.color, radius: 18)
                }
                Image(systemName: "lamp.table.fill")
                    .font(.system(size: 42))
                    .foregroundStyle(AppColor.accent)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 230)
        }
        .foregroundStyle(.white)
        .paperCard()
    }

    private func gentleStats(_ summary: LivingGardenSummary) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Quiet rhythms").font(.headline)
            HStack {
                metric("\(summary.activeDays)", "days in bloom")
                metric("\(summary.gentleStreakDays)", "gentle rhythm")
                metric("\(summary.driftProgress.memoriesCollected)", "drift colors")
            }
        }
        .foregroundStyle(.white)
        .paperCard()
    }

    private func mediaMix(_ summary: LivingGardenSummary) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Memory textures").font(.headline)
            HStack(spacing: 18) {
                Label("\(summary.photoCount) photos", systemImage: "photo.fill")
                Label("\(summary.voiceCount) voices", systemImage: "waveform")
            }
            HStack(spacing: 18) {
                Label("\(summary.openedCapsules) capsules", systemImage: "hourglass")
                Label("\(summary.resurfacedMemories) resurfaced", systemImage: "sparkles")
            }
        }
        .font(.subheadline)
        .foregroundStyle(.white)
        .paperCard()
    }

    private func metric(_ value: String, _ title: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value).font(.title2.weight(.bold)).foregroundStyle(AppColor.accent)
            Text(title).font(.caption).foregroundStyle(.white.opacity(0.65))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModel(dependencies: PreviewSupport.dependencies))
}
