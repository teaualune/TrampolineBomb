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

    func makeBomb(isUpper: Bool) -> TBBomb {
        let bomb = TBBomb()
        let size = bomb.frame.width
        let x = 2 * (getHalfBool() ? -size : size) + fieldWidth
        let y = getRandBetween(isUpper ? upperRange : lowerRange)
        bomb.position = CGPointMake(x, y)
        resetBombNextState(bomb, isUpper: isUpper)
        return bomb
    }

    func shouldMakeBomb(turn: Int) -> Bool {
        return CREATE_BOMB_AT.indexOf(turn) != nil
    }

    func pickTargetPosition(yRange: SKRange) -> CGPoint {
        return CGPointMake(getRandBetween(fieldWidth, lower: 0), getRandBetween(yRange.upperLimit, lower: yRange.lowerLimit))
    }

    func resetBombNextState(bomb: TBBomb, isUpper: Bool) {
        bomb.initiateNewDirection(pickTargetPosition(isUpper ? upperRange : lowerRange), newSpeed: getRand() + 1)
    }
}

private let CREATE_BOMB_AT: [Int] = [0, 15, 24, 29, 34]

private func getRand() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(RAND_MAX))
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