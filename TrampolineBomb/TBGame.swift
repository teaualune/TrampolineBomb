//
//  TBGame.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/20.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import UIKit
import SpriteKit

enum GameState {
    case PLAYING
    case END
    case STOPPED
}

protocol GameStateListener {
    func gameStateChanged(newState: GameState, oldState: GameState)
}

class TBGame {

    let root = SKNode()
    var frame: CGRect = CGRectZero
    let bombFactory = TBBombFactory()
    private lazy var bombs = [TBBomb]()

    private var turn = 0
    private var exploding = false

    let explodeAction = SKAction.scaleTo(0.01, duration: 0)

    private let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")

    init() {
        player1 = TBPlayer(playerNumber: .One)
        player2 = TBPlayer(playerNumber: .Two)

        gameOverLabel.fontSize = 45
        gameOverLabel.zPosition = 1000
        root.addChild(gameOverLabel)
    }

    func reset(frame: CGRect) {
        self.frame = frame
        bombFactory.upperRange = player2.dragYRange
        bombFactory.lowerRange = player1.dragYRange
        bombFactory.fieldWidth = frame.size.width

        player1.reset()
        player2.reset()

        for b in bombs {
            b.removeFromParent()
        }
        bombs.removeAll()

        cachedTouches.removeAll()
        player1.setInitialPosition(frame)
        player2.setInitialPosition(frame)

        turn = 0
        exploding = false

        gameOverLabel.position = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame))
        gameOverLabel.hidden = true
    }

    var _state: GameState = .END
    var state: GameState {
        get {
            return _state
        }
        set {
            let old = _state
            _state = newValue
            for listener in listeners {
                listener.gameStateChanged(newValue, oldState: old)
            }
        }
    }

    private lazy var listeners = [GameStateListener]()

    func listenGameState(listener: GameStateListener) {
        listeners.append(listener)
    }

    let player1: TBPlayer
    let player2: TBPlayer

    private lazy var cachedTouches = [PlayerNumber: UITouch](minimumCapacity: 2)

    func receiveNewTouches(touches: Set<UITouch>) {
        if cachedTouches.count == 2 {
            return
        }

        for touch in touches {
            let location = touch.locationInNode(root)
            if handleTouch(touch, withLocation: location, forPlayer: player1) { break }
            handleTouch(touch, withLocation: location, forPlayer: player2)
        }
    }

    private func handleTouch(touch: UITouch, withLocation location: CGPoint, forPlayer player: TBPlayer) -> Bool {
        if cachedTouches[player.playerNumber] == nil {
            if let offset = player.isPointNearTrampoline(location) {
                player.dragOffset = offset
                cachedTouches[player.playerNumber] = touch
                return true
            }
        }
        return false
    }

    func removeTouches(touches: Set<UITouch>) {
        for t in touches {
            if cachedTouches[.One] == t {
                cachedTouches.removeValueForKey(.One)
            }
            if cachedTouches[.Two] == t {
                cachedTouches.removeValueForKey(.Two)
            }
        }
    }

    func update() {
        if exploding { return }

        player1.update(cachedTouches[.One])
        player2.update(cachedTouches[.Two])

        if player1.hp == 0 || player2.hp == 0 {
            gameOver(player1.hp == 0 ? player2 : player1)
            return
        }

        for (i, b) in bombs.enumerate() {
            b.update()
            if b.zHeight < 0 {
                checkCollision(b)
                if b.state == .Exploding {
                    handleExplosion(b)
//                    exploding = true
//                    cachedTouches.removeAll()
                } else if i == 0 {
                    turn += 1
                }
            }
        }

        if bombFactory.shouldMakeBomb(turn) {
            makeBomb()
        }
    }

    private func checkCollision(bomb: TBBomb) {
        if CGPoint.distance(bomb.position, second: player1.trampoline.position) < COLLISION_THRESHOLD {
            bombFactory.resetBombNextState(bomb, isUpper: true)
        } else if CGPoint.distance(bomb.position, second: player2.trampoline.position) < COLLISION_THRESHOLD {
            bombFactory.resetBombNextState(bomb, isUpper: false)
        } else {
            bomb.state = .Exploding
        }
    }

    private func handleExplosion(bomb: TBBomb) {

        if let idx = bombs.indexOf(bomb) { bombs.removeAtIndex(idx) }
        if bombs.count == 0 {
            makeBomb()
        }

        if let smoke = SKEmitterNode(fileNamed: "TBSmokeParticle.sks"),
            let explosion = SKEmitterNode(fileNamed: "TBExplodeParticle.sks") {
            explosion.position = bomb.position
            explosion.targetNode = root
            explosion.zPosition = 1000
            smoke.position = bomb.position
            smoke.targetNode = root
            smoke.zPosition = 1000
            root.addChild(smoke)
            root.addChild(explosion)
            root.runAction(SKAction.waitForDuration(2)) {
                explosion.removeFromParent()
                smoke.removeFromParent()
            }
        }

        bomb.runAction(explodeAction) {
//            self.exploding = false
            bomb.removeFromParent()

            let y = bomb.position.y
            let mid = CGRectGetMidY(self.frame)
            if y > mid {
                self.player2.hp -= 1
            } else {
                self.player1.hp -= 1
            }
        }
    }

    private func makeBomb() {
        let isUpper = turn % 2 == 0
        let position = isUpper ? player1.trampoline.position : player2.trampoline.position
        let newBomb = bombFactory.makeBomb(isUpper, targetPosition: position)
        bombs.append(newBomb)
        root.addChild(newBomb)
        turn += 1
    }

    private func gameOver(winner: TBPlayer) {
        gameOverLabel.text = "player \(winner.playerNumber.rawValue + 1) wins!!"
        gameOverLabel.hidden = false
        gameOverLabel.runAction(SKAction.waitForDuration(5)) { 
            self.state = .END
            self.reset(self.frame)
        }
    }
}

private let COLLISION_THRESHOLD: CGFloat = 75
