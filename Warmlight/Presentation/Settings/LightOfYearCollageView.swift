import SwiftUI

/// The "light of the year" collage itself — a grid of warm tiles, one per moment,
/// rendered to an image for export via `ImageRenderer`.
struct LightOfYearCollageView: View {
    let year: Int
    let moments: [Moment]

    private let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        VStack(spacing: 16) {
            Text("Light \(String(year))")
                .font(.system(.title, design: .serif).weight(.bold))
                .foregroundStyle(AppColor.text)

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(moments) { moment in
                    tile(for: moment)
                }
            }
        }
        .padding(24)
        .background(AppColor.background)
    }

    private func tile(for moment: Moment) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(moment.emotion.color.opacity(0.85))
            Image(systemName: moment.emotion.symbolName)
                .font(.title3)
                .foregroundStyle(AppColor.background)
        }
        .frame(height: 64)
    }
}

#Preview {
    LightOfYearCollageView(
        year: 2026,
        moments: [
            Moment(text: "Coffee on the balcony", emotion: .joy),
            Moment(text: "A friend called", emotion: .love),
            Moment(text: "A quiet evening", emotion: .calm)
        ]
    )
}
