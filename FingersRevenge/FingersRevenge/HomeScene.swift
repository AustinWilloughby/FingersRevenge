//
//  HomeScene.swift
//  FingersRevenge
//
//  Created by Austin Willoughby on 9/22/16.
//  Copyright © 2016 Austin Willoughby / Peter Lockhart. All rights reserved.
//

import SpriteKit

class HomeScene: SKScene {
    // MARK: - ivars -
    let sceneManager:GameViewController
    let button:SKLabelNode = SKLabelNode(fontNamed: GameData.font.mainFont)
    let classicButton: RectangleSprite = RectangleSprite(size: CGSize(width: 700, height: 200 ), fillColor: SKColor.white, strokeColor: SKColor.black)
    let avoidButton: RectangleSprite = RectangleSprite(size: CGSize(width: 700, height: 200), fillColor: SKColor.white, strokeColor: SKColor.black)
    let audioNode:SKNode = SKNode()
    
    
    // MARK: - Initialization -
    init(size: CGSize, scaleMode:SKSceneScaleMode, sceneManager:GameViewController){
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been inplemented")
    }
    
    //Set up scene
    override func didMove(to view: SKView) {
        backgroundColor = GameData.scene.backgroundColor
        let fingerLogo = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "fingersLogo")))
        let label2 = SKLabelNode(fontNamed: "AvenirNextCondensed-HeavyItalic")
        
        fingerLogo.size = CGSize(width: fingerLogo.size.width * 0.9 , height: fingerLogo.size.height * 0.9)
        
        fingerLogo.position = CGPoint(x:size.width/2, y:size.height/2 + 650)
        
        label2.text = "Revenge"
        label2.fontSize = 250
        label2.position = CGPoint(x:size.width/2, y:size.height/2 + 350)
        
        fingerLogo.zPosition = 1
        label2.zPosition = 1
        
        addChild(fingerLogo)
        addChild(label2)
        
        classicButton.position = CGPoint(x: size.width/2, y: size.height/2 - 250)
        classicButton.lineWidth = 10
        addChild(classicButton)
        
        avoidButton.position = CGPoint(x: size.width/2, y: size.height/2 - 600)
        avoidButton.lineWidth = 10
        addChild(avoidButton)
        
        let label4 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label4.verticalAlignmentMode = .center
        label4.horizontalAlignmentMode = .center
        label4.text = "Classic Mode"
        label4.fontColor = UIColor.black
        label4.fontSize = 70
        label4.position = CGPoint(x:size.width/2, y:size.height/2 - 250)
        addChild(label4)
        
        let label5 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label5.verticalAlignmentMode = .center
        label5.horizontalAlignmentMode = .center
        label5.text = "Avoidance Mode"
        label5.fontColor = UIColor.black
        label5.fontSize = 70
        label5.position = CGPoint(x:size.width/2, y:size.height/2 - 600)
        addChild(label5)
        
        self.addChild(audioNode)
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        let touch = touches.first!
        
        if classicButton.contains(touch.location(in: self)){
            audioNode.run(SKAction.playSoundFileNamed("Ding.mp3", waitForCompletion: true))
            sceneManager.loadGameScene(levelNum: 1, totalScore: 0, avoidMode: false)
        }
        else if avoidButton.contains(touch.location(in: self)){
            audioNode.run(SKAction.playSoundFileNamed("Ding.mp3", waitForCompletion: true))
            sceneManager.loadGameScene(levelNum: 1, totalScore: 0, avoidMode: true)
        }
    }
}
