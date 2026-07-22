import SwiftUI

/// Main screen: a horizontal coverflow carousel of moment cards you swipe
/// sideways like photos, plus "+ moment" and "ray from the past".
struct MainCarouselView: View {
    @Bindable var viewModel: MomentsViewModel
    let dependencies: AppDependencies

    @State private var isShowingAddMoment = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppColor.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    if viewModel.moments.isEmpty {
                        EmptyMomentsView()
                            .frame(maxHeight: .infinity)
                    } else {
                        carousel
                            .frame(maxHeight: .infinity)
                    }

                    addMomentButton
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("Warmlight")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await viewModel.requestRayFromThePast() }
                    } label: {
                        Image(systemName: "sun.haze.fill")
                    }
                    .tint(AppColor.accent)
                    .disabled(viewModel.moments.isEmpty)
                    .accessibilityLabel("Ray from the Past")
                }
            }
        }
        .task { await viewModel.load() }
        .sheet(isPresented: $isShowingAddMoment) {
            AddMomentView(dependencies: dependencies) { text, emotion, photoData, voiceData in
                await viewModel.addMoment(text: text, emotion: emotion, photoData: photoData, voiceNoteData: voiceData)
            }
        }
        .sheet(item: $viewModel.recalledMoment) { moment in
            RayFromPastView(moment: moment, dependencies: dependencies)
        }
    }

    private var carousel: some View {
        GeometryReader { geometry in
            let sidePadding = max((geometry.size.width - 280) / 2, 0)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 28) {
                    ForEach(viewModel.moments) { moment in
                        MomentCardView(moment: moment, dependencies: dependencies)
                            .scrollTransition(.animated.threshold(.visible(0.7))) { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1 : 0.84)
                                    .rotation3DEffect(
                                        .degrees(phase.value * 26),
                                        axis: (x: 0, y: 1, z: 0)
                                    )
                                    .opacity(phase.isIdentity ? 1 : 0.5)
                            }
                            .contextMenu {
                                Button(role: .destructive) {
                                    Task { await viewModel.delete(moment) }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, sidePadding)
                .padding(.vertical, 24)
            }
            .scrollTargetBehavior(.viewAligned)
        }
    }

    private var addMomentButton: some View {
        Button {
            isShowingAddMoment = true
        } label: {
            Label("+ moment", systemImage: "plus")
        }
        .buttonStyle(WarmPrimaryButtonStyle())
        .padding(.horizontal, 28)
    }
}

#Preview {
    MainCarouselView(
        viewModel: MomentsViewModel(dependencies: PreviewSupport.dependencies),
        dependencies: PreviewSupport.dependencies
    )
}
