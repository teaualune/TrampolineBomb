//
//  GameViewController.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/20.
//  Copyright (c) 2016年 Radioflux. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private var inited = false

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if !inited {
            inited = true

            let skView = self.view as! SKView
            skView.showsFPS = true
            skView.showsNodeCount = true

            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true

            let scene = GameScene(size: self.view.bounds.size)
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
    
            skView.presentScene(scene)
        }
    }
    
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
