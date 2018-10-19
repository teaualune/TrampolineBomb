//
//  CGPoint+TrampolineBomb.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2018/10/19.
//  Copyright © 2018 Radioflux. All rights reserved.
//

import UIKit

extension CGPoint {
    static func distance(first: CGPoint, second: CGPoint) -> CGFloat {
        return CGFloat(hypotf(Float(second.x - first.x), Float(second.y - first.y)))
    }
}

func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
}

func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
}

func +=( lhs: inout CGPoint, rhs: CGPoint) {
    lhs = lhs + rhs
}

func *(lhs: CGFloat, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs * rhs.x, y: lhs * rhs.y)
}
