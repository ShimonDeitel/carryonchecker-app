import SwiftUI

@main
struct CarryOnCheckerApp: App {
    @StateObject private var store = CarryOnCheckerStore()
    @StateObject private var purchases = PurchaseManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(purchases)
                .tint(Theme.accent)
        }
    }
}
