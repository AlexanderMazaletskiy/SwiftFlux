//
//  ActionCreatorSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/11/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Result
import SwiftFlux

class ActionCreatorSpec: QuickSpec {
    struct ActionCreatorTestModel {
        let name: String
    }

    struct ActionCreatorTestAction: Action {
        typealias Payload = ActionCreatorTestModel
        func invoke(dispatcher: Dispatcher) {
            dispatcher.dispatch(self, result: Result(value: ActionCreatorTestModel(name: "test")))
        }
    }

    struct ActionCreatorDefaultErrorAction: Action {
        typealias Payload = ActionCreatorTestModel
        func invoke(dispatcher: Dispatcher) {
            dispatcher.dispatch(self, result: Result(error: NSError(domain: "TEST00000", code: -1, userInfo: [:])))
        }
    }

    enum ActionError: ErrorType {
        case UnexpectedError(NSError)
    }

    struct ActionCreatorErrorAction: Action {
        typealias Payload = ActionCreatorTestModel
        typealias Error = ActionError
        func invoke(dispatcher: Dispatcher) {
            let error = ActionError.UnexpectedError(
                NSError(domain: "TEST00000", code: -1, userInfo: [:])
            )
            dispatcher.dispatch(self, result: Result(error: error))
        }
    }

    override func spec() {
        describe("invoke", { () in
            var results = [String]()
            var fails = [String]()
            var callbacks = [String]()

            beforeEach({ () -> () in
                results = []
                fails = []
                callbacks = []
                
                let id1 = ActionCreator.dispatcher.register(ActionCreatorTestAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.name)1")
                    case .Failure(_):
                        fails.append("fail1")
                    }
                }
                let id2 = ActionCreator.dispatcher.register(ActionCreatorErrorAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.name)2")
                    case .Failure(let error):
                        fails.append("fail2 \(error.dynamicType)")
                    }
                }
                let id3 = ActionCreator.dispatcher.register(ActionCreatorDefaultErrorAction.self) { (result) in
                    switch result {
                    case .Success(let box):
                        results.append("\(box.name)3")
                    case .Failure(let error):
                        fails.append("fail3 \(error.dynamicType)")
                    }
                }
                callbacks.append(id1)
                callbacks.append(id2)
                callbacks.append(id3)
            })
            
            afterEach({ () -> () in
                for id in callbacks {
                    ActionCreator.dispatcher.unregister(id)
                }
            })
            
            context("when action succeeded") {
                it("should dispatch to registered callback handlers") {
                    let action = ActionCreatorTestAction()
                    ActionCreator.invoke(action)

                    expect(results.count).to(equal(1))
                    expect(fails.isEmpty).to(beTruthy())
                    expect(results).to(contain("test1"))
                }
            }

            context("when action failed with error type") {
                it("should dispatch to registered callback handlers") {
                    let action = ActionCreatorErrorAction()
                    ActionCreator.invoke(action)
                    
                    expect(fails.count).to(equal(1))
                    expect(results.isEmpty).to(beTruthy())
                    expect(fails).to(contain("fail2 ActionError"))
                }
            }

            context("when action failed") {
                it("should dispatch to registered callback handlers") {
                    let action = ActionCreatorDefaultErrorAction()
                    ActionCreator.invoke(action)
                    
                    expect(fails.count).to(equal(1))
                    expect(results.isEmpty).to(beTruthy())
                    expect(fails).to(contain("fail3 NSError"))
                }
            }
        })
    }
}
