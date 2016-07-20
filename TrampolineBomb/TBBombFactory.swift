//
//  TBBombFactory.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/21.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import SpriteKit

class TBBombFactory {

    func makeBomb(isUpper: Bool, inFrame frame: CGRect) -> TBBomb {
        let bomb = TBBomb()
        let size = bomb.frame.width
        let x = 2 * (getHalfBool() ? -size : size) + frame.size.width
        let y = getRandBetween(frame.size.height, isUpper: isUpper)
        bomb.position = CGPointMake(x, y)
        resetBombNextState(bomb, isUpper: isUpper, inFrame: frame)
        return bomb
    }

    func shouldMakeBomb(turn: Int) -> Bool {
        return CREATE_BOMB_AT.indexOf(turn) != nil
    }

    func pickTargetPosition(isUpper: Bool, inFrame frame: CGRect) -> CGPoint {
        return CGPointMake(getRandBetween(frame.size.width), getRandBetween(frame.size.height, isUpper: isUpper))
    }

    func resetBombNextState(bomb: TBBomb, isUpper: Bool, inFrame frame: CGRect) {
        let isUpper = false
        bomb.initiateNewDirection(pickTargetPosition(isUpper, inFrame: frame), newSpeed: getRand() + 1)
    }
}

private let CREATE_BOMB_AT: [Int] = [0, 15, 24, 29, 34]

private func getRand() -> CGFloat {
    return CGFloat(Float(arc4random()) / Float(RAND_MAX))
}

private func getHalfBool() -> Bool {
    return getRand() > 0.5
}

private func getRandBetween(full: CGFloat, isUpper: Bool? = nil) -> CGFloat {
    let upper = (isUpper == nil) ? full : (full / (isUpper! ? 1 : 2))
    let lower = (isUpper == nil) ? 0 : (isUpper! ? full / 2 : 0)
    return getRand() * (upper - lower) + lower
}