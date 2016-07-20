//
//  TBGame.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/20.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import Foundation

enum GameState {
    case PLAYING
    case END
    case PAUSED
}

protocol GameStateListener {
    func gameStateChanged(newState: GameState, oldState: GameState)
}

class TBGame {
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

    private var listeners = [GameStateListener]()

    func listenGameState(listener: GameStateListener) {
        listeners.append(listener)
    }
}
