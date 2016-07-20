//
//  TBTrampoline.swift
//  TrampolineBomb
//
//  Created by Teaualune Tseng on 2016/7/20.
//  Copyright © 2016年 Radioflux. All rights reserved.
//

import SpriteKit

let Z_POS_TRAMPOLINE_BG: CGFloat = 100

class TBTrampoline : SKNode {
    private let background: SKSpriteNode

    init(backgroundName: String, size: CGSize) {
        background = SKSpriteNode(imageNamed: backgroundName)
        background.size = size
        background.zPosition = Z_POS_TRAMPOLINE_BG
        super.init()
        self.addChild(background)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
