import ComposableArchitecture
import SwiftUI

public extension Reducer {
    /// Relays actions sent trough this reducer.
    func relay(
        destination: @escaping (Action) -> Void
    ) -> Self {
        combined(
            with: .init { _, action, _ in
                .fireAndForget {
                    destination(action)
                }
            }
        )
    }

    /// Relays actions sent trough this reducer.
    func relay<Value>(
        _ path: CasePath<Action, Value>,
        destination: @escaping (Value) -> Void
    ) -> Self {
        combined(
            with: .init { _, action, _ in
                if let value = path.extract(from: action) {
                    return .fireAndForget {
                        destination(value)
                    }
                } else {
                    return .none
                }
            }
        )
    }
}

/// Use this class when you need to hook into actions of a store.
/// Using directly the `Reducer.relay` forces you to initialize a `Store` directly in the `View.body` since you need
/// to access `self` to update some state. Doing it as a property doesn't work since `self` is not available yet.
/// The update of that state will provoke the `body` to be recomputed, which will recreate the `Store` and cause issues.
/// This class helps solving this situation:
/// 1. Instead of using `Store` in a `let` property use this `RelayStore`. The initializer looks exactly the same.
/// 2. In the `body` when you need to pass a store to the feature view, use `RelayStore.store(relay:)` to get a real
///     store with an injected relay.
public final class RelayStore<State, Action, Environment> {
    private let initialState: State
    private let reducer: Reducer<State, Action, Environment>
    private let environment: Environment
    private var store: Store<State, Action>?

    public init(
        initialState: State,
        reducer: Reducer<State, Action, Environment>,
        environment: Environment
    ) {
        self.initialState = initialState
        self.reducer = reducer
        self.environment = environment
    }

    public func storeWithRelay(_ relay: @escaping (Action) -> Void) -> Store<State, Action> {
        if let store = store {
            return store
        }

        store = .init(
            initialState: initialState,
            reducer: reducer.relay(destination: relay),
            environment: environment
        )
        return store!
    }
}

public extension Binding {
    func hasValue<T>() -> Binding<Bool> where Value == T? {
        .init {
            self.wrappedValue != nil
        } set: { newValue in
            if newValue == false {
                self.wrappedValue = nil
            }
        }
    }
}
