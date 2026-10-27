import SwiftUI

struct LibraryView: View {
    @EnvironmentObject private var favorites: FavoritesStore
    @State private var category: PoseCategory?
    @State private var subject: Subject?
    @State private var onlyFavorites = false
    @State private var showFreeCamera = false

    private let columns = [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)]

    private var poses: [Pose] {
        PoseLibrary.all.filter { pose in
            (category.map { pose.category == $0 } ?? true)
                && (subject.map { pose.subjects.contains($0) } ?? true)
                && (!onlyFavorites || favorites.contains(pose))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Chọn dáng, mở camera. AI sẽ chỉ bạn cách chỉnh từng chi tiết ✨")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterChip(title: "Tất cả", icon: "sparkles", isOn: category == nil) { category = nil }
                        ForEach(PoseCategory.allCases) { c in
                            FilterChip(title: c.title, icon: c.icon, isOn: category == c) { category = c }
                        }
                    }
                }

                Picker("Đối tượng", selection: $subject) {
                    Text("Tất cả").tag(Subject?.none)
                    ForEach(Subject.allCases) { s in
                        Text(s.title).tag(Optional(s))
                    }
                }
                .pickerStyle(.segmented)

                if poses.isEmpty {
                    ContentUnavailableView(
                        onlyFavorites ? "Chưa có dáng yêu thích" : "Không có dáng phù hợp",
                        systemImage: onlyFavorites ? "heart" : "figure.stand",
                        description: Text(onlyFavorites ? "Nhấn ♥ ở trang chi tiết để lưu dáng." : "Thử bỏ bớt bộ lọc.")
                    )
                    .padding(.top, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(poses) { pose in
                            NavigationLink(value: pose) {
                                PoseCardView(pose: pose, isFavorite: favorites.contains(pose))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle("PoseNy")
        .navigationDestination(for: Pose.self) { PoseDetailView(pose: $0) }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button { onlyFavorites.toggle() } label: {
                    Image(systemName: onlyFavorites ? "heart.fill" : "heart")
                }
                .accessibilityLabel("Chỉ hiện dáng yêu thích")
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button { showFreeCamera = true } label: {
                    Image(systemName: "camera.fill")
                }
                .accessibilityLabel("Mở camera")
            }
        }
        .fullScreenCover(isPresented: $showFreeCamera) {
            CameraScreen(pose: nil)
        }
    }
}

private struct FilterChip: View {
    let title: String
    let icon: String
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.subheadline.weight(.medium))
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isOn ? Color.accentColor : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(isOn ? Color.white : Color.primary)
        }
        .buttonStyle(.plain)
    }
}

struct PoseCardView: View {
    let pose: Pose
    let isFavorite: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            PoseFigureView(pose: pose)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(alignment: .topTrailing) {
                    if isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(7)
                            .background(Color.black.opacity(0.25), in: Circle())
                            .padding(8)
                    }
                }
                .overlay(alignment: .bottomLeading) {
                    Label(pose.category.title, systemImage: pose.category.icon)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(8)
                }

            Text(pose.name)
                .font(.subheadline.weight(.semibold))
                .lineLimit(1)
            Text((pose.subjects.map(\.title) + [pose.framing.title]).joined(separator: " · "))
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
}
