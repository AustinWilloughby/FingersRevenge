//
//  GameScene.swift
//  FingersRevenge
//
//  Created by Austin Willoughby on 9/22/16
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

class GameScene: SKScene, UIGestureRecognizerDelegate {
    // MARK: - ivars -
    var levelNum:Int
    var totalScore:Int
    let sceneManager:GameViewController
    
    var playableRect = CGRect.zero
    var totalSprites = 0
    
    var playerSprite = PlayerSprite(size: CGSize(width: 100, height: 100), lineWeight: 10, strokeColor: SKColor.white, fillColor: SKColor.lightGray)
    let levelLabel = SKLabelNode(fontNamed: GameData.font.mainFont)
    let scoreLabel = SKLabelNode(fontNamed: GameData.font.mainFont)
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = false
    
    //obstacl spawning ivars
    var obstacleInterval = 1.5
    var obstacleSpawnTimer = 1.5
    
    var tapCount = 0 // 3 taps and the game is over!
    
    var previousPanX:CGFloat = 0.0
    var playerTouch:UITouch!
    
    // MARK: - ivars with observers -
    var levelScore:Int = 0{
        didSet
        {
            scoreLabel.text = "Score: \(levelScore)"
            totalScore = totalScore + 1
        }
    }
    
    // MARK: - Initialization -
    init(size: CGSize, scaleMode:SKSceneScaleMode, levelNum:Int, totalScore:Int, sceneManager:GameViewController){
        self.levelNum = levelNum
        self.totalScore = totalScore
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
        
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panDetected))
        pan.delegate = self
        view?.addGestureRecognizer(pan)
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func didMove(to view: SKView){
        setupUI()
        makeSprites(howMany: 1)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panDetected))
        pan.delegate = self
        view.addGestureRecognizer(pan)
        
        playerSprite.position = CGPoint(x: size.width/2, y:size.height/2 - 700)
        playerSprite.name = "player"
        addChild(playerSprite)
        
        //unpauseSprites()
    }
    
    
    
    deinit{
        // TODO: Clean up resources, timers, listeners, etc . . .
    }
    
    // MARK: - Helpers -
    private func setupUI(){
        playableRect = getPlayableRectPhonePortrait(size: size)
        let fontSize = GameData.hud.fontSize
        let fontColor = GameData.hud.fontColorWhite
        let marginH = GameData.hud.marginH
        let marginV = GameData.hud.marginV
        
        backgroundColor = GameData.hud.backgroundColor
        
        levelLabel.fontColor = fontColor
        levelLabel.fontSize = fontSize
        levelLabel.position = CGPoint(x: marginH,y: playableRect.maxY - marginV)
        levelLabel.verticalAlignmentMode = .top
        levelLabel.horizontalAlignmentMode = .left
        levelLabel.text = "Level: \(levelNum)"
        addChild(levelLabel)
        
        scoreLabel.fontColor = fontColor
        scoreLabel.fontSize = fontSize
        
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .left
        // next 2 lines calculate the max width of scoreLabel
        scoreLabel.text = "Score: 0000"
        let scoreLabelWidth = scoreLabel.frame.size.width
        
        // here is the starting text of scoreLabel
        scoreLabel.text = "Score: \(levelScore)"
        
        scoreLabel.position = CGPoint(x: playableRect.maxX - scoreLabelWidth - marginH,y: playableRect.maxY - marginV)
        addChild(scoreLabel)
        
    }
    
    //adds an obstacle to the top of the screen
    func addObstacle(){
        var o:RectangleSprite
        o = RectangleSprite(size: CGSize(width: 300, height: 80), fillColor:SKColor.green)
        o.name = "obstacle"
        let x = arc4random_uniform(UInt32(playableRect.width))
        let y = playableRect.height
        o.position = CGPoint(x: CGFloat(x), y: CGFloat(y))
        addChild(o)
    }
    
    func makeSprites(howMany:Int){
        totalSprites = totalSprites + howMany
        var s:DiamondSprite
        if howMany > 0{
            for _ in 0...howMany-1{
                s = DiamondSprite(size: CGSize(width: 60, height: 100), lineWeight: 10, strokeColor: SKColor.green, fillColor: SKColor.magenta)
                s.name = "diamond"
                s.position = randomCGPointInRect(playableRect, margin: 300)
                s.fwd = CGPoint.randomUnitVector()
                addChild(s)
            }
        }
    }
    
    func calculateDeltaTime(currentTime: TimeInterval){
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else{
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    func moveSprites(dt:CGFloat){
        if spritesMoving{
            enumerateChildNodes(withName: "diamond", using: {
                node, stop in
                let s = node as! DiamondSprite
                let halfWidth = s.frame.width/2
                let halfHeight = s.frame.height/2
                
                s.update(dt: dt)
                
                // check left/right
                if s.position.x <= halfWidth || s.position.x >= self.size.width - halfWidth{
                    s.reflectX() //bounce
                    s.update (dt: dt) //make and extra move
                    self.levelScore = self.levelScore + 1 // lamest game ever "bounce and win"
                }
                
                //check top/bottom
                if s.position.y <= self.playableRect.minY + halfHeight || s.position.y >= self.playableRect.maxY - halfHeight{
                    s.reflectY() // bounce
                    s.update(dt: dt) // make an extra bounce
                    self.levelScore = self.levelScore + 1 // lamest game ever - "bounce n win"
                }
            })
            
            enumerateChildNodes(withName: "obstacle", using:{
                node, stop in
                let o = node as! RectangleSprite
                o.update(dt: dt)
            })
        }
    }
    
    func unpauseSprites (){
        let unpauseAction = SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.run({self.spritesMoving = true})
            ])
        run(unpauseAction)
    }
    
    // MARK: - Events -
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        if let touch = touches.first{
            let positionInScene = touch.location(in: self)
            let touchedNodes = self.nodes(at: positionInScene)
            for sprite in touchedNodes{
                if let name = sprite.name{
                    if name == "player"
                    {
                        print("touched")
                        //spritesMoving = true
                    }
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?){
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
            }
    
    
    // MARK: - Actions -
    func panDetected(_ sender:UIPanGestureRecognizer) {
//        // retrieve pan movement along the x-axis of the view since the gesture began
//        let currentPanX = sender.translation(in: view!).x
//        print("currentPanX since gesture began = \(currentPanX)")
//        
//        // calculate deltaX since last measurement
//        let deltaX = currentPanX - previousPanX
//        playerSprite.position = CGPoint(x: playerSprite.position.x + (deltaX * 2), y: playerSprite.position.y)
//        
//        // if the gesture has completed
//        if sender.state == .ended {
//            previousPanX = 0
//        } else {
//            previousPanX = currentPanX
//        }
        if sender.state == .began{
            var touchLocation = sender.location(in: sender.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            let touchedNodes = self.nodes(at: touchLocation)
            for sprite in touchedNodes{
                if let name = sprite.name{
                    if name == "player"
                    {
                        playerSprite.canMove = true
                        spritesMoving = true
                    }
                }
            }
        }
        if(sender.state == .changed){
            if(playerSprite.canMove)
            {
                var touchLocation = sender.location(in: sender.view)
                touchLocation = self.convertPoint(fromView: touchLocation)
                playerSprite.position = touchLocation
//                var translation = sender.translation(in: sender.view)
//                translation = CGPoint(x: translation.x, y: -translation.y)
//                playerSprite.position = CGPoint(x: playerSprite.position.x + translation.x, y: playerSprite.position.y + translation.y)
//                sender.setTranslation(CGPoint(x: 0, y:0), in: sender.view)
            }
        }
        if(sender.state == .ended){
            spritesMoving = false
            playerSprite.canMove = false
        }
    }
    
    
    // MARK: - Game Loop -
    override func update(_ currentTime: TimeInterval){
        calculateDeltaTime(currentTime: currentTime)
        moveSprites(dt: CGFloat(dt))
        if spritesMoving{
            obstacleSpawnTimer = obstacleSpawnTimer - dt
            if(obstacleSpawnTimer <= 0)
            {
                addObstacle()
                obstacleSpawnTimer = obstacleInterval
            }
        }
    }
}
