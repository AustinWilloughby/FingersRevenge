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
    
    
    //Load an array of rectanglesprites from a map identifier
    func loadMap(map:String)->[SKShapeNode]{
        var chunkMap:[String] = map.characters.split{$0 == ","}.map(String.init)
        
        if chunkMap.last != "E" {
            chunkMap.append("E")
        }
        
        var chunks = [SKShapeNode]()
        
        
        var currentStartHeight: Int = startHeight
        for i in 0 ..< chunkMap.count{
            let levelChunk: [String] = getChunkAtIndex(chunk: chunkMap[i])
            let chunkInfo = loadChunk(map: levelChunk, startingHeight: currentStartHeight)
            let currentChunk = chunkInfo.0
            currentStartHeight = chunkInfo.1
            
            chunks.append(contentsOf: currentChunk)
        }
        
        return chunks
    }
    
    
    //Load a chunk from a map string[], give starting height to know where it is in the world
    func loadChunk(map:[String], startingHeight: Int)->(newChunk: [SKShapeNode], height: Int){
        var currentLine = map[0]
        let xSize: Int = tilesAcross
        let ySize: Int = map.count
        var button:RectangleSprite?
        var gates:[RectangleSprite] = [RectangleSprite]()
        var chunk = [SKShapeNode]()
        
        for y in 0 ..< ySize{
            currentLine = map[ySize - y - 1]
            
            for x in 0 ..< xSize{
                var tempRect:RectangleSprite
                
                let index = currentLine.index(currentLine.startIndex, offsetBy: x)
                switch currentLine[index]
                {
                    case "O": //Generic obstacle
                        tempRect = generateRectDetails(fill: randomGreenColor(), stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "O")
                        chunk.append(tempRect)
                    
                    case "L": //Finish line (graphic)
                        tempRect = generateRectDetails(fill: SKColor.white, stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "L")
                        chunk.append(tempRect)
                    
                    case "F": //Finish line (collider)
                        tempRect = generateRectDetails(fill: SKColor.clear, stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "F")
                        chunk.append(tempRect)
                    
                    case "G": //Gate Obstacle
                        tempRect = generateRectDetails(fill: randomLightGrayColor(), stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "G")
                        chunk.append(tempRect)
                        gates.append(tempRect)
                    
                    case "B": //Button Obstacle
                        tempRect = generateRectDetails(fill: SKColor.red, stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "B")
                        chunk.append(tempRect)
                        tempRect.isButton = true
                        button = tempRect
                    
                    case "U": //Unbreakable rects
                        tempRect = generateRectDetails(fill: randomDarkGrayColor(), stroke: SKColor.clear, name: "obstacle", xValue: x, yValue: y, startHeight: startingHeight, elementID: "U")
                        chunk.append(tempRect)
                    
                    case "R": //Rings
                        let tempRing = RingSprite(size: CGSize(width: unitSize, height: unitSize))
                        tempRing.position = CGPoint(x: (x * unitSize) + (unitSize / 2), y:startingHeight + (y * unitSize))
                        tempRing.physicsBody = SKPhysicsBody.init(polygonFrom: tempRing.path!)
                        tempRing.physicsBody?.isDynamic = false
                        tempRing.physicsBody?.categoryBitMask = CollisionMask.ring
                        tempRing.physicsBody?.collisionBitMask = CollisionMask.none
                        tempRing.name = "ring"
                        chunk.append(tempRing)
                    
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
    
    
    //Handle generating the rectangle information
    func generateRectDetails(fill: SKColor, stroke: SKColor, name: String, xValue: Int, yValue: Int, startHeight: Int, elementID: String) -> RectangleSprite
    {
        let tempRect = RectangleSprite(size: CGSize(width: unitSize, height: unitSize), fillColor: fill, strokeColor: stroke)
        tempRect.name = name
        tempRect.elementID = elementID
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
    
    //MARK: Random Colors
    func randomGreenColor() -> SKColor{
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
    
    func randomLightGrayColor() -> SKColor{
        var l:CGFloat
        let lRange:CGFloat = 90.0 - 70.0
        l = (70.0 + CGFloat(((CGFloat(arc4random_uniform(101))/100.0) * lRange)))/100.0
        
        return SKColor(hue: 0, saturation: 0, brightness: l, alpha: 1)
    }
    
    func randomDarkGrayColor() -> SKColor{
        var l:CGFloat
        let lRange:CGFloat = 40.0 - 20.0
        l = (20.0 + CGFloat(((CGFloat(arc4random_uniform(101))/100.0) * lRange)))/100.0
        
        return SKColor(hue: 0, saturation: 0, brightness: l, alpha: 1)
    }
    
    //Get a random chunk back
    func randomChunk(currentChunk: Int, endChunk: Int, avoidOnly: Bool) -> [SKShapeNode]{
        if(currentChunk > endChunk){
            return loadChunk(map: LevelChunks.end, startingHeight: 1920).0
        }
        if !avoidOnly {
            return loadChunk(map: getChunkAtIndex(chunk: String(randRange(lower: 1, upper: 17))),startingHeight: 1920).0
        }
        else{
            return loadChunk(map: getChunkAtIndex(chunk: String(randRange(lower:101, upper: 110))), startingHeight: 1920).0
        }
    }
    
    //Get the chunk at a given index
    func getChunkAtIndex(chunk: String) -> [String]{
        var levelChunk: [String]
        switch(chunk){
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
            
            case "6":
                levelChunk = LevelChunks.six
            
            case "7":
                levelChunk = LevelChunks.seven
            
            case "8":
                levelChunk = LevelChunks.eight
            
            case "9":
                levelChunk = LevelChunks.nine
            
            case "10":
                levelChunk = LevelChunks.ten
            
            case "11":
                levelChunk = LevelChunks.eleven
            
            case "12":
                levelChunk = LevelChunks.twelve
            
            case "13":
                levelChunk = LevelChunks.thirteen
            
            case "14":
                levelChunk = LevelChunks.fourteen
            
            case "15":
                levelChunk = LevelChunks.fifteen
            
            case "16":
                levelChunk = LevelChunks.sixteen
            
            case "17":
                levelChunk = LevelChunks.seventeen
            
            case "101":
                levelChunk = LevelChunks.aOne //aOne = first avoid map
            
            case "102":
                levelChunk = LevelChunks.aTwo
            
            case "103":
                levelChunk = LevelChunks.aThree
            
            case "104":
                levelChunk = LevelChunks.aFour
            
            case "105":
                levelChunk = LevelChunks.aFive
            
            case "106":
                levelChunk = LevelChunks.aSix
            
            case "107":
                levelChunk = LevelChunks.aSeven
            
            case "108":
                levelChunk = LevelChunks.aEight
            
            case "109":
                levelChunk = LevelChunks.aNine
            
            case "110":
                levelChunk = LevelChunks.aTen
            
            default:
                levelChunk = LevelChunks.end
        
        }
        return levelChunk
    }

    //Get the level at index
    func getLevelAtIndex(index: Int, avoidOnly: Bool) -> String{
        if(avoidOnly){
            switch index{
                case 1:
                    return LevelMaps.aOne
                case 2:
                    return LevelMaps.aTwo
                default:
                    return LevelMaps.aThree
            }
        }
        else{
            switch index{
                case 1:
                    return LevelMaps.one
                case 2:
                    return LevelMaps.two
                default:
                    return LevelMaps.three
            }
        }
    }

    //Generate random number
    func randRange (lower: UInt32 , upper: UInt32) -> UInt32 {
        return lower + arc4random_uniform(upper - lower + 1)
    }
}

//Maps
struct LevelMaps{
    static let one :String = "1,1,2,2,3,4,5,5"
    static let two :String = "6,7,8,9,10,10,11,11,12,13,12,13"
    static let three :String = "14,14,15,15,16,16,17,17"
    
    static let aOne :String = "101,102,103,104,105"
    static let aTwo :String = "106,108,107,110,109"
    static let aThree :String = "109,110,103,109,101,104"
}
