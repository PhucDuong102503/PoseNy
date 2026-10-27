import Foundation

final class FavoritesStore: ObservableObject {
    @Published private(set) var ids: Set<String>

    private let key = "favoritePoseIDs"

    init() {
        ids = Set(UserDefaults.standard.stringArray(forKey: key) ?? [])
    }

    func contains(_ pose: Pose) -> Bool { ids.contains(pose.id) }

    func toggle(_ pose: Pose) {
        if ids.contains(pose.id) { ids.remove(pose.id) } else { ids.insert(pose.id) }
        UserDefaults.standard.set(Array(ids), forKey: key)
    }
}
