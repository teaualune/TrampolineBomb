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
        self.hidden = newState == .PLAYING
        self.userInteractionEnabled = !self.hidden
    }

    override init(fontNamed fontName: String?) {
        super.init(fontNamed: fontName)
        self.text = "Start"
        self.fontSize = 45
        self.gameStateChanged(.END, oldState: .END)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    required override init() {
        super.init()
    }

    private var _touching = false

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _touching = true
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        _touching = false
        if let g = game {
            g.reset(g.frame)
            g.state = .PLAYING
        }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        _touching = false
    }
}
