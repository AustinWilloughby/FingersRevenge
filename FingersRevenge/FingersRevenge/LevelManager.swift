//
//  LevelManager.swift
//  FingersRevenge
//
//  Created by student on 10/3/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import Foundation
import SpriteKit

class LevelManager{
    private var startHeight:Int
    private var tilesAcross:Int
    private var unitSize:Int
    
    init(){
        tilesAcross = 10
        unitSize = 1080 / tilesAcross
        startHeight = 2200
    }
    
    
    func loadMap(map:String)->[RectangleSprite]{
        var chunkMap:[String] = map.characters.split{$0 == ","}.map(String.init)
        
        if chunkMap.last != "E" {
            chunkMap.append("E")
        }
        
        var chunks = [RectangleSprite]()
        
        
        var currentStartHeight: Int = startHeight
        for i in 0 ..< chunkMap.count{
            var levelChunk: [String]
            switch(chunkMap[i]){
                case "1":
                    levelChunk = LevelChunks.one
                
                case "2":
                    levelChunk = LevelChunks.two
                
                case "3":
                    levelChunk = LevelChunks.three
                
                case "4":
                    levelChunk = LevelChunks.four
                
                case "5":
                    levelChunk = LevelChunks.five
                
                default:
                    levelChunk = LevelChunks.end
            }
            
            let chunkInfo = loadChunk(map: levelChunk, startingHeight: currentStartHeight)
            let currentChunk = chunkInfo.0
            currentStartHeight = chunkInfo.1
            
            chunks.append(contentsOf: currentChunk)
        }
        
        return chunks
    }
    
    
    private func loadChunk(map:[String], startingHeight: Int)->(newChunk: [RectangleSprite], height: Int){
        var currentLine = map[0]
        let xSize: Int = tilesAcross
        let ySize: Int = map.count
        var button:RectangleSprite?
        var gates:[RectangleSprite] = [RectangleSprite]()
        var chunk = [RectangleSprite]()
        
        for y in 0 ..< ySize{
            currentLine = map[ySize - y - 1]
            
            for x in 0 ..< xSize{
                var tempRect:RectangleSprite
                
                let index = currentLine.index(currentLine.startIndex, offsetBy: x)
                switch currentLine[index]
                {
                    case "O": //Generic obstacle
                        tempRect = generateRectDetails(fill: randomColor(), stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "O")
                        chunk.append(tempRect)
                    
                    case "L": //Finish line (graphic)
                        tempRect = generateRectDetails(fill: SKColor.white, stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "L")
                        chunk.append(tempRect)
                    
                    case "F": //Finish line (collider)
                        tempRect = generateRectDetails(fill: SKColor.clear, stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "F")
                        chunk.append(tempRect)
                    
                    case "G": //Gate Obstacle
                        tempRect = generateRectDetails(fill: SKColor.lightGray, stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "G")
                        chunk.append(tempRect)
                        gates.append(tempRect)
                    
                    case "B": //Button Obstacle
                        tempRect = generateRectDetails(fill: SKColor.red, stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "B")
                        chunk.append(tempRect)
                        tempRect.isButton = true
                        button = tempRect
                    
                    case "U": //Unbreakable rects
                        tempRect = generateRectDetails(fill: SKColor.darkGray, stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "U")
                        chunk.append(tempRect)
                    
                    default:
                        break
                }
            }
        }
        if(button != nil && gates.count > 0){
            button?.gates = gates
        }
        return (chunk, startingHeight + (ySize * unitSize))
    }
    
    func randomColor() -> SKColor{
        var h:CGFloat, s:CGFloat, l:CGFloat
        let hRange:CGFloat = 140.0 - 90.0
        let sRange:CGFloat = 100.0 - 50.0
        let lRange:CGFloat = 60.0 - 40.0
        h = (90.0 + CGFloat(((CGFloat(arc4random_uniform(101))/100.0) * hRange)))/3.6/100.0
//        s = (50.0 + CGFloat(((CGFloat(arc4random_uniform(101))/100.0) * sRange)))/100.0
        s = 100.0/100.0
        l = (60.0 + CGFloat(((CGFloat(arc4random_uniform(101))/100.0) * lRange)))/100.0
        
        return SKColor(hue: h, saturation: s, brightness: l, alpha: 1)
    }
    
    func generateRectDetails(fill: SKColor, stroke: SKColor, name: String, xValue: Int, yValue: Int, startHeight: Int, elementID: String) -> RectangleSprite
    {
        let tempRect = RectangleSprite(size: CGSize(width: unitSize, height: unitSize), fillColor: fill, strokeColor: stroke)
        tempRect.name = name
        let x = (xValue * unitSize) + (unitSize / 2)
        let y = startHeight + (yValue * unitSize)
        tempRect.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
        
        switch elementID
        {
            case "O":
                tempRect.physicsBody = SKPhysicsBody.init(polygonFrom: tempRect.path!)
                tempRect.physicsBody?.isDynamic = false
                tempRect.physicsBody?.categoryBitMask = CollisionMask.wall
                tempRect.physicsBody?.collisionBitMask = CollisionMask.none
            
            case "L": break
                //For now we arent doing anything
            
            case "F":
                tempRect.physicsBody = SKPhysicsBody.init(polygonFrom: tempRect.path!)
                tempRect.physicsBody?.isDynamic = false
                tempRect.physicsBody?.categoryBitMask = CollisionMask.finish
                tempRect.physicsBody?.collisionBitMask = CollisionMask.none
            
            case "G":
                tempRect.physicsBody = SKPhysicsBody.init(polygonFrom: tempRect.path!)
                tempRect.physicsBody?.isDynamic = false
                tempRect.physicsBody?.categoryBitMask = CollisionMask.gate
                tempRect.physicsBody?.collisionBitMask = CollisionMask.none
            
            case "B":
                tempRect.physicsBody = SKPhysicsBody.init(polygonFrom: tempRect.path!)
                tempRect.physicsBody?.isDynamic = false
                tempRect.physicsBody?.categoryBitMask = CollisionMask.button
                tempRect.physicsBody?.collisionBitMask = CollisionMask.none
            
            case "U":
                tempRect.physicsBody = SKPhysicsBody.init(polygonFrom: tempRect.path!)
                tempRect.physicsBody?.isDynamic = false
                tempRect.physicsBody?.categoryBitMask = CollisionMask.unbreakable
                tempRect.physicsBody?.collisionBitMask = CollisionMask.none
            
            default:
                break
        }
        
        return tempRect
    }
}

struct LevelMaps{
    static let one :String = "5,1,2,3,4,3,2,4,1,3"
    static let two :String = "2,1,3"
}
