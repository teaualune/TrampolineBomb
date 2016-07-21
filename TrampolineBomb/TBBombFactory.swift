//
//  TBBombFactory.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/21.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import SpriteKit

class TBBombFactory {

    lazy var upperRange: SKRange = SKRange()
    lazy var lowerRange: SKRange = SKRange()

    var fieldWidth: CGFloat = 0

    func makeBomb(isUpper: Bool, targetPosition: CGPoint) -> TBBomb {
        let bomb = TBBomb()
        let size = BOMB_SIZE.width
        let x = getHalfBool() ? -2*size : fieldWidth + 2*size
        let y = getRandBetween(isUpper ? upperRange : lowerRange)
        bomb.position = CGPointMake(x, y)
        resetBombNextState(bomb, isUpper: isUpper, assignPosition: targetPosition)
        return bomb
    }

    func shouldMakeBomb(turn: Int) -> Bool {
        return CREATE_BOMB_AT.indexOf(turn) != nil
    }

    func pickTargetPosition(yRange: SKRange) -> CGPoint {
        return CGPointMake(getRandBetween(fieldWidth, lower: 0), getRandBetween(yRange.upperLimit, lower: yRange.lowerLimit))
    }

    func resetBombNextState(bomb: TBBomb, isUpper: Bool, assignPosition: CGPoint? = nil) {
        bomb.initiateNewDirection(assignPosition ?? pickTargetPosition(isUpper ? upperRange : lowerRange), newSpeed: getRand() + 1)
    }
}

private let CREATE_BOMB_AT: [Int] = [0, 15, 24, 29, 34]

private func getRand() -> CGFloat {
    return CGFloat(arc4random_uniform(100)) / 100
}

private func getHalfBool() -> Bool {
    return getRand() > 0.5
}

private func getRandBetween(range: SKRange) -> CGFloat {
    return getRandBetween(range.upperLimit, lower: range.lowerLimit)
}

private func getRandBetween(upper: CGFloat, lower: CGFloat) -> CGFloat {
    return getRand() * (upper - lower) + lower
}

//private func getRandBetween(full: CGFloat, isUpper: Bool? = nil) -> CGFloat {
//    let upper = (isUpper == nil) ? full : (full / (isUpper! ? 1 : 2))
//    let lower = (isUpper == nil) ? 0 : (isUpper! ? full / 2 : 0)
//    return getRandBetween(upper, lower: lower)
//}