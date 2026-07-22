import SwiftUI
import UIKit

/// A single glowing "card of light" — emotion color, optional photo, text.
struct MomentCardView: View {
    let moment: Moment
    let dependencies: AppDependencies

    @State private var photo: UIImage?

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [moment.emotion.color.opacity(0.95), AppColor.surface],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 280, height: 380)
                    .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    .overlay(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.6)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                    )
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: moment.emotion.symbolName)
                    Text(moment.emotion.displayName)
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppColor.text)

                Text(moment.text)
                    .font(.title3.weight(.medium))
                    .foregroundStyle(AppColor.text)
                    .lineLimit(5)

                HStack(spacing: 10) {
                    if moment.hasVoiceNote {
                        Image(systemName: "waveform")
                            .foregroundStyle(AppColor.text.opacity(0.8))
                    }
                    Text(moment.createdAt.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption2)
                        .foregroundStyle(AppColor.text.opacity(0.65))
                }
            }
            .padding(20)
        }
        .frame(width: 280, height: 380)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .warmGlow(color: moment.emotion.color)
        .task(id: moment.photoFileName) {
            await loadPhotoIfNeeded()
        }
    }

    private func loadPhotoIfNeeded() async {
        guard let fileName = moment.photoFileName else { return }
        if let data = await dependencies.loadMediaData(fileName: fileName, kind: .photo) {
            photo = UIImage(data: data)
        }
    }
}

#Preview {
    MomentCardView(
        moment: Moment(text: "Morning coffee in the first sunlight", emotion: .calm),
        dependencies: PreviewSupport.dependencies
    )
    .padding()
    .background(AppColor.background)
}
