//
//  DefaultModelService.swift
//
//  Created by Osamu Sakamoto on 2025/02/23.
//  Copyright © 2025 Osamu Sakamoto. All rights reserved.
//

import Foundation
import SwiftData


extension FWImpl {
    protocol ContextModelAccessor : FW.ModelAccssor {
        var context: ModelContext {get}
    }
    
    public class DefaultModelService : FW.ModelService {
        private class Accessor : ContextModelAccessor {
            @TaskLocal fileprivate static var nestLevel:Int = 0
            private(set) var context: ModelContext
            fileprivate var shouldRollback: Bool = false
            init(_ context: ModelContext) {
                self.context = context
            }
            func setRollbackOnly() {
                shouldRollback = true
            }
        }

        @ModelActor
        fileprivate actor ServiceActor {
            func execute<T>(_ block: sending @escaping (ModelContext) throws -> T) rethrows -> sending T {
                return try! block(self.modelContext)
            }
        }
        private var serviceActor: ServiceActor
        public init (_ container: ModelContainer) {
            serviceActor = ServiceActor(modelContainer: container)
        }
        public func transaction<T>(_ block: sending @escaping (any FW.ModelAccssor) throws -> T) async rethrows -> sending T {
            return await self.serviceActor.execute { context in
                let nestLevel = Accessor.nestLevel
                if nestLevel != 0 {
                    fatalError("should not nest transactions(\(nestLevel)")
                }
                // do not save dirty udpates outside transaction.
                context.rollback()
                let accessor = Accessor(context)
                var success = false
                defer {
                    if success && !accessor.shouldRollback {
                        try! context.save()
                    } else {
                        context.rollback()
                    }
                }
                let ret = Accessor.$nestLevel.withValue(nestLevel + 1) {
                    return try! block(accessor)
                }
                success = true
                return ret
            }
        }
        
        public func query<T>(_ block: sending @escaping (any FW.ModelAccssor) throws -> T) async rethrows -> sending T {
            return await self.serviceActor.execute { context in
                let accessor = Accessor(context)
                return try! block(accessor)
            }
        }
    }
}

/// ModelAccessor operations
extension FWImpl.ContextModelAccessor {
    public func insert<T>(_ model: T) where T : PersistentModel {
        self.context.insert(model)
    }

    public func delete<T>(model: T.Type, where predicate: Predicate<T>?, includeSubclasses: Bool) throws where T : PersistentModel {
        try! self.context.delete(model: model, where: predicate, includeSubclasses: includeSubclasses)
    }

    public func delete<T>(_ model: T) where T : PersistentModel {
        self.context.delete(model)
    }
    
    public func fetch<T>(_ descriptor: FetchDescriptor<T>) throws -> [T] where T : PersistentModel {
        return try! self.context.fetch(descriptor)
    }
    
    public func fetchCount<T>(_ descriptor: FetchDescriptor<T>) throws -> Int where T : PersistentModel {
        return try! self.context.fetchCount(descriptor)
    }
    
    public func fetch<T>(_ descriptor: FetchDescriptor<T>, batchSize: Int) throws -> FetchResultsCollection<T> where T : PersistentModel {
        return try! self.context.fetch(descriptor, batchSize: batchSize)
    }
    
    public func fetchIdentifiers<T>(_ descriptor: FetchDescriptor<T>) throws -> [PersistentIdentifier] where T : PersistentModel {
        return try! self.context.fetchIdentifiers(descriptor)
    }
    
    public func fetchIdentifiers<T>(_ descriptor: FetchDescriptor<T>, batchSize: Int) throws -> FetchResultsCollection<PersistentIdentifier> where T : PersistentModel {
        return try! self.context.fetchIdentifiers(descriptor, batchSize: batchSize)
    }
    
    public func find<Model : FW.Model>(_ id: Model.ID) throws -> Model? {
        let ret:Model? = self.context.registeredModel(for: id)
        return ret
    }
}
