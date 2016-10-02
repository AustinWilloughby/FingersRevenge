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



class GameScene: SKScene, UIGestureRecognizerDelegate, SKPhysicsContactDelegate {
    // MARK: - ivars -
    var levelNum:Int
    var totalScore:Int
    
    let sceneManager:GameViewController
    
    var playableRect = CGRect.zero
    var totalSprites = 0
    
    var playerSprite = PlayerSprite(size: CGSize(width: 200, height: 200), lineWeight: 10, strokeColor: SKColor.white, fillColor: SKColor.lightGray)
    let levelLabel = SKLabelNode(fontNamed: GameData.font.mainFont)
    let scoreLabel = SKLabelNode(fontNamed: GameData.font.mainFont)
    
    var tap:UITapGestureRecognizer = UITapGestureRecognizer()
    var pan:UIPanGestureRecognizer = UIPanGestureRecognizer()
    
    var lastUpdateTime: TimeInterval = 0
    var dt: TimeInterval = 0
    var spritesMoving = true
    
    //obstacl spawning ivars
    var obstacleInterval = 1.5
    var obstacleSpawnTimer = 1.5
    
    var tapCount = 0 // 3 taps and the game is over!
    
    var previousPanX:CGFloat = 0.0
    var playerTouch:UITouch?
    
    
    var healthBar:SKSpriteNode = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "ThreeHealth")))
    
    var playerHealth:Int = 3{
        didSet{
            switch playerHealth{
            case 1:
                healthBar.texture = SKTexture(image: #imageLiteral(resourceName: "OneHealth"))
            case 2:
                healthBar.texture = SKTexture(image: #imageLiteral(resourceName: "TwoHealth"))
            default:
                healthBar.texture = SKTexture(image: #imageLiteral(resourceName: "ThreeHealth"))
            }
        }
    }

    
    // MARK: - ivars with observers -
    var levelScore:Int = 0{
        didSet
        {
            if levelScore < 0{
                levelScore = 0
            }
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
        
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func didMove(to view: SKView){
        setupUI()
        makeSprites(howMany: 1)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        tap.delegate = self
        
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(panDetected))
        pan.delegate = self

        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)
        
        playerSprite.position = CGPoint(x: size.width/2, y:size.height/2 - 700)
        playerSprite.name = "player"
        playerSprite.physicsBody = SKPhysicsBody.init(polygonFrom: playerSprite.path!)
        playerSprite.physicsBody?.isDynamic = false
        playerSprite.physicsBody?.categoryBitMask = CollisionMask.player
        playerSprite.physicsBody?.contactTestBitMask = CollisionMask.wall
        playerSprite.physicsBody?.collisionBitMask = CollisionMask.none
        addChild(playerSprite)
        
        setPauseState(gamePaused: true)
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
        
//        levelLabel.fontColor = fontColor
//        levelLabel.fontSize = fontSize
//        levelLabel.position = CGPoint(x: marginH,y: playableRect.maxY - marginV)
//        levelLabel.verticalAlignmentMode = .top
//        levelLabel.horizontalAlignmentMode = .left
//        levelLabel.text = "Level: \(levelNum)"
//        addChild(levelLabel)
        
        healthBar.anchorPoint = CGPoint(x: 0, y: 1)
        healthBar.position = CGPoint(x: 0, y: playableRect.height)
        addChild(healthBar)
        
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
        
        o.physicsBody = SKPhysicsBody.init(polygonFrom: o.path!)
        o.physicsBody?.isDynamic = false
        o.physicsBody?.categoryBitMask = CollisionMask.wall
        o.physicsBody?.contactTestBitMask = CollisionMask.projectile
        o.physicsBody?.collisionBitMask = CollisionMask.none
        addChild(o)
    }
    
    func makeSprites(howMany:Int){
        totalSprites = totalSprites + howMany
        var s:DiamondSprite
        if howMany > 0{
            for _ in 0...howMany-1{
                s = DiamondSprite(size: CGSize(width: 60, height: 100), lineWeight: 10, strokeColor: SKColor.green, fillColor: SKColor.magenta)
                s.name = "projectile"
                s.position = randomCGPointInRect(playableRect, margin: 300)
                s.fwd = CGPoint.randomUnitVector()
                s.physicsBody = SKPhysicsBody.init(polygonFrom: s.path!)
                s.physicsBody?.isDynamic = true
                s.physicsBody?.categoryBitMask = CollisionMask.projectile
                s.physicsBody?.contactTestBitMask = CollisionMask.wall
                s.physicsBody?.collisionBitMask = CollisionMask.none
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
            enumerateChildNodes(withName: "projectile", using: {
                node, stop in
                let s = node as! DiamondSprite
                let halfWidth = s.frame.width/2
                let halfHeight = s.frame.height/2
                
                s.update(dt: dt)
                
                // check left/right
                if s.position.x <= halfWidth || s.position.x >= self.size.width - halfWidth{
                    s.reflectX() //bounce
                    s.update (dt: dt) //make and extra move
                }
                
                //check top/bottom
                if s.position.y <= self.playableRect.minY + halfHeight || s.position.y >= self.playableRect.maxY - halfHeight{
                    s.reflectY() // bounce
                    s.update(dt: dt) // make an extra bounce
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
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if(playerSprite.canMove)
        {
        }
    }
    
    // MARK: - Actions -
    func panDetected(_ sender:UIPanGestureRecognizer) {
        sender.maximumNumberOfTouches = 1; // programming
        if sender.state == .began{
            var touchLocation = sender.location(in: sender.view)
            touchLocation = self.convertPoint(fromView: touchLocation)
            let touchedNodes = self.nodes(at: touchLocation)
            for sprite in touchedNodes{
                if let name = sprite.name{
                    if name == "player"
                    {
                        playerSprite.changeColor(strokeColor: SKColor.clear, fillColor: SKColor.clear)
                        setPauseState(gamePaused: false)
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
                
            }
        }
        if(sender.state == .ended){
            playerSprite.changeColor(strokeColor: SKColor.white, fillColor: SKColor.lightGray)
            setPauseState(gamePaused: true)
        }
    }
    
    func tapDetected(_ sender:UITapGestureRecognizer){
        if spritesMoving == true{
            if sender.state == .ended{
                var touchLocation = sender.location(in: sender.view)
                touchLocation = self.convertPoint(fromView: touchLocation)
                var s = DiamondSprite(size: CGSize(width: 60, height: 100), lineWeight: 10, strokeColor: SKColor.green, fillColor: SKColor.magenta)
                s.name = "projectile"
//              s.physicsBody = SKPhysicsBody.init(polygonFrom: s.path!)
//              s.physicsBody?.isDynamic = true
//              s.physicsBody?.categoryBitMask = CollisionMask.projectile
//              s.physicsBody?.contactTestBitMask = CollisionMask.wall
//              s.physicsBody?.collisionBitMask = CollisionMask.none
                s.position = playerSprite.position
                let offset = touchLocation - s.position
                addChild(s)
                let direction = offset.normalized()
                let shootAmount = direction * 2300
                let realDest = shootAmount + s.position
                let actionMove = SKAction.move(to: realDest, duration: 0.5)
                let actionMoveDone = SKAction.removeFromParent()
                s.run(SKAction.sequence([actionMove, actionMoveDone]))
                self.levelScore -= 1
                self.playerHealth -= 1
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer:UIGestureRecognizer, shouldRecognizeSimultaneouslyWith: UIGestureRecognizer) -> Bool{
        return (gestureRecognizer == tap && shouldRecognizeSimultaneouslyWith == pan)
    }
    
    func projectileDidCollideWithWall(projectile: DiamondSprite, wall: RectangleSprite){
        print("hit")
        projectile.removeFromParent()
        wall.removeFromParent()
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
    }
    
    
    // MARK: - Game Loop -
    override func update(_ currentTime: TimeInterval){
        if spritesMoving {
            calculateDeltaTime(currentTime: currentTime)
            moveSprites(dt: CGFloat(dt))
            if spritesMoving{
                obstacleSpawnTimer = obstacleSpawnTimer - dt
                if(obstacleSpawnTimer <= 0)
                {
                    addObstacle()
                    levelScore += 5;
                    obstacleSpawnTimer = obstacleInterval
                }
            }
        }
    }
    
    func setPauseState(gamePaused: Bool){
        spritesMoving = !gamePaused
        playerSprite.canMove = !gamePaused
        
        enumerateChildNodes(withName: "projectile", using:{
            node, stop in
            let d = node as! DiamondSprite
            d.isPaused = gamePaused
        })
    }
}
