//
//  GameScene.swift
//  ShooterGame
//
//  Created by Roman on 3/20/16.
//  Copyright (c) 2016 Roman Puzey. All rights reserved.
//

import SpriteKit

struct PhysicsCategory
{
    static let None:        UInt32 = 0
    static let All:         UInt32 = UInt32.max
    static let Enemy:       UInt32 = 0b1 // 1
    static let Projectile:  UInt32 = 0b10 // 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {

    let player = SKSpriteNode(imageNamed: "player.png")
    var enemiesDestroyed = 0

    override func didMoveToView(view: SKView)
    {
        backgroundColor = SKColor.whiteColor()

        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.setScale(3)


        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self


        addChild(player)

        addEnemy()
        setProjectile()

        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(addEnemy), SKAction.waitForDuration(1.5)])))
        runAction(SKAction.repeatActionForever(SKAction.sequence([SKAction.runBlock(setProjectile), SKAction.waitForDuration(0.5)])))
    }

    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }

    func random(min min:CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }

    func addEnemy()
    {
        let enemy = SKSpriteNode(imageNamed: "enemy.png")

        enemy.physicsBody = SKPhysicsBody(circleOfRadius: enemy.size.width / 2)
        enemy.physicsBody?.dynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.Enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.None

        let randomY = random(min: enemy.size.height / 2, max: size.height - enemy.size.height / 2)
        enemy.position = CGPoint(x: size.width + enemy.size.width / 2, y: randomY)

        addChild(enemy)

        let enemySpeed = random(min: CGFloat(3.0), max: CGFloat(5.0))
        let moveEnemy = SKAction.moveTo(CGPoint(x: -enemy.size.width / 2, y: randomY), duration:  NSTimeInterval(enemySpeed))
        let removeEnemy = SKAction.removeFromParent()

        let loseAction = SKAction.runBlock(
            {
                let show = SKTransition.doorsCloseHorizontalWithDuration(0.5)
                let gameOverScene = GameOverScene(size: self.size, won: false)
                self.view?.presentScene(gameOverScene, transition: show)
            })

        enemy.runAction(SKAction.sequence([moveEnemy, loseAction, removeEnemy]))
    }

    func setProjectile()
    {
        let projectile = SKSpriteNode(imageNamed: "projectile.png")
        projectile.position = player.position

        projectile.physicsBody = SKPhysicsBody(rectangleOfSize: projectile.size)
        projectile.physicsBody?.dynamic = true

        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Enemy
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true

        addChild(projectile)

        let moveAction = SKAction.moveToX(1000, duration: 3.0)
        let removeAction = SKAction.removeFromParent()

        projectile.runAction(SKAction.sequence([moveAction, removeAction]))
    }

    func projectileCollision(projectile: SKSpriteNode, enemy: SKSpriteNode)
    {
        enemy.removeFromParent()
        projectile.removeFromParent()

        enemiesDestroyed++

        if enemiesDestroyed > 100
        {
            let show = SKTransition.doorsCloseHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene(size: self.size, won: true)
            self.view?.presentScene(gameOverScene, transition: show)
        }
    }

    func didBeginContact(contact: SKPhysicsContact)
    {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        if ((firstBody.categoryBitMask & PhysicsCategory.Enemy != 0) && (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0))
        {
            var enemy: SKSpriteNode = secondBody.node as! SKSpriteNode
            if secondBody.allContactedBodies().count == 1
            {
                enemy.removeFromParent()
                enemiesDestroyed++
            }

            var projectile: SKSpriteNode? = firstBody.node as? SKSpriteNode
            projectile?.removeFromParent()
        }

    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */

            let touch = touches.first
            let touchLocation = touch!.locationInNode(self)

            let timeToTravel = abs((touchLocation.y - player.position.y) / 500)

            let moveAction = SKAction.moveToY(touchLocation.y, duration: NSTimeInterval(timeToTravel))

            moveAction.timingMode = SKActionTimingMode.EaseInEaseOut
            player.runAction(moveAction)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
