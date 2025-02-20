//
//  ModelStateTracker.swift
//
//  Created by Osamu Sakamoto on 2025/02/21.
//  Copyright © 2025 Osamu Sakamoto. All rights reserved.
//
import Foundation
import SwiftData

@Observable public final class ModelTrackingState<Model : FW.Model> : Identifiable, Sendable {
    public let id: Model.ID
    fileprivate(set) var version: Int
    fileprivate(set) var isDeleted: Bool = false
    init(id: Model.ID, version: Int=0) {
        self.id = id
        self.version = version
    }
}
@Observable public final class ModelCollectionTrackingState : Sendable {
    fileprivate(set) var version: Int
    fileprivate(set) var isDeleted: Bool = false
    init(version: Int=0) {
        self.version = version
    }
}

public class ModelStateTracker<Model : FW.Model> {
    open func trackModel(_ id: Model.ID) -> ModelTrackingState<Model> {
        fatalError("trackModel must be implemented")
    }
    open func trackCollection() -> ModelCollectionTrackingState {
        fatalError("trackCollection must be implemented")
    }
}

extension FW {
    public class MutableModelStateTracker<Model : FW.Model> : ModelStateTracker<Model> {
        open func collectionDidReset() {
        }
        open func collectionDidChange() {
        }
        open func modelDidInsert(_ id: Model.ID) {
        }
        open func modelDidUpdate(_ id: Model.ID) {
        }
        open func modelDidDelete(_ id: Model.ID) {
        }
    }
}

extension FWImpl {
    /**
        Implementation of ModelStateTracker, all method must be called on MainActor
     */
    public class MainModelStateTracker<Model : FW.Model>: FW.MutableModelStateTracker<Model> {
        private let modelStates = NSMapTable<NSObject, ModelTrackingState<Model>>(keyOptions: NSPointerFunctions.Options.strongMemory, valueOptions: NSPointerFunctions.Options.weakMemory)
        private var collectionState: ModelCollectionTrackingState?
        
        public override func trackModel(_ id: Model.ID) -> ModelTrackingState<Model> {
            let key = toKey(id)
            return MainActor.assumeIsolated {
                if let state = self.modelStates.object(forKey: key) {
                    return state
                }
                let state = ModelTrackingState<Model>(id: id)
                self.modelStates.setObject(state, forKey: key)
                return state
            }
        }
        
        public override func trackCollection() -> ModelCollectionTrackingState {
            return MainActor.assumeIsolated {
                if let state = self.collectionState {
                    return state
                }
                let state = ModelCollectionTrackingState()
                self.collectionState = state
                return state
            }
        }
        
        public override func collectionDidReset() {
            MainActor.assumeIsolated(collectionDidResetInMain)
        }
        
        private func collectionDidResetInMain() {
            if let state = self.collectionState {
                state.version += 1
            }
            if let iter = modelStates.objectEnumerator() {
                iter.forEach { state in
                    if let state = state as? ModelTrackingState<Model> {
                        if !state.isDeleted {
                            state.version += 1
                        }
                    }
                }
            }
        }
        public override func collectionDidChange() {
            MainActor.assumeIsolated {
                if let collection = self.collectionState {
                    collection.version += 1
                }
            }
        }

        public override func modelDidInsert(_ id: Model.ID) {
            let key = toKey(id)
            MainActor.assumeIsolated {
                if let state = self.modelStates.object(forKey: key) {
                    if !state.isDeleted {
                        return
                    }
                    state.version += 1
                }
                if let collection = self.collectionState {
                    collection.version += 1
                }
            }
        }
        
        public override func modelDidUpdate(_ id: Model.ID) {
            let key = toKey(id)
            MainActor.assumeIsolated {
                if let state = self.modelStates.object(forKey: key) {
                    if state.isDeleted {
                        FWImpl.logger.warning("MainModelStateTracker::modelDidUpdate model \(key) is deleted. version=\(state.version)")
                    }
                    state.version += 1
                }
                if let collection = self.collectionState {
                    collection.version += 1
                }
            }
        }

        public override func modelDidDelete(_ id: Model.ID) {
            let key = toKey(id)
            MainActor.assumeIsolated {
                if let state = self.modelStates.object(forKey: key) {
                    guard !state.isDeleted else {
                        return
                    }
                    state.isDeleted = true
                    state.version += 1
                }
                if let collection = self.collectionState {
                    collection.version += 1
                }
            }
        }
                
        @inline(__always) private func toKey(_ id: Model.ID) -> NSObject {
            return id.id.hashValue as NSObject
        }
    }
}

