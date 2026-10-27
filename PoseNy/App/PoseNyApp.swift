import SwiftUI

@main
struct PoseNyApp: App {
    @StateObject private var favorites = FavoritesStore()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                LibraryView()
            }
            .environmentObject(favorites)
        }
    }
}
