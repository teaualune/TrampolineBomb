//
//  GameScene.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/20.
//  Copyright (c) 2016年 Radioflux. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    private let game = TBGame()

    override func didMoveToView(view: SKView) {

        self.addChild(game.root)

        game.root.addChild(setupBgNode(self.frame))

        game.player1.addPlayer(game.root, frame: self.frame)
        game.player2.addPlayer(game.root, frame: self.frame)

        game.state = .END
        game.reset(self.frame)

        let startLabel = TBStartButton(fontNamed: "Chalkduster")
        startLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        startLabel.game = game
        game.listenGameState(startLabel)
        game.root.addChild(startLabel)
    }

    private func setupBgNode(frame: CGRect) -> SKNode {
        //        let bgNode = SKShapeNode(rect: self.frame)
        //        bgNode.fillColor = UIColor.redColor()
        let bgNode = SKSpriteNode(imageNamed: "bg")
        bgNode.setScale(max(1, frame.width / bgNode.size.width, frame.height / bgNode.size.height))
        bgNode.position = CGPoint(x:CGRectGetMidX(frame), y:CGRectGetMidY(frame))
        bgNode.zPosition = -100
        return bgNode
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        if game.state == .PLAYING {
            game.receiveNewTouches(touches)
        }
    }

    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if game.state == .PLAYING {
            game.removeTouches(touches)
        }
    }

    override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
        if let t = touches where game.state == .PLAYING {
            game.removeTouches(t)
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if game.state == .PLAYING {
            game.update()
        }
    }
}
