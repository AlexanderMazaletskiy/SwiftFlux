//
//  ReduceStoreSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 11/18/15.
//  Copyright © 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Result
import SwiftFlux

class ReduceStoreSpec: QuickSpec {
    struct CalculateActions {
        struct Plus: Action {
            typealias Payload = Int
            let number: Int
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(value: number))
            }
        }
        struct Minus: Action {
            typealias Payload = Int
            let number: Int
            func invoke(dispatcher: Dispatcher) {
                dispatcher.dispatch(self, result: Result(value: number))
            }
        }
    }

    class CalculateStore: ReduceStore<Int> {
        override init() {
            super.init()

            self.reduce(CalculateActions.Plus.self) { (state, result) -> Int in
                switch result {
                case .Success(let number): return state + number
                default: return state
                }
            }

            self.reduce(CalculateActions.Minus.self) { (state, result) -> Int in
                switch result {
                case .Success(let number): return state - number
                default: return state
                }
            }
        }

        override var initialState: Int {
            return 0
        }
    }

    override func spec() {
        let store = CalculateStore()
        var results = [Int]()
        var callbacks = [String]()
    
        beforeEach { () -> () in
            results = []
            callbacks.append(
                store.eventEmitter.listen(.Changed) { () -> Void in
                    results.append(store.state)
                }
            )
        }

        afterEach({ () -> () in
            for id in callbacks {
                ActionCreator.dispatcher.unregister(id)
            }
        })

        it("should calculate state with number") {
            ActionCreator.invoke(CalculateActions.Plus(number: 3))
            ActionCreator.invoke(CalculateActions.Plus(number: 3))
            ActionCreator.invoke(CalculateActions.Minus(number: 2))
            ActionCreator.invoke(CalculateActions.Minus(number: 1))

            expect(results.count).to(equal(4))
            expect(results[0]).to(equal(3))
            expect(results[1]).to(equal(6))
            expect(results[2]).to(equal(4))
            expect(results[3]).to(equal(3))
        }
    }
}