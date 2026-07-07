import Foundation

struct AirlinePreset: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var maxLengthCM: Double
    var maxWidthCM: Double
    var maxHeightCM: Double
    var maxWeightKG: Double
}

struct Bag: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String
    var lengthCM: Double
    var widthCM: Double
    var heightCM: Double
    var weightKG: Double
    var airlineID: UUID
    var createdAt: Date = Date()

    func fits(_ airline: AirlinePreset) -> Bool {
        lengthCM <= airline.maxLengthCM &&
        widthCM <= airline.maxWidthCM &&
        heightCM <= airline.maxHeightCM &&
        weightKG <= airline.maxWeightKG
    }
}
