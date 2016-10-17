//
//  ProjectileSprite.swift
//  FingersRevenge
//
//  Created by student on 10/17/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import Foundation
import SpriteKit

class ProjectileSprite: SKSpriteNode{
    // MARK: - ivars -
    var fwd:CGPoint = CGPoint(x:0.0, y:1.0) // North/Up
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    var delta:CGFloat = 300.0 //Magnitude of vector per second
    var hit:Bool = false
    
    // MARK: - Initialization
    init(size:CGSize){
        super.init(texture: SKTexture(image: #imageLiteral(resourceName: "NailClipping")), color: SKColor.white, size: size)
        
        let physSize = CGSize(width: size.width / 1.3, height: size.height / 1.3)
        
        //adding physics body
        self.physicsBody = SKPhysicsBody(texture: SKTexture(image: #imageLiteral(resourceName: "NailClipping")), size: physSize)
        self.physicsBody?.isDynamic = true
        self.physicsBody?.affectedByGravity = false
        self.physicsBody?.categoryBitMask = CollisionMask.projectile
        self.physicsBody?.contactTestBitMask = CollisionMask.wall
        self.physicsBody?.collisionBitMask = CollisionMask.projectile
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods -
    func update(dt:CGFloat){
        velocity = fwd * delta
        position = position + velocity * dt
    }
    
    func rotateToDirection(dest: CGPoint){
        let direction: CGVector = CGVector(dx: dest.x - self.position.x, dy: dest.y - self.position.y)
        self.zRotation = direction.angle() - 1.5708 //90 degrees in radians
    }
}
