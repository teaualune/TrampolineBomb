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

    let bombFactory = TBBombFactory()
    private lazy var bombs = [TBBomb]()

    private var turn = 0

    init() {
        player1 = TBPlayer(playerNumber: .One)
        player2 = TBPlayer(playerNumber: .Two)
    }

    func reset(frame: CGRect) {
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

    func update(frame: CGRect) {
        if let t1 = cachedTouches[.One] {
            player1.updateTrampolinePosition(t1)
        }
        if let t2 = cachedTouches[.Two] {
            player2.updateTrampolinePosition(t2)
        }

        for b in bombs {
            b.update()
            if b.state == .Exploding {
                //
            }
        }

        if bombFactory.shouldMakeBomb(turn) {
            bombs.append(bombFactory.makeBomb(turn % 2 == 0, inFrame: frame))
            turn += 1
        }

    }
}
