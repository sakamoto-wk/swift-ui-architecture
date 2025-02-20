//
//  PropertyBinder.swift
//
//  Created by Osamu Sakamoto on 2025/02/20.
//  Copyright © 2025 Osamu Sakamoto. All rights reserved.
//

import Foundation


fileprivate struct StructSetter<Type> {
    private let srcPath:AnyKeyPath
    private let setter: (Type, Any) -> Type
    
    init<ValueType>(_ src:AnyKeyPath, to dstPath: WritableKeyPath<Type, ValueType>) {
        self.srcPath = src
        self.setter = {
            var dst = $0
            dst[keyPath: dstPath] = $1 as! ValueType
            return dst
        }
    }
    
    func set(_ src: Any, to dst: Type) -> Type {
        return self.setter(dst, src[keyPath: srcPath] as Any)
    }
}

fileprivate struct ClassSetter<Type> {
    private let srcPath:AnyKeyPath
    private let setter: (Type, Any) -> Type
    
    init<ValueType>(_ src:AnyKeyPath, to dstPath: ReferenceWritableKeyPath<Type, ValueType>) {
        self.srcPath = src
        self.setter = {
            $0[keyPath: dstPath] = $1 as! ValueType
            return $0
        }
    }
    
    func set(_ src: Any, to dst: Type) {
        _ = self.setter(dst, src[keyPath: srcPath] as Any)
    }
}

/**
 Updates the target's properties with values from the source in a declarative manner.
 ** DO NOT use this. Manually setting properties is simpler and clearer.**

 ```swift
 
 var updator1 = ClassUpdator<A, B>.builder()
     .update(\.i1, with: \.i1)
     .update(\.i2, with: \.i2)
     .update(\.s1, with: \.string)
     .build()
 var a = A()
 updator1.update(a, with: b)
 
 // This is simpler and clearer
 a.i1 = b.i1
 a.i2 = b.i2
 a.s1 = b.string

 */
@available(*, deprecated, message: "Set properties manually. This is simpler and clearer.")
public class ClassUpdator<Target: AnyObject, With> {
    private let setters : [ClassSetter<Target>]
    fileprivate init(_ setters: [ClassSetter<Target>]) {
        self.setters = setters
    }
    public func update(_ target:Target, with source:With) {
        for setter in setters {
            setter.set(source, to: target)
        }
    }
    public static func builder() -> Builder<Target, With> {
        return Builder<Target, With>()
    }
    public class Builder<Destination: AnyObject, Source> {
        private var setters : [ClassSetter<Destination>] = []
        fileprivate init(){}
        
        public func build() -> ClassUpdator<Destination, Source> {
            return ClassUpdator<Destination, Source>(self.setters)
        }
        
        public func update<ValueType>(_ target: ReferenceWritableKeyPath<Destination, ValueType>, with source:KeyPath<Source, ValueType>) -> Self {
            self.setters.append(ClassSetter(source, to: target))
            return self
        }
    }
}


/**
 Updates the target struct's properties with values from the source in a declarative manner.
 ** DO NOT use this. Manually setting properties is simpler and clearer.**
 */
@available(*, deprecated, message: "Set properties manually. This is simpler and clearer.")
public class StructUpdator<Target, With> {
    private let setters : [StructSetter<Target>]
    fileprivate init(_ setters: [StructSetter<Target>]) {
        self.setters = setters
    }
    public func update(_ target:Target, with source:With) -> Target {
        var ret = target
        for setter in setters {
            ret = setter.set(source, to: ret)
        }
        return ret
    }
    public static func builder() -> Builder<Target, With> {
        return Builder<Target, With>()
    }
    public class Builder<Destination, Source> {
        private var setters : [StructSetter<Destination>] = []
        fileprivate init(){}
        
        public func build() -> StructUpdator<Destination, Source> {
            return StructUpdator<Destination, Source>(self.setters)
        }
        
        public func update<ValueType>(_ target: WritableKeyPath<Destination, ValueType>, with source:KeyPath<Source, ValueType>) -> Self {
            self.setters.append(StructSetter(source, to: target))
            return self
        }
    }
}
