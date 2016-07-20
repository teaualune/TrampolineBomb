//
//  TBPlayer.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/20.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import SpriteKit

enum PlayerNumber : Int, Hashable {
    case One = 0
    case Two = 1

    var hashValue: Int { get {
        return rawValue
    }}
}

func ==(lhs: PlayerNumber, rhs: PlayerNumber) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class TBPlayer {

    var hp = MAX_HP
    let trampoline: TBTrampoline
    let playerLabel: SKLabelNode
    let playerNumber: PlayerNumber

    var dragOffset: CGPoint = CGPointZero

    init(playerNumber: PlayerNumber) {
        self.playerNumber = playerNumber
        switch playerNumber {
        case .One:
            trampoline = TBTrampoline(backgroundName: "trampoline1", size: SIZE)
            playerLabel = SKLabelNode(text: "player 1")
            break
        case .Two:
            trampoline = TBTrampoline(backgroundName: "trampoline2", size: SIZE)
            trampoline.zRotation = CGFloat(M_PI)
            playerLabel = SKLabelNode(text: "player 2")
            playerLabel.zRotation = CGFloat(M_PI)
            break
        }
        playerLabel.fontName = "Chalkduster"
        playerLabel.fontSize = 20
    }

    func addPlayer(toNode: SKNode, frame: CGRect) {

        let yRange: SKRange
        let halfTrampolineHeight = SIZE.height / 2 - 10
        switch playerNumber {
        case .One:
            yRange = SKRange(lowerLimit: CGRectGetMinY(frame) + halfTrampolineHeight, upperLimit: CGRectGetMidY(frame) - halfTrampolineHeight - 30)
            break
        case .Two:
            yRange = SKRange(lowerLimit: CGRectGetMidY(frame) + halfTrampolineHeight + 30, upperLimit: CGRectGetMaxY(frame) - halfTrampolineHeight)
        }

        let halfTrampolineWidth = SIZE.width / 2 - 10
        trampoline.constraints = [SKConstraint.positionX(SKRange(lowerLimit: CGRectGetMinX(frame) + halfTrampolineWidth, upperLimit: CGRectGetMaxX(frame) - halfTrampolineWidth), y: yRange)]

        setInitialPosition(frame)

        toNode.addChild(playerLabel)
        toNode.addChild(trampoline)
    }

    func setInitialPosition(frame: CGRect) {
        let y: CGFloat
        let labelY: CGFloat
        switch playerNumber {
        case .One:
            y = CGRectGetMidY(frame) / 2
            labelY = CGRectGetMinY(frame) + 20
            break
        case .Two:
            y = CGRectGetMidY(frame) * 3 / 2
            labelY = CGRectGetMaxY(frame) - 20
        }
        let x = CGRectGetMidX(frame)
        playerLabel.position = CGPointMake(x, labelY)
        trampoline.position = CGPointMake(x, y)
    }
 
    func isPointNearTrampoline(point: CGPoint) -> CGPoint? {
        let distance = CGPoint.distance(point, second: trampoline.position)
        if distance < PLAYER_DRAG_THRESHOLD {
            return point - trampoline.position
        } else {
            return nil
        }
    }

    func updateTrampolinePosition(touch: UITouch) {
        guard let parent = trampoline.parent else { return }
        trampoline.position = touch.locationInNode(parent) - dragOffset
    }
}

private let MAX_HP: Int = 5
private let SIZE = CGSizeMake(100, 100)
let PLAYER_DRAG_THRESHOLD: CGFloat = 140
