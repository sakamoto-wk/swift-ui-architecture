//
//  Model.swift
//
//  Created by Osamu Sakamoto on 2025/02/20.
//  Copyright © 2025 Osamu Sakamoto. All rights reserved.
//

import Foundation
import SwiftData

extension FW {
    /// Base interface for Database model claesses
    public protocol Model : PersistentModel where ID == PersistentIdentifier {
    }
    
    public protocol ModelAccssor {
        func insert<T>(_ model: T) where T : PersistentModel
        func delete<T>(model: T.Type, where predicate: Predicate<T>?, includeSubclasses: Bool) throws where T : PersistentModel
        func delete<T>(_ model: T) where T : PersistentModel
        func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T : PersistentModel
        func fetchCount<T>(_ descriptor: FetchDescriptor<T>) throws -> Int where T : PersistentModel
        func fetch<T>(_ descriptor: FetchDescriptor<T>, batchSize: Int) throws -> FetchResultsCollection<T> where T : PersistentModel
        func fetchIdentifiers<T>(_ descriptor: FetchDescriptor<T>) throws -> [PersistentIdentifier] where T : PersistentModel
        func fetchIdentifiers<T>(_ descriptor: FetchDescriptor<T>, batchSize: Int) throws -> FetchResultsCollection<PersistentIdentifier> where T : PersistentModel
        func find<Model : FW.Model>(_ id: Model.ID) throws -> Model?
        func setRollbackOnly()
    }
    
    public protocol ModelService {
        @discardableResult
        func transaction<T>(_ block: sending @escaping (ModelAccssor) throws -> T) async rethrows -> sending T
        
        @discardableResult
        func query<T>(_ block: sending @escaping (ModelAccssor) throws -> T) async rethrows -> sending T
    }
}

extension FW.ModelAccssor {
    public func delete<T>(model: T.Type, where predicate: Predicate<T>? = nil, includeSubclasses: Bool = true) throws where T : PersistentModel {
        try! self.delete(model: model, where: predicate, includeSubclasses: includeSubclasses)
    }
}
