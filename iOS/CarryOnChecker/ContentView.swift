import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: CarryOnCheckerStore
    @EnvironmentObject var purchases: PurchaseManager
    @State private var showingAdd = false
    @State private var showingPaywall = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.bags) { bag in
                    if let airline = store.airline(for: bag.airlineID) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(bag.name).font(Theme.headlineFont)
                                Spacer()
                                Image(systemName: bag.fits(airline) ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundStyle(bag.fits(airline) ? .green : .red)
                            }
                            Text("\(airline.name) · \(String(format: "%.0f", bag.lengthCM))x\(String(format: "%.0f", bag.widthCM))x\(String(format: "%.0f", bag.heightCM))cm, \(String(format: "%.1f", bag.weightKG))kg")
                                .font(Theme.captionFont)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .onDelete { store.remove(at: $0) }
            }
            .navigationTitle("Carry-on Checker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { showingSettings = true } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .accessibilityIdentifier("main.settingsButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if store.canAdd(isPro: purchases.isPro) {
                            showingAdd = true
                        } else {
                            showingPaywall = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                    .accessibilityIdentifier("main.addButton")
                }
            }
            .sheet(isPresented: $showingAdd) { AddBagView() }
            .sheet(isPresented: $showingPaywall) { PaywallView() }
            .sheet(isPresented: $showingSettings) { SettingsView() }
        }
    }
}

struct AddBagView: View {
    @EnvironmentObject var store: CarryOnCheckerStore
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var length = "45"
    @State private var width = "30"
    @State private var height = "20"
    @State private var weight = "6"
    @State private var airlineID: UUID?

    var body: some View {
        NavigationStack {
            Form {
                Section("Bag") {
                    TextField("Name", text: $name)
                        .accessibilityIdentifier("addBag.nameField")
                    TextField("Length (cm)", text: $length).keyboardType(.decimalPad)
                    TextField("Width (cm)", text: $width).keyboardType(.decimalPad)
                    TextField("Height (cm)", text: $height).keyboardType(.decimalPad)
                    TextField("Weight (kg)", text: $weight).keyboardType(.decimalPad)
                }
                Section("Airline") {
                    Picker("Airline", selection: $airlineID) {
                        ForEach(store.airlines) { airline in
                            Text(airline.name).tag(Optional(airline.id))
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { hideKeyboard() }
            .navigationTitle("Add Bag")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        guard let aid = airlineID ?? store.airlines.first?.id else { return }
                        let bag = Bag(name: name.isEmpty ? "Bag" : name,
                                      lengthCM: Double(length) ?? 0,
                                      widthCM: Double(width) ?? 0,
                                      heightCM: Double(height) ?? 0,
                                      weightKG: Double(weight) ?? 0,
                                      airlineID: aid)
                        _ = store.add(bag, isPro: purchases.isPro)
                        dismiss()
                    }
                    .accessibilityIdentifier("addBag.saveButton")
                }
            }
            .onAppear { airlineID = store.airlines.first?.id }
        }
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
