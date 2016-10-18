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
    
    
    // MARK: - Initialization -
    init(size: CGSize, scaleMode:SKSceneScaleMode, sceneManager:GameViewController){
        self.sceneManager = sceneManager
        super.init(size: size)
        self.scaleMode = scaleMode
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been inplemented")
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = GameData.scene.backgroundColor
        let fingerLogo = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName: "fingersLogo")))
        let label2 = SKLabelNode(fontNamed: "AvenirNextCondensed-HeavyItalic")
        
        fingerLogo.size = CGSize(width: fingerLogo.size.width * 0.9 , height: fingerLogo.size.height * 0.9)
        
        fingerLogo.position = CGPoint(x:size.width/2, y:size.height/2 + 400)
        
        label2.text = "Revenge"
        label2.fontSize = 250
        label2.position = CGPoint(x:size.width/2, y:size.height/2 + 100)
        
        fingerLogo.zPosition = 1
        label2.zPosition = 1
        
        addChild(fingerLogo)
        addChild(label2)
        
        let label4 = SKLabelNode(fontNamed: GameData.font.mainFont)
        label4.text = "Place Finger on Diamond To Play"
        label4.fontColor = UIColor.lightGray
        label4.fontSize = 70
        label4.position = CGPoint(x:size.width/2, y:size.height/2 - 700)
        addChild(label4)
        
        var s:DiamondSprite;
        s = DiamondSprite(size: CGSize(width: 100, height: 100), lineWeight: 10, strokeColor: SKColor.white, fillColor: SKColor.lightGray)
        s.position = CGPoint(x: size.width/2, y:size.height/2 - 300)
        addChild(s)
        
        
    }
    
    override func touchesBegan(_ touchces: Set<UITouch>, with event: UIEvent?){
        sceneManager.loadGameScene(levelNum: 1, totalScore: 0)
    }
}
