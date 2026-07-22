import SwiftUI

struct LivingGardenBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var drifting = false

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "#17142D"), Color(hex: "#713B69"), Color(hex: "#FF8A72")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Circle()
                .fill(AppColor.accent.opacity(0.2))
                .frame(width: 260)
                .blur(radius: 55)
                .offset(x: drifting ? 110 : 65, y: drifting ? -240 : -200)
            ForEach(0..<14, id: \.self) { index in
                Circle()
                    .fill(index.isMultiple(of: 3) ? AppColor.primary : AppColor.accent)
                    .frame(width: CGFloat(3 + index % 5))
                    .blur(radius: 0.5)
                    .offset(
                        x: CGFloat((index * 47) % 330) - 165,
                        y: CGFloat((index * 83) % 700) - 350 + (drifting ? -18 : 18)
                    )
                    .opacity(0.55)
            }
        }
        .ignoresSafeArea()
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 5).repeatForever(autoreverses: true)) {
                drifting = true
            }
        }
    }
}

struct PaperCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(.ultraThinMaterial.opacity(0.88))
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(.white.opacity(0.16))
            }
    }
}

extension View {
    func paperCard() -> some View {
        modifier(PaperCardModifier())
    }
}
