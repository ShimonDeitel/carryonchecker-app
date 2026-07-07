import XCTest
@testable import CarryOnChecker

final class CarryOnCheckerTests: XCTestCase {
    var store: CarryOnCheckerStore!

    override func setUp() {
        super.setUp()
        store = CarryOnCheckerStore()
    }

    func testSeedDataIsBelowFreeLimit() {
        XCTAssertLessThan(store.bags.count, CarryOnCheckerStore.freeTierLimit)
    }

    func testAddIncreasesCount() {
        let before = store.bags.count
        let added = store.add(Bag(name: "Test", lengthCM: 40, widthCM: 30, heightCM: 20, weightKG: 5, airlineID: store.airlines.first!.id), isPro: false)
        XCTAssertTrue(added)
        XCTAssertEqual(store.bags.count, before + 1)
    }

    func testAddRespectsFreeLimitWhenNotPro() {
        while store.bags.count < CarryOnCheckerStore.freeTierLimit {
            _ = store.add(Bag(name: "Test", lengthCM: 40, widthCM: 30, heightCM: 20, weightKG: 5, airlineID: store.airlines.first!.id), isPro: false)
        }
        let blocked = store.add(Bag(name: "Test", lengthCM: 40, widthCM: 30, heightCM: 20, weightKG: 5, airlineID: store.airlines.first!.id), isPro: false)
        XCTAssertFalse(blocked)
    }

    func testProBypassesFreeLimit() {
        while store.bags.count < CarryOnCheckerStore.freeTierLimit {
            _ = store.add(Bag(name: "Test", lengthCM: 40, widthCM: 30, heightCM: 20, weightKG: 5, airlineID: store.airlines.first!.id), isPro: false)
        }
        let allowed = store.add(Bag(name: "Test", lengthCM: 40, widthCM: 30, heightCM: 20, weightKG: 5, airlineID: store.airlines.first!.id), isPro: true)
        XCTAssertTrue(allowed)
    }

    func testCanAddReflectsLimit() {
        while store.bags.count < CarryOnCheckerStore.freeTierLimit {
            _ = store.add(Bag(name: "Test", lengthCM: 40, widthCM: 30, heightCM: 20, weightKG: 5, airlineID: store.airlines.first!.id), isPro: false)
        }
        XCTAssertFalse(store.canAdd(isPro: false))
        XCTAssertTrue(store.canAdd(isPro: true))
    }

    func testRemoveDecreasesCount() {
        _ = store.add(Bag(name: "Test", lengthCM: 40, widthCM: 30, heightCM: 20, weightKG: 5, airlineID: store.airlines.first!.id), isPro: false)
        let before = store.bags.count
        store.remove(at: IndexSet(integer: 0))
        XCTAssertEqual(store.bags.count, before - 1)
    }

    func testIsAtFreeLimitFalseInitially() {
        XCTAssertFalse(store.isAtFreeLimit)
    }

    func testPersistedStateRoundTrips() {
        let count = store.bags.count
        let reloaded = CarryOnCheckerStore()
        XCTAssertEqual(reloaded.bags.count, count)
    }
}
