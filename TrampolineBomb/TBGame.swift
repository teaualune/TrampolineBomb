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
    case playing
    case ended
    case stopped
}

protocol GameStateListener {
    func gameStateChanged(newState: GameState, oldState: GameState)
}

class TBGame {

    let root = SKNode()
    var frame: CGRect = CGRect.zero
    let bombFactory = TBBombFactory()
    private lazy var bombs = [TBBomb]()

    private var turn = 0
    private var exploding = false

    let explodeAction = SKAction.scale(to: 0.01, duration: 0)

    private let gameOverLabel = SKLabelNode(fontNamed: "Chalkduster")

    init() {
        player1 = TBPlayer(playerNumber: .one)
        player2 = TBPlayer(playerNumber: .two)

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
        player1.setInitialPosition(frame: frame)
        player2.setInitialPosition(frame: frame)

        turn = 0
        exploding = false

        gameOverLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        gameOverLabel.isHidden = true
    }

    private var _state = GameState.ended

    var state: GameState {
        get {
            return self._state
        }
        set {
            let old = self._state
            self._state = newValue
            for listener in listeners {
                listener.gameStateChanged(newState: newValue, oldState: old)
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
            let location = touch.location(in: root)
            if handleTouch(touch: touch, withLocation: location, forPlayer: player1) { break }
            _ = handleTouch(touch: touch, withLocation: location, forPlayer: player2)
        }
    }

    private func handleTouch(touch: UITouch, withLocation location: CGPoint, forPlayer player: TBPlayer) -> Bool {
        if cachedTouches[player.playerNumber] == nil {
            if let offset = player.isPointNearTrampoline(point: location) {
                player.dragOffset = offset
                cachedTouches[player.playerNumber] = touch
                return true
            }
        }
        return false
    }

    func removeTouches(touches: Set<UITouch>) {
        for t in touches {
            if cachedTouches[.one] == t {
                cachedTouches.removeValue(forKey: .one)
            }
            if cachedTouches[.two] == t {
                cachedTouches.removeValue(forKey: .two)
            }
        }
    }

    func update() {
        if exploding { return }

        player1.update(touch: cachedTouches[.one])
        player2.update(touch: cachedTouches[.two])

        if player1.hp == 0 || player2.hp == 0 {
            gameOver(winner: player1.hp == 0 ? player2 : player1)
            return
        }

        for (i, b) in bombs.enumerated() {
            b.update()
            if b.zHeight < 0 {
                checkCollision(bomb: b)
                if b.state == .exploding {
                    handleExplosion(bomb: b)
//                    exploding = true
//                    cachedTouches.removeAll()
                } else if i == 0 {
                    turn += 1
                }
            }
        }

        if bombFactory.shouldMakeBomb(turn: turn) {
            makeBomb()
        }
    }

    private func checkCollision(bomb: TBBomb) {
        if CGPoint.distance(first: bomb.position, second: player1.trampoline.position) < COLLISION_THRESHOLD {
            bombFactory.resetBombNextState(bomb: bomb, isUpper: true)
        } else if CGPoint.distance(first: bomb.position, second: player2.trampoline.position) < COLLISION_THRESHOLD {
            bombFactory.resetBombNextState(bomb: bomb, isUpper: false)
        } else {
            bomb.state = .exploding
        }
    }

    private func handleExplosion(bomb: TBBomb) {

        if let idx = bombs.firstIndex(of: bomb) {
            bombs.remove(at: idx)
        }
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
            root.run(SKAction.wait(forDuration: 2)) {
                explosion.removeFromParent()
                smoke.removeFromParent()
            }
        }

        bomb.run(explodeAction) {
//            self.exploding = false
            bomb.removeFromParent()

            let y = bomb.position.y
            let mid = self.frame.midY
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
        let newBomb = bombFactory.makeBomb(isUpper: isUpper, targetPosition: position)
        bombs.append(newBomb)
        root.addChild(newBomb)
        turn += 1
    }

    private func gameOver(winner: TBPlayer) {
        gameOverLabel.text = "player \(winner.playerNumber.rawValue + 1) wins!!"
        gameOverLabel.isHidden = false
        gameOverLabel.run(SKAction.wait(forDuration: 5)) {
            self.state = .ended
            self.reset(frame: self.frame)
        }
    }
}

private let COLLISION_THRESHOLD: CGFloat = 75
