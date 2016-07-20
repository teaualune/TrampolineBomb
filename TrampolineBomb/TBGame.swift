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

    init() {
        player1 = TBPlayer(playerNumber: .One)
        player2 = TBPlayer(playerNumber: .Two)
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
        for touch in touches {
            let location = touch.locationInNode(node)

            if cachedTouches[.One] == nil {
                if let offset = player1.isPointNearTrampoline(location) {
                    player1.dragOffset = offset
                    cachedTouches[.One] = touch
                }
            }
        }
    }
}
