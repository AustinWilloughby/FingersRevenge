//
//  DiamondSprite.swift
//  FingersRevenge
//
//  Created by Austin Willoughby on 9/22/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import Foundation
import SpriteKit

class DiamondSprite: SKShapeNode{
    // MARK: - ivars -
    var fwd:CGPoint = CGPoint(x:0.0, y:1.0) // North/Up
    var velocity:CGPoint = CGPoint.zero // speed with a direction
    var delta:CGFloat = 300.0 //Magnitude of vector per second
    var hit:Bool = false
    
    // MARK: - Initialization
    init(size:CGSize, lineWeight:CGFloat, strokeColr:SKColor, fillColor:SKColor){
        super.init()
        let halfHeight = size.height/2.0
        let halfWidth = size.width/2.0
        let top = CGPoint(x:0, y:halfHeight)
        let right = CGPoint(x:halfWidth, y:0)
        let bottom = CGPoint(x:0, y:-halfHeight)
        let left = CGPoint(x:-halfWidth, y:0)
        
        let pathToDraw = CGMutablePath()
        pathToDraw.move(to: top)
        pathToDraw.addLine(to: right)
        pathToDraw.addLine(to: bottom)
        pathToDraw.addLine(to: left)
        pathToDraw.closeSubpath()
        path = pathToDraw
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.fillColor = fillColor
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods -
    func update(dt:CGFloat){
        velocity = fwd * delta
        position = position + velocity * dt
    }
    
    func reflectX(){
        fwd.x *= CGFloat(-1.0)
    }
    
    func reflectY(){
        fwd.y *= CGFloat(-1.0)
    }
}
