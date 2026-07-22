import SwiftUI

struct LanternDriftView: View {
    @State private var viewModel: LanternDriftViewModel
    @State private var coordinator = GameCoordinator()
    @State private var lanternX: CGFloat = 0

    init(dependencies: AppDependencies) {
        _viewModel = State(initialValue: LanternDriftViewModel(dependencies: dependencies))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LivingGardenBackground()
                if coordinator.isShowingRitual {
                    ritual
                } else {
                    drift
                }
            }
            .navigationTitle("Lantern Drift")
            .navigationBarTitleDisplayMode(.inline)
            .task { await viewModel.load() }
        }
    }

    private var ritual: some View {
        VStack(spacing: 24) {
            Image(systemName: "paperplane.fill")
                .font(.system(size: 58))
                .foregroundStyle(AppColor.accent)
                .shadow(color: AppColor.accent, radius: 24)
            Text("Let the lantern wander")
                .font(.system(.largeTitle, design: .serif).weight(.semibold))
                .multilineTextAlignment(.center)
            Text("Guide with one thumb. Gather any colors you meet. There is no timer and no way to lose.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.76))
            Button("Begin drifting") {
                viewModel.restart()
                coordinator.begin()
            }
            .buttonStyle(WarmPrimaryButtonStyle())
            Text("\(viewModel.progress.sessions) gentle journeys · \(viewModel.progress.memoriesCollected) colors gathered")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.62))
        }
        .foregroundStyle(.white)
        .paperCard()
        .padding(24)
    }

    private var drift: some View {
        GeometryReader { proxy in
            ZStack {
                ForEach(Array(EmotionColor.allCases.enumerated()), id: \.element) { index, emotion in
                    memorySeed(emotion)
                        .position(
                            x: CGFloat(42 + (index * 67) % max(Int(proxy.size.width - 84), 1)),
                            y: CGFloat(110 + (index * 101) % max(Int(proxy.size.height - 220), 1))
                        )
                }

                lantern
                    .position(x: proxy.size.width / 2 + lanternX, y: proxy.size.height * 0.68)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                lanternX = min(max(value.translation.width, -proxy.size.width * 0.4), proxy.size.width * 0.4)
                            }
                    )

                VStack {
                    Text(viewModel.sessionCompleted ? "Your garden received this light." : "Drift toward a color to gather it.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.82))
                        .paperCard()
                    Spacer()
                    Button(viewModel.sessionCompleted ? "Drift again" : "Rest the lantern") {
                        if viewModel.sessionCompleted {
                            coordinator.returnToRitual()
                        } else {
                            Task { await viewModel.finish() }
                        }
                    }
                    .buttonStyle(WarmPrimaryButtonStyle())
                }
                .padding()
            }
        }
    }

    private var lantern: some View {
        ZStack {
            Circle()
                .fill(AppColor.accent.opacity(0.25))
                .frame(width: 110, height: 110)
                .blur(radius: 16)
            Image(systemName: "light.beacon.max.fill")
                .font(.system(size: 52))
                .foregroundStyle(.white, AppColor.primary)
        }
        .accessibilityLabel("Drifting lantern")
    }

    private func memorySeed(_ emotion: EmotionColor) -> some View {
        Button {
            viewModel.collect(emotion)
        } label: {
            Circle()
                .fill(emotion.color)
                .frame(width: 34, height: 34)
                .overlay(Circle().stroke(.white.opacity(0.7)))
                .shadow(color: emotion.color, radius: 12)
        }
        .disabled(viewModel.sessionCompleted)
        .accessibilityLabel("\(emotion.displayName) memory")
    }
}
