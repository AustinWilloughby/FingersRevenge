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
    let scoreLabel = SKLabelNode(fontNamed: GameData.font.mainFont)
    let pauseLabel = SKLabelNode(fontNamed: GameData.font.mainFont)
    let shootLabel = SKLabelNode(fontNamed: GameData.font.mainFont)
    var screenBlocker: RectangleSprite
    
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
    
    var levelManager:LevelManager
    
    
    var healthBar:SKSpriteNode = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "ThreeHealth")))
    
    var playerHealth:Int = 3{
        didSet{
            switch playerHealth{
            case 0:
                healthBar.removeFromParent()
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
        levelManager = LevelManager()
        screenBlocker = RectangleSprite(size: playableRect.size, fillColor: SKColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.6), strokeColor: SKColor.clear)
        
        super.init(size: size)
        self.scaleMode = scaleMode
        
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle -
    override func didMove(to view: SKView){
        setupUI()
        
        //Set up everything on the screen
        tap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        tap.delegate = self
        
        
        pan = UIPanGestureRecognizer(target: self, action: #selector(panDetected))
        pan.delegate = self

        view.addGestureRecognizer(pan)
        view.addGestureRecognizer(tap)
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        playerSprite.position = CGPoint(x: size.width/2, y:size.height/2)
        playerSprite.zPosition = 3
        playerSprite.name = "player"
        playerSprite.physicsBody = SKPhysicsBody.init(polygonFrom: playerSprite.path!)
        playerSprite.physicsBody?.isDynamic = true
        playerSprite.physicsBody?.categoryBitMask = CollisionMask.player
        playerSprite.physicsBody?.contactTestBitMask = CollisionMask.wall | CollisionMask.finish | CollisionMask.gate | CollisionMask.unbreakable
        playerSprite.physicsBody?.collisionBitMask = CollisionMask.none
        
        addChild(playerSprite)

        
        pauseLabel.fontColor = SKColor.lightGray
        pauseLabel.fontSize = GameData.hud.fontSize * 1.3
        
        pauseLabel.verticalAlignmentMode = .center
        pauseLabel.horizontalAlignmentMode = .center
        pauseLabel.text = "Move Diamond to Begin"
        pauseLabel.position = playerSprite.position
        pauseLabel.position.y = pauseLabel.position.y + 425
        
        pauseLabel.zPosition = 2
        addChild(pauseLabel)
        
        shootLabel.fontColor = SKColor.lightGray
        shootLabel.fontSize = GameData.hud.fontSize * 0.9
        
        shootLabel.verticalAlignmentMode = .center
        shootLabel.horizontalAlignmentMode = .center
        shootLabel.text = "Tap With Second Finger to Shoot"
        shootLabel.position = playerSprite.position
        shootLabel.position.y = pauseLabel.position.y - 50
        
        shootLabel.zPosition = 2
        addChild(shootLabel)
        
        
        screenBlocker = RectangleSprite(size: playableRect.size, fillColor: SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6), strokeColor: SKColor.clear)
        screenBlocker.zPosition = 1
        screenBlocker.position = CGPoint(x: size.width/2, y:size.height/2)
        addChild(screenBlocker)
        
        setPauseState(gamePaused: true)
    }
    
    
    
    deinit{
        // TODO: Clean up resources, timers, listeners, etc . . .
    }
    
    // MARK: - Helpers -
    private func setupUI(){
        playableRect = getPlayableRectPhonePortrait(size: size)
        let marginH = GameData.hud.marginH
        let marginV = GameData.hud.marginV
        
        backgroundColor = GameData.hud.backgroundColor 
        
        healthBar.anchorPoint = CGPoint(x: 0, y: 1)
        healthBar.position = CGPoint(x: 0, y: playableRect.height)
        healthBar.zPosition = 2
        addChild(healthBar)
        
        scoreLabel.fontColor = GameData.hud.fontColorWhite
        scoreLabel.fontSize = GameData.hud.fontSize

        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.horizontalAlignmentMode = .left
          // next 2 lines calculate the max width of scoreLabel
        scoreLabel.text = "Score: 0000"
        let scoreLabelWidth = scoreLabel.frame.size.width
        
          // here is the starting text of scoreLabel
        scoreLabel.text = "Score: \(levelScore)"
        
        scoreLabel.position = CGPoint(x: playableRect.maxX - scoreLabelWidth - marginH,y: playableRect.maxY - marginV)
        scoreLabel.zPosition = 2
        addChild(scoreLabel)
        
        //If the game is stil progressing, load the right level. Otherwise start the first chunk of endless
        if(GameData.level >= 4){
            //Endless start
            var level:[RectangleSprite] = levelManager.randomChunk()
            for i in 0 ..< level.count{
                addChild(level[i])
            }
        }
        else{
            var level:[RectangleSprite] = levelManager.loadMap(map: levelManager.getLevelAtIndex(index: GameData.level))
            for i in 0 ..< level.count{
                addChild(level[i])
            }
        }
        
    }
    
    //Calculate time since last cycle
    func calculateDeltaTime(currentTime: TimeInterval){
        if lastUpdateTime > 0 {
            dt = currentTime - lastUpdateTime
        }
        else{
            dt = 0
        }
        lastUpdateTime = currentTime
    }
    
    //Move all of the sprites
    func moveSprites(dt:CGFloat){
        if spritesMoving{
            enumerateChildNodes(withName: "projectile", using: {
                node, stop in
                let s = node as! ProjectileSprite
                s.update(dt: dt)
            })
            
            var count:Int = 0
            enumerateChildNodes(withName: "obstacle", using:{
                node, stop in
                count += 1
                let o = node as! RectangleSprite
                o.update(dt: dt)
            })
            
            //If there are no more obstacles, generate new ones (for endless mode)
            if(count <= 0){
                var level:[RectangleSprite] = levelManager.randomChunk()
                for i in 0 ..< level.count{
                    addChild(level[i])
                }
            }
        }
    }
    
    //Unpause actions
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
        //Handle gesture recognition
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
    
    //handle tapping
    func tapDetected(_ sender:UITapGestureRecognizer){
        if spritesMoving == true{
            if sender.state == .ended{
                var touchLocation = sender.location(in: sender.view)
                touchLocation = self.convertPoint(fromView: touchLocation)
                let s = ProjectileSprite(size: SKTexture(image: #imageLiteral(resourceName: "NailClipping")).size())
                s.name = "projectile"
                s.position = playerSprite.position
                s.zPosition = CGFloat(-1)
                let offset = touchLocation - s.position
                addChild(s)
                let direction = offset.normalized()
                let shootAmount = direction * 2300
                let realDest = shootAmount + s.position
                s.rotateToDirection(dest: realDest)
                let actionMove = SKAction.move(to: realDest, duration: 0.5)
                let actionMoveDone = SKAction.removeFromParent()
                s.run(SKAction.sequence([actionMove, actionMoveDone]))
                self.levelScore -= 1
                
                playNailClip()
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer:UIGestureRecognizer, shouldRecognizeSimultaneouslyWith: UIGestureRecognizer) -> Bool{
        return (gestureRecognizer == tap && shouldRecognizeSimultaneouslyWith == pan)
    }
    
    func projectileDidCollideWithWall(projectile: ProjectileSprite, wall: RectangleSprite){
        projectile.removeFromParent()
        wall.removeFromParent()
    }
    
    
    
    //Checking collisions
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //Projectile Collision with Destructible Rect
        if((firstBody.categoryBitMask == CollisionMask.wall) && (secondBody.categoryBitMask == CollisionMask.projectile)){
            if firstBody.node != nil && secondBody.node != nil{
                let rectangleNode = firstBody.node as! RectangleSprite
                let projectileNode = secondBody.node as! ProjectileSprite
                if(!projectileNode.hit)
                {
                    rectangleNode.takeDamage()
                }
                projectileNode.hit = true
                projectileNode.removeFromParent()
            }
        }
        
        //Projectile with Button
        if((firstBody.categoryBitMask == CollisionMask.button) && (secondBody.categoryBitMask == CollisionMask.projectile)){
            if firstBody.node != nil && secondBody.node != nil{
                let rectangleNode = firstBody.node as! RectangleSprite
                let projectileNode = secondBody.node as! ProjectileSprite
                if(!projectileNode.hit)
                {
                    rectangleNode.destroyGates()
                    rectangleNode.takeDamage()
                    rectangleNode.takeDamage()
                }
                projectileNode.hit = true
                projectileNode.removeFromParent()
            }
        }
        
        //Projectile with Gate
        if((firstBody.categoryBitMask == CollisionMask.gate || firstBody.categoryBitMask == CollisionMask.unbreakable) && (secondBody.categoryBitMask == CollisionMask.projectile))
        {
            if(secondBody.node != nil)
            {
                let projectileNode = secondBody.node as! ProjectileSprite
                projectileNode.hit = true
                projectileNode.removeFromParent()
            }
        }
        
        //Player collides with obstacles
        if((firstBody.categoryBitMask == CollisionMask.wall || firstBody.categoryBitMask == CollisionMask.gate || firstBody.categoryBitMask == CollisionMask.unbreakable) && (secondBody.categoryBitMask == CollisionMask.player)){
            
            playerHealth -= 1
            if(playerHealth <= 0)
            {
                sceneManager.loadGameOverScene(results: LevelResults(levelNum: self.levelNum, levelScore: self.levelScore, totalScore: self.totalScore, msg: ""))
            }
            else{
                let wallNode = firstBody.node as! RectangleSprite
                wallNode.removeFromParent()
            }
        }
        
        //Player Colliding with Finish Line
        if((firstBody.categoryBitMask == CollisionMask.player) && (secondBody.categoryBitMask == CollisionMask.finish)){
            GameData.level += 1
            sceneManager.loadLevelFinishScene(results: LevelResults(levelNum: self.levelNum, levelScore: self.levelScore, totalScore: self.totalScore, msg: ""))
        }
    }
    
    
    // MARK: - Game Loop -
    override func update(_ currentTime: TimeInterval){
        calculateDeltaTime(currentTime: currentTime)
        arrayOfPlayers=arrayOfPlayers.filter(){$0.isPlaying}
        
        if spritesMoving {
            moveSprites(dt: CGFloat(dt))
            if spritesMoving{
                obstacleSpawnTimer = obstacleSpawnTimer - dt
                if(obstacleSpawnTimer <= 0)
                {
                    levelScore += 100;
                    obstacleSpawnTimer = obstacleInterval
                }
            }
        }
    }
    
    //pause or unpause
    func setPauseState(gamePaused: Bool){
        spritesMoving = !gamePaused
        playerSprite.canMove = !gamePaused
        enumerateChildNodes(withName: "projectile", using:{
            node, stop in
            let d = node as! ProjectileSprite
            d.isPaused = gamePaused
        })
        
        if(gamePaused == true){
            if(playerSprite.position.y > playableRect.maxY - 500)
            {
                pauseLabel.position.x = playableRect.maxX / 2
                pauseLabel.position.y = playerSprite.position.y - 225
            }
            else{
                pauseLabel.position.x = playableRect.maxX / 2
                pauseLabel.position.y = playerSprite.position.y + 225
            }
            pauseLabel.fontColor = SKColor.lightGray
            screenBlocker.fillColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.6)
        }
        else{
            shootLabel.isHidden = true
            pauseLabel.text = "Move Diamond to Resume"
            screenBlocker.fillColor = SKColor.clear
            pauseLabel.fontColor = SKColor.clear
        }
    }
}
