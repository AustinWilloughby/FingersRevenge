//
//  RectangleSprite.swift
//  FingersRevenge
//
//  Created by student on 9/25/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import Foundation
import SpriteKit

class RectangleSprite : SKShapeNode{
    var fwd:CGPoint = CGPoint(x:0.0, y:-1.0) // Down
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    var delta:CGFloat = 400.0 //Magnitude of vector per second
    var health:Int = 2//amount of times to be hit until destroyed
    let size:CGSize
    
    let colorArrayIndex = 2;//which color to draw
    
    // MARK: - Initialization
    init(size:CGSize, fillColor:SKColor){
        self.size = size
        super.init()
        
        //drawing the rectangle with a centered origin.
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: CGPoint(x: -size.width/2, y: size.height/2))
        pathToDraw.addLine(to: CGPoint(x: size.width/2, y: size.height/2))
        pathToDraw.addLine(to: CGPoint(x: size.width/2, y: -size.height/2))
        pathToDraw.addLine(to: CGPoint(x: -size.width/2, y: -size.height/2))
        pathToDraw.closeSubpath()
        path = pathToDraw
        self.fillColor = fillColor
        
        //adding physics body
//        self.physicsBody = SKPhysicsBody(rectangleOf: size)
//        self.physicsBody?.isDynamic = true
//        self.physicsBody?.affectedByGravity = false
//        self.physicsBody?.categoryBitMask = CollisionMask.wall
//        self.physicsBody?.contactTestBitMask = CollisionMask.projectile
//        self.physicsBody?.collisionBitMask = CollisionMask.wall
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: CGFloat)
    {
        velocity = fwd * delta
        position = position + velocity * dt
        if(position.y < -size.height/2){
            self.removeFromParent()
        }
        
    }
    
    func takeDamage(){
        health -= 1
        if health == 1{
            self.fillColor = UIColor.yellow
        }
        if health <= 0{
            self.removeFromParent()
        }
    }
}
