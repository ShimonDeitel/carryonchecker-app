import Foundation
import Combine

final class CarryOnCheckerStore: ObservableObject {
    static let freeTierLimit = 20

    @Published var bags: [Bag] = [] { didSet { persist() } }
    @Published var airlines: [AirlinePreset] = [] { didSet { persist() } }

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("carryoncheckerstore.json")
        load()
    }

    var isAtFreeLimit: Bool { bags.count >= Self.freeTierLimit }

    func canAdd(isPro: Bool) -> Bool {
        isPro || bags.count < Self.freeTierLimit
    }

    func add(_ bag: Bag, isPro: Bool) -> Bool {
        guard canAdd(isPro: isPro) else { return false }
        bags.append(bag)
        return true
    }

    func remove(at offsets: IndexSet) {
        bags.remove(atOffsets: offsets)
    }

    func update(_ bag: Bag) {
        if let idx = bags.firstIndex(where: { $0.id == bag.id }) {
            bags[idx] = bag
        }
    }

    func airline(for id: UUID) -> AirlinePreset? {
        airlines.first(where: { $0.id == id })
    }

    private func seedIfNeeded() {
        if airlines.isEmpty {
            airlines = [
                AirlinePreset(name: "Standard Economy", maxLengthCM: 56, maxWidthCM: 45, maxHeightCM: 25, maxWeightKG: 10),
                AirlinePreset(name: "Budget Carrier", maxLengthCM: 55, maxWidthCM: 40, maxHeightCM: 20, maxWeightKG: 7),
                AirlinePreset(name: "Premium Carrier", maxLengthCM: 60, maxWidthCM: 46, maxHeightCM: 28, maxWeightKG: 12),
            ]
        }
        if bags.isEmpty, let first = airlines.first {
            bags = [Bag(name: "My Backpack", lengthCM: 45, widthCM: 30, heightCM: 20, weightKG: 6, airlineID: first.id)]
        }
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(PersistedState(bags: bags, airlines: airlines)) {
            try? data.write(to: fileURL)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else {
            seedIfNeeded()
            return
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let state = try? decoder.decode(PersistedState.self, from: data) {
            self.bags = state.bags
            self.airlines = state.airlines
        }
        seedIfNeeded()
    }

    struct PersistedState: Codable {
        var bags: [Bag]
        var airlines: [AirlinePreset] = []
    }

}
