import SwiftUI

struct OnboardingView: View {
    let dependencies: AppDependencies
    let onFinish: () -> Void

    @State private var viewModel: OnboardingViewModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(dependencies: AppDependencies, onFinish: @escaping () -> Void) {
        self.dependencies = dependencies
        self.onFinish = onFinish
        _viewModel = State(initialValue: OnboardingViewModel(dependencies: dependencies))
    }

    var body: some View {
        ZStack {
            GeometryReader { geo in
                ZStack {
                    Image("RitualGarden")
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                    LinearGradient(
                        colors: [.black.opacity(0.1), .black.opacity(0.72)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            }
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack {
                HStack {
                    Spacer()
                    if viewModel.pageIndex < 3 {
                        Button("Skip ritual") {
                            viewModel.pageIndex = 3
                        }
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.white.opacity(0.78))
                    }
                }
                Spacer(minLength: 0)
                ritualContent
                    .id(viewModel.pageIndex)
                    .transition(reduceMotion ? .opacity : .asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .scale.combined(with: .opacity)))
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .animation(reduceMotion ? .easeInOut(duration: 0.15) : .spring(duration: 0.8), value: viewModel.pageIndex)
    }

    @ViewBuilder
    private var ritualContent: some View {
        switch viewModel.pageIndex {
        case 0:
            ritualCard(
                symbol: "sparkle",
                title: "Catch your first light",
                message: "Pause where the garden glows. A small moment is enough.",
                button: "Reach for the light"
            )
        case 1:
            VStack(spacing: 20) {
                Text("Choose its color")
                    .font(.system(.largeTitle, design: .serif).weight(.semibold))
                EmotionPickerView(selection: $viewModel.firstMomentEmotion)
                Button("Keep this color") { viewModel.advance() }
                    .buttonStyle(WarmPrimaryButtonStyle())
            }
            .foregroundStyle(.white)
            .paperCard()
        case 2:
            ritualCard(
                symbol: "waveform",
                title: "Give it a voice",
                message: "Write it now. You can add a voice note or photo to any moment in your garden.",
                button: "Write my moment"
            )
        default:
            VStack(spacing: 18) {
                Image(systemName: "hourglass")
                    .font(.system(size: 42))
                    .foregroundStyle(AppColor.accent)
                Text("Seal a time capsule")
                    .font(.system(.largeTitle, design: .serif).weight(.semibold))
                TextField("A warm detail you want to meet again…", text: $viewModel.firstMomentText, axis: .vertical)
                    .lineLimit(3...5)
                    .padding()
                    .background(.white.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 18))
                if let error = viewModel.errorMessage {
                    Text(error).font(.caption).foregroundStyle(AppColor.accent)
                }
                Button(viewModel.lastPageCTA) {
                    Task {
                        if await viewModel.saveFirstMoment() {
                            onFinish()
                        }
                    }
                }
                .buttonStyle(WarmPrimaryButtonStyle())
                .disabled(viewModel.isSaving)
                Button("Replay ritual") { viewModel.pageIndex = 0 }
                    .font(.footnote)
            }
            .foregroundStyle(.white)
            .paperCard()
        }
    }

    private func ritualCard(symbol: String, title: String, message: String, button: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: symbol)
                .font(.system(size: 52))
                .foregroundStyle(AppColor.accent)
                .shadow(color: AppColor.accent, radius: 20)
            Text(title)
                .font(.system(.largeTitle, design: .serif).weight(.semibold))
                .multilineTextAlignment(.center)
            Text(message)
                .multilineTextAlignment(.center)
                .foregroundStyle(.white.opacity(0.75))
            Button(button) { viewModel.advance() }
                .buttonStyle(WarmPrimaryButtonStyle())
        }
        .foregroundStyle(.white)
        .paperCard()
    }
}
