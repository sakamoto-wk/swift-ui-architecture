//
//  ModelVersion.swift
//
//  Created by Osamu Sakamoto on 2025/02/22.
//  Copyright © 2025 Osamu Sakamoto. All rights reserved.
//

import SwiftUI


@Observable
public class ModelVersionState<Model : FW.Model> {
    fileprivate(set) var model: Model {
        didSet {
            if let state = self.state, state.id == model.id {
                return
            }
            if let tracker = self.tracker {
                self.state = tracker.trackModel(model.id) as ModelTrackingState<Model>
            }
        }
    }
    private var state: ModelTrackingState<Model>?
    private weak var tracker: ModelStateTracker<Model>?
    init(_ model: Model) {
        self.model = model
    }
    public var version : Int {
        return state?.version ?? -1
    }
    public var isDeleted : Bool {
        return state?.isDeleted ?? false
    }
    public func setup(_ tracker: ModelStateTracker<Model>) {
        guard self.tracker !== tracker else { return }
        self.tracker = tracker
        self.state = tracker.trackModel(model.id)
    }
}

@propertyWrapper
public struct ModelVersion<Model : FW.Model> : DynamicProperty {
    @State private var state: ModelVersionState<Model>
    public init(wrappedValue: Model) {
        self.state = .init(wrappedValue)
    }
    
    public var wrappedValue: Model {
        get { return self.state.model }
        nonmutating set {
            self.state.model = newValue
        }
    }
    
    public var projectedValue: ModelVersionState<Model> { state }
}


@Observable
public class ModelArrayVersionState<Model : FW.Model> {
    fileprivate(set) var models: Array<Model>
    private var state: ModelCollectionTrackingState?
    private weak var tracker: ModelStateTracker<Model>?
    init(_ models: Array<Model>) {
        self.models = models
    }
    public var version : Int {
        return state?.version ?? -1
    }
    public func setup(_ tracker: ModelStateTracker<Model>) {
        guard self.tracker !== tracker else { return }
        self.tracker = tracker
        self.state = tracker.trackCollection()
    }
}


@propertyWrapper
public struct ModelArrayVersion<Model:FW.Model> : DynamicProperty {
    @State private var state: ModelArrayVersionState<Model>
    public init(wrappedValue: Array<Model>) {
        self.state = .init(wrappedValue)
    }
    
    public var wrappedValue: Array<Model> {
        get { return self.state.models }
        nonmutating set {
            self.state.models = newValue
        }
    }
    
    public var projectedValue: ModelArrayVersionState<Model> { state }
}

