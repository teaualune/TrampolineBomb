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

    override func didMove(to view: SKView) {

        self.addChild(game.root)

        game.root.addChild(setupBgNode(frame: self.frame))

        game.player1.addPlayer(toNode: game.root, frame: self.frame)
        game.player2.addPlayer(toNode: game.root, frame: self.frame)

        game.state = .ended
        game.reset(frame: self.frame)

        let startLabel = TBStartButton(fontNamed: "Chalkduster")
        startLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        startLabel.game = game
        game.listenGameState(listener: startLabel)
        game.root.addChild(startLabel)
    }

    private func setupBgNode(frame: CGRect) -> SKNode {
        //        let bgNode = SKShapeNode(rect: self.frame)
        //        bgNode.fillColor = UIColor.redColor()
        let bgNode = SKSpriteNode(imageNamed: "bg")
        bgNode.setScale(max(1, frame.width / bgNode.size.width, frame.height / bgNode.size.height))
        bgNode.position = CGPoint(x: frame.midX, y: frame.midY)
        bgNode.zPosition = -100
        return bgNode
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       /* Called when a touch begins */
        if game.state == .playing {
            game.receiveNewTouches(touches: touches)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if game.state == .playing {
            game.removeTouches(touches: touches)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>?, with event: UIEvent?) {
        if let t = touches, game.state == .playing {
            game.removeTouches(touches: t)
        }
    }

    override func update(_ currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if game.state == .playing {
            game.update()
        }
    }
}
