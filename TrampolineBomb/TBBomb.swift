//
//  TBBomb.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/21.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import SpriteKit

enum TBBombState {
    case normal
    case exploding
}

class TBBomb : SKNode {

    private let sprite: SKSpriteNode
    var state = TBBombState.normal

    private let shadow: SKShapeNode

    var bombSpeed: CGPoint = CGPoint.zero
    var zHeight: CGFloat = 1

    private var _jumpDistance: CGFloat = 1
    var jumpDistance: CGFloat {
        get {
            return _jumpDistance
        }
        set {
            if newValue == 0 { return }
            _jumpDistance = newValue
        }
    }

    private var jumpedDistance: CGFloat = 0

    override init() {
        sprite = SKSpriteNode(imageNamed: "bomb")
        sprite.zPosition = Z_POS
        sprite.size = BOMB_SIZE

        shadow = SKShapeNode(ellipseOf: CGSize(width: BOMB_SIZE.width, height: BOMB_SIZE.height / 2))
        shadow.fillColor = UIColor.black
        shadow.zPosition = Z_POS - 1

        super.init()
        self.addChild(shadow)
        self.addChild(sprite)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func initiateNewDirection(target: CGPoint, newSpeed: CGFloat) {
        var distance = CGPoint.distance(first: target, second: self.position)
        if distance == 0 {
            distance = 1
        }
        self.jumpDistance = distance
        self.jumpedDistance = 0
        self.bombSpeed = (SPEED_MULTIPLIER / distance) * (target - self.position)
        self.zHeight = 0.1
    }

    func update() {
        if state == .normal {
            self.position += bombSpeed
            jumpedDistance += hypot(bombSpeed.x, bombSpeed.y)
            zHeight = getParabolaHeight(x: 2 * jumpedDistance / jumpDistance - 1) + 0.1
            sprite.setScale(scaleByHeight)
            sprite.position.y = BOMB_SIZE.height * (zHeight * 2 + 0.5)
        }
    }

    private var scaleByHeight: CGFloat {
        get {
            return zHeight / 2 + 1 // zHeight = 0 ~ 1, scale = 1 ~ 1.5
        }
    }
}

let BOMB_SIZE = CGSize(width: 30, height: 30)

private let Z_POS: CGFloat = 200
private let SPEED_MULTIPLIER: CGFloat = 3

private func getParabolaHeight(x: CGFloat) -> CGFloat {
    // y = 1 - x^2, -1 <= x <= 1
    return 1 - x*x
}
