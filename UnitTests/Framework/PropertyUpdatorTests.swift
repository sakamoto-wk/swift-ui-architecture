//
//  PropertyUpdatorTests.swift
//
//  Created by Osamu Sakamoto on 2025/02/21.
//  Copyright © 2025 Osamu Sakamoto. All rights reserved.
//

import Foundation
import Testing
@testable import CountriesSwiftUI

@Suite struct PropertyUpdatorTests {
    class A {
        var i1: Int = 0
        var i2: Int? = nil
        var s1: String? = nil
    }

    struct S {
        var i1: Int = 0
        var i2: Int? = nil
        var s1: String? = nil
    }

    class B {
        var i1: Int = 0
        var i2: Int? = nil
        var string: String? = nil
    }

    @available(iOS, deprecated: 9.0)
    @Test func classUpdator() {
        var updator1 = ClassUpdator<A, B>.builder()
            .update(\.i1, with: \.i1)
            .update(\.i2, with: \.i2)
            .update(\.s1, with: \.string)
            .build()
        var b = B()
        b.i1 = 12
        b.i2 = 3
        b.string = "hello"
        var a = A()
        updator1.update(a, with: b)

        #expect(a.i1 == 12)
        #expect(a.i2 == 3)
        #expect(a.s1 == "hello")

        b.i1 = -1
        b.i2 = nil
        b.string = nil
        updator1.update(a, with: b)
        #expect(a.i1 == -1)
        #expect(a.i2 == nil)
        #expect(a.s1 == nil)
    }

    
    @available(iOS, deprecated: 9.0)
    @Test func structUpdator() {
        var updator1 = StructUpdator<S, B>.builder()
            .update(\.i1, with: \.i1)
            .update(\.i2, with: \.i2)
            .update(\.s1, with: \.string)
            .build()
        var b = B()
        b.i1 = 12
        b.i2 = 3
        b.string = "hello"
        var s = S()
        s = updator1.update(s, with: b)

        #expect(s.i1 == 12)
        #expect(s.i2 == 3)
        #expect(s.s1 == "hello")

        b.i1 = -1
        b.i2 = nil
        b.string = nil
        s = updator1.update(s, with: b)
        #expect(s.i1 == -1)
        #expect(s.i2 == nil)
        #expect(s.s1 == nil)
    }

}
