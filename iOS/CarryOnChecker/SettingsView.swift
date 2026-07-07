import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("hapticsEnabled") private var hapticsEnabled = true

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Notifications", isOn: $notificationsEnabled)
                        .accessibilityIdentifier("settings.notificationsToggle")
                    Toggle("Haptics", isOn: $hapticsEnabled)
                        .accessibilityIdentifier("settings.hapticsToggle")
                }

                Section("Subscription") {
                    if purchases.isPro {
                        Label("Pro Unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Button("Upgrade to Pro") {
                            Task { await purchases.purchase() }
                        }
                        .accessibilityIdentifier("settings.upgradeButton")
                    }
                    Button("Restore Purchases") {
                        Task { await purchases.restore() }
                    }
                    .accessibilityIdentifier("settings.restoreButton")
                }

                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/carryonchecker-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/carryonchecker-app/terms.html")!)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settings.doneButton")
                }
            }
        }
    }
}
