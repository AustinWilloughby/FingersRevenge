//
//  RingSprite.swift
//  FingersRevenge
//
//  Created by student on 12/12/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import Foundation
import SpriteKit

class RingSprite : SKShapeNode{
    var fwd:CGPoint = CGPoint(x:0.0, y:-1.0) // Down
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    var delta:CGFloat = 400.0 //Magnitude of vector per second
    var health:Int = 2//amount of times to be hit until destroyed
    let size:CGSize
    var isButton:Bool = false
    var elementID:String = "R"
    
    let colorArrayIndex = 2;//which color to draw
    
    // MARK: - Initialization
    init(size:CGSize){
        self.size = size
        super.init()
        
        //drawing the rectangle with a centered origin.
        let pathToDraw = UIBezierPath(ovalIn: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)).cgPath
        path = pathToDraw
        self.fillColor = UIColor.clear
        self.lineWidth = 20.0
        self.strokeColor = UIColor.yellow
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: CGFloat)
    {
        velocity = fwd * delta
        position = position + velocity * dt
        if(position.y < -size.height){
            self.removeFromParent()
        }
        
    }
    
    func pickUp(){
        self.physicsBody?.categoryBitMask = CollisionMask.none
        self.physicsBody?.contactTestBitMask = CollisionMask.none
        self.physicsBody?.collisionBitMask = CollisionMask.none
        let g = SKAction.group([SKAction.scale(by: 3.0, duration: 0.2), SKAction.fadeOut(withDuration: 0.2)])
        self.run(SKAction.sequence([g, SKAction.run{ self.removeFromParent() }]))
    }
}
