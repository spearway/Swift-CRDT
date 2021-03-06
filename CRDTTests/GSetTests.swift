//
//  GSetTests.swift
//  CRDTTests
//
//  Created by Dominique d'Argent on 24.07.17.
//  Copyright © 2017 Dominique d'Argent. All rights reserved.
//

import XCTest
@testable import CRDT

class GSetTests: XCTestCase {
    
    func testInitialValue() {
        let set = newSet()
        
        XCTAssertEqual(set.value, Set())
    }
    
    func testAdd() {
        var set = newSet()
        
        set.add(1)
        XCTAssertEqual(set.value, [1])
        
        set.add(2)
        XCTAssertEqual(set.value, [1, 2])
        
        set.add(3)
        XCTAssertEqual(set.value, [1, 2, 3])
        
        // add is idempotent
        set.add(3)
        XCTAssertEqual(set.value, [1, 2, 3])
    }
    
    func testJoin() {
        var a = newSet()                        // {}
        var b = newSet()                        // {}
        
        a.add(1)                                // {1}
        b.add(2)                                // {2}
        
        let join = a.joining(other: b)          // {1, 2}
        XCTAssertEqual(join.value, [1, 2])
        
        // join is least upper bound (LUB) of a and b
        XCTAssert(a <= join)
        XCTAssert(b <= join)
        
        a.join(other: b)                        // {1, 2}
        b.join(other: a)                        // {1, 2}
        
        XCTAssert(a <= b)
        XCTAssert(b <= a)
    }
    
    func testPartiallyOrdered() {
        var a = newSet()                        // {}
        var b = newSet()                        // {}
        
        XCTAssert(a <= b)
        XCTAssert(b <= a)
        XCTAssertFalse(a.isConcurrent(to: b))
        XCTAssertFalse(b.isConcurrent(to: a))
        
        a.add(1)                                // {1}
        a.add(2)                                // {1, 2}
        
        XCTAssertFalse(a <= b)
        XCTAssert(b <= a)
        XCTAssertFalse(a.isConcurrent(to: b))
        XCTAssertFalse(b.isConcurrent(to: a))
        
        b.add(2)                                // {2}
        b.add(3)                                // {2, 3}
        
        XCTAssertFalse(a <= b)
        XCTAssertFalse(b <= a)
        XCTAssert(a.isConcurrent(to: b))
        XCTAssert(b.isConcurrent(to: a))
        
        a.join(other: b)                        // {1, 2, 3}
        
        XCTAssertFalse(a <= b)
        XCTAssert(b <= a)
        XCTAssertFalse(a.isConcurrent(to: b))
        XCTAssertFalse(b.isConcurrent(to: a))
        
        b.join(other: a)                        // {1, 2, 3}
        
        XCTAssert(a <= b)
        XCTAssert(b <= a)
        XCTAssertFalse(a.isConcurrent(to: b))
        XCTAssertFalse(b.isConcurrent(to: a))
    }
    
    func testSequence() {
        var set = newSet()
        set.add(1)
        set.add(2)
        set.add(3)
        set.add(4)
        set.add(5)
        
        XCTAssertEqual(Set(set), [1, 2, 3, 4, 5])
    }
    
    func testContains() {
        var set = newSet()
        XCTAssertFalse(set.contains(1))
        
        set.add(1)
        XCTAssert(set.contains(1))
    }
    
}

// MARK: - Util
fileprivate func newSet() -> GSet<Int> {
    return GSet()
}
