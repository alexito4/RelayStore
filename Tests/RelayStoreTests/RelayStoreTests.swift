import ComposableArchitecture
import RelayStore
import XCTest

final class RelayStoreTests: XCTestCase {
    func testRelay() throws {
        var relayedNumber: Int?

        let store = TestStore(
            initialState: .init(),
            reducer: reducer.relay { action in
                switch action {
                case let .someAction(number):
                    relayedNumber = number
                }
            },
            environment: .init()
        )

        store.send(.someAction(42))
        XCTAssertEqual(relayedNumber, 42)
    }

    func testRelayCasePath() throws {
        var relayedNumber: Int?

        let store = TestStore(
            initialState: .init(),
            reducer: reducer.relay(/Action.someAction) { number in
                relayedNumber = number
            },
            environment: .init()
        )

        store.send(.someAction(42))
        XCTAssertEqual(relayedNumber, 42)
    }

    func testRelayStore() throws {
        let relayStore = RelayStore(
            initialState: .init(),
            reducer: reducer,
            environment: .init()
        )

        var relayedNumber: Int?

        let realStore = relayStore.storeWithRelay {
            switch $0 {
            case let .someAction(number):
                relayedNumber = number
            }
        }

        ViewStore(realStore).send(.someAction(42))
        XCTAssertEqual(relayedNumber, 42)

        // Real store is cached
        XCTAssert(
            realStore === relayStore.storeWithRelay {
                switch $0 {
                case let .someAction(number):
                    relayedNumber = number
                }
            }
        )
    }
}

struct State: Equatable {}
enum Action: Equatable {
    case someAction(Int)
}

struct Environment {}
let reducer = Reducer<State, Action, Environment>.empty
