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
        
        var chunk = [RectangleSprite]()
        
        for y in 0 ..< ySize{
            currentLine = map[ySize - y - 1]
            
            for x in 0 ..< xSize{
                var tempRect:RectangleSprite
                
                let index = currentLine.index(currentLine.startIndex, offsetBy: x)
                switch currentLine[index]
                {
                    case "O":
                        tempRect = RectangleSprite(size: CGSize(width: unitSize, height: unitSize), fillColor: SKColor.green)
                        tempRect.name = "obstacle"
                        let x = (x * unitSize) + (unitSize / 2)
                        let y = startingHeight + (y * unitSize)
                        tempRect.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
                        
                        tempRect.physicsBody = SKPhysicsBody.init(polygonFrom: tempRect.path!)
                        tempRect.physicsBody?.isDynamic = false
                        tempRect.physicsBody?.categoryBitMask = CollisionMask.wall
                        //tempRect.physicsBody?.contactTestBitMask = CollisionMask.projectile
                        tempRect.physicsBody?.collisionBitMask = CollisionMask.none
                        
                        chunk.append(tempRect)
                    
                    case "E":
                        tempRect = RectangleSprite(size: CGSize(width: unitSize, height: unitSize), fillColor: SKColor.white)
                        tempRect.name = "obstacle"
                        let x = (x * unitSize) + (unitSize / 2)
                        let y = startingHeight + (y * unitSize)
                        tempRect.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
                        
                        tempRect.physicsBody = SKPhysicsBody.init(polygonFrom: tempRect.path!)
                        tempRect.physicsBody?.isDynamic = false
                        tempRect.physicsBody?.categoryBitMask = CollisionMask.finish
                        //tempRect.physicsBody?.contactTestBitMask = CollisionMask.projectile
                        tempRect.physicsBody?.collisionBitMask = CollisionMask.none
                    
                        chunk.append(tempRect)
                    default:
                        break
                }
            }
        }
        return (chunk, startingHeight + (ySize * unitSize))
    }
}

struct LevelMaps{
    static let one :String = "1,2,3,4,3,2,4,1,3"
    static let two :String = "2,1,3"
}
