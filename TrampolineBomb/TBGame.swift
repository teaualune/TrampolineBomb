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
    case PAUSED
}

protocol GameStateListener {
    func gameStateChanged(newState: GameState, oldState: GameState)
}

class TBGame {

    var frame: CGRect = CGRectZero
    let bombFactory = TBBombFactory()
    private lazy var bombs = [TBBomb]()

    private var turn = 0

    init() {
        player1 = TBPlayer(playerNumber: .One)
        player2 = TBPlayer(playerNumber: .Two)
    }

    func reset(frame: CGRect) {
        self.frame = frame
        bombFactory.upperRange = player2.dragYRange
        bombFactory.lowerRange = player1.dragYRange
        for b in bombs {
            b.removeFromParent()
        }
        bombs.removeAll()
        cachedTouches.removeAll()
        player1.setInitialPosition(frame)
        player2.setInitialPosition(frame)
        turn = 0
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

    func receiveNewTouches(touches: Set<UITouch>, inNode node: SKNode) {
        if cachedTouches.count == 2 {
            return
        }

        for touch in touches {
            let location = touch.locationInNode(node)
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
        player1.update(cachedTouches[.One])
        player2.update(cachedTouches[.Two])

        for (i, b) in bombs.enumerate() {
            b.update()
            if b.zHeight < 0 {
                checkCollision(b)
                if b.state == .Exploding {
                    handleExplosion(b)
                } else if i == 0 {
                    turn += 1
                }
            }
        }

        if bombFactory.shouldMakeBomb(turn) {
            bombs.append(bombFactory.makeBomb(turn % 2 == 0))
            turn += 1
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
        let y = bomb.position.y
        let mid = CGRectGetMidY(frame)
        if y > mid {
            player2.hp -= 1
        } else {
            player1.hp -= 1
        }
    }
}

private let COLLISION_THRESHOLD: CGFloat = 70
