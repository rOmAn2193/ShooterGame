//
//  GameOverScene.swift
//  ShooterGame
//
//  Created by Roman on 3/20/16.
//  Copyright © 2016 Roman Puzey. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene
{
    init(size: CGSize, won: Bool)
    {
        super.init(size:size)

        backgroundColor = SKColor.whiteColor()

        let message = won ? "You Won!" : "You Lost :/"

        let label = SKLabelNode(fontNamed: "MarkerFelt-Wide")
        label.text = message
        label.fontSize = 40
        label.fontColor = SKColor.blackColor()
        label.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(label)

        runAction(SKAction.sequence([SKAction.waitForDuration(3.0), SKAction.runBlock()
            {
                let transition = SKTransition.doorsOpenHorizontalWithDuration(0.5)
                let scene = GameScene(size: size)
                // scene.scaleMode = .AspectFill
                self.view?.presentScene(scene, transition: transition)
            }]))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}