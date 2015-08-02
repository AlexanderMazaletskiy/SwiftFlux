//
//  EventEmitterSpec.swift
//  SwiftFlux
//
//  Created by Kenichi Yonekawa on 8/2/15.
//  Copyright (c) 2015 mog2dev. All rights reserved.
//

import Quick
import Nimble
import Box
import Result
import SwiftFlux

class EventEmitterSpec: QuickSpec {
    override func spec() {
        class TestStore: Store {
            static let instance = TestStore()
            enum TestEvent {
                case List
                case Created
            }
            typealias Event = TestEvent
        }
        class TestStore2: Store {
            static let instance = TestStore2()
            enum TestEvent {
                case List
                case Created
            }
            typealias Event = TestEvent
        }

        describe("emit") {
            var listeners = [String]()
            var results = [String]()

            beforeEach({ () -> () in
                listeners = []
                let id1 = EventEmitter.listen(TestStore.instance, event: TestStore.Event.List, handler: { () -> Void in
                    results.append("test list")
                })
                let id2 = EventEmitter.listen(TestStore2.instance, event: TestStore2.Event.List, handler: { () -> Void in
                    results.append("test2 list")
                })
                let id3 = EventEmitter.listen(TestStore.instance, event: TestStore.Event.Created, handler: { () -> Void in
                    results.append("test created")
                })
                listeners.append(id1)
                listeners.append(id2)
                listeners.append(id3)
            })

            afterEach({ () -> () in
                for listener in listeners {
                    EventEmitter.unlisten(listener)
                }
            })
            
            it("should fire event correctly") {
                EventEmitter.emit(TestStore.instance, event: TestStore.Event.List)
                expect(results.count).to(equal(1))
                expect(results[0]).to(equal("test list"))
 
                EventEmitter.emit(TestStore.instance, event: TestStore.Event.List)
                expect(results.count).to(equal(2))
                expect(results[1]).to(equal("test list"))

                EventEmitter.emit(TestStore2.instance, event: TestStore2.Event.List)
                expect(results.count).to(equal(3))
                expect(results[2]).to(equal("test2 list"))

                EventEmitter.emit(TestStore.instance, event: TestStore.Event.Created)
                expect(results.count).to(equal(4))
                expect(results[3]).to(equal("test created"))

                EventEmitter.unlisten(listeners[2])
                EventEmitter.emit(TestStore.instance, event: TestStore.Event.Created)
                expect(results.count).to(equal(4))
            }
        }
    }
}