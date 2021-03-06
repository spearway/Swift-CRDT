//
//  SemiLattice.swift
//  CRDT
//
//  Created by Dominique d'Argent on 24.07.17.
//  Copyright © 2017 Dominique d'Argent. All rights reserved.
//

public protocol PartiallyOrdered: Equatable {
    static func <=(lhs: Self, rhs: Self) -> Bool
}

extension PartiallyOrdered {
    public func isConcurrent(to other: Self) -> Bool {
        return !(self <= other) && !(other <= self)
    }
    
    public static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs <= rhs && rhs <= lhs
    }
}

public protocol Joinable {
    // must be associative, commutative, idempotent
    mutating func join(other: Self)
    func joining(other: Self) -> Self
}

public protocol SemiLattice: PartiallyOrdered {
}

public protocol JoinSemiLattice: SemiLattice, Joinable {
}

extension JoinSemiLattice {
    public func joining(other: Self) -> Self {
        var join = self
        join.join(other: other)
        
        // join is least upper bound of self and other
        assert(self <= join)
        assert(other <= join)
        
        return join
    }
}
