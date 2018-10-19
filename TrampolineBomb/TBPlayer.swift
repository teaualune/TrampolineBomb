//
//  TBPlayer.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/20.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import SpriteKit

enum PlayerNumber : Int, Hashable {
    case one = 0
    case two = 1

    var hashValue: Int {
        return rawValue
    }
}

func ==(lhs: PlayerNumber, rhs: PlayerNumber) -> Bool {
    return lhs.hashValue == rhs.hashValue
}

class TBPlayer {

    var hp = MAX_HP
    let trampoline: TBTrampoline
    let playerLabel: SKLabelNode
    let playerNumber: PlayerNumber

    var dragOffset: CGPoint = CGPoint.zero
    var dragYRange: SKRange = SKRange()

    init(playerNumber: PlayerNumber) {
        self.playerNumber = playerNumber

        switch playerNumber {
        case .one:
            trampoline = TBTrampoline(backgroundName: "trampoline1", size: SIZE)
            break
        case .two:
            trampoline = TBTrampoline(backgroundName: "trampoline2", size: SIZE)
            trampoline.zRotation = CGFloat.pi
            break
        }

        playerLabel = SKLabelNode(fontNamed: "Chalkduster")
        playerLabel.text = labelText
        playerLabel.fontName = "Chalkduster"
        playerLabel.fontSize = 20
        if playerNumber == .two {
            playerLabel.zRotation = CGFloat.pi
        }
    }
    
    private var labelText: String {
        return "player \(playerNumber.rawValue + 1), HP = \(hp)"
    }

    func addPlayer(toNode: SKNode, frame: CGRect) {

        let halfTrampolineHeight = SIZE.height / 2 - 10
        switch playerNumber {
        case .one:
            dragYRange.lowerLimit = frame.minY + halfTrampolineHeight
            dragYRange.upperLimit = frame.midY - halfTrampolineHeight - 30
            break
        case .two:
            dragYRange.lowerLimit = frame.midY + halfTrampolineHeight + 30
            dragYRange.upperLimit = frame.maxY - halfTrampolineHeight
        }

        let halfTrampolineWidth = SIZE.width / 2 - 10
        trampoline.constraints = [SKConstraint.positionX(SKRange(lowerLimit: frame.minX + halfTrampolineWidth, upperLimit: frame.maxX - halfTrampolineWidth), y: dragYRange)]

        setInitialPosition(frame: frame)

        toNode.addChild(playerLabel)
        toNode.addChild(trampoline)
    }

    func setInitialPosition(frame: CGRect) {
        let y: CGFloat
        let labelY: CGFloat
        switch playerNumber {
        case .one:
            y = frame.midY / 2
            labelY = frame.minY + 20
            break
        case .two:
            y = frame.midY * 3 / 2
            labelY = frame.maxY - 20
        }
        let x = frame.midX
        playerLabel.position = CGPoint(x: x, y: labelY)
        trampoline.position = CGPoint(x: x, y: y)
    }
 
    func isPointNearTrampoline(point: CGPoint) -> CGPoint? {
        let distance = CGPoint.distance(first: point, second: trampoline.position)
        if distance < PLAYER_DRAG_THRESHOLD {
            return point - trampoline.position
        } else {
            return nil
        }
    }

    private var cachedHP = MAX_HP

    func update(touch: UITouch?) {
        if let t = touch {
            updateTrampolinePosition(touch: t)
        }

        if hp != cachedHP {
            playerLabel.text = labelText
            cachedHP = hp
        }
    }

    private func updateTrampolinePosition(touch: UITouch) {
        guard let parent = trampoline.parent else { return }
        trampoline.position = touch.location(in: parent) - dragOffset
    }

    func reset() {
        hp = MAX_HP
        cachedHP = hp
        playerLabel.text = labelText
    }
}

private let MAX_HP: Int = 5
private let SIZE = CGSize(width: 100, height: 100)
let PLAYER_DRAG_THRESHOLD: CGFloat = 140
