//
//  TBStartButton.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/20.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import SpriteKit

class TBStartButton : SKLabelNode, GameStateListener {

    var game: TBGame?

    func gameStateChanged(newState: GameState, oldState: GameState) {
        self.isHidden = newState == .PLAYING
        self.isUserInteractionEnabled = !self.isHidden
    }

    override init(fontNamed fontName: String?) {
        super.init(fontNamed: fontName)
        self.text = "Start"
        self.fontSize = 45
        self.gameStateChanged(newState: .END, oldState: .END)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init() {
        super.init()
    }

    private var _touching = false

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        _touching = true
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        _touching = false
        if let g = game {
            g.reset(frame: g.frame)
            g.state = .PLAYING
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        _touching = false
    }
}
