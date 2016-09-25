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
    var delta:CGFloat = 300.0 //Magnitude of vector per second
    var health:CGFloat = 3.0//amount of times to be hit until destroyed
    
    let colorArrayIndex = 2;//which color to draw
    
    // MARK: - Initialization
    init(size:CGSize, fillColor:SKColor){
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
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(dt: CGFloat)
    {
        velocity = fwd * delta
        position = position + fwd * dt
    }
}
