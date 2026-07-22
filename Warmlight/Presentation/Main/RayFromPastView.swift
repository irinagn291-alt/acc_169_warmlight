import SwiftUI

/// "Ray from the Past" recall sheet — surfaces one random past moment as a
/// warm resource on a difficult day.
struct RayFromPastView: View {
    let moment: Moment
    let dependencies: AppDependencies

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Text("Ray from the Past")
                .font(.system(.title2, design: .serif).weight(.semibold))
                .foregroundStyle(AppColor.text)

            MomentCardView(moment: moment, dependencies: dependencies)

            Text("This moment warmed you once. Let it glow again.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundStyle(AppColor.text.opacity(0.7))
                .padding(.horizontal, 32)

            Spacer()

            Button("Keep this light") { dismiss() }
                .buttonStyle(WarmPrimaryButtonStyle())
                .padding(.horizontal, 32)

            Text("Warmlight is not a substitute for professional care.")
                .font(.caption2)
                .foregroundStyle(AppColor.text.opacity(0.45))
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColor.background.ignoresSafeArea())
    }
}

#Preview {
    RayFromPastView(
        moment: Moment(text: "An unexpected call from an old friend", emotion: .love),
        dependencies: PreviewSupport.dependencies
    )
}
