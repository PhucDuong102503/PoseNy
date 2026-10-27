import SwiftUI

struct PoseDetailView: View {
    let pose: Pose
    @EnvironmentObject private var favorites: FavoritesStore
    @State private var showCamera = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                PoseFigureView(pose: pose)
                    .frame(maxHeight: 420)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 6) {
                    Text(pose.name).font(.title2.bold())
                    Text(pose.summary).foregroundStyle(.secondary)
                    Text(([pose.category.title] + pose.subjects.map(\.title) + [pose.framing.title]).joined(separator: " · "))
                        .font(.caption)
                        .foregroundStyle(.tint)
                }

                HStack(alignment: .top, spacing: 12) {
                    InfoCard(icon: pose.angle.icon, title: "Góc máy", value: pose.angle.title, detail: pose.angle.detail)
                    InfoCard(icon: "camera.aperture", title: "Ống kính", value: pose.lensLabel, detail: pose.lensDetail)
                }

                InfoCard(icon: "face.smiling", title: "Biểu cảm", value: nil, detail: pose.expression)

                VStack(alignment: .leading, spacing: 10) {
                    Label("Mẹo cho người chụp", systemImage: "lightbulb")
                        .font(.headline)
                    ForEach(Array(pose.tips.enumerated()), id: \.offset) { index, tip in
                        HStack(alignment: .firstTextBaseline, spacing: 10) {
                            Text("\(index + 1)")
                                .font(.caption.bold())
                                .frame(width: 22, height: 22)
                                .background(Color.accentColor.opacity(0.15), in: Circle())
                            Text(tip)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button { favorites.toggle(pose) } label: {
                Image(systemName: favorites.contains(pose) ? "heart.fill" : "heart")
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button { showCamera = true } label: {
                Label("Chụp với dáng này", systemImage: "camera.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding()
            .background(.bar)
        }
        .fullScreenCover(isPresented: $showCamera) {
            CameraScreen(pose: pose)
        }
    }
}

private struct InfoCard: View {
    let icon: String
    let title: String
    let value: String?
    let detail: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(title, systemImage: icon)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
            if let value {
                Text(value).font(.headline)
            }
            Text(detail)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
